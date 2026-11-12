# Selected Vertical Spline Operator Matrix

This child implements the selected `SUVFE_MATRIX` computation from `arpifs/setup/suvfe_matrix.F90`. A matrix entry integrates a weight basis function times an input basis function, its first derivative or its integral. These are the mass, derivative and integral-product matrices used to construct the actual 19-level vertical operators. All coordinates, polynomial coefficients and matrix entries are dimensionless.

`int md2asm_spline_operator_matrix(const int32_t controls[6], const double scalars[3], const void *owners[6], double *output, void *workspace, const uint64_t *workspace_bytes)` takes six addresses in x0 through x5 under the Arm procedure call standard. Controls contain kind, integral-from-surface flag, input basis count, input offset, weight basis count and weight offset. Kind is minus one, zero or one; the surface flag is zero. For the retained small shapes, each basis count is 21 through 24, each offset is zero through its basis count minus 21 and matrix dimension is 21. The new operational shapes have matrix dimension 139 and exactly the seven control tuples below. Spline order is four for both routes. Scalars contain exact positive zero for the source minimum interval, followed by sample bounds positive zero and one. These supported source choices are passed explicitly; second derivatives, integral-from-surface mode and nonzero minimum interval require separate qualification and are rejected.

The new control tuples are written as kind, surface flag, input basis, input offset, weight basis and weight offset. Other larger tuples remain unsupported.

| Kind | Surface | Input basis | Input offset | Weight basis | Weight offset |
| --- | --- | --- | --- | --- | --- |
| 0 | 0 | 139 | 0 | 139 | 0 |
| 0 | 0 | 140 | 0 | 140 | 0 |
| 0 | 0 | 140 | 1 | 140 | 1 |
| -1 | 0 | 139 | 0 | 140 | 1 |
| 1 | 0 | 139 | 0 | 139 | 0 |
| 1 | 0 | 139 | 0 | 140 | 0 |
| 1 | 0 | 139 | 0 | 140 | 1 |

Owners is a read-only array of six addresses: input transform, weight transform, input knots, weight knots, input pieces and weight pieces. Each transform has 16 FP64 words from the qualified sampling-transform child. Each knot owner has basis_count plus four FP64 words and must be admissible for the checked basis and piece constructors. Each piece owner has basis_count times 16 FP64 words in the source column-major basis/segment/coefficient order. The input and weight offsets select `dimension` consecutive basis functions. All consumed values and intermediates are finite. Output has `dimension*dimension` FP64 words: 441 for the small shapes or 19321 words (154568 bytes) for the operational shapes. It uses column-major order, with weight index varying fastest and input index next.

Every input, output and workspace buffer is caller-owned and mapped for the declared extent. The integer control address is aligned to four bytes; the remaining addresses, each nested owner address and capacity address are aligned to eight bytes. Inputs, output and workspace are disjoint. Workspace capacity is at least 23648 bytes for the small shapes or 656544 bytes for the operational shapes. Valid numerical owner provenance, complete extents, finite intermediate arithmetic and disjointness are caller preconditions. No OpenIFS module variable, class record, descriptor, vtable or original callable is required.

| Workspace byte offset | Reserved bytes | Use |
| --- | --- | --- |
| 0 | 1760 | Up to 55 complete knot-interval records. |
| 1760 | 10752 | Input cumulative integrals, basis count by total knot count. |
| 12512 | 10752 | Weight cumulative integrals, basis count by total knot count. |
| 23264 | 192 | Input interval contributions, one per input basis. |
| 23456 | 192 | Weight interval contributions, one per weight basis. |

The preceding table describes the retained small workspace. The new route reserves the following complete regions. The maximum basis count is 140 and the maximum total knot count is 288, so each cumulative table needs `140*288*8=322560` bytes.

| Operational workspace offset | Reserved bytes | Use |
| --- | --- | --- |
| 0 | 9184 | Up to 287 complete knot-interval records. |
| 9184 | 322560 | Input cumulative integrals. |
| 331744 | 322560 | Weight cumulative integrals. |
| 654304 | 1120 | Input contributions for up to 140 basis functions. |
| 655424 | 1120 | Weight contributions for up to 140 basis functions. |

