# GPU Physics Rate Closure

Revision 1 supplies the complete original `CPQTUV` calculation from the [state-change rate formulation](../../../../../formulations/openifs/dynamics/state_rates.md), revision 1.0, and the [accepted CPU contract](../../../../md2fort/references/openifs/dynamics/cpqtuv.md), revision 1.1. After the physical processes change their rates, this calculation updates wind, temperature and tracers, evaporates small cloud amounts, and optionally corrects the continuity rate. The [direct PTX source](../../../../../src/openifs/dynamics/gpu/physics_rate_closure.ptx) preserves every original rounding and strict comparison. FP64 means the 64-bit floating-point format.

## Original Interface And Storage

`md2asm_gpu_cpqtuv` receives the original argument-address vector and the [64-byte context](../gpu_call_context.md). The eighteen original slots remain in this order.

| Slots | Original values |
| --- | --- |
| 0–7 | TECLDP object, YGFL object, full columns, first column, last column, levels, timestep, dry-flux flag |
| 8–13 | Earlier U, earlier V, earlier temperature, complete earlier PGFL, dynamics rates, convection continuity rate |
| 14–17 | Updated U, updated V, updated temperature, compact PGFLT1 |

Integers and logical flags have four bytes. A full-level field has K by N FP64 cells, where K is positive full columns and N is nonnegative levels. Columns are contiguous, and one-based selected columns lie between first and last. Earlier PGFL contains NDIM fields; compact PGFLT1 and dynamics contain NDIM1 fields. All address products fit signed 64 bits, and every used owner remains mapped and aligned to eight bytes through synchronization. The five mutable arrays are separate from one another and from all inputs. Read-only input arrays may share storage. Empty selected ranges and zero levels change no numerical owner and read no unused numerical buffer.

TECLDP has 2776 bytes. Its cloud-fraction threshold RAMIN is at byte 112 and its water threshold RLMIN is at byte 120. RAMIN has no unit; RLMIN has units of kilograms per kilogram. YGFL has 1359136 bytes. Signed 32-bit NUMFLDS, NDIM and NDIM1 occur at bytes 0, 48 and 64. Generic component objects start at byte 3848 with stride 368, up to 2163 components. Each stores LACTIVE at byte 64, LT1 at 92, MP at 168, MP9_PH at 184 and MP1 at 188. LACTIVE and LT1 are logical flags. MP1 selects compact storage and MP9_PH selects earlier storage. Active generic mappings must be in range; inactive mappings may be invalid and cause no access.

Seven original pointer slots identify the named components: Q at 799840, L at 799856, I at 799848, R at 799920, S at 799912, A at 799984 and PHYCTY at 801104. Q is vapour, L liquid, I ice, R rain, S snow and A cloud fraction. PHYCTY selects the stored physics continuity rate. All seven pointers identify valid component objects, even when their fields are disabled. Every index actually used by a correction must fit its complete owner. The named water/cloud fields used together are distinct, and active continuity storage is separate from the earlier water fields.

Context bytes 48 and 56 identify an immutable sixteen-byte record. Its two words address the original live RALVDCP and RALSDCP constants, in that order. These constants have units of kelvin and convert a water mass-fraction change to a temperature change. The host supplies their addresses and calculates no numerical value. Metadata, constants and all declared input arrays remain unchanged.

## Complete Ordered Update

Use a positive finite timestep in seconds. Wind has units of metres per second, temperature kelvin and water components kilograms per kilogram. Other tracers retain their caller units. For each selected cell, round timestep times incoming rate, then separately round earlier value plus that product. Apply this to U, V and temperature. Visit generic components in their stored order. Each LT1 component applies the same update to its MP1 compact field from its MP9_PH earlier field. Repeated MP1 selections repeat the calculation using the preceding rounded result as the incoming rate.

Visit L, I, R and S in that order. If a component is LT1 and its current value is strictly below RLMIN, add that value to Q, multiply it by the appropriate latent-heat constant, subtract that rounded product from temperature and set the component to positive zero. Use RALVDCP for liquid and rain, and RALSDCP for ice and snow. Negative arithmetic witnesses follow the same source equations.

When L, I and A all have LT1 true, round L plus I. If A is below RAMIN or that rounded sum is below RLMIN, add the sum to Q, subtract the rounded liquid latent-heat product from temperature, then subtract the rounded ice product. Set L, I and A to positive zero. Then cap LT1 cloud fraction above one at exactly one. Threshold equality does not trigger a correction. This order conserves total water and the declared latent-heat balance within rounding error.

If PHYCTY is active, copy the supplied convection continuity rate into its MP field in PGFL. If the dry-flux flag is also true and Q, L, I, R and S are all active, calculate a water change d. In Q, L, I, R, S order, separately round current compact value minus earlier value, dynamics rate times timestep, and their subtraction. Add the five contributions from left to right. Round one minus d, then visit generic components in order and multiply every LT1 compact field by this factor. Repeat duplicate selections in their original order.

Sum the resulting Q, L, I, R and S from left to right to obtain q. Separately subtract q from one, divide d by that result, divide the quotient by timestep and add it to the saved continuity rate. The two denominators must be nonzero, and all arithmetic inputs and results are finite. Dynamics rates are read only in this enabled five-water correction. The convection array is read only when continuity is active. Inactive last-block dynamics tails are never read.

## Arithmetic, Bounds And Checks

Every multiply, add, subtract and divide rounds separately to nearest with ties to even and calls the [qualified full result/status helpers](../mathematical_support.md). Keep signed zero and gradual underflow. No fused arithmetic, reassociation, approximate model division, reduced precision or host-supplied model stage is used. Finite comparisons preserve strict threshold decisions. Per-thread new flags combine by integer OR at context byte 8. Basic arithmetic writes no errno event, so incoming errno is preserved.

Required metadata, logical values, shapes and used component indices are checked before output stores. A refusal sets context error 1 without changing any output owner. Valid complete allocations and the stated alias rules remain caller duties. Positive one-dimensional grids and blocks distribute independent cells with a grid-stride loop; other grid/block dimensions are one, shared bytes are zero and no array scratch is required.

The unchanged 135-case frozen CPU corpus was applied to the complete GPU call on exclusive job 7510938, node nid010553, visible GPU 0. All five complete returned arrays and their guards agree exactly. The 252152 canonical bytes also compare directly with the retained strict Fortran output file. Twelve new refusal cases and two genuine no-work controls pass, giving 149 immediate FPCR, FPSR and errno checks. Across these calls, 48824320 complete output and guard bytes have zero differences and 317915136 read-only input and guard bytes stay unchanged. These byte counts include protected complete owners; they are distinct from the smaller canonical stream.

Independent physical functions from the accepted verifier were reused on the returned GPU buffers. They check 4581 numerical relations over 1044 physical points, including 45 points with enabled water-mass correction. The checks cover wind updates, repeated targets, total water, latent heat, continuity and rescaling. The corpus covers every six-field LT1 combination, optional continuity and water-mass modes, alternate maps, repeated targets, threshold equality, signed zeros, subnormals, cropped columns, odd widths, empty intervals and zero levels. Native model entries contain no fused or reduced-precision floating-point arithmetic; all rounded operations use the qualified helpers.

The original production source is retained as `md2asm_drv_physics_close_7358525`. The [live forecast interface](../physics_forecast_calls.md) preserves all eighteen original addresses and verifies complete changed-stage outputs in the eight-stage forecast. A complete PTX forecast and its runtime remain separate requirements.
