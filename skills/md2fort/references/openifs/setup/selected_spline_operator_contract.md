# Selected vertical spline operator

This raw composition constructs one vertical integral or derivative operator from its dimensionless eta coordinates. FP64 means the IEEE binary64 format, with 53 significant binary digits. It follows the consumed `SUVERTFEB` stages for the actual 19-level and 137-level hydrostatic, new-spline configurations. The five admitted operator families are `RINTBF11`, `RDERBF00`, `RDERBF01`, `RDERBF10` and `RDERBF11`. It constructs all numerical intermediates through qualified direct assembly children; it consumes no saved matrix, inverse, OpenIFS record, module constant, type descriptor, vtable or original numerical callable.

The application binary interface is `int md2asm_selected_spline_operator(const int32_t control[6], const double *eta_in, const double *eta_out, double *output, void *workspace, const uint64_t *workspace_bytes)`. Pointers enter in x0 through x5. An `int32_t` is a four-byte signed integer; `uint64_t` is an eight-byte unsigned integer. The six controls are operator kind, output rows, top output value condition, bottom output value condition, first input derivative flag and last input derivative flag. The 19-level tuples are `[-1,20,1,0,1,1]`, `[1,19,0,0,0,0]`, `[1,19,0,1,0,1]`, `[1,19,1,0,1,0]` and `[1,19,0,0,1,1]`. Input basis count and matrix dimension are 21 for that route. The 137-level route uses dimension 139 and tuples `[-1,138,1,0,1,1]`, `[1,137,0,0,0,0]`, `[1,137,0,1,0,1]`, `[1,137,1,0,1,0]` and `[1,137,0,0,1,1]`. Output and weight basis counts are the matrix dimension plus the two output value conditions; their basis offset is the top value condition. Spline order is four, approximation and integral-from-surface flags are false, and the minimum interval is positive zero.

Eta input is the qualified actual eta construction with positive zero and one as its material endpoints. Its 21 or 139 finite values are strictly increasing. Eta output has the declared number of stored input values, beginning at input index one when counting from zero. The child checks these shape, order and subset rules. Membership in the actual eta and selected inverse domain remains a caller precondition; other physical grids require separate qualification. All arithmetic intermediates are finite. Output has `(output_rows,matrix_dimension)` FP64 values in column-major order, with its row index changing fastest.

Integer control has four-byte alignment. All real, workspace and capacity addresses have eight-byte alignment and their complete declared mapped extents. Buffers are disjoint. The caller owns every buffer, including at least 61,856 workspace bytes for dimension 21 or 1,954,048 bytes for dimension 139. The parent owns no heap allocation. The large-product children temporarily allocate their square results, copy each complete result, and release it before the next call; the final rectangular result remains caller-owned. Return zero writes every output word. Return two rejects metadata before output or workspace mutation. Return three reports a numerical child failure after work begins; workspace and any partially returned output must then be discarded. The admitted input domain has no numerical-child failure.

The 21-column workspace has the following layout.

| Workspace byte offset | Reserved bytes | Numerical owner |
| --- | --- | --- |
| 0, 128, 256 | 128 each | Three sampling transforms. |
| 384, 592, 800 | 208 each | Input, output and weight knots. |
| 1008, 3824, 6640 | 2816 each | Input, output and weight spline pieces. |
| 9456, 9632, 9808 | 176 each | Input, output and weight centre coordinates. |
| 9984 | 3528 | Mass matrix. |
| 13512 | 3528 | Stiffness matrix. |
| 17040 | 3528 | Input evaluation matrix. |
| 20568 | 3528 | Output evaluation matrix; only its required rows are used. |
| 24096 | 3528 | Inverse mass matrix. |
| 27624 | 3528 | Inverse input evaluation matrix. |
| 31152, 34680 | 3528 each | First and second composed products. |
| 38208 | 23648 | Reused operator-matrix scratch. |

The 139-column workspace uses the following complete layout. Each of the three role groups is ordered input, output and weight. Their maximum basis count is 140.

