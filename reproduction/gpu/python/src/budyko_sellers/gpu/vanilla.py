"""Run the unchanged ordered energy-balance method on GPU device arrays."""

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
    forcing = coeff[2 * p + i] if q[i] <= par[5] else coeff[p + i]
    r = sub(forcing, add(par[3], mul(par[4], q[i])))
    ell = add(r, div(sub(work[i], work[i - 1]), par[2]))
    e = add(q[i], mul(div(par[1], par[0]), ell))
    out[i] = add(mul(base[i], 0.5), mul(e, 0.5)) if final else e


def enqueue(n, q, stage, out, work, coeff, par, steps, stream, block=128):
    """Queue complete FP64 stages and pole copies on one GPU stream.

    Parameters
    ----------
    n, steps : int
        Interior band count and complete step count within the frozen domain.
    q, stage, out, work : GPU array of float64, shape (n + 2,)
        Disjoint flat buffers. q's interior is preserved by one step.
    coeff, par : GPU array of float64
        Immutable K,W,I fields and C,dt,delta,A,B,Tf in contract units.
    stream : CUDA stream
        Ordered stream shared with capture and timing.
    block : int
        Threads per block. Partial blocks return before array access.

    Returns
    -------
    None
        The last state is out for an odd count and q for an even count.

    Notes
    -----
    All model arithmetic uses explicit rounded FP64 device intrinsics.
    """
    grid = int((n + block - 1) // block)
    for _ in range(steps):
        halo[1, 32, stream](n, q)
        faces[int((n + 1 + block - 1) // block), block, stream](n, q, work, coeff)
        update[grid, block, stream](n, q, q, stage, work, coeff, par, 0)
        halo[1, 32, stream](n, stage)
        faces[int((n + 1 + block - 1) // block), block, stream](n, stage, work, coeff)
        update[grid, block, stream](n, stage, q, out, work, coeff, par, 1)
        halo[1, 32, stream](n, out)
        q, out = out, q
