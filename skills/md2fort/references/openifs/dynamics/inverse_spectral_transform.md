# Complete Inverse Spectral Transform Contract

Numerical contract revision 1 freezes the selected `ltinv_mod::ltinv` source calculation before parent assembly generation. A spectral coefficient is the size of a wave in the model state. This parent turns coefficients on a sphere into Fourier coefficients at each latitude. It also forms the working winds $`U_c=a\cos\phi\,u`$ and $`V_c=a\cos\phi\,v`$ before this change of representation, with units of square metres per second. Here $`a`$ is the sphere's radius in metres, $`\phi`$ is latitude in radians and $`u,v`$ are wind speeds in metres per second. Requested scalar derivatives use $`D f=\cos\phi\,\partial f/\partial\phi`$ and retain the scalar's units. Later stages supply the metric conversion to wind speed. It performs no time update. Formulation revision 2 clarifies the units and highest working degree in this already verified calculation, without changing the source model or ordered arithmetic.

The source is `contrib/ectrans/src/trans/internal/ltinv_mod.F90` in the retained OpenIFS tree. Its complete original copy is `original_ltinv_mod.F90`. Its selected numerical children are the already developed `VDTUV`, `SPNSDE`, `LEINV` and `ASRE1B`. The Legendre child uses accepted unfused arithmetic revision 2, which rounds each product and sum separately. All old vendor sources and references stay unchanged.

## Selected Method

The captured forecast has scalar input truncation 21 and 32 Gaussian latitudes. Wind and scalar-derivative preparation can produce working degree 22, so the reconstruction includes that extra degree. The formulation's $`N`$ means the highest active degree of the selected working field. A Gaussian grid uses latitude positions chosen for accurate integration. Zonal order `KM` is 0 through 21 and its local index `KMLOC` is `KM+1`. `R.NLEI1` is 25. `KLEI2` counts internal coefficient columns and `KDIM1` is the leading output dimension. Every order has all six configurations below.

| Output fields | Wind fields | Scalar fields | Scalar derivatives | Internal columns | Output leading dimension | Keep vorticity | Keep divergence |
| ---: | ---: | ---: | ---: | ---: | ---: | --- | --- |
| 1 | 0 | 1 | 0 | 2 | 2 | No | No |
| 2 | 1 | 0 | 0 | 8 | 4 | No | No |
| 19 | 0 | 19 | 0 | 38 | 38 | No | No |
| 116 | 19 | 20 | 20 | 232 | 232 | Yes | Yes |
| 38 | 19 | 0 | 0 | 152 | 76 | No | No |
| 97 | 19 | 20 | 20 | 232 | 194 | No | Yes |

All genuine calls select the standard Gaussian route with `LATLON`, `S.LDLL` and `S.LUSEFLT` false. No optional Fourier callback is present. The mapped latitude route, butterfly route and arbitrary callbacks are outside this revision.

First prepare degree coefficients through `PREPSNM`. Set degrees `0:KM-1` to positive zero. For degree `j` from `KM` through `NTMAX+2`, copy the raw FP64 value at `F.REPSNM(D.NPMT(KM)+KMLOC-KM+j)`. FP64 is the 64-bit floating-point format. Retain all copied diagonal and padding values.

Pack spectral fields through `PRFI1B`. Let `count=NSMAX+1-KM` and `base=D.NASM0(KM)`. For `j=1:count`, copy the real and imaginary pair at `base+2*(count-j)` into row `j+2` and the next two field columns. The selected field maps are absent, so packing uses field order without an extra map. Set rows 1, 2 and `count+3` to positive zero. Other internal rows are unconsumed unless a later declared calculation writes them. This step performs no floating-point arithmetic.

Internal columns hold vorticity, divergence, eastward wind, northward wind, scalars and scalar derivatives in that order. Their widths are `2*KF_UV`, `2*KF_UV`, `2*KF_UV`, `2*KF_UV`, `2*KF_SCALARS` and `2*KF_SCDERS`. Form both winds through unchanged accepted `VDTUV` equations before scalar packing. A present `PSPSCALAR` uses ascending field order. Otherwise append `PSPSC2`, each plane of `PSPSC3A`, in ascending plane order. `PSPSC3B` is absent in this revision. The genuine alternative route has one two-dimensional field and 19 fields in one `PSPSC3A` plane.

When derivatives are requested, `KF_SCDERS` equals `KF_SCALARS`. Apply the unchanged accepted `SPNSDE` equation to the scalar block. Output count is `(2+LVORGP+LDIVGP)*KF_UV+KF_SCALARS+KF_SCDERS`. Start the transform at column `1+2*KF_UV*(NOT LVORGP)+2*KF_UV*(NOT LDIVGP)`, then include exactly `2*KF_OUT_LT` columns.

Call accepted `LEINV` revision 2 on both parity halves. Parity means whether a latitude pattern changes sign across the equator. Reconstruct all 16 northern latitudes in ascending stored degree order. At order zero, use real columns only and reset imaginary values to positive zero. Then `ASRE1B` forms northern `A+S` and southern `S-A` values, and scatters both into the complete `FOUBUF_IN` owner through the source process and wave maps. Every child retains its accepted equations, arithmetic order, rounding points and physical limits.

## Complete Interface

