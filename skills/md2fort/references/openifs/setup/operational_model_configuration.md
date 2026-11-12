# Operational Model Configuration

This parent creates the small settings needed by the selected one-hour forecast. The input has 137 layers, 450 seconds per step, eight steps and four processes. The separate process constructor owns the parallel settings. This component owns selected MODEL metadata and small interpolation records. It does not create physical forecast arrays or complete numerical initialisation.

The interface is `int md2asm_attach_operational_model_configuration(MODEL, capacity, FIELDS, Geometry, headers, text, text_bytes, output_slot)`, using x0 through x7. MODEL has 4,275,088 writable bytes, FIELDS has 529,288 writable bytes, Geometry has 20,400 read-only bytes and headers has 9,328 read-only bytes. Text has 1 through 262,144 readable bytes. The output is an eight-byte pointer slot containing zero. All record addresses align to eight bytes. Complete ranges are mapped, disjoint and do not wrap. Capacity covers MODEL, and FPCR is zero.

The stable outer constructors first associate MODEL offset 8 with Geometry and FIELDS offset 1,840 with MODEL. The field namespace at MODEL offset 192, interpolation record at MODEL offset 1,573,768 and motion record at FIELDS offset 1,856 start zero. Headers supply grid dimensions and the date and seconds within the day. Clock construction must produce eight steps before any MODEL mutation.

The parent owns one zero-initialised 67,616-byte configuration record. Zero supplies fresh storage and bytes that the source leaves unwritten. Physical constants, clock inputs, dynamics settings and physics settings are then produced by direct assembly children. Every record that contains pointers is constructed at its final address.

| Configuration offset in bytes | Record or value |
| --- | --- |
| 0, 8, 16, 24, 32 | MODEL, FIELDS, Geometry, lifetime marker, interpolation-owner flag |
| 40, 48 | Source `NSUPERSEDE=1`, borrowed partition after association |
| 64, 584 | Physical constants, forecast controls |
| 52,096, 53,120, 53,144 | Single-column controls, shared output controls, output requests |
| 65,296, 65,320, 65,360 | Physics counts, field side effects, surface controls |
| 65,408, 65,728, 65,768 | Dynamics-core, initialisation and nudging controls |
| 67,592, 67,596, 67,600 | Trajectory value, inactive packing word, terrain controls |

The selected source order is dynamics metadata, time integration, physics controls, trajectory controls, nudging, mass-conservation controls, field dimensions, field registration, motion maps, interpolation declarations, selected dynamics controls and semi-Lagrangian buffer maps. Source routine identifiers remain in the assembly trace. Independent omitted stages are not supplied by this constructor. It establishes nine general fields with seven active physical fields, fourteen main motion fields, three surface motion fields and nine tiles from the live children.

The five physical field counts remain private while the fresh field namespace is constructed. Before publication, each generated count must equal its corresponding physical count. The parent then stores the same bits. This postpones only equal-valued stores that no intervening child reads. The gas descriptor graph stays at its final address. The field side effect `LSPLTHOIGFL` is held at MODEL offset 1,568,800.

The twelve surface controls are layer count, missing-field sentinel, step count, six wave and flux flags, aquaplanet mode, trajectory mode and ECMWF mode. They come from live headers and accepted configuration children. The four terrain words start zero and are explicitly unready. `md2asm_associate_operational_model_partition(configuration, partition)` must run before a terrain consumer. Its two arguments use x0 and x1. It checks matching lifetime markers and Geometry, world size four, the two-by-two wave and vertical split, rank coordinates and completed partition state 3. It reads the vertical-group count at partition offset 36 and group index at 68, then stores them at configuration offsets 67,612 and 67,608. It also borrows the partition at offset 48. Existing association or invalid input returns 2 before writes. Success returns zero. The leaf uses no private frame and preserves registers and machine status.

The packing word remains source-unwritten and unused while coupling output is disabled. A later output stage must supply its actual encoding controls. The configuration cannot be used to infer an experimental packing default.

Success publishes the owner and returns zero. Allocation failure returns one. An entry refusal returns two without changing caller bytes or allocating. A child failure returns `64 + 4*n + child_status`, where `n` is its one-based stage number. The output remains zero, acquired small owners are released, and completed MODEL/FIELDS prefixes can remain. Recreate the stable outer records before retrying a late failure. The parent preserves x18, saved registers, FPCR and natural child FPSR/errno. Its fixed frame is 1,024 bytes, with at most 26,320 bytes including the nested physics frame.

Release receives the writable owner-pointer slot. It releases the two small interpolation parity arrays, frees the configuration and clears the slot while MODEL remains live. It preserves entry machine status and does not free MODEL, FIELDS, Geometry or large fields. Its frame is 112 bytes, plus the 32-byte small-map release frame.

The complete final-address join matches 4,898,696 record and small-owner bytes against an explicit composition of the same accepted children. Source and physical checks of those children are reused. Raw status, aliases, freshness, changed bounds, allocation failure and release pass. The complete loaded-model check also passes on all four live process layouts. Full forecast acceptance remains separate.
