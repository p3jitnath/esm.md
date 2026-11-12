# Upper-Air Initial-State Loading

Revision 1 composes the accepted [upper-air field reader](initial_upper_air_field_reader.md) and [placement stage](upper_air_initial_state_placement.md) into one direct assembly call. It loads humidity, cloud liquid, cloud ice and cloud fraction from the actual coarse input file and places them in the original eight-field blocked array. Humidity and cloud mass fractions have units kg/kg, while cloud fraction has no unit. This stage performs no new physical arithmetic or interpolation.

## Interface And Input

The application binary interface is `int md2asm_load_initial_upper_air_state(path, gfl, gfl_bytes)`. Registers `x0`, `x1` and `x2` carry a readable zero-terminated file path, the complete mutable array address and its capacity in bytes. The array has shape `(24,19,8,86)` in Fortran order and needs 2,509,824 bytes. Its pointer is nonnull and eight-byte aligned, with a nonwrapping consumed span. The caller supplies mapped storage and the complete incoming array contents.

The selected file is `ICMGGepc8INIUA`. Its 76 records contain 2,048 values each. The accepted reader freezes their parameter and level identities. The placement child copies active rows into fields 1, 2, 3 and 6, clears complete fields 4, 5, 7 and 8, and preserves 9,728 padding bytes in the copied fields. This parent retains exactly those storage rules and the caller's arbitrary complete preimage. It does not clear that preimage before reading.

## Ordered Execution And Errors

Validate the output span and floating-point control register before allocation or file access. Allocate one 1,247,008-byte private buffer with `malloc`, partitioned into 1,245,184 decoded value bytes and 1,824 metadata bytes. Keep the completed-record counter in the local stack. Call the accepted direct reader, then call the accepted direct placement only if decoding succeeds. Release the private buffer once through `free`.

Return 0 for success, 1 for an invalid path pointer, output span or floating-point mode, and 2 for allocation failure. A reader error returns its original code plus 16, and a placement error returns its original code plus 32. The complete model array remains unchanged when reading fails. The placement child validates its complete metadata before its first write. No original input routine or numerical fallback is called.

## Register And Library Boundary

FP64 means the 64-bit floating-point format. The floating-point control register, FPCR, must be zero for the codec route. The parent preserves FPCR, the floating-point status register FPSR, `errno`, the platform register `x18`, all required saved integer and vector registers, and sixteen-byte stack alignment. Its frame has 112 bytes. The parent uses no floating-point arithmetic, so input loading contributes no new numerical flags.

The direct children use the declared C ecCodes file-format library and ordinary file services. This parent additionally uses `malloc`, `free` and `__errno_location`. These are allocation and runtime boundaries, not forecast calculations. Original OpenIFS object construction, startup diagnostic norms and a complete autonomous executable remain separate work. No original-body coverage is claimed for this composition.

## Acceptance

Ten focused cases and three seeded ABI paths pass, with zero differing bytes across the complete 2,509,824-byte model array. The combined loader matches both the actual original SUGRIDUG returned state from its complete starting array and the independent placement control from an arbitrary preimage. Invalid spans and mode, missing files and wrong record schemas leave the complete output unchanged. Status, the platform register and protected buffer boundaries remain unchanged. Independent source/interface review also passes. The unchanged child scientific, codec and storage proofs are reused. This component adds no forecast run, comparative timing or original-body coverage.
