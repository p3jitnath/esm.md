# GPU Saturation Humidity

Revision 1 supplies the complete original `SATUR` call from the [saturation formulation](../../../../../formulations/openifs/physics/saturation.md), revision 1. Temperature determines the equilibrium vapour pressure over liquid water and ice. A temperature-dependent liquid fraction blends these pressures, and the ideal-gas relation converts the result to a vapour mass fraction. The [accepted CPU contract](../../../../md2fort/references/openifs/physics/satur.md) fixes the original source arithmetic and constants. The [direct PTX source](../../../../../src/openifs/physics/gpu/saturation_humidity.ptx) keeps every intermediate FP64 rounding point. FP64 means the 64-bit floating-point format.

## Original Interface And Shared Constants

`md2asm_gpu_satur` receives the original argument-address vector and the [64-byte GPU context](../gpu_call_context.md). Its ten slots address first column, last column, full columns, first level, last/full levels, linear-mode flag, pressure, temperature, output humidity and phase flag, in that order. Integers and logical flags have four bytes. Matrix values have eight bytes and columns are contiguous. A one-based column c and level j use element offset (c-1)+K*(j-1), where K is the full column count. Supply zero through 4096 columns, zero through 1024 levels and valid selected ranges, including empty work.

Input matrices may share storage. Output humidity is disjoint from every input. Complete storage must remain valid and naturally aligned until the host synchronizes the launch. Inputs, constants and metadata stay read-only. Selected output cells change, and every other complete-owner byte stays unchanged. The host supplies a positive one-dimensional grid and block, with other dimensions one and dynamic shared storage zero. A grid-stride loop covers the supported shapes without array scratch.

Context bytes 48 and 56 identify an immutable 96-byte record. Its twelve words are addresses of the original live FP64 global constants below. The host supplies addresses and calculates no constant or model value.

| Record word | Constant | Meaning and units |
| ---: | --- | --- |
| 0 | RTICE | Ordinary ice threshold, K |
| 1 | RTICECU | Convective ice threshold, K |
| 2 | RTWAT_RTICE_R | Ordinary inverse temperature interval, K⁻¹ |
| 3 | RTWAT_RTICECU_R | Convective inverse temperature interval, K⁻¹ |
| 4 | RTWAT | Liquid-water threshold, K |
| 5 | RETV | Vapour-to-dry-air gas-constant ratio minus one, dimensionless |
| 6 | RTT | Reference temperature, K |
| 7 | R2ES | Reference vapour pressure times dry-to-vapour gas-constant ratio, Pa |
| 8 | R3LES | Liquid-water exponential coefficient, dimensionless |
| 9 | R4LES | Liquid-water temperature offset, K |
| 10 | R3IES | Ice exponential coefficient, dimensionless |
| 11 | R4IES | Ice temperature offset, K |

## Complete Ordered Calculation

Use temperature from 160 through 330 K and positive finite air pressure in pascals, with the source-defined binary constants. A true linear flag uses the ordinary ice threshold and inverse interval. With a false linear flag and phase flag one, use the convective pair; otherwise use the ordinary pair. Clip temperature first below RTWAT, then above the selected ice threshold. Subtract that threshold, multiply by its stored inverse interval, square the rounded value and take the minimum with one. This gives the liquid fraction alpha.

For water, separately subtract RTT from temperature, multiply by R3LES, separately subtract R4LES from temperature, divide numerator by denominator and call the [qualified original-rounding exponential](../mathematical_support.md). Repeat the same ordered calculation for ice with R3IES and R4IES. Linear mode multiplies each exponential by R2ES before blending. Multiply alpha by the water value, separately subtract alpha from one, multiply that result by the ice value and add the two products. Nonlinear mode instead multiplies the completed blend by R2ES. This distinction preserves the original intermediate rounding.

Divide the scaled vapour pressure by air pressure and cap the ratio at 0.5. Separately multiply RETV by the ratio, subtract from one, divide one by that difference and multiply the ratio by the correction. The result is kilograms of vapour per kilogram of moist air. Every subtraction, multiplication, addition and division rounds separately to nearest with ties to even. Preserve gradual underflow and signed zero. Fused arithmetic, reassociation, approximate model division and reduced precision are forbidden. Finite min/max operations select an existing word and require no new rounding.

Each thread owns independent cells. New Arm-equivalent status bits combine by integer OR at context byte 8. The two exponential calls retain water-before-ice order. A nonzero error-write event has original ordinal 2*cell+phase+1, where phase is zero for water and one for ice. Pack ordinal shifted left eight bits plus the one-byte code, and combine events by atomic maximum at context byte 16. The supported temperature and constants give ordinary finite exponential arguments and no error write. The host preserves incoming errno when no event occurs.

Validate supported dimensions, selected ranges, logical mode and required record/pointers before output writes. A metadata refusal sets error 1 and preserves output bytes. An empty dimension or selected range reads no unused numerical matrix or constant record. Complete valid owner storage and the stated alias rules remain caller requirements. The original production source is linked under both `satur_` and `md2asm_callpar_satur_7358525`; a live bridge must preserve the ten original addresses.

## Component Evidence And Limits

On exclusive job 7510938, node nid010553, visible GPU 0, the component gate passed 60 numerical calls and 11 controls, including eight refusals and three genuine empty calls. All 71 immediate FPCR, FPSR and errno comparisons passed. The checks found zero differing bytes across 4,456,448 complete output and guard bytes; 13,369,344 protected input and guard bytes stayed unchanged. The unchanged accepted CPU assembly uses the exact accepted scalar exponential library as its separate oracle. A verification-only assembly tail call selects that library without calculating any model stage.

Independent 220-digit calculations passed 19,712 physical relations for the saturation law, pure-phase pressure bounds, nonnegative bounded humidity and ideal-gas residual. The largest error divided by the larger of mathematical humidity and the smallest normal FP64 value was about 2.410×10⁻¹⁵, within the declared bound of 256 times 2⁻⁵³ plus a subnormal rounding allowance. The corpus contains 632 nonzero subnormal outputs, both arithmetic modes and phase flags, threshold neighbours, capped ratios, cropped rows and levels, odd widths, inactive cells, empty work and dimension limits. Constants and scalar arguments remain unchanged.

A separate CPU check covers all 211 unique source-rounded exponential arguments, including 210 words outside the earlier foundation corpus. Independent 120-digit and 240-digit exponentials give a largest conservative error of 0.502736 units in the last place, below the frozen one-unit acceptance limit. This check requires no repeat GPU or component run.

Native instruction review found no fused or reduced-precision model arithmetic. Rounded model operations and exponentials call the separately qualified helpers. Integer address division may use implementation machinery internally while retaining exact integer coordinates. The [live forecast interface](../physics_forecast_calls.md) also verifies this entry within the eight-stage forecast, including complete storage and immediate status. A complete PTX forecast and its runtime remain separate requirements.
