# OpenIFS GPHPRE contract

Contract revision 1.2 freezes the complete GPHPRE body in OpenIFS 48.1.1. Its physical input is [hybrid pressure](../../../../../formulations/openifs/dynamics/hybrid_pressure.md), revision 1.0. A half level is a layer boundary. A full level is a pressure chosen within a layer. This stage updates upper boundary pressures, optional pressure coefficients and optional full pressures without advancing time.

## Inputs and top selection

NPROMA is the allocated column count, KFLEV is the layer count, and KSTART through KPROF select active columns. PRESH has shape (NPROMA,0:KFLEV). Its bottom row supplies positive surface pressure and stays unchanged. Compute each upper pressure as $`p_h=\mathrm{RN}(A_h+\mathrm{RN}(B_hp_s))`$. RN rounds an operation to FP64, the 64-bit floating-point format, using nearest rounding with ties to an even final bit.

If PXYB or PRESF is present, first calculate all active top pressures with the same operations. Set IFIRST=2 for the whole group if any top is at or below TOPPRES, including equality. Otherwise set IFIRST=1. TOPPRES is a positive pressure read from the frozen module state, with standard forecast value 0.1 Pa. Only active columns enter the decision.

Let $`p_u,p_l`$ be the rounded upper and lower pressures, $`\Delta B=B_l-B_u`$ the dimensionless depth coefficient, and $`C=A_lB_u-A_uB_l`$ a pressure coefficient in pascals. VDELB and VC supply the reviewed depth coefficient and C. Their setup stays upstream. Start the complete PXYB scratch array at positive zero, including inactive columns and unused fields.

| Field | Symbol | Units |
| --- | --- | --- |
| M_DELP | W | Pa |
| M_RDELP | E | 1/Pa |
| M_LNPR | D | 1 |
| M_ALPH | A | 1 |
| M_RTGR | T | 1/Pa |
| M_RPRE | H | 1/Pa |
| M_RPP | Q | 1/Pa² |

## Complete ordered arithmetic

Finite-element mode represents vertical variation with basis functions. Its supplied depth weight need not equal the difference of boundary pressures. At each active layer use VDELA, VDELB, VAF and VBF for $`D_A,D_B,A_f,B_f`$ and calculate the following values.

```math
\begin{aligned}
W&=\mathrm{RN}(D_A+\mathrm{RN}(D_Bp_s)), & E&=\mathrm{RN}(1/W),\\
F&=\mathrm{RN}(A_f+\mathrm{RN}(B_fp_s)), & I&=\mathrm{RN}(1/F),\\
D&=\mathrm{RN}(WI), & T&=\mathrm{RN}(B_fI),\\
A&=\mathrm{RN}(\mathrm{RN}(p_l-F)I).
\end{aligned}
```

H and Q remain positive zero. If PRESF is present, recompute F with the same affine expression.

Conventional normal layers run from IFIRST through KFLEV. Set $`W=\mathrm{RN}(p_l-p_u)`$ and $`E=\mathrm{RN}(1/W)`$. Mode NDLNPR=0 initialises $`I_u=\mathrm{RN}(1/p_u)`$ at the first normal layer and calculates $`H=\mathrm{RN}(1/p_l)`$. Carry H as the next layer's rounded upper reciprocal. Use the frozen [scalar math library](../pressure_math.md) for log and exp.

```math
\begin{aligned}
D&=\log_{\mathrm{frozen}}(\mathrm{RN}(p_lI_u)),\\
A&=\mathrm{RN}(1-\mathrm{RN}(\mathrm{RN}(p_uE)D)),\\
Q&=\mathrm{RN}(HI_u),\\
T&=\mathrm{RN}\left(E\,\mathrm{RN}\left(\Delta B+\mathrm{RN}(\mathrm{RN}(CD)E)\right)\right).
\end{aligned}
```

Modes 1 and 2 instead use $`Q=\mathrm{RN}(1/\mathrm{RN}(p_lp_u))`$, $`D=\mathrm{RN}(W\sqrt{Q})`$ and $`H=\mathrm{RN}(1/p_l)`$. Square root is correctly rounded. Their A and T use the same expressions above.

