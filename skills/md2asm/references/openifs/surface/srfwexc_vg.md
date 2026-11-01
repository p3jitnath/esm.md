# Soil Water Exchange Contract

Revision 1. [Physics input](../../../../../formulations/openifs/surface/soil_water_transfer.md), equations WT-1 and WT-2. [Direct source](../../../../../src/openifs/surface/soil_water_exchange.S). The original numerical reference is `SRFWEXC_VG_MOD::SRFWEXC_VG`.

## Complete Update

The routine computes the frozen soil fraction from temperature, limits liquid water between the wilting and field-capacity values, and distributes root extraction between layers. Condensation goes to the first layer. Otherwise each root weight is its vegetation weight times available liquid water, with the source's optional small water-balance correction. The normalising denominator is at least $`100\,2^{-52}`$.

Each interface uses the greater wetness of its neighbouring layers. Dry interfaces use minimum diffusivity and zero conductivity. Saturated interfaces use the table limits. Intermediate interfaces use WT-2 and its diffusivity relation, where $`D`$ is in square metres per second.

```math
D=\frac{(1-m)K_s}{\alpha m(w_s-w_r)}
s^{\ell-1/m}
\left[(1-s^{1/m})^m+(1-s^{1/m})^{-m}-2\right].
```

The parameter $`\alpha`$ is the inverse length from the soil table. Frozen fractions blend diffusivity with its minimum and reduce conductivity. The last layer permits downward drainage and has no diffusion coefficient. Surface runoff uses either the source's subgrid saturation model or its infiltration-rate limit. The update includes rain, snowmelt, interception, vegetation, bare-soil and urban fluxes. It returns runoff, diffusion coefficients, water increments, gravity fluxes, two accumulated evaporation budgets and all written diagnostic fields. The diagnostic field 8 remains unchanged.

All operations use separately rounded FP64 instructions, which store about 16 decimal digits. Powers with real non-integer exponents use the qualified private POWER entry. A square is a separate multiplication. The source's lower-layer default-real `1.001` is first rounded to FP32 and then widened to FP64. All other declared constants retain their original kinds. The source order is retained for each layer sum, root sum, flux addition and diagnostic update. Columns are independent.

## Declared Domain

There are 1 to 4,096 columns, 2 to 512 soil layers and 8 to 10 tiles. A contiguous active column interval may be empty. GNU descriptors support positive, negative and gapped strides, with non-overlapping dimensions. Diagnostic storage may have zero extent. Nonempty diagnostic storage has at least ten fields. Every numerically consumed value must be finite. Land temperatures are 100 to 500 kelvin, wetness and consumed tile fractions are 0 to 1, and consumed fluxes have magnitude at most 1 kilogram per square metre per second. Nonland temperature storage may contain zero. Unused nonland hydraulic values and copied accumulator payloads remain unchanged and need no physical bounds. The time interval is between $`10^{-9}`$ and $`10^9`$ seconds.

Selected land soil tables satisfy $`0\leq w_r\leq w_{\mathrm{wilt}}\leq w_{\mathrm{cap}}<w_s\leq1`$ and $`0.05\leq m\leq0.95`$, with positive layer depths and inverse length. The conductivity exponent and minimum diffusivity use the extended limits stated below. Land wilting wetness is at least $`10^{-6}`$, the saturated-minus-residual wetness is at least $`10^{-6}`$, and a conductive intermediate face has relative wetness at least $`2^{-40}`$. These limits keep the consumed powers finite. Root weights are nonnegative. The thermal transition uses the already qualified 270.16 to 274.16 kelvin sinusoid. The fixed water density is 1,000 kilograms per cubic metre.

The positive surface runoff scale RPSFR is between $`10^{-9}`$ and 2. It multiplies the rain rate and supplies its ordinary reciprocal in the infiltration branch. The original coarse forecast uses 2, and both its complete nonland call and two consumed land runoff cases are independently checked without changing any numerical operation.

