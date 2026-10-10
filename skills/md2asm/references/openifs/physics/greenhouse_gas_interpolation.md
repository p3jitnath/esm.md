# Greenhouse-Gas Interpolation Contract

Physics revision 1.0 is [greenhouse_gas_profiles.md](../../../../../formulations/openifs/physics/greenhouse_gas_profiles.md). P01 blends latitude profiles. P02 divides gas amount by pressure thickness. The climatology is a supplied model input.

## Ordered FP64 Calculation

For each selected column, compute each climatology amount as `low+w*(high-low)`, with separate subtraction, multiplication and addition. Set accumulated amount zero to positive zero, then add layers in increasing pressure order. Preserve each FP64 rounding point.

For each model face after the top, search intervals from the top. Choose the first with `p>=left` and `p<right`. Otherwise use the last interval, including equality at the final boundary. Compute `(p-left)/(right-left)`, then `Cleft+fraction*(Cright-Cleft)`, rounding each operation separately. The initial model amount is positive zero. Subtract successive rounded amounts, then divide by the separately rounded difference between successive model pressures.

The native body may keep rounded model amounts in registers and use one climatology accumulation buffer. This removes two temporary arrays without changing arithmetic dependencies or rounding. The original parent's private final interpolation weight is unused after the child returns and is not a model output.

Require FPCR zero, nearest-even rounding, gradual underflow and preserved signed zeros. Forbid fused arithmetic, reassociation, approximate division and reduced precision.

## Interface And Storage

`md2asm_openifs_interp_gas` receives eleven address arguments. x0 and x1 address first and last INTEGER4 columns, x2 the full column count, x3 contiguous one-based latitude indices, x4 contiguous FP64 weights, x5 the climatology layer count, x6 the model layer count, and x7 the rank-one pressure descriptor. Incoming stack offsets 0, 8 and 16 hold the rank-two gas-amount descriptor, model face-pressure buffer and model output buffer.

Descriptors have data at byte 0 and first element stride at byte 40. The amount descriptor has second stride at byte 64. Data addresses the first logical cell. Dummy indices start at one, while pressure starts at zero. A zero first stride means one. Signed strides and gaps are supported within supplied owners. Each latitude index must address two neighbouring profiles.

Model faces contain `KLON*(KLEV+1)` FP64 cells and outputs contain `KLON*KLEV`, with columns contiguous. Model counts are nonnegative. Climatology count is from 1 to 4096. Private accumulation needs `8*(KLEVCLIM+1)` bytes, rounded up to 16-byte alignment. Buffers and descriptors are disjoint and naturally aligned, and address products fit signed 64 bits. Empty columns or model layers write nothing.

The genuine contained Fortran child uses a private host pointer in x18. The local original-control wrapper supplies that context and restores x18. The standalone native child leaves x18 untouched, restores x19 through x30, and preserves saved FP registers and FPCR. Its complete native parent must call it directly.

## Output And Acceptance

Canonical output is the complete owner's unmodified little-endian FP64 bytes, including inactive columns and gaps. Inputs, descriptors, bounds and guards stay unchanged. Require zero differing bytes against the genuine strict original child.

Independent exact rational evaluation uses P01 and the piecewise-linear cumulative profile, then P02. Let $`u=2^{-53}`$ be unit roundoff, $`N`$ the climatology layer count, $`F`$ the largest pressure fraction, $`S`$ the total absolute blended amount, and $`d`$ the smallest model pressure thickness. A conservative forward error bound is `u*(64+16*N)*(max(1,F)*S/d+abs(q_exact))` plus `2^-1074*(64+16*N)*max(1,1/d)`. This includes blend, accumulation, pressure interpolation, cancellation and division errors. It does not replace the exact byte check.

The focused corpus covers latitude endpoints, uniform concentrations, pressure ties, extrapolation, signed and padded descriptors, sparse profiles, subnormal values, partial and empty columns, zero model layers and the scratch limit. Check nonnegativity and integrated column amount. Critical and forecast acceptance are separate, with no timing claim.

## Critical Results

The small strict original/native verifier passed 99 calls over 19,696 complete owner bytes, with zero differences and 3,113 independent profile relations. Inputs, descriptor bytes, inactive outputs and guards stayed unchanged. Immediate preserved-register and stack checks passed, and FPCR was zero. The emitted instructions contain no fused or approximate operations, no FPCR writes and no x18 use.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 counted 57,600 actual native child calls inside 6,400 complete RADGHG calls. All nine complete parent output owners match across 70,041,600 bytes, and 17,971,200 independent profile relations passed. All ten saved forecast files also match across 618,140 bytes. The child is directly bound inside its assembly parent. Independent whole-forecast physics, whole-process byte identity and comparative speed remain unproved.
