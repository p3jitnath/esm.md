# Surface Group Initialization

Revision 2 retains the selected route and adds the operational metadata domain. It defines the selected numerical-storage initialization stages from INI_SFLP2 and INI_SFLP3 in SURFACE_FIELDS_MIX. A surface group holds related fields, such as soil temperatures or lake quantities. A layered group gives each field several depths. This utility prepares caller-owned group and field metadata before registration. It changes no physical state and uses no OpenIFS object constructor, global data or callable. Original console printing and hook services remain outside this numerical-storage utility.

## Interface And Source Inputs

The planned interface is int md2asm_initialize_surface_group(controls, group, fields, field_bytes). Registers x0 through x3 carry a read-only 48-byte control record, one writable TYPE_SURF_GEN record, the writable complete array of field records and its capacity. The caller owns all storage. Controls and group require four-byte alignment, while fields require eight-byte alignment. All full declared ranges must be mapped, nonwrapping and disjoint.

Controls hold signed 32-bit kind at byte zero, layer count at four, multi-time-level logical at eight, NOFFTRAJ and NOFFTRAJ_CST at twelve and sixteen, NUNDEFLD at twenty, an exact sixteen-character group name at twenty-four and record count at forty. Bytes forty-four through forty-seven are reserved and unchanged. Kind is two or three, the logical is zero or one and count is one through 694. Kind two requires layer count minus one, while kind three supports zero through 64 layers or the additional exact count 137. The two trajectory offsets are nonnegative signed integers. NUNDEFLD is minus 99,999 for the selected source or minus 999,999 for the operational source. It is an explicit input and receives no invented global definition.

The typed original-source query confirms a 60-byte group, 64-byte two-dimensional fields and 288-byte layered fields. It records every member offset before emission. Empty layered groups retain a zero layer count. INI changes only FINALISED, NLEVS, IPTR, LMTL, CGRPNAME, NDIM5 and the two trajectory offsets in the group. NUMFLDS, NDIM, IPTR5 and L3D retain their incoming bytes. In every complete field record it changes only MP, MP0, MP9, MP1, ITRAJ, LSET and IBUGFINDER. They receive NUNDEFLD in the four map slots, zero trajectory and set flags, and the one-based field index. Every other field byte, including padding, declared-default storage and descriptor words, remains incoming. No payload is allocated or initialized.

## Record Layout

The group contains eight consecutive four-byte integers at offsets zero through 28, in the order NUMFLDS, NDIM, NLEVS, IPTR, IPTR5, NDIM5, NOFFTRAJ and NOFFTRAJ_CST. Its sixteen-byte name starts at 32. Four-byte logicals L3D, LMTL and FINALISED start at 48, 52 and 56. Both field kinds begin with seven four-byte words MP, MP0, MP9, MP1, ITRAJ, IBUGFINDER and LSET at offsets zero through 24. Only these 28 field bytes change here. The remaining 36 two-dimensional bytes or 260 layered bytes retain their incoming values. The layered record's four 64-byte array descriptors begin at 32, 96, 160 and 224 and remain untouched.

## Return And Acceptance

Validate all control values, capacities and complete ranges before the first write. Return zero on success or two before mutation for unsupported inputs. Integer operations alone prepare the records, so preserve FPCR, FPSR and errno without changing them. The leaf uses no stack and preserves x18 and all saved integer and vector registers. It has no external dependency.

Compare complete group and field arrays with genuine original INI calls under distinct incoming byte patterns. Include both record kinds, a single record and the full source allocation of 694 records. Keep source-unwritten bytes and guards in every comparison. Capture native ABI and arithmetic status immediately and record original logging status separately, with no whole-body service-equivalence claim. Verify the map slots, one-based indices, group name and layer controls independently. Check invalid ranges and controls before mutation, then inspect a pure assembly process and obtain independent source and ABI review. Reuse accepted children and run no model forecast.

## Completed Checkpoint

Six genuine source cases compare all 644,744 group and field bytes, including inactive zero-layer groups and complete 694-record allocations. They preserve 566,696 source-unwritten bytes and pass 19,494 independent map, index, name and layer relations. All 23 immediate calls and eleven before-mutation rejects retain zero native ABI masks and the declared numerical status. The original logging status remains separately recorded. All 432 guard bytes remain unchanged. A pure assembly process writes the complete 199,932-byte zero-layer example exactly, with no shared-library dependency or original data. Independent source and ABI review passes.

The operational extension changes only the two input-admission predicates. Its complete 137-layer use is accepted through the [operational surface metadata route](selected_surface_configuration.md#operational-metadata-route), including all source-unwritten bytes and one complete selected-route replay. The earlier independent child checks are reused without repetition.
