"""Time complete GPU graph updates and compare all returned canonical bytes."""

import ctypes as ct
import json
import hashlib
from pathlib import Path
import time

import numpy as np

import runtime


def require_verified(model, names):
    """Reject comparative timing without current scientific and graph evidence."""
    frozen = runtime.fingerprint()
    for name in names:
        suffix = name if name.startswith("julia") else "native"
        folder = runtime.ROOT / "bench/.runs/gpu" / model
        scientific = json.loads((folder / ("verification-" + suffix + ".json")).read_text())
        graph = json.loads((folder / ("graphs-" + suffix + ".json")).read_text())
        if not scientific["passed"] or not graph["passed"]:
            raise RuntimeError("Scientific and graph verification must pass before timing.")
        if name not in scientific["implementations"] or name not in {row["name"] for row in graph["records"]}:
            raise RuntimeError("The requested implementation has no current verification evidence.")
        if scientific["fingerprint"] != frozen or graph["fingerprint"] != frozen:
            raise RuntimeError("Sources or binaries changed after verification. Verify again before timing.")


def inputs(protocol, eb, model, size):
    if model == "eb":
        seed, coeff, par, _ = eb.inputs(size)
        return eb.Buffers(seed, coeff, par)
    seed = protocol._initial("mixed", size, size)
    par, _ = protocol._parameters(size, size, "mixed")
    return protocol._Buffers(seed, par)


def reference(protocol, eb, model, host, steps, folder, cpu_sw, cpu_eb):
    signature = hashlib.sha256(str(steps).encode() + b"".join(
        getattr(host, name).tobytes() for name in (("q", "coeff", "par") if model == "eb" else ("q", "parameters"))) +
        (runtime.ROOT / "bench/.build" / ("libeb_fortran_vanilla.so" if model == "eb" else "libsw_fortran_vanilla.so")).read_bytes()).hexdigest()
    cache = folder / "reference.npz"
    if cache.exists():
        with np.load(cache) as saved:
            if str(saved["signature"]) == signature:
                return saved["stage"].copy(), saved["final"].copy()
    backend = (cpu_eb if model == "eb" else cpu_sw)("fortran_vanilla")
    if model == "eb":
        backend.bind(host, steps)()
    else:
        backend.run(host, steps)
    final = host.out if steps % 2 else host.q
    for phase, values in ((1, host.stage), (2, final)):
        path = folder / ("reference-p%d.bin" % phase)
        if model == "eb":
            eb.write(path, values, host.coeff, host.par, steps, phase)
        else:
            protocol._write(path, values, host.parameters, steps, phase)
    np.savez(cache, signature=signature, stage=host.stage, final=final)
    return host.stage.copy(), final.copy()


def validate(protocol, eb, model, state, expected, host, steps, folder, name):
    arrays = {key: array.get() for key, array in state.arrays.items()}
    validate_arrays(protocol, eb, model, arrays, expected, host, steps, folder, name)


def validate_arrays(protocol, eb, model, arrays, expected, host, steps, folder, name):
    for key in ("coeff", "par") if model == "eb" else ("parameters",):
        protocol._compare(getattr(host, key), arrays[key], name + " immutable input " + key)
    final = arrays["out"] if steps % 2 else arrays["q"]
    for phase, values in ((1, arrays["stage"]), (2, final)):
        protocol._compare(expected[phase - 1], values, name + " graph phase %d" % phase)
        if model == "eb":
            eb.admissible(values, host.coeff, host.par)
            eb.halo_check(values)
        else:
            protocol._admissible(values, host.parameters)
            protocol._halo_check(values)
        path = folder / (name + "-p%d.bin" % phase)
        if model == "eb":
            eb.write(path, values, host.coeff, host.par, steps, phase)
        else:
            protocol._write(path, values, host.parameters, steps, phase)
        if path.read_bytes() != (folder / ("reference-p%d.bin" % phase)).read_bytes():
            raise AssertionError(name + " canonical graph files differ.")


