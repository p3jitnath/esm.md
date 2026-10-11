# LASURE Solver Contract

[Physics input](../../../../../formulations/openifs/dynamics/time_map_factors.md), revision 1. This contract covers the complete ordinary `LASURE` body, including all three map branches and the refined Coriolis flag. The original source is `arpifs/adiab/lasure.F90`.

## Ordered Update

Use round-to-nearest FP64 with ties to even, gradual underflow, signed zeros and FPCR zero. A multiply and a divide round separately. Reuse the accepted ordinary hardware arithmetic route. Disable profiling hooks and retain no numerical language helper.

First compute `PDTS2 = 0.5 * PDT`, then `PBT = PDTS2 * PBETADT`. `PDT`, `PDTS2`, `PBT` and `PBDT` have units of seconds. The other numerical quantities are dimensionless.

When `LSIDG` is true, each active column receives `PBDT = PBT` and `PREDIV = 1`. This branch takes precedence over `LESIDG`. Otherwise, when `LESIDG` is true, separately compute `GM * GM`, `PBT * GMAPPA`, its division by the square, and `GMAPPA` divided by the square. Otherwise, compute `(PBT * RSTRET) * RSTRET` before division by `GM * GM`, and separately compute `RSTRET * RSTRET` before its division. Reusing invariant rounded products preserves these rounding points.

Compute `PESGP = 1 + VESL` and `PESGM = 1 - VESL`. Compute `LD2TLFF1 = L2TLFF AND (LMPHYS OR LEPHYS) AND NOT LAGPHY`. Logical storage is a four-byte integer with false zero and true one.

## Storage and Interface

All seventeen arguments are ordinary addresses. In order they are `YDGEOMETRY, YDEPHY, YDDYN, YDEDYN, YDPHY, KSTART, KPROF, PBETADT, PDT, KIBL, PDTS2, PBT, LD2TLFF1, PBDT, PREDIV, PESGP, PESGM`. The first eight addresses use `x0` to `x7`. The remaining nine use the entry stack in eight-byte slots. The public default entry is `lasure_`, with a unique native symbol used in the paired local build.

The geometry object is 17,096 bytes and its column count is at byte 5,144. Its stretch is at byte 7,512. Its rank-one block descriptor starts at byte 8,472 and selects `KIBL`. Each grid block is 1,472 bytes. The `GM` and `GMAPPA` rank-one descriptors start at bytes 704 and 768 in that block. Use the accepted GNU descriptor representation, with the base, element offset, element size, type, span, stride, lower bound and upper bound in eight-byte words. Resolve an element with `base + span * (offset + stride * index)`. Preserve valid positive or negative block strides, including nonunit block strides. The original map pointers are declared CONTIGUOUS, so each present map has unit element stride and span eight.

Reuse the accepted geometry, TDYN and TEPHY object sizes. The focused metadata probe adds only the fields used here. TDYN is 4,720 bytes with `L2TLFF` at 4,448, `LSIDG` at 2,476 and `VESL` at 4,320. TEDYN is 1,088 bytes with `LESIDG` at 1,056. TEPHY is 448 bytes with `LAGPHY` at 64 and `LEPHYS` at zero. TPHY is 1,096 bytes with `LMPHYS` at 12. Retain the complete object and selected block bytes unchanged. Unused maps may be absent and unused stored numerical bits are not interpreted.

The integer scalars use four aligned bytes and the real scalars use eight aligned bytes. Let `K` be the geometry's column capacity, with `0 <= K <= 4096`. The work range obeys `1 <= KSTART <= K+1` and `0 <= KPROF <= K`, including empty work. Each output array owns all `8*K` bytes, with column one first. All seven output owners are disjoint from each other, every input owner and every context owner. Preserve the complete array bytes outside active columns. Inputs and outputs are little-endian.

The selected block must be within a valid rank-one derived-type descriptor. A consumed map must cover every active column. Complete contiguous map backing owners are bounded by the descriptor's first and last element addresses. Descriptors, context objects, scalar arguments and selected maps remain read-only. Keep every callee-preserved general register and the lower 64 bits of `v8` to `v15` unchanged, with a sixteen-byte aligned stack.

## Physical Domain and Acceptance

Use finite `PDT >= 0`, `PBETADT >= 0` and `-1 <= VESL <= 1`. Every consumed map input is positive and finite. The map square must be positive and finite, and every produced numerical intermediate and output must be finite. This supports signed zero timesteps and nonzero subnormal results while rejecting invalid numerical overflow. The implicit branch does not consume maps. The extended branch consumes `GM` and `GMAPPA`, and the stretch branch consumes `GM` and `RSTRET`.

Before generation, verify the genuine original's half-timestep relation, the exact rational physical map relations within the actual rounding-error enclosure, nonnegative factors, the off-centering sum and range, and every flag combination. Reuse the accepted rigorous rounding-budget helpers for unchanged arithmetic. Check all three branches, the implicit branch's precedence, partial and empty ranges, one and 4,096 columns, signed zeros, subnormal outputs, absent unused maps, unused NaN payloads and reversed or nonunit block descriptors.

After generation, run that same critical corpus with protected bounds and preserved-register probes. Require zero differing complete output bytes, unchanged complete inputs and contexts, and FPCR zero. A composable relay runs the genuine original on complete output clones and the direct assembly on the real outputs, compares every returned byte and records the first mismatch. Root adds the relay to one combined forecast gate. A passed critical corpus alone does not establish live forecast acceptance.

## Current Evidence

On owned job 7240564, node nid010555, CPU 64, the genuine original passed 55 cases and 201,180 complete output bytes with 49,967 independent physical relations and nine nonzero subnormal outputs. The direct assembly passed 110 protected calls and 402,360 bytes with 99,934 relations and eighteen nonzero subnormal outputs. All returned bytes agreed, complete inputs and geometry owners stayed unchanged, every preserved register passed, and FPCR stayed zero.

The direct body has no stack frame or helper call. It reuses invariant rounded products, processes two independent FP64 columns with NEON instructions, and handles an odd final column separately. The paired relay passed the same 55 cases and 201,180 returned bytes, with 1,707,564 unchanged metadata bytes and zero differences. It returns the native bytes after checking the genuine original on complete clones. No comparative timing or speedup is claimed.

Local source, metadata, critical verifier, instruction record, paired relay, literal build commands and small artifact identities are retained under `.runtime/openifs/lasure_source_7240564/`. The final frozen contract requires contiguous maps because the original pointers have that declaration. The first unsupported map-stride fixture is retained locally and was corrected before assembly generation.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 passes these positive actual calls with zero differing bytes. Each byte scope describes the complete owners compared by that routine.

| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| lasure | 2,150 | 903,000 | Complete routine owners |

All ten saved files also match across 618,140 bytes. The accepted critical physics and interface checks are reused. These checks cover the declared routine domains and saved files. Whole-forecast physical verification, whole-process byte identity and comparative timing remain open in the [coverage record](../../../../../src/openifs/README.md).
