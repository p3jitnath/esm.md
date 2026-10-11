# CUDDRAFN Numerical Contract

[CUDDRAFN](../../../../../src/openifs/physics/cuddrafn.S) implements revision 1, equations P1–P2, of [Convective Downdraft Descent](../../../../../formulations/openifs/physics/convective_downdraft_descent.md). It includes the complete normal-physics parent and privately binds complete [CUADJTQ](cuadjtq.md) mode 2. Unchanged child physical and arithmetic proofs are reused.

## Domain, ABI and Bounds

LPHYLIN is false. KLON and KLEV are positive. The selected column range is empty or lies within KLON. NJKT3 lies from 1 through KLEV. ENTRDD is finite and nonnegative, RMFCMIN is finite and positive, and used pressure differences and physical states are admissible. All accessed real values are finite. The lower-region pressure denominator is nonzero. Logical values are zero or one. The tangent-linear child branch remains outside this contract.

The GNU Fortran AArch64 application binary interface, or ABI, has twenty-four addresses. The first eight use x0–x7 and the last sixteen use consecutive eight-byte caller stack slots. Integer and logical values occupy four bytes. FP64 values use eight-byte alignment. Separate contiguous owners do not alias, and the column index changes fastest.

| Arguments | Meaning | Owner |
| --- | --- | --- |
| 1–2 | YDEPHLI, YDECUMF | Plain 120 and 344-byte objects |
| 3–6 | KIDIA, KFDIA, KLON, KLEV | Four-byte integer scalars |
| 7 | LDDRAF | KLON logical input |
| 8–11 | PTENH, PQENH, PQSEN, PGEO | KLON × KLEV FP64 input |
| 12–13 | PGEOH, PAPH | KLON × (KLEV+1) FP64 input |
| 14 | PRFL | KLON changed FP64 |
| 15–16 | PTD, PQD | KLON × KLEV changed FP64 |
| 17 | PMFU | KLON × KLEV FP64 input |
| 18–24 | PMFD, PMFDS, PMFDQ, PDMFDP, PDMFDE, PMFDDE_RATE, PKINED | KLON × KLEV changed FP64 |

LPHYLIN is at byte 4 of YDEPHLI. ENTRDD, NJKT3 and RMFCMIN are at bytes 40, 316 and 120 of YDECUMF, measured through the accepted metadata-only route. The body preserves x19–x29, the low 64 bits of v8–v15, sixteen-byte stack alignment and FPCR, without using x18. A fixed 640-byte frame and aligned 52*KLON+32-byte arena retain six FP64 column vectors and one logical vector. Arena size is rounded upward to sixteen-byte alignment and limited to 1 MiB.

## Frozen Parent Calculation

Use the source gravity reciprocal, ZFACBUO=0.5/(1+0.5) and Z_CWDRAG=((3/8)*0.506)/0.2, with their separately rounded operations. Set private organised entrainment, buoyancy, entrainment and detrainment to positive zero. Set selected PDMFDE, PMFDDE_RATE and PKINED cells at every level to positive zero.

For JK from 3 through KLEV, copy the pressure row and set a column mask from LDDRAF and previous PMFD<0. Skip the entire row when no columns are enabled. For enabled columns, set EN=DE=((ENTRDD*MFprevious)*(GEOHprevious-GEOHcurrent))*ZRG.

If JK>NJKT3, set EN=0 and DE=(PMFD_at_NJKT3*(Pcurrent-Pprevious))/(Pbottom-P_at_NJKT3). Otherwise form ZDZ=-(GEOHprevious-GEOHcurrent)*ZRG and add (OENTR*ZDZ)*MFprevious to EN. Apply the ordered limits max(EN,0.3*MFprevious), max(EN,(-0.75*MFUcurrent)-(MFprevious-DE)) and min(EN,0). In this upper region, write PDMFDE=EN-DE for every selected column, including an inactive column's retained private EN and DE.

