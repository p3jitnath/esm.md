# OpenIFS GPGEO contract

Contract revision 1.1 records the complete GPGEO body in OpenIFS 48.1.1. Its physical input is the existing [hydrostatic balance](../../../../../formulations/openifs/dynamics/hydrostatic_balance.md), revision 1.0, equations P01 and P02. This routine integrates supplied vertical pressure weights without recalculating pressure or advancing time. Complete finite-element acceptance also requires a verified direct VERDISINT dependency; a call to the high-level reference is permitted only during local preparation.

## Supplied state and method

A half level is a layer boundary, and a full level is a point chosen within the layer. Let $`N`$ be the number of layers, counted from the top downwards. PHI stores $`\Gamma=gz`$ at boundaries 0 to N, with the supplied surface value at boundary N. PHIF stores it at full levels 1 to N. Both fields use square metres per second squared. PT stores temperature in kelvin. PR stores the mixture gas constant in joules per kilogram per kelvin for a hydrostatic model, or that constant multiplied by hydrostatic pressure divided by total pressure for a model with vertical pressure corrections.

PLNPR supplies a dimensionless pressure-depth weight $`d_j`$. PALPH supplies a dimensionless full-level weight $`a_j`$ in conventional mode. These can be prescribed approximations from the upstream pressure stage. GPGEO uses the supplied values rather than assuming that every depth is an exact log-pressure ratio. In conventional mode, descending from the surface gives

```math
\Gamma_{j-1}=\Gamma_j+R_jT_jd_j,
\qquad
\Gamma^f_j=\Gamma_j+a_jR_jT_j.
```

Finite-element mode represents variation between points with basis functions. VFE_RDETAH supplies the reciprocal dimensionless coordinate width $`r_j=1/(\eta_j-\eta_{j-1})`$. Prepare $`q_j=-R_jT_jd_jr_j`$ in temporary boundary-indexed storage, with positive-zero entries at temporary rows 0 and N+1. Call the direct VERDISINT dependency with operation IBOT, boundary option 11, and absent optional KBC and KCHUNK. Its supplied integration operator produces a full-level integral from the bottom. Add the unchanged surface PHI to its rows 0 to N-1 to obtain PHIF. Then calculate all half-level PHI values with the same descending recurrence as conventional mode. PALPH is unused and can be absent in this mode.

The dependency uses the supplied NVFE_INTBC value 0, 1, 2 or 3 to select the correct integration matrix. Its input and output have shapes (KPROMA,N+2) and (KPROMA,N+1), with column varying first. Complete acceptance requires the dependency's frozen matrix shapes, ordered reductions, exact output checks and instruction audit. Outside an OpenMP parallel region, arbitrary valid active intervals are supported. Inside a parallel region, the upstream VERINT matrix call is unshifted, so the matched source path requires KSTART=1. Record this restriction rather than changing the mathematical input or hiding the dependency.

## Ordered FP64 arithmetic

FP64 is the 64-bit floating-point number format. RN rounds each result to nearest FP64 with ties to an even final bit. Preserve gradual underflow and signed zeros, and leave the floating-point control register unchanged. Forbid fused operations, expression contraction, reassociation, approximate arithmetic, reduced precision and fast-math.

For each conventional cell, let H be the old lower-boundary PHI. Calculate $`u=\mathrm{RN}(R_jT_j)`$, $`v=\mathrm{RN}(u d_j)`$ and $`\Gamma_{j-1}=\mathrm{RN}(H+v)`$. For the full level, independently calculate $`c=\mathrm{RN}(a_jR_j)`$, $`e=\mathrm{RN}(cT_j)`$ and $`\Gamma^f_j=\mathrm{RN}(H+e)`$. Do not replace the full-level product by $`a_j u`$, since that changes an intermediate rounding point. Store the half-level result before the full-level result.

Finite-element preparation uses unary negation of R, then $`u=\mathrm{RN}((-R_j)T_j)`$, $`v=\mathrm{RN}(u d_j)`$ and $`q_j=\mathrm{RN}(v r_j)`$. Store active temporary endpoints as positive zero. Preserve the dependency's ordered integration. Each full-level result is $`\mathrm{RN}(ZOUT_{j-1}+\Gamma_N)`$. Complete those results before descending through half levels. Do not use PALPH in this branch. Independent columns can use in-bounds NEON pairs and a scalar final column.

## Shapes, buffers and mutation

KPROMA is positive, N is nonnegative, and 1 <= KSTART <= KPROMA with KSTART-1 <= KPROF <= KPROMA. PHI has shape (KPROMA,N+1), PHIF and all conventional inputs have shape (KPROMA,N), and entries are contiguous FP64 values in Fortran order. PHI's lower vertical bound is zero; the other physical arrays start at level one. Every used buffer is aligned to at least eight bytes. Extents, the combined temporary size and all address arithmetic fit signed 64-bit values. An allocation large enough for the finite-element temporary arrays must be available.

The vertical geometry object is present and valid. In finite-element mode, the contiguous VFE_RDETAH allocation covers indices 1 through N and can have a lower bound below 1. Its values and all required integration matrices are immutable. Unused allocations, including this coordinate array in conventional mode and PALPH in finite-element mode, can be absent. The dependency's configuration and operator storage must meet its verified contract whenever an active finite-element call requires them.

Empty active intervals and zero layers leave physical outputs unchanged. When no physical entry is active, explicit physical arrays can be absent. Profiling hooks are excluded. Inputs and every used intermediate are finite. Scientific cases use positive temperature, effective gas constant and pressure-depth weights; numerical boundary cases can use finite signed values to verify rounding and permitted storage.

