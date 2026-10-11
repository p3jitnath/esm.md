# RRTM_TAUMOL1 Contract

Revision 1.0 preserves the complete OpenIFS Band1 calculation from [P01-P03](../../../../../formulations/openifs/physics/longwave_water_nitrogen.md). It produces dimensionless absorption depths and Planck weights for the first ten points in a complete 140-point longwave output owner. The formulation uses the current 10 to 350 cm$`^{-1}`$ band limits.

## Complete Numerical Update

Visit increasing active layer and column indices. A layer at or below its supplied tropopause uses the lower tables. Higher layers use the upper tables. All columns are active, including night columns. Spectral points outside this band's first ten points and levels outside the active count preserve every incoming bit.

With one-based source pressure and temperature indices $`J_P,J_T,J_{T1}`$, lower zero-based rows are $`I_0=5(J_P-1)+(J_T-1)`$ and $`I_1=5J_P+(J_{T1}-1)`$. Upper rows are $`I_0=5(J_P-13)+(J_T-1)`$ and $`I_1=5(J_P-12)+(J_{T1}-1)`$. Multiply weights 00, 10, 01 and 11 by coefficients at rows $`I_0,I_0+1,I_1,I_1+1`$, rounding each product and each left-to-right addition separately. Multiply the completed line sum by water.

For each continuum or nitrogen coefficient, subtract its first temperature node from the adjacent node, multiply the rounded difference by its supplied fraction and add the first node. Multiply the self and foreign results by their own factors. Form the nitrogen scaling as a separately rounded broadening-column times supplied density-factor product, then multiply it by the interpolated nitrogen coefficient. The lower absorption adds self, foreign and nitrogen terms to the rounded water line term in that order. The upper absorption adds foreign then nitrogen and must not read the self-continuum values or index.

For lower pressure below 250 hPa, subtract pressure from 250, multiply by FP64 0.15, divide by FP64 154.4 and subtract from one. At or above 250 hPa, the lower factor is exactly one. For upper pressure, divide by FP64 95.6, multiply by FP64 0.15 and subtract from one. Multiply the completed gas absorption by this rounded factor, then add the supplied Band1 aerosol depth. These multiplication and division orders follow the separate expressions and remain distinct.

Copy the selected lower or upper Planck coefficient word directly to its output. Do not normalise these empirical weights or add a rounding stage. Table setup, aerosol preparation and atmospheric interpolation inputs are unchanged frozen stages outside this leaf. No driver supplies a numerical stage from the leaf.

## ABI, Bounds And Storage

The application binary interface (ABI) is GNU Fortran on little-endian AArch64. Twenty-seven by-address arguments occupy x0-x7 and nineteen eight-byte caller stack slots. Their source order is TDIMV, first column, last column, active level count, absorption output, pressure, aerosol depth, four interpolation weight fields 00, 01, 10 and 11, foreign factor and fraction, foreign INTEGER4 index, pressure INTEGER4 index, two temperature INTEGER4 indices, water column, tropopause INTEGER4 vector, self factor and fraction, self INTEGER4 index, Planck output, minor-gas fraction, minor-gas INTEGER4 index, nitrogen density factor and broadening column.

TDIMV occupies 32 bytes and contains the allocated vertical extent in its first INTEGER4 field. Let $`n`$ be the active column count and $`V`$ the allocated level count. Input fields store columns fastest, then allocated levels. Aerosol storage holds columns by allocated levels by all sixteen bands, although this leaf reads only the first band. Both complete outputs hold columns by all 140 spectral points by allocated levels. Their cell offset is $`c+n(g+140l)`$, with zero-based indices. This layout differs from the input fields and must be preserved. INTEGER4 arrays need four-byte alignment and FP64 arrays need eight-byte alignment. All true owner capacities are present and input owners are disjoint from output owners.

Support zero work, shifted positive column labels, up to 4,096 columns and up to 512 active and allocated levels, with allocated extent at least the active count. Tropopause indices lie from zero through the active level count. Lower pressure indices lie from 1 through 12, upper indices from 13 through 58, and both temperature indices lie from 1 through 4. Foreign indices lie from 1 through 3, minor-gas indices from 1 through 18 and lower self indices from 1 through 9. Supplied lower and upper table strides are both one. Upper self-continuum values and index are unused.

