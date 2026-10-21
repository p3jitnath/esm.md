# Parallel Convective Columns

This route evaluates the accepted complete CUMASTRN convection model, which describes rising and sinking air in a vertical column. It preserves the original physical model, every separately rounded 64-bit floating-point calculation and all 36 mutable output arrays. The [complete column contract](../physics/convective_column_update.md) defines the original 68 argument addresses and physical checks.

The fast route supports 1 through 32 allocated columns, 4 through 64 vertical levels and at least one selected column. Each of 32 single-thread GPU blocks can process one selected column. Every worker keeps the original allocated column count as the distance between successive vertical planes, so the original array indexing remains valid. Other supported shapes use the original complete serial kernel.

An owner is one complete allocated buffer. Each worker has private copies of the incoming mutable arrays and the complete original numerical workspace. The join checks all completion markers, errors, events and 36 output descriptors before it writes an original output. It copies the first complete private result, then replaces each later worker's selected column in every plane. This preserves the original whole first dissipation plane, which is zero for all columns, and the unchanged incoming bytes of other inactive columns.

Two original decisions depend on several columns. The ascent stage keeps a flag that states whether any selected column enabled shared work. The downdraft stage uses the presence of any enabled column to select a diagnostic update. These decisions use only zero or nonzero integer values. Workers combine them with an integer OR while retaining the original floating-point calculations in each column.

Each decision and vertical level has a fresh 16-byte coordination slot. A worker contributes its Boolean value, then publishes its completion bit. GPU acquire and release operations ensure that a worker reads the result only after every active participant has published its bit. A wait that reaches 200,000,000 GPU clock cycles sets a shared failure word. The join then selects the original complete serial route, with original outputs still untouched. A private numerical error or event also selects that route.

The complete host keeps the original application binary interface, which is the rule for passing arguments and preserving registers. Its only changed call selects the new dispatcher. The dispatcher accepts the same six launch arguments, uses a 1,152-byte stack frame aligned to 16 bytes, and preserves the original registers and host floating-point control around allocation and launch services. The original host still owns input loading, numerical constants, its temporary workspace and final status handling.

| Private storage | Size and role |
|---|---|
| Launch request | Five aligned 64-bit words hold the original vector, arena, arena capacity, route word and copied probe context |
| Probe context | 64 bytes copy the original context, with the new arena used only for its scratch bounds |
| Arena | 64 MiB (67,108,864 bytes), with a 65,536-byte header and one private row per active column |
| Coordination owner | 2,176 bytes inside the header hold the active mask, failure word and 128 decision slots |
| Private row | A 4,096-byte prefix followed by the original numerical scratch requirement, rounded up to 4,096 bytes |
| Largest supported layout | 48,824,320 bytes for 32 columns and 64 levels, within the 64 MiB arena |

The original admission checks run first. A shared admission body also checks the complete added arena and its request, route, original context and original scratch owners against the model's existing buffers. Its ordinary and expanded-owner wrappers preserve their respective interfaces. The minimum original scratch requirement stays unchanged. The added storage has eight-byte alignment, and every private source range must remain inside its worker's scratch allocation.

EXP, FAST and WIDE are the original counters for elementary mathematical work. Their contributions are inside column or scalar-cell calculations, so the join sums them in unsigned 64-bit arithmetic. It updates the three original optional counter owners in their original order. Source floating-point flags combine with OR. The original serial route preserves event precedence when a private worker reports a nonzero event.

Twelve complete calls passed across six accepted physical cases and two guarded memory placements. These include unstable and stable columns, a one-column four-level case, selected subranges and a captured 24-column, 19-level call. All 314,440 canonical output bytes and 17,088,456 complete owner bytes agree exactly, together with physical checks, immediate status, the original ABI and actual counters. Separate controls of the actual Boolean helper passed all-zero, mixed and missing-participant cases. Seven admission-only controls preserve complete buffer before-images and distinguish ordinary bounds from overlaps beyond the original minimum scratch span. These are component results, and do not establish full forecast acceptance or a runtime improvement.

The direct transport is in [convective_column_stages.ptx](../../../../../src/openifs/convection/gpu/convective_column_stages.ptx), [convective_boolean_protocol.ptx](../../../../../src/openifs/convection/gpu/convective_boolean_protocol.ptx) and [convective_parallel_dispatch.S](../../../../../src/openifs/convection/gpu/convective_parallel_dispatch.S). The private numerical entries share unchanged local helpers with their original public providers. Local immutable records retain the accepted source and object identities, the source inverses, the complete checks and the separate publication wiring evidence.
