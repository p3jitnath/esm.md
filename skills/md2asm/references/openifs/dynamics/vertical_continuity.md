# Vertical Continuity Solver Contract

This is the first complete GPCTY contract for the selected finite-element route. It defines a new deterministic buffer representation, while retaining every original numerical expression, source-defined byte and physical method. The corrected Fortran remains a separate reference. The unchanged original forecast remains the saved-file reference.

## Physical Meaning And Complete Route

Use 19 layers, boundary choice 3, ITOP/11 integration and no upper-boundary flux. Wind components u and v use metres per second; surface-pressure gradients g_x and g_y use pascals per metre. Divergence D and the optional specific mass source s use inverse seconds. Layer pressure depth Delta_p uses pascals, inverse full-level pressure r_p uses inverse pascals, and coordinate coefficients B and Delta_B are dimensionless. The supplied full-level B may have a small signed finite-element interpolation overshoot; positive pressure and layer depth remain required.

For every active column and layer, form $`q=R(R(u g_x)+R(v g_y))`$, where R is one FP64 rounding to nearest with ties to even. Form $`d=R(R(D\Delta p)+R(\Delta B q))`$. When the source is present, replace d with $`R(d-R(s\Delta p))`$. Scale it with $`z=R(d r_{\Delta\eta})`$, where r_deta is the reciprocal dimensionless layer thickness. Set the top and extra input to positive zero and call the complete accepted private VERDISINT child, retaining its ITOP/11, default IBC3 and strict increasing-column matrix reduction. The actual same-run integration matrix has SHA256 ada93faf4c4f1ed071a8cb110c0429f31ff43917d823f8bbdd253ec65aba41c9, identical to the accepted LAPINEB matrix.

Let I_j denote its full-level result and I_bottom its extra surface result, in pascals per second. $`EVEL_j=R(R(B_j I_b)-I_j)`$, $`PSDIV_j=I_j`$, $`DIVDP_j=d_j`$ and $`VVEL_j=R(R((-I_j)+R(B_j q_j))r_{p,j})`$. Preserve each separate rounding point. No fused operation, contraction, reassociation, approximate arithmetic or reduced precision is allowed. Independent output fields may be transferred together after q, d and I are complete; keep every output entry's dependency order.

## New Output Representation

The five field maps are EVEL=1, VVEL=2, PSDIV=3, PSDVBC=4 and DIVDP=5, with five fields. At active level zero, set EVEL and PSDIV to positive zero. Set active PSDVBC levels zero through 18 to positive zero and its bottom level 19 to I_bottom. The original source left only those first PSDVBC slots uninitialised. Retain their allocator witness and do not claim agreement against their old bytes. Preserve incoming VVEL and DIVDP level-zero bits, every inactive column and all other owner bytes.

The two genuine R23 packets cover 24 active columns and eight active columns in complete 24-column carriers. Their complete corrected returns total 38,400 bytes. All 33,536 originally defined bytes agree with the unchanged original capture, and all 4,864 newly defined bytes are positive zero. The complete corrected return agrees with a separate ordered oracle, and 3,200 independent 120-digit pressure-divergence, coordinate mass-flux, material pressure-rate and boundary relations pass. Reuse the retained 385 uniform sigma-coordinate mass-source relations and the unchanged accepted child science.

## Complete Interface And Bounds

The entry retains 19 ordinary pointers in original GPCTY order: YDVFE, YDCVER, KPROMA, KD, KF, KFLEV, LDRUBC, YDVAB, YDVETA, PU, PV, PD, PEVT, PXYB, PSPL, PSPM, PRPREF, PCTY and optional PDPHYCTY. The explicit arrays store column first, then level, then field. Freeze one through 256 total columns, KD from one through KPROMA and KF from KD-1 through KPROMA. The empty interval changes no public output byte and performs no floating-point parent work. KFLEV is 19, LVERTFE is true, LDRUBC is false and NVFE_INTBC is 3.

