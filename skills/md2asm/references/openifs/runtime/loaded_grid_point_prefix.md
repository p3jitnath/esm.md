# Loaded grid-point prefix

This component joins the accepted initial-state owners to the inverse transform and the first grid-point calculation. The inverse transform converts spectral fields into values on the horizontal grid. The checked seam then gives the original and assembly CPG_GP routines the same first and final tile values from that live model. A tile is one consecutive block of stored columns. This seam stops before the packed-buffer clear and the selected physics calls.

## Assembly entries

[`loaded_grid_point_input_ownership.S`](../../../../../src/openifs/setup/loaded_grid_point_input_ownership.S) exports `md2asm_create_loaded_grid_point_inputs(spectral_path, surface_path, upper_air_path, namelist_path, alias_destinations120, holder24)`. Its six addresses enter registers `x0` through `x5`. The caller supplies a zero 24-byte holder with three eight-byte pointer slots. The entry calls the accepted startup-input owner, complete distributed Geometry owner and [source-ordered initialized model](../input/source_ordered_operational_model_initialization.md), in that order. The slots retain startup, the Geometry sidecar and the initialized-model owner. Geometry is the live grid metadata; the model borrows it and retains its numerical input arrays.

The creation guard checks nonnull arguments, eight-byte alignment and nonwrapping spans for the alias table and holder, their separation, and an initially empty holder. Each path must be a live readable string ending with a zero byte. The alias table must identify fifteen live writable eight-byte destination cells. Those cells must remain separate from the holder, paths and constructor inputs under the accepted initialization contract. These complete mappings and destination relations remain caller prerequisites.

The creation entry returns zero on success, two on its own refusal, or the exact nonzero child status. On a child failure, the successful earlier holder slots remain available for explicit cleanup. `md2asm_release_loaded_grid_point_inputs(holder24)` releases the initialized model, sidecar and startup in reverse order, clearing each successfully released slot. A null holder is an empty release. The holder must stay alive until cleanup completes. The creation and release stack frames occupy 96 and 48 bytes, respectively, before child work.

[`loaded_grid_point_prefix.S`](../../../../../src/openifs/runtime/loaded_grid_point_prefix.S) exports `md2asm_bind_loaded_grid_point_tile(owner64, arguments608, block4, capacities88)`. An application binary interface, or ABI, specifies these four addresses in `x0` through `x3` and the registers that a call preserves. The table contains the original 75 CPG_GP addresses and its accepted 80-byte dependency-record address. The last argument contains eleven eight-byte backing-array capacities, in bytes. A successful call replaces only the first three record addresses and eleven field-section addresses. Other entries retain their exact incoming values.

The binder checks the initialized owner phase, loaded-owner flags, record relationships, alignment, nonwrapping spans, the live block limit and the required existing provider shape. It checks each selected dense GNU Fortran descriptor: data type, rank, eight-byte element size, lower bounds of one, strides, offset and complete array capacity. All products and byte offsets use 64-bit integers. It stages the complete table in its 864-byte aligned stack frame and returns two before any table write on refusal. It adds no floating-point calculation.

The same file exports `md2asm_transform_initialized_grid_point_model(owner64, modes32)` with addresses in `x0` and `x1`. Its 64-byte frame preserves the caller while it invokes accepted [UPDTIM time coefficients](../dynamics/operational_time_coefficients.md) and then the accepted [operational inverse transform](../dynamics/operational_model_transform_callers.md). It derives MODEL, FIELDS, physical constants and partition addresses from that same live owner. Modes are eight four-byte integers; the qualified mode is `(0,0,0,1,0,0,0,0)`. The entry returns the exact first failing child status. Its local refusals check null addresses; complete producer and span admission remains a caller prerequisite.

All new entries preserve `x18` and the required saved registers. Their stack pointers stay aligned to 16 bytes. They add no floating-point instruction and do not reset FPCR, FPSR or `errno`. FPCR must be zero for the accepted numerical children. The new wrappers preserve the children's natural status. Verification starts with eager shared-library binding so that a first-call linker resolver does not enter a register-preservation measurement.

## Live fields and caller prerequisites

The qualified numerical providers require 17 stored columns and 137 layers. The binder reads these values from live Geometry and retains that specialization. It reads the live positive block count and accepts any contained block; this checkpoint checks blocks 1 and 97,055 of the actual 1,649,920-point partition. The final tile has two active columns. No change to the main Fortran executable or a resolution-specific rebuild is used.

Motion and tracer arrays retain their complete 17-column pitch in the final tile. Its horizontal Geometry vector views contain only the two active elements. Each view uses its own descriptor bounds; a view address can lie inside a larger allocation. The observer preflights both tile views and copies only their active elements before the inverse.

The eleven capacities follow this order. FIELDS offsets identify descriptors, not archived addresses. The binder uses their live bases and pitches.

| Capacity slot | CPG_GP argument | FIELDS descriptor offset, bytes |
|---:|---|---:|
| 0 | PGFL | 3,416 |
| 1 | PGMV | 1,856 |
| 2 | PGMVS | 1,992 |
| 3 | PGMVT1 | 2,104 |
| 4 | PGMVT1S | 2,240 |
| 5 | PGFLT1 | 3,552 |
| 6 | PSP_RR | 11,144 |
| 7 | PSP_SB | 10,256 |
| 8 | PSP_SG | 10,544 |
| 9 | PSD_VF | 13,296 |
| 10 | PSD_VV | 14,624 |