For an enabled column, store MFcurrent=(MFprevious+EN)-DE. Mix sensible-energy and water fluxes in the exact source order, using the previous environmental and plume states. Use one rounded reciprocal of min(-RMFCMIN,MFcurrent) for both unchanged uses. Compute Qcurrent from mixed water flux and Tcurrent from mixed energy, current gravitational potential and heat capacity. Limit temperature first to at most 400 K and then to at least 100 K. Save its pre-adjustment humidity.

Call the complete direct CUADJTQ mode 2 on the actual PTD and PQD matrices and current row, with the same mask, pressure values, dimensions and selected columns. Drivers provide no numerical stage. Subtract adjusted humidity from the saved value to obtain COND.

Form virtual-temperature buoyancy in the source order. When rain and upward mass flux are positive, subtract Tcurrent*(rain/MFUcurrent). If buoyancy is nonnegative or rain<=MFcurrent*COND, replace MFcurrent and buoyancy with positive zero. Store sensible-energy and water fluxes, rain transfer=(-MFcurrent)*COND at the previous level, and rain=rain+transfer.

Divide buoyancy by environmental temperature, preserving its uncapped value for kinetic energy. Cap the organised-entrainment value at zero. With ZDZ=-(GEOprevious-GEOcurrent), add capped_buoyancy*ZDZ to the retained buoyancy integral. Set OENTR=((RG*capped_buoyancy)*0.5)/(1+integral). Store PMFDDE_RATE=-DE.

Set DKBUO=(ZDZ*uncapped_buoyancy)*ZFACBUO. Choose EN when EN<0, otherwise DE. Set DKEN=min(1,((1+Z_CWDRAG)*chosen)/min(-RMFCMIN,MFprevious)). Store PKINED=max(0,(KINprevious*(1-DKEN)+DKBUO)/(1+DKEN)). Preserve each product, sum, division, comparison and store dependency.

## Arithmetic, Output and Verification

Direct assembly uses frozen FP64 round-to-nearest with ties to even, gradual underflow and signed zeros. Fused arithmetic, reassociation, approximate operations, reduced precision and fast-math are forbidden. Complete unchanged saturation and scalar EXP routes retain their accepted evidence.

Canonical output is the full PRFL owner, PTD, PQD, PMFD, PMFDS, PMFDQ, PDMFDP, PDMFDE, PMFDDE_RATE and PKINED, in argument order and little-endian storage. Every other owner remains unchanged. Unchanged cells retain their original bits. Acceptance requires independent parent layer budgets, rain transfer, stopping and kinetic-energy relations, zero differing complete bytes, protected bounds, the immediate ABI and unchanged FPCR. Child proofs are reused.

Critical checks pass 78 protected placements, 90 900 independent 100-digit parent physical relations and 2 160 576 complete source/native owner bytes with zero differences. The main 74-case corpus covers complete one, three, six, eight and 137-level descents, upper and lower regions, zero entrainment, inactive histories, rain-supply stopping, empty and cropped ranges, the lower temperature cap and source-unused NaN ghosts. Four focused placements add buoyant stopping and the upper temperature cap. There are 7 368 active layer updates, 42 stopped layers and 40 pre-adjustment caps. All read-only owners, the 24-address immediate ABI and FPCR pass. Complete unchanged child proofs are reused.

The paired smoke passes twenty-two genuine calls, 77 088 complete output bytes and 2 064 live parent budget relations with zero differences. It includes 376 active layers and sixteen stopped layers, with twelve sampled temperature caps. The full parent state owners are compared on every call. Physical admissibility is checked at consumed plume layers, while source-unused top and saturation ghosts retain all bits. New parent instruction and affected-document checks pass.

## Positive Optimisation Lesson

Retain only the six required column histories and one logical mask across the ordered descent, caching source constants in the fixed frame. Bind the complete accepted adjustment child to the actual parent state. Reuse each already-rounded scalar reciprocal where the source repeats the identical operands, while preserving distinct source products, comparisons and output stores.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 observed 2,150 genuine calls. The same-input comparison covers 71,001,600 complete returned owner bytes with zero differences. Independent critical physics, unchanged inputs and the declared interface checks passed. All ten saved forecast files also match across 618,140 bytes. This result covers the declared routine domain and saved files. Independent whole-forecast physics, whole-process byte identity and comparative speed remain unproved.