| Workspace byte offset | Reserved bytes | Numerical owner |
| --- | --- | --- |
| 0, 128, 256 | 128 each | Sampling transforms. |
| 384, 1536, 2688 | 1152 each | Knots. |
| 3840, 21760, 39680 | 17920 each | Spline pieces. |
| 57600, 58720, 59840 | 1120 each | Centre coordinates. |
| 60960 | 154568 | Mass matrix. |
| 215528 | 154568 | Stiffness matrix. |
| 370096 | 154568 | Input evaluation matrix. |
| 524664 | 154568 | Output evaluation matrix; only its declared rows are active. |
| 679232 | 154568 | Inverse mass matrix. |
| 833800 | 154568 | Inverse input evaluation matrix. |
| 988368, 1142936 | 154568 each | First and second products. |
| 1297504 | 656544 | Reused operator-matrix scratch. |

Each owner has its required prefix written before any numerical read. Bytes that no entered stage writes retain their incoming values and do not supply a calculation. Reused scratch can retain earlier stage contents outside the next stage's active prefix. Three sampling transforms, three knot vectors and three spline coefficient owners are constructed in source stage order. Apply the input, output and weight value boundary conditions next. Build the mass and stiffness matrices, then the input and output evaluation matrices. Invert the mass and input evaluation matrices through the qualified selected inverse utility at dimension 21 or the public-library inverse utility at dimension 139. Multiply stiffness by inverse input evaluation, inverse mass by that product, then output evaluation by that product. Each ordinary FP64 operation and reduction retains its source order and separate rounding. At dimension 21, the inverse's consumed BLAS update sites use the qualified integer one-round helper. The large route calls the same public LibSci inverse and GNU Fortran matrix-product services as the compiled original; their algorithms and controls remain unchanged. Direct assembly introduces no fused operation.

The 21-column selected inverse utility omits DGECON's unused private diagnostic and abort-only condition estimate under its exact matrix-domain bound; no condition-estimator result is supplied or claimed. The knot-interval utility omits unused equal-label sort permutations. Complete parent bytes and immediate returned status are required to qualify these omissions at this boundary. Original printouts, profiling and inactive quality printouts are omitted diagnostics; no consumed forecast calculation is omitted. The 139-column inverse retains `DGETRF`, `DGECON` and `DGETRI`, including the original 556-word work extent and natural service status. This composition does not claim a general `SUVERTFEB` interface or an original `MINV`, `DGECON` or `DSORT` body replacement.

Execution requires FPCR zero: nearest/ties-to-even rounding and gradual underflow. Incoming FPSR sticky bits remain, and source numerical arithmetic can add flags. The child preserves errno, FPCR, x18, x19 through x29 and d8 through d15. The 21-column frame is 512 bytes and its maximum nested stack is 6,848 bytes. The 139-column frame is 1,456 bytes; its two 139-word integer arrays occupy bytes 296–851 and 852–1407, and three boundary pairs occupy 1408–1431. Both frames are aligned to 16 bytes and have paired release on every entered exit. The new maximum direct nested stack is 316,432 bytes, including the 314,976-byte public-inverse wrapper; the public libraries need additional internal storage. The small route retains its accepted `_exit` service and direct arithmetic. The large route additionally uses the qualified public LibSci and GNU Fortran runtime interfaces, plus libc ownership and errno services. No original OpenIFS routine supplies a production stage. Separate source controls, complete intermediate and returned-byte checks, ABI/status checks and independent polynomial integral/derivative relations are required before local readiness. Forecast admission remains separate and no new original-body credit is assigned here.

The 137-level qualification passes all five operators under incoming FPSR zero and 24. All ten complete outputs, totalling 1,525,664 bytes, agree exactly with the separate original control. Twenty actual large inverse calls and thirty matrix products retain their defined intermediates and natural status. All 5,232,784 checked padding bytes preserve their before-images. Twenty temporary square results are copied completely and freed once; ten rectangular results remain caller-owned. All twelve native ABI/status checks pass with zero masks, including two preflight no-write refusals. The original control retains its separately recorded `x18` platform-register exception. The independent methods pass 386,420 inverse relations for the five added inverse inputs, 230,740 exact dot products for the twelve added operand pairs, and 2,332 analytic parent identities, using unchanged allowances. Existing two-inverse and three-product evidence is reused. This admits the bounded raw operator graph, not the upper storage owner, startup or a 137-level forecast; no performance claim is made.
