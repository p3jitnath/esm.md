# ICESTATENEMO Contract

The [physical note](../../../../../formulations/openifs/surface/coupled_sea_ice.md) describes the column mapping. The direct [assembly](../../../../../src/openifs/surface/icestatenemo.S) implements every optional field in the complete arpifs/climate/icestatenemo.F90 source.

## Inputs and outputs

The nine addresses are YDMCC, KSTGLO, KIDIA, KFDIA, PTHKICE, PSNTICE, PALBICE, PTEMPSEA and PTEMPICE. The first object is the original TMCC record. The three scalar indices are signed 32-bit integers. Each of the last five addresses is either null for an absent optional field, or a contiguous FP64 slice beginning at its selected KIDIA cell. The slice contains KFDIA minus KIDIA plus one cells when that count is positive. Each output has a distinct owner and does not overlap a consumed input. The caller retains cells outside the selected slice. Buffer addresses have eight-byte alignment and integer addresses have four-byte alignment.

The measured TMCC record has 7,584 bytes. LNEMOCOUP is at byte 6,796, and the rank-one CPLNG_FLD descriptor is at byte 7,360. A coupling-field record has 352 bytes, with its rank-three FP64 D descriptor at byte 240. The five original field indices are at bytes 7,528, 7,532, 7,524, 7,432 and 7,520 in optional-output order. Derived-record stride is positive. Data has positive first-axis stride and one-cell second and third dimensions with lower bound one. The selected global interval starts at KSTGLO minus one plus KIDIA. Qualified blocks contain at most 4,096 cells and lie inside the input owner. The descriptor layout and precision are measured from the unchanged original types.

## Complete operation

If coupling is disabled, return every optional owner unchanged. Otherwise calculate IST as KSTGLO minus one plus KIDIA and IEND as KSTGLO minus one plus KFDIA. In original order, copy the ice-thickness field when its output is present, then snow thickness, ice reflectivity, sea temperature and ice temperature. Each value is the original REAL conversion from ocean precision to atmospheric precision. Both precisions are FP64 in this build, so integer 64-bit loads and stores preserve all value bits, including signed zeros. There is no equation evaluation, reduction, interpolation or omitted driver stage.

The canonical returned record contains all five complete caller-owned output arrays in that order, including unselected and absent-field cells. The accepted physical scope requires nonnegative consumed thicknesses, reflectivity from zero to one, and consumed temperatures from 160 to 340 K. Passive and absent fields are not physically interpreted.

## Arm interface

The first eight addresses use x0 through x7 and the last address is read from the caller's stack pointer. The direct function preserves saved integer and floating-point registers, stack alignment, FPCR and FPSR. It requires FPCR zero and checks active descriptors, selected bounds, alignment and owner overlap before any public copy. It uses no numerical Fortran child. Profiling remains separate from the copied physical values.

## Original-first evidence

Before emission, twelve protected original calls pass 11,160 complete owner bytes and 2,198 independent copying and physical relations. Cases cover each optional field separately, all fields, no fields, inactive coupling, cropped and empty selections, one column and a larger block. Original status stays zero and errno stays 47. The 24 protected native placements pass 22,320 complete owner bytes with zero differences and 4,396 independent relations. Six full nine-address interface cases preserve all saved registers, stack alignment, control, seeded status and errno. Nine shared-owner entry rejections preserve all 680 public owner bytes per case. Five paired parents pass 3,040 complete owner bytes and 470 additional independent relations, including inactive and absent fields. Two profiled pairs preserve exact status and errno. A source-first negative reflectivity case remains rejected with all 680 public bytes unchanged. Actual forecast acceptance remains pending.
