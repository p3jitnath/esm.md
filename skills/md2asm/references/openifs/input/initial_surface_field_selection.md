# Initial Surface Field Selection

This stage selects raw decoded surface fields before physical conversions. A surface field gives one value at each of 2,048 global grid points. The original SUGRIDG routine first sets its two complete temporary arrays to positive zero, then GRID_IN fills the requested fields in file order. This stage performs those storage operations without floating-point calculations.

## Interface

The entry is int md2asm_select_initial_surface_fields(values, values_bytes, metadata, metadata_bytes, fields_2d, fields_2d_bytes, fields_3d, fields_3d_bytes). Registers x0 through x7 carry these eight arguments in order. FP64 is the 64-bit floating-point format.

| Buffer | Shape or meaning | Fixed bytes |
| --- | --- | ---: |
| values | 140 records, each with 2,048 FP64 values | 2,293,760 |
| metadata | 140 rows of parameter, level, count, date and time, each a signed 64-bit integer | 5,600 |
| fields_2d | Original Fortran shape (2048, 47), with grid points consecutive | 770,048 |
| fields_3d | Original Fortran shape (2048, 5, 5), with grid points followed by snow levels and fields | 409,600 |

Each pointer is nonzero and aligned to eight bytes. Every fixed span must fit without address wrap. Each output is disjoint from both inputs and the other output. The two read-only inputs may share bytes. Capacity beyond the fixed spans remains unchanged. The caller provides mapped storage.

## Ordered Selection

The two read-only request tables in the [assembly source](../../../../../src/openifs/input/initial_surface_field_selection.S) fix the actual original order of 47 two-dimensional fields and five layered fields. The first twelve two-dimensional fields contain four soil temperatures, four soil water contents and four ice temperatures. Lake state, skin temperature, intercepted water and other surface properties follow in the source table. The layered order is snow mass (228141), albedo (32), density (33), temperature (238) and liquid water (228038), each at levels 1 through 5. Albedo is the fraction of incoming radiation that a surface reflects. These sets contain no repeated or shared code. Raw decoded units remain unchanged.

Every input record must contain 2,048 values. For each record in file order, find the first two-dimensional request with the same parameter. Its level is ignored because the original call supplies no two-dimensional level requests. If that output is still missing, select this record and move to the next record. Otherwise try the first matching layered parameter and its requested snow level. Each requested output accepts its first matching record. A successful two-dimensional selection prevents the same record filling a layered output. Date and time remain part of decoder identity but do not change this original selection rule. Selection stops once all 72 requested records are found.

Check the complete metadata count column, every buffer and all selected indices before changing either output. Then set both complete outputs to positive zero and copy each selected record with integer loads and stores. Preserve every FP64 bit, including signed zeros and unusual diagnostic values. Numerical status, errno and all registers required by the Arm application binary interface, or ABI, must remain unchanged. The stack stays aligned to sixteen bytes, and no external function is called.

| Return | Meaning | Output effect |
| --- | --- | --- |
| 0 | All requested fields selected and copied | Both complete arrays written |
| 1 | Invalid pointer, capacity, address span or overlap | No output write |
| 2 | A record has the wrong value count | No output write |
| 3 | At least one requested field is missing | No output write |

## Source And Acceptance Boundary

Source references are arpifs/setup/sugridg.F90, lines 235 through 301, and arpifs/module/iostream_mix.F90, lines 2910 through 2947. The original source first checks a two-dimensional request, then uses CYCLE after a successful assignment before considering a layered request. A separate Fortran reference must reproduce that ordering from metadata rather than use the assembly's selected indices. The separate reference and direct assembly match both complete arrays across 1,179,648 bytes. The same complete bytes match the actual original MODGRINML input packet. Seventeen focused cases pass, covering distinct bit patterns, repeated-month selection, ignored two-dimensional levels, shared read-only inputs, short buffers, metadata, missing fields, output overlap and address limits. Three seeded native ABI paths pass. Protected bounds, complete input bytes and immediate arithmetic status remain unchanged. Detailed records stay local.

MODGRINML performs the following physical conversions and bounds. Those calculations are outside this storage stage and remain required direct assembly work. This component adds no audited weather-routine credit and does not establish a complete autonomous forecast.

The [operational selector](operational_surface_field_selection.md) adds a separate 81-record, 6,599,680-point entry with 50 ordinary fields. Both entries share one integer body with a 288-byte aligned frame. The legacy shape, request identifiers and selection rules remain unchanged, and one focused legacy diagnostic-bit case passes against the independent control.
