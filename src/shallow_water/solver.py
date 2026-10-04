"""Implement the ordered periodic shallow-water operation with Numba."""

from math import frexp, sqrt

from numba import njit
from numpy import uint64

MIN_NORMAL = float.fromhex("0x1.0p-1022")

@njit(cache=True, fastmath=False, error_model="numpy")
def _halo(q, nx, ny, P, S):
    for a in range(3):
        for j in range(1, ny + 1):
            q[uint64((a) * S + (j) * P + (0))] = q[uint64((a) * S + (j) * P + (nx))]
            q[uint64((a) * S + (j) * P + (nx + 1))] = q[uint64((a) * S + (j) * P + (1))]
        for i in range(nx + 2):
            q[uint64((a) * S + (0) * P + (i))] = q[uint64((a) * S + (ny) * P + (i))]
            q[uint64((a) * S + (ny + 1) * P + (i))] = q[uint64((a) * S + (1) * P + (i))]


@njit(cache=True, fastmath=False, error_model="numpy")
def _prepare(q, work, g, firstrow, lastrow, P, S):
    for j in range(firstrow, lastrow + 1):
        for i in range(P):
            h, mx, my = q[uint64((0) * S + (j) * P + (i))], q[uint64((1) * S + (j) * P + (i))], q[uint64((2) * S + (j) * P + (i))]
            u, v = mx / h, my / h
            z = g * h
            c = sqrt(z)
            p = (z * h) * 0.5
            work[uint64((0) * S + (j) * P + (i))] = mx * u + p
            work[uint64((1) * S + (j) * P + (i))] = mx * v
            work[uint64((2) * S + (j) * P + (i))] = my * v + p
            work[uint64((3) * S + (j) * P + (i))] = abs(u) + c
            work[uint64((4) * S + (j) * P + (i))] = abs(v) + c


@njit(inline="always", fastmath=False, error_model="numpy")
def _face(ql, qr, fl, fr, half_alpha):
    return (fl + fr) * 0.5 - half_alpha * (qr - ql)


@njit(inline="always", fastmath=False, error_model="numpy")
def _fluxes(qc, qe, qn, fc, fe, gc, gn, ae, an):
    return _face(qc, qe, fc, fe, ae), _face(qc, qn, gc, gn, an)


@njit(inline="always", fastmath=False, error_model="numpy")
def _cell(east, west, north, south, qc, base, xscale, yscale, dt, final, scaled):
    if scaled:
        dx, dy = (east - west) * xscale, (north - south) * yscale
    else:
        dx, dy = (east - west) / xscale, (north - south) / yscale
    ell = -(dx + dy)
    e = qc + dt * ell
    return base * 0.5 + e * 0.5 if final else e


