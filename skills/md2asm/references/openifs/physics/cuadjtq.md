# CUADJTQ Numerical Contract

[CUADJTQ](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/physics/cuadjtq.S) implements [Convective Saturation Adjustment](../../../../../formulations/openifs/physics/convective_saturation_adjustment.md), revision 1, equations A1–A2. It provides the complete queued `cuadjtq_` entry for normal physics. Mode 3 tail-calls the unchanged accepted [environment body](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/physics/cuinin_environment.S) and reuses its [CUININ proof](cuinin.md).

## Modes and Supported Inputs

The direct and paired entries require `TEPHLI%LPHYLIN=false`. Temperature, humidity and pressure are finite, used pressure is positive, temperature stays clear of the saturation poles, and the accepted outputs remain physically admissible. KLON and KLEV are positive. KK is a one-based level from 1 through KLEV. The selected interval is empty or lies within KLON. Supported logical values are zero and one.

| ICALL | Physical branch | Columns | Phase choice |
| --- | --- | --- | --- |
| 0 | Environment adjustment | All selected | Standard mixed phase |
| 1 | Updraft condensation | True LDFLAG | Convective mixed phase |
| 2 | Downdraft evaporation | True LDFLAG | Convective mixed phase |
| 3 | Environment adjustment | All selected | Convective mixed phase |
| 4 | Flagged environment adjustment | True LDFLAG | Standard mixed phase |
| 5 | Environment adjustment | All selected | Standard mixed phase |
| 6 | Updraft condensation | True LDFLAG | Liquid-only where LDOFLAG is true, otherwise convective mixed phase |

Modes 1 and 3 also admit the captured missing-column interfaces from CUBASEN and CUININ. A consumed missing temperature must use the exact negative quiet-NaN word `fff8000000000000`, and pressure remains finite and positive. Mode 1 requires finite nonnegative humidity. Mode 3 permits finite nonnegative humidity or the same missing word. Other missing encodings and missing values in other modes are rejected. Complete owner bytes remain checked, but a missing cell has no claimed physical heat or water balance. The private mode-3 numerical body is unchanged.

Mode 6 requires the optional LDOFLAG address, as the original source does. Other mode codes make no changes in normal physics. The tangent-linear branches use TANH and remain outside this contract.

## GNU Fortran ABI and Bounds

The AArch64 application binary interface, or ABI, receives twelve addresses. The first eight use `x0–x7` and the last four use consecutive eight-byte caller stack slots. Integers and logical values occupy four bytes. Real values use FP64 and eight-byte alignment.

| Argument | Meaning | Storage |
| --- | --- | --- |
| 1 | YDEPHLI | Plain 120-byte object, LPHYLIN at byte 4 |
| 2–6 | KIDIA, KFDIA, KLON, KLEV, KK | Integer scalars |
| 7 | PSP | Pressure column vector |
| 8–9 | PT, PQ | Contiguous KLON × KLEV FP64 matrices |
| 10 | LDFLAG | Logical column vector |
| 11 | KCALL | Integer scalar |
| 12 | LDOFLAG | Optional logical column vector, or a null address |

The column index changes fastest. PT and PQ have disjoint owners and do not alias pressure, flags or the plain object. The selected row starts at `(KK-1)*KLON`. The direct body preserves `x19–x29`, the low 64 bits of `v8–v15`, stack alignment and FPCR, and does not use x18. Added modes use a fixed 384-byte frame and no array allocation. Accepted mode 3 retains its 320-byte frame. Thermodynamic constants and scalar EXP reuse the source definitions and accepted route from [saturation](satur.md) and CUININ.

## Frozen Calculation

Each admitted cell receives exactly two complete source corrections. Standard modes use RTICE and RTWAT_RTICE_R. Convective modes use RTICECU and RTWAT_RTICECU_R. Compute the bounded quadratic liquid fraction a with the original minimum, maximum, subtraction, inverse-interval multiplication and square. Latent heat divided by heat capacity is `H=a*RALVDCP+(1-a)*RALSDCP`, or RALVDCP for the pure-liquid branch.

Environment and evaporation modes use `exp(R3*(T-RTT)/(T-R4))` with a rounded product before division. Combine liquid and ice exponentials in their source order, multiply by R2ES, then by the once-rounded pressure reciprocal. Set `z=min(0.5,e*(1/p))`, `cor=1/(1-RETV*z)` and `qs=z*cor`. Form `F=(a*R5ALVCP)*(1/(T-R4LES)^2)+((1-a)*R5ALSCP)*(1/(T-R4IES)^2)` with denominator squares before exact divisions. Set `cond=(Q-qs)/(1+(qs*cor)*F)`.

