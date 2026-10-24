# GWDRAG_WMS Numerical Contract

[Direct assembly](../../../../../src/openifs/physics/gwdrag_wms.S) implements [Non-Orographic Gravity-Wave Drag](../../../../../formulations/openifs/physics/nonorographic_gravity_wave_drag.md), revision 1, equations G1–G2. The complete source calculation uses four directions and twenty phase speeds. It includes every declared spectral slope, both saturation laws, critical-level filtering, the finite-step momentum correction and the final pressure-weighted wind tendencies.

## Declared Physical Domain

KLON is 1 through 2048 and KLEV is 2 through 512. The selected one-based column interval is empty or lies within KLON. KLAUNCH is 1, 2 or 3 and its configured launch level is within 2 through KLEV. NSLOPE is -1, 0, 1 or 2. GPTWO is exactly 2 or 3. All four configuration flags retain their source branches. The three standard profiles are required only when LGINDL is true. Pressure increases downwards, used temperatures and full pressure are positive, the top half-pressure boundary may be zero, the time step and wavelength are positive, and every admitted output passes the independent momentum and energy checks.

The complete coarse-grid domain requires the source-ordered spacing max(100,(2*RA)*sqrt(RPI*PGAW)) to be at least 29000 metres in every selected column. RPI must have the canonical binary word 400921fb54442d18. The direct body checks both requirements before any output write. Within this complete domain the source ATAN operand is exactly positive zero and its spacing factor is exactly one. Other spacing values are outside this contract. Actual forecast coverage requires the original domain recorder and the changed saved-file gate.

## Frozen Arithmetic and Stages

Use FP64 with round-to-nearest ties-to-even, gradual underflow, signed zeros and FPCR zero. No fused arithmetic, contraction, reassociation or approximate division is allowed. The qualified scalar EXP and LOG routes are reused. The four source-ordered SIN and COS operands use their independently qualified result words, including the small nonzero cardinal residuals. The source sum of absolute cosines gives an exact normalisation of one.

1. Clear all tendency cells and the selected flux cells. Average adjacent temperature and wind cells. Compute density and the bounded buoyancy frequency in the original order.
2. Construct the stretched twenty-point reciprocal-speed coordinate, its positive integration weights and each direction's wind relative to the launch wind. Preserve the ordered EXP, reciprocal, product and subtraction stages.
3. Form the complete selected launch spectrum. Preserve the source's multiplication chains for integer powers two, three and four. Sum the twenty contributions from first to last. Apply the declared coarse spacing factor, the original precipitation or latitude branch and its exact normalisation. Optionally use the complete standard-atmosphere launch factor.
4. Propagate each directional spectrum from the launch layer upwards. Update the largest encountered intrinsic wind, the source SIGN-based activity and each ordered flux sum. Apply the complete square or cubic saturation law and retain the source's copied phase diagnostic when a layer has no local critical deposition.
5. Follow rejected momentum into the next layer using the complete original finite-step correction. The physical check tracks carried momentum and its phase-weighted energy. The copied diagnostic in a layer is not assumed to describe a packet carried from another layer.
6. Sum directions in source order, then form each wind tendency from the flux difference and the once-rounded gravity-over-pressure difference. Drivers supply no numerical stage.

## GNU Fortran ABI and Storage

The application binary interface, or ABI, receives twenty-two addresses. Arguments 1–8 use x0–x7 and the remaining fourteen use consecutive caller stack slots. Integers and logical values use four bytes. FP64 arrays use eight-byte alignment and the column index changes fastest. The matrices have KLON*KLEV values. Half-pressure and returned flux matrices have KLON*(KLEV+1) values. Complete output owners must be disjoint from one another and from consumed input owners.

The plain objects are TSTA 384 bytes, TEGWD 96 bytes and TEGWWMS 168 bytes. TSTA rank-one descriptors start at bytes 0, 128 and 192 for standard half pressure, height-related energy and temperature. Their data, offset and stride obey the GNU descriptor ABI. The paired domain requires unit-stride standard profiles and checked bounds that include the consumed launch levels. TEGWD GSSEC is at byte 48. TEGWWMS flags are at bytes 0, 4, 8 and 12. Launch levels begin at 16, slope is 36, latitude option is 40, launch fluxes begin at 48, wavelengths at 80, saturation coefficient is 104, saturation law is 112, Gaussian width is 128, Gaussian amplitudes begin at 136 and precipitation coefficient is 160.

