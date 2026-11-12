# Initial Surface Field Reader

This direct assembly reader loads the frozen coarse model's surface input file. It returns every decoded record in file order, including all twelve months of six climatological fields. Climatology describes typical seasonal conditions. Parameter, level, date and time identify each record, so equal parameter names from different months remain distinct.

## Interface

The entry is int md2asm_read_initial_surface_fields(path, values, values_bytes, metadata, metadata_bytes, messages_read). The six machine arguments use registers x0 through x5. This application binary interface, or ABI, preserves the same register and error rules as the [spectral reader](initial_spectral_field_reader.md) and [upper-air reader](initial_upper_air_field_reader.md).

| Output | Frozen shape | Minimum bytes |
| --- | --- | --- |
| values | 140 records of 2,048 consecutive FP64 values | 2,293,760 |
| metadata | 140 rows of five signed 64-bit integers | 5,600 |
| messages_read | One unsigned 64-bit completed-record count | 8 |

FP64 is the 64-bit floating-point format. Each metadata row is parameter, level, count, dataDate and dataTime. Dates use year-month-day digits, and times use hour-minute digits. The file contains 72 monthly records for parameters 18, 17, 16, 15, 66 and 67. Their dates run from 99990115 through 99991215. The remaining 68 records retain their individual dates and times.

All output pointers must be nonnull, aligned to eight bytes, large enough and mutually disjoint across their fixed spans. Their addresses must not wrap. The path must be a readable zero-byte-terminated string and may overlap output storage because fopen consumes it before any output write. The caller must provide mapped storage. Capacity beyond the fixed spans is untouched.

The reader requires FPCR zero. FPCR controls floating-point execution, and FPSR records floating-point status. Both and errno are restored on return. The 224-byte frame has 16-byte alignment. Registers x18 through x30 and the vector register parts required by the Arm ABI are preserved.

## Frozen File Boundary

Each message must match its frozen parameter, level, date, time and count before its values are decoded. Each grid must have Ni 64, Nj 32, Gaussian N 16 and scanningMode zero. These labels define 64 longitude points on each of 32 Gaussian latitude rows, in the original file order. No sorting or geographical interpolation occurs.

The assembly passes the original missingValue setting of -9999 to the C ecCodes library. The frozen file has 25 bitmap records and no missing values. The decoded numbers retain the file-format library's exact output bits. The assembly owns file opening, record traversal, label checks, buffer placement and cleanup, using only libc and the ecCodes C interface.

| Return | Meaning |
| --- | --- |
| 0 | All 140 records and clean end of file accepted |
| 1 | Invalid arguments or nonzero FPCR |
| 2 | File open failed |
| 3 | Codec, read or handle-release failure |
| 4 | Unexpected record identity, grid, count or file length |
| 5 | File close failed after an otherwise successful read |

Code 1 changes no output. The completed-record count is zeroed after fopen consumes the path, including an open failure. Later failures retain the completed prefix. The current value record may have changed if decoding or handle deletion fails, while its metadata and count are committed only after successful deletion. Cleanup preserves an earlier error and releases each held handle and file once.

## Relation To Original Setup

The original SUGRIDF route calls SUGRIDG, which asks GRID_IN for selected surface parameters. GRID_IN initially keeps the first matching parameter and requested level. It does not average the twelve monthly messages. For these frozen records, the first member of each monthly series is January. The original run consumes 139 records before its requests are satisfied, while this raw reader retains all 140.

The original extra climatology route SUGRCLIA is inactive in the selected setup because LCANARI is false and NFPCLI is zero. Its general time interpolation is a separate numerical operation. MODGRINML also performs separate physical conversions and bounds after decoding, including gravity and water-density scaling, land and sea assignments, snow bounds, vegetation-dependent water capacity and lake bounds. These operations remain required assembly work for complete initialisation. This reader performs none of those physical calculations, and no verifier or driver supplies them.

## Acceptance

All 2,293,760 decoded value bytes and 5,600 metadata bytes match the separate C ecCodes reference. Nine focused cases cover the real file, short buffers, changed date or time, changed grid order, swapped records, an extra record and truncation. Three seeded native ABI paths pass, with protected bounds and unchanged numerical status. The revised shared body also passes the retained eleven spectral cases and five upper-air cases, including their ABI checks. Detailed receipts remain local. This component does not establish an autonomous forecast or change audited routine counts.
