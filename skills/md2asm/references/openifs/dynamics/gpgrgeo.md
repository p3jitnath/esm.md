# OpenIFS GPGRGEO contract

Contract revision 1.1 records the complete GPGRGEO body in OpenIFS 48.1.1. Its physical inputs are the existing [hydrostatic balance](../../../../../formulations/openifs/dynamics/hydrostatic_balance.md), revision 1.0, equations P01 and P02, and [pressure-gradient coefficients](../../../../../formulations/openifs/dynamics/pressure_gradient_coefficients.md), revision 1.0, equations OIFS-PG1 to OIFS-PG3. These formulations retain their existing equations, identifiers and hashes. GPGRGEO differentiates supplied layer integration without calculating pressure weights or advancing time. Complete finite-element acceptance requires the separately verified direct VERDISINT dependency.

## Physical quantities and method

A half level is a layer boundary, and a full level is a point inside a layer. Let N be the number of layers, counted downwards from the top. Geopotential $`\Phi=gz`$ has units of square metres per second squared. Its horizontal derivative $`B=\partial\Phi/\partial x`$ describes change along horizontal coordinate x. When x uses metres, B uses metres per second squared. A model coordinate with another scale retains its corresponding derivative unit.

PRT supplies $`H=R_mT`$ in square metres per second squared. PRTL and PRTM supply its derivatives G in two directions. PLNPR supplies dimensionless pressure-depth weight d, and PALPH supplies dimensionless full-level weight a. PXYBDER supplies their derivatives D and A, in inverse metres for a distance coordinate. Its first index is column, second is level, and third selects a field through read-only module object YYTXYBDER. POROGL and POROGM supply surface derivatives of geopotential.

An absent or false LDNHEE selects the hydrostatic or source quasi-elastic model, with its supplied modified temperature. True selects the model with vertical pressure corrections. Then PRNHPPI supplies the dimensionless ratio $`c=p_h/p`$, and PQCHAL and PQCHAM supply $`Q=\partial\ln(p/p_h)/\partial x`$. Hydrostatic pressure $`p_h`$ and total pressure p are positive in physical cases. Thus $`\partial c/\partial x=-cQ`$, and the derivative of cH is $`c(G-HQ)`$, by the product and chain rules.

For each direction, start from supplied surface derivative $`B_N=B_s`$. Conventional mode gives

```math
\begin{aligned}
B_{j-1}&=B_j+d_jG_j+D_jH_j, &
B^f_j&=B_j+a_jG_j+A_jH_j &&\text{when LDNHEE is absent or false},\\
B_{j-1}&=B_j+d_jc_j(G_j-H_jQ_j)+D_jc_jH_j, &
B^f_j&=B_j+a_jc_j(G_j-H_jQ_j)+A_jc_jH_j &&\text{when LDNHEE is true}.
\end{aligned}
```

These are horizontal derivatives of the supplied discrete height integral. Weights can be approximations from the upstream pressure stage; d need not be an exact logarithmic pressure ratio. Optional PNH1L and PNH1M contain $`n=-HQ`$ when LDNHEE is true, and positive zero otherwise.

Finite-element mode represents vertical variation with basis functions. It uses the same descending half-level recurrence. For full levels, prepare a coordinate derivative in each direction,

```math
q_j=-\bigl(d_jG_j+D_jH_j\bigr)r_j
\quad\text{or}\quad
q_j=-\bigl(d_jc_j(G_j-H_jQ_j)+D_jc_jH_j\bigr)r_j,
\qquad
r_j=\frac{1}{\eta_j-\eta_{j-1}}.
```

The dimensionless coordinate eta increases downwards, and VFE_RDETAH supplies reciprocal layer width r. Put q at temporary rows 1 to N with positive-zero rows 0 and N+1. For each direction, direct VERDISINT with operation IBOT, boundary option 11 and absent optional KBC and KCHUNK integrates from the bottom. Add the surface derivative to its rows 0 to N-1 to obtain full-level derivatives. PALPH and alpha derivative fields are unused.

## Ordered FP64 arithmetic