The direct entry preserves x19–x29, the low halves of v8–v15, stack alignment and FPCR. It does not use x18. A fixed 1024-byte frame stores addresses and scalar work. A private zeroed arena holds 22*KLON*KLEV + 252*KLON + 48 FP64 values and is released after the call. Allocation supplies storage only. It never evaluates a numerical stage.

Canonical bytes are complete PTENU, PTENV, PFLUXU and PFLUXV owners in that order, little-endian. The whole tendency owners are cleared as in the source, including inactive columns. Inactive flux bytes and every read-only input owner remain unchanged. Acceptance requires zero differing bytes, independent wave-action, momentum and phase-weighted energy relations, protected bounds, immediate ABI checks and unchanged FPCR.

## Verification State

The complete genuine original source passes twenty-two physical cases, 40512 returned bytes compared with its passive trace, 45498 independent physical relations and 110 critical events. Cases include all four slopes, both saturation laws, all four optional flags, the precipitation and both Gaussian branches, three launch choices and 2 through 512 levels. The complete four-azimuth primitive proof and source physical proof are reused. The new direct body passes the same twenty-two cases, 40512 complete returned bytes and 613872 consumed intermediate trace bytes with zero differences. Its independent native gate passes 45498 physical relations and 110 critical events. Eight additional protected direct calls check both buffer edges, cropped columns with unused NaN values, empty column intervals, zero top pressure, all saved scalar registers and FPCR. They compare 9280 complete returned bytes and 296 pressure-weighted relations with zero differences. Eight paired primary calls compare the same 9280 returned bytes and pass 11398 independent live relations, including six critical events. Two prewrite guard rejections preserve all 80 output bytes for a spacing below 29 km and changed RPI. The first admitted source-rounded spacing and its next admitted metric also match the original outputs. Actual forecast configuration and saved-file acceptance remain pending.

## Positive Optimisation Lesson

Keep the complete private arrays in one allocation and reuse each identical EXP result inside an unchanged coordinate cell. Cache launch constants and profile factors. Use fixed qualified azimuth values to preserve exact source rounding while avoiding repeated transcendental calls. Retain reduction order and the complete carried-momentum correction when sharing the scalar cell loops.


The original coarse forecast has now recorded 86 genuine calls and 2,048 consumed column weights, with no comparison-shadow calls. Its source-ordered grid spacing ranged from 167,243.296 m to 620,264.619 m, safely within the declared minimum of 29,000 m. Every reported call used Gaussian factor 2, spectral slope 1, saturation exponent 2, the previously checked flag configuration and launch level 11. The five frozen constants were unchanged, with no grid-bound failure or changed value of π. This establishes the recorded geometry domain. Complete native live-owner checks and saved forecast files still remain before acceptance.

The live physical observer reconstructs rejected momentum by subtracting two rounded fluxes. Keep its energy consistent with that same momentum and the mixture phase, including positive packets below the significance limit. Do not clip the energy fraction independently while retaining a slightly larger rounded momentum. In the captured sixth launch, this difference was about $`1.2854\times10^{-19}`$, within the unchanged $`3.4103\times10^{-15}`$ momentum budget. Both corrected observers pass all 17,737 captured physical relations and 51 energy-deposition events. The numerical assembly and every physical tolerance remain unchanged.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 passes these positive actual calls with zero differing bytes. Each byte scope describes the complete owners compared by that routine.

| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| gwdrag_wms | 1,118 | 16,743,168 | Native private wave child, compared complete parent owners and child proof |

All ten saved files also match across 618,140 bytes. The accepted critical physics and interface checks are reused. These checks cover the declared routine domains and saved files. Whole-forecast physical verification, whole-process byte identity and comparative timing remain open in the [coverage record](../../../../../src/openifs/README.md).


The separate [runtime fine-grid extension](runtime_nonorographic_gravity_waves.md) restores the original spacing factor for its declared default parameter selection. It retains this coarse entry and its complete accepted object unchanged.
