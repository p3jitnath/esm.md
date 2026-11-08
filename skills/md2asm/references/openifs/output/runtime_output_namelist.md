# Runtime Output Namelist

`md2asm_parse_runtime_output_namfpc` reads the first `NAMFPC` group from an input buffer. A namelist is a text group that assigns named Fortran settings. This assembly child preserves the operational field and level requests, including the physical parameter identifiers. It supplies configuration data and does not calculate or write forecast fields.

## Interface And Storage

The application binary interface defines how a caller passes arguments and which registers must survive the call. Put the input address in `x0`, its length in `x1` and the output address in `x2`. The input length is from 1 to 262,144 bytes. The output is an eight-byte-aligned, separate 22,608-byte record. Both buffers must fit their declared bounds without address wrap. Return `w0` is zero on success or two for invalid or unsupported input. Every output byte remains unchanged on failure.

The 23,152-byte stack frame includes saved registers and a private output record. The stack remains aligned to 16 bytes. The child preserves `x18`, saved registers, floating-point control and status, and the C library error indicator `errno`. It calls no external service and uses no floating-point instructions.

| Byte Offset | Content | Storage |
| --- | --- | --- |
| 0 through 32 | Seven three-dimensional field counts, the two-dimensional count and physical-field count | Nine 32-bit integers |
| 40 | `CFPFMT` | Eight space-padded bytes |
| 48, 52, 56 | `NFPCLI`, `LFPQ`, `LTRACEFP` | Three 32-bit integers |
| 64 | `RFPCORR` | One 64-bit floating-point value |
| 80, then steps of 1,024 bytes | `MFP3DFS`, `MFP3DFP`, `MFP3DFH`, `MFP3DFT`, `MFP3DFV`, `MFP3DFI`, `MFP3DFF`, `MFP2DF`, `MFPPHY`, `NRFP3S` | Each has 256 integer slots |
| 10,320, then steps of 2,048 bytes | `RFP3P`, `RFP3H`, `RFP3TH`, `RFP3PV`, `RFP3I`, `RFP3F` | Each has 256 floating-point slots |

Unused header bytes and carrier slots beyond an original array's size are zero. The defined source defaults are retained. `MFPPHY` starts at −9999 and `NRFP3S` at −9. Real level arrays start at −9, except potential-vorticity levels at 9,999,000,000 and isentropic levels at −9999. `LFPQ` starts false, `LTRACEFP` true and `RFPCORR` at 2,943 joules per kilogram, the allowed difference in terrain gravitational potential energy per unit mass. The initial format is `GAUSS`, so this selected route requires an explicit `MODEL` format.

## Accepted Inputs

The first seven code families and the physical list permit up to 256 entries. The two-dimensional list permits 212 entries. Active ordinary field codes are from 1 to 686. Active physical identifiers are positive signed 32-bit integers, so identifiers such as `228141` remain intact. The model-level list permits 200 entries, each from zero to 200 or using the source markers −9 and −99. Real-family capacities are 75, 127, 75, 75, 75 and 75 entries in table order. These limits follow the selected source arrays and do not establish support for every future model.

Names are case insensitive. Whole-array lists may use `(:)`, with optional spaces. Logical values may use `true` or `false`, with optional surrounding periods and any letter case. The selected climatology control `NFPCLI` must be zero. Exact integral real spellings, including decimal and exponent forms, preserve signed zero. Indexed sections, repeated-value notation, duplicate keys, unknown keys, missing active entries and incomplete groups are rejected. The caller must check each level's physical range and supply every requested calculation.

## Checks And Limits

A verification-only Fortran control uses the original compiled `TNAMFPL` type and its defaults. Eight cases compare the complete record across 180,864 bytes with zero differences. They include the operational 103 physical identifiers, 137 model levels and 21 pressure levels, changed field selections, all supported families, exact array ends, logical forms and signed zero. Twenty-four focused refusals check malformed sections, unsupported bounds, truncated input, overlap, alignment and address overflow. All 40 observed calls retain their required machine status, and the guarded buffers close successfully.

An independent source and interface review checked the 30-key table, storage bounds, defaults, token delimiters and fresh assembled object. These component checks do not accept a complete output request, field writer or operational forecast. The [source](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/output/runtime_output_namelist.S) is built directly with an assembler and linker. The unchanged [smaller parser](selected_output_namfpc.md) remains available for its qualified callers.
