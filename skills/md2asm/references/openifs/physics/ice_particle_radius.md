# Ice Particle Radius Contract

The [physical input](../../../../../formulations/openifs/physics/ice_particle_radius.md) is revision 1.0. The complete direct entry is [ice_effective_radius.S](../../../../../src/openifs/physics/ice_effective_radius.S), which replaces the original queued name `ICE_EFFECTIVE_RADIUS`. The original source is `arpifs/phys_radi/ice_effective_radius.F90`. No driver supplies a numerical stage.

## Supported Calculation

All four `NRADIP` options are included. Option 0 writes 40 micrometres. Options 1 and 2 use the following separately rounded polynomial, with $`t=\min(T-RTT,-0.1)`$.

```math
r=326.3+t[12.42+t(0.197+0.0012t)].

```

Option 1 limits this result to 40–130 micrometres. Option 2 limits it to 30–60 micrometres. Option 3 uses ICE-1 to ICE-3, including both constant and latitude-dependent minimum diameter and the complete optional SPP perturbation. SPP means a configured random change to a model parameter.

The original option-3 order is $`a=(1000p)/(R_dT)`$, $`I=[a\,{\rm RN}(q_i+q_s)]/c`$, $`A=45.8966\,I^{0.2214}`$ and $`B=0.7957\,I^{0.2535}`$. It then computes $`[1.2351+0.0105(T-RTT)][A+B(T-83.15)]`$. Each multiply, add, subtract and divide rounds separately. The optional multiplier is $`\exp(\mu+xP_{\rm pert})`$, evaluated before the diameter limits. The clear branch writes $`80RRE2DE`$. Radius conversion rounds after the diameter limits.

The scalar power calls use the accepted private original-compatible POWER primitive. Its fixed internal rounding rules are preserved through exact integer arithmetic and contain no fused floating-point instruction. The scalar exponential uses the accepted strict route. Their unchanged proofs are reused, while the new complete calculation has its own physical and output checks.

## Complete Latitude Domain

The latitude-dependent option accepts every finite FP64 sine of latitude from −1 to 1, including signed zero and the two poles. It calls the accepted original-rounding ASIN primitive, then passes that rounded result to the accepted original-rounding COS primitive. It then subtracts 20 from RMINICE, multiplies by the cosine and adds 20, with a separate rounding after each operation. This preserves the source calculation instead of using a square-root identity. The ASIN result is within the COS primitive's accepted range. These calls use [asin_original_rounding.S](../../../../../src/openifs/support/asin_original_rounding.S) and [sin_cos_original_rounding.S](../../../../../src/openifs/support/sin_cos_original_rounding.S).

An integer check of the input bits rejects a non-finite sine or a magnitude greater than one. The routine computes and checks every selected minimum diameter before writing any output radius. The constant-minimum branch does not consume latitude, and the other options retain their existing input rules.

The earlier coarse qualification used `NSMAX=21`, `NDGLG=32`, `NSTTYP=1` and `RSTRET=1`. Its complete 32-row Gaussian proof and saved forecast comparison remain historical evidence. The general route uses the qualified arithmetic helpers for other supported latitude words, and its changed component checks include values outside those 32 rows.

## Interface And Storage

Fourteen addresses follow the GNU Fortran AArch64 ABI. The original and direct entries are subroutines with no defined W0 return value. The first eight use x0–x7 and the last six use the incoming stack. Arguments in order are TERAD, TSPP_CONFIG, KIDIA, KFDIA, KLON, KLEV, pressure, temperature, cloud fraction, ice mass fraction, snow mass fraction, sine of latitude, output radius and optional perturbation. Integer scalars use four bytes. All real arrays use FP64 and Fortran column order, with column as the fastest index.

Each matrix owns `8*KLON*KLEV` bytes. Latitude owns `8*KLON` bytes. Perturbations, when consumed, own `8*KLON*NRFTOTAL_RADGRID` bytes. Only selected columns of the output matrix change. Inactive output words and unused input words retain every bit, including NaN payloads. Input and output owners must not overlap. Array storage needs eight-byte alignment.

TERAD owns 2040 bytes. Its consumed fields are NRADIP at 116, NMINICE at 164, RRE2DE at 584 and RMINICE at 608. TSPP_CONFIG owns 3192 bytes. LSPP is at 0, NRFTOTAL_RADGRID at 220, the GNU rank-one PN descriptor at 352 and ZRADEFFI at 568. Each PN entry owns 184 bytes. MU, XMAG and MP_RADGRID are at 56, 24 and 140. Descriptor lower bounds locate the selected entry, with the unit stride of the allocated PN owner.

The native entry preserves x19–x29, the lower 64 bits of v8–v15 and stack alignment. It uses at most an aligned eight-byte temporary per column for the minimum diameter. It checks FPCR before execution and keeps round-to-nearest, gradual underflow and signed zero. Solver arithmetic contains no expression contraction or reassociation.

## Acceptance Limits

Supported shapes have 1–2048 columns and 1–512 levels, with a valid selected column interval or an empty interval. Options 1 and 2 consume finite temperatures from 160 to 350 kelvin. The cloudy option-3 branch consumes positive finite pressure, finite temperature in that range, cloud fraction in (0.001,1], and nonnegative finite ice and snow fractions. The declared physical corpus uses at most 120000 pascals and 0.1 kilograms per kilogram for each condensed species. Clear branches may retain unused temperature and pressure NaN words. Configured diameter and radius-conversion factors are positive and finite. Optional perturbation indexes must fit their declared owner and its exponential argument must remain within the accepted scalar range.

The source physical gate passes 56 protected placements, 96912 complete output bytes and 34924 independent physical relations. It covers all four options, both minimum-diameter choices, the optional perturbation, complete latitude rows, strict cloud-threshold cases, inactive columns, unused NaN storage and 512 levels. The direct body passes the same 56 protected placements and 96912 output bytes, with 69848 independent source/native relations and immediate ABI preservation. Three focused interface cases add 248 bytes and 148 physical relations for shifted PN lower bounds, a true LSPP flag with selector zero and an empty interval. Three paired entry calls compare 472 bytes, check 146 live physical relations and exercise all 32 latitude words. Two historical shared-output checks covered the earlier 32-row latitude guard and the unchanged unsupported-option guard before any output write. The small inactive-mode perturbation guard refinement reuses the unchanged numerical proof. Acceptance requires zero differing output bytes, preserved read-only owners, independent radius and unit checks, immediate ABI preservation and FPCR zero. Forecast acceptance additionally requires the actual latitude guard and unchanged saved output files.

The general latitude route passes two original/direct pairs at 8 columns and 137 levels, with 17536 complete output bytes and zero differing bytes. The inputs include both poles, signed zeros, finite values outside the former table and eight retained operational-grid sines. Low ice content makes the latitude minimum control the first layer, while a clear layer checks the unchanged default. Each role passes 2229 independent physical relations, preserves read-only owners and bounds, and returns with FPCR zero, FPSR 16 and errno 777. Both actual ABI masks are zero, and neither void entry has a defined W0 result. A separate native call with an invalid final-column sine stops with all 8768 output bytes unchanged. This is changed-child acceptance; the corrected complete forecast remains unverified.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 passes these positive actual calls with zero differing bytes. Each byte scope describes the complete owners compared by that routine.

| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| ice_effective_radius | 6,400 | 7,782,400 | Complete routine owners |

All ten saved files also match across 618,140 bytes. The accepted critical physics and interface checks are reused. These checks cover the declared routine domains and saved files. Whole-forecast physical verification, whole-process byte identity and comparative timing remain open in the [coverage record](../../../../../src/openifs/README.md).