@njit(inline="always", fastmath=False, error_model="numpy")
def _row(q, base, out, work, par, final, first, scaled, xscale, yscale, j, nx, ny, P, S, ring):
    r, rn, rf, rs = (j % 3, (j + 1) % 3, 3 + j % 2, 3 + (j - 1) % 2) if ring else (j, j + 1, j - 1, j - 2)
    aw = max(work[uint64((3) * S + (r) * P + (0))], work[uint64((3) * S + (r) * P + (1))]) * 0.5
    out[uint64((0) * S + (ny + 1) * P + (0))] = _face(q[uint64((0) * S + (j) * P + (0))], q[uint64((0) * S + (j) * P + (1))], q[uint64((1) * S + (j) * P + (0))], q[uint64((1) * S + (j) * P + (1))], aw)
    out[uint64((1) * S + (ny + 1) * P + (0))] = _face(q[uint64((1) * S + (j) * P + (0))], q[uint64((1) * S + (j) * P + (1))], work[uint64((0) * S + (r) * P + (0))], work[uint64((0) * S + (r) * P + (1))], aw)
    out[uint64((2) * S + (ny + 1) * P + (0))] = _face(q[uint64((2) * S + (j) * P + (0))], q[uint64((2) * S + (j) * P + (1))], work[uint64((1) * S + (r) * P + (0))], work[uint64((1) * S + (r) * P + (1))], aw)
    for i in range(1, nx + 1):
        h, mx, my = q[uint64((0) * S + (j + 1) * P + (i))], q[uint64((1) * S + (j + 1) * P + (i))], q[uint64((2) * S + (j + 1) * P + (i))]
        u, v = mx / h, my / h
        z = par[0] * h
        c = sqrt(z)
        p = (z * h) * 0.5
        ax, cross, ay = mx * u + p, mx * v, my * v + p
        sxn, syn = abs(u) + c, abs(v) + c
        work[uint64((0) * S + (rn) * P + (i))], work[uint64((1) * S + (rn) * P + (i))], work[uint64((2) * S + (rn) * P + (i))] = ax, cross, ay
        work[uint64((3) * S + (rn) * P + (i))], work[uint64((4) * S + (rn) * P + (i))] = sxn, syn
        ae = max(work[uint64((3) * S + (r) * P + (i))], work[uint64((3) * S + (r) * P + (i + 1))]) * 0.5
        an = max(work[uint64((4) * S + (r) * P + (i))], syn) * 0.5
        ass = max(work[uint64((4) * S + (0) * P + (i))], work[uint64((4) * S + (r) * P + (i))]) * 0.5 if first else 0.0
        east, north = _fluxes(q[uint64((0) * S + (j) * P + (i))], q[uint64((0) * S + (j) * P + (i + 1))], h,
                              q[uint64((1) * S + (j) * P + (i))], q[uint64((1) * S + (j) * P + (i + 1))], q[uint64((2) * S + (j) * P + (i))], my, ae, an)
        if first:
            out[uint64((0) * S + (0) * P + (i))] = _face(q[uint64((0) * S + (j - 1) * P + (i))], q[uint64((0) * S + (j) * P + (i))], q[uint64((2) * S + (j - 1) * P + (i))], q[uint64((2) * S + (j) * P + (i))], ass)
        out[uint64((0) * S + (ny + 1) * P + (i))], work[uint64((0) * S + (rf) * P + (i))] = east, north
        east, north = _fluxes(q[uint64((1) * S + (j) * P + (i))], q[uint64((1) * S + (j) * P + (i + 1))], mx,
                              work[uint64((0) * S + (r) * P + (i))], work[uint64((0) * S + (r) * P + (i + 1))], work[uint64((1) * S + (r) * P + (i))], cross, ae, an)
        if first:
            out[uint64((1) * S + (0) * P + (i))] = _face(q[uint64((1) * S + (j - 1) * P + (i))], q[uint64((1) * S + (j) * P + (i))], work[uint64((1) * S + (0) * P + (i))], work[uint64((1) * S + (r) * P + (i))], ass)
        out[uint64((1) * S + (ny + 1) * P + (i))], work[uint64((1) * S + (rf) * P + (i))] = east, north
        east, north = _fluxes(q[uint64((2) * S + (j) * P + (i))], q[uint64((2) * S + (j) * P + (i + 1))], my,
                              work[uint64((1) * S + (r) * P + (i))], work[uint64((1) * S + (r) * P + (i + 1))], work[uint64((2) * S + (r) * P + (i))], ay, ae, an)
        if first:
            out[uint64((2) * S + (0) * P + (i))] = _face(q[uint64((2) * S + (j - 1) * P + (i))], q[uint64((2) * S + (j) * P + (i))], work[uint64((2) * S + (0) * P + (i))], work[uint64((2) * S + (r) * P + (i))], ass)
        out[uint64((2) * S + (ny + 1) * P + (i))], work[uint64((2) * S + (rf) * P + (i))] = east, north
    for a in range(3):
        for i in range(1, nx + 1):
            south = out[uint64((a) * S + (0) * P + (i))] if first else work[uint64((a) * S + (rs) * P + (i))]
            out[uint64((a) * S + (j) * P + (i))] = _cell(out[uint64((a) * S + (ny + 1) * P + (i))], out[uint64((a) * S + (ny + 1) * P + (i - 1))],
                                work[uint64((a) * S + (rf) * P + (i))], south, q[uint64((a) * S + (j) * P + (i))], base[uint64((a) * S + (j) * P + (i))],
                                xscale, yscale, par[3], final, scaled)
    for a in range(5):
        work[uint64((a) * S + (rn) * P + (0))] = work[uint64((a) * S + (rn) * P + (nx))]
        work[uint64((a) * S + (rn) * P + (nx + 1))] = work[uint64((a) * S + (rn) * P + (1))]


