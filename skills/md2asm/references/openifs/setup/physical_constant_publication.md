# Shared Physical Constant Publication

A storage owner is the record that holds a set of values. The startup stage builds the model constants in a private record. This utility copies the completed values into the shared owner selected by the forecast routines, so those routines read the source-defined constants. The values, units and ordered calculations are defined in [Owned Physical Constants](physical_constant_setup.md).

The source is the 520-byte constant record at byte offset 9,448 in the 9,968-byte startup owner. Its producer finishes before this copy. The destination is the persistent helper record named `md2asm_owned_initial_physical_constants`. The current linked program selects this same owner for the required constant aliases. Publication occurs before geometry and physics setup.

## Interface And Storage

The assembly entry is `md2asm_publish_owned_physical_constant_namespace` in [physical_constant_publication.S](../../../../../src/openifs/setup/physical_constant_publication.S). Its application binary interface, or ABI, defines how the caller passes arguments and receives the result.

| Register | Argument | Units or storage |
| --- | --- | --- |
| `x0` | Read-only source address | 520-byte record |
| `x1` | Source capacity | bytes, at least 520 |
| `x2` | Writable destination address | 520-byte record |
| `x3` | Destination capacity | bytes, at least 520 |
| `w0` | Returned status | 0 for success, 2 for refusal |

Both addresses must be nonzero and aligned to eight bytes. Their complete 520-byte ranges must not overlap or wrap around the address space. These conditions are checked before the first write. The caller keeps both owners alive throughout the call.

The first 512 bytes contain 64 values stored as FP64 words, where FP64 means a 64-bit floating-point representation. Bytes 512 through 515 hold the setup logical. Integer loads and stores copy these 516 defined bytes exactly, including the source sentinel bit pattern. The four reserved destination bytes remain unchanged, and the complete source remains read-only.

This Armv8.2-A leaf uses registers `x0` through `x7` and needs no stack storage or child call. It preserves SP, `x18`, the saved registers, floating-point registers, the floating-point control and status registers, and `errno`. Integer copying preserves the completed calculation without adding arithmetic events or numerical-child calls.

## Completed Checks And Limits

Seven focused ABI calls pass. The actual helper destination receives all 516 defined bytes exactly, all 14 required constant aliases identify the declared offsets in that owner, and the reserved tail, source, guards and factory storage remain unchanged. Success and refusal paths retain the declared status, ABI, floating-point state and `errno`. The parent insertion has an exact source and object inverse to the previous factory, with all previous instructions and relocations retained. The accepted constant calculation and its independent physical checks are reused.

Three affected images link with strict symbol checks. A separate loader-only check preserves the existing constant and registry bindings across 208 libraries. These results accept this publication step and its interfaces. A complete operational forecast and its raw-state and saved-output comparisons remain open. The earlier forecast did not capture its numerical solar inputs, so this result does not identify that run’s exact rejected predicate.
