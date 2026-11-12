# Runtime shortwave aerosol extinction

This [direct AArch64 calculation](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/radiation/runtime_shortwave_aerosol_extinction.S) extends the column count of the original `aerosol_sw_extinction` routine. Shortwave radiation includes visible sunlight. Aerosols are small airborne particles, and extinction describes their effect on a light beam. The component preserves the source's ordered weighted sum. Its conversion to a physical inverse-length value remains unresolved, as described below.

Let $`P`$ be the allocated column count. The entry `md2asm_runtime_shortwave_aerosol_extinction` admits $`1 \le P \le 128`$ and radiation band 10. First and last are one-based active column indices. First is from 1 through $`P+1`$, last is from 0 through $`P`$, and last is at least first minus one. First equal to last plus one gives an empty interval. The earlier 24-column entry remains available. All checked shapes use the same assembled and original reference entries.

The application binary interface, or ABI, passes the following addresses. FP64 means a 64-bit floating-point value. Every complete owner remains live through return.

| Argument | Location | Meaning and complete storage |
| --- | --- | --- |
| 1 | `x0` | Column count, int32 |
| 2 | `x1` | First active column, int32 |
| 3 | `x2` | Last active column, int32 |
| 4 | `x3` | Radiation configuration, 20,040 bytes |
| 5 | `x4` | Radiation band, int32 equal to 10 |
| 6 | `x5` | FP64 shape $`(P,12)`$, with column index varying fastest; $`96P`$ bytes |
| 7 | `x6` | Relative humidity, $`8P`$ bytes |
| 8 | `x7` | Weighted-sum output, $`8P`$ bytes |
| 9 | Incoming stack +0 | Read-only runtime context, 16 bytes |

The context's first word is the common physical-record pointer and remains unread. Its second word points to a 16-byte profiling policy: a pointer to a zero int32, followed by a reserved zero word. Scalar addresses and the flag align to four bytes. FP64 arrays, configuration, context and policy align to eight bytes.

The selected configuration has 12 species, 14 shortwave bands, 18 coefficient types for particles that do not absorb water, 13 types for particles that absorb water, and 12 humidity bins. These table sizes are physical inputs. Their GNU Fortran descriptors store the data address, element size, rank, bounds and strides. Every consumed descriptor requires its declared one-based bounds, contiguous strides and complete span.

| Configuration byte offset | Coefficient backing |
| --- | --- |
| 11608 | Twelve int32 class values |
| 11672 | Twelve int32 type indices |
| 11736 | FP64 table, 14 by 18 |
| 12264 | FP64 table, 14 by 12 by 13 |
| 13736 | Twelve FP64 humidity thresholds |

Class 1 is ignored, class 2 uses the table without water absorption, and class 3 uses the humidity-dependent table. The routine reads a type index only for an active class and reads no unused coefficient table. An empty interval still validates the classes, as the original does, then reads no mixing values, humidity, output, type indices or coefficient payloads. Every consumed span must be aligned and must not wrap around the address range. The complete output must be disjoint from all consumed input, metadata, control, policy and coefficient owners. Read-only inputs may share storage.

For each active column, the sum starts at positive zero. Species follow their original order, with separate FP64 multiplication and addition. Humidity equal to a threshold stays in the lower bin; humidity above the last threshold selects bin 12. An unordered comparison selects the first bin. The original helper's `FCMPE` instruction also raises the invalid-operation flag for a NaN humidity, and the assembly preserves that result. Thresholds must be finite, start at positive zero, increase strictly and remain no greater than one.

The tables state mass-extinction coefficients in square metres per kilogram of aerosol. The selected CLIMAER caller supplies mass mixing ratios in grams per kilogram, but the weighted sum contains no air-density factor. The shown calculation therefore does not establish an inverse-length unit. This component preserves the source arithmetic and checks its weighted-sum equations. It does not insert a density factor or accept the upstream physical-unit claim.

The floating-point control register must be zero, selecting nearest-even rounding and gradual underflow. Fused multiply-add, contraction, reassociation and approximate arithmetic remain forbidden. Success or an admitted empty interval returns zero. Admission refusal returns two before an output store. The entry preserves `x18`, callee-saved registers, 16-byte stack alignment, the control register and errno; floating-point status keeps its natural result. It uses a fixed 512-byte frame, no heap storage, external numerical call or original module storage.

Five pairs against the actual original routine compared 207,372 complete bytes with zero differences. They cover 17 columns with active columns 2 through 16, 9 columns with columns 3 through 9, 24 full columns, an all-ignored case and an empty interval. The saved outputs passed 161 independent weighted-sum, zero-input, single-species, monotonicity and inactive-word checks. Twenty-nine refusal cases preserved their known buffers, and a separate empty case read no poisoned unused backing. Immediate status, register, control, floating-point flag and errno checks passed. Source and result reviews passed, and controller and child identities closed without signals.

This interface and range extension adds no original-routine body to the completion count. The production coefficient-owner connection, CLIMAER caller, active parameterisation branch and full forecast still require joined acceptance. Detailed inputs, original source versions, raw results, exact bindings and process records remain local.
