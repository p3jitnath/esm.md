"""Run the fused ordered energy-balance method on GPU device arrays."""

import numpy as np
from numba import cuda
from numba.cuda.libdevice import dadd_rn as add, dmul_rn as mul, ddiv_rn as div


@cuda.jit(device=True, inline=True)
def sub(x, y):
    return add(x, -y)


@cuda.jit(fastmath=False)
def halo(n, q):
    t = cuda.grid(1)
    if t == 0:
        q[0] = q[1]
    elif t == 1:
        q[n + 1] = q[n]


@cuda.jit(fastmath=False)
def faces(n, q, work, coeff):
    i = cuda.grid(1)
    if i > n:
        return
    if i == 0 or i == n:
        work[i] = 0.0
    else:
        work[i] = mul(coeff[i], sub(q[i + 1], q[i]))


@cuda.jit(fastmath=False)
def update(n, q, base, out, work, coeff, par, final):
    i = cuda.grid(1) + 1
    if i > n:
        return
    p = n + 2
    if i == 1:
        q[0] = q[i]
    if i == n:
        q[n + 1] = q[i]
    right = mul(coeff[i], sub(q[i + 1], q[i])) if i < n else 0.0
    left = mul(coeff[i - 1], sub(q[i], q[i - 1])) if i > 1 else 0.0
    forcing = coeff[2 * p + i] if q[i] <= par[5] else coeff[p + i]
    r = sub(forcing, add(par[3], mul(par[4], q[i])))
    ell = add(r, div(sub(right, left), par[2]))
    e = add(q[i], mul(div(par[1], par[0]), ell))
    value = add(mul(base[i], 0.5), mul(e, 0.5)) if final else e
    out[i] = value
    if i == 1:
        out[0] = value
    if i == n:
        out[n + 1] = value


@cuda.jit(device=True, inline=True)
def euler(n, q, coeff, i, ratio, delta, A, B, Tf):
    p = n + 2
    value = q[i]
    right = mul(coeff[i], sub(q[i + 1], value)) if i < n else 0.0
    left = mul(coeff[i - 1], sub(value, q[i - 1])) if i > 1 else 0.0
    forcing = coeff[2 * p + i] if value <= Tf else coeff[p + i]
    r = sub(forcing, add(A, mul(B, value)))
    ell = add(r, div(sub(right, left), delta))
    return add(value, mul(ratio, ell))


@cuda.jit(fastmath=False)
def complete(n, q, stage, out, work, coeff, par):
    i = cuda.grid(1) + 1
    if i > n:
        return
    p = n + 2
    ratio, delta = div(par[1], par[0]), par[2]
    A, B, Tf = par[3], par[4], par[5]
    first = euler(n, q, coeff, i, ratio, delta, A, B, Tf)
    right = mul(coeff[i], sub(euler(n, q, coeff, i + 1, ratio, delta, A, B, Tf), first)) if i < n else 0.0
    left = mul(coeff[i - 1], sub(first, euler(n, q, coeff, i - 1, ratio, delta, A, B, Tf))) if i > 1 else 0.0
    forcing = coeff[2 * p + i] if first <= Tf else coeff[p + i]
    r = sub(forcing, add(A, mul(B, first)))
    ell = add(r, div(sub(right, left), delta))
    value = add(mul(q[i], 0.5), mul(add(first, mul(ratio, ell)), 0.5))
    stage[i], out[i] = first, value
    if i == 1:
        q[0], stage[0], out[0] = q[i], first, value
    if i == n:
        q[n + 1], stage[n + 1], out[n + 1] = q[i], first, value


@cuda.jit(fastmath=False)
def persistent(n, q, stage, out, work, coeff, par, steps):
    shared = cuda.shared.array((3, 130), dtype=np.float64)
    i = cuda.threadIdx.x + 1
    active = i <= n
    ratio = delta = A = B = Tf = kr = kl = warm = ice = 0.0
    if active:
        shared[0, i] = q[i]
        p = n + 2
        ratio, delta = div(par[1], par[0]), par[2]
        A, B, Tf = par[3], par[4], par[5]
        kr, kl, warm, ice = coeff[i], coeff[i - 1], coeff[p + i], coeff[2 * p + i]
    cuda.syncthreads()
    source, result = 0, 2
    for _ in range(steps):
        phase_source, phase_result = source, 1
        for phase in range(2):
            if active:
                temperature = shared[phase_source, i]
                right = mul(kr, sub(shared[phase_source, i + 1], temperature)) if i < n else 0.0
                left = mul(kl, sub(temperature, shared[phase_source, i - 1])) if i > 1 else 0.0
                forcing = ice if temperature <= Tf else warm
                r = sub(forcing, add(A, mul(B, temperature)))
                ell = add(r, div(sub(right, left), delta))
                value = add(temperature, mul(ratio, ell))
                if phase == 1:
                    value = add(mul(shared[source, i], 0.5), mul(value, 0.5))
                shared[phase_result, i] = value
            cuda.syncthreads()
            phase_source, phase_result = 1, result
        source, result = result, source
    if active:
        q[i], stage[i], out[i] = shared[0, i], shared[1, i], shared[2, i]
        if i == 1:
            q[0], stage[0], out[0] = q[i], stage[i], out[i]
        if i == n:
            q[n + 1], stage[n + 1], out[n + 1] = q[i], stage[i], out[i]


def enqueue(n, q, stage, out, work, coeff, par, steps, stream, block=128):
    """Queue complete ordered FP64 updates with reuse of stages and parameters.

    Parameters
    ----------
    n, steps : int
        Interior band count and complete step count.
    q, stage, out, work : GPU array of float64, shape (n + 2,)
        Disjoint state and scratch buffers in the frozen CPU layout.
    coeff, par : GPU array of float64
        Immutable K,W,I fields and C,dt,delta,A,B,Tf in contract units.
    stream : CUDA stream
        Same ordered stream used for graph capture and events.
    block : int
        Threads per block for the complete-step kernel.

    Returns
    -------
    None
        The last state is out for an odd count and q for an even count.

    Notes
    -----
    A nonempty batch of at most 128 bands uses one block with two barriers per
    step. Larger grids recompute neighbouring first-stage values from q,
    which removes a whole-grid synchronisation while returning both stages.
    """
    if not steps:
        return
    if n <= 128:
        persistent[1, 128, stream](n, q, stage, out, work, coeff, par, steps)
        return
    grid = int((n + block - 1) // block)
    for _ in range(steps):
        complete[grid, block, stream](n, q, stage, out, work, coeff, par)
        q, out = out, q
