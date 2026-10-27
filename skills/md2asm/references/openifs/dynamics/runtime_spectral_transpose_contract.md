# Runtime Spectral Transposes

TRMTOS collects spectral coefficients, which describe horizontal waves, into complete vertical columns. TRSTOM returns those columns to the original distribution of levels. [The direct assembly](../../../../../src/openifs/dynamics/runtime_spectral_transposes.S) copies all 64 bit floating-point values without changing their bits. The existing serial entries remain unchanged. Production uses public FIAT and MPICH services, with no original OpenIFS routine or global variable.

The application binary interface keeps the original argument order. Each argument is an address. Optional absent arguments are null. The final argument borrows the complete 4096 byte phase 7 partition associated with the supplied 20400 byte Geometry record.

| Argument | TRMTOS | TRSTOM |
| --- | --- | --- |
| 1 through 3 | Geometry, LDNHDYN, LDNHX | Same |
| 4 through 14 | Local VOR, DIV, T, SPD, SVD, SNHX, GFL, SP, AUX, selected 3D, selected 2D | Corresponding column arrays |
| 15 through 25 | Corresponding column arrays | Corresponding local arrays |
| 26 through 28 | LDSELECT3D, LDSELECT2D, LDFULLM | Same |
| 29 | Partition | LDNEEDPS |
| 30 | Absent | Partition |

The entry names are `md2asm_runtime_trmtos` and `md2asm_runtime_trstom`. Arguments 1 through 8 use x0 through x7. Partition is at incoming stack offset 160 or 168 bytes. Logical values occupy 4 bytes. Arrays use GNU descriptors with actual offsets, bounds and positive active strides. Exact GNU empty-array strides are permitted. Payloads obey the original separate-array requirements and remain owned by the caller. The stack stays aligned to 16 bytes. The entries preserve x18, callee-saved integer registers and the required low 64 bits of v8 through v15. The largest nested private frame is 1760 bytes.

Live Geometry supplies coefficient and level counts and the NPTRSV, NPTRSVF, NUMLL, NPTRLL and NPSURF maps. Partition supplies world, rank, transform factors and coordinates. The public MPL communicator must match them. The qualified MPICH interface represents its Fortran and C communicators by the same 4 byte integer. Source identity rank mapping is required. The component admits truncations 1 through 8191, global levels 1 through 512, worlds 1 through 65536 and no more level sets than global levels plus one. Zero local levels or columns are admitted. These bounds do not extend upstream Geometry or file readers.

Optional fields follow the original source gates. Selected fields retain ascending source order. LDFULLM selects its genuine coefficient map. TRSTOM retains full-pressure delivery when LDNEEDPS is present and true. Larger physical leading dimensions preserve their row padding. For multiple level sets, the original forward-send and backward-receive rings retain tags 1000 and 1200, exact headers and pressure-first payload order. All requests finish before temporary storage is freed.

The total temporary budget is 8 GiB per process, with checked integer sizes and signed 32 bit MPI counts. Result 0 means success, 1 means a common allocation refusal and 2 means a common input refusal. Processes agree admission and allocation status before destination writes. Refusals preserve public records and payloads. A public MPI failure aborts the communicator. FPCR must be zero and actual FIAT profiling must be disabled. Successful public services retain natural errno, which is recorded separately.

One coordinated check passed 132 calls in four separate original and assembly MPI steps. It used actual retained TCo1279, 137-level metadata on 23 processes with one level set, then the accepted 2 by 2 distribution with normal and full-m maps, field selection, padded rows and full pressure. All 20,004,096,000 paired destination bytes agreed exactly. Complete descriptors, 2004 pointer relations, 132 immediate status records, independent field patterns, two common refusals, 85 temporary acquisitions and frees, and 16 independent node cleanup receipts passed. Native ABI masks were zero, source masks were zero or the qualified x18-only mask, and FPCR and FPSR agreed. Wider and empty shapes remain source-reviewed. This component check does not establish a complete forecast.
