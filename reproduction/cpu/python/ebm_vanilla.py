"""Implement the ordered diffusive energy balance operation with Numba."""

from numba import njit


@njit(cache=True, fastmath=False, error_model="numpy")
def _halo(q):
    q[0], q[-1] = q[1], q[-2]


@njit(cache=True, fastmath=False, error_model="numpy")
def _update(q, base, out, work, coeff, par, final):
    n = q.size - 2
    beta = par[1] / par[0]
    work[0], work[n] = 0.0, 0.0
    for i in range(1, n):
        work[i] = coeff[0, i] * (q[i + 1] - q[i])
    for i in range(1, n + 1):
        forcing = coeff[2, i] if q[i] <= par[5] else coeff[1, i]
        r = forcing - (par[3] + par[4] * q[i])
        ell = r + (work[i] - work[i - 1]) / par[2]
        e = q[i] + beta * ell
        out[i] = base[i] * 0.5 + e * 0.5 if final else e


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
    _halo(q)
    _update(q, q, stage, work, coeff, parameters, False)
    _halo(stage)
    _update(stage, q, out, work, coeff, parameters, True)
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
    for k in range(0, nsteps, 2):
        step(q, stage, out, work, coeff, parameters)
        if k + 1 < nsteps:
            step(out, stage, q, work, coeff, parameters)
