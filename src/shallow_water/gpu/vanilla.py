"""Run the unchanged ordered shallow-water method on flat GPU arrays."""

from numba import cuda
from numba.cuda.libdevice import dadd_rn as add, dmul_rn as mul, ddiv_rn as div, dsqrt_rn as sqrt


@cuda.jit(device=True, inline=True)
def sub(x, y):
    return add(x, -y)


@cuda.jit(fastmath=False)
def halo(nx, ny, q):
    t = cuda.grid(1)
    p, s = nx + 2, (nx + 2) * (ny + 2)
    if t >= 3 * s:
        return
    a, j, i = t // s, (t % s) // p, t % p
    if 0 < i <= nx and 0 < j <= ny:
        return
    ii = nx if i == 0 else 1 if i == nx + 1 else i
    jj = ny if j == 0 else 1 if j == ny + 1 else j
    q[t] = q[a * s + jj * p + ii]


@cuda.jit(fastmath=False)
def prepare(nx, ny, q, work, par):
    t = cuda.grid(1)
    s = (nx + 2) * (ny + 2)
    if t >= s:
        return
    h, mx, my = q[t], q[s + t], q[2 * s + t]
    u, v = div(mx, h), div(my, h)
    z = mul(par[0], h)
    c = sqrt(z)
    pressure = mul(mul(z, h), 0.5)
    work[t] = add(mul(mx, u), pressure)
    work[s + t] = mul(mx, v)
    work[2 * s + t] = add(mul(my, v), pressure)
    work[3 * s + t] = add(abs(u), c)
    work[4 * s + t] = add(abs(v), c)


@cuda.jit(device=True, inline=True)
def face(ql, qr, fl, fr, sl, sr):
    alpha = sl if sl >= sr else sr
    return sub(mul(add(fl, fr), 0.5), mul(mul(alpha, 0.5), sub(qr, ql)))


@cuda.jit(fastmath=False)
def update(nx, ny, q, base, out, work, par, final):
    t = cuda.grid(1)
    if t >= nx * ny:
        return
    p, s = nx + 2, (nx + 2) * (ny + 2)
    k = (t // nx + 1) * p + t % nx + 1
    sx, sy = 3 * s, 4 * s
    for a in range(3):
        b = a * s + k
        if a == 0:
            fx0, fxe, fxw = q[s + k], q[s + k + 1], q[s + k - 1]
            fy0, fyn, fys = q[2 * s + k], q[2 * s + k + p], q[2 * s + k - p]
        else:
            fx0, fxe, fxw = work[(a - 1) * s + k], work[(a - 1) * s + k + 1], work[(a - 1) * s + k - 1]
            fy0, fyn, fys = work[a * s + k], work[a * s + k + p], work[a * s + k - p]
        east = face(q[b], q[b + 1], fx0, fxe, work[sx + k], work[sx + k + 1])
        west = face(q[b - 1], q[b], fxw, fx0, work[sx + k - 1], work[sx + k])
        north = face(q[b], q[b + p], fy0, fyn, work[sy + k], work[sy + k + p])
        south = face(q[b - p], q[b], fys, fy0, work[sy + k - p], work[sy + k])
        ell = -add(div(sub(east, west), par[1]), div(sub(north, south), par[2]))
        e = add(q[b], mul(par[3], ell))
        out[b] = add(mul(base[b], 0.5), mul(e, 0.5)) if final else e


def enqueue(nx, ny, q, stage, out, work, par, steps, stream, block=128):
    """Queue both complete stages and periodic boundaries on one stream.

    Parameters
    ----------
    nx, ny, steps : int
        Interior dimensions and complete step count within the frozen domain.
    q, stage, out : GPU array of float64
        Disjoint flat states with 3*(nx+2)*(ny+2) values in CPU field order.
    work : GPU array of float64
        Five disjoint scratch fields with the same pitch.
    par : GPU array of float64, shape (4,)
        Immutable g,dx,dy,dt in SI units.
    stream : CUDA stream
        Ordered stream shared with capture and timing.
    block : int
        Threads per block. Partial blocks do not access invalid cells.

    Returns
    -------
    None
        Last state is out for an odd count and q for an even count.
    """
    s = (nx + 2) * (ny + 2)
    cells = int((nx * ny + block - 1) // block)
    halos = int((3 * s + block - 1) // block)
    points = int((s + block - 1) // block)
    for _ in range(steps):
        halo[halos, block, stream](nx, ny, q)
        prepare[points, block, stream](nx, ny, q, work, par)
        update[cells, block, stream](nx, ny, q, q, stage, work, par, 0)
        halo[halos, block, stream](nx, ny, stage)
        prepare[points, block, stream](nx, ny, stage, work, par)
        update[cells, block, stream](nx, ny, stage, q, out, work, par, 1)
        halo[halos, block, stream](nx, ny, out)
        q, out = out, q
