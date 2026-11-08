# Inactive sponge controls

A sponge can damp motion near a model boundary. The inactive `SUSPNG` source branch disables this damping and leaves its coefficient array unallocated. This [assembly entry](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/setup/inactive_sponge_controls.S) reproduces that setup branch without a weather calculation.

## Interface and bounds

The application binary interface (ABI) uses `md2asm_initialize_inactive_sponge_controls` with these arguments.

| Register | Argument |
|---|---|
| `x0` | Writable Model, aligned to 8 bytes |
| `x1` | Model capacity in bytes, at least 4,275,088 |
| `x2` | Read-only `fort.4` text |
| `x3` | Text length, from 1 to 262,144 bytes |

Model and text must be fully mapped, separate and free from address wrap. The coefficient descriptor `RSPONGF`, whose base word is at Model byte 1,570,408, must be unallocated. No input is read through that base.

The entry calls the accepted `md2asm_require_empty_physics_group` reader. Its supported grammar requires the first matching uppercase `NAMSPNG` group, with the marker in the first ten columns, to be present and empty except for comments. It does not implement general Fortran namelist syntax or an active sponge.

The returned 32-bit status in `w0` is 0 on success or 2 on refusal. On success, the sole Model store sets the four-byte `LNSPONGE` logical at byte 1,570,400 to false. On refusal, Model is unchanged. The text and every descriptor byte remain unchanged in both cases.

The entry uses a 64-byte stack frame aligned to 16 bytes. It preserves `x18`, saved integer and vector registers, the floating-point control and status registers, and `errno`. It performs no floating-point operation or allocation.

## Source stage and qualification

Original `SUSPNG` follows `SUDYN` and interpolation setup, before physics setup in `SU0YOMB`. The qualified owning join runs this entry after its interpolation owners are complete and before any numerical consumer. The current earlier parameter constructors do not read this sponge flag. Active damping and a previously allocated coefficient array remain outside this route.

Eight essential calls check the retained current input and input, extent, alignment and owner refusals. They compare 34,207,042 bytes with zero differing bytes, including all Model bytes outside the one defined store and the complete read-only input. Guarded buffers, raw status, numerical flags, `errno`, saved registers and nonzero `x18` pass. A separate combined setup check covers the new parent call order and SPPT cleanup.

This accepts the inactive setup component and its owning interface. It does not establish a complete forecast or active sponge support.
