# Surface Field Registration

Revision 1 defines the owned two-dimensional field-registration stage from SURFACE_FIELDS_MIX SETUP_SFLP2. Registration assigns an input identifier, name, default and trajectory membership to one field before its group is finalized. A trajectory stores values needed at later model times. This utility changes metadata only and uses no original module data, model object or callable.

## Interface And Layout

The interface is int md2asm_define_surface_field_2d(group, field, trajectory, plan). Registers x0 through x3 carry a writable 60-byte group, writable 64-byte field, writable 408-byte trajectory record and read-only 40-byte plan. The [group initializer](surface_group_initialization.md) gives the group and field layouts. Group and trajectory need four-byte alignment, while field and plan need eight-byte alignment. All complete spans are mapped, nonwrapping and mutually disjoint. The caller owns all storage and supplies the selected two-dimensional group with NLEVS minus one.

The trajectory record contains signed 32-bit NOFFTRAJ and NOFFTRAJ_CST at offsets zero and four, followed by 100 signed 32-bit NSTRAJGRIB entries at eight. The plan contains an unsigned presence mask at zero, signed input identifier at four, raw eight-byte default at eight, signed trajectory option at sixteen, signed input-request flag at twenty and an exact sixteen-character name at twenty-four. Presence-mask bits zero through four select identifier, name, default, trajectory option and request respectively. An absent member's value is not read.

The group must be unfinished, its next field index IPTR must be one through 693 and the field's IBUGFINDER must equal IPTR. When the trajectory option is present, it is zero, one or two and the group's NDIM5 is between zero and IPTR minus one. For option one, NOFFTRAJ is zero through 99. For option two, NOFFTRAJ_CST is a nonnegative signed integer whose increment does not overflow. No other trajectory count or table entry is read unless that option consumes it. Unsupported values reject before any mutation with status two. Success returns zero.

## Ordered Stores

Preserve the source field values and counter updates. These disjoint integer stores run under one caller’s ownership, so their store order does not change a returned value or arithmetic flag. A missing identifier receives minus 999, a missing request receives minus one, a missing name receives sixteen spaces and a missing default receives positive zero. Present defaults are copied as raw bits, preserving signed zeros and non-number payloads. A present trajectory option always increments NDIM5, including option zero. Option one appends the field identifier at the next NSTRAJGRIB position and increments NOFFTRAJ. Option two increments NOFFTRAJ_CST. An absent trajectory option gives field ITRAJ zero without changing NDIM5. Finally set field LSET true and increase group IPTR by one. Preserve every other byte in all three mutable records.

The function is an integer-only leaf with no stack, child call or external dependency. It preserves x18, all saved integer and vector registers, FPCR, FPSR and errno. FPCR controls floating-point arithmetic and FPSR stores its status. No physical value is calculated or rounded here. No whole-original-body credit is claimed for this selected utility.

## Acceptance

Use the genuine SETUP_SFLP2 body as a separate reference with explicitly supplied global trajectory state. Compare all three complete returned records across all 32 optional-presence combinations, including present-zero trajectory, both append routes, raw default bits and the last admitted index. Check source-unwritten bytes, every input byte, complete guards, immediate Arm ABI/status and invalid-call rejection before mutation. Verify counts and field mapping independently, obtain a source and ABI peer and inspect a standalone assembly dependency graph. Run no forecast for this metadata-only change.

## Completed Checkpoint

All 32 optional-presence combinations match 17,024 complete source bytes, including present-zero trajectory, both append routes, the last field and table positions, raw negative zero and signalling non-number defaults. All 74 immediate ABI/status calls and ten invalid-input checks pass, preserving 4,352 guard bytes. The 320 independent mapping and count relations pass. A standalone assembly process initializes and registers the first field, then writes all 532 complete bytes exactly against the genuine two-stage parent. It has no shared-library dependency. Independent source and ABI review passes.
