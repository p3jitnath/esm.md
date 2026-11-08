# Inactive chemistry scalar initialization

Chemistry setup still assigns control values when no chemical fields are active. This [assembly entry](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/setup/inactive_chemistry_scalar_initialization.S) applies the 13 composition defaults and 28 inactive chemistry assignments from `SUGFL1`. It copies source constants without a time update, numerical calculation or unit conversion.

## Interface and bounds

The application binary interface (ABI) defines the argument registers, storage bounds and returned status. `md2asm_initialize_inactive_chemistry_scalar_defaults` uses the usual Arm ABI.

| Register | Argument |
|---|---|
| `x0` | Writable `TCOMPO` record, 280 bytes, aligned to 8 bytes |
| `x1` | Writable `TCHEM` record, 11,936 bytes, aligned to 8 bytes |
| `x2` | Read-only array of two unsigned 64-bit byte capacities, aligned to 8 bytes |
| `x3` | Read-only array of four signed 32-bit field counts, aligned to 4 bytes |

The capacities must be at least 280 and 11,936 bytes, in that order. The counts are `NCHEM`, `NGHG`, `NAERO` and `NACTAERO`; each must be zero. All four storage ranges must be mapped, separate and free from address wrap. Field counts are dimensionless. The floating-point control register, `FPCR`, must be zero.

The returned 32-bit status in `w0` is 0 on success or 2 on refusal. Every admission check occurs before an output store. The entry preserves `x18`, saved integer and vector registers, `FPCR`, the floating-point status register `FPSR`, and `errno`. It uses no stack frame, external call or allocation.

## Source assignments and ownership

The entry writes exactly 41 scalar members, or 176 bytes. Each store has its original field name beside it, and the assignments retain source order. All other record bytes, including descriptors, padding and members not assigned by this branch, remain unchanged. Array construction and aerosol or ozone storage belong to separate producers.

In the qualified Model layout, `TCHEM` starts at byte 4,219,928 and `TCOMPO` starts at byte 4,231,864. The owning setup supplies these views after successful grid-field configuration and reads the four actual counts from the live Model. The leaf does not parse input groups or support active chemistry and input overrides. It must run at the qualified inactive source stage before consumers use these defaults.

## Qualification and limits

The essential component check passed 13 cases and 15 ABI calls. An independent Fortran control executes the original 41 named assignments on two different incoming byte patterns. It matches all 24,432 compared record bytes, including bytes that must stay unchanged. Count, capacity, alignment and overlap refusals preserve 134,728 checked bytes. Guarded buffers, numerical status, `errno`, saved registers and a nonzero `x18` value pass.

The owning source insertion has an exact inverse and a retained instruction and relocation check. This accepts the scalar setup component and its interface. It does not establish a completed forecast, later held values or complete chemistry support.
