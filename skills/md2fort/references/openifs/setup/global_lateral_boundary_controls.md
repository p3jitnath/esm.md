# Global Lateral Boundary Controls

This entry reproduces the global branch of OpenIFS `SUELBC_INIT`. A global model covers the whole Earth, so it does not need weather data along an outer edge.

The live `LELAM` control must be zero, which selects the global model. Preserve the original call order in `arpifs/setup/su0yomb.F90`, after `SUNDDH` and before `SUALTDH`.

## Interface

`md2asm_initialize_global_lateral_boundary_controls` follows the AArch64 application binary interface, which defines arguments and preserved registers.

| Register | Meaning | Required storage |
| --- | --- | --- |
| `x0` | Writable `TELBC_MODEL` record | At least 2504 bytes, aligned to 8 bytes |
| `x1` | Available bytes at `x0` | At least 2504 |
| `x2` | Read-only `LELAM` logical value | At least 4 bytes, aligned to 4 bytes |
| `x3` | Available bytes at `x2` | At least 4 |
| `w0` | Return status | 0 for success, 2 for refusal |

The caller supplies valid storage and true sizes. Null pointers, invalid alignment, short buffers, address overflow, overlapping target and control, or nonzero `LELAM` return 2 before any write.

## Source Values

The typed record begins at byte 4272560 of the qualified 4275088-byte `Model`. Its first 168 bytes contain exactly the 22 members assigned by the global branch in `arpifs/module/yemlbc_model.F90`. These are integer counts and logical values, with no physical units. They are set to zero except `LRFIRST`, `NECRIPL` and `NFRLSG`, which each receive the 32-bit integer value 1 at record offsets 8, 36 and 68.

The source's local pointer named `LUNBC` refers to `LSPTENC` at offset 164. Preserve that source relationship. The separate record member `LUNBC` at offset 168 and all other bytes from offset 168 through 2503 remain unchanged, including allocation descriptors and padding.

The entry preserves the ABI registers, `x18`, stack, SIMD registers, floating-point control and status, and `errno`. It uses integer instructions, makes no calls, allocates no memory and supports any grid resolution within this global profile.

## Acceptance

The component check matches every record byte with strict Fortran `SUELBC_INIT` and checks invalid inputs, surrounding bytes, repeated initialization and raw caller state. Complete forecast and saved-output agreement remain pending.
