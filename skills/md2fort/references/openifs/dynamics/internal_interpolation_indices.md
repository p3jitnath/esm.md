# Internal Interpolation Indices

SUINTDYNSL prepares the integer indices used by semi-Lagrangian transport. This method traces each moving air parcel back to its earlier position and interpolates the fields there. These indices identify the stored interpolation weights. The routine does not calculate a weather field or change the physical model.

The source is arpifs/module/intdynsl_mod.F90. SUINTDYNSL calls SUPTR_TLSCAW twice, SUPTR_TRSCAW twice, SUPTR_TSCO and SUPTR_TCCO. The assembly follows their integer operations and branch order. SUDYN calls this setup after SUGFL3, when LSLAG is true and NSLDIMK has its final value. SUGFL3 supplies the active field descriptions. SUDYN supplies the interpolation controls. The assembly does not replace a missing input producer with a captured result.

The application binary interface is `int md2asm_initialize_internal_interpolation_indices(void *model, uint64_t capacity)`. Register x0 supplies the live MODEL address, aligned to eight bytes. Register x1 gives its mapped capacity, at least 4,275,088 bytes. The complete span must not wrap around the address space. The entry returns 0 on success or 2 on refusal. Its 96-byte stack frame remains aligned to 16 bytes. It preserves x18, x19 through x29, the return address, stack pointer and d8 through d15. It uses no floating-point instructions, external calls or dynamic storage.

The input NSLDIMK is the number of horizontal weight sets and must lie between 1 and the declared maximum 4. Source logical fields use the GNU representations 0 and 1. LSLAG must be true for this selected call. The active field count must lie between 0 and 2163. The routine compares each active field's complete 12-character CSLINT value with the three source Hermite interpolation names. This interpolation also uses derivatives to form the estimated value. All input offsets, record sizes and array limits come from a named query of the original declarations.

| Record | MODEL Byte Offset | Bytes | Meaning |
| --- | ---: | ---: | --- |
| YYTLSCAW | 1570584 | 28 | Linear weights at full levels |
| YYTLSCAWH | 1570612 | 28 | Linear weights at half levels |
| YYTRSCAW | 1570640 | 144 | Other weights at full levels |
| YYTRSCAWH | 1570784 | 144 | Other weights at half levels |
| YYTSCO | 1570928 | 20 | Spherical interpolation coordinates |
| YYTCCO | 1570948 | 20 | Computational coordinates and wind rotation |

The six records occupy 384 contiguous bytes. An index begins at 1 and advances by each source-defined block width. Separate full-level controls select spline, Hermite, heat, vertical-filter and weighted-interpolation blocks. The half-level call disables spline and Hermite inputs, as the source requires. Array entries above NSLDIMK retain their incoming representation. Every refusal occurs before a record is written. All other MODEL bytes remain unchanged.

Five comparisons call the unchanged original SUINTDYNSL through an address-only reference adapter and apply the direct assembly to the same explicit input. The cases cover all supported weight counts, both sides of each source control branch, all three Hermite names, a nonmatching name and an empty field set. They compare 21,375,440 complete MODEL bytes, with zero differences. The source and native outputs retain matching unused-array bytes. The raw native state is FPCR 0, FPSR 16, errno 777 and ABI mask 0. Six critical cases reject an invalid count, invalid logical value, short capacity or bad alignment without changing MODEL. These are metadata checks, so no separate physical integration claim is made. The required autonomous forecast remains the enclosing acceptance gate.
