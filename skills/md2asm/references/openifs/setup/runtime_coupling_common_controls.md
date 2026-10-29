# Coupling Common Controls

This assembly entry performs the two scalar assignments from OpenIFS `SU_COUP_COM`. It first sets `NVCOM` to 2 and `LOMLDTH` to false, then applies values from the `NAMCOM` input group. `NVCOM` is an integer count of scheme parameters. `LOMLDTH` is the original logical setting, which stores false or true. These settings have no physical units.

The caller runs this stage after climate initialization and before wave initialization, including when ocean coupling is inactive. It uses the same persistent input text and model record as the other setup stages.

## Interface

The application binary interface, or ABI, states how a caller passes data in Arm registers. The entry is `md2asm_initialize_runtime_coupling_common_controls`.

| Register | Input |
| --- | --- |
| `X0` | Address of readable input text |
| `X1` | Text length from 1 to 262,144 bytes |
| `X2` | Address of the writable 336-byte `TCOM` record, aligned to 8 bytes |
| `X3` | Available target capacity, at least 336 bytes |

Both declared memory ranges must exist, stay within the address range and remain separate. On success, `W0` is zero. The entry writes the 4-byte `NVCOM` at offset 0 and the 4-byte `LOMLDTH` at offset 264. The other 328 bytes stay unchanged. On input refusal, `W0` is two and every target byte stays unchanged.

The entry uses a 96-byte stack frame with 16-byte alignment. It preserves `X18`, the saved integer and vector registers, the floating-point control and status registers, and `errno`, the C library error indicator. It allocates no storage and calls no external routine.

## Input Rules

Use a line-leading `&NAMCOM` header and end the group with `/`. The parser accepts spaces, tabs, line breaks, comments beginning with `!`, comma separators and case-insensitive member names. `NVCOM` accepts signed decimal values from −2,147,483,648 to 2,147,483,647. `LOMLDTH` accepts `T`, `F`, `TRUE` or `FALSE`, with optional surrounding dots. A null assignment keeps the current value, and the last repeated assignment takes effect.

Lower-case group names and wider header indentation are declared extensions to the original group locator. Comparisons use forms supported by both implementations. A missing group, unknown member, out-of-range integer or unsupported syntax returns status two. This is a bounded parser for these two scalars.

## Verification Scope

The accepted component check covers 35 calls. Supported values agree with an independent strict Fortran namelist reader. The checks also cover the declared syntax limits, protected memory boundaries, unchanged input and target bytes, and preserved caller state. The parent insertion preserves the existing status agreement and cleanup, and reversing that insertion reproduces the previous complete object exactly. Detailed records stay in the local runtime folder.

Full operational forecast agreement remains pending. Component acceptance does not establish complete raw-state or saved-output agreement.
