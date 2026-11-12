# Surface Initial-State Conversion Contract

This direct AArch64 routine reproduces the selected OpenIFS `MODGRINML` route with 2,048 grid points, 47 surface fields and five fields with five snow layers. It first calls the [surface unit-scaling child](surface_field_unit_scaling.md), then applies the original land, sea, snow, vegetation and lake adjustments. The [formulation](../../../../../formulations/openifs/input/surface_initial_state_conversion.md) states their physical meaning. The scope requires the ECMWF surface scheme and does not include other grid sizes, single-layer snow, monthly interpolation or complete model initialisation.

## Interface and Storage

The application binary interface (ABI) is `int md2asm_convert_initial_surface_state(field2d, bytes2d, field3d, bytes3d, parameters, parameter_bytes, configuration, configuration_bytes)`. The eight arguments use registers `x0` to `x7`, and the return code uses `w0`. The arrays change in place. Parameter identifiers and configuration words remain unchanged.

| Buffer | Required bytes | Storage |
| --- | ---: | --- |
| `field2d` | 770048 | FP64 `(2048,47)` in Fortran order |
| `field3d` | 409600 | FP64 `(2048,5,5)` in Fortran order |
| `parameters` | 208 | 52 signed 32-bit identifiers, first 47 for 2D fields |
| `configuration` | 2304 | 288 raw 64-bit words described below |

FP64 means a 64-bit floating-point number. Fields and configuration require eight-byte alignment, and identifiers require four-byte alignment. Each supplied capacity must cover its complete required span, without address wrap. The two field spans must be disjoint from each other and both immutable spans. Immutable spans may overlap. Every declared field value belongs to the output, with no padding or omitted boundary points.

Configuration words use zero-based positions. Word 0 is zero for a valid configuration, word 1 is 2048, and word 2 gives the greatest supported vegetation index from 0 to 127. Words 3 to 7 contain the original `LECMWF`, `LECURR`, `LEOCCO`, `LEOCWA` and `LMCC04` logical values, with zero meaning false. Words 8 to 12 contain the FP64 bits for gravity `RG`, freezing temperature `RTT`, water density `RHOH2O`, water-capacity scale `RWLMAX` and sea-ice minimum `RCIMIN`. Words 13 to 16 give the lower and upper bounds of the two vegetation tables, each of which must contain indices zero through word 2. Word 17 is format revision 1. Words 32 through 159 contain vegetation cover values at indices 0 through 127, and words 160 through 287 contain leaf area indices. Unused words and table entries are retained unchanged.

The first matching identifier selects each field, as in the original source. Required 2D identifiers are `172, 235, 139, 170, 183, 236, 198, 39, 40, 41, 42, 228009, 228010, 228007, 34, 29, 30, 27, 28, 43, 31`. Identifiers `151131` and `151132` are additionally required when `LECURR` is true and `LMCC04` is false. Required 3D identifiers are snow amount `228141`, snow temperature `238` and liquid water `228038`. The three lake identifiers retain their original initialised values from `yom_grib_codes.F90`.

## Arithmetic and Rejection

The floating-point control register (FPCR) must be zero, which selects nearest-even rounding and gradual underflow. The floating-point status register (FPSR) retains incoming flags and records the original required arithmetic. Preserve FPCR, `errno`, `x18`, saved integer registers and the low halves of vector registers `v8` to `v15`. The parent uses a 384-byte stack frame aligned to 16 bytes and calls only the direct scaling child. It has no Fortran, codec or operating-system dependency.

Finite field values and valid finite physical constants and table values are caller requirements. Round vegetation types to the nearest integer with half values away from zero, using `FCVTAS` as in the genuine compiled source. Before any field write, reject each vegetation value outside the range that rounds into its table, including NaN, a stored not-a-number value. The validation restores incoming FPSR before either rejection or the scaling call, so it contributes no arithmetic flags to the result.

Return 0 for success, 1 for invalid buffer spans, 2 for nonzero FPCR, 3 for unsupported configuration, 4 for an absent required field, or 5 for an invalid vegetation index. Every rejected call leaves the complete two fields and FPSR unchanged. Integer flags and caller-saved registers are scratch.

