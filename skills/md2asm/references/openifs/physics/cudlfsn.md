# CUDLFSN Numerical Contract

[CUDLFSN](../../../../../src/openifs/physics/cudlfsn.S) implements revision 1, equations D1–D2, of [Convective Downdraft Initial State](../../../../../formulations/openifs/physics/convective_downdraft_start.md). Its complete normal-physics calculation privately calls the complete [CUADJTQ](cuadjtq.md) mode-2 body and reuses the unchanged child physics and arithmetic proofs.

## Supported Domain and Interface

LPHYLIN is false. KLON and KLEV are positive. The selected column range is empty or lies within KLON. Input temperatures, humidities, pressures and fluxes are finite, used pressure is positive, and admitted humidity and output temperatures remain physically admissible. Logical values are zero or one. LMFDD can be false or true. RMFDEPS is a finite nonnegative downward mass-flux fraction. The tangent-linear TANH branch is outside this contract.

The GNU Fortran AArch64 application binary interface, or ABI, has twenty-eight addresses. The first eight use x0–x7 and the last twenty occupy consecutive eight-byte caller stack slots. Integers and logical values occupy four bytes. Real values use FP64 and eight-byte alignment. Matrices are contiguous and column index changes fastest. Separate declared owners do not alias.

| Argument | Meaning | Owner |
| --- | --- | --- |
| 1–2 | YDEPHLI, YDECUMF | Plain objects, 120 and 344 bytes |
| 3–6 | KIDIA, KFDIA, KLON, KLEV | Four-byte scalars |
| 7–9 | KCBOT, KCTOP, LDCUM | KLON integer or logical vectors |
| 10–14 | PTENH, PQENH, PTEN, PQSEN, PGEO | KLON × KLEV input FP64 |
| 15–16 | PGEOH, PAPH | KLON × (KLEV+1) input FP64 |
| 17–18 | PTU, PQU | KLON × KLEV input FP64 |
| 19–20 | PMFUB, PRFL | KLON input and changed FP64 vectors |
| 21–26 | PTD, PQD, PMFD, PMFDS, PMFDQ, PDMFDP | KLON × KLEV changed FP64 |
| 27–28 | KDTOP, LDDRAF | KLON changed integer or logical vectors |

LPHYLIN is at byte 4 of YDEPHLI. LMFDD is at byte 260 and RMFDEPS at byte 128 of YDECUMF, measured by the existing metadata-only layout route. The body preserves x19–x29, the low 64 bits of v8–v15, stack alignment and FPCR, and does not use x18. It uses a fixed 512-byte frame and an aligned scratch arena of 40*KLON+32 bytes, with the size rounded upward to sixteen-byte alignment and limited to 1 MiB.

## Ordered Calculation

Set selected LDDRAF values to false and KDTOP to KLEV+1. If LMFDD is false, return with all other bytes unchanged. Otherwise initialise private minimum-energy values to 1e8 and private indices to KLEV+1.

For JK from 3 through KLEV-2, compute the convective phase fraction using the unchanged bounded quadratic source route. Compute latent heat as a*RLVTT+(1-a)*RLSTT. Form saturated moist energy in the exact order (RCPD*PTEN+PGEO)+latent*PQSEN. Strictly lower energy replaces the stored minimum and index, so ties keep the first level.

For JK from 3 through KLEV-3, copy PTENH, PQENH and PAPH into one-level private rows. A column is enabled only when LDCUM is true, PRFL is positive, no downdraft was selected, JK is below cloud top and above cloud base in the source index direction, and JK is at or below the minimum-energy index. Preserve the source predicates JK<KCBOT, JK>KCTOP and JK>=IKHSMIN. Skip the child when no columns are enabled.

Call the complete direct CUADJTQ with ICALL=2, the original selected column interval, and private KLEV=KK=1. This storage-only change supplies the same selected row values and leaves every child arithmetic dependency unchanged. No driver supplies wet-bulb adjustment or another numerical stage.

For an enabled column, compute TTEST=0.5*(PTU+TWET), QTEST=0.5*(PQU+QWET), BUO=TTEST*(1+RETV*QTEST)-PTENH*(1+RETV*PQENH), COND=PQENH-QWET and MFTOP=(-RMFDEPS)*PMFUB, with each product and addition rounded separately. Accept only BUO<0 and PRFL>(10*MFTOP)*COND.

An accepted level receives KDTOP=JK, LDDRAF=true, PTD=TTEST, PQD=QTEST and PMFD=MFTOP. Store PMFDS=PMFD*(RCPD*PTD+PGEOH) and PMFDQ=PMFD*PQD. The previous-level rain change is PDMFDP=(-0.5*PMFD)*COND, and PRFL=PRFL+PDMFDP. Preserve this store order and the first accepted level.

## Arithmetic and Output

The solver is emitted directly as AArch64 assembly and built with an assembler and linker. The frozen FP64 route uses round-to-nearest with ties to even, gradual underflow and signed zeros. Fused arithmetic, reassociation, approximate division, reduced precision and fast-math are forbidden. Scalar EXP and the unchanged child phase calculations reuse their accepted routes.

Canonical bytes are the full PRFL owner, then PTD, PQD, PMFD, PMFDS, PMFDQ, PDMFDP, KDTOP and LDDRAF, in argument order and little-endian storage. Unselected and unmodified cells keep their input bytes. Every other owner remains unchanged. Acceptance requires independent moist-energy selection and downdraft mass/heat/water/rain relations, zero differing bytes, protected bounds, immediate saved-register checks and unchanged FPCR.

## Verification State

The native critical verifier passes 76 protected placements, 14 840 independent parent physical relations and 1 456 896 complete source/native owner bytes with zero differences. It covers enabled and disabled downdrafts, cold and warm mixtures, unavailable rain, zero mass fraction, equal-energy ties, a minimum outside the search range, cloud masks, empty and cropped columns, one and 137 levels, all read-only owners, immediate saved registers and FPCR. Seventy-two columns start downdrafts in this corpus. Complete unchanged mode-2 child proofs are reused.

The paired smoke passes twenty genuine calls, 48 000 complete output bytes and 206 live parent physical relations with zero differences. It includes eighteen enabled and two disabled calls, with twenty-six starting columns. The live minimum check permits the declared floating-point error bound around physical energy ties, while raw output comparisons preserve every original selection bit. Actual forecast acceptance still requires genuine forecast calls and saved-file comparison.

## Positive Optimisation Lesson

Use the accepted complete saturation-adjustment child while retaining only one private wet-bulb level at a time. Cache source constants once per parent call, retain the minimum energy per column and reuse the same row arena across the ordered search. This reduces scratch storage while preserving every child input, source comparison and output rounding point.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 observed 2,150 genuine calls. The same-input comparison covers 47,884,800 complete returned owner bytes with zero differences. Independent critical physics, unchanged inputs and the declared interface checks passed. All ten saved forecast files also match across 618,140 bytes. This result covers the declared routine domain and saved files. Independent whole-forecast physics, whole-process byte identity and comparative speed remain unproved.