PEVT is unused in this route and may be null. Retain its ordinary pointer without requiring or reading a backing owner. Optional PDPHYCTY may also be null; only that null omits its declared source subtraction. Every consumed ordinary owner remains strict and complete. PXYB has seven fields with the captured YYTXYB map [1,2,3,4,5,6,7,7]. PCTY has 20 stored levels and five fields. The output carrier is disjoint from every consumed input record, array, coefficient carrier and field-map global. Input-only aliases may be preserved.

Use complete type records of 2,176 bytes for TVFE, 216 bytes for TCVER, 512 bytes for TVAB and 320 bytes for TVETA. The consumed dense FP64 descriptors are RINTBF11 at TVFE+240, VBF at TVAB+320, VDELB at TVAB+448 and VFE_RDETAH at TVETA+256. The three rank-one arrays use bounds 1:19, stride one, descriptor origin -1 and complete 152-byte carriers. The matrix uses bounds 1:20 by 1:21, strides one and 20, origin -21 and a complete 3,360-byte carrier. Descriptors use eight-byte elements and spans. Require eight-byte alignment for every consumed real array.

Before writing public output, validate all controls, field maps, descriptor bounds, output disjointness and active numerical inputs. Require positive layer pressure depth, inverse pressure and reciprocal coordinate depth; permit nonnegative Delta_B including signed zero. All active inputs and all consumed coefficient values have magnitude below $`2^{128}`$, retaining signed zeros and subnormals. Separate products, sums and the 21-term integration then stay below $`2^{800}`$, which excludes floating-point overflow without changing the method. Inactive input values need not be read. Reject unsupported controls and bounds before public mutation.

## ABI And Reference Status

The direct parent owns every selected stage and calls only its accepted private complete assembly VERDISINT child. General allocation and parallel-status support supply no numerical weather calculation. A driver supplies no missing stage. Preserve x18, x19 through x29, the link register and the low 64 bits of d8 through d15, with 16-byte stack alignment. Use FPCR zero, gradual underflow and preserved signed zeros. Return the native numerical FPSR with incoming sticky flags, and preserve incoming errno after allocation bookkeeping.

The separately named corrected control is compiled with -ffixed-x18 from exactly the root's repaired source, with strict contraction-disabled arithmetic and the unchanged accepted vertical reference. Its strict reference route still changes x18, so a declared reference-only assembly forwarding bridge saves and restores x18 at the complete reference boundary. It supplies no numerical stage and changes no FPCR, FPSR or errno. The full seeded probe still checks every required integer and floating-point register. Native calls never link or use that bridge. Preserve the first raw source register-difference record and the root's original corrected library and source hashes.

Accept zero differing bytes across the complete corrected PCTY carrier, unchanged complete consumed inputs and records, actual aliases, protected bounds, fresh and sticky numerical status, errno and full seeded raw native ABI. Retain the first stage, field, column, level and bit patterns of any difference. Admission requires the root's positive normal-call and exact ten-file comparison against the unchanged original forecast.

## Direct Build And Source Traceability

The physical input is [vertical continuity](../../../../../formulations/openifs/dynamics/vertical_continuity.md), revision 1. The complete direct entry is `md2asm_gpcty_7259755`. Assemble this parent and reuse the accepted [vertical dispatcher](../../../../../src/openifs/dynamics/verdisint.S), vertical integral and derivative stages, and [ordered matrix product](../../../../../src/openifs/dynamics/strict_matrix.S). Rename their private symbols through the assembler definitions and object-symbol mapping recorded locally, preserving every instruction. The parent’s private integration entry is `md2asm_gpcty_private_verdisint_body`. Link against the unchanged source-owned configuration records and allocation support only. The direct route makes no Fortran numerical call.

## Accepted Forecast Calls

The complete direct stage passes 2,150 genuine native calls and 41,280,000 complete returned bytes with zero differences. All ten saved forecast files agree across 618,140 bytes. The recorded independent physics and interface checks remain required within this contract. Other forecast stages remain in Fortran.
