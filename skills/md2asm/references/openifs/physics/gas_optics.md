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

Reverse the vertical order and apply the configured spectral permutation. Clip each longwave depth to the configured nonnegative minimum. For ordinary spectral order, process four contiguous samples at a time with the same minimum as the first FMAX operand in each lane. The 140-sample row has exactly 35 complete groups. Reuse the source and destination row addresses while retaining the complete scalar permutation path for reordered spectra. Prepare shortwave coefficients and initialise all shortwave scratch depths, scattering fractions and incoming samples to positive zero before the complete shortwave parent. Nighttime children leave these zero samples intact.

If requested, multiply each incoming sample by its band factor. Sum all 112 samples in the unchanged original reduction order. For daylight, divide the supplied irradiance by that sum, then multiply each returned sample. For night, retain a scale of exactly 1 and zero radiation. Reverse the shortwave layer order, copy its scattering fractions and clip depth to the configured minimum.

## Interface and Bounds

The Arm ABI takes fifteen addresses. Registers x0 to x7 contain full column count, layer count, first column, last column, configuration, single-level inputs, thermodynamic inputs and gas inputs. Seven stack addresses contain longwave depth, shortwave depth, shortwave scattering fraction, optional albedo, optional atmospheric emission, optional surface emission and optional incoming radiation.

Each returned depth has spectral sample first, layer second and selected column last. Longwave depth uses 140 samples and shortwave fields use 112. Atmospheric emission has H+1 boundaries. Surface emission and incoming radiation have one spectrum per selected column. Buffers are separate and aligned to their scalar element types. Supplied metadata and nested input owners are immutable.

The direct parent owns every temporary allocation and every new numerical stage. Its children have unique private symbols, so they cannot accidentally enter an original-symbol interception route. No comparison driver supplies a missing solver stage. The parent preserves x18, x19 to x29, the low halves of v8 to v15 and FPCR. Allocation and release are ordinary memory operations outside the numerical definitions. Every integer scratch extent is rounded up to eight bytes, and every FP64 extent is already a multiple of eight bytes. Clear complete 64-byte groups with paired vector stores, followed by bounded eight-byte stores. This covers exactly the existing allocation with positive-zero bits and uses only caller-saved registers.

## Acceptance

The current protected comparison passes 48 original/native calls over 10,413,312 returned bytes with zero differences. Inputs are read-only, output bounds have inaccessible guard pages, and the fifteen-address ABI and FPCR checks pass. Independent checks cover 9,696 observed layer means, 962,696 coordinate relations, 335,160 emission relations, 32,240 spectral partitions and 19,130 solar relations. The corpus includes both spectral orders, one-cell and odd-column shapes, daytime and night, and absent optional outputs. Reuse the accepted tables and child physics.

The scratch clear and ordinary contiguous clipping paths change storage instructions and independent FMAX scheduling only. Each lane retains the original operands and result bits, including the signed-zero rule. The vector clear changes no floating-point flags, and reordered spectra keep the accepted scalar route. Independent source reviews establish complete store bounds, register lifetimes and unchanged arithmetic outside these paths.

The genuine zero-pressure top face remains supported. Its protected 19-layer replay passes over 637,952 bytes, with 304 positive layer means and 79,748 returned-field relations. The gas physics is unchanged. Earlier combined forecasts passed 6,400 actual gas-optics calls over 4,082,892,800 compared bytes.

The current autonomous image with these gas changes and paired longwave layers matches all 685 numerical buffers, 560 descriptor relations and 27,486,113 raw bytes, all ten saved files over 618,140 bytes, and all 59 controlled final-state views. ABI mask is zero, with natural FPCR 0, FPSR 25 and errno 0. Known inactive optional arguments and incoming-status differences remain visible, so this is numerical-state and file identity rather than whole-process boundary identity.

Three matched ordinary forecast pairs give medians of 25.42 seconds before this batch and 24.29 seconds after it. All six runs reproduce the ten files and 59 ordinary final-state views outside timing. Every pair favours the batch and measured ranges do not overlap. These measurements cover the combined gas-memory and longwave changes, without assigning a separate full-forecast gain to either gas path. See the concise [comparison table](../../../../../README.md).