The original uses two slightly different dry thresholds for the two directions of an interface. To retain a conservative column balance, unfrozen interface wetness in the small interval above residual wetness and below the larger dry threshold is excluded before writes, except for the proved zero-transfer case defined in the next paragraph. Dry and saturated branches remain supported. An original-source witness with $`w_r=0.01`$, $`w=0.010005`$, $`m=0.95`$ and $`\ell=0`$ gains $`2.1094\times10^{-7}`$ kilograms per square metre with no external water source. This source limitation is retained, rather than modifying its outputs.

An otherwise excluded warm dry interface is also supported when its minimum diffusivity is positive zero and there are at most nine tiles. Let the dimensionless relative wetness be $`s=(w-w_r)/(w_s-w_r)`$, with $`s\geq2^{-40}`$ and the retained stored lower bound $`m\geq0.05`$. Use the first matching pair of upper limits: $`m\leq1/8`$ with $`s\leq2^{-7}`$; $`m\leq3/16`$ with $`s\leq2^{-11}`$; $`m\leq1/4`$ with $`s\leq2^{-14}`$; or $`m\leq5/16`$ with $`s\leq2^{-18}`$. These limits keep the first mathematical power normal and no greater than $`2^{-56}`$. For accepted argument words, the actual selected POWER result must be positive normal and below $`2^{-55}`$, and its power of one must remain exactly one. Subtraction from one then rounds to one, so the conductivity factor is positive zero. Existing exponent and conductivity guards keep the other factors finite. Both ordered directions transfer zero water. The dispatch adds integer operations only, and all numerical arithmetic and input words remain unchanged. Actual source and native output bytes, ABI, FPCR, FPSR and errno must agree. Point-specific provider evidence does not establish a global POWER error bound. Minimum diffusivity alone does not admit this route, and the known nonconservative witness remains excluded.

## Interface and Evidence

The extended dry-interface dispatch passed four accepted boundary calls over 221,024 returned bytes with zero differences and 344 independent physical relations. Four first excluded neighbour inputs were refused before any of those bytes changed. One genuine class-2 input passed all 25,764 controlled bytes, status and interface checks. Its 1,032 scientific relations used 864 unchanged non-coefficient checks, 76 unchanged coefficient checks and 92 coefficient checks with propagated absolute error bounds for cancellation, which is loss of relative accuracy when subtracting nearby values. The earlier relative-error failures remain in the local record. Actual selected power values were checked against independent high-precision values for these arguments; this evidence applies to the checked inputs. These are component checks, and a complete forecast still requires its own state and output comparison.

The Arm application binary interface has 32 address arguments, with the first eight in registers and the remaining 24 on the stack. Integers and logical values are four bytes. FP64 values and descriptor owners have eight-byte alignment. The callee preserves the required general and floating-point registers and the stack alignment. Returned owners must be disjoint from inputs, descriptor headers, parameter objects and consumed tables. All bounds and scientific admission checks run before caller outputs change.

The original source passed 24 protected placements over 3,232,896 complete returned bytes and 94,164 independent 110-digit relations before direct generation. The checks cover water units, gravity transport, each layer balance, the column balance, frozen and saturated soils, both runoff branches, root extraction, urban terms, nonland cells and diagnostics. The complete native gate returned the same 3,232,896 bytes with zero differences and 188,328 source/native physical relations. The immediate ABI and paired routes each passed two focused calls over 536,784 bytes. Two new nonland and empty cases passed 36,168 bytes on source, native and paired routes. Seven prewrite cases preserved 29,624 shared output bytes. The numerical core was unchanged during the focused admission corrections. Unchanged SIN and POWER qualifications, soil layouts and protected-buffer tools are reused.

