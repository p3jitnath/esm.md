"""Implement the ordered periodic shallow-water operation with Numba."""

from math import sqrt

from numba import njit


@njit(cache=True, fastmath=False)
def _halo(q):
    ny, nx = q.shape[1] - 2, q.shape[2] - 2
    for a in range(3):
        for j in range(1, ny + 1):
            q[a, j, 0] = q[a, j, nx]
            q[a, j, nx + 1] = q[a, j, 1]
        for i in range(nx + 2):
            q[a, 0, i] = q[a, ny, i]
            q[a, ny + 1, i] = q[a, 1, i]


@njit(cache=True, fastmath=False)
def _prepare(q, work, g):
    for j in range(q.shape[1]):
        for i in range(q.shape[2]):
            h, mx, my = q[0, j, i], q[1, j, i], q[2, j, i]
            u, v = mx / h, my / h
            z = g * h
            c = sqrt(z)
            p = (z * h) * 0.5
            work[0, j, i] = mx * u + p
            work[1, j, i] = mx * v
            work[2, j, i] = my * v + p
            work[3, j, i] = abs(u) + c
            work[4, j, i] = abs(v) + c


@njit(inline="always", fastmath=False)
def _face(ql, qr, fl, fr, alpha):
    return (fl + fr) * 0.5 - (alpha * 0.5) * (qr - ql)


@njit(cache=True, fastmath=False)
def _component(q, base, out, fx, fy, sx, sy, par, final):
    for j in range(1, q.shape[0] - 1):
        for i in range(1, q.shape[1] - 1):
            east = _face(q[j, i], q[j, i + 1], fx[j, i], fx[j, i + 1],
                         max(sx[j, i], sx[j, i + 1]))
            west = _face(q[j, i - 1], q[j, i], fx[j, i - 1], fx[j, i],
                         max(sx[j, i - 1], sx[j, i]))
            north = _face(q[j, i], q[j + 1, i], fy[j, i], fy[j + 1, i],
                          max(sy[j, i], sy[j + 1, i]))
            south = _face(q[j - 1, i], q[j, i], fy[j - 1, i], fy[j, i],
                          max(sy[j - 1, i], sy[j, i]))
            dx, dy = (east - west) / par[1], (north - south) / par[2]
            ell = -(dx + dy)
            e = q[j, i] + par[3] * ell
            out[j, i] = base[j, i] * 0.5 + e * 0.5 if final else e


@njit(cache=True, fastmath=False)
def _update(q, base, out, work, par, final):
    for a in range(3):
        if a == 0:
            fx, fy = q[1], q[2]
        elif a == 1:
            fx, fy = work[0], work[1]
        else:
            fx, fy = work[1], work[2]
        _component(q[a], base[a], out[a], fx, fy, work[3], work[4], par, final)


@njit(cache=True, fastmath=False)
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
    _halo(q)
    _prepare(q, work, parameters[0])
    _update(q, q, stage, work, parameters, False)
    _halo(stage)
    _prepare(stage, work, parameters[0])
    _update(stage, q, out, work, parameters, True)
    _halo(out)


@njit(cache=True, fastmath=False)
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
    for n in range(0, nsteps, 2):
        step(q, stage, out, work, parameters)
        if n + 1 < nsteps:
            step(out, stage, q, work, parameters)