def native(protocol, eb, model, names, sizes, counts, repeats, metadata, block, cpu_sw, cpu_eb, output, repeat_start=0):
    """Measure matched graphs in rotated order on shared native device arrays.

    Parameters
    ----------
    protocol, eb : module
        Existing canonical encoding and independent scientific checks.
    model : str
        sw or eb, selecting the frozen model.
    names : list of str
        GPU assembly and independently compiled native/Python controls.
    sizes, counts : list of int
        Interior sizes and matching complete step counts.
    repeats : int
        Number of accepted samples at each workload.
    metadata : dict
        Exclusive allocation, fixed GPU and host affinity.
    block : int
        Threads per block.
    cpu_sw, cpu_eb : class
        Unchanged vanilla CPU reference backends.
    output : Path
        JSON evidence destination.

    Returns
    -------
    dict
        Timings, validation, source hashes and actual quiet-node evidence.
    """
    backends = {name: runtime.Backend(name, model, block) for name in names}
    records = []
    try:
        for size, steps in zip(sizes, counts):
            folder = output.parent / (model + "-%d-%d" % (size, steps))
            folder.mkdir(parents=True, exist_ok=True)
            host = inputs(protocol, eb, model, size)
            expected = reference(protocol, eb, model, inputs(protocol, eb, model, size), steps, folder, cpu_sw, cpu_eb)
            started = time.perf_counter_ns()
            state = runtime.State(host, model)
            allocation_ns = time.perf_counter_ns() - started
            graphs, preparations = {}, {}
            for name, backend in backends.items():
                start = time.perf_counter_ns()
                backend.enqueue(state, 1)
                runtime.driver().gpu_sync()
                compile_warm_ns = time.perf_counter_ns() - start
                state.upload(host)
                start = time.perf_counter_ns()
                graphs[name] = backend.capture(state, steps)
                capture_ns = time.perf_counter_ns() - start
                nodes = ct.c_uint64()
                runtime.driver().gpu_graph_nodes(graphs[name], ct.byref(nodes))
                # Ordinary repeated entry and graph replay have separate checks.
                backend.enqueue(state, steps)
                validate(protocol, eb, model, state, expected, host, steps, folder, name + "-ordinary")
                state.upload(host)
                runtime.driver().gpu_graph_launch(graphs[name])
                validate(protocol, eb, model, state, expected, host, steps, folder, name + "-replay")
                preparations[name] = {"allocation_ns": allocation_ns, "compile_warm_ns": compile_warm_ns, "capture_ns": capture_ns,
                                      "graph_nodes": nodes.value}
            try:
                for repeat in range(repeat_start, repeat_start + repeats):
                    order = names[repeat % len(names):] + names[:repeat % len(names)]
                    for name in order:
                        before = runtime.quiet(metadata)
                        start = time.perf_counter_ns()
                        state.upload(host)
                        upload_ns = time.perf_counter_ns() - start
                        # Keep enough steady work outside the timer to raise clocks.
                        warmed = time.monotonic()
                        while time.monotonic() - warmed < 0.03:
                            runtime.driver().gpu_graph_launch(graphs[name])
                            runtime.driver().gpu_sync()
                            state.upload(host)
                        elapsed = ct.c_float()
                        begin_wall = time.perf_counter_ns()
                        runtime.driver().gpu_graph_time(graphs[name], ct.byref(elapsed))
                        host_wait_ns = time.perf_counter_ns() - begin_wall
                        after = runtime.observation(metadata)
                        pids = {int(line.split(",")[0]) for line in after["processes"]}
                        if pids - {__import__("os").getpid()} or after["load"][0] > 2.0:
                            raise RuntimeError("Foreign work disturbed the timed graph.")
                        start = time.perf_counter_ns()
                        arrays = {key: array.get() for key, array in state.arrays.items()}
                        download_ns = time.perf_counter_ns() - start
                        validate_arrays(protocol, eb, model, arrays, expected, host, steps, folder, name)
                        cells = size if model == "eb" else size * size
                        record = {"model": model, "size": size, "steps": steps, "name": name,
                                  "repeat": repeat, "order": order, "milliseconds": float(elapsed.value),
                                  "microseconds_per_step": float(elapsed.value) * 1000 / steps,
                                  "million_cell_steps_per_second": cells * steps / (elapsed.value * 1000),
                                  "host_wait_ns": host_wait_ns, "upload_ns": upload_ns, "download_ns": download_ns,
                                  "block": backends[name].block, "launch_layout": backends[name].layout(size, 1 if model == "eb" else size), "differing_bytes": 0,
                                  "before": before, "after": after, **preparations[name],
                                  "device_addresses": state.pointers()}
                        records.append(record)
                        print(json.dumps({key: record[key] for key in ("model", "size", "name", "repeat", "million_cell_steps_per_second")}), flush=True)
            finally:
                for graph in graphs.values():
                    runtime.driver().gpu_graph_close(graph)
                for array in state.arrays.values():
                    array.close()
        report = {"passed": True, "model": model, "implementations": names, "metadata": metadata,
                  "records": records, "fingerprint": runtime.fingerprint(),
                  "timer": "CUDA events around one replay of all complete steps",
                  "placement": "One shared set of guarded device arrays within this process"}
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(json.dumps(report, indent=2) + "\n")
        return report
    finally:
        for backend in backends.values():
            backend.close()


