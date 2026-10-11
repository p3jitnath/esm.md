# RRTM_TAUMOL2 Contract

Revision 1.0 preserves the complete OpenIFS Band2 calculation from [P01-P02](../../../../../formulations/openifs/physics/longwave_water.md). It produces dimensionless absorption depths and Planck weights for points eleven through twenty-two in a complete 140-point longwave output owner. The formulation uses the current 350 to 500 cm$`^{-1}`$ band limits.

## Complete Numerical Update

Visit increasing active layer and column indices. A layer at or below its supplied tropopause uses the lower tables. Higher layers use the upper tables. All columns are active, including night columns. Spectral points outside points eleven through twenty-two and levels outside the active count preserve every incoming bit.

With one-based source pressure and temperature indices $`J_P,J_T,J_{T1}`$, lower zero-based rows are $`I_0=5(J_P-1)+(J_T-1)`$ and $`I_1=5J_P+(J_{T1}-1)`$. Upper rows are $`I_0=5(J_P-13)+(J_T-1)`$ and $`I_1=5(J_P-12)+(J_{T1}-1)`$. Multiply weights 00, 10, 01 and 11 by coefficients at rows $`I_0,I_0+1,I_1,I_1+1`$, rounding each product and each left-to-right addition separately. Multiply the completed line sum by water.

For each continuum, subtract its first temperature node from the adjacent node, multiply the rounded difference by its supplied fraction and add the first node. Multiply the self and foreign results by their own factors. The lower depth adds self then foreign to the rounded water line term. The upper depth adds only foreign and must not read the self-continuum values or index.

For lower pressure, subtract 100 hPa, multiply by FP64 0.05, divide by FP64 900 and subtract from one. Multiply the completed lower gas absorption by this rounded correction, then add the supplied Band2 aerosol depth. The upper branch adds aerosol directly after foreign continuum and must not read pressure. The dry-air column argument is unused in both branches.

Copy the selected lower or upper Planck coefficient word directly to its output. Do not normalise these empirical weights or add a rounding stage. Table setup, aerosol preparation and atmospheric interpolation inputs are unchanged frozen stages outside this leaf. No driver supplies a numerical stage from the leaf.

## ABI, Bounds And Storage

The application binary interface (ABI) is GNU Fortran on little-endian AArch64. Twenty-four by-address arguments occupy x0-x7 and sixteen eight-byte caller stack slots. Their source order is TDIMV, first column, last column, active level count, absorption output, pressure, dry-air column, aerosol depth, four interpolation weights 00, 01, 10 and 11, foreign factor and fraction, foreign INTEGER4 index, pressure INTEGER4 index, two temperature INTEGER4 indices, water column, tropopause INTEGER4 vector, self factor and fraction, self INTEGER4 index and Planck output.

TDIMV occupies 32 bytes and contains the allocated vertical extent in its first INTEGER4 field. Let $`n`$ be the active column count and $`V`$ the allocated level count. Input fields store columns fastest, then allocated levels. Aerosol storage holds columns by allocated levels by all sixteen bands, although this leaf reads only the second band. Both complete outputs hold columns by all 140 spectral points by allocated levels. Their cell offset is $`c+n(g+140l)`$, with zero-based indices. This layout differs from the input fields and must be preserved. INTEGER4 arrays need four-byte alignment and FP64 arrays need eight-byte alignment. All true owner capacities are present and input owners are disjoint from output owners.

Support zero work, shifted positive column labels, up to 4,096 columns and up to 512 active and allocated levels, with allocated extent at least the active count. Tropopause indices lie from zero through the active level count. Lower pressure indices lie from 1 through 12, upper indices from 13 through 58, and both temperature indices lie from 1 through 4. Foreign indices lie from 1 through 3, while lower self indices from 1 through 9. Supplied lower and upper table strides are both one. Upper self-continuum values and index are unused.

Lower pressure is finite, positive and at most 1,100 hPa. Upper pressure and all dry-air column values are unused and need no numerical values. Water, continuum density factors and aerosol depths are finite and nonnegative. Input weights and interpolation fractions are finite with magnitude at most $`2^{20}`$. Their original extrapolation is supported. Intermediate arithmetic and defined output depths must remain finite. Tables retain their genuine original setup, including empirical values and separately rounded reductions.

