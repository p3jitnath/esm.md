# Radiation Grid Driver Contract

Revision 1 freezes the selected `RADINTG` interface and ordered mathematics from the original `arpifs/phys_radi/radintg.F90`. The [physical input](../../../../../formulations/openifs/radiation/radiation_grid_driver.md) defines equations P01–P04. The direct parent and its physical calculation children are assembly. Its frozen power helper is compiled C and remains a declared dependency of this mixed forecast. Independent parent checks, genuine live source comparisons and exact forecast files pass within the scope below.

## Selected inputs and arithmetic

There are 2048 model points, 2048 radiation points, nineteen layers and twenty layer boundaries. Each radiation block has eight columns, so there are 256 blocks. Columns change fastest in each Fortran-order array. The selected modern radiation route has equal model and radiation grids and equal sine latitude within each block. Interpolation, diagnostic field output, prescribed ozone, prognostic aerosol, stochastic changes and legacy radiation are inactive. Other controls or shapes need a new contract.

FP64 stores each real value in 64 bits. Require floating-point control register `FPCR=0`, with nearest-even rounding, gradual underflow and preserved signed zeros. Each multiplication, addition, subtraction, division and square root rounds separately. Preserve ordered operands, intermediate rounding and deterministic integer decisions. Fused operations, contraction, reassociation, approximate division or square root, reduced precision and fast math are prohibited.

For P01, first add two to the captured curvature coefficient and multiply by that coefficient. Above the strict `1e-10` threshold, square the supplied cosine, add the curvature term, take the square root, subtract the cosine and divide the coefficient by the result. Equality takes the floor branch. For P02, form the two weighted products in their original order, add them, form the denominator, round its reciprocal and multiply the numerator by that reciprocal. The top temperature uses the original extrapolation and the bottom temperature copies skin temperature.

Pack skin temperature by a rounded square followed by another rounded square. Recover its fourth root through the accepted original-rounding `POWER` helper. Replacing it by two square roots changes the arithmetic. Clamp the first six albedo bands, cloud fraction and water inputs without modifying their supplied forecast owners. Preserve the original humidity limits and particle-concentration limits from the physical input.

Packing uses 78 ordered `INDRAD` operations, 295 input fields, 125 output fields and 933 total fields. Disabled fields keep `NUNDEFLD=-99999` and remain unread. Group columns by exactly equal sine latitude before aerosol, ozone and greenhouse preparation. `NGHGRAD=21` selects all supplied gas profiles and replaces ozone by profile ozone times layer pressure depth. Retain all twelve supplied MACC aerosol mass fields, the fifth legacy-aerosol replacement and earlier assignments that are later overwritten.

For P03 and P04, preserve the original ordered six-band sums and all separately rounded products, divisions and subtractions. Update the local albedo only on the specified positive-flux branch. Add the same surface net-flux change at each height, then apply the original bounds. Retain the effective top-flux calculation and its later overwrite. Divide shortwave outputs by the separately ordered product `RII0*RADJUST*mu_e`. Clamp transmission and longwave derivatives to zero through one. Keep longwave net flux in W m⁻² and copy the same net field to `PEMTD` and `PEMTU`.

## Assembly dependencies

| Child entry | Accepted assembly and purpose |
| --- | --- |
| `md2asm_radact` | [Aerosol and ozone preparation](../../../../../src/openifs/radiation/aerosol_and_ozone_preparation.S), aerosol climatology |
| `md2asm_grid_ozone_layers` | [RADOZC](../../../../../src/openifs/physics/radozc.S), the original eleven-address ozone interface, assembled with `RADOZC_SYMBOL=md2asm_grid_ozone_layers` |
| `md2asm_grid_greenhouse_profiles` | [RADGHG](../../../../../src/openifs/physics/radghg.S), greenhouse profiles, with its accepted entry renamed locally |
| `md2asm_grid_gas_layer` | [Gas layer interpolation](../../../../../src/openifs/physics/interp_gas.S), called by the greenhouse child with its accepted entry renamed locally |
| `md2asm_radiation_field_preparation` | [Radiation field preparation](radiation_field_preparation.md), complete accepted atmospheric transport |
| `md2asm_pow_original_rounding_candidate` | Frozen original-rounding C mathematical helper, used for the fourth root |

Unchanged child science and exact-output proofs are reused. The physical calculation children use their accepted assembly bodies, including the eleven-address `RADOZC` interface. The power library uses the retained `original_power_candidate.c` and `round_product_sum.c` sources. Its independent power checks and exact bits, status and error-code comparisons remain local. A complete autonomous assembly forecast must replace this mathematical dependency with direct assembly.

Allocation and byte movement use `calloc`, `memcpy`, `memset` and `free`. Logging uses `puts`, `gstats_` and the original DrHook interface. These calls supply no numerical calculation. The read-only hook `md2asm_grid_stage_observe_r5` observes packed fields before transport and before output updates; the local verifier provides it and preserves raw floating-point status. Verification tools and source controls remain under the ignored `.runtime/` directory.

