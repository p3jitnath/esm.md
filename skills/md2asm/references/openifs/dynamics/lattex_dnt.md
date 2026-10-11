# LATTEX_DNT Solver Contract

[Physics input](../../../../../formulations/openifs/dynamics/two_level_transport_terms.md), revision 1. This contract covers the complete arithmetic body in `arpifs/adiab/lattex_dnt.F90`. It reuses accepted GEOMETRY, TDYN and TDYNA storage and the rigorous rounding-error enclosure from VDFDIFM.

## Complete Update

Use ordered FP64 arithmetic, nearest rounding with ties to even, gradual underflow, signed zeros and FPCR zero. Each multiplication, addition and subtraction rounds separately. Copies preserve all bits. Forbid FMA, contraction, reassociation, approximate operations, reduced precision and fast-math. The direct assembly supplies every numerical stage.

Write `z=RN(1+XIDT)` and `R=RN(PMOY1X+RN(z*PXSI))`. The corrector is selected by `LPC_FULL AND NCURRENT_ITER>0`. An optional `LDNESC` overrides `LNESC` when present. The early branch is `NSTEP<=NFOST OR NESC`. Preserve the complete source branch order.

In the predictor with `KXLAG=2`, split interpolation adds PXT0 to PXL9 and the outgoing nonlinear change to PXLF9. Without splitting, add both contributions to PXL9 in their original order. The early outgoing change is `PESGM*PMOY1X`. Stable extrapolation mixes the non-extrapolated and extrapolated terms, preserving `old + w*extrapolated + (1-w)*base` as separately rounded left-to-right additions. Include PXT0 in the base only without splitting. The centred branch adds `(0.5*PESGM)*(R-PXNLT9)` after the early terms.

For predictor `KXLAG>=3`, update PXL0 with the outgoing change and PXL9 with PXT0. Stable extrapolation adds `w*(R-PXNLT9)` after the nonlinear term. With LPC_CHEAP, put that extrapolated term in PXLF0 instead. The early and stable final-point increments are `PESGP*R`. The centred increment is `PESGP*(1.5*R-0.5*PXNLT9)`. For other KXLAG values, omit these transport increments while retaining the remaining source stages.

The full predictor copies PMOY1X to PCXNLT9. When NESC is false, save R to PXNLT9 after its earlier uses. In the full corrector, add the earlier state PXT9 and `PESGM*PCXNLT9` to the corresponding outgoing arrays unless LPC_CHEAP is true. Add `PESGP*R` to PXT1 for KXLAG two or greater.

Then set `h=z` when XIDT is positive and `h=PESGP` otherwise. Subtract `h*old_PXSI` from PXT1 and replace PXSI by that same separately rounded product. Reuse it only after preserving its exact bits.

The diagnostic branch runs after that replacement. Let `Q=z*new_PXSI`. Predictor KXLAG three or greater adds `(PESGP*z)*new_PXSI` to PSIDDHXT1 in the early and stable branches. Stable extrapolation also adds `Q-old_PSIDDHXT9` to PSIDDHXL0. The centred branch adds `(0.5*PESGM)*(Q-old_PSIDDHXT9)` to PSIDDHXL0 and `PESGP*((1.5*z)*new_PXSI-0.5*old_PSIDDHXT9)` to PSIDDHXT1. Save Q to PSIDDHXT9 when predictor NESC is false. A corrector adds the first diagnostic increment only for KXLAG three or greater. Keep every displayed parenthesis and original multiplication order.

## Storage and ABI

There are twenty-seven ordinary addresses, with no descriptor or hidden length. In order they are `YDGEOMETRY, YDLDDH, YDRIP, YDDYN, YDDYNA, KST, KPROF, LDSETTLS, KXLAG, PESGP, PESGM, PXT0, PXT9, PMOY1X, PMIXNL, PXSI, PXNLT9, PXT1, PXL0, PXL9, PXLF9, PCXNLT9, PSIDDHXT1, PSIDDHXT9, PSIDDHXL0, PXLF0, LDNESC`. The first eight arrive in x0 through x7. Nineteen more use eight-byte entry-stack slots. The default symbol is `lattex_dnt_`.

