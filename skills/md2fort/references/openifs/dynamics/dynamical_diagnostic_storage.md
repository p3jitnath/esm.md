# Dynamical Diagnostic Storage

This setup owns the work arrays that record changes produced by the dynamical equations. These changes are called tendencies. It follows the original SUNDDH diagnostic controls and the complete SUALDYN_DDH allocation and initialisation body. It adds no scientific calculation.

## Source and Selected Route

The controls first require an empty first NAMDDH group in the live configuration text. They then write the original false defaults for LRSLDDH, LRSIDDH and LRHDDDH from `arpifs/dia/sunddh.F90` lines 257–259 and the resulting LRDDHDYN logical OR from line 850. The existing bounded `md2asm_require_empty_physics_group` parser admits the group before any MODEL mutation. A nonempty group refuses, so the stage cannot silently discard a user override.

The storage stage implements `arpifs/dia/sualdyn_ddh.F90`, called from SU0YOMB after diagnostic setup. It supports the source LRDDHDYN-false route. This flag disables the full diagnostic calculation while retaining small real owners required by downstream interfaces. The first two dimensions are therefore one for both spectral and grid work. A spectral field is stored as coefficients of horizontal basis functions, while a grid field stores values at spatial points. The final dimension of each grid owner remains the live number of grid blocks, even on this inactive diagnostic route.

The caller supplies live named owners for the thermal-field count NFTHER, transported-field counts NUMFLDS and NUMSPFLDS, semi-implicit diagnostic dimension NDIMSIGMV, logical flags LNHDYN and LNHX and Geometry's grid-block count. The existing semi-implicit tendency-layout producer derives NDIMSIGMV before this stage. No captured descriptor or payload supplies a production input.

## Interfaces and Ownership

| Assembly entry | Arguments in x0 onwards | Purpose |
| --- | --- | --- |
| `md2asm_initialize_dynamical_diagnostic_controls` | MODEL, MODEL capacity, configuration text, text bytes | Admit NAMDDH, then write its four named logical controls. |
| `md2asm_allocate_dynamical_diagnostic_storage` | Geometry, Geometry capacity, MODEL, MODEL capacity | Allocate and initialise all 17 source owners. |
| `md2asm_release_dynamical_diagnostic_storage` | MODEL, MODEL capacity | Release all owners in reverse source order. |

Capacities are byte counts. Geometry and MODEL must be mapped, non-wrapping, disjoint, aligned to eight bytes and at least 17,096 and 4,275,088 bytes. Configuration text must be mapped, bounded and disjoint from MODEL. Each entry returns a 32-bit status in w0. Zero means success, one means allocation failure and two means an unsupported input. An admission failure changes no MODEL byte and allocates nothing.

The allocation stage requires all 17 base pointers to be null. Counts must be nonnegative, grid blocks and NDIMSIGMV must be positive and the two nonhydrostatic flags must be zero or one. NFTHER plus two and every byte-size product must fit the declared signed storage range. The three grid third-dimension choices are NDIMSIGMV, two plus NFTHER, and the transported-field counts. NUMSPFLDS is replaced by at least one where the original source requires MAX(1,NUMSPFLDS). A zero NUMFLDS is a supported empty extent.

All owners contain FP64 words, with eight bytes per element. Their GNU Fortran descriptors retain the queried rank, unit lower bounds and contiguous column-major strides. For the selected singleton first two dimensions, rank-two offsets are −2, rank-three offsets are −3 and rank-four offsets are minus three minus the third extent. These offsets cancel the lower-bound contributions when a caller forms an element address.

| Source allocation group | Owners in source order | Extents |
| --- | --- | --- |
| Semi-implicit spectral tendencies | SPTNDSI_VOR, SPTNDSI_DIV, SPTNDSI_T, SPTNDSI_SPD, SPTNDSI_SVD | Each has shape (1,1). |
| Diffusion spectral tendencies | SPTNDHD_VOR, SPTNDHD_DIV, SPTNDHD_T, SPTNDHD_GFL, SPTNDHD_SPD, SPTNDHD_SVD, SPTNDHD_SNHX | Each has shape (1,1), except GFL with shape (1,1,max(1,NUMSPFLDS)). |
| Grid tendencies | GMVTNDSI_DDH, GMVTNDHD_DDH, GFLTNDHD_DDH, GMVTNDSL_DDH, GFLTNDSL_DDH | Each has shape (1,1,field count,grid blocks). |

Ordinary malloc preserves source-unwritten payloads. Temporary owners are allocated in the exact original order, and their descriptors publish only after all allocations succeed. If allocation fails, the stage frees earlier temporary owners in reverse order and leaves MODEL unchanged. The source-written fields become positive zero. The two thermal spectral owners remain unwritten when NFTHER is zero. The four spectral pressure and vertical-divergence owners remain unwritten when LNHDYN is false, and the spectral NH-X owner remains unwritten when LNHX is false. No other payload is filled merely because its allocation is fresh.

On the actual hydrostatic input, 17 owners contain 16,608 bytes. The original source writes positive zero to 16,568 bytes and leaves 40 bytes in five inactive nonhydrostatic spectral owners unchanged. The three grid owners consumed by CALL_SL have shapes (1,1,9,86), (1,1,3,86) and (1,1,8,86). Their MODEL descriptor offsets are 4269136, 4269272 and 4269408.

The controls use a 32-byte frame, allocation uses 256 bytes and release uses 64 bytes. Each entry preserves x18, all required callee-saved registers and the aligned stack. The entries use no floating-point calculation. Their only external production calls are malloc, free and the already accepted empty-group parser. Release clears base pointers and is safe after setup failure and when repeated. The caller must release only owners created by this allocator, while the complete MODEL record is still live.

## Accepted Checks

Three genuine complete-source profiles cover the actual 86-block inputs, the zero-thermal and zero-transported-extent case, and active nonhydrostatic branches. Whole MODEL descriptors and all owner payloads agree exactly, including nonzero preimages in source-unwritten arrays. A separate source inventory checks every shape and positive-zero or unchanged-payload obligation. Native ABI masks are zero, and immediate FPCR, FPSR and errno match the original source. Release and repeated release pass.

All 17 allocation-failure positions free their earlier temporary owners and preserve MODEL. Seventeen critical unsupported bounds, shapes, logical controls, size products and NAMDDH inputs refuse before mutation. Original Fortran and verification tools remain local. Complete saved-output agreement remains a separate gate in the autonomous forecast.
