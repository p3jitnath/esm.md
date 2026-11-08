# Soil Water Exchange Contract

Revision 2. [Physics input](../../../../../formulations/openifs/surface/soil_water_transfer.md), equations WT-1 and WT-2. [Direct source](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/surface/soil_water_exchange.S). The original numerical reference is `SRFWEXC_VG_MOD::SRFWEXC_VG`.

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

The canonical reference corrects the original asymmetric dry thresholds. Each internal face uses the same dry product in both directions: the stored binary64 `1.001_JPRB` factor at the top face, and the original default-real `1.001` widened to binary64 at deeper faces. Equality selects the dry branch. Both directions keep equality to the rounded `0.999_JPRB` saturation product in the intermediate branch. The conductivity formula, its ordered arithmetic, the frozen fraction and the forward calculations remain unchanged. This is a declared numerical-contract revision with a corrected strict Fortran reference. The earlier source and the known nonconservative `m=0.95` witness remain archived; their changed outputs must be reported separately from the new zero-difference comparison.

The earlier dyadic zero-transfer admission is retained in the local history. It is no longer needed after the two directions use the same threshold. All computational-domain, finite-intermediate, buffer, status and interface requirements remain in force. A bottom outgoing face has no following reverse face. The former witness must now pass the corrected conservative layer and column equations, including quiet columns, rather than being silently admitted with the old arithmetic.

## Corrected Internal-Face Comparison

A coordinated component comparison covers 324 retained genuine calls, nine controlled threshold cases and the exact retained nonconservative witness. All 334 direct-assembly calls match the corrected strict Fortran reference over 8,586,824 complete controlled owner bytes, with zero differences. The returned floating-point control and status registers and the system error value agree for every pair. Native calls pass every ABI check, and the original compiler's previously declared x18-only exception remains visible in the raw records. All buffer guards, unchanged bytes and the actual water-density global also agree. Each corrected reference call is produced once; completed results are reused after interrupted tool attempts.

The numerical correction changes three of the 324 retained genuine original outputs, with 32 differing bytes in total. The old outputs remain archived as evidence of the earlier asymmetric calculation. The zero-transfer checks and the 2,150-call routine table below also describe that earlier numerical reference; they do not establish a trajectory for the corrected reference. The separate saved-output scientific check qualifies 341,045 retained relations. The earlier 28,125 coefficient-relative failures remain recorded and use the explicitly revised final-coefficient error allowance below. Three earlier water-balance failures use independently checked bounds for the source's ordered rounding. All 63,940 active returned conductivity and diffusion values are finite and nonnegative, and the exact retained nonconservative witness now passes its eleven layer, column and state checks. No complete corrected forecast or performance result is claimed.

## Hydraulic Coefficient Error Check

The independent check starts from the exact stored inputs and encloses each real hydraulic formula in an interval, a lower and an upper bound. Let $`u=2^{-53}`$ and let $`a,b`$ be the exact endpoint results of an operation. The interval allows $`u\max(\lvert a\rvert,\lvert b\rvert)+2^{-1075}`$ for an ordinary binary64 operation and $`2u\max(\lvert a\rvert,\lvert b\rvert)+2^{-1075}`$ for a power. This power allowance defines the chosen error budget; it is not a statement that every actual library call has that accuracy. Independent high-precision calculations with outward rounding construct the interval $`[L,U]`$. The direct acceptance rule requires the observed final coefficient to lie inside this interval, so its absolute error from the enclosed real formula is at most $`U-L`$. This is a declared replacement for the failed coefficient-relative limits, which remain in the archived records.

The error intervals can be very broad when subtraction removes leading digits, and do not give a tight estimate of physical accuracy. The largest retained 110-digit coefficient residual in this corpus is about $`1.2491\times10^{-8}`$ metres for the returned diffusion coefficient. Separate 220- and 340-digit calculations check the two rows with the widest intervals. Every returned coefficient must also be finite and nonnegative, and every layer, column, state and diagnostic relation remains required. The 314 checks of actual selected POWER argument and result words remain separate evidence. These recorded-input checks do not establish a global library error bound or acceptance for unseen inputs.

## Interface and Evidence