Let K be NPROMA, N be NFLEVG, and S/E be the inclusive NFLSA/NFLEN transport bounds. Use K zero through 4,096, N zero through 1,024, S zero or one, and E from N through N+1. Each main level field has `8*K*N` bytes. PXL0, PXL9, PXLF9, PSIDDHXL0 and PXLF0 have `8*K*max(0,E-S+1)` bytes. Access physical level one at padded offset `8*K*(1-S)`. Preserve all extra transport levels. Columns vary fastest, then levels, with little-endian output bytes.

The inclusive range has `1<=KST<=K+1` and `0<=KPROF<=K`. Empty work leaves complete outputs unchanged. Scalars and logicals have four-byte alignment, and reals have eight-byte alignment. Canonical logical words are zero or one. An unused ordinary array or optional flag may be absent. A consumed or written array must be present. Arrays used by a branch are finite. Present unused storage may contain arbitrary opaque bits.

Outputs are the eleven views PXSI through PXLF0. Compare every complete declared returned view, including inactive cells and padding. Preserve any aliases among unused views in comparison clones. Written views are disjoint from each other and consumed inputs. The interface supplies no capacity for their enclosing caller buffers, so storage outside the declared returned views is outside this routine's capture boundary.

Reuse the accepted object storage and measure only newly consumed members. An offset is the number of bytes from the object's start.

| Object | Complete bytes | Members and byte offsets |
| --- | --- | --- |
| GEOMETRY | 17,096 | NPROMA 5,144, NFLEVG 5,224, NFLSA 5,244, NFLEN 5,248. |
| TDYN | 4,720 | NCURRENT_ITER 2,580, NSPLTHOI 4,204, XIDT 4,328. |
| TDYNA | 456 | LNESC 280, LPC_FULL 336, LPC_CHEAP 340. |
| TLDDH | 120 | LRSIDDH 108. |
| TRIP | 175,976 | NFOST 24. |

Preserve every complete metadata owner and the read-only `__yomct3_MOD_nstep` global. Original SUDIM uses no extra transport level for its two-dimensional case and one extra level at each end otherwise. The padded-owner checks cover both layouts.

Preserve x19 through x29, x18, the link register and the required low halves of v8 through v15. Keep a sixteen-byte aligned stack. All arithmetic and field selection stay inside the direct assembly body. No numerical helper, compiler assembly or omitted setup stage is permitted.

## Critical Acceptance

Use finite XIDT between minus one and one, PESGP/PESGM between zero and two with their sum equal to two within input-rounding error, nonnegative step/iteration counts and valid method flags. Consumed mixing weights lie between zero and one. Check independent exact rational affine transport and diagnostic balances using the accepted outward rounding-error enclosure. Include each predictor/corrector branch, split signs, stable mixing endpoints, both optional overrides, transport padding, partial/empty work, zero dimensions, 4,096 columns, 1,024 levels, signed zeros, subnormals, a noncontraction case and unused absent or NaN fields.

Before generation, the genuine original must pass the independent balances and complete returned-byte checks. Then use the same accepted corpus with protected bounds and preserved-register probes. Require zero differing bytes, unchanged complete inputs and metadata, and FPCR zero. Return direct assembly bytes in the paired actual-call relay and include it in a combined forecast before claiming forecast acceptance. No comparative timing is claimed.

Original physics passed 152 cases, 562,680 complete returned union bytes and 46,590 independent affine balances. Native verification passed 304 protected calls, 1,125,360 bytes and 93,180 balances, including 72 nonzero subnormal outputs. The paired smoke passed 152 calls and 562,680 bytes. Every required byte agreed, complete inputs remained unchanged, the ABI was preserved and FPCR was zero. The focused unused-alias case reused the 151-case base proof without changing assembly. No comparative timing is claimed.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 passes these positive actual calls with zero differing bytes. Each byte scope describes the complete owners compared by that routine.

| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| lattex_dnt | 6,450 | 169,660,800 | Complete routine owners |

All ten saved files also match across 618,140 bytes. The accepted critical physics and interface checks are reused. These checks cover the declared routine domains and saved files. Whole-forecast physical verification, whole-process byte identity and comparative timing remain open in the [coverage record](../../../../../src/openifs/README.md).