@njit(cache=True, fastmath=False, error_model="numpy", inline="always")
def _update(q, base, out, work, par, final, nx, ny, P, S):
    scaled = (frexp(par[1])[0] == 0.5 and frexp(par[2])[0] == 0.5
              and par[1] >= MIN_NORMAL and par[2] >= MIN_NORMAL)
    xscale, yscale = (1.0 / par[1], 1.0 / par[2]) if scaled else (par[1], par[2])
    _prepare(q, work, par[0], 0, 1, P, S)
    ring = nx >= 128 and ny >= 3
    _row(q, base, out, work, par, final, True, scaled, xscale, yscale, 1, nx, ny, P, S, ring)
    for j in range(2, ny + 1):
        _row(q, base, out, work, par, final, False, scaled, xscale, yscale, j, nx, ny, P, S, ring)



@njit(cache=True, fastmath=False, error_model="numpy")
def _step_flat(q, stage, out, work, parameters, nx, ny, P, S):
    _halo(q, nx, ny, P, S)
    _update(q, q, stage, work, parameters, False, nx, ny, P, S)
    _halo(stage, nx, ny, P, S)
    _update(stage, q, out, work, parameters, True, nx, ny, P, S)
    _halo(out, nx, ny, P, S)


@njit(cache=True, fastmath=False, error_model="numpy")
def step(q, stage, out, work, parameters):
    """Return the first stage and complete SSPRK2 output in reusable buffers.

    Parameters
    ----------
    q, stage, out : ndarray of float64, shape (3, ny + 2, nx + 2)
        Disjoint C-contiguous state buffers in depth, x-momentum, y-momentum
        order. Input interior values remain unchanged; input halos may change.
    work : ndarray of float64, shape (5, ny + 2, nx + 2)
        Disjoint scratch storage for the D03 fluxes and speed bounds.
    parameters : ndarray of float64, shape (4,)
        Shared values g, dx, dy, dt in SI units; these values remain unchanged.

    Returns
    -------
    None
        The stage and out arrays receive the outputs, including periodic halos.

    Notes
    -----
    The valid-input and ordered arithmetic contract is defined in
    formulations/shallow_water.md. Compilation uses fastmath=False.
    """
    ny, nx = q.shape[1] - 2, q.shape[2] - 2
    P, S = q.shape[2], q.shape[1] * q.shape[2]
    _step_flat(q.reshape(q.size), stage.reshape(stage.size), out.reshape(out.size),
               work.reshape(work.size), parameters, nx, ny, P, S)



@njit(cache=True, fastmath=False, error_model="numpy")
def run(q, stage, out, work, parameters, nsteps):
    """Run complete updates with alternating state buffers.

    Parameters
    ----------
    q, stage, out, work, parameters : ndarray of float64
        Buffers and SI parameters satisfying the step contract.
    nsteps : int
        Number of complete steps, from 0 through 1000000.

    Returns
    -------
    None
        Final state is out for an odd count and q for an even count. Repeated
        updates may overwrite both q and out; stage contains the last stage.
    """
    ny, nx = q.shape[1] - 2, q.shape[2] - 2
    P, S = q.shape[2], q.shape[1] * q.shape[2]
    qf, sf, of, wf = q.reshape(q.size), stage.reshape(stage.size), out.reshape(out.size), work.reshape(work.size)
    for n in range(0, nsteps, 2):
        _step_flat(qf, sf, of, wf, parameters, nx, ny, P, S)
        if n + 1 < nsteps:
            _step_flat(of, sf, qf, wf, parameters, nx, ny, P, S)
