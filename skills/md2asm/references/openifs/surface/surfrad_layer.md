# SURFRAD_LAYER Contract

The [physical note](../../../../../formulations/openifs/surface/surface_radiation_inputs.md) gives the wind, calendar and sea-ice inputs. The direct [assembly](../../../../../src/openifs/surface/surfrad_layer.S) contains the complete 156-line arpifs/phys_ec/surfrad_layer.F90 operation and its closed numerical children.

## Complete operation

For each selected column at KLEV, multiply the eastward wind by itself, multiply the northward wind by itself, add the two rounded products and apply the correctly rounded hardware square root. Keep FP64 after every operation and forbid fused multiply-add. The result supplies the complete radiation calculation and becomes the local wind diagnostic.

Read the original global integers NINDAT and NSSSSS and the FP64 RDAY value. Split NINDAT into year, month and day using the original integer division and remainder order. Round RSTATI and RDAY to the nearest integer with ties away from zero. Form NSSSSS plus rounded RSTATI, divide by rounded RDAY to get the day increment and retain its remainder as the second of day. Call the complete [UPDCAL child](../physics/updcal.md) with private date outputs and a private twelve-month table, using output unit minus one. The initial date has year 1600 through 3000, RDAY is exactly 86,400 seconds and the accumulated integer time is nonnegative without 32-bit overflow.

Set the selected cells of the private ice-reflectivity array to positive zero. When LNEMOLIMALB is true, call the complete [ICESTATENEMO child](icestatenemo.md) with only PALBICE present. That child copies a supplied field only when LNEMOCOUP is true. Then call the complete [SURFRAD wrapper](surfrad.md), passing every original field, the updated date and the private ice reflectivity. The complete [controller](surfrad_ctl.md), canyon calculation and bounded math routes remain unchanged apart from private names used to count genuine calls.

## Model records

The twelve ordinary addresses retain original order YDSURF, YDMCC, YDERAD, YDEPHY, YDRIP, KDIM, PAUX, STATE, LLKEYS, AUXL, PSURF and SURFL. The table gives measured record sizes and consumed members. A descriptor is the record that gives an array's address, shape and memory spacing.

| Record | Bytes | Consumed members |
| --- | --- | --- |
| Surface metadata | 18,224 | Field-index pointers and the albedo-coefficient interval |
| Coupling settings | 7,584 | LNEMOCOUP, LNEMOLIMALB and the selected ocean field |
| Radiation settings | 2,040 | NSW at 60 and NLWEMISS at 72 |
| Physics settings | 448 | Registered surface handle at 440 |
| Time settings | 175,976 | RSTATI at 32 |
| Dimensions | 192 | KIDIA 0, KFDIA 4, KLON 12, KTILES 24, KSTGLO 28 and KLEV 48 |
| Auxiliary inputs | 1,992 | Solar-cosine descriptor at 1,360 |
| Model state | 1,240 | Wind-component descriptors at 32 and 120 |
| Local switches | 664 | Hemisphere descriptor at 128 |
| Local diagnostics | 2,336 | Wind at 8 and particle counts at 72 and 136 |
| Surface fields | 13,680 | Background fields, snow, temperature, water, soil type, lake ice, reflectivity and emission |
| Local surface fields | 2,096 | Tile fractions and spectral reflection, emission and tile albedos |

Metadata pointers select background reflectivity, forest type, urban cover and high vegetation cover through MP at target byte zero. Snow, temperature, water and lake-ice pointers use MP9 at target byte eight. The measured pointer offsets and field descriptors are explicit in the assembly. No record allocation or field lookup is delegated to a numerical Fortran routine.

## Storage and Arm interface