With IFIRST=2, process layer 1 after all normal layers. Mode 0 retains its actual W and E and uses $`D=\log_{\mathrm{frozen}}(\mathrm{RN}(p_1/\mathrm{TOPPRES}))`$, $`H=\mathrm{RN}(1/p_1)`$, $`A=\mathrm{RHYDR0}`$, $`Q=\mathrm{RN}(1/\mathrm{RN}(p_1\mathrm{TOPPRES}))`$ and $`T=\mathrm{RN}(E\Delta B_1)`$. RHYDR0 is a dimensionless top closure weight.

Top modes 1 and 2 instead set W equal to $`p_1`$. Mode 1 sets $`D=\mathrm{RN}(2+\mathrm{RN}(C_v/R_d))`$, reading RCVD and RD in joules per kilogram per kelvin. Mode 2 uses the already computed second-layer W and D.

```math
D_1=\mathrm{RN}\left(1+\mathrm{RN}\left(\mathrm{RN}\left(D_2\,\mathrm{RN}(W_1/W_2)\right)\sqrt{\mathrm{RN}(p_2/p_1)}\right)\right).
```

Then set $`E=\mathrm{RN}(1/W)`$, A=1, $`T=\mathrm{RN}(E\Delta B_1)`$, $`H=\mathrm{RN}(1/p_1)`$ and $`Q=\mathrm{RN}(\mathrm{RN}(DE)\,\mathrm{RN}(DE))`$. Reusing the identical rounded DE value preserves the result.

If PXYB is present, copy every scratch field and column to it. If PRESF is present, mode 0 with LAPRXPK=true stores $`\mathrm{RN}(\mathrm{RN}(p_u+p_l)\,0.5)`$. With LAPRXPK=false it stores $`\mathrm{RN}(\exp_{\mathrm{frozen}}(-A)p_l)`$. Modes 1 and 2 store $`\mathrm{RN}(\mathrm{RN}(1-A)p_l)`$ in normal layers and $`\mathrm{RN}(p_1/D_1)`$ at the closed top. All coefficient stages stay inside the direct routine when only PRESF is requested.

Forbid fusion, reassociation, approximate division or square root, reduced precision and fast-math. Preserve signed zeros, gradual underflow and the floating-point control register, FPCR.

## Shapes, storage and ABI

NPROMA is positive, KFLEV is nonnegative, 1 <= KSTART <= NPROMA, and KSTART-1 <= KPROF <= NPROMA. Calls with neither optional output support empty intervals and zero layers without accessing unused numerical buffers. Optional outputs require at least one layer and a nonempty interval. Mode 2 with IFIRST=2 requires at least two layers. These restrictions avoid the source's undefined empty top decision and absent next layer. Conventional NDLNPR is 0, 1 or 2, while finite-element mode ignores it.

PXYB has shape (NPROMA,KFLEV,NDIM), using module YYTXYB. Every used index fits the module count and actual caller capacity, and used fields are distinct. Finite-element mode uses five fields and permits invalid unused H/Q indices. Every present allocation covers its full declared shape. Arrays are contiguous aligned FP64 values in Fortran order, with column varying first. Address arithmetic fits signed 64 bits.

Used coefficients are contiguous GNU rank-one allocations. VAH and VBH cover 0 through KFLEV-1. Finite-element mode also uses VAF, VBF, VDELA and VDELB at 1 through KFLEV. Conventional optional modes use VDELB and, for normal layers, VC. Allocations may start below their first used index. Unused allocations may be absent. Outputs are disjoint from each other, coefficient storage and configuration, which retain their bytes. PRESH's bottom and inactive columns stay unchanged. PRESF's inactive columns stay unchanged. Present PXYB receives positive zero in every inactive cell and unused field.

All used inputs and required intermediates are finite. Surface and full pressures, weights and used denominators are positive. Boundaries increase downwards and top pressure is nonnegative. The science corpus uses normal relative layer depth at least 0.001. Near-coincident layers expose an upstream log-conditioning defect, so source agreement alone does not establish their physical validity. TOPPRES, RD and RCVD are positive, and RHYDR0 is nonnegative.

Export gphpre_ on AArch64 for GNU Fortran 12.3. Registers x0 to x7 hold addresses of KPROMA, KFLEV, KSTART, KPROF, YDVAB, YDCVER, PRESH and optional PXYB. Optional PRESF is the first incoming stack address. An absent optional array is null. Integers and logical values use 32 bits. Preserve x19 to x29, the link register, required parts of v8 to v15 and 16-byte stack alignment. Do not use x18. Profiling hooks are excluded. Standard allocation, clearing and copying calls may manage scratch but supply no numerical stage.

