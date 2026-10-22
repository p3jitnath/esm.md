# Initial File Header Contract

Revision 2 reads the first spectral and grid messages from real initial-condition files. GRIB is the weather-file format, and ecCodes is the public C library that decodes it. A regular Gaussian grid has the same number of points in every latitude row. A reduced Gaussian grid can have different row lengths. This component reads their metadata and changes no physical field.

The direct [assembly reader](../../../../../src/openifs/input/initial_model_file_headers.S) follows the selected header reads in `INQUIRE_GRIB` and the metadata assignments in `SUARG`. Production uses only ecCodes and libc. It has no original OpenIFS provider, constructor, module data or model-state packet. Geometry construction, field loading and the forecast remain separate stages.

## Interface and bounds

The interface is `int md2asm_read_initial_model_headers(const char *spectral_path, const char *grid_path, void *record, uint64_t capacity)`. Registers x0 through x3 pass these arguments, and w0 returns the status. Paths are readable C strings ending in zero bytes. The record address is nonnull and aligned to eight bytes. The caller supplies mapped readable and writable storage for the required committed extent.

Let $`R`$ be the number of northern latitude rows. For these grids, Gaussian order $`N`$ equals $`R`$. The full latitude count is $`\mathrm{Nj}=2R`$. The committed extent $`C`$, in bytes, is

```math
C=\max\left(5232,\;8\left\lceil\frac{4208+4R}{8}\right\rceil\right).
```

The multiplication and rounding give room for $`R`$ four-byte row lengths and any final alignment padding. The legacy T21 record remains exactly 5,232 bytes. $`R=1280`$ needs 9,328 bytes. The capacity must be at least $`C`$. Address-wrap checks cover the required span, not unused numeric capacity. Bytes beyond $`C`$ remain untouched.

Spectral truncation $`J`$ is the largest retained wave index and is zero through 4096. The file's combined A/B vertical-coordinate array `PV` has an even count from 4 through 514, giving 1 through 256 layers. Every decoded coefficient must be finite. GRIB editions one and two are accepted through their ecCodes template-number keys: 50 for the spectral message and 40 for the Gaussian grid message.

| Grid route | Supported dimensions | Row conditions |
| --- | --- | --- |
| Regular, `PLPresent`=0 | Gaussian order $`N`$ from 1 through 256 and $`\mathrm{Nj}=2N`$ | A positive signed 32-bit `Ni` supplies every row length |
| Reduced, `PLPresent`=1 | $`N`$ from 1 through 1280 and $`\mathrm{Nj}=2N`$ | Exactly `Nj` positive signed 32-bit `PL` entries, with equal mirrored north and south rows |

For reduced input, the complete `PL` sum must fit a positive signed 32-bit integer and equal `numberOfDataPoints`. `NUDLON` is the maximum northern row length. `NUHTYP` is zero when all northern rows equal the first, and two otherwise. A constant-row reduced input therefore still returns zero. No operational date, coefficient, row length or point total is built into the assembly.

Each file keeps its own date and time. The date identifier is positive and no greater than 99,999,999. Its HHMM clock has an hour from 0 through 23 and a minute from 0 through 59. Forecast hours must convert to nonnegative signed 32-bit seconds. The utility does not require the two file dates to match.

## Output record

All words use the little-endian Arm representation. An `int32` value is a four-byte signed integer. FP64 is the eight-byte floating-point format. Pressure at a layer boundary is A plus the product of B and surface pressure; A is in pascals, while B has no unit. Their decoded bits are copied without arithmetic or unit conversion.

| Byte offset | Value | Representation |
| --- | --- | --- |
| 0, 4 | `NUSMAX` and `NUCMAX`, both $`J`$ | Signed `int32` |
| 8, 12, 16 | `NUDGL`, `NUDLON` and layer count | Signed `int32` counts |
| 20, 24, 28 | `NUHTYP`, `NUSTTYP`=1 and `NGRIBFILE`=1 | Signed `int32` choices |
| 32, 36, 40 | Spectral date, seconds within day and forecast seconds | Three signed `int32` values |
| 44, 48, 52 | Grid date, seconds within day and forecast seconds | Three signed `int32` values |
| 56 | Northern latitude-row count $`R`$ | Signed `int32` |
| 64, 72, 80 | `USTRET`=1, `UMUCEN`=1 and `ULOCEN`=positive zero | FP64 |
| 88 | `NSUPERSEDE`=1 | Signed `int32` |
| 96 | A, capacity 257 values | FP64; only layers+1 values change |
| 2152 | B, capacity 257 values | FP64; only layers+1 values change |
| 4208 | `NULOEN`, the $`R`$ northern row lengths | Signed `int32` |

Reserved words, inactive coefficient entries, inactive row entries and alignment padding retain their caller bytes. The routine stages a before-image of every byte that it can commit. It first copies the legacy prefix, then checks the dimension-derived extent and copies any additional caller bytes before filling the private `PL` tail.

## Failure and resource rules

| Status | Meaning |
| --- | --- |
| 0 | Both headers and all checks complete; both files close successfully |
| 1 | Invalid argument, alignment, required capacity, wrapped span or nonzero FPCR |
| 2 | File open failure |
| 3 | Codec, message creation or handle deletion failure |
| 4 | Unsupported or inconsistent metadata |
| 5 | File close failure after otherwise successful reading |

Every failure leaves all public output bytes unchanged. Checks available at entry run before file calls. The larger capacity check follows the decoded dimensions; an earlier file or metadata failure keeps precedence. Cleanup errors replace success only. Each held message handle and open file is released once. The success counter increments only after complete publication. `md2asm_initial_model_header_count_get()` returns that serial counter, which starts at zero.

The application binary interface requires FPCR zero at entry. FPCR controls rounding and exceptions, FPSR records arithmetic status, and errno is the C library error indicator. The utility restores all three on return. It preserves x18 through x29, the return address, the required lower halves of v8 through v15 and sixteen-byte stack alignment. It performs no floating-point arithmetic itself.

The stack frame has 112 saved-register bytes and 34,240 private bytes. Private offsets [0,9328) hold the staged record, [9328,13440) hold at most 514 FP64 `PV` values, [13440,33920) hold at most 2560 eight-byte C-long `PL` values, and [33920,34240) hold local scalars and saved status. These regions are disjoint and sixteen-byte aligned. No heap allocation, new allocation error or private pointer is added to the public record.

## Checks and limits

The accepted legacy checks compare complete T21 records and preserved tails with the original public `INQUIRE_GRIB` child and `SUARG` assignments. They retain independent file-format and hybrid-pressure checks, protected bounds, malformed inputs, balanced cleanup and native ABI/status checks. The original reference can raise different flags or errno and can change x18; those raw differences remain separate from this utility's preserved-status ABI.

The revision-2 critical packet passes 15 semantic cases, six protected ABI/status cases and the required-span wrap check. All 62,464 complete owner bytes match exactly, including the 9,328-byte operational record, legacy T21 records and preserved tails. All native ABI masks are zero, FPCR/FPSR/errno are preserved, and file counts are balanced. The separate raw-GRIB check and 831 exact hybrid-pressure relations also pass. Deletion and close fault injection were not repeated; their error paths retain the reviewed legacy source. No model, full-field decode or performance measurement forms part of this checkpoint. Header acceptance does not establish operational geometry, complete initial loading or a forecast.
