# GRIB Soil Layer Labels

GRIB stores a weather field with labels that identify its parameter and layer. This entry reproduces the soil-depth labels from the original SUGRIB routine. The labels describe existing model layers and do not calculate soil physics. Layer thickness is in metres. The stored top and bottom labels are integer centimetres.

The AArch64 entry is `md2asm_initialize_runtime_grib_soil_levels(surface, output, capacity)` in [runtime_grib_soil_levels.S](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/output/runtime_grib_soil_levels.S). Arguments use x0 through x2. The caller supplies the complete borrowed surface record of 11,584 bytes, an output buffer of at least 144 bytes and its capacity in bytes. The surface record has eight-byte alignment and the output has four-byte alignment. Their complete mapped spans must not overlap or overflow an address. The caller retains both records through the call.

The selected surface model has four soil layers. Its NCSS value at byte 3944 is four. The RDAT description at byte 9264 supplies temperature-layer thicknesses. RDAW at byte 9328 supplies water-layer thicknesses. Both are complete GNU rank-one FP64 descriptions with four values, unit element stride and bounds one through four. Each thickness is finite, nonnegative and no greater than one million metres. Signed zero and subnormal values retain the original arithmetic.

For each layer, add its thickness and all earlier thicknesses in the original increasing order to obtain the bottom depth. Subtract the current thickness to obtain the top depth. Convert each depth to centimetres, add the original 0.1 adjustment, cap the result at 255 and truncate toward zero. Every prefix starts again from zero as in the source. Separate FP64 additions, subtraction and multiplication retain their original rounding points.

The table contains three groups of four rows.

| Group | Parameter numbers in layer order | Thickness source |
| --- | --- | --- |
| Soil temperature | 139, 170, 183, 236 | RDAT |
| Soil water | 39, 40, 41, 42 | RDAW |
| Soil ice | 35, 36, 37, 38 | RDAW, as selected by original SUGRIB |

The output stores twelve int32 parameter numbers, then twelve bottom depths, then twelve top depths. This is the original 12-by-3 column-major table and occupies exactly 144 bytes. The result is staged on the stack and published only after every input passes. Unsupported input returns two and leaves the complete output unchanged. Success returns zero. The entry allocates no heap storage and uses a 384-byte stack frame with 16-byte alignment. It preserves x18, saved AArch64 registers and FPCR, which must be zero. FPSR and errno retain their natural effects.

Component checks passed eight original and assembly pairs with zero differences across 1,152 complete output bytes. They cover genuine layer inputs, changed thicknesses, the 255 cap, fractional depths, signed zero and subnormal values. Independent unit analysis passed 576 relations, and six invalid-input calls passed 24 preservation checks. All paired ABI masks were zero, FPCR was zero, FPSR was 16 and errno was 777. An initial independent real-number check omitted FP64 rounding near an integer threshold. Its failure remains archived, while a saved-only rounding-bound correction validates the same retained pairs without rerunning them or changing outputs. Complete encoder, file and forecast acceptance remain separate requirements.
