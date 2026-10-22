# Operational Vertical Configuration Intake

This child reads the first selected `NAMCVER` text group and returns the six integer controls required by the [operational vertical context](vertical_startup_context.md). It supports the actual 137-level input and equivalent assignments within the syntax below. It does not open a file, allocate storage or initialise a numerical owner. The existing empty-group parser and its callers remain unchanged.

## Interface And Storage

The entry `md2asm_parse_operational_vertical_configuration` receives the text address in `x0`, its byte count in `x1`, four read-only geometry controls in `x2`, and six writable output controls in `x3`. An `int32` is a four-byte signed integer. The geometry input is four `int32` words: level count 137, ECMWF mode 1, nonhydrostatic mode 0 and two-dimensional mode 0. These are explicit caller inputs. The output contains these four words followed by `NVSCH=3` and `LVFE_GWMPA=1`.

The text contains 1 to 262,144 readable bytes and does not need a terminating zero byte. The geometry input occupies 16 readable bytes, and the output occupies 24 writable bytes. Both integer buffers must be eight-byte aligned. The three complete ranges must be disjoint, and each address plus its required extent must not wrap. Adjacent ranges are permitted. The caller owns all buffers and keeps them live for the complete call.

The entry returns zero in `w0` after publishing all six words, or two on refusal. It checks pointers, extents, overlap, geometry controls, text and selected control values before the first output store. A refusal preserves the complete output before-image. It also preserves the text and geometry input on success.

The Arm 64-bit application binary interface defines the argument and preserved registers. The entry preserves `x18`, all callee-saved registers, the floating-point control register `FPCR`, the sticky arithmetic-status register `FPSR`, and `errno`. It uses only integer instructions and local helpers, with no external service. Its 160-byte, 16-byte-aligned frame contains saved registers in bytes 0–95 and nine private assignment words in bytes 96–131; bytes 132–159 are padding. It does not change the incoming floating-point mode.

## First-Group Selection

The original `POSNAM` delegates to `POSNAME`, which reads 40-character records, requires an ampersand within the first ten columns, then searches that record for the uppercase group name. This child accepts a strict subset: `&NAMCVER` must be the first nonblank token on its line and start in columns 1–10. Spaces and tabs each count as one input byte. The next byte must be whitespace, a comma, a slash or an exclamation mark. The actual input starts in column 1; a separate source case starts in column 2.

Before selecting a group, any uppercase `&NAMCVER` prefix in an unsupported position or with an unsupported suffix causes refusal. This includes ambiguous occurrences in preceding text or comments. The parser therefore does not skip an earlier unsupported occurrence and substitute a later group. Lowercase and mixed-case group names do not select a group, following the original uppercase lookup.

The selected group ends at its first slash outside a line comment. An exclamation mark begins a comment that continues through the next line break. Later groups are ignored after a successful first group. A missing terminator, unknown key or invalid value in the first group causes refusal, even if a later group is valid.

## Supported Assignments And Source Resets

Keys are case-insensitive scalar assignments of the form `key=value`. Spaces, tabs, line breaks and commas separate assignments. Logical values accept `T`, `F`, `TRUE`, `FALSE` and their dotted forms, without case sensitivity. Integer values accept an optional sign followed by decimal digits, with checked `int32` bounds. Repeated keys within the selected group use the last assigned value. Arrays, repeat counts, expressions, quoted values and other keys are outside this interface.

| Key | Type | Source default |
|---|---|---:|
| `LVERTFE` | Logical | 1 |
| `NVSCH` | `int32` | 0 |
| `LVFE_GWMPA` | Logical | 0 |
| `LVFE_GW` | Logical | 0 |
| `LVFE_Z_TERM` | Logical | 0 |
| `LVFE_X_TERM` | Logical | 0 |
| `LVFE_LAPL_BC` | Logical | 0 |
| `LVFE_LAPL` | Logical | 0 |
| `NDLNPR` | `int32` | 0 |

The source is `YOMCVER::SUCVER_GEOM` in `arpifs/module/yomcver.F90`. On the selected hydrostatic path it resets `LVFE_Z_TERM`, `LVFE_LAPL` and `LVFE_LAPL_BC` to false. With finite elements enabled it also resets `NDLNPR` to zero. The parser validates these assignments before applying their reset effect. Their text values may therefore differ without changing the final source configuration.

Success requires final `LVERTFE=1`, `NVSCH=3`, `LVFE_GWMPA=1`, `LVFE_GW=0` and `LVFE_X_TERM=0`. These controls retain the qualified type-3, order-4 numerical route. Other final configurations cause refusal. In particular, the new child does not treat an empty group as the operational configuration.

The six-word result reconstructs the complete source configuration: begin with the zero-owned 216-byte `TCVER` record, apply the [qualified default constructor](vertical_coordinate_configuration.md) for inputs 1, 0 and 0, then set its `NVSCH` word at byte 24 and `LVFE_GWMPA` word at byte 104. Every remaining source-reset control agrees with that complete record. Source-unwritten bytes retain their declared zero before-image; this parser does not grant permission to discard other controls.

## Completed Checks And Limits

The actual first-group source result is reused. Two additional genuine source calls check equivalent mixed syntax with repeated keys and hydrostatic resets, and a final `LVFE_X_TERM=1` configuration that this context cannot represent. The unchanged original numerical object supplies those records. Its natural input status is `FPCR=0`, `FPSR=0`, `errno=0`; verification file transport has a separate exit with `errno=777`. The original platform-register exception is retained separately from native acceptance.

One native eight-call packet passes with all ABI masks zero and exact seeded status. The actual and equivalent texts produce 48 decoded output bytes and reconstruct 432 complete source-record bytes with zero differences. Six refusals preserve the complete output: an unsupported control, unterminated text at a protected page boundary, an unknown first-group key before a later valid group, integer overflow, an invalid logical token, and overlapping output and input owners. All 11,610 observed text bytes, input controls and caller guards remain unchanged. The protected page checks the declared readable bound; it does not expand caller permissions.

The native object calls no original OpenIFS provider or library. The previous empty-group parser, numerical children and context evidence are reused without rerunning them. This acceptance covers the bounded raw text child, not the complete Fortran namelist language, a file-reading adapter, enclosing startup or an operational forecast.
