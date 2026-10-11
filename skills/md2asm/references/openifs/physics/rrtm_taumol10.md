# RRTM_TAUMOL10 Contract

Revision 1.0 preserves the complete OpenIFS Band10 update from [P01-P02](../../../../../formulations/openifs/physics/longwave_water_line_continuum.md). The complete outputs contain dimensionless absorption depths and Planck weights. This leaf writes points 109 through 114 of each 140-point owner and preserves every other bit.

## Complete Numerical Update

Visit increasing active layer and column indices. A layer at or below its supplied tropopause selects the lower line and Planck tables. Higher layers select the upper tables. All columns are active.

For one-based pressure and temperature indices $`J_P,J_T,J_{T1}`$, lower zero-based rows are $`I_0=5(J_P-1)+J_T-1`$ and $`I_1=5J_P+J_{T1}-1`$. Upper rows use $`I_0=5(J_P-13)+J_T-1`$ and $`I_1=5(J_P-12)+J_{T1}-1`$. Multiply weights 00, 10, 01 and 11 by line words at rows $`I_0,I_0+1,I_1,I_1+1`$. Add the four rounded products from left to right, then multiply the completed sum by water.

Each continuum subtracts its first temperature node from the adjacent node, multiplies the rounded difference by its supplied fraction and adds the first node. Multiply that result by its density factor. Lower absorption adds self, foreign and Band10 aerosol depths to the water term in that order. Upper absorption adds foreign then aerosol and must not read the self values or index. Copy the selected empirical Planck word directly to its output.

Atmospheric interpolation, aerosol preparation and genuine table setup are frozen input stages. No driver supplies a numerical stage from this leaf.

## ABI, Bounds And Storage

The application binary interface (ABI) is GNU Fortran on little-endian AArch64. Twenty-two by-address arguments occupy x0-x7 and fourteen eight-byte caller stack slots. Their source order is TDIMV, first column, last column, active level count, absorption output, aerosol depth, weights 00, 01, 10 and 11, foreign factor and fraction, foreign INTEGER4 index, pressure INTEGER4 index, two temperature INTEGER4 indices, water, tropopause INTEGER4 vector, self factor and fraction, self INTEGER4 index and Planck output.

TDIMV occupies 32 bytes and begins with the allocated level count. Let $`n`$ be the active column count and $`V`$ the allocated level count. Input fields store columns fastest, then allocated levels. Aerosol storage holds columns by allocated levels by sixteen bands. This leaf consumes its tenth band. Complete outputs hold columns by 140 spectral points by allocated levels, at cell offset $`c+n(g+140l)`$. Integer arrays need four-byte alignment and floating-point arrays need eight-byte alignment. Complete owner capacities are present and input owners are disjoint from output owners.

Support empty work, shifted positive column labels, up to 4,096 columns and 512 active and allocated levels, with allocated extent at least the active count. Tropopause indices lie from zero through the active count. Lower pressure indices lie from 1 through 12, upper indices from 13 through 58 and both temperature indices from 1 through 4. Foreign indices lie from 1 through 3 and lower self indices from 1 through 9. Both supplied line strides equal one. Consumed columns, density factors and aerosol are finite and nonnegative. Interpolation weights and fractions are finite with magnitude at most $`2^{20}`$. Extrapolation is retained and all defined intermediates and outputs remain finite.

The unchanged module tables contain 65 lower and 235 upper line rows per spectral point, ten self nodes, four foreign nodes and six Planck words for each atmospheric branch. Original setup combines sixteen points into groups of sizes 2, 2, 2, 2, 4 and 4. Absorption uses normalised quadrature weights, while Planck fractions use unweighted sums.

Preserve x19-x29, the link register and sixteen-byte stack alignment, leaving x18 and d8-d15 untouched. The direct body uses a fixed 352-byte frame and has no external numerical calls or variable-size private arrays.

## Arithmetic And Acceptance

FP64 means 64-bit floating-point numbers. Use FP64 round-to-nearest with ties to even, gradual underflow, preserved signed zeros and FPCR zero. Every subtraction, multiplication and addition rounds separately. Forbid fused arithmetic, reassociation, approximation and reduced precision.

Reuse the accepted four-corner and adjacent-continuum routes. The new small verifier checks the band's genuine tables, independent complete absorption and Planck relations, then every original and native owner byte. Cases cover table corners and endpoints, zero water and continuum terms, upper unused self inputs, extrapolated weights, empty work, shifted and odd columns, vertical tails, signed zeros and tiny values. Read-only inputs, complete unchanged coefficient owners and guard pages check storage bounds.

The frozen independent physical bound is $`1024\epsilon C+1024u`$, where $`\epsilon=2^{-52}`$, $`u=2^{-1074}`$ and $`C`$ is the sum of absolute water, continuum and aerosol contributions. Planck words must also equal their selected input words exactly. Independent table reductions use $`128\epsilon C+128u`$ for weighted coefficients and $`32\epsilon\lvert S\rvert+32u`$ for Planck sums. The native output limit is zero different bytes.

## Reusable Implementation Choice

Share the ordered four-corner and foreign-continuum instructions across the atmospheric branches, while retaining the lower branch's self-continuum stage. Keep unchanged per-cell weights and factors in registers across the six spectral points. Comparative performance requires quiet-node measurements of the complete forecast.

## Accepted Evidence

The genuine original setup passed 1,896 independent reductions at 100 decimal digits and exact agreement for 256 source literal words. The tenth RADRRTM record supplies 38,400 bytes of line data. Its empirical Planck sum is 1.000008718 and is retained without normalisation.

The first native numerical run passed 288 guarded placements, 59,184 independent relations and 14,434,560 complete output-owner bytes with zero differences. It covered 11,220 lower cells and 18,372 upper cells, preserving 13,961,088 untouched bytes, all read-only inputs, unchanged coefficient owners and FPCR zero.

The composable paired relay passed 24 parent calls, 144 independent relations and 67,200 complete output-owner bytes with zero differences. It covered 36 lower cells and 36 upper cells, preserving 66,048 untouched bytes and FPCR zero. The relay is ready for a forecast batch. Full-forecast acceptance and comparative timing remain separate stages.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 observed 6,400 genuine calls. The same-input comparison covers 2,179,072,000 complete returned owner bytes with zero differences. Independent critical physics, unchanged inputs and the declared interface checks passed. All ten saved forecast files also match across 618,140 bytes. This result covers the declared routine domain and saved files. Independent whole-forecast physics, whole-process byte identity and comparative speed remain unproved.
