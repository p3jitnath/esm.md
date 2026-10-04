"""Implement the ordered diffusive energy balance operation with Numba."""

from math import frexp

from numba import njit
from numpy import uint64

MIN_NORMAL = float.fromhex("0x1.0p-1022")


@njit(cache=True, fastmath=False, error_model="numpy")
def _halo(q):
    q[0], q[-1] = q[1], q[-2]


@njit(inline="always", fastmath=False, error_model="numpy")
def _update(q, base, out, work, coeff, par, beta, scale, scaled, final, lo, hi, whole):
    n = q.size - 2
    if whole:
        lo, hi = 1, n
    intercept, slope, threshold = par[3], par[4], par[5]
    for i in range(lo, hi + 1):
        east = coeff[0, uint64(i)] * (q[uint64(i + 1)] - q[uint64(i)])
        west = coeff[0, uint64(i - 1)] * (q[uint64(i)] - q[uint64(i - 1)])
        ice, warm = coeff[2, uint64(i)], coeff[1, uint64(i)]
        forcing = ice if q[uint64(i)] <= threshold else warm
        r = forcing - (intercept + slope * q[uint64(i)])
        diffusion = (east - west) * scale if scaled else (east - west) / scale
        ell = r + diffusion
        e = q[uint64(i)] + beta * ell
        out[uint64(i)] = base[uint64(i)] * 0.5 + e * 0.5 if final else e


@njit(cache=True, fastmath=False, error_model="numpy")
def step(q, stage, out, work, coeff, parameters):
    """Return both SSPRK2 stages in reusable temperature buffers.

    Parameters
    ----------
    q, stage, out, work : ndarray of float64, shape (n + 2,)
        Disjoint contiguous buffers; q's interior remains unchanged, while
        both output states receive copied pole ghosts.
    coeff : ndarray of float64, shape (3, n + 2)
        Immutable contiguous K, warm ASR, and ice ASR fields.
    parameters : ndarray of float64, shape (6,)
        Immutable C, dt, delta, A, B, Tf in formulation units.

    Returns
    -------
    None
        stage and out receive the complete operation's outputs.

    Notes
    -----
    The ordered arithmetic and supported domain are in budyko_sellers.md.
    Compilation retains correctly rounded division and disables fast-math.
    """
    beta = parameters[1] / parameters[0]
    scaled = frexp(parameters[2])[0] == 0.5 and parameters[2] >= MIN_NORMAL
    scale = 1.0 / parameters[2] if scaled else parameters[2]
    _complete(q, stage, out, work, coeff, parameters, beta, scale, scaled, q.size >= 8194)


@njit(inline="always", fastmath=False, error_model="numpy")
def _complete(q, stage, out, work, coeff, par, beta, scale, scaled, tiled):
    n = q.size - 2
    _halo(q)
    if tiled:
        for lo in range(1, n + 1, 512):
            hi = min(n, lo + 511)
            first = lo if lo == 1 else lo + 1
            last = min(n, hi + 1)
            _update(q, q, stage, work, coeff, par, beta, scale, scaled, False, first, last, False)
            if lo == 1:
                stage[0] = stage[1]
            if last == n:
                stage[n + 1] = stage[n]
            _update(stage, q, out, work, coeff, par, beta, scale, scaled, True, lo, hi, False)
    else:
        _update(q, q, stage, work, coeff, par, beta, scale, scaled, False, 1, n, True)
        _halo(stage)
        _update(stage, q, out, work, coeff, par, beta, scale, scaled, True, 1, n, True)
    _halo(out)


@njit(cache=True, fastmath=False, error_model="numpy")
def run(q, stage, out, work, coeff, parameters, nsteps):
    """Run complete steps with alternating state buffers.

    Parameters
    ----------
    q, stage, out, work, coeff, parameters : ndarray of float64
        Buffers satisfying the step contract.
    nsteps : int
        Complete-step count, from 0 through 1000000.

    Returns
    -------
    None
        Final state is out after an odd count and q after an even count.
    """
    if nsteps == 0:
        return
    beta = parameters[1] / parameters[0]
    scaled = frexp(parameters[2])[0] == 0.5 and parameters[2] >= MIN_NORMAL
    scale = 1.0 / parameters[2] if scaled else parameters[2]
    if q.size >= 8194:
        if scaled:
            _repeated(q, stage, out, work, coeff, parameters, nsteps, beta, scale, True, True)
        else:
            _repeated(q, stage, out, work, coeff, parameters, nsteps, beta, scale, False, True)
    else:
        if scaled:
            _repeated(q, stage, out, work, coeff, parameters, nsteps, beta, scale, True, False)
        else:
            _repeated(q, stage, out, work, coeff, parameters, nsteps, beta, scale, False, False)


@njit(inline="always", fastmath=False, error_model="numpy")
def _repeated(q, stage, out, work, coeff, parameters, nsteps, beta, scale, scaled, tiled):
    for k in range(0, nsteps, 2):
        _complete(q, stage, out, work, coeff, parameters, beta, scale, scaled, tiled)
        if k + 1 < nsteps:
            _complete(out, stage, q, work, coeff, parameters, beta, scale, scaled, tiled)
