# Deterministic Convective Momentum Contract

Revision 1.0. The input is [convective_wind_transport.md](../../../../../formulations/openifs/physics/convective_wind_transport.md). The original routine is `CUDUDV` in `arpifs/phys_ec/cududv.F90`. The frozen forecast prints LSPP=F in its retained initialization. This contract supports both complete deterministic solver branches. A live call with stochastic perturbations enabled is rejected.

## Interface And Bounds

The routine has 27 argument addresses. Registers x0 through x7 hold convection object, stochastic configuration, first column, last column, full column count, level count, first transport level and convection-type array. Incoming stack addresses continue in source order as follows.

| Stack byte | Input or output |
| ---: | --- |
| 0, 8, 16 | Cloud-base levels, cloud-top levels, cloud flags |
| 24 | Time step |
| 32, 40 | Edge pressure, layer pressure |
| 48, 56 | Environmental U and V wind |
| 64, 72 | Updraft and downdraft mass flux |
| 80, 88 | Previous updraft and downdraft mass flux |
| 96, 104, 112, 120 | Updraft U, downdraft U, updraft V, downdraft V |
| 128 | Unused stochastic field |
| 136, 144 | Updated U and V tendencies |

INTEGER4 and GNU logical arrays contain four-byte entries. FP64 fields contain eight-byte entries. Every layer field has shape full-column count by level count, with columns fastest. Edge pressure has one extra level. Objects measure 344 and 3192 bytes. Convection settings RMFSOLUV, RMFSOLRHS, RMFADVW and RMFADVWDD lie at bytes 72, 96, 104 and 112. The stochastic LSPP flag lies at byte 0. Gravity is the unchanged `__yomcst_MOD_rg` global.

Buffers are contiguous, naturally aligned and separate. Source counts, products and addresses fit signed 64 bits. First transport level is from 2 through level-count-plus-one. Used cloud tops and bases are valid source layer indices, and a used explicit cloud base is not above the first transport level. Edge and required layer pressure differences are positive. All used numerical values and intermediates are finite. The reused child requires finite, nonzero rounded diagonals and finite solutions. Only active convective entries are read. Inactive object members and stochastic arrays need no value access.

The complete private stack footprint is at most 1,048,576 bytes. Its aligned arena holds seven full FP64 matrices and one logical matrix. Three flux arrays become the two solution arrays and the diagonal array after the complete flux divergence stage, when the old values are no longer needed. This reuses storage without changing the arithmetic.

## Complete Ordered Calculation

Store `implicit_remainder=1-RMFSOLUV` and `inverse_time_step=1/time_step`. For each active column and layer, divide gravity by the edge pressure difference. For each transport level, multiply the remainder by the preceding environmental wind, subtract it from the plume wind, then multiply by the appropriate updraft or downdraft mass flux. Form all four U/V plume momentum fluxes.

When RMFSOLUV is zero, replace fluxes below the cloud base with their cloud-base values multiplied by `(surface_edge-current_edge)/(surface_edge-base_edge)`. Square this rounded fraction for convection type 3. For all layers above the bottom, compute flux divergence in the source order `((up_next-up_current)+down_next)-down_current`, then multiply by the rounded gravity-to-pressure factor. At the bottom, negate that factor and multiply by the separately rounded sum of updraft and downdraft fluxes. The explicit branch adds these accelerations to both complete selected tendency fields.

For the implicit branch, set its complete diagonal matrix to one, lower-diagonal matrix to positive zero and logical matrix to false. A source row is used only when the column is convective and its level is at least cloud-top-minus-one. For each such row, form `scale=(RMFSOLUV*gravity_to_pressure)*time_step`. Its lower diagonal is `(-scale)*(up_mass+down_mass)`. Its diagonal is `1+scale*(next_up_mass+next_down_mass)` above the bottom and one at the bottom.

For convection type 1, use RMFADVW as the additional advection weight, otherwise use positive zero. Form its factor in the complete source order `((((gravity*(old_up_mass+RMFADVWDD*old_down_mass))/(layer_pressure-previous_layer_pressure))*time_step)*advection_weight)`. Multiply this factor by the preceding environmental wind minus the current environmental wind. Form each forcing as `(((flux_acceleration+old_tendency*RMFSOLRHS)*time_step)+environmental_wind)-advection_correction`.

Call the unchanged complete direct [CUBIDIAG](cubidiag.md) child once for each wind component. Preserve its regularised diagonal, reciprocal-first arithmetic, full output zeroing and cloud-top rules. Replace each used tendency by `old_tendency*(1-RMFSOLRHS)+(solution-environmental_wind)*inverse_time_step`. All other tendency cells remain unchanged. No driver computes a numerical stage.

Round each FP64 operation separately to nearest with ties to even. Preserve signed zeros, gradual underflow and FPCR zero. Forbid fused arithmetic, reassociation, approximate division and reduced precision. Restore required Arm saved registers, keep sixteen-byte stack alignment, leave x18 unchanged and bind the complete accepted child privately.

## Acceptance

Require zero differing bytes for the complete U and V tendency owners. Preserve all input fields, objects, scalars, inactive output cells and guards. Check the native ABI directly around the entry.

Independently derive plume fluxes and their pressure-weighted momentum budget. For the implicit branch, check the supplied lower-bidiagonal equations and reconstructed wind tendency with high precision. Reuse unchanged CUBIDIAG scientific and byte evidence. Use a compact corpus for both solver branches, convection types, cloud masks, cloud top and base boundaries, explicit linear and squared continuation, one complete 137-layer column, cropped and empty columns, and finite small values. Scientific residual bounds account for FP64 rounding and complement exact output bytes. Live forecast acceptance is separate.

The direct source is [cududv.S](../../../../../src/openifs/physics/cududv.S).

## Critical Results

The native check passed 56 protected placements, 7,984 independent momentum and implicit-equation relations and 236,352 complete U/V tendency bytes with zero differences. All inputs, inactive output cells, saved registers and FPCR passed. The 137-layer cases include explicit, semi-implicit and fully implicit settings. Both deterministic branches privately reuse the unchanged accepted CUBIDIAG body. The new caller's instruction review found no fused or approximate operations, no FPCR writes and no x18 use.

The independent row residual uses `2048*2^-52*max(1,levels)` times the sum of absolute matrix and forcing terms, with a small subnormal allowance. The paired live observer checks the pressure-weighted column momentum budget, whose interior flux differences cancel. It compares every output byte and checks the explicit deterministic configuration before each call.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 observed 2,150 genuine calls. The same-input comparison covers 15,686,400 complete returned owner bytes with zero differences. Independent critical physics, unchanged inputs and the declared interface checks passed. All ten saved forecast files also match across 618,140 bytes. This result covers the declared routine domain and saved files. Independent whole-forecast physics, whole-process byte identity and comparative speed remain unproved.