Every local array is contiguous in Fortran column order, with lower bound one and at least KLON rows. Local owners have at most 4,096 rows, positive field extents and valid selected indices. The field indices and requested spectral slices stay inside their parent owners. The registered scheme handle retains the [wrapper's accepted lifetime](surfrad.md). All nine mutable data owners are distinct from one another, all consumed inputs, the scheme object and the model records. Object and FP64 addresses have eight-byte alignment, and scalar integer addresses have four-byte alignment.

The first eight ordinary addresses use x0 through x7 and the other four start at the caller's stack pointer. Preserve all saved registers, stack alignment, the floating-point control register (FPCR) and inherited floating-point status (FPSR). A fixed 73,728-byte frame holds original addresses, date values, field descriptors and two private arrays of up to 4,096 FP64 values. Compute the wind into private storage and use that exact field for the radiation child. Publish the selected wind cells after the complete child succeeds, so a rejected child interface cannot partly change a public wind owner. This store schedule preserves every numerical dependency, rounding point and consumed child value because the owners do not overlap.

The canonical output contains the complete wind owner, then complete PALBD, PALBP, the whole surface diagnostic owner containing PALB, PSPECTRALEMISS, PEMIT, PALBTI, PCCNL and PCCNO in that order. Preserve unselected rows, unused spectral columns and unrelated fields in a shared diagnostic owner. The twelve model records and registered scheme remain byte-identical. Counting wrappers record genuine children and supply no numerical stage.

## Original-first evidence

Before direct emission, seven protected complete original calls pass 23,760 owner bytes and 11,591 independent 120-digit relations. These include enabled and disabled coupling, a present but inactive ocean field, a single column, an empty interval, a year boundary and the 2000 leap-day boundary. Independent wind norms and Gregorian dates accompany the accepted surface-radiation physical checks. Every model record and the scheme object remains unchanged, including unused spectral columns. Fresh status is 16, control is zero and errno is 47. Earlier child physics, exact arithmetic and helper proofs are reused. The direct native body then passes fourteen protected placements with 47,520 complete owner bytes, zero differences and 23,182 independent relations. Seven complete Arm interface probes preserve saved registers, the stack, floating-point control, inherited status and errno. Thirteen shared-memory rejection cases preserve every public owner.

The private ice-copy entry accepts one or more coupling field records and checks the index of every requested output against the actual upper bound. The original layer passes a single requested albedo field. The independent original checks include that one-record table. This narrow descriptor extension changes no copied value and leaves the previously frozen stand-alone ice entry unchanged.

The paired gate runs the complete original first in private output owners and admits it through independent wind, Gregorian-date, ice-albedo and complete radiation checks. Seven complete pairs pass 23,760 output bytes with zero differences and 11,658 independent relations. Genuine private calendar, surface wrapper, controller and canyon calls each total seven, while the optional ice-copy entry totals six. The gate compares all defined consumed child values and every declared child output bit. Unselected automatic ice scratch cells are unused and are excluded from the consumed-input trace. Two profiled pairs and one process started and called from a different directory also pass. An independently rejected temperature preserves all nine shared public output owners before native execution. Counting observers provide no omitted physics.

## Actual Forecast Acceptance


| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| surfrad_layer | 2,150 | 130,032,000 | Complete returned surface-radiation layer owners |

Shared saved-file evidence and its limits are in the [coverage record](../../../../../src/openifs/README.md#shared-coarse-forecast-evidence).

## Runtime Provider Binding

The unchanged complete parent and its five numerical children also supply the runtime provider. This runtime binding admits 1 through 4,096 columns and 1 through 512 layers. The live layer count selects the wind plane within its admitted descriptors, and each complete owner remains within the existing 67,108,864-element limit. All field, date, tile, scheme and mathematical input bounds above still apply. The same assembled body supports each admitted resolution.

The original names `RDAY`, `NINDAT` and `NSSSSS` refer to assembly-owned producer storage. `RDAY` is the eight-byte value at physical-record offset 40. The date and starting second are four-byte values at clock-record offsets 0 and 4. The physical and clock producers must finish before this consumer runs. These aliases share the producer bytes, so different supported dates do not require a new solver or a copied constant.

Three transparent assembly branches connect the calendar, ice-copy and surface-wrapper child names to their accepted bodies. Two existing branches connect the controller and canyon bodies. A tail branch forwards the original register and stack arguments directly, with no new frame or numerical operation. The omitted weak callbacks were verification observers and supplied no calculation. Six complete numerical objects remain identical to their accepted versions. All existing public alias instructions and relocations remain unchanged, with only the three new branches appended.

A focused binding check confirms the five actual branch targets, all three live data addresses and their global offset table entries, which are the linker’s stored addresses. The complete 520-byte physical record matches its accepted producer. Clock producers at the operational date and a leap day update the same date and second aliases. The linked numerical route contains direct assembly and permitted mathematical libraries, with no original OpenIFS calculation or state. Existing independent physics, exact complete-output, protected-buffer, status and Arm interface results are reused without another numerical bank. Complete `CALLPAR` forwarding, later surface-scheme setup and the loaded operational weather join remain pending.
