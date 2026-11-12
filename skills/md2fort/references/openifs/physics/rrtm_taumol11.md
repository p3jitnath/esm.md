# RRTM_TAUMOL11 Contract

Revision 1.0 preserves the complete OpenIFS Band11 update from [P01-P02](../../../../../formulations/openifs/physics/longwave_water_oxygen.md). This leaf writes dimensionless absorption depths and Planck weights at points 115 through 122 of each 140-point owner, preserving every other bit.

## Complete Numerical Update

Visit increasing active layer and column indices. A layer at or below its supplied tropopause selects the lower line, oxygen and Planck tables. Higher layers select their upper tables. All columns are active.

For one-based pressure and temperature indices $`J_P,J_T,J_{T1}`$, lower zero-based rows are $`I_0=5(J_P-1)+J_T-1`$ and $`I_1=5J_P+J_{T1}-1`$. Upper rows use $`I_0=5(J_P-13)+J_T-1`$ and $`I_1=5(J_P-12)+J_{T1}-1`$. Multiply weights 00, 10, 01 and 11 by line words at rows $`I_0,I_0+1,I_1,I_1+1`$. Add the four rounded products from left to right, then multiply the completed sum by water.

Each continuum subtracts its first temperature node from the adjacent node, multiplies the rounded difference by its supplied fraction and adds the first node. Multiply that result by its density factor. Lower absorption adds self then foreign to the rounded water line term. Upper absorption adds foreign and must not read self values or their index.

First multiply oxygen by its supplied minor-gas density scale, retaining this rounded product. The original name minor gas denotes its smaller absorption contribution. Subtract adjacent oxygen temperature nodes, multiply by the supplied minor fraction and add the first node. Multiply that rounded interpolation by the rounded oxygen scale. Add oxygen absorption after water and continuum, then add Band11 aerosol depth. Copy the selected empirical Planck word directly to its output. Interpolation, aerosol preparation and genuine table setup are frozen inputs. No driver supplies an omitted numerical stage.

## ABI, Bounds And Storage

The application binary interface (ABI) is GNU Fortran on little-endian AArch64. Twenty-six by-address arguments occupy x0-x7 and eighteen eight-byte caller stack slots. Their source order is TDIMV, first column, last column, active level count, absorption output, aerosol depth, weights 00, 01, 10 and 11, foreign factor and fraction, foreign INTEGER4 index, pressure INTEGER4 index, two temperature INTEGER4 indices, water, oxygen, tropopause INTEGER4 vector, self factor and fraction, self INTEGER4 index, Planck output, minor fraction, minor INTEGER4 index and minor density scale.

TDIMV occupies 32 bytes and begins with the allocated level count. Let $`n`$ be the active column count and $`V`$ the allocated level count. Input fields store columns fastest, then allocated levels. Aerosol storage holds columns by allocated levels by sixteen bands. This leaf consumes its eleventh band. Complete outputs hold columns by 140 spectral points by allocated levels, at cell offset $`c+n(g+140l)`$. Integer arrays need four-byte alignment and floating-point arrays need eight-byte alignment. Complete owner capacities are present and input owners are disjoint from output owners.

Support empty work, shifted positive column labels, up to 4,096 columns and 512 active and allocated levels, with allocated extent at least the active count. Tropopause indices lie from zero through the active count. Lower pressure indices lie from 1 through 12, upper indices from 13 through 58 and both temperature indices from 1 through 4. Foreign indices lie from 1 through 3, lower self indices from 1 through 9 and minor indices from 1 through 18. Both supplied line strides equal one.

Consumed gas columns, density factors and aerosol are finite and nonnegative. Interpolation weights and fractions are finite with magnitude at most $`2^{20}`$. Extrapolation is retained. The oxygen-density product and all defined intermediate and output values remain finite. Upper self values and index need no numerical values.

The unchanged module tables contain 65 lower and 235 upper line rows per point, ten self nodes, four foreign nodes, nineteen lower and upper oxygen nodes and eight Planck words for each branch. Original setup combines sixteen points into groups of sizes 1, 1, 2, 2, 2, 2, 3 and 3. Absorption uses normalised quadrature weights, while Planck fractions use unweighted sums.

Preserve x19-x29, the link register and sixteen-byte stack alignment, leaving x18 and d8-d15 untouched. The complete direct body uses a fixed 352-byte frame and has no external numerical calls or variable-size private arrays.

## Arithmetic And Acceptance

FP64 means 64-bit floating-point numbers. Use FP64 round-to-nearest with ties to even, gradual underflow, preserved signed zeros and FPCR zero. Every subtraction, multiplication and addition rounds separately. Forbid fused arithmetic, reassociation, approximation and reduced precision.

Reuse the accepted four-corner, adjacent-continuum and complete minor-gas routes. The new small verifier checks genuine tables, independent complete water, oxygen, continuum, aerosol and Planck relations, then every original and native owner byte. Cases cover all table limits and endpoints, zero water, oxygen scale and continuum terms, upper unused self inputs, extrapolated weights and fractions, empty work, shifted and odd columns, vertical tails, signed zeros and tiny values. Read-only inputs, unchanged coefficient owners and guard pages check bounds.

The frozen independent physical bound is $`1024\epsilon C+1024u`$, where $`\epsilon=2^{-52}`$, $`u=2^{-1074}`$ and $`C`$ is the sum of absolute water, continuum, oxygen and aerosol contributions. Planck words must also equal their selected input words exactly. Independent table reductions use $`128\epsilon C+128u`$ for weighted coefficients and $`32\epsilon\lvert S\rvert+32u`$ for Planck sums. The native output limit is zero different bytes.

## Reusable Implementation Choice

Prepare the oxygen-density product once per cell and reuse it across all eight points. Share ordered line, foreign-continuum and minor-gas instructions across branches, retaining the lower self stage and each branch's own oxygen table. Comparative performance requires quiet-node measurements of the full forecast.

## Accepted Evidence

The genuine original setup passed 2,832 independent reductions at 100 decimal digits and exact agreement for 864 source literal words. The eleventh RADRRTM record supplies 38,400 bytes of line data. Its empirical Planck sum is 0.999998452 and is retained without normalisation.

The first native numerical run passed 288 guarded placements, 78,912 independent relations and 14,434,560 complete output-owner bytes with zero differences. It covered 14,960 lower cells and 24,496 upper cells, preserving 13,803,264 untouched bytes, read-only inputs, unchanged coefficient owners and FPCR zero.

The composable paired relay passed 24 parent calls, 192 independent relations and 67,200 complete output-owner bytes with zero differences. It covered 48 lower cells and 48 upper cells, preserving 65,664 untouched bytes and FPCR zero. The relay is ready for a forecast batch. Full-forecast acceptance and comparative timing remain separate stages.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 observed 6,400 genuine calls. The same-input comparison covers 2,179,072,000 complete returned owner bytes with zero differences. Independent critical physics, unchanged inputs and the declared interface checks passed. All ten saved forecast files also match across 618,140 bytes. This result covers the declared routine domain and saved files. Independent whole-forecast physics, whole-process byte identity and comparative speed remain unproved.
