# Multicore CPU solver contract

This extension applies to the [shallow-water solver](../../../src/sw/solver.f90) and [energy-balance solver](../../../src/ebm/solver.f90). Their [shallow-water](2d_rusanov_ssprk2.md) and [energy-balance](budyko_sellers.md) contracts still define the physics, ordered binary64 arithmetic, serial interfaces and output encoding. This extension changes how workers share one coupled domain, while preserving every required returned state bit.

OpenMP supplies concurrent CPU workers. The Fortran coordinator owns tile gathering, both numerical stages, repeated time steps, state publication and boundary copies. A comparison driver restores inputs and calls this complete solver. It supplies no numerical stage.

## Public C interfaces

The entries use `ISO_C_BINDING`. Integer dimensions and step counts are C `int` values, state elements are eight-byte C `double` values in the binary64 format, and workspace lengths are `int64_t` element counts. A callback is a function pointer to a complete serial run entry with the following interface.

```c
#include <stdint.h>

typedef void (*sw_kernel_fn)(
    int nx, int ny, double *q, double *stage, double *out,
    double *work, const double *par, int count);

typedef void (*eb_kernel_fn)(
    int n, double *q, double *stage, double *out, double *work,
    const double *coeff, const double *par, int count);

int64_t sw_tiles_values(int nx, int ny, int px, int py, int batch);
int64_t eb_tiles_values(int n, int threads, int batch);

int sw_run_tiles(
    sw_kernel_fn kernel, int nx, int ny,
    double *q, double *stage, double *out, const double *par,
    int count, int px, int py, int batch,
    double *workspace, int64_t workspace_values);

int eb_run_tiles(
    eb_kernel_fn kernel, int n, double *q, double *stage, double *out,
    const double *coeff, const double *par, int count,
    int threads, int batch, double *workspace, int64_t workspace_values);
```

Normal use passes the solver's own `sw_run` or `eb_run` as `kernel`. A comparison may select a separately qualified complete kernel through the same interface. A positive count requires a nonnull compatible function pointer that remains valid throughout the call. Each local invocation receives the original global spacings, time step and other parameter words. Energy-balance coefficient columns are copied from their corresponding global indices, so the smaller tile dimensions do not redefine the physical grid.

## Bounds, shapes and ownership

`count` is from 0 to 1,000,000 complete steps. `batch` limits the number of complete steps in each local group. The last group uses only the remaining steps.

| Model | Admitted dimensions and workers | Batch bounds |
| --- | --- | --- |
| Shallow water | `nx,ny` are 1 to 4,096, `1 <= px <= nx`, `1 <= py <= ny` and `px*py <= 288`. Each worker owns a nonempty tile. The largest expanded local dimension must also be at most 4,096. | 1 to 32 |
| Energy balance | `n` is 1 to 65,536 and `1 <= threads <= min(n,288)`. Each worker owns a nonempty latitude range. | 1 to 256 |

The worker bounds are limits of these interfaces, not a claim that a machine supplies that many physical cores. Record the allocated cores, configured budget, actual team and workers with nonempty ownership separately. In particular, a 128-band EBM cannot launch more than 128 workers through this entry.

| Model and array | Contiguous Fortran shape and units |
| --- | --- |
| Shallow-water `q`, `stage`, `out` | `(nx+2,ny+2,3)`, with x contiguous. The three fields are depth [m] and the two depth-weighted velocities [m²/s]. |
| Shallow-water `par` | Four values, in order `g` [m/s²], `dx` [m], `dy` [m] and `dt` [s]. |
| Energy-balance `q`, `stage`, `out` | `n+2` temperatures [°C], including both pole ghosts. |
| Energy-balance `coeff` | `(n+2,3)`, with the cell index contiguous. Columns contain `K` [W/(m² K)], `W` [W/m²] and `I` [W/m²]. |
| Energy-balance `par` | Six values, in order `C` [J/(m² K)], `dt` [s], `delta` [1], `A` [W/m²], `B` [W/(m² K)] and `Tf` [°C]. |

The caller owns all arrays for the complete call. Their storage must be disjoint and aligned to at least eight bytes, with valid values and bounds under the model's original contract. The state arrays and workspace may change. Parameters and coefficients remain unchanged. Workspace contains private states and numerical scratch of mixed physical units, with no returned-value rule after a positive count. No pointer or numerical workspace is retained after return. Larger alignment and memory placement are target tuning choices, recorded with the build and measurements.

## Workspace size

Use the corresponding `*_tiles_values` query for the live dimensions, partition and batch before a positive call. Its result counts binary64 elements, so the required byte count is eight times that result. A result of `-1` means the requested size rules are not supported.

