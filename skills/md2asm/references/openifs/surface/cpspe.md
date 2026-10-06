# OpenIFS CPSPE contract

Contract revision 1.0 freezes the numeric body of local OpenIFS 48.1.1 CPSPE. The physical input is [surface-state change](../../../../../formulations/openifs/surface/surface_state.md), revision 1.0. This is one surface update, not a complete weather forecast.

## Method and arithmetic

CPSPE applies a supplied tendency to an existing state. The caller supplies PDT in seconds, which represents the effective interval between the input and output states. Preserve this interval rather than assuming that it equals the forecast's nominal step.

For each active field entry, first round the product to FP64, then round the sum to FP64.

```math
a=\operatorname{RN}_{64}(\mathrm{PDT}\,r_q),
\qquad
q_{\mathrm{new}}=\operatorname{RN}_{64}(q_{\mathrm{old}}+a).
```

RN64 means rounding to the nearest representable 64-bit value, with ties rounded to an even final bit. Preserve subnormal values and signed zeros. Inputs are finite and each required intermediate must be finite. Disable contraction, reassociation and fast-math. Check FPCR before execution. A fused multiply-add has only one rounding point and therefore does not meet this contract.

The installed upstream object contains FMADD instructions. A reference built from the unchanged upstream Fortran source with contraction disabled is required for this contract. Agreement with that strict reference does not establish agreement with the installed fused-arithmetic executable.

## Shapes and active columns

KPROMA is the leading array dimension. KSTART and KPROF are inclusive Fortran column indices. Require KPROMA greater than zero, 1 <= KSTART <= KPROMA, and KSTART - 1 <= KPROF <= KPROMA. KPROF equal to KSTART - 1 selects an empty interval. All layer and extra-field counts are nonnegative. Array sizes and address calculations must fit signed 64-bit arithmetic.

Arrays use Fortran column order, so adjacent horizontal columns occupy adjacent FP64 entries. KLEVS counts soil layers, KLEVSN counts snow layers, KLEVO counts ocean layers, KLEVXP counts levels in each extra field, and KFLDXP and KFLDXP2 count extra fields. Different arrays must not overlap. Tendencies are read-only. States are changed only in active columns. An array with zero trailing extent is not accessed.

| Index | Tendency | State | Trailing shape |
| --- | --- | --- | --- |
| 0 | PTSAE1 | PTSA1 | KLEVS |
| 1 | PTLE1 | PTL1 | None |
| 2 | PWSAE1 | PWSA1 | KLEVS |
| 3 | PISAE1 | PISA1 | KLEVS |
| 4 | PWLE1 | PWL1 | None |
| 5 | PSNSE1 | PSNS1 | KLEVSN |
| 6 | PWSNE1 | PWSN1 | KLEVSN |
| 7 | PASNE1 | PASN1 | KLEVSN |
| 8 | PRSNE1 | PRSN1 | KLEVSN |
| 9 | PTSNE1 | PTSN1 | KLEVSN |
| 10 | PTLICEE1 | PTLIC1 | None |
| 11 | PTLMNWE1 | PTLMN1 | None |
| 12 | PTLWMLE1 | PTLML1 | None |
| 13 | PTLBOTE1 | PTLBT1 | None |
| 14 | PTLSFE1 | PTLSF1 | None |
| 15 | PHLICEE1 | PHLIC1 | None |
| 16 | PHLMLE1 | PHLM1 | None |
| 17 | PEXTRE1 | PEXTRP1 | KLEVXP, KFLDXP |
| 18 | PXTR2E1 | PXTRP21 | KFLDXP2 |
| 19 | PUOE1 | PUO1 | KLEVO |
| 20 | PVOE1 | PVO1 | KLEVO |
| 21 | PTOE1 | PTO1 | KLEVO |
| 22 | PSOE1 | PSO1 | KLEVO |

The numeric update is independent between fields and columns under the non-overlap requirement. Field traversal may change while preserving both rounding points for every entry. This routine does not impose positive-state limits or conserve an unspecified field total. Physical checks must instead verify the supplied tendency balance and constant-state cases.

## AArch64 interface

Export cpspe_ with the upstream GNU Fortran explicit-shape interface. All 56 arguments are passed by address. Arguments 1 through 9 are signed 32-bit integers in the order KPROMA, KSTART, KPROF, KLEVS, KLEVXP, KLEVO, KLEVSN, KFLDXP and KFLDXP2. Argument 10 is the FP64 PDT. Arguments 11 through 33 are the tendency pointers in table order, and arguments 34 through 56 are the matching state pointers.

The first eight addresses arrive in x0 through x7. At the entry stack pointer, KFLDXP2 is at byte offset 0, PDT at 8, the first tendency at 16, and the first state at 200. Stack pointer alignment is 16 bytes, and arrays require at least 8-byte alignment. Preserve x19 through x29, the link register, the stack pointer and the required portions of v8 through v15. Do not use the platform register x18. The leaf assembly may use scalar FP64 and two-lane NEON instructions, with a scalar remainder that never crosses the active interval.

Profiling hooks are excluded from numerical state and are not supplied by the solver. The routine emits every surface numeric update itself. A caller may supply or record tendencies but must not apply a missing update.

## Verification and output

Use the unchanged upstream Fortran numeric source as the strict reference. Compare all state and tendency bytes after every tested call, including inactive columns, zero-sized fields and buffer guards. Include single columns, odd widths, partial active intervals, empty intervals, zero layer counts, realistic soil and snow counts, signed zeros, subnormal values and a case that distinguishes fused from separate arithmetic. Place single-entry states and tendencies at the end of a readable memory page, with access to the next page disabled, so that a vector tail cannot touch an extra entry.

Check constant-tendency trajectories against the stated balance and use exact powers of two for independently calculable physical examples. Do not require positivity when a prescribed tendency legitimately removes a quantity. The acceptance limit is zero differing bytes. Report the first stage, step, field, cell and both 64-bit patterns on failure.

Canonical state output is the concatenation of the 23 state arrays in table order, each in Fortran cell order as little-endian FP64, including inactive entries. No metadata or timing bytes enter this stream. A kernel verification record cannot establish whole-forecast agreement. The forecast also needs captured stage states, checkpoint files, final files and independent physical checks.

## Forecast capture

The forecast verifier calls the strict-source Fortran routine on copies of the 23 incoming states, then calls the complete assembly routine on the forecast states. It compares every resulting state byte and checks unchanged tendencies, active finite inputs and outputs, alignment, sizes and non-overlapping buffers. It adds no surface update.

Each call in the forecast output stream starts with an 8-byte call number, 4-byte forecast step, nine 4-byte dimensions in interface order and the FP64 PDT. This 56-byte little-endian header is followed by the 23 complete state arrays in table order, including inactive entries. The separate input stream uses the same header, then appends the incoming state and tendency for each field in table order. Pointer addresses, timing and profiling data are excluded.

## Provenance and measurement

Emit assembly directly from this contract and build it with an assembler and linker. Compiler output may be inspected for instruction verification but must not be used to construct the solver. Archive hashes of the local upstream source, contract, generated assembly, strict reference object, input records and verifier reports. Keep builds and checks on the own quiet exclusive Slurm node. No performance result or reusable optimisation lesson is accepted until repeated complete-update measurements pass the quietness and exact-output checks.
