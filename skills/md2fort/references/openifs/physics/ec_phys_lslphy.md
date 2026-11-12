# Physics Time Interval Controller

This contract freezes the complete `EC_PHYS_LSLPHY` calculation in OpenIFS 48.1.1. The [physical input](../../../../../formulations/openifs/physics/physics_increment.md) describes how supplied rates change wind, temperature and tracers. The controller selects the stored time interval and calls the complete [GPADDSLPHY assembly](gpaddslphy.md). It does not calculate the physical rates or transport the resulting fields.

## Complete Calculation

Let $`d`$ be the requested physics interval in seconds, $`t`$ the model interval in seconds and $`s`$ the stored physics interval in seconds. All three use FP64, the 64-bit floating-point format, and are finite and nonnegative. Compare $`d`$ and $`t`$ numerically. When they are equal, preserve every incoming bit of $`s`$. Otherwise, assign the larger of $`d`$ and one second, using the original comparison and operand selection.

```math
s'=
\begin{cases}
s, & d=t,\\
\max(d,1\,\mathrm{s}), & d\ne t.
\end{cases}
```

Call the complete direct GPADDSLPHY child with $`s'`$. It preserves every state byte on the first transport step. Otherwise, it adds each supplied rate multiplied by $`s'`$, with multiplication and addition rounded separately. Keep the child's ordered tracer mapping, including repeated mappings to the same output. Empty rows and zero levels still retain the controller's time-interval update.

The original profiling hook supplies no numerical stage and is excluded from the native calculation. The direct parent and its private child call no OpenIFS Fortran body. The original remains a separate control.

## Interface And Storage

The native entry is `md2asm_ec_phys_lslphy`. Its application binary interface, or ABI, has fourteen ordinary addresses. Registers `x0..x7` carry geometry, slow-physics settings, general settings, physics settings, first selected column, last selected column, first-step flag and requested interval. Incoming stack slots 0, 8, 16, 24, 32 and 40 carry the wind-u output, wind-v output, temperature output, tracer output, saved wind/temperature rates and saved tracer rates. Integers and logical values use 32 bits, and real arrays use aligned FP64 values.

A storage-only GNU Fortran 12.3 probe measures the general object as 1,556,112 bytes. Its tracer object begins at byte 184, model interval at byte 1,359,528 and integration-settings object at byte 1,359,320. The physics object occupies 160 bytes and stores its interval at byte 8. The geometry, slow-physics, tracer and array layouts are the unchanged qualified child layouts. The general object, geometry, slow-physics settings and input rates remain unchanged. The physics object changes only its eight interval bytes. The selected geometry supports 1 to 4,096 columns, 0 to 512 active levels and at most 1,024 stored vertical entries. Outputs obey every child bound, disjoint-owner and alignment requirement.

Canonical output bytes concatenate the complete physics object, wind-u, wind-v, temperature and tracer owners, in that order. Preserve inactive rows, vertical boundaries, unselected fields, signed zeros and padding. Values are little-endian FP64 and integer words. Use round-to-nearest with ties to even, gradual underflow and FPCR zero, and preserve the caller's FPCR. No fused, approximate or reassociated arithmetic is allowed.

The native parent preserves `x18`, `x19..x29`, the required low halves of `v8..v15`, and a sixteen-byte-aligned stack. Its private child is assembled directly from the unchanged accepted GPADDSLPHY source under a unique internal name. The paired relay checks supported shapes and finite consumed inputs before writing, compares complete owners and returns the unchanged original output.

## Acceptance

Reuse the child's accepted independent physics, exact ordered arithmetic, boundary and ABI evidence. Before parent emission, check the original controller's interval selection and complete owner updates for equal and unequal intervals, the one-second threshold, signed zero, both first-step modes, empty ranges, zero levels, odd and partial columns, and repeated tracer mappings. Use independent 90-digit constant-rate relations and zero differing returned bytes after generation. Check the complete fourteen-address interface through the accepted wider address probe, while extra addresses remain unused. Check inherited floating-point status and errno, protected owner edges and immutable inputs. Native prewrite guards reject unsupported controller settings. The paired relay also rejects unsupported consumed numerical inputs, child mappings and overlapping outputs before either calculation starts. Child buffer bounds remain caller obligations for direct execution. The complete saved-file forecast gate remains separate from small-call acceptance.

## Small-Call Evidence

The original controller passes 22 protected placements and 932 independent 90-digit relations before generation. The complete direct parent then matches all 42,208 output bytes, including first-step, empty, boundary and repeated-tracer cases. The immediate Arm interface probe, fresh floating-point status and errno also agree.

Eight complete paired calls, including an initialised profiling call, match 14,576 bytes and pass 238 independent relations. Thirteen native controller guards preserve 28,288 shared output bytes, and seventeen paired guards preserve 36,992 bytes. The paired relay records the original hook's possible inexact-status bit separately and restores the original status together with the incoming flags. The native numerical status is checked exactly in the original small-call corpus with profiling disabled. This excludes timer arithmetic from the numerical contract while preserving every output bit.

The native parent owns the interval decision and calls the complete private assembly child. The observer provides inputs and compares outputs.

## Actual Forecast Acceptance


| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| ec_phys_lslphy | 2,150 | 43,688,000 | Complete physics settings and prognostic owners |

Shared saved-file evidence and its limits are in the [coverage record](../../../../../src/openifs/README.md#shared-coarse-forecast-evidence).
