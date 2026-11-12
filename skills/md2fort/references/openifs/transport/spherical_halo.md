# Spherical Boundary Contract

Revision 1 implements the complete SLEXTPOL entry from the [physics note](../../../../../formulations/openifs/transport/spherical_halo.md). It fills mirrored pole rows and periodic longitude stars from the supplied physical grid, while preserving the field-selection modes and optional demand mask.

## Grid And Updates

Intersect the local north and south halo extents with the supplied global extrapolation rows. Reflect a northern global row g to 1 minus g and a southern row g to twice the number of physical latitudes plus one minus g. Convert both to local row indices with the supplied first-row offset.

For every local longitude, wrap its global index with the original integer remainder and determine the destination and matching reflected-row buffer positions. Use the reflected source when it belongs to the local core interval. Otherwise retain the communicated destination as the source. Mode one copies every core-sourced field and then multiplies the destination by its parity. Modes two and three freeze the destination and chosen-source indices for the row before applying field updates. Mode two updates fields outside the fixed interval, while mode three updates the interval itself. Preserve ascending row, field and point order. Mode one traverses pole points before fields, while modes two and three traverse fields before the frozen point pairs.

After pole treatment, complete rows receive periodic star values. Width two has one extra western value and two eastern values. Width three has two western values and three eastern values. Preserve the original individual copy order. The same field-selection mode applies to these copies. An optional mask is first cleared over the first buffer-size elements for every mode. Mode three then marks the chosen pole sources and periodic star source points. Preserve the remaining mask tail.

## Interface And Bounds

The eight-address Arm application binary interface receives TDIM, SL_STRUCT, field count, the two fixed-field endpoints, mode, parity, field buffer and an optional mask. Field storage is an eight-byte aligned contiguous FP64 matrix with buffer positions varying first. Parity is a contiguous FP64 vector. The mask and grid maps contain four-byte integers. SL_STRUCT arrays are genuine contiguous allocatables with their original lower bounds and offset, rather than entry-array descriptors. Reuse the accepted SL_STRUCT size, buffer-size offset and first-row offset; probe only the newly consumed members.

Support widths two and three, modes one through three, one through 4096 fields, positive buffer size through 262144 positions and bounded global/local latitude maps through 512 rows. Complete physical rows have at least four longitudes. All accessed mapped positions, star positions and chosen sources fit their owners. For a complete periodic row, its zero-based core offset is at least width minus one, and its offset plus the longitude count plus the width is at most the owner length. The first and last physical owner elements are valid destinations. Partial and empty rows need no periodic star space. Pole rows validate their actual computed source and destination positions. Longitude starts are positive and normalised within one full row. Reflected rows have the same longitude count. Mode one ignores the fixed-field endpoints, whose values may be undefined in the original caller. Validate the fixed interval only in modes two and three, where the first endpoint is at most the last endpoint plus one. Equality defines an empty interval and skips all mode-three field writes. The optional mask is either absent or owns buffer size plus twice the width. Metadata, parity, fields and mask are disjoint, except for the intended ordered in-place field copies.

Preserve signed zeros, subnormals, nearest-even FP64 arithmetic, the floating-point control register and Arm saved registers. The eight addresses occupy x0 through x7 in the order stated above, with no incoming stack arguments. Restore x19 through x29 and the return address, preserve the low 64 bits of v8 through v15, and keep the stack aligned to 16 bytes. The body uses a 256-byte fixed frame and a temporary integer-pair workspace of round-up-to-16 of eight times the buffer size, at most 2 MiB. Return the stack to its incoming position on every exit. Parity multiplication is the only floating-point calculation. Use no fused, approximate or numerical helper operation. Timing hooks lie outside the numerical outputs.

## Acceptance

Before emission, check the complete original against independently derived spherical reflection, field parity and cyclic longitude identities. Derive expected source points from physical row coordinates and Euclidean modulo, separate from the source integer calculation, and require every mask bit and untouched field byte. Include both poles, partial reflected core ownership, modes and widths, selected and empty intervals, signed zeros, subnormals and absent masks.

The direct body must then return zero differing bytes over the full field and mask owners, preserve protected metadata and bounds, and pass the immediate eight-address ABI and FPCR check. A paired adapter compares complete original and native returns on the same inputs. Actual forecast acceptance and timing are later gates.

The original passed the independent geometry check before assembly emission. The native gate then passed 912 protected calls, 77,583,408 returned field and mask bytes, and 1,675,072 independent coordinate and parity relations with zero differing bytes. It included 4096 fields, 512 rows and the maximum buffer size, and preserved 2,389,392 protected input bytes. The paired adapter smoke passed 180 small calls, 555,840 returned bytes and 9,216 relations with zero differences. The full gate supplies coverage evidence for unchanged arithmetic, so future adapter smoke runs need only their specific owner cases. Comparative timing remains open.
Forecast calls exposed two adapter assumptions about unused fixed-field endpoints and periodic boundary padding. The corrected adapter follows only consumed source accesses. The captured genuine first call then passed one protected replay over 11,486,104 returned bytes and 168,532 independent geometry relations with zero differences, including an immediate ABI check. Its paired replay passed the same bytes. The numerical body and its 912-call full gate remain unchanged.

## Actual Forecast Acceptance


| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| slextpol | 25 | 287,152,600 | Complete routine owners |

Shared saved-file evidence and its limits are in the [coverage record](../../../../../src/openifs/README.md#shared-coarse-forecast-evidence).
