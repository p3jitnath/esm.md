# Initial Surface-State Loading

Revision 1 loads the selected coarse model's surface state directly from its GRIB input file. It composes the accepted [reader](initial_surface_field_reader.md), [field selector](initial_surface_field_selection.md), [physical conversions](surface_initial_state_conversion.md) and [blocked placement](initial_surface_state_placement.md). A blocked array stores nearby grid points together. The [physical formulation](../../../../../formulations/openifs/input/surface_initial_state_conversion.md) describes the original surface adjustments. This composition changes no physical equation or arithmetic order.

## Interface And Storage

The application binary interface, or ABI, is `int md2asm_load_initial_surface_state(path, configuration, configuration_bytes, owners, owner_table_bytes, parameters, parameter_bytes)`. Registers `x0` through `x6` carry the seven arguments, and `w0` returns the status. The path is a readable zero-terminated C string. The read-only configuration contains 288 raw 64-bit words, the owner table contains five pointer/capacity pairs and the parameter table contains 52 signed 32-bit identifiers. Their formats remain those of the conversion and placement children.

| Complete mutable owner | Fortran shape | Required bytes |
| --- | --- | ---: |
| Soil state | `(24,4,6,86)` | 396288 |
| Lake state | `(24,14,86)` | 231168 |
| Snow state | `(24,5,10,86)` | 825600 |
| Skin temperature and water reservoir | `(24,4,86)` | 66048 |
| Fixed surface properties | `(24,38,86)` | 627456 |

The configuration needs 2304 bytes with eight-byte alignment, the owner table needs 80 bytes with eight-byte alignment and the identifiers need 208 bytes with four-byte alignment. All caller storage must be mapped and nonwrapping. Complete mutable owners are mutually disjoint and disjoint from every read-only argument span. The caller provides their exact complete incoming bytes. The native source bridge checks the frozen live field requests, destinations and shapes before calling this entry.

## Ordered Execution

Allocate 3479008 private bytes with `malloc`. The first 2293760 bytes hold all 140 decoded records, followed by 5600 metadata bytes, 770048 bytes of selected 2D fields and 409600 bytes of layered fields. Call the four direct stages in that order. Only final placement writes model owners, after every decode, selection and physical conversion succeeds. Free the private storage once.

The selected route has 2048 global points, a block width of 24 and five snow layers. It retains the frozen 47 plus 5 field order and performs no interpolation. Unselected owner planes and all final-block padding retain their incoming bytes. The preceding surface-default assignments remain a separate initialisation stage. This controller does not replace inherited bytes with invented zeros.

Return 0 for success, 1 for invalid basic pointers, capacities, alignment or floating-point mode, and 2 for allocation failure. A child failure returns 100 plus the reader code, 200 plus the selection code, 300 plus the conversion code, or 400 plus the placement code. Every owner remains unchanged unless placement succeeds. Each child's existing rejection and buffer rules still apply.

## Arithmetic And Library Boundary

FP64 is a 64-bit floating-point number. FPCR controls floating-point execution and must be zero. Preserve FPCR, `errno`, `x18`, saved integer registers and the required halves of saved vector registers. The 176-byte stack frame remains aligned to 16 bytes. Protect FPSR, the arithmetic status register, around allocation and release, retaining every flag from the direct physical conversion. No arithmetic is fused, approximated or reordered.

The controller and all four numerical and storage stages are direct assembly. Its other calls are ordinary memory allocation and file services plus the ecCodes C file-format interface. A temporary native SUGRIDG bridge still reads typed original metadata through local Fortran getters. Those getters supply only constants, bounds, owner addresses and field identifiers. They perform no forecast calculation. Complete model construction, earlier defaults, startup diagnostic statistics and an autonomous executable remain separate work.

## Current Evidence

Four focused composition cases and three seeded ABI paths pass against the independent whole-slice storage control, using real original converted fields and arbitrary complete owner preimages. All 2146560 owner bytes agree. Missing files, short configuration and an absent required parameter leave every owner unchanged. Status, read-only input and protected bounds also pass. The unchanged child physics and interface checks are reused.

The actual original SUGRIDG packet also passes from all captured incoming bytes. The direct controller reads the real GRIB file and reproduces all 2146560 returned bytes, including untouched planes and padding. FPCR 0, FPSR 16 and errno 2 agree. Source and ABI review passes. The native original-interface bridge also passes three status cases with zero original numerical calls. The joint native forecast passes all 27486113 bytes in 685 complete final owners and all 618140 bytes in ten saved files, with matching immediate status and a positive complete input counter. The typed metadata boundary and earlier model construction remain, so this component does not establish full autonomy.