| Arguments | Meaning |
| --- | --- |
| 1–5 | `KIDIA, KFDIA, KLON, KLEVS, KTILES` give the active interval and counts |
| 6 | `PTMST` is the time interval in seconds |
| 7–9 | `KTVL, KTVH, KSOTY` give low vegetation, high vegetation and soil types |
| 10–15 | `PSDOR, PFRTI, PEVAPTI, PWSAM1M, PTSAM1M, PCUR` give terrain, fractions, evaporation, wetness, temperature and urban share |
| 16–21 | `PTSFC, PTSFL, PMSN, PEMSSN, PEINTTI, PEVAPSNW` give convective rain, large-scale rain, melt, snow mismatch, interception and forest-snow evaporation |
| 22–24 | `YDSOIL, YDVEG, YDURB` are soil, vegetation and urban parameter objects |
| 25–28 | `PROS, PCFW, PRHSW, PSAWGFL` return runoff, diffusion coefficient, water increment and gravity flux |
| 29–30 | `PFWEL1, PFWE234` accumulate top-layer and deeper-layer evaporation |
| 31 | `LDLAND` is the logical land mask |
| 32 | `PDHWLS` contains optional soil-water diagnostics |

GNU descriptors describe each array's first address, element size, dimensions and strides. A stride is the memory gap between adjacent elements. The complete returned memory spans include inactive cells and padding, which must remain byte-for-byte unchanged. One 48-byte scratch set per layer is reused across columns. This local storage contains the ice fraction, liquid water, three root profiles and total root extraction. Model-wide scientific acceptance and whole-forecast timing remain separate checkpoints.


Each one-dimensional field contains at least the column count. The soil matrices have column and layer dimensions. Tile matrices have column and tile dimensions. Diagnostics have column, layer and diagnostic-field dimensions. Terrain and layer depths use metres, temperatures use kelvin, and water fractions and tile shares are dimensionless. Input fluxes and evaporation accumulators use kilograms per square metre per second. Runoff uses kilograms per square metre, diffusion coefficients use metres, returned increments are dimensionless and gravity fluxes use kilograms per square metre per second.

## Observed Runoff-Scale Admission

The first actual coarse call used RPSFR equal to 2, while the original guard capped it at one. The corrected admission retains the complete arithmetic body. Two protected replays of the captured call match 21,120 original output bytes with zero differences and 3,552 source/native independent relations. Four protected land cases cover both runoff methods, the value 2 and its neighbour below 2, matching 12,768 bytes with zero differences and 512 source/native relations. Immediate 32-address ABI and paired routes pass. The neighbour above 2 rejects before changing all 10,560 shared output bytes. Existing positive-input, physical, interface and helper proofs are reused. Actual combined

The hydraulic tables can have zero minimum diffusivity and a negative conductivity exponent. The supported minimum diffusivity is zero to 0.01 square metres per second, and the exponent is −2.3421 to 4. These values include the unchanged coarse-model tables. In the captured land call, evaporation and interception nearly cancel. Independent layer and column error estimates use the sum of the absolute contributing fluxes before cancellation, with the unchanged rounding factor $`4096N2^{-52}`$. A 110-digit calculation checks the physical balance, and complete original and assembly owners must still have zero differing bytes.

## Zero-Transfer Admission Checks

A genuine 24-column, four-layer exchange replay matches all 55,256 reconstructed owner bytes and the original floating-point status and system error value. Two controlled single-column boundary pairs match 110,512 complete owner bytes and pass 172 source and assembly physical relations. Four nearby excluded cases preserve 221,024 complete owner bytes before refusal. A rolling assembly exchange, diffusion, increment and correction chain then matches all four saved original boundaries, with 221,024 returned owner bytes and identical status at every stage. These component checks do not establish a complete forecast.

The genuine call also has 1,032 independent physical relations: 908 retain their previous bounds, and 124 hydraulic coefficients use propagated rounding bounds because subtraction can cancel leading digits. The consumed POWER values are checked independently at two high precisions. The earlier 82 coefficient-relative failures remain in the local evidence; all 24 column-water balances pass their unchanged limits. This qualification covers the saved input and does not claim a global error bound for POWER.

## Actual Forecast Acceptance


| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| srfwexc_vg_mod::srfwexc_vg | 2,150 | 22,704,000 | Complete returned routine owners |

Shared saved-file evidence and its limits are in the [coverage record](../../../../../src/openifs/README.md#shared-coarse-forecast-evidence).
