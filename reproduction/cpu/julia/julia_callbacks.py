"""Embed the local Julia runtime and retain four compiled C callback entries."""

import ctypes
import os
from pathlib import Path

HERE = Path(__file__).resolve().parent
RUNTIME = HERE.parents[3] / "julia-1.12.7"
_RUNTIME = None
_CALLBACKS = None


def load_callbacks(model):
    """Return two retained native Julia callbacks for one physical model.

    Parameters
    ----------
    model : {'sw', 'ebm'}
        Model whose complete serial run entries are requested.

    Returns
    -------
    dict
        Route records with integer C entry addresses and retained runtime handles.

    Raises
    ------
    RuntimeError
        If Julia reports an initialization or source-compilation exception.

    Notes
    -----
    Julia 1.9 and later automatically adopt foreign threads entering a non-closure
    cfunction. Initialization and compilation must occur before any timed call.
    """
    global _RUNTIME, _CALLBACKS
    if _CALLBACKS is None:
        os.environ.setdefault("JULIA_NUM_THREADS", "1")
        os.environ.setdefault("JULIA_NUM_GC_THREADS", "1")
        os.environ.setdefault("JULIA_CPU_TARGET", "neoverse-v2")
        os.environ.setdefault("JULIA_DEPOT_PATH", str(HERE / "depot"))
        _RUNTIME = ctypes.PyDLL(
            str(RUNTIME / "lib/libjulia.so"), mode=ctypes.RTLD_GLOBAL
        )
        initializer = ctypes.CDLL(
            str(HERE / "libembedding_init.so"), mode=ctypes.RTLD_GLOBAL
        )
        initializer.fresh_julia_init.argtypes = []
        initializer.fresh_julia_init.restype = None
        initializer.fresh_julia_init()
        _RUNTIME.jl_eval_string.argtypes = [ctypes.c_char_p]
        _RUNTIME.jl_eval_string.restype = ctypes.c_void_p
        _RUNTIME.jl_exception_occurred.argtypes = []
        _RUNTIME.jl_exception_occurred.restype = ctypes.c_void_p
        _RUNTIME.jl_unbox_voidpointer.argtypes = [ctypes.c_void_p]
        _RUNTIME.jl_unbox_voidpointer.restype = ctypes.c_void_p
        import json

        source = "include(" + json.dumps(str(HERE / "callbacks.jl")) + ")"
        _RUNTIME.jl_eval_string(source.encode())
        if _RUNTIME.jl_exception_occurred():
            _RUNTIME.jl_eval_string(
                b"showerror(stderr, current_exceptions()); println(stderr)"
            )
            raise RuntimeError("Julia source initialization failed")
        _CALLBACKS = {}
        for selected_model in ("sw", "ebm"):
            for variant in ("vanilla", "tuned"):
                name = selected_model + "_" + variant
                value = _RUNTIME.jl_eval_string(
                    ("FreshJuliaCallbacks." + name + "_ptr").encode()
                )
                if _RUNTIME.jl_exception_occurred():
                    raise RuntimeError("Julia callback lookup failed: " + name)
                _CALLBACKS[name] = int(_RUNTIME.jl_unbox_voidpointer(value))
    return {
        "julia_"
        + variant: {
            "address": _CALLBACKS[model + "_" + variant],
            "keepalive": _RUNTIME,
            "runtime_path": str(RUNTIME),
            "source_path": str(HERE / "callbacks.jl"),
            "foreign_thread_support": "https://docs.julialang.org/en/v1.9/NEWS/#Multi-threading-changes",
            "allocation_policy": "Borrowed isbits CArray views; no numerical buffer allocation",
        }
        for variant in ("vanilla", "tuned")
    }


def build_routes(model, coordinator_path):
    """Bind callback records to one retained common Fortran coordinator.

    Parameters
    ----------
    model : {'sw', 'ebm'}
        Model whose complete entry is required.
    coordinator_path : str or pathlib.Path
        Already qualified common Fortran coordinator library.

    Returns
    -------
    dict
        Two serial callback addresses and the complete GC-safe entry address.

    Raises
    ------
    RuntimeError
        If Julia cannot bind the selected coordinator.
    """
    import json

    routes = load_callbacks(model)
    code = (
        "FreshJuliaCallbacks.configure("
        + json.dumps(model)
        + ","
        + json.dumps(str(Path(coordinator_path).resolve()))
        + ")"
    )
    _RUNTIME.jl_eval_string(code.encode())
    if _RUNTIME.jl_exception_occurred():
        raise RuntimeError("Julia coordinator binding failed")
    value = _RUNTIME.jl_eval_string(
        ("FreshJuliaCallbacks." + model + "_tiles_ptr").encode()
    )
    address = int(_RUNTIME.jl_unbox_voidpointer(value))
    for record in routes.values():
        record["coordinator_shim"] = address
        record["coordinator_path"] = str(Path(coordinator_path).resolve())
        record["gc_policy"] = (
            "Julia1.12 public @ccall gc_safe=true wraps the entire OpenMP coordinator"
        )
    return routes
