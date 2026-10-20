# Surface Field Unit Scaling

This direct assembly child implements only MODGRINML's first scaling stage, source lines 140–186. The [physical input](../../../../../formulations/openifs/input/surface_field_unit_scaling.md) states the unit changes. The later land, sea, snow, vegetation and lake adjustments belong to the [complete conversion parent](surface_initial_state_conversion.md).

## Interface

The C-compatible entry is int md2asm_scale_initial_surface_fields(field2d, bytes2d, field3d, bytes3d, parameters, parameter_bytes, constants, constant_bytes). Its eight arguments use registers x0 through x7. The application binary interface, or ABI, defines these arguments and the register obligations.

| Buffer | Frozen representation | Minimum bytes |
| --- | --- | --- |
| field2d | In/out FP64, Fortran shape (2048, 47) | 770,048 |
| field3d | In/out FP64, Fortran shape (2048, 5, 5) | 409,600 |
| parameters | 47 two-dimensional then five layered signed 32-bit codes | 208 |
| constants | Read-only FP64 gravitational acceleration, water density | 16 |

The two field pointers and constants must be eight-byte aligned. Parameters must be four-byte aligned. All pointers must be nonnull, with nonwrapping consumed spans and sufficient mapped storage. Each mutable field span must be disjoint from the other field and both immutable spans. The two immutable spans may overlap. Extra capacity is untouched.

The coefficients must be the original finite positive FP64 input words, with units m/s² and kg/m³. The supported field values are finite FP64 numbers, including signed zeros and subnormal numbers. FPCR, the floating-point control register, must be zero. This selects round-to-nearest with ties to even and gradual underflow. Return 0 means success, 1 means an invalid buffer contract, and 2 means a nonzero FPCR. Rejection precedes every output write and floating-point operation.

## Original Parameter Rules

| Parameter code | Two-dimensional factor | Layered factor |
| --- | --- | --- |
| 173, 244, 160 | Gravity | Gravity |
| 198 | Water density | Water density |
| 141, the legacy single-layer snow code | One | Water density |
| Every other code, including multilayer snow 228141 | One | One |

Each output is one FP64 multiplication of the selected coefficient by its incoming value. The multiplication by one is retained. There is no contraction, reassociation, division or approximation. Each field value is independent at this stage, so storage traversal does not alter an arithmetic dependency or reduction. The helper uses scalar FMUL with no floating-point child or high-level numerical fallback.

For zero-based point $`p`$, level $`l`$ and field $`f`$, the two-dimensional word index is $`p+2048f`$ and the layered word index is $`p+2048(l+5f)`$. Every one of the 147,456 stored values is multiplied once, covering all 1,179,648 mutable bytes.

The leaf uses no stack or external call and preserves x18 through x30, d8 through d15 and all untouched vector registers. It uses d0 and d1 as floating-point scratch and x0 through x17 plus integer flags as scratch. FPCR and errno are unchanged. FPSR, the floating-point status register, retains incoming flags and gains exactly the events from the prescribed multiplications. The enclosing caller must preserve that updated status through subsequent observation.

## Acceptance

The local candidate passes ten focused cases with complete-buffer and immediate status agreement against the separate source-stage control. Three seeded native ABI paths pass, with immutable inputs and protected bounds retained. Independent exact products check 624 rounded unit conversions, including signed zeros and subnormal inputs. The selected actual packet uses gravity 9.80665 m/s² and water density 1000 kg/m³. The actual complete fields also match the separate source-stage control, with fresh numerical status and a zero native ABI mask. The parent reproduces all actual returned MODGRINML field bytes. Independent source and interface review passes. The joint native forecast passes all 27,486,113 bytes in 685 complete final owners and all 618,140 bytes in ten saved files, with matching immediate status and positive direct input counters. This child supplies no later MODGRINML adjustment and does not establish complete autonomous initialisation.

The [complete GPU surface implementation](../../../../md2asm-gpu/references/openifs/input/complete_surface_initial_conversion.md) combines the required scaling and conversion in one launch while preserving these fields, arithmetic and public buffer rules. Its contract records the changed transport checks and the retained independent physical evidence.