Before the symmetry correction, the extended dry-interface dispatch passed four accepted boundary calls over 221,024 returned bytes with zero differences and 344 independent physical relations. Four first excluded neighbour inputs were refused before any of those bytes changed. One genuine class-2 input passed all 25,764 controlled bytes, status and interface checks. Its 1,032 scientific relations used 864 unchanged non-coefficient checks, 76 unchanged coefficient checks and 92 coefficient checks with propagated absolute error bounds for cancellation, which is loss of relative accuracy when subtracting nearby values. The earlier relative-error failures remain in the local record. Actual selected power values were checked against independent high-precision values for these arguments; this evidence applies to the checked inputs. These are component checks, and a complete forecast still requires its own state and output comparison.

The Arm application binary interface has 32 address arguments, with the first eight in registers and the remaining 24 on the stack. Integers and logical values are four bytes. FP64 values and descriptor owners have eight-byte alignment. The callee preserves the required general and floating-point registers and the stack alignment. Returned owners must be disjoint from inputs, descriptor headers, parameter objects and consumed tables. All bounds and scientific admission checks run before caller outputs change.

For the earlier numerical reference, the original source passed 24 protected placements over 3,232,896 complete returned bytes and 94,164 independent 110-digit relations before direct generation. The checks cover water units, gravity transport, each layer balance, the column balance, frozen and saturated soils, both runoff branches, root extraction, urban terms, nonland cells and diagnostics. The complete native gate returned the same 3,232,896 bytes with zero differences and 188,328 source/native physical relations. The immediate ABI and paired routes each passed two focused calls over 536,784 bytes. Two new nonland and empty cases passed 36,168 bytes on source, native and paired routes. Seven prewrite cases preserved 29,624 shared output bytes. These historical gates kept their numerical core unchanged during the focused admission corrections; they do not qualify the later symmetry correction. Unchanged SIN and POWER qualifications, soil layouts and protected-buffer tools are reused.

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

The first actual coarse call used RPSFR equal to 2, while the original guard capped it at one. The corrected admission retains the complete arithmetic body. Two protected replays of the captured call match 21,120 original output bytes with zero differences and 3,552 source/native independent relations. Four protected land cases cover both runoff methods, the value 2 and its neighbour below 2, matching 12,768 bytes with zero differences and 512 source/native relations. Immediate 32-address ABI and paired routes pass. The neighbour above 2 rejects before changing all 10,560 shared output bytes. Existing positive-input, physical, interface and helper proofs are reused.

The hydraulic tables can have zero minimum diffusivity and a negative conductivity exponent. The supported minimum diffusivity is zero to 0.01 square metres per second, and the exponent is −2.3421 to 4. These values include the unchanged coarse-model tables. In the captured land call, evaporation and interception nearly cancel. Independent layer and column error estimates use the sum of the absolute contributing fluxes before cancellation, with the unchanged rounding factor $`4096N2^{-52}`$. A 110-digit calculation checks the physical balance, and complete original and assembly owners must still have zero differing bytes.

## Historical Zero-Transfer Admission Checks

A genuine 24-column, four-layer exchange replay matches all 55,256 reconstructed owner bytes and the original floating-point status and system error value. Two controlled single-column boundary pairs match 110,512 complete owner bytes and pass 172 source and assembly physical relations. Four nearby excluded cases preserve 221,024 complete owner bytes before refusal. A rolling assembly exchange, diffusion, increment and correction chain then matches all four saved original boundaries, with 221,024 returned owner bytes and identical status at every stage. These component checks do not establish a complete forecast.

The genuine call also has 1,032 independent physical relations: 908 retain their previous bounds, and 124 hydraulic coefficients use propagated rounding bounds because subtraction can cancel leading digits. The consumed POWER values are checked independently at two high precisions. The earlier 82 coefficient-relative failures remain in the local evidence; all 24 column-water balances pass their unchanged limits. This qualification covers the saved input and does not claim a global error bound for POWER.

## Historical Routine-Corpus Evidence


| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| srfwexc_vg_mod::srfwexc_vg | 2,150 | 22,704,000 | Complete returned routine owners |

This table retains the earlier numerical reference. Shared saved-file evidence and its limits are in the [coverage record](../../../../../src/openifs/README.md#shared-coarse-forecast-evidence).
