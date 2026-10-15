# Snow Profile Initialisation Contract

Revision 2 implements the [physics note](../../../../../formulations/openifs/surface/snow_profile_initialisation.md) as the complete SURFWS_INIT_SL numerical entry. It selects all calibrated profile coefficients, finds the nearest temperature and density centres and initialises every returned layer, boundary field and active-layer index. The source and genuine tables are frozen locally before generation.

## Ordered Calculation

The profile bank has 27 centres in each group. Twelve temperature groups cover day and night with 2, 3, 4, 5, deep-seasonal and glacier profiles. Five density groups cover 2, 3, 4, 5 and deep profiles. Preserve each decimal table value as the original default-real binary32 value converted exactly to binary64. Temperature regression arrays with no reader or returned field have no numerical effect.

Day means that the cosine of solar zenith exceeds 100000 times FP64 machine epsilon. Seasonal snow means that supplied snow mass is below the glacier threshold. Depth thresholds are 0.15, 0.20, 0.25 and 0.50 metres. Terrain below 50 metres uses the five-layer group in the 0.25 to 0.50 metre interval. Higher terrain selects the group from the incoming active-layer count. Glacier temperature coefficients use the glacier group, while its density coefficients still use the depth and terrain selection.

For each centre, subtract the three features, square each rounded difference, add the first two squares and then the third, and take the hardware square root. Select the first smallest rounded distance. Preserve the square root because its rounding can create ties. Return all selected mean and standard-deviation coefficients. Evaluate the top-density polynomial with separate products and a left-to-right sum.

Seasonal snow uses the capped skin temperature at the top, the supplied snow temperature in interior layers and the capped soil temperature at the bottom. Every layer receives the supplied density. The first layer receives supplied snow mass and liquid water, while all later layers receive positive zero. Its maximum density comes from the soil settings. Shallow snow below 0.20 metres returns zero soil adjustment depth and preserves the incoming active-depth bytes. Deeper snow uses half the first soil depth and the selected snow interface when skin temperature is at least snow temperature, otherwise total depth.

Glacier initialisation sets the outgoing active-layer count to the full layer count after coefficient and middle-layer selection. It caps the top and remaining snow temperatures, assigns density 300 kilograms per cubic metre, assigns mass as density times each supplied layer depth and returns zero liquid water. Its active depth uses the bottom snow interface when skin temperature is at least snow temperature, otherwise total depth. Both branches return the capped mean of snow and soil temperature at the middle boundary.

## Interface And Bounds

The Arm application binary interface passes 39 argument addresses. Arguments are first column, last column, total columns, snow layers, centre count, solar cosine, terrain, soil temperature, skin temperature, total depth, snow interfaces, glacier threshold, layer depths, mean snow temperature, density, snow mass, liquid water, albedo, four layer outputs, three boundary temperatures, maximum density, adjustment depth, active-layer count, middle-layer index, active depth, two centre indices, four coefficient outputs, top density, constants and soil settings.

Real arrays use GNU rank-one or rank-two FP64 descriptors with eight-byte elements. Integer output arrays use rank-one four-byte descriptors. The base addresses the first logical element. A zero first stride means one element. Signed, independent strides and unprocessed columns are preserved. Real storage is aligned to eight bytes and integer storage to four bytes. Read module settings through the frozen TCST and TSOIL layout. The soil-depth member is a genuine contiguous allocatable with its original offset and integer lower bound.

The supported scientific domain has 1 to 4096 allocated columns, 5 to 512 snow layers, exactly 27 centres, finite nonnegative snow depth and mass, positive reference density, positive finite temperatures, finite ordered intermediates and albedo from zero to one. Incoming active layers are from 1 through the full layer count when total depth is below 0.20 metres, because this branch does not use that count as an interface index. Deeper snow requires at least 2 active layers, and terrain at least 50 metres requires 2 through 5 when total depth is from 0.25 to below 0.50 metres. Input and output owners are disjoint and cover their declared shapes. An empty active interval writes no output.

Preserve FPCR zero, nearest-even FP64 rounding, gradual underflow, all returned bits and saved general and floating-point registers. Use no numerical helper, fused operation, reassociation or approximate arithmetic. The assembly contains its complete tables, selection, distances, polynomial and layer initialisation. Its fixed 1024-byte frame preserves x19 through x29, the return address and d8 through d15. TCST is 128 bytes with melting temperature at byte zero. TSOIL is 2416 bytes with reference density at byte 1832, maximum new-snow density at byte 1960 and the soil-depth descriptor at byte 1584.

## Acceptance

Before emission, check the original entry against independent long-double profile distances, the calibrated density polynomial, seasonal water budgets and glacier layer masses. Include every table-selection branch, threshold neighbours, first ties, empty and partial intervals, signed strides, buffer guards and the untouched shallow active-depth field. The native entry must then return zero differing complete-owner bytes and preserve its immediate ABI. A paired adapter runs this complete entry and keeps the unchanged original only as a same-input shadow comparison. Actual forecast acceptance is recorded below, while timing remains a separate gate.

The original physical check passed before assembly emission. The protected native check passed 578 calls, 457,736,128 complete returned bytes and 21,776,974 independent relations with zero differences. It covers all twelve temperature and five density groups, 6,672 rounded first ties, 4096 columns, 512 layers, signed strides and untouched shallow active depths. The immediate 39-address register and FPCR check passed. Thirty-three paired calls pass 420,552 returned bytes and 28,130 independent relations with zero differences. Detailed input, table, build and relay records remain local. Timing remains unmeasured; actual forecast acceptance is recorded below.

The first actual forecast call contains 24 snow-free columns with one incoming active layer. A focused replay preserves all 30,144 captured original owner bytes. Six original and native cases with one active layer below 0.20 metres pass 157,824 complete output bytes and 19,008 independent relations with zero differences. The corrected paired guard passes the same cases and still rejects one active layer at 0.20 metres before the numerical entry runs. The direct assembly and all original equations remain unchanged.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 passes these positive actual calls with zero differing bytes. Each byte scope describes the complete owners compared by that routine.

| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| surfws_init_sl_mod::surfws_init_sl | 86 | 2,262,144 | Complete routine owners |

All ten saved files also match across 618,140 bytes. The accepted critical physics and interface checks are reused. These checks cover the declared routine domains and saved files. Whole-forecast physical verification, whole-process byte identity and comparative timing remain open in the [coverage record](../../../../../src/openifs/README.md).

## Shared Parent Status

The current shared-parent route retains one discarded hardware square root after each 27-centre classification. The original GNU 12.3 source uses a two-lane SVE square root whose final inactive lane contains the rounded soil-minus-skin temperature feature. A negative value sets the invalid-operation flag in the floating-point status register, or FPSR. The assembly executes the same discarded operation so this immediate status agrees with the source; valid distances, ties, coefficients and returned bytes remain unchanged. The first retained feature is -0.0005035400390625 kelvin. This status bridge reuses the accepted physical checks and exact R37/R39 parent status evidence. Its current enclosing route passes the joint final-state, status, ABI and saved-file gate, with no additional routine credit.

Build the shared-parent private binding with `-DORIGINAL_SYMBOL=md2asm_snow_profile_initialisation_private_entry`. The public `md2asm_snow_profile_initialisation` and this private name refer to the same body. The original Fortran entry remains the separate verification reference. This target-specific status operation is required for the recorded GNU 12.3 source on GH200 with a 16-byte SVE vector; it makes no wider compiler or vector-length claim.