Retain every multiplication in the scaling child, including multiplication by one. For final adjustments, use the genuine source `FMAXNM` and `FMINNM` routes for maximum and minimum. Sum snow and liquid water separately, each from positive zero in increasing layer order, then subtract the two totals. Match the source ordered comparison with `FCMPE` and `B.LS`, so an unordered result from overflowing totals does not clear the layers. Retain all signed zeros and intermediate FP64 rounding points. Do not fuse or reorder operations.

Let $`c_L`$ and $`c_H`$ be the separately rounded cover products, and let $`a_L`$ and $`a_H`$ be the two selected leaf area indices. Form the capacity through these separate rounded stages, then multiply by `RWLMAX`.

```math
u_1=1-c_L,\quad u_2=u_1-c_H,\quad u_3=c_La_L,\quad u_4=u_2+u_3,\quad u_5=c_Ha_H,\quad u_6=u_4+u_5,\quad W_{\max}=W_0u_6.
```

The source uses exactly `273.15` K for the lake-bottom limit, while snow and missing sea temperature use the supplied `RTT`. Preserve both values. Keep the original ocean soil-temperature rule, including its recorded source warning, without changing the physics.

## Current Checks and Limits

The local candidate passes eleven focused cases against the separate original-source control, including land and sea points, missing values, ocean flags, current flags, snow limits, vegetation ties, invalid indices and finite inputs whose snow totals overflow. Three seeded ABI paths pass. All 1,179,648 field bytes agree, immutable inputs and protected boundaries remain unchanged, and independent checks confirm the specified snow, water, ice, lake and current bounds. The accepted scaling-child checks also cover independently rounded unit products. The selected actual input also passes. All 1,179,648 returned field bytes match both the isolated original-source control and the actual original MODGRINML capture. Fresh flags agree, and the actual incoming status gives the exact returned FPCR 0, FPSR 16 and errno 2, with a zero native ABI mask. The actual configuration has 20 vegetation types, disabled currents and both ocean flags true. Independent source and interface review passes. The joint native forecast passes all 27,486,113 bytes in 685 complete final owners and all 618,140 bytes in ten saved files, with matching immediate status and positive direct input counters. This component does not provide a complete autonomous forecast.

The [complete GPU surface implementation](../../../../md2fort-gpu/references/openifs/input/complete_surface_initial_conversion.md) combines the required scaling and conversion in one launch while preserving these fields, arithmetic and public buffer rules. Its contract records the changed transport checks and the retained independent physical evidence.

## Operational Extension

Revision 2 adds `md2asm_convert_operational_initial_surface_state` with the same eight-argument ABI. It selects exactly 6,599,680 points, 50 ordinary fields and five fields with five snow layers. Required capacities are 2,639,872,000, 1,319,936,000, 220 and 2,304 bytes for the two field buffers, IDs and configuration. All byte products and addresses are 64-bit. Each ordinary plane is 52,797,440 bytes, and each five-layer field is 263,987,200 bytes. The explicit entry selects the geometry; caller bytes cannot select another shape. The original entry retains its 2,048-point, 47-field route.

Only integer extents, strides, search bounds and the matching scaling-child entry change. Both routes share the original floating-point instructions, first-match lookup, vegetation checks, ordered five-layer snow reductions, constants and tables. The 384-byte frame retains four selected integer values in previously unused slots. The complete original source is recovered by the recorded inverse projection. Existing buffer, overlap, alignment, configuration and FPCR checks still occur before mutation.

A separate source process calls genuine complete MODGRINML and SURF_INQ with actual source-backed controls and a registered source surface handle. The native process compares every one of the 3,959,808,000 operational result bytes and 1,179,648 legacy result bytes, with zero differences. It also checks 4,608 configuration bytes, 428 ID bytes, unchanged constants and 548,260 guard bytes. Five immediate ABI observations have zero native masks; FPCR remains zero and errno remains 777. The operational arithmetic produces FPSR 16 from zero. The source's allowed x18 change is recorded separately and is not allowed in native code. A short ordinary-field capacity returns one with both field buffers protected against writes. Both bounded processes finish and release their mappings.

The unchanged unit, snow, vegetation and physical evidence is reused. This checkpoint qualifies complete conversion, scaling and owned conversion configuration. It does not qualify the surrounding file-loading caller, complete setup or an operational forecast.
