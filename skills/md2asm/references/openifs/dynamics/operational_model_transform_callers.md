# Operational Model Transforms

A transform converts weather fields between grid values and spectral coefficients. The inverse operation produces grid values, and the direct operation produces coefficients. These wrappers preserve the selected TRANSINV_MDL and TRANSDIR_MDL calls to the public transform library. Assembly owns the OpenIFS field views, controls, temporary storage and call order.

`md2asm_operational_inverse_model_transform(G,GMV,TGFL,SP,MODEL,partition,modes)` and `md2asm_operational_direct_model_transform(G,GMV,TGFL,SP,MODEL,partition,configuration)` use x0 through x6. Their first six complete records contain 20,400, 1,560, 1,096, 2,992, 4,275,088 and 4,096 bytes. All consumed owners and views remain mapped, aligned to eight bytes, nonwrapping and disjoint except declared read-only component views. Their qualified producers and backing arrays remain live until return.

Inverse modes contain eight 32-bit words in order, NPROMATR, NSTEP, LDUV, LDERR, LDVOR, LDFSCOMP, LDSIDDH and LDHDDDH. The selected route has NPROMATR 0, LDUV false, LDERR true, no callback or diagnostic-tendency route, and LDVOR false or true for its reserved output plane. The caller derives these flags from the original TRANSINVH rules, including optional output eligibility. Public LDUVDER is LDUV AND LDERR. The direct configuration is one mapped character A.

The four-process grid has 137 global layers, 68 or 69 local spectral layers, 819,840 local coefficient words and 1,649,920 local points in 97,055 blocks of 17. The final block has two active points. YT0 has seven volume and three surface fields, with U, V and temperature at indices 3, 4 and 5. YT1 has three volume and one surface field, with temperature at 3. Preserve all remaining previous-time planes and the source descriptor strides.

Inverse copies log-pressure into its 6,558,720-byte temporary only in the owning spectral group. The original no-spectral-tracer branch passes the rank-two shape 1 by NSPEC2 on every process, even when that process has no active scalar. Keep that slice and its live field-set map. Direct passes the YT1 wind, temperature and first surface field to the public transform, then only the owning group copies pressure coefficients back. All four processes enter matching collectives. Release each temporary on every returned path.

Return 0 after success, 1 on temporary allocation failure or 2 before a transform on unsupported controls or interface refusal. Both wrapper frames have 1,024 bytes, aligned to 16. Preserve x18, saved registers, required vector low halves and FPCR. FPCR must be zero. Natural public-library flags and system error values remain observable.

The separate five-argument `md2asm_initialize_operational_rayleigh_controls(text,bytes,G,MODEL,configuration)` supplies the consumed SUDYN friction flags through the accepted bounded parser. For the selected 137-layer route both flags are false. It changes only MODEL logicals at 1566724 and 1566728, preserves all status and has an 80-byte frame. Active friction requires its separate source path and is refused here.

All four maps pass both inverse modes and the direct operation against genuine original callers. Complete output and inactive owners, raw status, ABI, guards and allocation cleanup agree. Existing transform physics checks are reused. Complete model stepping and forecast timing remain unverified.
