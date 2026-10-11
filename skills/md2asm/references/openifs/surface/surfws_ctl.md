# Snow Warm-Start Controller Contract

Revision 1 implements complete `SURFWS_CTL_MOD::SURFWS_CTL` for its declared single-state initialization mode, `NSNMLWS=2`, from [Snow At The Start Of A Forecast](../../../../../formulations/openifs/surface/snow_warm_start.md), SW-1. The retained genuine coarse-forecast soil object has this value at byte 488. Modes one and three require other numerical initialization children and are rejected before public writes. This contract does not claim those modes.

## Complete Ordered Update

A warm start begins a forecast from an existing snow state. The controller uses 27 profile clusters, which are groups of measured snow profiles, a profile-depth threshold of 0.125 metres and a permanent-snow mass threshold of 9000 kilograms per square metre. It copies all four original snow-layer bound arrays, forms ice heat capacity as `RHOCI/RHOICE`, and allocates the four coefficient banks. Snow cover is `MAX(fraction[5]+fraction[7],RFRTINY)`. The no-snow flag compares that result with `RFRSMALL`. The original land flag compares the supplied mask with exactly one.

Call the complete accepted [snow grid](snow_grid.md) with its optional minimum-grid setting absent. Copy its returned layer depths into a separate full-depth array, then cap each provisional depth at one metre. Keep the original heat calculation, each depth sum, the first-layer mean temperature and density, the complete input snow-mass sum, and the initial zero liquid mean. Sum each field in increasing layer order with separate FP64 operations.

The first temperature and density midpoint is zero. Each later midpoint is its predecessor plus half the rounded sum of its two neighbouring depths. Keep separate capped and full midpoint arrays. Initially repeat the mean temperature and density in all layers, place total mass in the first layer, set the other masses and all liquid masses to zero, clear all coefficient banks and initialize both coefficient indices to one.

Call the complete accepted [single-state initialization](snow_profile_initialisation.md), [exponential profile](snow_exponential_profile.md) and [mass adjustment](surfws_massadj.md), in that order. Every numerical child is direct assembly. The mass adjustment admits the signed decay coefficients selected by the original shallow-snow tables. Reuse each child's ordered calculations and physical evidence, including glacier and inactive-layer writes. No driver supplies an omitted grid, profile or correction stage.

Finally, overwrite all allocated temperature, mass, density and liquid layers only when snow cover is present, more than one layer is active, and every proposed temperature lies between 100 kelvin and melting. Otherwise retain all four input fields. A shallow column can still receive the initialization values even when its exponential and mass stages are skipped. Preserve this original distinction. The original warning text is outside canonical numerical output.

## Domain And Interface

The Arm application binary interface passes 17 addresses. They contain first and last columns, column count, layer count, terrain variation, real land mask, tile fractions, solar-angle cosine, soil temperatures, skin temperature, snow albedo, snow temperature, snow mass, snow density, liquid mass, TCST and TSOIL. The first eight addresses use `x0..x7`; the rest use the caller stack. The four snow matrices are the returned owners.

Support 1–4096 columns and 5–512 layers, partial and empty ranges, and signed independent GNU FP64 descriptor strides. Tile fractions contain at least seven tiles and soil temperature contains at least one layer. A descriptor stores the data address, dimensions and entry distances. Rank-one and rank-two descriptors occupy 64 and 88 bytes. TCST and TSOIL occupy 128 and 2416 bytes. Reuse accepted layouts, with the newly measured snow-bound descriptors at bytes 2120, 2184, 2248 and 2312 and RFRTINY at byte 400. These embedded allocatable arrays are contiguous, start at one and cover every declared layer. RDAT retains the same one-based contiguous contract.

Consumed quantities are finite. Snow temperature lies in `[100,273.16]` kelvin, soil and skin temperatures in `[100,350]` kelvin, density in `[1,1000]` kilograms per cubic metre, and water mass is nonnegative with liquid no greater than total mass. Solar-angle cosine lies in `[-1,1]`, fractions and albedo in `[0,1]`, and terrain variation is nonnegative. The original constants and every derived child operand satisfy the linked child's complete admitted domain. In particular, each exponential argument has magnitude at most 700. A triggered one-active-layer mass adjustment must satisfy its exact initial mass relation, preventing the original layer-zero residual. All guard failures occur before caller writes.

Canonical output comprises the complete four snow owners in increasing memory address order, including unused columns and stride padding. Keep descriptor, configuration and input-owner bytes unchanged. Returned owners are separate from each other, all inputs and descriptor storage. Preserve the Arm saved registers, aligned stack and floating-point control register. Use FP64 nearest-even rounding, gradual underflow, separate arithmetic and the unchanged qualified scalar maths. No fused operation, approximation or OpenIFS Fortran numerical call is admitted.

## Acceptance

Before assembly emission, 24 protected original placements pass 216832 complete bytes and 10678 independent 110-digit water, temperature and liquid-capacity relations. They cover daylight and night, ordinary and varying terrain, glaciers, no-snow and shallow columns, signed column and layer strides, partial and empty ranges and 512 layers. Reuse the already qualified children and add complete-controller output, saved-register and prewrite checks. Native and paired results are recorded after their actual execution. Forecast acceptance and an autonomous assembly forecast remain separate requirements.

The complete native body passes the 24 protected placements over 216832 complete bytes with zero differences and 21356 source and native physical relations. After adding only composed-exponential admission, two focused immediate 17-address ABI calls and two paired calls each pass 21696 bytes with zero differences and 2912 source and native relations. Four additional paired no-snow and empty-range calls pass 8576 bytes with zero differences. Thirteen new prewrite cases preserve 19552 shared output bytes, including both excluded initialization modes and an excessive composed exponential operand. A cached comparison preserves 158656 inactive or padding bytes without rerunning the numerical body. The combined native object contains no fused or approximate instruction and imports no OpenIFS Fortran numerical routine.  Detailed records stay in `.runtime/openifs/snow_warm_start_7240564/`.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 passes these positive actual calls with zero differing bytes. Each byte scope describes the complete owners compared by that routine.

| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| surfws_ctl_mod::surfws_ctl | 86 | 330,240 | Complete returned routine owners |

All ten saved files also match across 618,140 bytes. The accepted critical physics and interface checks are reused. These checks cover the declared routine domains and saved files. Whole-forecast physical verification, whole-process byte identity and comparative timing remain open in the [coverage record](../../../../../src/openifs/README.md).
