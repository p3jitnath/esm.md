# Gravity-Wave Launch Caller Contract

[GWDRAGWMS_LAYER](../../../../../src/openifs/physics/gwdragwms_layer.S) completes the launch-level combination for [Non-Orographic Gravity-Wave Drag](../../../../../formulations/openifs/physics/nonorographic_gravity_wave_drag.md), revision 1. Its complete direct child obeys the [GWDRAG_WMS contract](gwdrag_wms.md). The caller supports zero through three configured launches in the same physical and coarse-grid domain.

The caller forms total surface precipitation by three left-to-right additions of PFPLCL, PFPLCN, PFPLSL and PFPLSN, then takes the source numeric maximum with positive zero. It clears selected wind-tendency cells. For each launch, in source order, the complete native child calculates both tendencies and both flux matrices. The caller adds each tendency and subtracts each flux from the accumulated stress with one FP64 rounding per operation. It does not alter pressure, temperature or wind inputs. No driver supplies a numerical stage.

## Interface and Bounds

The GNU Fortran application binary interface, or ABI, receives nine addresses. The first eight use x0–x7 and the ninth caller stack slot supplies the GNU derived-type vector descriptor for NOGW. The plain objects are TSTA 384 bytes, TEGWD 96 bytes, TEGWWMS 168 bytes, DIMENSION_TYPE 192 bytes, STATE_TYPE 1240 bytes, AUX_TYPE 1992 bytes and FLUX_TYPE 5064 bytes. The unused YGFL argument is retained in the interface. Its source associations supply no consumed calculation or field.

Dimensions KIDIA, KFDIA, KLON and KLEV are at bytes 0, 4, 12 and 48. STATE descriptors U, V and T are at 32, 120 and 208. AUX descriptors PAPRSF, PAPRS, PAPHIF, PGELAT and PGAW are at 448, 360, 96, 1040 and 1104. FLUX descriptors PFPLCL, PFPLCN, PFPLSL, PFPLSN, PSTRDU and PSTRDV are at 1144, 1232, 1320, 1408, 2200 and 2288. TEGWWMS NLAUNCHLEV is at 28 and its wave time step is at 120. Every VARIABLE_3D element has 728 bytes and its P descriptor starts at 64.

Consumed input matrices are contiguous with KLON columns and their complete declared vertical bounds. Rank-one inputs are contiguous KLON vectors. NOGW has unit element stride and at least two actual elements. Its assumed-shape dummy remaps the first two actual elements to NOGW(1) and NOGW(2), irrespective of the caller's lower bound. Each P matrix has one-based KLON by KLEV bounds. Stress matrices have KLON columns and levels 0 through KLEV. The four precipitation matrices include logical level KLEV. GNU descriptors store data at byte 0, element offset at 8, strides at 40 and 64, and lower/upper bounds at 48/56 and 72/80. The first physical value is data plus eight times offset plus the lower bounds multiplied by their strides. Mutable owners are disjoint from each other and from consumed input owners.

KLON is 1 through 2048 and KLEV is 2 through 512. The selected interval is empty or within KLON. For an active launch, the complete child domain applies. The parent checks source-ordered coarse spacing, RPI, launch bounds, spectral slope and the saturation law before any output write. All physical inputs and original output bytes remain unchanged outside the selected cells. Zero-launch calls clear selected NOGW cells and preserve stresses.

The native entry preserves the required saved integer registers, low halves of v8–v15, stack alignment and FPCR. It does not use x18. A 768-byte aligned frame and one storage-only allocation hold the precipitation vector, two temporary tendencies and two temporary fluxes. Its 4*KLON*KLEV + 3*KLON FP64 values are released after the call. The complete child is privately bound without repeating its accepted scientific or scalar-math proofs.

## Arithmetic and Acceptance

Use the frozen FP64 arithmetic from the child contract, with separately rounded operations, signed zeros, gradual underflow and no fused arithmetic or reassociation. Canonical bytes concatenate both complete NOGW P owners and the complete PSTRDU and PSTRDV owners in little-endian order. Inactive output cells, descriptors, inputs and every unrelated object byte retain their original bits. Acceptance requires zero differing output bytes, independent pressure-weighted momentum checks across the accumulated launches, protected bounds, immediate ABI checks and unchanged FPCR. The complete caller passes twenty protected source/native cases, 75776 complete returned bytes and 18944 independent accumulated-momentum relations with zero differences. Cases cover zero through three launches, all four spectral slopes, both saturation laws, standard-profile launch, negative precipitation clipped to zero, selected interior columns, both protected buffer edges, shifted actual vector lower bounds and 2 through 512 levels. Four focused immediate-ABI calls add 3424 returned bytes and 856 source/native relations. The paired closure passes four primary calls, 3424 returned bytes and 428 live parent relations with zero differences. Its six genuine private native wave launches also pass 10284 reused carried-wave relations and four critical events. One composed parent call adds 912 returned bytes, 114 parent relations and three genuine private native launches with 5652 carried-wave relations. Its three public child comparison calls are correctly marked as verification shadows with zero primary calls. Two prewrite rejections preserve all 160 shared output bytes for finer spacing and changed RPI. Actual forecast calls, configuration coverage and saved-file acceptance remain pending.

## Positive Optimisation Lesson

Unroll the derived-object addresses once, reuse one set of temporary arrays across the launch loop and bind the accepted child privately. Keep the launch sequence and the caller's accumulation order unchanged. No repeated child proof is needed when its complete body and configuration remain unchanged.


The original coarse forecast has now recorded 86 genuine calls and 2,048 consumed column weights, with no comparison-shadow calls. Its source-ordered grid spacing ranged from 167,243.296 m to 620,264.619 m, safely within the declared minimum of 29,000 m. Every reported call used Gaussian factor 2, spectral slope 1, saturation exponent 2, the previously checked flag configuration and launch level 11. The five frozen constants were unchanged, with no grid-bound failure or changed value of π. This establishes the recorded geometry domain. Complete native live-owner checks and saved forecast files still remain before acceptance.

The live physical observer reconstructs rejected momentum by subtracting two rounded fluxes. Keep its energy consistent with that same momentum and the mixture phase, including positive packets below the significance limit. Do not clip the energy fraction independently while retaining a slightly larger rounded momentum. In the captured sixth launch, this difference was about $`1.2854\times10^{-19}`$, within the unchanged $`3.4103\times10^{-15}`$ momentum budget. Both corrected observers pass all 17,737 captured physical relations and 51 energy-deposition events. The numerical assembly and every physical tolerance remain unchanged.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 passes these positive actual calls with zero differing bytes. Each byte scope describes the complete owners compared by that routine.

| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| gwdragwms_layer | 1,118 | 16,743,168 | complete_parent_returned_owners |

All ten saved files also match across 618,140 bytes. The accepted critical physics and interface checks are reused. These checks cover the declared routine domains and saved files. Whole-forecast physical verification, whole-process byte identity and comparative timing remain open in the [coverage record](../../../../../src/openifs/README.md).