def worker_arrays(prefix, host, model):
    """Read every guarded Julia result after its worker checked device guards."""
    names = ("q", "stage", "out", "work", "coeff", "par") if model == "eb" else (
        "q", "stage", "out", "work", "parameters")
    values = np.fromfile(str(prefix) + ".raw", dtype="<f8")
    result, offset = {}, 0
    for name in names:
        shape = getattr(host, name).shape
        count = getattr(host, name).size
        result[name] = values[offset:offset + count].reshape(shape)
        offset += count
    if offset != values.size:
        raise AssertionError("The Julia snapshot has the wrong byte count.")
    return result


def julia(protocol, eb, model, name, sizes, counts, repeats, metadata, block, cpu_sw, cpu_eb,
          output, worker_class, repeat_start=0):
    """Time a sequential Julia process on the same GPU and validate its bytes."""
    worker = worker_class(name, model, block)
    records = []
    try:
        for size, steps in zip(sizes, counts):
            folder = output.parent / (model + "-%d-%d" % (size, steps))
            folder.mkdir(parents=True, exist_ok=True)
            host = inputs(protocol, eb, model, size)
            expected = reference(protocol, eb, model, inputs(protocol, eb, model, size), steps, folder, cpu_sw, cpu_eb)
            input_path = folder / "input.bin"
            if model == "eb":
                eb.write(input_path, host.q, host.coeff, host.par)
            else:
                protocol._write(input_path, host.q, host.parameters)
            for repeat in range(repeat_start, repeat_start + repeats):
                before = runtime.quiet(metadata, {worker.process.pid})
                prefix = folder / (name + "-%d" % repeat)
                fields = worker.command("BENCH", input_path, prefix, steps)
                if len(fields) != 10 or fields[0] != "TIME":
                    raise RuntimeError("Julia timing failed. See " + worker.log.name)
                elapsed = float(fields[1])
                after = runtime.observation(metadata)
                pids = {int(line.split(",")[0]) for line in after["processes"]}
                if pids - {worker.process.pid} or after["load"][0] > 2.0:
                    raise RuntimeError("Foreign work disturbed the Julia graph.")
                for suffix in ("-ordinary", "-replay", ""):
                    arrays = worker_arrays(str(prefix) + suffix, host, model)
                    validate_arrays(protocol, eb, model, arrays, expected, host, steps, folder, name + suffix)
                    Path(str(prefix) + suffix + ".raw").unlink()
                cells = size if model == "eb" else size * size
                record = {"model": model, "size": size, "steps": steps, "name": name,
                          "repeat": repeat, "order": [name], "milliseconds": elapsed,
                          "microseconds_per_step": elapsed * 1000 / steps,
                          "million_cell_steps_per_second": cells * steps / (elapsed * 1000),
                          "capture_ns": int(fields[2]), "compile_warm_ns": int(fields[3]),
                          "allocation_ns": int(fields[4]), "upload_ns": int(fields[5]),
                          "download_ns": int(fields[6]), "host_wait_ns": int(fields[7]),
                          "graph_nodes": int(fields[8]), "device_addresses": [int(value) for value in fields[9].split(",")],
                          "block": worker.block, "launch_layout": runtime.launch_layout(name, model, size, 1 if model == "eb" else size, worker.block),
                          "differing_bytes": 0, "before": before, "after": after}
                records.append(record)
                print(json.dumps({key: record[key] for key in ("model", "size", "name", "repeat", "million_cell_steps_per_second")}), flush=True)
        report = {"passed": True, "model": model, "implementations": [name], "metadata": metadata,
                  "records": records, "fingerprint": runtime.fingerprint(), "julia": worker.metadata,
                  "timer": "CUDA events around one replay of all complete steps",
                  "placement": "Separate sequential Julia worker with guarded device arrays on the same GPU UUID"}
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(json.dumps(report, indent=2) + "\n")
        return report
    finally:
        worker.close()