PHI and PHIF are separate from one another and from every input and geometry allocation. Read-only input arrays can overlap one another because GPGEO does not change them. Active PHI rows 0 to N-1 and active PHIF levels change, while the entire surface PHI row, inactive columns, inputs, descriptors and configuration bytes remain unchanged. Temporary arrays are private to the routine. The driver supplies no numerical stage.

## GNU Fortran ABI

An application binary interface, or ABI, defines argument locations and the registers a function must preserve. Export gpgeo_ for AArch64 and GNU Fortran 12.3. Registers x0 to x7 hold addresses of KPROMA, KSTART, KPROF, KFLEV, PHI, PHIF, PT and PR. Incoming stack offsets 0, 8 and 16 hold PLNPR, PALPH and the vertical geometry pointer. Integer and logical values use 32 bits. Preserve x19 to x29, the link register, 16-byte stack alignment and required parts of v8 to v15. Do not use x18. This implementation uses only v0 to v7 for floating-point work.

The storage-only probe measures TVERTICAL_GEOM as 3232 bytes. Its YRVETA, YRVFE and YRCVER begin at offsets 520, 840 and 3016. LVERTFE is at offset 3068 and NVFE_INTBC at 3052. The VFE_RDETAH rank-one allocation descriptor starts at 776, with data pointer at 0, element size and span of eight bytes, unit stride at 40, lower bound at 48 and upper bound at 56. Its level-one value is data plus eight times (1 - lower bound). Re-measure these values for another compiler or configuration.

The VERDISINT call uses x0=geometry+840, x1=geometry+3016, x2=address of four characters IBOT, x3=address of two characters 11, and x4 to x7 as the original four integer argument addresses. Its outgoing stack holds the temporary input pointer, temporary output pointer, null KBC, null KCHUNK, hidden 64-bit character length 4 and hidden 64-bit character length 2 at offsets 0, 8, 16, 24, 32 and 40. VERDISINT_ENTRY defaults to verdisint_assembly_. A build that redirects it to verdisint_ is preparation only and cannot establish a complete direct solver.

The routine can call malloc and free for private storage; these calls provide memory, not numerical work. They allocate a single block of $`8\,\mathrm{KPROMA}(2N+3)`$ bytes for the two temporary arrays. Conventional mode allocates no temporary block. No exponential or logarithm is evaluated by GPGEO, so the pressure math library is not a numerical dependency of its assembly body.

## Independent physical and exact checks

Use the isothermal hydrostatic solution $`\Gamma(p)=\Gamma_s+RT\ln(p_s/p)`$ to check both boundary and full-level height. Supply independent positive pressure coordinates and their dimensionless depth and full-level log distances. Test a known constant pressure-ratio correction in PR to check the model with vertical pressure effects. The layerwise increase equals supplied effective gas constant times temperature times pressure depth, and positive physical inputs must give increasing height upwards. Adding a constant surface potential must shift every active result by that constant.

For finite-element science, use an independently derived integration matrix that integrates a constant coordinate derivative exactly at known full-level positions. Compare its known linear gravitational profile, surface anchoring and increasing upward height. Test every source-defined IBOT/11 boundary selector, distinct coordinate lower bounds and partial intervals outside parallel regions. These manufactured operators test the integration relationship without claiming whole-forecast physical validity.

Use long-double independent expected values, with physical tolerance $`10^{-10}\ \mathrm{m^2\,s^{-2}}+10^{-12}\lvert\Gamma\rvert`$. Critical numerical cases protect separate rounding, signed zeros, subnormals, odd widths, final columns, one and zero layers, empty intervals, untouched surface and inactive bytes, read-only inputs and final protected pages. Compare every raw output bit with unchanged strict-source Fortran, requiring zero differing bytes and reporting stage, case, field, level, column and both bit patterns. Check unchanged FPCR and audit emitted and reference instructions after assembly emission.

Canonical small-check files concatenate complete PHI and PHIF arrays with their guards as little-endian FP64 values in Fortran order. A protected tail uses a leading guard only. Forecast records begin with uint64 call number, int32 forecast step, six int32 values in KPROMA, KSTART, KPROF, KFLEV, LVERTFE and NVFE_INTBC order, two int64 coordinate lower/upper bounds and four int64 selected-matrix lower/upper bounds. This fixed header is 84 bytes. Bounds are zero when unused. Output records append complete PHI, then PHIF. Input records append incoming PHI and PHIF, complete PT, PR and PLNPR, conventional PALPH when used, then finite-element coordinate values at levels 1 to N and selected matrix values in allocation order when used. Do not record addresses, clocks or object padding. Timing records remain separate.

## Provenance and acceptance

Freeze this formulation, contract, source identity, measured layout, target features, toolchains and critical input rules before emitting assembly directly. Use an assembler and linker, without compiler-generated solver assembly or intermediate representations. Record the emission time before inspecting reference instructions. Preserve rejected checks, raw output bytes, hashes and complete dependency records in ignored runtime storage.

Conventional-branch acceptance can be recorded after its independent science and exact checks pass. Complete GPGEO acceptance also requires the verified direct finite-element dependency, its active branch checks and all saved forecast comparisons. A source call to a high-level dependency is explicitly incomplete. No comparative timing or optimisation conclusion follows from correctness checks.

Revision 1.1 corrects only the physical-source reference. The initial generated note, revision 1.0 contract and original pre-emission freeze remain archived under .runtime/openifs/gpgeo/frozen-docs/. The existing hydrostatic formulation has unchanged mathematics, revision and equation identifiers. This correction changes no ordered arithmetic, assembly instruction or accepted output byte; the supplemental provenance record preserves both original and current document hashes.
