# RRTM_TAUMOL4 Contract

Revision 1.0 preserves the complete OpenIFS Band4 calculation from [P01-P02](../../../../../formulations/openifs/physics/longwave_water_carbon_dioxide_ozone.md). It produces dimensionless absorption depths and Planck weights at points thirty-nine through fifty-two in each complete 140-point longwave output owner.

## Complete Numerical Update

Visit increasing active layer and column indices. A layer at or below its supplied tropopause uses water, carbon dioxide and lower tables. Higher layers use ozone, carbon dioxide and upper tables. All columns are active. Other spectral points and allocated level tails preserve every incoming bit.

At entry, divide the supplied reference water and carbon-dioxide columns at level eleven to obtain $`R_A=\chi(1,11)/\chi(2,11)`$. Divide reference ozone and carbon dioxide at level thirteen to obtain $`R_B=\chi(3,13)/\chi(2,13)`$. These two FP64 divisions belong inside the assembly leaf. Their genuine reference words come from the original SURRTRF setup.

For each pressure corner, multiply its supplied gas ratio by carbon dioxide, then add water or ozone to obtain its rounded combined column $`Q`$. Divide that layer's selected species by $`Q`$ and cap the resulting fraction $`s`$ at the scalar ONEMINUS value. Lower mixture positions are $`x=8s`$ and upper positions are $`x=4s`$. Truncate nonnegative $`x`$ to its zero-based mixture index $`j`$, then retain its fractional part $`f=x-j`$. This gives the same MOD result on the declared nonnegative domain, including signed zero. Prepare the Planck mixture through the same complete operations using $`R_A`$ or $`R_B`$, independently of both supplied pressure-corner ratios.

With one-based source indices $`J_P,J_T,J_{T1}`$, lower zero-based base rows are $`I_0=9[5(J_P-1)+J_T-1]`$ and $`I_1=9[5J_P+J_{T1}-1]`$. Upper rows are $`I_0=5[5(J_P-13)+J_T-1]`$ and $`I_1=5[5(J_P-12)+J_{T1}-1]`$. Add each pressure corner's own mixture index to its own row. The first corner uses temperature weights 00 and 10, while the second uses 01 and 11.

For upper mixtures and lower fractions from 0.125 through 0.875 inclusive, multiply the two temperature weights by $`1-f`$ and $`f`$. Multiply these four rounded weights by successive mixture nodes at the first and second temperature, adding the four products from left to right. The second temperature starts nine rows later below the tropopause and five rows later above it.

Lower fractions outside that middle interval use three mixture nodes at each temperature. For $`s<0.125`$, set $`p=f-1`$. For $`s>0.875`$, set $`p=-f`$. Square $`p`$, then square the rounded square, preserving both rounding points. Set $`h_0=p^4`$, $`h_1=(1-p)-2p^4`$ and $`h_2=p+p^4`$, rounding each operation. Multiply each coefficient by its supplied temperature weight before multiplying by a table word. The low-fraction branch visits rows $`I+j,I+j+1,I+j+2`$, then those same offsets nine rows later, using coefficients $`h_0,h_1,h_2`$. The high-fraction branch visits rows $`I+j-1,I+j,I+j+1`$, then those offsets nine rows later, using $`h_2,h_1,h_0`$. Add all six products in that order.

Multiply each complete corner sum by its own rounded combined column, then add the first and second corner depths. Lower layers next add self continuum, foreign continuum and supplied Band4 aerosol depth in that order. Each continuum subtracts adjacent temperature nodes, multiplies that rounded difference by its supplied fraction, adds the first node, then multiplies by its density factor. Upper layers add aerosol directly and must not read water, lower ratios, self or foreign values and indices. Lower layers must not read ozone or upper ratios.

The complete upper gas and aerosol depth is multiplied at local points eight through fourteen by the supplied empirical factors 0.92, 0.88, 1.07, 1.10, 0.99, 0.88 and 0.943. Each factor is first rounded as a source FP32 literal, then widened exactly to FP64. Preserve this final multiplication and its rounding point. Independent cells allow this multiplication immediately after each cell's complete depth sum.

For each Planck output, subtract adjacent selected mixture nodes, multiply the rounded difference by the independent Planck mixture fraction, then add the first node. Do not normalise the empirical fractions. Atmospheric interpolation, aerosol preparation and genuine table setup are frozen input stages outside the leaf. No driver supplies an omitted numerical stage.

## ABI, Bounds And Storage

The application binary interface (ABI) is GNU Fortran on little-endian AArch64. Twenty-nine by-address arguments occupy x0-x7 and twenty-one eight-byte caller stack slots. Their source order is TDIMV, first column, last column, active level count, absorption output, aerosol depth, four interpolation weights 00, 01, 10 and 11, foreign factor and fraction, foreign INTEGER4 index, pressure INTEGER4 index, two temperature INTEGER4 indices, scalar ONEMINUS, water, carbon dioxide, ozone, tropopause INTEGER4 vector, self factor and fraction, self INTEGER4 index, Planck output, two water-carbon-dioxide ratios and two ozone-carbon-dioxide ratios.

