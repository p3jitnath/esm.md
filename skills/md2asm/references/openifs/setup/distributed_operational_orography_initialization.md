# Distributed Terrain Initialisation

Terrain geopotential describes elevation multiplied by gravitational acceleration, in square metres per square second. This SUOROG stage converts its spectral coefficients into grid values and two horizontal derivatives. It keeps the [accepted terrain arithmetic](operational_orography_initialization.md) and uses the live four-process transform maps.

`md2asm_initialize_distributed_operational_orography(G,G_bytes,coefficients,coefficient_bytes,controls,controls_bytes)` takes its six arguments in x0 through x5. G is the final 20,400-byte Geometry record. The 16-byte controls contain four 32-bit integers in order, LELAM, LGRADGP, MYSETV and NPRTRV. The first two are source-produced false flags. NPRTRV is 2 and MYSETV is 1 or 2 from the live partition. The coefficient owner has one valid unused byte in group 1 or 6,558,720 bytes in group 2. All records are mapped, nonwrapping and disjoint. G and nonempty coefficients align to eight bytes, and controls align to four.

All four processes enter both public inverse transforms. Assembly owns the OpenIFS coefficient preparation, separately rounded multiplication and blocked placement. The first transform produces terrain values. The second produces derivatives from the source vorticity/divergence pair. Local wave numbers and starts come from live Geometry maps. Empty spectral groups read no coefficient.

Each process owns three arrays of 13,199,480 bytes with shape 17 by 97,055. Only the 1,649,920 physical points are assigned, including two points in the final block. Incoming padding stays unchanged. Install the three descriptors after all allocations succeed. The temporary has 39,598,080 or 52,715,520 bytes, according to the process group. Release it after use. `md2asm_release_distributed_operational_orography(G)` frees the three new owners before Geometry release.

The 1,024-byte stack frame is aligned to 16 bytes. Preserve x18, saved registers and floating-point control FPCR. FPCR must be zero. Public transform arithmetic flags and the system error value remain observable. Return 0 means success, 1 means allocation failure with partial cleanup, and 2 means an interface or scope refusal before mutation.

The four-process comparison passes 316,784,640 assigned terrain bytes exactly, with complete metadata, input and guard checks. Original unassigned padding is preserved and is outside the cross-process numerical comparison. Independent terrain and transform checks are reused. Allocation-failure and refusal checks pass. Full forecast acceptance remains separate.