## Interface and bounds

The application binary interface, or ABI, defines argument addresses and register obligations. The original `radintg_` interface has 59 address arguments: registers `x0`–`x7` carry the first eight and the caller stack carries the other 51. The descriptive public entry `md2asm_radiation_grid_driver` aliases the unchanged qualified entry `md2asm_radiation_grid_driver_primary_r5`. Defining `RADINTG_EXPORT_ORIGINAL_SYMBOL` also exports `radintg_` at that same address. Integers and logical values occupy four bytes; real values occupy eight. Require natural alignment, valid physical inputs and actual descriptor bounds.

An owner is an allocated buffer or a recorded view of that buffer. The complete logical owners total 13,180,768 bytes in 136 views: 6,765,456 returned bytes and 6,415,312 read-only bytes per call. The model owner has 4,275,088 bytes and the geographic owner has 17,096 bytes. Twelve inactive arrays have one real element each. `PPERTT`, argument 44 with zero-based numbering, has zero extent and remains unread. Declared nominal array shapes do not enlarge these actual buffers. Keep every inactive byte and descriptor word.

The four geographic coordinate descriptors lie at bytes 8664, 8792, 8920 and 8984, each with 2048 FP64 values. The model surface handle at byte 1578328 points to a separate 11,584-byte `YOS_SURF` record; its minimum-albedo scalar is at byte 6776. Native assembly loads these stored values and owns the surface query's diagnostic hooks. The active greenhouse provider is the separate 928-byte record addressed by `__yoeradghg_MOD_yradghg`, containing two coordinate and nine gas arrays. Preserve the complete accepted coefficient owners, descriptor ranks, bounds, strides and element sizes. Integer coefficient tables use four-byte elements.

Returned owners must not overlap consumed input owners, except for the unchanged model scalar views: integer `KMODE` at model byte 1608732 and real `PCCO2` at model byte 1856416. The assembly checks these exact aliases before allocation and delayed commit. The private workspace has 22,125,456 bytes and the frame has 5120 bytes. Separate saved registers, outgoing argument addresses and local descriptors. Keep caller metadata, read-only owners and all unselected outputs unchanged.

Preserve `x18`, `x19`–`x29`, the return address, the low 64 bits of `d8`–`d15`, sixteen-byte stack alignment and FPCR. The captured `LHOOK=1` setting retains original profiling names. The original source has recorded ABI mask `2097152`, which identifies its `x18` limitation; the comparison bridge contains that defect. Require native ABI mask zero. Compare immediate raw FPCR, arithmetic-status register FPSR and library error code `errno` without masking. The protected fixture enters with FPCR zero, FPSR 16 and errno 2; both return FPCR zero, FPSR 24 and errno 34.

## Actual acceptance checks

Three protected complete source/direct calls compare 39,542,304 owner bytes with zero differences. They cover genuine inputs, sunlight threshold equality and adjacent FP64 values, night, absorbing and reflecting albedo, both local-albedo branches, supported scalar aliases, unused placeholders and read-only bounds. Independent decimal calculations at 85 digits check sunlight, boundary temperatures, packed physical limits, the transmission/reflection relations and layer-flux balance with a separate FP64 rounding bound. Native ABI and raw immediate status pass. The source limitation remains recorded.

The radiation-only forecast advances the simulated state by 24 hours and makes 25 genuine source/direct parent pairs under the same live setup. They compare 329,519,200 complete owner bytes and check 14,899,200 independent parent relations with zero byte differences, native/source ABI failures or raw status differences. Direct child counts are 6400 aerosol, 6400 ozone, 6400 greenhouse, 6400 radiation-field, 51,200 fourth-root and 1950 packing-index calls. The original source comparison forwards all 6400 radiation-field and inner-column calls with zero additional child-native credit. Unchanged accepted inner physics is reused.

The forecast exits successfully and all ten saved files match the corrected original-only reference exactly across 618,140 bytes. They are the five `ICMSHepc8` and five `ICMUAepc8` files at hours 0, 6, 12, 18 and 24. Zero differing raw bytes is the acceptance limit; no output is rounded, masked or normalised. These checks qualify this selected `RADINTG` calculation in the shared numerical forecast. They do not establish an autonomous assembly forecast, whole-forecast independent science or comparative performance.

An older cold capture lacks some runtime setup. Both original and direct cold returns differ from its archived final flux bits. The original artifact and detailed investigation remain local. Acceptance uses the complete live source/direct pairs under one setup and the exact saved files.

Detailed receipts, original sources, protected fixtures, failures, build commands and observations remain local under `.runtime/openifs/radiation_grid_driver_7358525/focused_qualification_r1/`. The run uses job 7358525 on `nid010681` and local memory. Focused qualification uses CPU 64, and the forecast comparison uses CPU 32. The direct primary object has no prohibited fused or approximate arithmetic instructions. No comparative timing is reported.