TDIMV occupies 32 bytes and begins with the allocated vertical extent. Let $`n`$ be the active column count and $`V`$ the allocated level count. All input arrays store columns fastest, then allocated levels. Aerosol storage holds columns by allocated levels by sixteen bands and this leaf reads the fourth band. Complete outputs store columns by 140 spectral points by allocated levels, at zero-based cell offset $`c+n(g+140l)`$. INTEGER4 arrays need four-byte alignment and FP64 arrays need eight-byte alignment. Complete owner capacities are present and input owners are disjoint from output owners.

Support empty work, shifted positive column labels, up to 4,096 columns and up to 512 active and allocated levels, with allocated extent at least the active count. Tropopause indices lie from zero through the active level count. Lower pressure indices lie from 1 through 12, upper indices from 13 through 58, and both temperature indices lie from 1 through 4. Lower foreign indices lie from 1 through 3 and self indices from 1 through 9. Lower and upper mixture strides are nine and five.

The scalar cap is finite and strictly between zero and one. Consumed species columns, carbon dioxide, gas ratios and aerosol depths are finite and nonnegative. Both rounded corner columns and the rounded Planck column are strictly positive. Interpolation weights and consumed continuum fractions and factors are finite with magnitude at most $`2^{20}`$. Their original extrapolation is supported. All declared intermediates and outputs remain finite. Each branch's unused arguments need no numerical values.

The reduced line tables have 585 lower rows and 1,175 upper rows per spectral point. There are ten lower self nodes and four lower foreign nodes. Planck storage contains fourteen spectral words at each of nine lower and five upper mixture nodes. The genuine reference atmosphere contains seven species at 59 levels. Read these unchanged inputs through their existing module symbols. Original setup combines sixteen points into thirteen groups of size one and one group of size three. Absorption coefficients use normalised quadrature weights and Planck fractions use unweighted sums.

Preserve x19-x29, the link register and sixteen-byte stack alignment, leaving x18 and d8-d15 untouched. The complete direct leaf uses a fixed 544-byte frame for saved pointers, registers, two reference ratios and reusable corner weights. It makes no external numerical calls.

## Arithmetic And Acceptance

Use FP64 round-to-nearest with ties to even, gradual underflow, preserved signed zeros and FPCR zero. Every declared operation rounds separately. Forbid fused arithmetic, reassociation, approximate instructions and reduced-precision numerical calculations. The seven source FP32 empirical constants are widened before the FP64 final-depth multiplication.

The small verifier checks mixed gas absorption, both independent pressure-corner mixtures, continuum contributions, upper corrections and reference Planck mixtures with higher-precision arithmetic. It compares complete original and native owner bytes, including untouched storage. Cases cover all nine combinations of the three lower mixture branches, both sides of 0.125 and 0.875 and exact ties, mixture bins, both pressure and temperature limits, the strict cap, upper unused inputs, extrapolated weights, zero species, signed zeros, tiny and subnormal columns, empty work, shifted columns, odd counts and vertical tails. Read-only owners and guard pages check input preservation and bounds.

The frozen independent physical bound is $`1024\epsilon C+1024u`$, where $`\epsilon=2^{-52}`$, $`u=2^{-1074}`$ and $`C`$ is the sum of absolute mathematical contributions, including the final correction-factor magnitude and aerosol. Planck uses the absolute adjacent-node contribution sum. Independent table reductions use $`128\epsilon C+128u`$ for weighted coefficients and $`32\epsilon\lvert S\rvert+32u`$ for Planck sums. These scientific bounds are separate from the zero-byte native agreement limit.

## Reusable Implementation Choice

Prepare each pressure corner's complete mixture weights once per atmospheric cell and reuse them across its fourteen spectral points. Keep its own combined column, row and four-node or six-node selection separate from the other corner. The direct upper calculation keeps its own five-node mixture width and final empirical multiplication. This preserves the complete arithmetic while avoiding repeated mixture setup. Comparative speed requires quiet-node measurements of the full forecast.

## Accepted Evidence

The genuine original setup passed 25,032 independent reductions at 100 decimal digits and exact agreement for 861 source literal words, including the complete reference atmosphere. The fourth RADRRTM record supplies 225,280 bytes of original line coefficients. Each empirical Planck node retains its supplied rounded sum.

The native verifier passed 512 guarded placements, 245,504 independent physical relations and 25,661,440 complete output-owner bytes with zero differences. It covered 47,740 lower cells, 75,012 upper cells, 33,880 low-mixture checks, 40,040 middle-mixture checks, 21,560 high-mixture checks and 37,506 corrected upper cells. It preserved 23,697,408 untouched output bytes, all read-only inputs, unchanged coefficient owners and FPCR zero. The first numerical run passed.

The composable paired relay passed 72 parent calls, 1,008 independent relations and 201,600 complete output-owner bytes with zero differences. It covered 252 lower and 252 upper cells, 168 checks for each lower mixture branch and 126 corrected upper cells. It preserved 193,536 untouched bytes and FPCR zero. The relay is ready for a forecast batch. Full-forecast acceptance and comparative timing remain separate stages.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 observed 6,400 genuine calls. The same-input comparison covers 2,179,072,000 complete returned owner bytes with zero differences. Independent critical physics, unchanged inputs and the declared interface checks passed. All ten saved forecast files also match across 618,140 bytes. This result covers the declared routine domain and saved files. Independent whole-forecast physics, whole-process byte identity and comparative speed remain unproved.
