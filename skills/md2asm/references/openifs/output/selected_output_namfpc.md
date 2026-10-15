# Bounded Output Namelist Parser

`md2asm_parse_output_namfpc` reads the first line-starting `NAMFPC` group from a live byte buffer. A namelist is a text group that assigns named Fortran settings. This child supplies the field and level settings for the selected output preparation route; it does not build an output request or call OpenIFS.

## Interface and storage

The AArch64 interface takes the input address in `x0`, the input length in `x1`, and the output address in `x2`. The input length is from 1 to 262,144 bytes. The output is a separate 5,696-byte record with room for 64 values in each array. The output and input buffers must not overlap. Return register `w0` is zero on success or two for unsupported or invalid input. On failure, every output byte remains unchanged.

The implementation uses a 6,240-byte stack frame, including saved registers, and keeps the stack aligned to 16 bytes. It preserves `x18`, the saved general registers, floating-point control and status registers, and the C library error indicator, `errno`. It makes no external calls and does not use floating-point instructions. Relative offsets in its key table avoid dynamic text relocation.

| Byte offset | Record field | Storage |
| --- | --- | --- |
| 0, 4, 8, 12, 16, 20, 24, 28, 32 | NFP3DFS, NFP3DFP, NFP3DFH, NFP3DFT, NFP3DFV, NFP3DFI, NFP3DFF, NFP2DF, NFPPHY | Nine signed 32-bit counts |
| 40 | CFPFMT | Eight bytes, padded with spaces |
| 64, 320, 576, 832, 1088, 1344, 1600, 1856, 2112 | MFP3DFS, MFP3DFP, MFP3DFH, MFP3DFT, MFP3DFV, MFP3DFI, MFP3DFF, MFP2DF, MFPPHY | Each is 64 signed 32-bit integers |
| 2368 | NRFP3S | 64 signed 32-bit integers |
| 2624, 3136, 3648, 4160, 4672, 5184 | RFP3P, RFP3H, RFP3TH, RFP3PV, RFP3I, RFP3F | Each is 64 FP64 values |

Header bytes not listed in the table are zero. Counts and dynamic field codes default to zero. `MFPPHY` defaults to −9999, and `NRFP3S` defaults to −9. Real level arrays default to −9, except `RFP3PV`, which defaults to 9999000000, and `RFP3I`, which defaults to −9999. These values are the declared defaults in `TNAMFPL` in `module/yomfpc.F90`, lines 255–292. `SUFPC`, lines 762–820, copies the completed field list without changing these entries.

## Accepted text and bounds

Keys and the group name are case insensitive. Spaces, tabs, line endings, commas, and comments beginning with an exclamation mark follow the checked bounded grammar. `CFPFMT` must contain the five characters `MODEL` in either single or double quotes. The initial format is the original nonlimited-area default, `GAUSS`, so a missing format is rejected for this selected route. Only the 26 keys in the record table are accepted. Duplicate keys, array indexing, repeated-value notation, null array entries, unknown keys and missing closing slashes are rejected. The parser uses the first matching group, as the source reading control does.

Counts are from zero to 64, and `NFPPHY` must be zero for this route. Every active dynamic code must be from 1 to 686 and must have been supplied. Unused supplied code entries may be zero. `NRFP3S` entries may be from zero to 64 or use the source markers −9 and −99; the request builder checks their selected level meaning. Every array accepts at most 64 supplied entries.

Real tokens must denote exact integral values with magnitude at most 2 to the power 53. An optional decimal point can have only zero fractional digits. An optional `E` or `D` exponent is from −15 to 15, and division by a negative power of ten must leave no remainder. The parser assembles the FP64 encoding with integer operations and preserves negative zero. This bounded route includes the selected pressure levels, measured in pascals, without a decimal conversion library. The caller remains responsible for the physical range and ordering of each level family.

## Verification and limits

`source_namfpc_control.F90` uses the original compiled `TNAMFPL` type and defaults, reads the same input text through a Fortran `NAMFPC` statement, and copies the complete bounded record. The original type and source reader are verification controls only. The direct library has no required shared libraries and calls no Fortran routine.

Six accepted cases cover the live R7 `fort.4`, empty field sets, comments and letter case, all supported field families, arrays with 64 entries, and exact integral real spellings, including negative zero. The source and native records agree in all 34,176 compared bytes. The source reader and complete selected original wrapper preserve incoming FPSR in the qualified cases. The complete original wrapper returns errno zero after its external file input; this parser has no external calls and preserves incoming errno. The raw flags are compared at return. The critical result also records malformed input, incomplete prefixes, overlap and length guards, protected input-page ends, saved registers and raw status. No forecast or performance timing is part of this child check.

The [complete forecast comparison](../../../../../src/openifs/README.md#verification) passes for this selected route, with every final owner and saved file compared. Original startup and remaining runtime services still prevent an autonomous-executable claim.
