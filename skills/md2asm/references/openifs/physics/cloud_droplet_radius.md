# Cloud Droplet Radius Contract

This contract covers the complete LIQUID_EFFECTIVE_RADIUS calculation from [the physics input](../../../../../formulations/openifs/physics/cloud_droplet_radius.md). A diagnostic uses the current atmospheric state and returns a radius without advancing time. The original Fortran is the discrete reference. Original independent physical checks passed 19 protected calls, 173,416 complete output bytes and 18,342 high-precision relations before assembly generation. The complete native body passes the same 19 protected calls and 173,416 bytes with zero differences, including immediate saved-register and FPCR checks. Six paired calls pass 1,472 bytes and 164 high-precision relations. Unsupported radius mode and out-of-range perturbation entries reject before a protected output can change.

## Interface And Storage

The Arm application binary interface defines how arguments and saved registers pass between routines. Eighteen addresses are passed in the original GNU Fortran interface. The first eight occupy x0–x7. The remaining ten occupy incoming stack bytes 0–72. Every scalar integer is a signed 32-bit value. Real arrays contain binary64 values, each using eight bytes.

| Argument positions | Meaning |
| --- | --- |
| 1–4 | Radiation, cloud, perturbation and atmospheric-field configuration objects |
| 5–8 | First active column, last active column, complete column count and level count |
| 9–13 | Pressure, temperature, cloud fraction, liquid mixing ratio and rain mixing ratio |
| 14–16 | Land fraction, land nuclei concentration and sea nuclei concentration |
| 17–18 | Returned radius and optional prescribed perturbations |

Arrays use column-major order, so consecutive columns share consecutive memory locations. A complete atmospheric array has column_count × level_count entries. Vectors have column_count entries. Only the selected columns of the returned radius may change. Empty selected ranges preserve every output byte. Input arrays, configuration objects, prescribed perturbations and their descriptor storage stay read-only. Owners must be aligned to at least eight bytes and active output cells must not alias consumed inputs.

The measured configuration layouts are radiation 2040 bytes, cloud 2776 bytes, perturbation 3192 bytes and atmospheric fields 1,359,136 bytes. The radiation mode is at 120, local land and sea nuclei flags at 520 and 524, and fixed land and sea concentrations at 552 and 560. The aerosol counts are at atmospheric 112, radiation 180 and 196, and cloud 1104. Perturbation enablement is at 0, its selected radius entry at 564 and its pattern count at 220. The rank-one perturbation descriptor is at 352, with a 184-byte element, scalar mean at 56, magnitude at 24 and pattern index at 140. The checked descriptor has unit element stride. The selected positive entry and pattern index must lie inside their complete owners.

The native frame is 16-byte aligned. It preserves x19–x30 and the low 64 bits of v8–v15, leaves x18 untouched and restores the stack pointer. Round-to-nearest, gradual underflow and preserved signed zeros require FPCR zero. No fused solver arithmetic, approximate division or square root is allowed.

## Ordered Calculation

The aerosol selection follows the original source before the radius mode is chosen. An active aerosol count of at least 12 with positive cloud aerosol enablement selects unsupported mode 3, which must reject before any output write. Modes 0, 1 and 2 are complete. Mode 0 uses 10 + ((100000 − pressure) × 3.5) in that order. Its coefficient has units µm Pa⁻¹. Independent physical acceptance for this legacy branch is limited to pressure 99,996–100,000 Pa. Mode 1 returns 13 µm for land fraction below 0.5 and 10 µm otherwise.

Mode 2 evaluates the positive quadratic term as (C × a) × C and the linear term as C × b, then subtracts the quadratic term. Sea adds 5.30 and land subtracts 27.9. Each operation rounds separately. An enabled positive perturbation entry multiplies the result by EXP(mean + magnitude × pattern), with a rounded multiplication before the rounded addition. The accepted strict EXP and LOG routes are reused.

The original compiler freezes the constant z in CDR-3 to binary64 bits 0x3fe5261293de469b over sea and 0x3fe5ef8102bb5092 over land. These values are part of the shared contract. The native solver loads them directly. The spectral spreads are the binary64 literals 0.77 and 0.69.

For each active cell, cloud fraction must be at least 0.001 and the rounded liquid-plus-rain sum must be positive. Density computes 1000 × pressure, then Rd × temperature, then divides. Liquid and rain each multiply by this density, then divide by cloud fraction. For liquid above REPSCW, divide rain by liquid, add one and call the uniquely named original-compatible POWER helper with exponent 0.666. The denominator computes 0.2 × z, then multiplies by the rain ratio, then adds one. Division returns the rain factor. Otherwise the factor is one.

Drop volume computes 3 × (liquid + rain), then divides by the separately rounded products ((4 × pi) × N) × d. Volume above REPLOG uses LOG, multiplication by 0.333 and EXP. Multiply the rain factor by 100 before multiplying by this exponential. Apply the original numeric minimum with 30 and numeric maximum with 4. Remaining cells return 4. Rd, pi, REPLOG and REPSCW are genuine original globals and stay read-only. No driver supplies a missing stage.

The source shadow retains its original profiling calls when LHOOK is enabled. Profiling records are separate from numerical output bytes. One focused enabled-profiling pair passes 48 complete output bytes with zero differences and FPCR zero. The native numerical body is unchanged.

## Acceptance

The physical corpus covers all three modes, fixed and local nuclei, both land classes, disabled and enabled perturbations, partial and empty active intervals, cloud thresholds, dry cells and subnormal water. Modern mode inputs require finite positive pressure and temperature, cloud fraction in 0–1, nonnegative water and positive activated concentration. The small verifier checks droplet volume and rain corrections using 70-digit decimal arithmetic, complete untouched owners, protected boundary pages, immediate saved registers and FPCR. Every complete source and native output byte must match with zero differences.  Accuracy samples establish the tested inputs, not a global bound.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 passes these positive actual calls with zero differing bytes. Each byte scope describes the complete owners compared by that routine.

| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| liquid_effective_radius | 6,400 | 7,782,400 | Complete routine owners |

All ten saved files also match across 618,140 bytes. The accepted critical physics and interface checks are reused. These checks cover the declared routine domains and saved files. Whole-forecast physical verification, whole-process byte identity and comparative timing remain open in the [coverage record](../../../../../src/openifs/README.md).
