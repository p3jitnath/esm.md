# Humidity Floor Contract

Revision 1.0. The input is [humidity_floor.md](../../../../../formulations/openifs/physics/humidity_floor.md). The original exported routine is `QNEGAT` in `arpifs/phys_ec/qnegat.F90`.

## Interface And Bounds

Eleven argument addresses enter the Arm ABI. Registers x0 through x7 point to the condensation object, first column, last column, full column count, level count, time step, humidity and output correction. The four counts are INTEGER4. Time step and numerical fields are FP64. Stack offsets 0, 8 and 16 hold edge pressure, existing diagnostic flux and optional input tendency. A null final address means the tendency is absent.

The plain TECND object contains 16 bytes, and its minimum humidity REPQMI is at byte 8. The body reads gravity from `__yomcst_MOD_rg`. Humidity, correction and optional tendency have full-column count times level-count cells. Pressure and flux have full-column count times level-count-plus-one cells, with edge index zero first. Columns are the fastest index. Buffers are contiguous, separate and naturally aligned, and address products fit signed 64 bits. Counts have a positive full column count and at least one level. An empty selected range writes nothing. All fields are finite, time step and gravity are positive, minimum humidity is nonnegative, and selected pressure thicknesses are positive.

The complete output owners include inactive columns and the unchanged top flux row. Input scalars, object, humidity, pressures, optional tendency and gravity stay unchanged.

## Complete Ordered Calculation

Compute `1/time_step` once. Initialize selected correction cells to positive zero when no tendency is supplied, otherwise copy that tendency exactly. Visit layers from top to bottom. Multiply time step by the current correction, then add humidity. Subtract this rounded sum from the minimum and take the maximum with positive zero. Multiply by the rounded reciprocal time step and add the result to the current correction.

Above the bottom, multiply that correction increment by the current pressure thickness, divide by the next pressure thickness, and subtract the result from the next layer's correction. The bottom applies its own increment without a transfer below. When the input tendency is present, subtract it from every final correction cell after these updates.

Set the private top flux to positive zero. For each layer, negate its final correction, multiply by its pressure thickness, divide by gravity, then add the preceding private flux. Add this rounded private flux to the existing diagnostic flux. Keep the existing top row.

The native body processes independent columns separately and recomputes each pressure difference from unchanged input edges. It retains the cumulative private flux in a register, removing both complete temporary matrices while preserving every output's arithmetic order. No driver supplies a stage.

Every FP64 operation rounds separately to nearest with ties to even. Keep signed zero, gradual underflow and FPCR zero. Forbid fused operations, reassociation, approximate division and reduced precision. Restore x19 through x29 and the link register, leave x18 unchanged, and use caller-saved FP registers. The fixed stack frame is 96 bytes.

## Acceptance

Require zero differing output bytes against the genuine strict original for both optional-input branches. Protect full owners, inactive cells, the top flux, inputs and saved registers.

Independently perform the pressure-weighted water transfers at 100-digit precision. Their column sum is zero above the bottom, and the final column change equals the bottom water addition. Check final humidity against the minimum within rounding error. Check the accumulated diagnostic increment from P03. Let `u=2^{-53}`, `N` be the layer count and `B` the larger of the minimum and the column's pressure-weighted sum of absolute humidity, absolute time-step-scaled input tendency and the minimum divided by its smallest pressure thickness. The comparison uses the conservative bound `(128+32*N)*u*max(B,minimum,2^-1022)` for humidity, with the corresponding pressure and gravity factors for mass and flux, plus a subnormal-rounding allowance. Exact source bytes remain the acceptance rule.

Use a compact corpus for no shortage, a top shortage, several transfers, bottom addition, a threshold tie, signed zeros, unequal pressure thicknesses, cropped and empty columns, one layer and a complete 137-layer column. Reuse the accepted ABI observer. Live forecast acceptance is separate from critical acceptance.

The direct source is [qnegat.S](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/physics/qnegat.S).

## Critical Results

The native check passed 76 protected placements, 16,406 independent water relations and 480,448 complete output bytes with zero differences. Both optional-tendency branches, inactive cells, the top flux, all inputs, saved registers and FPCR passed. The instruction review found no fused or approximate operations, no FPCR writes and no x18 use.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 observed 2,150 genuine calls. The same-input comparison covers 16,099,200 complete returned owner bytes with zero differences. Independent critical physics, unchanged inputs and the declared interface checks passed. All ten saved forecast files also match across 618,140 bytes. This result covers the declared routine domain and saved files. Independent whole-forecast physics, whole-process byte identity and comparative speed remain unproved.
