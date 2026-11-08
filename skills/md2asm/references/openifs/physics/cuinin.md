# CUININ Numerical Contract

[CUININ](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/physics/cuinin.S) implements [Convective Initial State](../../../../../formulations/openifs/physics/convective_initial_state.md), revision 1, equations I1–I3. Its private [environment adjustment](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/physics/cuinin_environment.S) implements the complete normal-physics CUADJTQ body for ICALL=3. That private body is separate from the queued full CUADJTQ routine and its other modes.

## Supported State and ABI

The direct and paired entries require and check `TEPHLI%LPHYLIN=false`. The tangent-linear CUADJTQS route remains outside this contract. `KLON` is positive and `KLEV` is at least one. The selected one-based column interval can be empty. Otherwise its endpoints lie within KLON. Used pressure is positive. Finite provisional layer temperatures can have either sign because the source combines neighbouring dry-static energies before adjustment. The resulting temperature used by saturation adjustment must be finite, exceed 32.19 K and stay clear of the source saturation poles. Finite adjusted temperatures are positive and humidity is nonnegative. The observed complete missing-column state is also admitted under the explicit bit rules below. The supplied NJKT2 integer selects the first interior adjustment level.

The AArch64 application binary interface, or ABI, receives 27 addresses. Arguments 1–8 use `x0–x7`. The remaining arguments use consecutive eight-byte caller stack slots. Integers occupy four bytes and FP64 reals occupy eight bytes. Arrays are contiguous, aligned to eight bytes, disjoint and stored with the column index changing fastest. Layer matrices contain `KLON*KLEV` values. Face matrices contain `KLON*(KLEV+1)` values.

| Arguments | Meaning | Storage |
| --- | --- | --- |
| 1–2 | `YDEPHLI,YDECUMF` | Plain objects, 120 and 344 bytes |
| 3–6 | `KIDIA,KFDIA,KLON,KLEV` | Integer scalars |
| 7–12 | `PTEN,PQEN,PQSEN,PUEN,PVEN,PGEO` | Layer matrices |
| 13 | `PAPH` | Face pressure |
| 14 | `KLAB` | Integer layer labels |
| 15–17 | `PTENH,PQENH,PQSENH` | Half-level state held in layer-sized arrays |
| 18 | `PGEOH` | Face geopotential |
| 19–27 | `PTU,PQU,PTD,PQD,PUU,PVU,PUD,PVD,PLU` | Plume layer outputs |

A metadata-only probe measured `TECUMF%NJKT2@312`. The existing interface proof supplies `TEPHLI%LPHYLIN@4`. Thermodynamic scalars reuse the frozen source definitions from the accepted [saturation contract](satur.md). The private child receives the original twelve-address CUADJTQ ABI, requires ICALL=3 and LPHYLIN=false, and ignores its unused flags exactly as that source branch does.

The caller preserves `x19–x29`, the low 64 bits of `v8–v15`, stack alignment and FPCR. It does not use `x18`. It has a 384-byte fixed frame and an aligned `12*KLON+32`-byte arena before alignment, limited to one MiB. The child has a fixed 320-byte frame and no array allocation. Both use only the qualified scalar EXP route.

## Complete Ordered Calculation

Set `inverse_cp=1/cp`. For each face index JK from 2 through KLEV, form I2 from two separately rounded `cp*T` products, their geopotential sums, the numeric maximum, the face-geopotential subtraction and the inverse_cp product. Copy previous-layer humidity and saturation humidity into PQENH and PQSENH. Copy the face pressure into a reusable column vector and set selected logical flags to true.

Skip adjustment when `JK>=KLEV-1` or `JK<NJKT2`. Otherwise execute the complete two-pass ICALL=3 child on that face. Then form `PQENH=max(0,min(previous_q,previous_qsat)+(adjusted_qsat-previous_qsat))` with separate subtraction, addition and numeric maximum against positive zero.

For each child pass, calculate the bounded quadratic liquid fraction a from H3. Form `e=R2ES*(a*exp(R3LES*(T-RTT)/(T-R4LES))+(1-a)*exp(R3IES*(T-RTT)/(T-R4IES)))`. Preserve each product, subtraction and division before EXP and each mixture product afterwards. Set `z=min(0.5,e*(1/p))`, `cor=1/(1-RETV*z)` and `qsat=z*cor`. The pressure reciprocal is rounded once before the two passes.

Calculate `F=(a*R5ALVCP)*(1/(T-R4LES)^2)+((1-a)*R5ALSCP)*(1/(T-R4IES)^2)`. Square each temperature difference before its exact division. Set `cond=(Q-qsat)/(1+(qsat*cor)*F)`. Form `heat=a*RALVDCP+(1-a)*RALSDCP`, then `T=T+heat*cond` and `Q=Q-cond`. The second pass repeats these complete equations with the updated T and Q. This is environmental adjustment, so condensation has neither the nonnegative clamp of an updraft nor the nonpositive clamp of a downdraft.