Callers supply complete live mapped paths, alias destinations, owner records, scalar owners, descriptors and arrays. Eight-byte records and floating-point arrays require eight-byte alignment; the block scalar requires four-byte alignment. Every complete span must be nonwrapping. Mutable local outputs, pressure work arrays and selected global outputs must be disjoint from each other and from all input records and owners, except the source-defined field sections. Actual producer ownership and operating-system mappings cannot be established by a pointer value alone. The binder does not validate the remaining raw CPG_GP carrier pointers or prove every alias relation. Those are explicit caller prerequisites and are checked separately in the live gate.

The initialized 64-byte owner retains its 800-byte model owner, 4,275,088-byte MODEL, 529,288-byte FIELDS, 67,616-byte configuration and complete array owners. It borrows the same 20,400-byte Geometry and 4,096-byte partition as startup and the sidecar. These owners must remain alive through the transform and every tile consumer. The 80-byte CPG_GP dependency record borrows physical constants, top pressure, the accepted dynamics maps, the live tracer namespace and false logical controls. Five separate pressure work arrays retain the accepted full and half-level extents. The [CPG_GP contract](../dynamics/forecast_grid_calculations.md) defines all 75 carrier capacities, physical units and input limits.

## Source order and bounds

The checked model has `LGRADSP`, `LPGFSF` and `LPGREUSE` false, `LTWOTL` true, and first-step iteration controls zero. UPDTIM produces the live step interval; the observer does not compute it. The inverse writes the current seven motion fields and three surface motion fields into the same initialized owners. The first-step GPTF2 call copies current winds into their previous-wind slots before HYD. The inactive old thermal and pressure branch is skipped by the original two-level condition. Source-unwritten field bytes retain their incoming bits.

The original CPG_GP seam executes GPTF2, terrain-gradient map products, surface-pressure conversion, hydrostatic calculations and transport-field initialization. The original 75-address reference and accepted 76-address assembly parent receive the same inverse-produced inputs. The checking driver supplies complete local carrier storage and probes these existing entries; it supplies no omitted numerical calculation. It restores the exact pre-call tile bytes between the original and native probes. It then retains both complete results. This is component verification; it does not provide an autonomous enclosing CPG caller.

Before the inverse, all four ranks stop at a live-address hold. A read-only observer checks every complete role span, eleven global owners, the five pressure work arrays per tile, actual horizontal Geometry rows and their vectors, source controls and eight actual forwarding targets. Only a separate sealed admission releases the hold. During each CPG_GP call, the six complete global motion/tracer owners are read-only except the selected tile pages; the other bytes on those pages are compared. Complete local carriers, inactive columns, metadata, raw floating-point status and allocation guards are also checked.

One GiB is 1,073,741,824 bytes. The named post-load transform and tile payload is 141,543,805,657 bytes per rank. Retaining the conservative decoder payload and an explicit 32 GiB execution reserve gives 226,589,125,265 bytes per rank. That reserve is an enforced allowance, not an analytic bound for public transform, MPI or allocator internals. Each rank has a 256 GiB virtual-address limit and a 225 GiB resident-memory cutoff. The node job has a stronger 240 GiB total memory cutoff, including file cache. The driver samples every two seconds and has a 2,100-second process deadline. These are correctness controls; no timing comparison follows from this run.

## Scope

This gate uses actual loaded initial fields, actual initialized metadata and the accepted numerical inverse provider. Its new exact comparison begins at CPG_GP. It does not rerun the accepted inverse comparison bank. Only the first and final local tiles are checked; the full grid-point scan, packed-buffer clear, selected physics, later time steps and a complete forecast remain separate. The pending CALLPAR providers and their enclosing forwarding remain outside this checkpoint. No full transport parent or retained R66 owner-cap extension is admitted.

## Acceptance

Four ranks each complete one accepted inverse call and two original/native CPG_GP pairs. The first and final tiles give eight genuine original calls and eight native calls, with 17,254,944 complete output and defined status bytes agreeing exactly. Each raw 40-byte probe record is retained. The defined status comparison contains FPCR, FPSR and `errno`; the void return register is diagnostic. Original CPG_GP uses `x18` as scratch and has ABI mask 2; all native masks are zero.

Both routes pass 250,344 independent relations, using the unchanged accepted pressure, map, hydrostatic, kinetic-energy, temperature, gas, wind-force, water-selection and exact state-transfer laws. The arithmetic checks use 90-digit decimal evaluation with the existing rounding bounds. Whole metadata and scalar comparisons preserve 78,279,168 bytes. All tracked owned allocations are released, and all four numerical processes terminate. Thirty-nine integer-only refusal cases preserve the full argument table without a numerical call. Historical accepted comparison banks are reused unchanged.

Two fresh isolated assembly builds reproduce both complete qualified objects. The complete pre-inverse observer admission passes before the numerical calls.
