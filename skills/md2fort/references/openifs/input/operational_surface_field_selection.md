# Operational Surface Field Selection

This assembly selects the raw surface values needed by the 9 km model before physical conversion. A parameter code identifies a physical quantity in the input file. The actual configuration requests 50 ordinary fields and five snow quantities at five depths, giving 75 complete record copies. It uses six albedo components and a Charnock surface-roughness parameter. Albedo is the fraction of incoming radiation that a surface reflects. This stage changes storage only and retains every value bit.

## Interface and Storage

The application binary interface, or ABI, defines argument registers and saved state. The entry `md2asm_select_operational_initial_surface_fields` receives eight arguments in x0 through x7. FP64 means the 64-bit floating-point format. Capacities use unsigned 64-bit byte counts.

| Arguments | Complete operational storage |
| --- | --- |
| x0 values, x1 capacity | 81 records × 6,599,680 FP64 values, 4,276,592,640 bytes |
| x2 metadata, x3 capacity | 81 rows of five signed 64-bit words, 3,240 bytes |
| x4 ordinary output, x5 capacity | 6,599,680 × 50 FP64 values, 2,639,872,000 bytes |
| x6 snow output, x7 capacity | 6,599,680 × 5 depths × 5 fields, 1,319,936,000 bytes |

All pointers must be nonnull and eight-byte aligned. Each complete consumed span must be mapped, nonwrapping and within its capacity. Outputs must be disjoint from one another and from both inputs. The read-only inputs may overlap. Extra capacity remains unchanged. Metadata words give parameter, level, value count, date and time. Dates and times remain input metadata but do not select fields. The reader retains the original field units. Physical conversion remains a separate stage.

## Configuration and Selection Order

The actual original configuration selects the first 43 ordinary requests from the [existing field order](initial_surface_field_selection.md), followed by parameters 210186, 210187, 210188, 210189, 210190, 210191 and 148. The six first suffix entries replace legacy parameters 15 through 18. The final entry is Charnock roughness. Snow parameters remain 228141, 32, 33, 238 and 228038, each at depths 1 through 5. Original setup captures independently confirm the complete request order in two profiles. The actual Stokes-wave fields use defaults and add no file request.

Check every metadata value count before output writes. Scan records in file order. Fill an ordinary request from its first matching parameter, ignoring level, then advance to the next record after that assignment. Otherwise fill an eligible snow request from its first matching parameter and depth. Require every requested record before writing. Set both complete outputs to positive zero, then copy the selected records with integer loads and stores. Points are consecutive within each output field. Snow depth increases before the snow-field index.

| Return | Meaning | Output effect |
| --- | --- | --- |
| 0 | Every requested field selected | Complete outputs written |
| 1 | Invalid buffer or overlap | No write |
| 2 | Wrong metadata value count | No write |
| 3 | A requested field is absent | No write |

## Shared Body and Register Rules

The legacy entry `md2asm_select_initial_surface_fields` retains its fixed 140-record, 2,048-point and 47-ordinary-field interface. Both entries use one shared integer body. The original 52 parameter identifiers remain literal, with one additional seven-word operational suffix. Address calculations, spans, field strides and copy lengths use 64-bit integers.

The function has no external call, allocation or floating-point operation. It preserves any incoming FPCR, FPSR and `errno`, x18 through x30 and all vector registers. FPCR controls arithmetic, while FPSR records arithmetic events. The frame has 288 bytes with 16-byte alignment. It contains saved registers, private selected-record indices and three fixed dimensions. The original routine remains a separate verification reference and supplies no production stage.

## Acceptance and Limits

The actual complete input is decoded once through the unchanged accepted reader. An independent C control finds each requested parameter and depth, while assembly scans records in source order. All 3,959,808,000 operational output bytes agree. One focused legacy case also matches all 1,179,648 bytes with diagnostic raw bit patterns, preserving signed zeros and other representations without floating-point interpretation.

All six native ABI/status calls pass. Four refusals cover a wrong final metadata count, a missing request, short capacity and output/input overlap, with both complete outputs protected against writes. Inputs are read-only, 490,872 guard and capacity bytes remain unchanged, and every mapping is released. The pure assembly object has no external dependency. An independent source/interface review also passes. No unchanged codec or physics bank is repeated.

This component supplies raw field selection. Surface conversion, defaults, placement, complete original input routines, full model construction and forecast acceptance remain separate work. Exact source, configuration, build and critical records remain local under `.runtime/`.
