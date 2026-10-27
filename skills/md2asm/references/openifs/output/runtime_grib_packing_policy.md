# Runtime GRIB Packing Policy

GRIB is the binary format used for the saved weather fields. This component selects the source packing settings for one field. Packing controls how the field is stored. It does not calculate the field or write a forecast file.

The direct entry is `md2asm_set_runtime_grib_packing` in [runtime_grib_packing_policy.S](../../../../../src/openifs/output/runtime_grib_packing_policy.S). It follows `GRIB_UTILS_MOD` routine `GRIB_SET_PACKING` from `arpifs/module/grib_utils_mod.F90`. Public ecCodes setters and the public Multio bit-count policy remain external services. The [runtime spectral fit](spectral_packing_fit.md#runtime-dimensions) supplies the accepted ordered spectral calculation.

## Interface and Bounds

The first eight arguments use Arm registers x0 to x7. The final two use successive eight-byte slots on the incoming stack. A spectral field stores coefficients of global wave patterns. A grid field stores values at grid points.

| Argument | Meaning and storage |
| --- | --- |
| x0 | Borrowed ecCodes C handle |
| w1 | Nonnegative signed 32-bit parameter identifier |
| x2 and x3 | Level-type bytes and their length from 1 to 32, without a trailing space or embedded zero |
| w4 and w5 | Spectral and gradient switches, each zero or one |
| x6 and x7 | Contiguous finite FP64 field values and their count from 1 to 2,147,483,647 |
| Incoming stack 0 | Signed 32-bit spectral truncation stored in an eight-byte argument slot |
| Incoming stack 8 | Address of six signed 32-bit controls |

The six controls are current simulation index, source linearisation index, log-pressure bit count, expression bit count, forced geopotential switch and forced log-pressure switch. Bit counts are from 0 to 64 and switches are zero or one. FP64 values need eight-byte alignment and the controls need four-byte alignment. All input spans must be mapped, stable, disjoint and nonwrapping. The caller keeps ownership of the handle and all buffers.

Spectral truncation $`N`$ is from 1 to 4,096 and requires exactly $`(N+1)(N+2)`$ values. Grid fields do not consume the truncation. The positive largest finite FP64 value is the source missing-data marker.

## Ordered Policy

Spectral packing preserves the source 16-bit default, model-level log-pressure override, forced half-power cases and gradient switch. The exact fitted exponent is negated and clamped to the source interval from −9.9 to 9.9. The subset truncation is the smaller of 10 and $`N`$ below 213, then 20 from 213 upward. All three subset keys receive that same value.

Grid packing first enables a bitmap when the missing-data marker occurs. Parameter identifiers from 80 to 120 use a positive configured expression bit count. Other cases pass the source-ordered minimum and maximum to the public Multio policy. The implementation preserves separate FP64 operations, rounding points and source setter order.

The entry returns zero on success, a public-service error after a failed setter or policy call, or two for an invalid input before changing the handle. A service failure can leave earlier metadata changes in place. The 256-byte frame is aligned to 16 bytes. The entry preserves x18, the Arm saved registers and FPCR, which must be zero on entry. FPSR and errno retain the effects of the selected operations and public services.

## Accepted Checks and Limits

Eight spectral profiles cover truncations 1, 21, 31 and 213, both forced settings, gradient and level dispatch, and exponent clamping. Four grid profiles cover range policy, a constant field, an explicit bit count and a missing value. All 110,470 encoded message bytes match the separate original Fortran control. Immediate machine state, complete input guards and two prewrite refusals also pass. The grid comparison uses the same initialized public Multio service under its default encoding policy.

This is component acceptance. Operational output fields, headers, time metadata, configured service initialisation, complete file writing and the full forecast remain separate integration requirements. Local source versions, build commands, diagnostics and comparison records remain under `.runtime/`.
