# ASRE1B Assembly Contract

Revision 1 implements [Fourier hemisphere reconstruction](../../../../../formulations/openifs/dynamics/fourier_hemisphere_reconstruction.md). The source is `contrib/ectrans/src/trans/internal/asre1b_mod.F90` in the retained OpenIFS source tree. Its complete exported body has five ordinary pointer arguments and no numerical children.

## Method and Arithmetic

For wave `KM`, select latitude indices `max(NDGNH-NDGLU(KM)+1,1)` through `NDGNH`. Use `NDGL=2*NDGNH`, so each northern latitude has a separate southern partner `NDGL+1-JGL`. For each of the `2*KFIELD` real coefficient rows, evaluate one separately rounded `A+S` and one separately rounded `S-A`. These rows hold the real and imaginary Fourier components of the requested fields.

The caller supplies the existing process and wave packing maps. For latitude `j`, its zero-based coefficient offset is `(NSTAGT0B(NPROCL(j))+NPNTGTB1(KMLOC,j))*2*KFIELD`. Store the northern result and then the southern result, in increasing latitude and row order. This body includes the complete reconstruction and scatter. The verification driver supplies no numerical stage.

Use FP64 round-to-nearest with ties to even, gradual underflow and signed zeros, with Arm FPCR zero. Use exact hardware addition and subtraction. Fused operations, reassociation, reduced precision and approximate arithmetic are forbidden.

## Interface and Bounds

The GNU Fortran application binary interface, or ABI, passes pointers to four-byte `KFIELD`, `KM` and `KMLOC` in `x0` through `x2`, followed by 88-byte rank-two `PAOA` and `PSOA` descriptors in `x3` and `x4`. A descriptor records an array address, shape and strides. For these assumed-shape arguments, logical index one starts at `descriptor.data`. Caller lower bounds and the stored descriptor offset do not shift that dummy origin.

The module pointers `R`, `G` and `D` refer to complete immutable objects of 56, 208 and 2584 bytes. Their consumed fields are `R.NDGL@20`, `R.NDGNH@28`, `G.NDGLU@128`, `D.NPROCL@1136`, `D.NSTAGT0B@1264` and `D.NPNTGTB1@1480`. Their allocated array descriptors use the stored offset and lower bounds. The 64-byte module descriptor `FOUBUF_IN` selects the complete returned output owner.

Support `0<=KFIELD,KM,KMLOC<=1024` and `0<=NDGNH<=4096`. The active count must lie between zero and `NDGNH`. Input arrays have positive element strides, enough rows and latitudes, separate columns and aligned FP64 values. The packing vectors have unit strides. The rank-two packing map has positive strides. Every consumed process and wave index must lie within its descriptor bounds. Every packed output interval must be disjoint, fit its full output owner and use nonnegative arithmetic that remains within the original signed 32-bit integer range.

Consumed coefficients and their sums and differences must be finite. Read-only input arrays, their descriptors, maps, metadata and output descriptor must be separate from the complete output owner. Alignment is four bytes for integers and eight bytes for FP64. The caller must establish this buffer contract before execution. The direct body also checks FPCR, scalar and shape limits, consumed map indices and output bounds before any output write, and exits with status 116 when those checks fail.

The assembly preserves `x19` through `x28` and `x29/x30`, does not use platform register `x18` or modify preserved SIMD registers, and keeps its stack aligned to 16 bytes. Its only external failure call is `_exit`. It has no high-level numerical helper.

## Output and Acceptance

The canonical output is the complete little-endian FP64 owner selected by `FOUBUF_IN`, including inactive coefficients and padding. Preserve every returned bit and every immutable owner. Require zero differing bytes against the unchanged original body.

Independent physics checks reconstruct the symmetric and antisymmetric input from the two returned hemispheres. Exact rational arithmetic in the small verifier bounds each addition or subtraction by half of its FP64 output spacing, then propagates those two bounds into the inverse reconstruction. Protected memory checks both buffer ends. Cases include empty selections, partial latitudes, different process maps, padded and strided input arrays, nondefault bounds, signed zeros, subnormal values and wide exponent differences.

The original body passed 86 protected calls, 1,546,576 complete output-owner bytes and 71,216 independent relations before assembly generation. The native and paired versions each passed the same 86 protected calls and complete output-owner comparisons with zero differing bytes. Six calls also checked preserved registers, and five rejected shapes or maps exited before changing 19,240 shared output bytes. No speed claim is made without a quiet-node timing result.

## Actual Forecast Acceptance


| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| asre1b_mod::asre1b | 1,144 | 1,413,992,448 | Complete routine owners |

Shared saved-file evidence and its limits are in the [coverage record](../../../../../src/openifs/README.md#shared-coarse-forecast-evidence).
