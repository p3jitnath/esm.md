# Physics Context Address Services

These three assembly services read dimensions, return a data address and select field views for one physics block. A view describes existing array storage without copying its values. The enclosing context is the group of records used by the physics driver. These services do not construct or release that context and do not add a forecast calculation.

## Source and Layout

The reference is the original `md2asm_physics_driver_shape`, `md2asm_physics_storage_zero_view` and `md2asm_physics_storage_begin_block` bodies in the retained `temporary_storage_services.F90`. Typed queries from that build establish the complete 119,384-byte context, its embedded 72,696-byte `FIELD_VARIABLES` record at byte 16 and the model offsets. The geometry record occupies 17,096 bytes and the model record occupies 4,275,088 bytes. These offsets belong to the declared retained build.

## Interfaces

| Entry | Inputs | Result |
| --- | --- | --- |
| `md2asm_physics_driver_shape` | `x0` addresses 53 pointer words and `x1` addresses eight 32-bit integer words | Write the eight source dimensions in their original order |
| `md2asm_physics_storage_zero_view` | `x0` addresses the complete context | Return the full 64-bit data address of `PERTL%ZDISSGW` in `x0`, including zero for a null view |
| `md2asm_physics_storage_begin_block` | `x0` addresses the context and `w1` contains the one-based block index | Clone private variable records, then update their block views |

The eight dimensions are points per block, vertical levels, total blocks, total grid points, transported fields, semi-Lagrangian fields, physics tendencies and radiation-call interval. These are counts except for the last value, which uses the original model time-step convention. No conversion is applied.

Pointers require eight-byte alignment and dimension outputs require four-byte alignment. Every complete input record must remain readable for the call. The output shape must not overlap the pointer table or its records. The block index must lie within the accepted field descriptors. The caller owns all numerical buffers. This service creates private variable metadata through the qualified field-array child, and the matching context cleanup must release those private records through that child's reset entry.

The entries follow AAPCS64, the Arm procedure-call convention. They preserve the required registers, `x18`, the floating-point control register, floating-point status flags and `errno`. The block service uses a 64-byte aligned stack frame and calls the accepted direct clone and update children. The two read services use no stack storage. No original Fortran procedure is called.

## Ordered Behaviour

The shape service follows the original eight reads and writes. The zero-view service returns the descriptor's data address at context byte 116,672. The block service completes cloning before it selects views. It uses the qualified field-array contract for complete descriptors, ownership and explicit construction of source-undefined metadata. It does not initialise or alter numerical field values.

## Acceptance

The focused check covers two complete dimension cases, associated and null full-width pointer returns, and three context compositions with empty, mixed and persistent field arrays. It compares each complete context outside the variable record, all source-defined variable metadata and every complete associated view. It also checks unchanged numerical owners, guarded buffer bounds and seven immediate native interface calls. All compared bytes agree. No new floating-point equation requires a separate physical test. Existing numerical child checks remain applicable.

The candidate remains local until its enclosing native forecast route passes the unchanged complete-state and saved-file comparisons. It does not establish an autonomous forecast.

The [complete forecast check](../../../../../src/openifs/README.md#verification) passes for the selected route. Its declared upstream data and branch limits remain in force.
