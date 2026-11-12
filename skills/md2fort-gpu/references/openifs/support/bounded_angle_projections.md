# Bounded Sine And Cosine

Revision 1 defines the [direct PTX source](../../../../../src/openifs/support/gpu/bounded_angle_projections.ptx) for sine and cosine over the complete accepted CPU input interval. The input angle $`x`$ is in radians and satisfies $`\lvert x\rvert\leq 2^{20}`$. Both outputs are dimensionless. Signed zeros and subnormal values, which are very small floating-point numbers, remain supported.

On a unit circle, cosine gives the horizontal coordinate and sine gives the vertical coordinate.

```math
c=\cos(x),\qquad s=\sin(x).
```

The [CPU source contract](../../../../md2fort/references/openifs/support/sin_cos_original_rounding.md) fixes the coefficients, thresholds and ordered arithmetic. The GPU uses the same small-angle approximations and table values. For larger supported angles, it subtracts a calculated number of quarter turns, evaluates the reduced angle and selects the original sign and sine or cosine branch. A quarter turn is $`\pi/2`$ radians. The reduction retains all seven exact product-sum calls and their original rounding points.

Ordinary operations round separately to FP64, the 64-bit floating-point format, with nearest-even ties and gradual underflow. The qualified integer product-sum helper implements each declared single-rounding operation inside these mathematical functions. It does not combine multiplication and addition in the weather equations. Tiny-input paths retain their source-discarded arithmetic because that work can set status flags. All 440 table words are unchanged and stay in read-only initialized global storage.

## Callable Interface

`md2asm_gpu_sin_bounded_finite` and `md2asm_gpu_cos_bounded_finite` each receive one PTX `.param.b64` number word. Their common callable, `md2asm_gpu_sin_cos_bounded`, also receives a 32-bit mode, zero for sine or one for cosine. Each returns one eight-byte-aligned, 32-byte object.

| Byte Offset | Returned Value | Meaning |
| ---: | --- | --- |
| 0 | FP64 word | Sine or cosine result |
| 8 | 32-bit flags | Newly raised Arm-equivalent numerical status |
| 12 | 32-bit event | Zero because these finite paths do not write `errno` |
| 16 | 64-bit FAST total | Executed product-sum calls that use the shorter integer path |
| 24 | 64-bit WIDE total | Executed calls that use the wider integer path |

The pure functions change no global counter or numerical buffer. Returned path totals remain separate from stored counters, whose updates follow the selected caller's source sites. Combine new flags with incoming flags by integer OR, and preserve the incoming C error slot called `errno`. Store arguments immediately before each call and consume its return words immediately afterward.

Each thread owns its parameter storage and temporary registers. The functions need no shared memory, barrier or host launch of their own. The parent supplies the valid input range and complete storage lifetime. Target PTX 8.5 and `sm_90`, assemble with `ptxas -c -arch=sm_90 --fmad=false`, then link the accepted status and exact product-sum objects once with `nvlink`. The [shared mathematical interface](../mathematical_support.md) defines those dependencies.

## Accepted Scope

The retained 32,332 signed angles pass for each function, giving 64,664 calls and 2,069,248 complete result bytes with zero differences. Result words, immediate flags, preserved `errno` and returned helper-path totals agree with the counted CPU observation route. Seeded status, prior error, empty input, meaningful range and storage refusals, and ordinary device allocations also pass.

Independent 170-digit checks cover the same input angles, geometry and accuracy. The largest observed errors are 0.508923 for sine and 0.508538 for cosine in units of the last place, the spacing between adjacent FP64 values. Full source review verifies the reduction, unchanged small-angle core and coefficient words. These component checks do not establish a complete GPU forecast or its runtime. Detailed operands, controls and records remain local.

The algorithm and coefficients derive from GNU libc 2.38's IBM Accurate Mathematical Library, copyright 2001–2023 Free Software Foundation, Inc., under the GNU Lesser General Public License, version 2.1 or later.