The reduced lower and upper line tables have 65 and 235 rows per spectral point. There are ten self nodes and four foreign nodes. Lower and upper Planck arrays contain twelve words each. Read these unchanged tables through their existing module symbols. Original setup combines sixteen points into groups of sizes 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2 and 2. Absorption coefficients use normalised supplied quadrature weights, while Planck fractions use unweighted sums. Independent 100-decimal checks validate these reductions and preserve source literal words without claiming new empirical-table accuracy.

Preserve x19-x29, the link register and sixteen-byte stack alignment, leaving x18 and d8-d15 untouched. The native body has no external numerical calls or variable-size private arrays. A fixed frame keeps the saved argument pointers and callee-saved registers separate.

## Arithmetic And Acceptance

Use FP64 round-to-nearest with ties to even, gradual underflow, preserved signed zeros and FPCR zero. Every declared subtraction, multiplication, division and addition rounds separately. Forbid fused arithmetic, reassociation, reduced precision and approximate instructions. Source constant 0.05 is FP64. Constants one, 100 and 900 are exact.

One small verifier checks independent line, continuum, pressure-correction, aerosol and Planck relations with higher-precision arithmetic, then compares complete original and native output owners byte for byte. Cases cover the pressure correction at and on both sides of 100 hPa, table corners and interpolation endpoints, zero water and continuum terms, upper unused pressure and self values, unused dry-air values, extrapolated factors, empty work, shifted columns, odd column counts, vertical tails, signed zeros and tiny positive values. Input owners are read-only, and guard pages expose owner bounds.

The independent physical relation bound is frozen as $`1024\epsilon C+1024u`$, where $`\epsilon=2^{-52}`$, $`u=2^{-1074}`$ and $`C`$ is the sum of the absolute mathematical contribution sizes after multiplication by the pressure-factor magnitude, plus the absolute aerosol depth. Copying a Planck word must also agree exactly with its frozen input word. Independent table reductions use $`128\epsilon C+128u`$ for weighted sums and $`32\epsilon\lvert S\rvert+32u`$ for unweighted Planck sums. These scientific bounds are separate from the zero-byte native output limit.

## Reusable Implementation Choice

Keep the lower layer's rounded pressure factor in a register while visiting its spectral points. Share the unchanged ordered four-corner interpolation and adjacent-node instructions between the lower and upper branches, while selecting each branch's own tables and complete addition order. This removes repeated setup without changing an arithmetic dependency. Comparative speed still requires quiet-node measurements of the complete forecast.


## Accepted Evidence

The genuine original setup passed 3,792 independent table reductions at 100 decimal digits and exact agreement for 256 source literal words. The second RADRRTM record supplies 38,400 bytes of original line coefficients. The supplied Planck weights sum to 1.000005009, and retain their rounded empirical source words without normalisation.

The native verifier passed 288 guarded placements, 118,368 independent physical relations and 14,434,560 complete output-owner bytes with zero differences. It covered 22,440 lower cells, 36,744 upper cells and 13,487,616 preserved storage bytes. Lower pressure tests covered 7,920 values below 100 hPa, 3,960 exact ties and 10,560 values above it. Upper pressure and self arrays and the complete dry-air array contained unusable numerical values, which confirmed that the unused arguments were not consumed. Read-only inputs, complete unchanged coefficient owners and FPCR zero were preserved. The first native numerical run passed.

The composable paired relay passed 24 parent calls, 288 independent relations and 67,200 complete owner bytes with zero differences. It covered 72 lower cells, 72 upper cells and 64,896 preserved storage bytes, with twenty-four lower values below, at and above the 100 hPa reference pressure. The relay is ready for a forecast batch. Full-forecast acceptance and comparative timing remain separate stages.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 observed 6,400 genuine calls. The same-input comparison covers 2,179,072,000 complete returned owner bytes with zero differences. Independent critical physics, unchanged inputs and the declared interface checks passed. All ten saved forecast files also match across 618,140 bytes. This result covers the declared routine domain and saved files. Independent whole-forecast physics, whole-process byte identity and comparative speed remain unproved.