Only the required prefix of each reserved region is written; padding retains its incoming bytes. The two cumulative regions and the two contribution regions are used only for kind minus one. The cumulative arrays have the source basis-fast column-major order and total knot count equal to input basis count plus weight basis count plus eight. They and all per-interval contribution words are initialised by the direct calculation before any numerical read. No workspace preimage supplies a missing numerical stage.

Return zero writes every matrix entry. Return two rejects unsupported controls, capacity, addresses, alignment or invalid knot metadata before output or workspace mutation. Return three reports a numerical-child rejection after computation starts; output and workspace can then contain completed stages and must be discarded. The qualified input domain has no child rejection. The child allocates no heap owner, so its caller retains ownership and cleanup of output and workspace on every return.

The knot-interval utility supplies complete active coordinates, rounded interval widths and cumulative knot indices. Their sum identifies each original source interval index. The matrix child still iterates every original knot position. For an integral operator, it clears interval contributions and performs each cumulative addition even at repeated or skipped positions, preserving source zero additions and signed-zero rules. Equal-coordinate label permutations remain unused. The original sort's fractional pivot conversion is omitted by the interval utility; its fresh-status difference remains recorded separately. This complete matrix comparison, including fresh FPSR zero, is therefore a required status boundary rather than a standalone `DSORT` equivalence claim.

For kind minus one, first integrate each input piece over every common interval and store the source cumulative table. In the main pass, convert each original knot interval to local lower and upper coordinates using the accepted `FX2T` child. Preserve the source coordinate differences and interval spans. Visit weight bases, then input bases, in increasing source index order. Copy each strided four-coefficient piece to private contiguous storage and apply the qualified local polynomial conversion. The interval-contribution child supplies the source-ordered product/integral term. Add it to the matrix entry, then separately multiply and add the earlier cumulative input term when required. After each weight basis, also add the source contributions from earlier input functions. Finally update every weight cumulative integral at that source knot position.

All ordinary products, additions, subtractions and divisions round separately. The complete graph uses only the qualified interval, local-polynomial, coordinate and polynomial assembly children. No fused instruction, external numerical library, recorded matrix input or precomputed inverse is consumed. Profiling and inactive source printouts are omitted diagnostics. Required sample arithmetic establishes the same inexact flag naturally at the complete matrix return; no status bit or output word is forced afterward.

The child owns a 544-byte frame aligned to 16 bytes. Its maximum nested frame is 896 bytes, including the interval-contribution child. Private integer-copy and loop helpers use this existing frame. It preserves x18, x19 through x29, the low 64 bits of d8 through d15, FPCR and errno. FPCR is zero with nearest/ties-to-even and gradual underflow. Incoming FPSR bits remain set, and the source arithmetic adds the same numerical flags.

Thirty-two genuine original `SUVFE_MATRIX` comparisons cover all three kinds, both incoming FPSR zero and 24, basis/offset bounds, equal and distinct input/weight knots, top and bottom value conditions and actual source operator combinations. All 112896 complete matrix bytes, complete input owners, output/workspace guards, unused workspace padding and immediate FPCR/FPSR/errno agree in 64 ABI observations. Seven rejected inputs preserve the complete output and workspace preimages. Independent 80-digit four-point Gaussian integration checks all 7056 entries of the 16 distinct matrix cases. That rule integrates the degree-seven local products exactly in exact arithmetic; the largest observed entry error is 6.115e-15. This matrix boundary closes the recorded sort-status difference for the checked cases. The enclosing complete vertical operator, source/ABI peer and autonomous forecast integration remain pending, with no new original-body credit.

The operational child qualification uses seven distinct actual source matrices under FPSR seeds zero and 24, giving 14 complete cases. It reuses the accepted original knot, polynomial-piece, boundary and transform records. All 2163952 matrix bytes match the original. The 539728 read-only owner and control bytes are preserved. All 16 native ABI and status checks pass, including two focused refusals. Native workspace padding retains 7818816 byte observations of its own incoming preimages. The unchanged 80-digit integration rule passes all 135247 distinct matrix entries within its retained rounding allowance. Every original sort stage is retained in the separate reference records. Complete matrix status agrees naturally; no flag is forced, no reference scratch is imported and no standalone merge/DSORT equivalence is claimed. The original 544-byte frame and 896-byte maximum nested stack remain unchanged. Existing small-shape and arithmetic evidence is reused by exact route correspondence. This complete child does not admit a selected operator, parent, startup or forecast.