FP64 is the 64-bit floating-point format. RN rounds each operation to nearest FP64 with ties to an even final bit. Preserve signed zeros and gradual underflow, and leave FPCR, the Arm floating-point control register, unchanged. Forbid fused operations, contraction, reassociation, approximate arithmetic, reduced precision and fast-math.

Stage 1 prepares private n arrays for both directions at every active level. When LDNHEE is true, negate H and compute $`n=\mathrm{RN}((-H)Q)`$. Otherwise store positive zero. Copy those bits to each present PNH1 output, independently. Stage 2 copies each supplied surface derivative to its active half-level surface cell, including when N is zero.

Stage 3 descends through all half levels. Without pressure correction, compute $`u=\mathrm{RN}(dG)`$, $`v=\mathrm{RN}(DH)`$, then $`B_{\mathrm{new}}=\mathrm{RN}(\mathrm{RN}(B_{\mathrm{old}}+u)+v)`$. With correction, compute $`s=\mathrm{RN}(G+n)`$, $`u=\mathrm{RN}(\mathrm{RN}(dc)s)`$, $`v=\mathrm{RN}(\mathrm{RN}(Dc)H)`$, and the same separately rounded additions. Store the L component before M at each cell.

Stage 4 in conventional mode ascends through full levels after every half-level value is complete. Use the same arithmetic with a and A replacing d and D, and read lower boundary $`B_j`$. Recompute each product with the declared multiplication order.

Stage 4 in finite-element mode ascends through temporary input levels. Without correction, compute $`u=\mathrm{RN}((-d)G)`$, $`v=\mathrm{RN}(DH)`$ and $`q=\mathrm{RN}(\mathrm{RN}(u-v)r)`$. With correction, compute $`s=\mathrm{RN}(G+n)`$, $`u=\mathrm{RN}(\mathrm{RN}((-d)c)s)`$, $`v=\mathrm{RN}(\mathrm{RN}(Dc)H)`$, and the same subtraction and final multiplication. Negate d before multiplication and retain the subtraction, since negating a sum can change signed-zero bits. Set active temporary endpoints to positive zero, call the dependency for L and then M, and obtain each full value from $`\mathrm{RN}(ZOUT_{j-1}+B_s)`$.

Columns are independent and can use scalar FP64 loops. Temporary arrays are private, and drivers supply no omitted numerical stage.

## Shapes, bounds and options

KPROMA is positive, N is nonnegative, 1 <= KD <= KPROMA, and KD-1 <= KF <= KPROMA. KF=KD-1 is an empty interval. Physical arrays are contiguous FP64 in Fortran order and aligned to at least eight bytes. PRT, PRTL, PRTM, PLNPR, used PALPH, present correction inputs, PHIFL, PHIFM and present PNH1 outputs have shape (KPROMA,N). PHIHL and PHIHM have shape (KPROMA,N+1), with vertical lower bound zero. Each orography buffer contains KPROMA entries. PXYBDER storage has shape (KPROMA,N,C), where C is the actual number of allocated fields. The source declaration uses YYTXYBDER%NDIM, but its accessed field blocks depend only on KPROMA, N and the selected indices.

Used map values M_LNPRL, M_LNPRM, and, in conventional mode, M_ALPHL and M_ALPHM lie between 1 and both NDIM and C. They can select arbitrary valid or repeated fields. Unused indices need no value, and unused generic fields need no allocation. INTDYN_MOD initializes generic YYTXYBDER with NDIM=9, while CPG_GP_HYD allocates six fields through YYTXYBDER0. GPGRGEO reads only its selected field blocks, so this six-field caller allocation is supported without reading the unused generic fields. The forecast driver is scoped to that known caller and records its actual capacity.

A present LDNHEE is a GNU Fortran logical with canonical value 0 or 1. True requires all three correction inputs present, even for empty or zero-level calls. Calls that invoke upstream ABOR1 are outside this contract. An absent or false flag permits absent correction inputs. Each PNH1 output can independently be present or absent. Unused PALPH can be absent in finite-element mode. Zero levels require no level-buffer access, but active calls still require orography and half-level surface buffers. Empty intervals change no physical output.