For several shallow-water workers, let `mx = ceil(nx/px) + 4*batch` when x is partitioned and `mx = nx` otherwise. Define `my` in the same way. The source reserves the following capacity for each local field, where `ceil` rounds a positive quotient up to the next integer.

```math
S=8192\left\lceil\frac{(m_x+2)(m_y+2)}{8192}\right\rceil,
\qquad V_{\mathrm{SW}}=p_xp_y\,14S.
```

Each worker's region contains three three-field states and five scratch fields. A one-worker call bypasses tiling and uses the serial scratch size of `5*(nx+2)*(ny+2)` elements.

For several energy-balance workers, set `m = min(n,ceil(n/threads)+4*batch)`. Four one-field arrays and three coefficient columns share each worker's region.

```math
S=8192\left\lceil\frac{m+2}{8192}\right\rceil,
\qquad V_{\mathrm{EBM}}=\mathrm{threads}\,7S.
```

A one-worker energy-balance call uses only `n+2` scratch elements. The capacity rounding is part of the current storage recipe. It does not increase the minimum eight-byte alignment requirement. The caller supplies `workspace_values >= V` for a positive count.

## Complete updates and returned states

Both models have two stages that read immediate neighbours. A group of `k` complete steps therefore has a dependency radius of `2*k` cells. Each worker gathers enough neighbouring values to protect its owned cells throughout the group and computes the expanded tile. Shallow-water overlap wraps periodically, while an unpartitioned direction retains its true periodic boundary. Energy-balance overlap stops at the true poles. Artificial tile boundaries cannot affect an owned returned value within the group.

Intermediate groups keep their global source buffer unchanged while workers publish only the complete owned result into the other state buffer. A barrier then makes that result available to the next group. The final group completes its local calculations before all workers meet at a barrier, then publishes both canonical state buffers and the last first-stage buffer. Thus intermediate public buffers are not a checkpoint interface.

Boundary owners also publish the global ghosts directly from protected local scratch. Shallow-water edge and corner owners write the opposite periodic faces and corners. Energy-balance end owners copy their protected endpoint to the corresponding pole ghost. All three returned arrays have complete boundaries.

After a positive odd count, `out` holds the final complete state and `q` the preceding complete state. After a positive even count, `q` is final and `out` is preceding. `stage` always holds the first stage of the final complete step. These roles depend on the total count, including a partial final group. A one-worker call invokes the complete serial kernel directly with the original scratch view and retains the same returned-state rules.

## Status and floating-point environment

The run entries return C `int` status `0` on success, `-1` for unsupported sizes, partitions, counts or insufficient positive-count workspace, and `-2` when the OpenMP runtime does not supply the requested team. These rejected calls change no state or scratch array. Pointer validity, nonoverlap and a compatible positive-count callback are caller obligations.

A valid zero-count call returns before checking workspace capacity, converting the callback or entering OpenMP. It preserves every array byte, including ghosts and workspace. Its dimensions, partition and batch must still satisfy the query's bounds.

The caller supplies round-to-nearest with ties to even, gradual underflow and non-halting arithmetic. For several workers, the coordinator saves the caller's status and each worker's earlier status, installs the caller's status during numerical work, and collects the supported standard IEEE flags. It restores each worker's earlier status, then restores caller controls and combines incoming and observed flags by logical OR. The standard flags are invalid operation, division by zero, overflow, underflow and inexact result. This rule includes flags naturally raised by overlap work and does not promise every target-specific hardware status bit. The one-worker direct path uses the serial callback's existing environment behaviour.

Build the source with OpenMP and compiler options that preserve these IEEE and ordered-arithmetic rules. Record compiler versions, processor options and inspected instructions in the target build record. Recompilation on another architecture requires the same independent physical checks, complete-output comparisons and environment checks before support is claimed.

## Acceptance and timing scope

The existing physical limits and canonical output encoding remain unchanged. Acceptance compares complete current, preceding and first-stage buffers, including boundaries, with zero differing bytes. Focused checks cover zero steps, partial and repeated groups, batch boundaries, small and asymmetric domains, immutable inputs and buffer bounds. Independent physical checks remain separate from exact agreement.

The complete-update timer includes gathering, overlap calculations, every numerical stage, publication, boundary copies, barriers and solver entry and return. Compilation, allocation, input restoration, first touch, verification and file writing remain outside it. Matched routes use the same grid, inputs, complete step count, actual team, placement and coordinator schedule. Hardware, chosen configurations and repeated timing variation belong in the [published comparison](../../../README.md) and local research records.
