# Operational Flux Configuration

The selected SUCFU, SUXFU and SUMCUF setup requests no diagnostic flux arrays. A flux is a quantity passing through a surface per unit time. Even with these requests inactive, later code needs the original reset frequency NFRRAZ of 20 steps and initial-reset switch N1RAZ of 1. This component supplies the actual source settings and two empty-array owners.

`md2asm_initialize_operational_flux_configuration(text,bytes,records48,controls32)` uses x0 through x3. Records48 contains three address/capacity pairs for TCFU, TXFU and TMCUF, with 162,272, 330,728 and 936 bytes. Their final FIELDS offsets are 35304, 197576 and 528320 inside 529,288 bytes. Text has at most 262,144 readable bytes. Records, backing owners and input ranges are mapped, aligned to eight bytes, nonwrapping and disjoint.

Controls32 has eight 32-bit words in order, NPROMA 17, NGPBLKS 97,055, LECMWF 1, NFPOS 2, LMPHYS 0, LDPRECIPS 0, LDPRECIPS2 0 and NCONF 1. The accepted bounded parsers read the first NAMCFU, NAMXFU and NAMMCUF groups and the actual NAMFPC requests. Success requires the declared source-inactive flux requests. It does not change an active request to make it inactive.

Each empty allocated array has shape 17 by 0 by 97,055, lower bounds 1 and a nonnull one-byte ownership token. It has no numerical payload. The GNU descriptor offset is minus 18 and its strides are 1, 17 and 0. A descriptor records an array's address, shape and strides. Preserve all other source stores, including their original rounding and source-unwritten bytes. `md2asm_release_operational_flux_configuration(records48)` releases both tokens before FIELDS release.

Return 0 on success, 1 on allocation failure or 2 on a checked request, shape, freshness or range refusal. The current initializer frame has 12,416 bytes, with a maximum 24,800-byte call chain including the actual request parser. Release has an 80-byte frame. Preserve x18, saved registers, FPCR, incoming arithmetic flags and the system error value. Original source display I/O has separately recorded status effects. This utility does not claim equivalent formatted output or whole-body I/O status.

The unchanged source-store and arithmetic proof reuses the accepted source cases. Independent typed allocations check the two changed descriptors. Complete created/released records and attached FIELDS bytes agree under two incoming fills. Guards, direct status, shape refusals and partial-allocation cleanup pass. The block driver and full forecast remain separate.
