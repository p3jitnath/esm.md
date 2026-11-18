"""Expose retained complete compiled Python kernels through native callbacks."""

import hashlib
import importlib.util
import json
import os
from pathlib import Path
import platform
import re
import sys

HERE = Path(__file__).resolve().parent
os.environ.setdefault("NUMBA_CACHE_DIR", str(HERE / "cache"))
import llvmlite
from llvmlite import binding as llvm
import numba
from numba import carray, cfunc, types
import numpy as np

_CALLBACKS = {}
_MODULES = {}
P = types.CPointer(types.float64)
SW_SIGNATURE = types.void(types.int32, types.int32, P, P, P, P, P, types.int32)
EB_SIGNATURE = types.void(types.int32, P, P, P, P, P, P, types.int32)


def _module(model, variant):
    """Load a private numerical source without editing its original bytes.

    Parameters
    ----------
    model : {"sw", "ebm"}
        Shallow water or energy balance.
    variant : {"vanilla", "tuned"}
        Historical numerical implementation.

    Returns
    -------
    module
        Retained numerical functions with fast arithmetic disabled.
    """
    key = (model, variant)
    if key not in _MODULES:
        path = HERE / (model + "_" + variant + ".py")
        name = "fresh_" + model + "_" + variant
        spec = importlib.util.spec_from_file_location(name, path)
        module = importlib.util.module_from_spec(spec)
        sys.modules[name] = module
        spec.loader.exec_module(module)
        _MODULES[key] = module
    return _MODULES[key]


def _compile(model, variant):
    """Compile a complete serial-run entry for the common coordinator.

    Parameters
    ----------
    model : {"sw", "ebm"}
        Selects state dimensions and parameter count.
    variant : {"vanilla", "tuned"}
        Historical numerical implementation.

    Returns
    -------
    numba.core.ccallback.CFunc
        Owner of native callback machine code. Borrowed SW states have shape
        ``(3, ny+2, nx+2)`` with depth [m] and momenta [m2/s]. EBM states
        contain ``n+2`` temperatures [degrees Celsius]. State and scratch may
        change; parameters and coefficients remain unchanged.

    Notes
    -----
    Pointer views borrow disjoint caller storage. The admitted numerical path
    calls compiled machine code without Python interpretation or its lock.
    """
    run = _module(model, variant).run
    if model == "sw":

        @cfunc(SW_SIGNATURE, nopython=True, fastmath=False)
        def callback(nx, ny, q, stage, out, work, par, count):
            shape = (3, ny + 2, nx + 2)
            run(
                carray(q, shape),
                carray(stage, shape),
                carray(out, shape),
                carray(work, (5, ny + 2, nx + 2)),
                carray(par, (4,)),
                count,
            )

    else:

        @cfunc(EB_SIGNATURE, nopython=True, fastmath=False)
        def callback(n, q, stage, out, work, coeff, par, count):
            shape = (n + 2,)
            run(
                carray(q, shape),
                carray(stage, shape),
                carray(out, shape),
                carray(work, shape),
                carray(coeff, (3, n + 2)),
                carray(par, (6,)),
                count,
            )

    return callback


def build_routes(model):
    """Return retained native callbacks after all required compilation.

    Parameters
    ----------
    model : {"sw", "ebm"}
        Model to compile before restoring numerical inputs and timing them.

    Returns
    -------
    dict
        ``python_vanilla`` and ``python_tuned`` map to CFunc owners. Their
        ``address`` integer is the native complete-run function pointer.

    Raises
    ------
    ValueError
        If the model is unsupported.
    """
    if model not in ("sw", "ebm"):
        raise ValueError("Select sw or ebm.")
    if model not in _CALLBACKS:
        _CALLBACKS[model] = {
            "python_" + variant: _compile(model, variant)
            for variant in ("vanilla", "tuned")
        }
    return _CALLBACKS[model]


def compilation_record(model):
    """Save emitted LLVM and compiler and numerical-source identities.

    Parameters
    ----------
    model : {"sw", "ebm"}
        Model whose compiled callbacks are inspected without numerical calls.

    Returns
    -------
    dict
        Compiler versions, callback addresses, source hashes and arithmetic audit.

    Raises
    ------
    RuntimeError
        If emitted LLVM contains unsafe arithmetic flags or a fused operation.
    """
    result = {
        "python": platform.python_version(),
        "numpy": np.__version__,
        "numba": numba.__version__,
        "llvmlite": llvmlite.__version__,
        "cpu": llvm.get_host_cpu_name(),
        "fastmath": False,
        "native_callbacks": {},
    }
    for name, callback in build_routes(model).items():
        text = callback.inspect_llvm()
        operations = [
            line
            for line in text.splitlines()
            if re.search(r"\b(?:fadd|fsub|fmul|fdiv|frem|fcmp|call)\b", line)
        ]
        unsafe = [
            line
            for line in operations
            if re.search(
                r"\b(?:fast|reassoc|nnan|ninf|nsz|arcp|contract|afn)\b|llvm\.fma|llvm\.fmuladd",
                line,
            )
        ]
        if unsafe:
            raise RuntimeError(unsafe)
        artifact = HERE / (model + "_" + name + ".ll")
        artifact.write_text(text)
        path = HERE / (model + "_" + name.removeprefix("python_") + ".py")
        result["native_callbacks"][name] = {
            "address": callback.address,
            "source": str(path),
            "source_sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
            "llvm": str(artifact),
            "llvm_sha256": hashlib.sha256(text.encode()).hexdigest(),
            "unsafe_llvm_operations": unsafe,
            "signature": str(SW_SIGNATURE if model == "sw" else EB_SIGNATURE),
        }
    return result


if __name__ == "__main__":
    record = {model: compilation_record(model) for model in ("sw", "ebm")}
    (HERE / "compilation.json").write_text(json.dumps(record, indent=2) + "\n")
    print(
        json.dumps(
            {
                "passed": True,
                "models": list(record),
                "versions": {
                    k: record["sw"][k]
                    for k in ("python", "numpy", "numba", "llvmlite", "cpu")
                },
            }
        )
    )
