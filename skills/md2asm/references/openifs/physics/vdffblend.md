# VDFFBLEND Solver Contract

Revision 1. The [wind formulation](../../../../../formulations/openifs/physics/wind_at_blending_height.md) maps to [direct AArch64 assembly](../../../../../src/openifs/physics/vdffblend.S). The complete original routine is `VDFFBLEND` in `arpifs/phys_ec/vdffblend.F90`. Its calculations interpolate in geopotential, although the old source comment says pressure.

## Method and Domain

The original has two stages. The first rounds `PBLEND * RG` to FP64. Below the lowest level, it writes that level's relative speed and uses its geopotential for the next stage. The second scans levels from the ground upwards, selecting the first interval with `lower <= target < upper`. It calculates both wind components, subtracts the current, and returns their Euclidean norm, which is the length of the wind vector.

For each component, the ordered update is `((upper_wind * (target - lower)) + (lower_wind * (upper - target))) / (upper - lower)`. Every subtraction, multiplication, addition, division and square root rounds separately. Even below the lowest level, the second stage can overwrite the first norm after this full interpolation arithmetic. The direct body retains that write and ordered arithmetic. It may finish both stages for one column before moving to the next because the declared owners cannot overlap and columns have no shared calculation.

The supported packet width is 1–4096 and the level count is 1–1024. Selected columns use Fortran numbering, with `1 <= KIDIA <= KLON+1` and `0 <= KFDIA <= KLON`; an empty range returns every output bit unchanged. Selected profiles have finite geopotential with absolute value at most 10¹² m²/s² and strictly decreasing values as the level number increases. Gravity is finite, positive and at most 100 m/s². Blending height is finite, nonnegative and at most 10¹⁰ m. Its rounded geopotential must lie below the highest level. One-level input therefore requires a target below that single level. Wind and current components are finite with absolute value at most 10⁶ m/s. These limits keep the declared intermediate products and squared speeds finite.

FPCR must be zero, selecting round-to-nearest with ties to even and gradual underflow. Signed zeros remain present. Fused multiply-add, contraction, reassociation, approximate division or square root, and reduced precision are forbidden. There is no numerical child or external scalar math call.

## Interface and Storage

The application binary interface, or ABI, is the ordinary GNU Fortran address interface. The default symbol is `vdffblend_`, and `ORIGINAL_SYMBOL` selects a unique local native entry. Arguments 0–7 use `x0`–`x7`; arguments 8–10 use the incoming stack.

| Indices | Meaning |
| --- | --- |
| 0–3 | 32-bit `KIDIA`, `KFDIA`, `KLON` and `KLEV` |
| 4–6 | FP64 wind components and geopotential, each with `KLON * KLEV` values |
| 7–9 | FP64 current components and blending height, each with `KLON` values |
| 10 | FP64 relative wind-speed output, with `KLON` values |

Arrays use contiguous Fortran column-major storage: consecutive columns are adjacent, and consecutive level planes have pitch `KLON`. Buffers are aligned to at least eight bytes and cover the complete declared shape. The complete output owner must be disjoint from every consumed owner; read-only owners may share storage. Inactive output columns retain their original bits. Canonical comparison covers the entire little-endian output owner.

The direct body uses caller-saved integer and floating-point registers and no workspace. It preserves `x18`, `x19`–`x29`, the required low halves of `v8`–`v15`, the link register and the aligned stack. Unsupported dimensions, FPCR or physical inputs reject before any output write.

## Independent Checks and Evidence

The physical check uses exact rational interpolation weights and the squared relative-speed identity. It separately checks the rounded conversion from height to geopotential against the exact product. It checks the lowest-level extension, internal level ties, nonnegative speed, untouched columns and immutable inputs. Its budget is `4096 * 2^-53` times the squared operand scale, plus the smallest-subnormal rounding allowance. The original reference must pass this check before direct assembly is emitted.

Critical inputs cover below-level and interior targets, exact internal ties, the top interval, signed zeros, surface currents, cropped and empty columns, one level, odd packet widths and both declared shape limits. Protected input and output buffers and the unchanged generic ABI checker establish bounds and register obligations. Local evidence remains under `.runtime/openifs/vdffblend_source_7240564/`. Complete source, native, paired and forecast gates are recorded as they pass; no forecast acceptance or comparative timing is implied.

The original complete body passed 12 critical cases, 33,208 output bytes and 20,733 independent relations before direct emission. The complete native body passed 24 protected placements, 66,416 compared bytes and 41,466 relations with zero differences. Five immediate ABI cases passed 120 output bytes and 61 relations, while seven unsupported inputs rejected before changing 280 shared output bytes. Four profiling-enabled paired calls passed 112 complete bytes and 56 driver relations; mutable output sharing was rejected before changing 40 shared bytes. Complete forecast acceptance and comparative timing remain pending.