def graphs(protocol, eb, model, names, metadata, block, cpu_sw, cpu_eb, output, worker_class):
    """Check empty, odd and even graph schedules at one-cell and partial blocks."""
    selected = [name for name in names if name != "fortran_vanilla"]
    workers = {name: worker_class(name, model, block) for name in selected if name.startswith("julia")}
    backends = {name: runtime.Backend(name, model, block) for name in selected if name not in workers}
    records = []
    try:
        for size in ((1, 128, 129) if model == "eb" else (1, 129, 257)):
            for steps in (0, 3, 4):
                folder = output.parent / ("graph-%d-%d" % (size, steps))
                folder.mkdir(parents=True, exist_ok=True)
                host = inputs(protocol, eb, model, size)
                expected = None if steps == 0 else reference(protocol, eb, model, inputs(protocol, eb, model, size),
                                                            steps, folder, cpu_sw, cpu_eb)
                input_path = folder / "input.bin"
                if model == "eb":
                    eb.write(input_path, host.q, host.coeff, host.par)
                else:
                    protocol._write(input_path, host.q, host.parameters)
                state = None if workers else runtime.State(host, model)
                try:
                    for name in selected:
                        if name in workers:
                            prefix = folder / name
                            fields = workers[name].command("GRAPH", input_path, prefix, steps)
                            results = [worker_arrays(str(prefix) + suffix, host, model) for suffix in ("-ordinary", "-replay")]
                            nodes = int(fields[1])
                        else:
                            backend = backends[name]
                            backend.enqueue(state, 1)
                            runtime.driver().gpu_sync()
                            state.upload(host)
                            graph = backend.capture(state, steps)
                            count = ct.c_uint64()
                            try:
                                runtime.driver().gpu_graph_nodes(graph, ct.byref(count))
                                nodes = count.value
                                backend.enqueue(state, steps)
                                results = [{key: array.get() for key, array in state.arrays.items()}]
                                state.upload(host)
                                runtime.driver().gpu_graph_launch(graph)
                                results.append({key: array.get() for key, array in state.arrays.items()})
                            finally:
                                runtime.driver().gpu_graph_close(graph)
                                state.upload(host)
                        for phase, arrays in enumerate(results):
                            if steps == 0:
                                for key, values in arrays.items():
                                    protocol._compare(getattr(host, key), values, name + " empty graph " + key)
                            else:
                                validate_arrays(protocol, eb, model, arrays, expected, host, steps, folder,
                                                name + ("-ordinary" if phase == 0 else "-replay"))
                        effective = workers[name].block if name in workers else backends[name].block
                        layout = runtime.launch_layout(name, model, size, 1 if model == "eb" else size, effective) if name in workers else backends[name].layout(size, 1 if model == "eb" else size)
                        records.append({"name": name, "size": size, "steps": steps, "graph_nodes": nodes,
                                        "differing_bytes": 0, "block": effective, "launch_layout": layout})
                        print(json.dumps(records[-1]), flush=True)
                finally:
                    if state:
                        for array in state.arrays.values():
                            array.close()
        report = {"passed": True, "model": model, "metadata": metadata, "records": records,
                  "fingerprint": runtime.fingerprint()}
        output.write_text(json.dumps(report, indent=2) + "\n")
        return report
    finally:
        for worker in workers.values():
            worker.close()
        for backend in backends.values():
            backend.close()
