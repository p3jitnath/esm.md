# Inactive composition records and aerosol ownership

This child constructs the remaining composition and chemistry metadata for the operational case with no transported chemical, greenhouse-gas or aerosol species. Metadata describes calculation options; it does not contain a forecast field. The reference is the inactive path of original `SUGFL1`, with the `TCOMPO`, `TCHEM` and `TYPE_AERO_DESC` layouts declared in `YOMCOMPO`, `YOMCHEM` and `YOEAERATM`. The complete [grid-field namespace](operational_grid_field_configuration.md) is a separate accepted child.

The application binary interface (ABI) defines argument registers, buffer bounds and preserved state. `md2asm_initialize_inactive_composition_owners` receives the following six arguments in Arm registers x0 through x5. Every start has eight-byte alignment, and the caller supplies complete mapped allocations. All six required ranges must avoid address wrap. The four writable outputs must be pairwise disjoint and must not overlap either read-only input; read-only inputs may overlap each other. Every check precedes allocation or public mutation. Extra numeric capacity does not extend the range used for these checks.

| Register | Buffer | Required bytes |
| --- | --- | --- |
| x0 | Writable composition record | 280 |
| x1 | Writable chemistry record | 11,936 |
| x2 | Writable eight GRIB parameter codes | 32 |
| x3 | Writable one-dimensional aerosol descriptor | 64 |
| x4 | Four read-only unsigned 64-bit capacities, in output order | 32 |
| x5 | Four read-only int32 counts: `NCHEM`, `NGHG`, `NAERO`, `NACTAERO` | 16 |

All four counts must be zero. The three composition allocatable descriptors at offsets 80, 152 and 216, and the chemistry descriptors at offsets 11,776 and 11,864, must have valid null bases. Their extents are 64, 64, 64, 88 and 64 bytes. The new aerosol descriptor must also have a null base, so an existing allocation cannot be lost. Other incoming record bytes are caller-owned preimages: the service changes only the source-defined members below. It does not call an original object constructor or read an original global variable.

Every offset below is measured in bytes from its record start. An int32 occupies four bytes; an FP64 occupies eight bytes. The source constants are stored as integer bit patterns, without a floating-point calculation. The composition diagnostic period is 6 hours. The inactive chemistry methane marker retains the source FP64 value −9999.9 and is not a newly calculated concentration.

| Record | Defined writes |
| --- | --- |
| Composition | int32 zero at 0, 16, 20, 24, 28, 40, 44, 48, 52 and 56; int32 one at 36 and 60; FP64 6 at 8 |
| Chemistry | int32 zero at 20, 24, 32, 36, 40, 44, 60, 68, 72, 76, 80, 9688, 9692, 9696, 9700, 9704, 9708, 9712, 9728, 9732, 9736, 9740 and 11928; int32 one at 28 and 64; int32 2000 at 9716; FP64 positive zero at 48; FP64 −9999.9 at 9720 |
| GRIB codes | Eight int32 values −999, with six chemical codes followed by two greenhouse-gas codes |

The constructor obtains a 152-byte payload through public `malloc` before publishing any output. This allocation represents the original one-element inactive aerosol owner. Original `SUGFL1` leaves every payload byte uninitialised; this service therefore performs no payload store. A later reader needs its own qualified source-defined setup before using those bytes. The 64-byte descriptor contains eight words: the new base pointer, signed offset −1, element size 152, GNU type word `0x50100000000`, span 152, stride 1, lower bound 1 and upper bound 1. These fields come from the actual original typed allocation, not a captured payload image.

Return 0 means success. Return 2 rejects unsupported input before allocation or mutation. Return 1 reports allocation failure with every output unchanged and the allocator's error value retained. The separate `md2asm_release_inactive_composition_owner(descriptor)` receives the complete writable 64-byte descriptor in x0. It checks the descriptor range, calls public `free` for a nonnull owned base, and clears only that base. Other descriptor bytes remain unchanged. A null base is already released. Release returns 0 on success or 2 for a checked invalid range. Never pass an unrelated allocation as an owned base.

Both entries require FPCR zero, which selects round-to-nearest with ties to even and gradual underflow. Each uses a 96-byte aligned stack frame and preserves x18, x19–x29, required SIMD registers, SP alignment, FPCR and FPSR. Allocation and release add only their public allocator's internal stack use. The production object has only `malloc` and `free` as external symbols, with no floating-point instruction, original OpenIFS provider, global state, language constructor or Fortran runtime. Incoming errno is not overwritten to hide an allocator result.

Two separate original-source and native profiles used ordinary source-unwritten bytes filled with `0x5b` or `0xa7`, while all null descriptors remained valid and zero-filled. A verification-only guarded allocator supplied matching payload preimages; production performs no such fill. All 25,040 compared record, descriptor, payload and release bytes agree exactly, with two explicit owner-address correspondences. All source-unwritten record bytes and 304 payload bytes preserve their preimages. The 82 member and 16 GRIB-code relations pass, with two allocations, two frees and no live owner. All six native ABI observations have zero masks. A failed allocation and an unsupported count leave every output and guard unchanged.

The genuine source returned naturally with FPCR/FPSR/errno 0/16/0 or 0/24/0; release returned 0/24/34. The independent source x18 exception is retained separately. The failure probe retained allocator errno 12, while the count refusal retained errno zero. Existing namespace, parsing, constant and scientific evidence is reused without repeating an old bank. This checkpoint does not admit enabled chemistry or aerosol algorithms, reproduce namelist/file-I/O or console effects, claim a complete `SUGFL1` body, initialise the aerosol payload, join an enclosing parent or run a forecast. Detailed records remain under `.runtime/`.
