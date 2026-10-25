# Physics Grid Dimensions

Revision 1 replaces the original DIMENSION_TYPE_INIT and DIMENSION_TYPE_UPDATE metadata operations. Metadata records grid sizes and addresses so a calculation can locate its input. These operations change no weather value and use no floating-point arithmetic. All counts have no physical unit.

## Records And Interfaces

The dimension record has 192 bytes. Its first 128 bytes contain 32 signed 32-bit integers, while its last 64 bytes describe a pointer to latitude numbers. A pointer descriptor records an array's address, element size, rank, bounds and stride. The input geometry, model and surface records need their complete declared extents of 17096, 4275088 and 18224 bytes. Each record is mapped and aligned to eight bytes. The mutable dimension record is disjoint from the three immutable source records.

The raw entry is `int md2asm_initialise_physics_dimensions(dimensions, geometry, model, surface)`, with the four addresses in x0 through x3. It copies 26 named source counts, assigns one to KIDIA and KTDIA, and sets K2DSDT from the selected stochastic-physics count when LSPSDT is true, or zero otherwise. KLEVO receives NCOM minus one. Source counts and their signed results must fit 32-bit storage, and LSPSDT must be a valid logical value. NCOM may be zero on the disabled-ocean route, giving the exact source result `KLEVO=-1`. Every other source operation is an integer copy.

The three block-specific integers KFDIA, KBL and KSTGLO and the entire incoming latitude descriptor remain unchanged during initialization. The complete named offset map comes from a typed GNU12.3 query of the original source records. No compiler-generated instructions supply the direct implementation.

The raw update entry is `int md2asm_update_physics_dimensions(dimensions, block, active, global_start, latitude_descriptor)`, with five arguments in x0 through x4. The three integer values update KBL, KFDIA and KSTGLO. Copy all 64 incoming descriptor bytes into KGPLAT without changing its target array. The source descriptor is mapped, eight-byte aligned and disjoint from the dimension record, or is exactly its KGPLAT descriptor. Its latitude owner stays live with the geometry. The pointer may be unassociated or associated with a contiguous integer array, including an empty array. Every other dimension byte remains unchanged.

## Original Method Boundary

The two original method symbols remain available. Their first argument is a two-word Fortran class descriptor whose first word points at the dimension record. Initialization retains the other three raw source addresses. Update receives the three integer values by address and the latitude descriptor as its fifth argument. These compatibility entries translate their arguments and call only the direct raw entries. They require no original constructor or Fortran vtable address.

Both raw entries return zero. All entries require complete valid caller records and do not add a rejection or allocation route. They use no stack, no external service and no floating-point instruction. Preserve x18 through x30, every vector register, FPCR, FPSR and errno. Caller-saved integer registers and integer condition flags are scratch. Sixteen-byte stack alignment is unchanged.

Two aligned 64-bit diagnostic counters count original initialization and update entries. They are serial verification metadata. `md2asm_physics_dimension_call_count_get(index)` returns the selected counter for index zero or one, and zero for other indices.

## Verification

The separate Fortran control uses the unchanged original source with only its module name changed. Ten critical cases compare all 192 record bytes, covering distinct counts, both stochastic-physics branches, first and final blocks, non-one latitude bounds, empty and unassociated pointers and descriptor self-assignment. Four seeded ABI cases pass. Complete immutable input records, latitude targets, buffer guards, FPCR, FPSR and errno remain unchanged.

The combined native forecast calls initialization 25 times and update 2,150 times. All 685 final model owners, containing 27,486,113 bytes, and all ten saved files, containing 618,140 bytes, match the separate source forecast with zero differing bytes. Native route, numerical status and ABI checks pass. No physical calculation changes, so unchanged physical checks are reused. Model startup and other storage methods still require Fortran and remain outside this component.

The [actual distributed dimension join](runtime_physics_dimension_block_binding.md) also checks the disabled-ocean NCOM zero route with KLEVO minus one, the complete 26-count live input map, and genuine first and final latitude-owner views at block width 17 and 137 layers. The raw INIT and UPDATE instructions remain unchanged.
