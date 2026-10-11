# Gas Optics Contract

This contract connects accepted gas-absorption and thermal-emission children. The original routine is `radiation_ifs_rrtm::gas_optics`. Optical depth measures the blocking strength of a gas layer. A spectral sample represents part of the radiation spectrum.

## Supported Inputs

Use 1 to 512 layers and 0 to 4096 selected columns from a contiguous full-column owner. Gas mass fractions, pressure and temperature use the accepted gas-preparation domains. Pressure and temperature have one more boundary than gas layers. The absolute top boundary can have zero pressure, while all remaining consumed boundaries are positive and increase towards the surface. The resulting layer means remain positive. The top face enters a constant unit conversion, a layer pressure difference and its adjacent mean, and it is never a logarithm operand or divisor. Every owner starts at column and layer label 1. The requested layers are the last layers of these owners.

The configuration has 140 longwave samples in 16 bands and 112 shortwave samples in 14 bands. A band groups adjacent wavelengths. Both ordinary and Spartacus spectral ordering are supported. Every consumed map is a complete valid permutation and its band labels agree with the accepted table grid.

Optional longwave albedo requires both atmospheric and surface emission outputs. A simple surface uses the accepted Planck children. A canopy uses all 140 supplied samples or a valid band-to-emission map. If albedo is absent, emission owners are not consumed and their supplied bytes remain untouched. Incoming shortwave flux is independently optional. A returned daylight spectrum requires both a lower and an upper pressure layer. The original Band 16 leaves its solar scratch unset when no upper layer exists, so that combination is outside the declared scientific domain. A one-layer canopy calculation can still omit the unused incoming spectrum.

Solar factors are positive and finite. Per-band scaling uses the original source's reordered map before its later reorder. This contract supports ordinary shortwave ordering or equal factors across all bands, for which that source convention has the intended physical meaning. The paired adapter records these switches and rejects an unsupported combination before writing outputs.

## Ordered Calculations

Add adjacent boundary pressures, then multiply by exactly 0.5. Do the same for temperature. Preserve the separate FP64 rounding of each operation. Pass every active gas species to the unchanged direct gas-preparation child.

Call complete longwave coefficient preparation, then all sixteen gas-absorption bands through the accepted parent. Aerosol depth is zero here because the aerosol stage follows separately. Reuse the complete child physics and table proofs. Continuum fractions may extrapolate outside 0 to 1 with valid adjacent table indices, as qualified by the genuine Band 13 replay.

When albedo is present, calculate atmospheric emission and simple-surface emission through their complete native children. Subtract each albedo from exactly 1, then multiply its emitted sample. Canopy emission is a lossless coordinate transfer.

Reverse the vertical order and apply the configured spectral permutation. Clip each longwave depth to the configured nonnegative minimum. Prepare shortwave coefficients and initialise all shortwave scratch depths, scattering fractions and incoming samples to positive zero before the complete shortwave parent. Nighttime children leave these zero samples intact.

If requested, multiply each incoming sample by its band factor. Sum all 112 samples in the unchanged original reduction order. For daylight, divide the supplied irradiance by that sum, then multiply each returned sample. For night, retain a scale of exactly 1 and zero radiation. Reverse the shortwave layer order, copy its scattering fractions and clip depth to the configured minimum.

## Interface and Bounds

The Arm ABI takes fifteen addresses. Registers x0 to x7 contain full column count, layer count, first column, last column, configuration, single-level inputs, thermodynamic inputs and gas inputs. Seven stack addresses contain longwave depth, shortwave depth, shortwave scattering fraction, optional albedo, optional atmospheric emission, optional surface emission and optional incoming radiation.

Each returned depth has spectral sample first, layer second and selected column last. Longwave depth uses 140 samples and shortwave fields use 112. Atmospheric emission has H+1 boundaries. Surface emission and incoming radiation have one spectrum per selected column. Buffers are separate and aligned to their scalar element types. Supplied metadata and nested input owners are immutable.

The direct parent owns every temporary allocation and every new numerical stage. Its children have unique private symbols, so they cannot accidentally enter an original-symbol interception route. No comparison driver supplies a missing solver stage. The parent preserves x18, x19 to x29, the low halves of v8 to v15 and FPCR. Allocation and release are ordinary memory operations outside the numerical definitions.

## Acceptance

Before assembly emission, 48 protected original calls passed over 10,413,312 returned bytes. The independent checks covered 4,848 layer means, 962,696 coordinate relations, 338,968 emission relations, 32,240 spectral partitions and 22,956 solar relations. Three observers recorded genuine original children and did not alter their calculations.

Inputs are read-only and output bounds have inaccessible guard pages on both sides across the corpus. All output bytes must match the unchanged original. Reuse accepted scalar math, tables, child physics and ABI evidence. Add only the new complete-parent ABI and paired checks. The forecast remains pending until the queued parent executes in the required combined forecast and its saved files have zero differing bytes.

The complete native parent then passed the same 48 cases and 10,413,312 bytes with zero differences. A focused three-case check passed 137,088 returned bytes and the immediate fifteen-address ABI, including x18 and FPCR. It also covered absent incoming radiation. Three paired calls passed 117,600 returned bytes with 14,704 independent returned-field and solar relations, including fully absent optional thermal outputs. Every linked numerical child is a complete accepted direct assembly body. The original tables and their independent physical qualification are reused.

The genuine forecast exposed a zero exterior top face that the initial parent adapter had rejected. A focused protected 19-layer placement then passed the unchanged original, native and corrected paired routes over 637,952 bytes with zero differences. The new source physics check includes 304 positive layer means and the existing coordinate, emission and solar budgets. The paired route checks 79,748 returned-field relations. The native body and accepted child proofs are unchanged.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 passes these positive actual calls with zero differing bytes. Each byte scope describes the complete owners compared by that routine.

| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| radiation_ifs_rrtm::gas_optics | 6,400 | 4,082,892,800 | Complete returned routine owners |

All ten saved files also match across 618,140 bytes. The accepted critical physics and interface checks are reused. These checks cover the declared routine domains and saved files. Whole-forecast physical verification, whole-process byte identity and comparative timing remain open in the [coverage record](../../../../../src/openifs/README.md).