Pressure is finite and positive, with upper pressure at most 250 hPa. Water, broadening column, density factors and aerosol depths are finite and nonnegative. Input weights and interpolation fractions are finite with magnitude at most $`2^{20}`$. Their original extrapolation is supported. Intermediate arithmetic and defined output depths must remain finite. Tables retain their genuine original setup, including empirical values and separately rounded reductions.

The reduced lower and upper line tables have 65 and 235 rows per spectral point. There are ten self nodes, four foreign nodes and nineteen nitrogen nodes. Lower and upper Planck arrays contain ten words each. Read these unchanged tables through their existing module symbols. Original setup combines sixteen points into groups of sizes 1, 1, 2, 2, 2, 2, 2, 2, 1 and 1. Absorption coefficients use normalised supplied quadrature weights, while Planck fractions use unweighted sums. Independent 100-decimal checks validate these reductions and preserve source literal words without claiming new empirical-table accuracy.

Preserve x19-x29, the link register and sixteen-byte stack alignment, leaving x18 and d8-d15 untouched. The native body has no external numerical calls or variable-size private arrays. A fixed frame keeps the saved argument pointers and callee-saved registers separate.

## Arithmetic And Acceptance

Use FP64 round-to-nearest with ties to even, gradual underflow, preserved signed zeros and FPCR zero. Every declared subtraction, multiplication, division and addition rounds separately. Forbid fused arithmetic, reassociation, reduced precision and approximate instructions. Source constants 0.15, 154.4 and 95.6 are FP64. Constants one and 250 are exact.

One small verifier checks independent line, continuum, nitrogen, pressure-correction, aerosol and Planck relations with higher-precision arithmetic, then compares complete original and native output owners byte for byte. Cases cover each pressure branch and threshold tie, table corners and interpolation endpoints, zero individual gas terms, upper unused self values, extrapolated factors, empty work, shifted columns, odd column counts, vertical tails, signed zeros and tiny positive values. Input owners are read-only, and guard pages expose owner bounds.

The independent physical relation bound is frozen as $`1024\epsilon C+1024u`$, where $`\epsilon=2^{-52}`$, $`u=2^{-1074}`$ and $`C`$ is the sum of the absolute mathematical contribution sizes after multiplication by the pressure-factor magnitude, plus the absolute aerosol depth. Copying a Planck word must also agree exactly with its frozen input word. Independent table reductions use $`128\epsilon C+128u`$ for weighted sums and $`32\epsilon\lvert S\rvert+32u`$ for unweighted Planck sums. These scientific bounds are separate from the zero-byte native output limit.

## Reusable Implementation Choice

Keep a layer's rounded pressure factor and nitrogen scale in registers while visiting its spectral points. Share the unchanged ordered four-corner interpolation and adjacent-node instructions between the lower and upper branches, while selecting each branch's own tables and complete addition order. This removes repeated setup without changing an arithmetic dependency. Comparative speed still requires quiet-node measurements of the complete forecast.

## Accepted Evidence

The genuine original setup passed 3,540 independent table reductions at 100 decimal digits and exact agreement for 864 source literal words. The first RADRRTM record supplies 38,400 bytes of original line coefficients. The supplied Planck weights sum to 1.000008266 because their empirical source values are rounded. Preserve those original words and their accepted reduction without normalisation.

The native verifier passed 288 guarded placements, 98,640 independent physical relations and 14,434,560 complete output-owner bytes with zero differences. It covered 18,700 lower cells, 30,620 upper cells and 13,645,440 preserved storage bytes. Lower pressure tests covered 9,900 values below 250 hPa, 3,300 exact threshold values and 5,500 values above it. Inputs remained read-only, complete coefficient owners remained unchanged and FPCR remained zero. The first numerical run passed.

The composable paired relay passed 24 parent calls, 240 independent relations and 67,200 complete owner bytes with zero differences. It covered 60 lower cells, 60 upper cells and 65,280 preserved storage bytes, including twenty lower values on each side of the threshold and twenty exact ties. These results establish the declared leaf and make its relay ready for the next forecast batch. Full-forecast acceptance and comparative timing remain separate stages.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 observed 6,400 genuine calls. The same-input comparison covers 2,179,072,000 complete returned owner bytes with zero differences. Independent critical physics, unchanged inputs and the declared interface checks passed. All ten saved forecast files also match across 618,140 bytes. This result covers the declared routine domain and saved files. Independent whole-forecast physics, whole-process byte identity and comparative speed remain unproved.