After the face loop, set bottom PTENH to `((cp*T_bottom+geo_bottom)-geoh_bottom)*inverse_cp` and bottom PQENH to the bottom layer humidity. Then copy the first layer's temperature and humidity to the upper boundary. This order also defines the one-layer case, where the upper copy is last. PQSENH at the first face remains supplied. The bottom face keeps its previous-layer saturation value when KLEV exceeds one.

Copy every selected PTENH and PQENH cell into both plume states. Set PLU to positive zero and KLAB to zero. Copy each wind component from the previous layer into both plumes, using the first layer at the first face.

## Arithmetic and Canonical Bytes

The primary contract uses ordered FP64 operations, round-to-nearest with ties to even, gradual underflow and signed zeros. It excludes fused arithmetic, reassociation, approximate division and reduced precision. The assembler and linker build directly emitted AArch64 bodies. Verification drivers supply no missing numerical stage.

Canonical output owners are KLAB, PTENH, PQENH, PQSENH, PTU, PQU, PTD, PQD, PUU, PVU, PUD, PVD and PLU, in that order. Complete little-endian owners include inactive columns and untouched saturation boundary values. All other inputs remain unchanged. Acceptance requires zero differing output bytes, independent dry-static and moist-adjustment checks, protected buffer bounds, preserved registers and FPCR. Complete forecast acceptance requires the combined saved-file comparison.

## Verification State

Critical verification passed 82 protected placements, 143 500 independent 100-digit dry-static, moist-adjustment and plume-state relations and 2 875 200 complete source/native owner bytes with zero differences. Cases cover one, two, three, six and 137 layers, stable and unstable profiles, four NJKT2 values, empty and cropped intervals, adjusted interior faces and all boundary assignments. Both moist corrections obey their latent heat and water balance and approach the physical saturation curve. Input owners, preserved registers and FPCR remain unchanged. The paired smoke passed 18 genuine calls, 693 600 complete output bytes and 3 600 critical live initial-state identities, with 2 740 adjusted column faces. The complete child proof is reused in the relay rather than recomputing each unchanged adjustment. Scalar EXP and source thermodynamic definitions reuse their accepted evidence.  All work used exclusive job 7240564 on nid010555, CPU 32, with local memory placement.

## Positive Optimisation Lesson

Keep pressure and logical column vectors in one small caller arena. The environment child keeps each cell's state in a fixed scalar frame and completes both adjustments before storing its final state. Reuse the liquid fraction within each unchanged-temperature pass and cache the pressure reciprocal across the two passes, preserving all source rounding points. This avoids full layer work arrays while retaining the complete calculation.

## Missing Columns and Boundary Bytes

A quiet NaN is a floating-point missing-value pattern. The frozen forecast supplies some complete temperature columns as the exact negative quiet-NaN word `fff8000000000000`. Its consumed saturation humidity is finite and nonnegative or uses that same word. Layer humidity, wind and geopotential remain finite. This observed state is admitted and checked before execution. Other consumed missing encodings are rejected. The complete original/native owner comparison preserves every admitted input and output bit. No physical temperature or water-balance claim is made for a missing column.

The source uses numeric MAX for dry-static energy and final adjusted humidity. FMAXNM retains the numeric operand when the other operand is a quiet NaN, so a missing adjusted humidity becomes the original positive-zero result. No input or output is normalised. The private mode-3 numerical body remains unchanged. The finite column in the captured call has a negative provisional layer temperature, while the neighbouring energy maximum gives a positive temperature for adjustment. The guard therefore checks the derived consumed temperature, rather than applying a saturation threshold to the provisional layer.

Before NJKT2, upper temperature placeholders can have separately checked quiet-NaN payloads and signs. Copies retain them, while the numeric energy maximum uses its finite alternative when present. The source-unused top face pressure and geopotential, final-layer saturation and final-layer winds retain their input bytes. CUMASTRN begins its energy calculation at NJKT2, which is 4 in the frozen forecast. Caller evidence remains local.

The focused correction passes six protected placements and 273 600 complete original/native output bytes with zero differences. It replays both complete captured forecast calls and the separate upper-placeholder edge case. A 100-digit physical check adds 404 relations for the captured finite column. The full existing relay closure passes six CUININ calls, 273 600 bytes and 6 912 live initial-state identities, plus 84 public CUADJTQ mode-3 calls and 612 864 bytes with zero differences. The child observes 644 canonical missing cell inputs. Complete read-only owners, saved registers and FPCR pass. The earlier finite and mode-3 scientific proofs are reused, and an unsupported consumed missing payload is rejected before execution. Combined

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 observed 4,300 genuine calls. The same-input comparison covers 196,080,000 complete returned owner bytes with zero differences. Independent critical physics, unchanged inputs and the declared interface checks passed. All ten saved forecast files also match across 618,140 bytes. This result covers the declared routine domain and saved files. Independent whole-forecast physics, whole-process byte identity and comparative speed remain unproved.
