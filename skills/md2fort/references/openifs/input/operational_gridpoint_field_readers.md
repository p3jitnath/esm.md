# Operational Grid-Point Field Readers

These direct assembly readers decode every surface and upper-air field in the existing 9 km input files. They retain raw field order and units through the public ecCodes library. They perform no physical conversion, geographical interpolation or placement into forecast storage. Original OpenIFS routines and Fortran code are not dependencies.

## Interface And Complete Outputs

The two entries are `md2asm_read_operational_initial_surface_fields` and `md2asm_read_operational_initial_upper_air_fields`. Both use the application binary interface (ABI) `int reader(path, values, values_bytes, metadata, metadata_bytes, messages_read)`, with arguments in x0 through x5 and return status in w0.

| Input file | Records | FP64 value bytes | Metadata bytes |
| --- | ---: | ---: | ---: |
| ICMGGacflINIT, surface | 81 | 4,276,592,640 | 3,240 |
| ICMGGacflINIUA, upper air | 959 | 50,632,744,960 | 38,360 |

FP64 means the 64-bit floating-point format. Each record contains 6,599,680 consecutive values. Its metadata has five signed 64-bit words giving parameter, level, value count, date and time. Dates use year-month-day digits and times use hour-minute digits. The completed-record count needs another eight bytes. All outputs are mapped, disjoint and eight-byte aligned, with no address wrap. Extra capacity is untouched. The path is a readable string ending in a zero byte.

The upper-air file has seven parameters at all 137 model levels. These are humidity 133, ozone 203, rain water 75, snow 76, cloud liquid 246, cloud ice 247 and cloud fraction 248. Each level first supplies its humidity/ozone pair, then a later series supplies the other five fields at each level. The surface schema retains all 81 records, including both land-mask records with parameter 172 and level zero. Dates 20110131, 20260621 and 99990615 stay distinct. No date, duplicate or field is removed.

## Grid Checks And Arithmetic

The grid has 2,560 Gaussian latitude rows. Gaussian rows are the unevenly spaced latitudes used by this model. The longitude count changes between rows, so the decoder checks every row count rather than assuming a rectangular grid. With zero-based row index $`i`$, the accepted count is

```math
n_i = 20 + 4\min(i,2559-i), \qquad 0 \le i < 2560.
```

The complete row list agrees with the independent input-header check. Each message also needs Gaussian parameter N=1280, Nj=2560, scanning mode zero and a missing rectangular Ni value. The public codec receives the original missing-value setting of −9999. These files contain no missing field values. Fixed schemas check parameter, level, count, date and time before decoding. Values remain the codec's exact returned bytes.

The entries share the accepted [initial-field decoder](initial_spectral_field_reader.md). Only their trusted grid selector enters the new reduced-grid validator. Existing entries and their numerical, copy and cleanup bodies remain unchanged. The main frame is 224 bytes and the private validator needs 20,624 bytes for all 2,560 int64 row counts and saved registers. Their nested assembly bound is 20,848 bytes, excluding library stack. Frames have 16-byte alignment. Preserve x18, all required saved registers, FPCR, FPSR and errno. FPCR controls floating-point execution and must be zero on entry. FPSR records arithmetic status. No forecast arithmetic is introduced.

## Returns And Accepted Checks

| Return | Meaning |
| --- | --- |
| 0 | Complete expected file and clean end of file |
| 1 | Invalid argument, capacity or floating-point control |
| 2 | File open failure |
| 3 | Codec, read or handle-release failure |
| 4 | Unexpected labels, grid, count or file length |
| 5 | File close failure after an otherwise successful read |

Argument refusal writes nothing. Later failures retain completed records, with the current value record possibly changed by a failed decode. Metadata and count commit only after successful handle release. Cleanup preserves the first error and releases every held file and handle once.

Both complete files pass against a separate C traversal of the public codec, comparing all 54,909,337,600 value bytes and 41,600 metadata bytes exactly. The reference keeps one field at a time, avoiding a second 50.63 GB output buffer. All ten native ABI checks pass with unchanged FPCR, FPSR and errno. Short capacities, a wrong row list that preserves point count and symmetry, and genuine truncation pass their required refusals. Complete outputs are read-only during refusal checks. All 286,064 guard and padding bytes remain intact, and resource counts balance. Publication compacts repeated schema rows with assembler repetition while preserving every executable byte, read-only data byte and relocation.

The public codec remains an explicit numerical dependency. These checks establish raw decoding and interface behavior. Physical conversions, model-state placement and a complete operational forecast need their own acceptance.