Condensation modes first form `ZL=1/(T-R4LES)` and `ZI=1/(T-R4IES)`. Their exponentials use `(R3*(T-RTT))*ZL` or the corresponding ZI product, preserving the reciprocal rounding. Their F uses squared reciprocals. The raw saturation correction is `C=1-RETV*z` and their correction is `cond=(Q*C^2-z*C)/(C^2+z*F)`. Pure-liquid mode 6 uses only the liquid exponential, F and latent heat.

The first condensation pass uses `z=min(0.5,e*(1/p))`. Its second pass preserves the source MINJ expression `z=z-0.5*(abs(0.5-z)-(0.5-z))` rather than replacing it with a minimum. Clamp first-pass condensation to a minimum of positive zero with the source's numeric maximum, using FMAXNM. If the calculated correction is a quiet NaN, this maximum selects positive zero. If that result equals zero, set the second correction to positive zero. Otherwise the second correction is unclamped.

Mode 2 clamps its first correction to a maximum of positive zero. If that first result equals zero, clamp its second correction to a maximum of positive zero. Otherwise its second correction is unclamped. Environment modes do not clamp either correction.

For every pass, update `T=T+H*cond` and `Q=Q-cond` as separately rounded operations. Recompute phase, exponential, derivative and latent heat from the updated state before the second pass. Mode 6 retains the source's separate mixed-phase and liquid-only populations. Cells are independent, so completing each cell before moving to the next does not change a reduction or output dependency.

## Arithmetic and Canonical Output

The body is emitted directly as AArch64 assembly and built with an assembler and linker. Drivers supply no omitted numerical stage. The FP64 contract uses round-to-nearest with ties to even, gradual underflow and signed zeros. It forbids fused arithmetic, reassociation, approximate division, reduced precision and fast-math.

Canonical bytes are the complete PT owner followed by the complete PQ owner, in little-endian order. All other owners, inactive columns and nonselected levels retain their input bytes. Acceptance requires independent heat/water and saturation checks, zero differing raw bytes, protected buffer bounds, immediate ABI checks and unchanged FPCR. Original mode 3 proofs and unchanged EXP/phase evidence are reused. Added checks cover the new mode arithmetic, masks, optional liquid selection, saturation caps and storage interface.

## Verification State

The critical verifier passes 88 protected placements, 2 634 independent 100-digit heat/water and saturation relations, and 532 224 complete source/native output bytes with zero differences. It covers modes 0–6, an unchanged no-op code, both mask values, optional liquid-only flags, standard and convective phase endpoints, saturation caps, signed zeros, empty and cropped ranges, and one and 137 levels. Complete read-only owners, saved registers and FPCR pass. Mode 3 numerical and physical proofs are reused, with two changed-interface placements.

The paired live smoke passes eighteen genuine calls, 7 776 complete output bytes and 96 independent coupled heat/water relations with zero differences. Each mode has two calls, with two extra mode-6 liquid-only calls and two no-op calls. The immediate ABI and FPCR checks pass. The captured CUININ closure adds 84 genuine mode-3 calls, 612 864 complete owner bytes and 644 canonical missing cell inputs with zero differences. Its narrow guard correction retains the complete earlier finite scientific proof, saved-register checks and FPCR. The captured CUBASEN mode-1 call and one missing-cell range add four protected placements, 29 184 complete output bytes and twelve independent finite thermodynamic relations with zero differences. The four genuine paired calls preserve all missing bits, humidity bytes, read-only owners, saved registers and FPCR. Only the demonstrated first-pass numeric maximum changes. Mode 2 and other finite proofs remain valid, and both downdraft caller libraries bind the refreshed full child. Combined forecast acceptance still requires actual forecast calls and saved-file comparison.

## Positive Optimisation Lesson

Tail-route unchanged mode 3 into its accepted complete body. For the added modes, retain one cell in a fixed scalar frame, cache pressure reciprocal across both corrections and reuse phase fraction within each unchanged-temperature pass. Share the standard environment arithmetic among modes 0, 4 and 5 while keeping their column masks distinct. Keep the condensation reciprocal route and second-pass cap explicit so that sharing code preserves all rounding points.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 observed 234,868 genuine calls. The same-input comparison covers 1,713,596,928 complete returned owner bytes with zero differences. Independent critical physics, unchanged inputs and the declared interface checks passed. All ten saved forecast files also match across 618,140 bytes. This result covers the declared routine domain and saved files. Independent whole-forecast physics, whole-process byte identity and comparative speed remain unproved.
