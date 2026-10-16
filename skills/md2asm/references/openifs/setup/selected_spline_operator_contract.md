# Selected vertical spline operator

This raw composition constructs one vertical integral or derivative operator from its dimensionless eta coordinates. It follows the consumed SUVERTFEB stages for the actual 19-level hydrostatic, new-spline configuration. The five admitted controls are the source RINTBF11, RDERBF00, RDERBF01, RDERBF10 and RDERBF11 operators. It constructs all numerical intermediates through qualified direct assembly children; it consumes no saved matrix, inverse, OpenIFS record, module constant, type descriptor, vtable or original numerical callable.

The application binary interface is `int md2asm_selected_spline_operator(const int32_t control[6], const double eta_in[21], const double *eta_out, double *output, void *workspace, const uint64_t *workspace_bytes)`. Pointers enter in x0 through x5. Controls are operator kind, output rows, top output value condition, bottom output value condition, first input derivative flag and last input derivative flag. Their supported tuples are `[-1,20,1,0,1,1]`, `[1,19,0,0,0,0]`, `[1,19,0,1,0,1]`, `[1,19,1,0,1,0]` and `[1,19,0,0,1,1]`. Input basis count and matrix dimension are 21. Output and weight basis counts are 21 plus the two output value conditions; their basis offset is the top value condition. Spline order is four, approximation and integral-from-surface flags are false, and the minimum interval is positive zero.

Eta input is the qualified actual 19-level eta construction with positive zero and one as its material endpoints. Its 21 finite values are strictly increasing. Eta output is the following 19 or 20 stored input values, beginning at input index one when counting from zero. The child checks these shape, order and subset rules. Membership in the actual eta and selected inverse domain remains a caller precondition; other physical grids require separate qualification. All arithmetic intermediates are finite. Output has `(output_rows,21)` FP64 values in column-major order, with its row index changing fastest.

Integer control has four-byte alignment. All real, workspace and capacity addresses have eight-byte alignment and their complete declared mapped extents. Buffers are disjoint. The caller owns every buffer, including at least 61856 workspace bytes; the child allocates nothing. Return zero writes every output word. Return two rejects metadata before output or workspace mutation. Return three reports a numerical child failure after work begins; workspace and any partially returned output must then be discarded. The admitted input domain has no numerical-child failure.

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

Each owner has its required prefix written before any numerical read. Reserved padding retains its incoming bytes and does not supply a calculation. Three sampling transforms, three knot vectors and three spline coefficient owners are constructed in source stage order. Apply the input, output and weight value boundary conditions next. Build the mass and stiffness matrices, then the input and output evaluation matrices. Invert the mass and input evaluation matrices through the qualified selected inverse utility. Multiply stiffness by inverse input evaluation, inverse mass by that product, then output evaluation by that product. Each ordinary FP64 operation and reduction retains its source order and separate rounding. Only the inverse's consumed BLAS update sites use the qualified integer one-round helper; no fused floating-point instruction is present.

The selected inverse utility omits DGECON's unused private diagnostic and abort-only condition estimate under its exact matrix-domain bound; no condition-estimator result is supplied or claimed. The knot-interval utility omits unused equal-label sort permutations. Complete parent bytes and immediate returned status are required to qualify these omissions at this boundary. Original printouts, profiling and inactive quality printouts are omitted diagnostics; no consumed forecast calculation is omitted. This composition does not claim a general SUVERTFEB interface or whole MINV, DGECON or DSORT body replacement.

Execution requires FPCR zero: nearest/ties-to-even rounding and gradual underflow. Incoming FPSR sticky bits remain, and source numerical arithmetic can add flags. The child preserves errno, FPCR, x18, x19 through x29 and d8 through d15. Its frame is 512 bytes aligned to 16 bytes. Maximum nested stack use is 6848 bytes including the sampling transform and selected inverse graph. Only the accepted integer arithmetic helper's domain-error `_exit` service is external. All production numerical instructions are direct assembly, with no Fortran or numerical-library dependency. Separate source controls, complete intermediate and returned-byte checks, ABI/status checks and independent polynomial integral/derivative relations are required before local readiness. Forecast admission remains separate and no new original-body credit is assigned here.