TVAB occupies 512 bytes and TCVER occupies 216 bytes. Its VBH, VAH, VC, VAF, VBF, VDELA and VDELB descriptors start at 64, 128, 192, 256, 320, 384 and 448. A descriptor holds data at 0, element offset at 8, element length at 16, span at 32, stride at 40, lower bound at 48 and upper bound at 56. Element j is at data+8(j-lower). TCVER has LAPRXPK at 0, NDLNPR at 4, RHYDR0 at 8 and LVERTFE at 52. The eight-int32 YYTXYB holds M_DELP, M_RDELP, M_LNPR, M_ALPH, M_RTGR, M_RPRE, M_RPP and NDIM in order. Read __intdyn_mod_MOD_yytxyb, __yomvert_MOD_toppres, __yomcst_MOD_rd and __yomcst_MOD_rcvd. Recheck layout for another compiler.

## Independent science and exact bytes

Check affine boundary pressures and the telescoping actual depth sum, which gives column mass after division by gravitational acceleration. Independently integrate log pressure to find the mode-0 identric mean, which is the exponential of average log pressure. Integrate log($`p_l/p`$) to check alpha. Arithmetic pressure is the midpoint. Modes 1 and 2 use geometric pressure $`\sqrt{p_up_l}`$ and depth $`2\sinh(\log(p_l/p_u)/2)`$. Check positive depth excess and its cubic thin-layer limit. With $`z=\sqrt{p_u/p_l}`$, $`E_*=(1-z)/(1+z)`$ and $`D_*=B_l/p_l-B_u/p_u`$, their T differs from the derivative of log geometric pressure by $`E_*D_*/2`$. Mode 0 T remains the identric derivative when LAPRXPK selects arithmetic pressure.

Check each prescribed top closure. Mode 2 gives D=2 in real arithmetic, while preserving the declared FP64 expression. Mixed top columns share a decision. Actual depths sum to surface minus actual top pressure. Closed-top mode-1/2 weights instead sum to surface pressure. Finite-element W is an adjusted integration weight, so check its affine weights and quotient-rule sensitivities rather than imposing an unweighted mass sum.

Physical limits are 1e-10 Pa plus 1e-12 relative pressure error, 1e-12 plus 1e-12 relative dimensionless error, and 1e-16 1/Pa plus 1e-12 relative inverse-pressure error, and 1e-20 1/Pa² plus 1e-12 relative inverse-pressure-squared error. Mode-0 alpha also permits its rounding amplification $`64\,2^{-53}(1+p_u/(p_l-p_u))`$. Apply the corresponding pressure allowance to the identric mean. Exact Fortran agreement permits zero differing bytes.

One verifier covers finite-element and all conventional modes, both LAPRXPK values, all optional combinations, positive and closed tops, threshold equality and mixed-column selection, partial and odd columns, pressure-only empty intervals and zero levels, alternate field maps, unused absent allocations, lower bounds 0 and -2, separate-rounding witnesses, input immutability, guards and protected-page tails. Compare complete PRESH, PXYB and PRESF buffers. Report the first stage, case, field, level, column and bit patterns.

Canonical small files concatenate complete guarded PRESH, PXYB and PRESF as little-endian FP64. Forecast headers contain uint64 call number, int32 step, nine int32 values in NPROMA, KFLEV, KSTART, KPROF, optional-presence mask, LVERTFE, NDLNPR, LAPRXPK and NDIM order, the eight-int32 field map, fourteen int64 lower/upper coefficient bounds in VAH, VBH, VAF, VBF, VDELA, VDELB and VC order, and four FP64 constants in TOPPRES, RD, RCVD and RHYDR0 order. The header is 224 bytes. Unused bounds are zero. Output records append complete PRESH, then present PXYB and PRESF. Input records append incoming PRESH, present PXYB and PRESF, then every used coefficient allocation in the declared order. Exclude addresses, clocks, padding, masking and normalisation.

## Provenance

Emit directly from this frozen contract, then assemble and link. Storage probes do not emit a solver. Inspect reference solver instructions only after direct emission. Preserve source, contract, library, verifier, probe and raw-output hashes. Add md2fort optimisation lessons only after accepted repeated quiet-node measurements.
