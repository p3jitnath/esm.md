# Surface Group Finalization

Revision 1 assigns storage indices to a completely registered surface group. It implements the returned metadata calculations in FINALISE_SFLP2 and FINALISE_SFLP3 without their diagnostic text output. The caller owns every record, and no original module, type table or model callable is used. A group can contain a surface value at each horizontal cell or a value at each cell and depth. Multiple time levels store the current and next states separately.

## Interface

The interface is int md2asm_finalize_surface_group(group, fields, field_bytes, totals, controls). Registers x0 through x4 carry a writable 60-byte group, writable contiguous field array, unsigned byte capacity, writable 24-byte totals and read-only eight-byte controls. Group, totals and controls need four-byte alignment, while fields need eight-byte alignment. All mapped nonwrapping complete spans are disjoint. A zero-field group may have a null field address and zero byte capacity. Preserve bytes outside the source-defined stores, including unused fields and every allocation descriptor.

The [group initializer](surface_group_initialization.md) defines group offsets. NLEVS minus one selects a two-dimensional group with 64-byte fields and L3D false. NLEVS zero through 64 selects a layered group with 288-byte fields and L3D true. The group is unfinished, LMTL is zero or one, and IPTR is one through 694, giving NUMFLDS equal to IPTR minus one. Every active field is registered with LSET true and IBUGFINDER equal to its one-based field index. Controls contain a four-byte LTWOTL Boolean and the four-byte NUNDEFLD value minus 99999. The six nonnegative signed 32-bit totals are NSURF, NSURFL, NDIMSURF, NDIMSURFL, NPROGSURF and NPROGSURFL in that order, matching the first 24 bytes of the owned TSURF record. Reject a signed overflow before mutation.

## Integer Updates

Let n be NUMFLDS. A layered group has depth factor NLEVS, while a two-dimensional group has depth factor one. Increase the first two totals by n and n times the depth factor. Increase the final two prognostic totals by those same amounts only for a multiple-time-level group. Such a group has NDIM equal to two n when LTWOTL is true or three n otherwise. A single-time-level group has NDIM equal to n. Increase the third and fourth totals by NDIM and NDIM times the depth factor. Set the group NUMFLDS, NDIM and FINALISED true.

For each field j from one to n, set MP to j. A single-time-level field has MP0, MP9 and MP1 equal to NUNDEFLD. Otherwise set MP0 to j. With two time levels set MP9 to j and MP1 to j plus n. With three time levels set MP9 to j plus n and MP1 to j plus two n. Disjoint integer stores may commute because each owner has one caller and no floating-point arithmetic is introduced.

Return zero on success or two for unsupported input before mutation. The leaf has no stack, child call or library dependency and preserves x18, saved registers, FPCR, FPSR and errno. Original diagnostic text and its I/O status are outside this utility. A separate full original finalizer is the returned-record reference, with its diagnostic status recorded separately.

## Required Acceptance

Compare complete returned group, field and total bytes with both genuine original finalizers for zero, one, actual and maximum field counts, both time-level choices, active and inactive depths, unrelated incoming bytes and accumulation. Check source-defined maps and counts independently, guards, immediate ABI/status and rejection before mutation. Reuse accepted registration evidence, inspect the production dependency graph and obtain an independent source/ABI peer. Run no forecast for this integer metadata utility.

## Accepted Checks

Twenty-seven genuine original comparisons cover both group kinds, zero and 693 fields, inactive and 64-layer depths, and single, two and three time levels. All 749,244 complete group, field and total bytes agree. All 68 immediate ABI/status calls pass, including thirteen invalid calls before mutation. The original diagnostic I/O leaves the same incoming flags and errno on these cases, while remaining outside this utility. All 5,400 guard bytes and 21,243 independent count and map relations pass. A standalone assembly process initializes, registers and finalizes one two-dimensional field, then writes all 148 returned bytes exactly against the genuine three-stage parent. It has no shared library or undefined symbol. This metadata checkpoint does not run a forecast.

Independent source and ABI review passes. A typed query confirms that the six counters occupy the original TSURF bytes zero through 23 in the declared order.