The GNU Fortran application binary interface, or ABI, passes 17 ordinary addresses. The first eight point to four-byte integers for order, local order, output field count, wind count, scalar count, derivative count, internal column count and output leading dimension. The remaining addresses select optional vorticity, divergence, scalar, two rank-three scalar carriers, one rank-two scalar carrier, two integer field maps and a function address. Preserve absent arguments as null. Rank-one, rank-two and rank-three descriptors have 64, 88 and 112 bytes. They record data address, offset, kind, rank, span, strides and bounds.

Read complete source records `F`, `R`, `D`, `S` and `G`, with sizes 728, 56, 2584, 120 and 208 bytes. `source-qualified-descriptors-r1.json` records component positions from an original Fortran type query. `S.FA` has 22 elements of 744 bytes. Preserve its complete owner and selected element alias. The selected element's two accepted matrix descriptors supply the declared reconstruction.

Retain every complete spectral owner, allocated transform array, descriptor, ordinary scalar, selected basis table, output owner and source-global carrier from the genuine packet. `FOUBUF` remains unchanged on this route. Cloning must preserve every observed overlap and descriptor bias. Rebase only source-qualified pointers, then restore original pointer bytes before comparison.

Every copied coefficient, field map entry, degree-table index, latitude index, process index and packed output interval must fit its captured owner. Consumed numerical cells and produced values must be finite. Selected Fourier output intervals must be disjoint and fit `FOUBUF_IN`. Require enough internal columns for the selected view and enough output rows for all fields. All selected coefficient carriers have contiguous fields, 506 coefficient columns and lower bounds of one. The rank-three carrier has exactly one plane. The 132 packets retain the exact supported ordinary bounds and aliases.

Preserve `x18`, required saved integer and SIMD registers, the return address and 16-byte stack alignment. The source-only bridge isolates the original source's ABI behaviour. The native parent preserves the raw ABI directly and retains both original profiling calls when `LHOOK` is true. Isolated replay disables external `DR_HOOK` because its process lacks the forecast runtime. The separate source forecast retains actual profiling and completes normally.

## Arithmetic and Checks

Use round-to-nearest with ties to even, gradual underflow and signed zeros, with Arm FPCR zero. Preserve accepted child arithmetic order. Forbid fused multiply-add, contraction, reassociation, fast-math, approximate division or square root and reduced precision. The parent owns degree preparation, packing, internal allocation, child calls, final scatter and cleanup. An evaluation driver must supply no omitted numerical stage.

The independent composed verifier begins with exact binary inputs and reconstructs every selected field in 110-digit arithmetic. It applies accepted wind, derivative, Legendre and hemisphere equations through an independently written field map. For a sum, propagate both input error bounds and add half of its FP64 output spacing. For a product, propagate `abs(a)*error_b+abs(b)*error_a+error_a*error_b`, then add half of its output spacing. This accounts for each unfused rounding point. A `1e-100*max(abs(exact_value),1)` margin accounts for decimal-control precision. All relations pass, with largest error 0.782 of this bound. Identical basis bytes reuse the accepted Gaussian-grid and normalised Legendre-table proof.

Canonical output is every returned owner in captured order, including metadata, immutable bytes and inactive Fourier cells. Encoding is the retained little-endian layout. Require zero differing bytes against the complete declared source, and exact immediate FPCR, FPSR and error indicator agreement. Hashes identify artifacts and do not replace raw comparison.

Complete source replay passes 132 packets, 203,008,784 whole-owner bytes and 111,319,824 immutable bytes with zero differences. All aliases, immediate machine status and saved ABI pass. The declared unfused Legendre source is visited 132 times. Independent composition passes 384,384 output relations and 2,301,936 basis contributions, plus raw packing, explicit zeros, field identities and complete Fourier output bytes. The original-only forecast completes 1,144 parent calls, and ten saved files match the wind source reference across 618,140 bytes.

The complete native parent now owns preparation, packing, allocation, private child calls, scatter and cleanup. It calls accepted assembly children through separate entry names and uses C library allocation only for storage. It sets newly allocated, unconsumed private scratch to positive zero while preserving every declared external output byte. Each local descriptor includes its stored bias so that its first logical cell is its first data address. This preserves the different accepted child descriptor conventions.

Native replay passes all 132 packets and all 203,008,784 complete owner bytes with zero differences, exact immediate machine status and raw ABI preservation. Four fresh-status source/native pairs cover empty and inherited floating-point flags and error indicators. Nine unsupported control or bound cases reject before any declared owner byte changes. A complete normal relay also passes all 132 packets with the existing accepted provider order. Its source shadow uses only the qualified source children, and its primary returns the native result. Child visits, immutable owners, metadata and alias offsets are checked separately. The source physics proof and unchanged child numerical proofs are reused.

The complete forecast passes 1,144 direct parent calls and 3,074,651,888 complete caller-buffer bytes with zero differences, including 1,660,659,440 immutable bytes. Every call preserves the raw ABI and matches immediate FPCR, FPSR and error indicator status without masking a flag. Actual profiling is enabled in all 1,144 calls. Each private numerical child visit matches its separate source comparison count. All ten saved files match the unchanged reviewed wind and unfused-transform reference across 618,140 bytes. These results cover this configured transform and its saved outputs. The forecast still uses other Fortran routines, and independent physics of the complete forecast remains open. No timing or speed claim is made.