GEOMETRY and its YRCVER target are read-only valid objects. Active finite-element calls with N>0 also require valid YRVETA and YRVFE targets, coordinate allocation and selected integration matrix. VFE_RDETAH has unit stride, covers 1 through N, and can have a lower bound below 1. IBOT/11 supports NVFE_INTBC=0,1,2,3 with the dependency's matching allocated matrices. Outside an OpenMP parallel region, arbitrary valid intervals are supported. Inside a parallel region, the unchanged source matrix call requires KD=1.

Every output is separate from the other outputs, inputs, geometry and module storage. Read-only inputs can overlap. Only active half-level rows 0 to N, active full levels 1 to N and active present PNH1 entries change. Inactive columns and guards retain raw bits; surface half-level cells change to the supplied orography derivatives. All inputs, maps, descriptors and configuration bytes remain unchanged.

All used inputs and intermediates are finite. Scientific cases use positive H and pressure ratio c with physically valid pressure coordinates. Gradients can have either sign, so no general output ordering applies. Numerical boundary cases can use signed finite weights, zeros and subnormals. Buffer sizes, temporary sizes and address arithmetic fit signed 64-bit values, and enough private memory is available. Conventional mode can allocate two arrays totalling 2*KPROMA*N entries. Finite-element mode can allocate six arrays totalling KPROMA*(6N+6) entries. Empty and zero-level calls need no allocation.

## GNU Fortran ABI and dependencies

An application binary interface, or ABI, defines argument locations and preserved registers. Export gpgrgeo_ for AArch64 and GNU Fortran 12.3. Registers x0 to x7 hold GEOMETRY, addresses of KPROMA, KD, KF and KFLEV, then PRT, PRTL and PRTM. Incoming stack offsets 0,8,16,24,32,40,48,56,64 hold PLNPR, PALPH, PXYBDER, POROGL, POROGM, PHIFL, PHIFM, PHIHL and PHIHM. Offsets 72,80,88,96,104,112 hold optional LDNHEE, PRNHPPI, PQCHAL, PQCHAM, PNH1L and PNH1M. Absent optional arguments are null; integer and logical values use 32 bits.

Preserve x19 to x29, the link register, required parts of v8 to v15 and 16-byte stack alignment. Do not use x18. Floating-point work can use only v0 to v7. Preserve saved registers across allocation and integration calls.

The storage-only probe measures GEOMETRY as 17096 bytes, with YRVETA, YRVFE and YRCVER pointers at 3248,3256,3264. Their target sizes are 320,2176,216 bytes. LVERTFE and NVFE_INTBC are 32-bit target values at YRCVER offsets 52 and 36. VFE_RDETAH's rank-one GNU descriptor starts at YRVETA offset 256, with data pointer at descriptor offset 0, eight-byte element size and span, stride one at 40, lower bound at 48 and upper bound at 56. Level one is data plus eight times (1 - lower bound). YYTXYBDER is 40 bytes, with map fields at 0,4,8,12 and NDIM at 36. Access it through __intdyn_mod_MOD_yytxybder. Re-measure for another compiler or configuration.

Each VERDISINT call uses x0=YRVFE target, x1=YRCVER target, x2=four characters IBOT, x3=two characters 11, and x4 to x7 as the original four integer argument addresses. Its 48-byte outgoing area holds input pointer, output pointer, null KBC, null KCHUNK, hidden 64-bit length 4 and hidden 64-bit length 2 at 0,8,16,24,32,40. VERDISINT_ENTRY defaults to verdisint_assembly_. Redirecting it to high-level verdisint_ is preparation only and cannot establish complete solver acceptance.

malloc and free provide private storage, not numerical work. The body evaluates no exponential, logarithm, division or square root. Finite-element integration and ordered matrix products must be direct assembly and independently verified before accepting that branch. Profiling hooks are excluded.

## Independent checks and canonical bytes

Use a known height profile rather than another recurrence. Let $`H(x)=H_0+Gx`$, total pressure distance $`W(x)=W_0+D_*x`$, and surface potential $`\Phi_s(x)`$ be prescribed. Differentiating $`\Phi(x)=\Phi_s(x)+H(x)W(x)`$ at zero gives independent expectation $`B_s+GW_0+H_0D_*`$. Prescribe equal log-pressure distances and full-point positions, then use their total distances directly. A layerwise linear H profile has a closed-form arithmetic-series sum to check changing temperature without a descending reference loop.

