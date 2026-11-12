# Operational Upper-Air Initial-State Placement

This assembly places decoded upper-air values into the nine-field model buffer for 137 atmospheric layers. It implements the selected assignments in OpenIFS `SUGRIDUG`, lines 243–264. Placement changes storage only. It does not change units, interpolate values or perform a physical time update. The original routine remains a separate reference.

## Fields and Order

The [operational reader](operational_gridpoint_field_readers.md) supplies 959 records, each with 6,599,680 values. The first 274 records alternate humidity and ozone at each level. The remaining 685 records contain rain, snow, liquid water, ice water and cloud fraction at each level. Levels increase from 1 through 137 within each group.

| Model slot | Field | Parameter code | Action |
| --- | --- | --- | --- |
| 1 | Humidity | 133 | Copy values |
| 2 | Liquid water | 246 | Copy values |
| 3 | Ice water | 247 | Copy values |
| 4 | Snow | 76 | Copy values |
| 5 | Rain | 75 | Copy values |
| 6 | Cloud fraction | 248 | Copy values |
| 7 | Ozone | 203 | Copy values |
| 8–9 | Gravity-wave diagnostic fields | None | Write positive zero |

Mass fractions have units kg/kg. Cloud fraction has no unit. The accepted field profiles request all seven named fields from the input, while the two diagnostic fields use their original zero action. Every copied 64-bit word retains its complete bit pattern.

## Interface and Bounds

The application binary interface (ABI) defines arguments and register preservation. The entry `md2asm_place_operational_upper_air_fields` receives six arguments in x0 through x5. Capacities use unsigned 64-bit byte counts.

| Argument | Required extent | Meaning |
| --- | --- | --- |
| x0 | 50,632,744,960 bytes | Read-only decoded values |
| x1 | At least that extent | Value capacity |
| x2 | 38,360 bytes | Read-only metadata |
| x3 | At least that extent | Metadata capacity |
| x4 | 65,099,332,296 bytes | Complete mutable model buffer |
| x5 | At least that extent | Model-buffer capacity |

All pointers must be nonnull and have eight-byte alignment. Complete spans must be mapped and must not wrap. The model buffer must not overlap either input. The two read-only inputs may overlap. Capacity beyond each required extent remains untouched.

Each metadata row contains five signed 64-bit words, giving parameter, level, value count, date and time. Validate the first three against every expected record before the first output store. Date and time are not used by placement and retain their incoming bytes. Return 0 means success, 1 rejects an invalid buffer and 2 rejects unexpected metadata. Rejection leaves the complete model buffer unchanged.

The function is a leaf with no stack frame, child call or floating-point instruction. It uses only x0 through x17 as scratch. It preserves x18 through x30, all vector registers, the floating-point control and status registers, and the library error indicator for every incoming state. The production object has no external dependencies.

## Storage and Padding

The model buffer has Fortran shape 17 × 137 × 9 × 388,217. A block holds 17 horizontal positions. The last block has eight physical positions and nine padding positions. Using zero-based row, level, slot and block indices, the physical point and model word are

```math
p=17b+r, \qquad w=r+17\bigl(l+137(s+9b)\bigr).
```

The seven input fields write 50,632,744,960 bytes at physical positions. Their 69,048 padding bytes remain exactly as supplied by the caller. Zero assignments cover both complete diagnostic fields, including their padding, and write 14,466,518,288 bytes. These extents partition the complete model buffer. All address, stride and byte-count calculations use 64-bit integers.

## Accepted Evidence and Limits

One actual complete input was decoded through the unchanged accepted reader. An independent metadata-driven Fortran control applies the original assignments in block, field and level order, while the assembly traverses input records. Their complete 65,099,332,296-byte model buffers match. Independent checks cover every diagnostic zero and every preserved padding byte. Inputs are protected read-only, and 70,808 guard and capacity bytes remain unchanged.

All four native ABI and status checks pass. Three refusals cover the last metadata record, insufficient model capacity and metadata/output overlap, with the complete output protected against writes. All mappings are released. No unchanged codec bank or full forecast was repeated. Source, interface, build and critical records remain local under `.runtime/`.

This result qualifies raw placement. File loading, field-profile construction, initial buffer creation, diagnostic norms, complete `SUGRIDUG`, full model startup and forecast acceptance remain separate boundaries. The existing coarse placement entry is unchanged.