For correction, differentiate $`\Phi(x)=\Phi_s(x)+(H_0+Gx)(W_0+D_*x)c_0e^{-Qx}`$. At zero its derivative is $`B_s+c_0(GW_0+H_0D_*-QH_0W_0)`$. Check a symmetric long-double difference of this closed-form function separately. Optional n outputs equal the analytic correction. Q=0,c=1 reduces the real expression to hydrostatic form; exact acceptance follows each branch's own rounded arithmetic.

Finite-element science uses an independently derived constant-derivative matrix at known full-point locations, checking the linear gradient profile and surface anchor in both directions and correction modes. Cover every supported selector, coordinate and matrix lower bounds, partial intervals outside parallel regions and unused alpha fields. A configured forecast matrix needs separate coefficient and quadrature checks; a synthetic operator does not prove whole-forecast accuracy.

The frozen conventional shapes (KPROMA,KD,KF,N) are (1,1,1,0), (1,1,1,1), (2,1,2,2), (3,1,3,3), (7,2,6,5), (9,1,9,19), (13,13,13,20), (3,2,1,7), (8,1,8,32). Cover absent, false and true flags, independent optional-output presence, valid six- and nine-field maps, constant and layerwise physical profiles, correction, both zero signs, subnormals and finite extremes. Protected-tail shapes include widths 1,3,4,7. Three additional cases use declared NDIM=9 with a protected actual capacity C=6, one for each flag state; the conventional corpus now contains 150 cases. A witness protects the two rounded additions. FE rules additionally cover selectors 0 through 3, lower bounds -1,0,1, both correction modes, and one, zero, odd, partial and empty shapes; acceptance waits for the verified direct dependency.

Physical derivative tolerance is $`10^{-11}+10^{-12}\lvert B\rvert`$ in its corresponding unit. The finite-difference witness includes a scale-aware allowance for truncation and long-double rounding. Check every output bit against unchanged strict-source Fortran, requiring zero differing bytes, and check inactive bytes, guards, read-only buffers, geometry, maps and unchanged FPCR. Report the first case, mode, field, level, column and both bit patterns. Inspect body and reference instructions only after direct emission.

Small-check files concatenate PHIHL,PHIHM,PHIFL,PHIFM,present PNH1L,present PNH1M for each frozen case, including guards, as little-endian FP64 in Fortran order. A protected tail has one leading guard. Forecast records begin with uint64 call number, int32 forecast step, ten int32 values KPROMA,KD,KF,KFLEV,LVERTFE,NVFE_INTBC,LDNHEE,presence mask,NDIM,C, four int32 map indices and six int64 coordinate and selected-matrix bounds. This header is 116 bytes. Presence bits 0 to 5 identify flag,ratio,QL,QM,PNH1L,PNH1M; unused bounds are zero.

Forecast output records append complete half L,half M,full L,full M and present PNH1 arrays. Inputs append their incoming bytes in that order, complete PRT,PRTL,PRTM,PLNPR,used PALPH,complete actual-capacity PXYBDER,POROGL,POROGM,used correction inputs,used coordinate levels 1 to N and selected matrix allocation. Addresses, object padding and clocks are excluded. Timing records are separate.

## Generation and acceptance

Freeze physics hashes, this contract, unchanged source, measured layout, critical input rules, target and toolchain before direct assembly emission. Build with assembler and linker without high-level solver code, compiler intermediate representations or compiler-generated solver assembly. Preserve each original freeze and any later amendment.

Conventional acceptance needs independent science, exact source comparison, bounds, FPCR and instruction audit. Complete acceptance also needs the verified direct finite-element dependency, its critical modes and saved forecast comparisons. An unresolved numerical dependency leaves the complete solver explicitly incomplete. Correctness checks provide no comparative timing or performance claim.

Revision 1.1 refines the storage bound after an independent audit of INTDYN_MOD lines 289 and 292 and CPG_GP_HYD line 184. It changes no physical equation, ordered arithmetic or emitted assembly. The original pre-emission contract, verifier and freeze remain under .runtime/openifs/gpgrgeo/frozen-docs/. The amendment records both document hashes and adds the protected six-field caller cases before forecast acceptance.
