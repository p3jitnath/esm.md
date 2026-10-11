# RRTM_TAUMOL16 Contract

Revision 1.0 preserves the complete OpenIFS Band16 calculation from [P01-P02](../../../../../formulations/openifs/physics/longwave_water_methane.md). It writes dimensionless absorption depths and Planck weights at points 139 through 140 in each complete 140-point longwave output owner.

## Complete Numerical Update

Visit increasing active layer and column indices. Lower layers use water, methane and the supplied lower tables. Upper layers retain the complete methane-only line calculation and copy their supplied upper Planck words. Preserve every incoming bit at other spectral points and allocated level tails.

At entry, divide the supplied reference columns to obtain $`R=\chi(1,6)/\chi(6,6)`$. This FP64 division belongs inside the direct leaf. The complete genuine reference atmosphere comes from the accepted SURRTRF setup.

Each lower pressure corner independently forms $`Q=\operatorname{RN}(W+\operatorname{RN}(rM))`$, then $`s=\min(\text{ONEMINUS},\operatorname{RN}(W/Q))`$. Here RN means one FP64 rounding. Form $`x=8s`$, truncate nonnegative $`x`$ to the zero-based mixture index $`j`$ and retain $`f=x-j`$. This matches the source MOD calculation, including signed zero. Prepare the independent Planck mixture through the same operations with reference ratio $`R`$.

With one-based source indices, the zero-based corner rows are $`I_0=9[5(J_P-1)+J_T-1]`$ and $`I_1=9[5J_P+J_{T1}-1]`$. The first corner uses temperature weights 00 and 10. The second uses 01 and 11. Each corner retains its own combined column, mixture index and fraction.

For $`0.125\le s\le0.875`$, form four rounded temperature-mixture weights from $`1-f`$ and $`f`$. Multiply these by the table words at rows $`I+j,I+j+1,I+j+9,I+j+10`$, then add the four products from left to right.

For $`s<0.125`$, set $`p=f-1`$. For $`s>0.875`$, set $`p=-f`$. Square $`p`$, then square that rounded square. Form $`h_0=p^4`$, $`h_1=(1-p)-2p^4`$ and $`h_2=p+p^4`$, rounding each operation. Multiply each coefficient by its temperature weight before multiplying by its table word. The low branch visits $`I+j,I+j+1,I+j+2,I+j+9,I+j+10,I+j+11`$ with coefficients $`h_0,h_1,h_2,h_0,h_1,h_2`$. The high branch visits $`I+j-1,I+j,I+j+1,I+j+8,I+j+9,I+j+10`$ with coefficients $`h_2,h_1,h_0,h_2,h_1,h_0`$. Add all six products in that order.

Multiply each complete corner sum by its own rounded $`Q`$. Add the first and second corner depths, then self continuum, foreign continuum and Band16 aerosol in that order. Each continuum subtracts adjacent temperature nodes, multiplies the rounded difference by its supplied fraction, adds the first node, then multiplies by its supplied density factor. Each Planck output subtracts adjacent selected mixture nodes, multiplies by the independent Planck fraction, then adds the first node. Do not normalise the supplied fractions.

For upper layers, form the complete integer rows $`I_0=[5(J_P-13)+J_T-1]\,\text{NSPB}(16)`$ and $`I_1=[5(J_P-12)+J_{T1}-1]\,\text{NSPB}(16)`$. The genuine original setup fixes $`\text{NSPB}(16)=0`$. Both rows are therefore zero. Read the two adjacent upper words at each corner and multiply them by weights 00, 10, 01 and 11. Add all four products from left to right, multiply the complete sum by methane, then add Band16 aerosol. Copy the supplied upper Planck word exactly. This branch does not consume water, gas-mixture ratios, the scalar cap or either continuum.

The frozen zero stride means that upper pressure and temperature indices do not select different table rows. This is the original supplied parameterisation. Acceptance establishes its ordered numerical relation and exact implementation, without claiming new physical accuracy for the empirical radiation tables.

Atmospheric interpolation, aerosol preparation and genuine table setup are frozen input stages outside this leaf. No driver supplies an omitted numerical stage. The lower mixture route reuses the accepted [Band4 arithmetic](rrtm_taumol4.md).

## ABI, Bounds And Storage

The application binary interface (ABI) is GNU Fortran on little-endian AArch64. Twenty-six by-address arguments occupy x0-x7 and eighteen eight-byte caller stack slots. Their source order is TDIMV, first column, last column, active level count, depth output, aerosol, four interpolation weights 00, 01, 10 and 11, foreign factor and fraction, foreign INTEGER4 index, pressure INTEGER4 index, two temperature INTEGER4 indices, scalar ONEMINUS, water, methane, tropopause INTEGER4 vector, self factor and fraction, self INTEGER4 index, Planck output and two water-methane ratios.

TDIMV occupies 32 bytes and begins with the allocated vertical extent. Let $`n`$ be the active column count and $`V`$ the allocated level count. Inputs store columns fastest, then allocated levels. Aerosol storage holds columns by allocated levels by sixteen bands and this leaf reads the sixteenth band. Complete outputs store columns by 140 spectral points by allocated levels, with zero-based offset $`c+n(g+140l)`$. INTEGER4 arrays need four-byte alignment and FP64 arrays need eight-byte alignment. Complete owner capacities are present and input owners are disjoint from output owners.

Support empty work, shifted positive column labels, up to 4,096 columns and 512 active and allocated levels, with allocated extent at least the active count. Tropopause indices range from zero through the active level count. Consumed lower pressure indices range from 1 through 12 and upper pressure indices from 13 through 58. Both temperature indices range from 1 through 4, foreign indices from 1 through 3 and self indices from 1 through 9. The lower mixture stride is nine.

Consumed lower water and mixture ratios, all active methane columns and aerosol depths are finite and nonnegative. The lower scalar cap is finite and strictly between zero and one. Lower rounded combined corner and Planck columns are strictly positive. All active interpolation weights and consumed lower continuum factors and fractions are finite with magnitude at most $`2^{20}`$, and the original extrapolation remains supported. Declared intermediate values and outputs remain finite. Unused upper arguments need no numerical values.

The unchanged lower and upper reduced line tables have 585 and 235 rows per spectral point. Self and foreign continua have ten and four nodes. Planck storage has two spectral words at each of nine lower mixture nodes and two constant upper Planck words. The genuine reference atmosphere has seven species at 59 levels. Original setup groups sixteen points in sizes four and twelve. Line and continuum coefficients use normalised quadrature weights. Planck fractions use unweighted sums.

Preserve x19-x29, the link register and sixteen-byte stack alignment, leaving x18 and d8-d15 untouched. The complete direct leaf uses a fixed 512-byte frame for saved pointers, registers, its reference ratio and reusable corner weights. It makes no external numerical calls.

## Arithmetic And Acceptance

Use FP64 round-to-nearest with ties to even, gradual underflow, signed zeros and FPCR zero. Every declared operation rounds separately. Forbid fused arithmetic, reassociation, approximate instructions and reduced precision.

The small verifier checks complete lower mixture absorption, continua, reference Planck mixtures, the full upper methane calculation and exact upper Planck copies. It compares complete original and native output owners. Cases cover all nine corner-branch combinations, both sides of mixture thresholds and exact ties, mixture bins, pressure and temperature limits, the strict cap, poisoned unused upper inputs, extrapolated weights, zero species, signed zeros, tiny and subnormal columns, empty work, shifted columns, odd counts and vertical tails. Read-only inputs and guard pages check preservation and bounds.

The frozen independent physical bound is $`1024\epsilon C+1024u`$, where $`\epsilon=2^{-52}`$, $`u=2^{-1074}`$ and $`C`$ is the sum of absolute mathematical contributions. Independent weighted reductions use $`128\epsilon C+128u`$ and Planck sums use $`32\epsilon\lvert S\rvert+32u`$. These scientific bounds are separate from the zero-byte native agreement limit.

## Reusable Implementation Choice

Prepare both complete pressure-corner mixtures once per lower atmospheric cell and reuse them across two spectral points. Retain the complete upper four-term sum and its final methane multiplication. Keep its fixed-row selection separate from the lower nine-node mixture arithmetic. These choices preserve the original dependencies while reducing repeated preparation. Comparative speed requires quiet-node forecast measurements.

## Accepted Evidence

The genuine original setup passed 1,688 independent reductions at 100 decimal digits and exact agreement for 384 source literal words. It reused the accepted complete 413-word reference-atmosphere proof. The sixteenth RADRRTM record supplies 104,960 bytes of original line coefficients. The source setup independently confirms spectral groups four and twelve, upper mixture stride zero and a band width of 650 cm inverse. Empirical Planck sums remain unchanged.

The native verifier passed 512 guarded placements, 35,072 independent physical relations and 25,661,440 complete output-owner bytes with zero differences. It covered 6,820 lower cells, 10,716 upper methane cells, 4,840 low-mixture checks, 5,720 middle-mixture checks and 3,080 high-mixture checks. It preserved 25,380,864 untouched output bytes, read-only inputs, unchanged coefficient owners and FPCR zero. Its first numerical run with the genuine declared stride passed.

The composable paired relay passed 80 parent calls, 160 independent relations and 224,000 complete output-owner bytes with zero differences. It covered 36 lower and 44 upper cells, with 24 checks for each lower mixture branch. Its all-upper case permits an unused NaN cap, while preserving the complete methane calculation and exact Planck copies. It preserved 222,720 untouched bytes and FPCR zero. Full-forecast acceptance and comparative timing remain separate stages.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 observed 6,400 genuine calls. The same-input comparison covers 2,179,072,000 complete returned owner bytes with zero differences. Independent critical physics, unchanged inputs and the declared interface checks passed. All ten saved forecast files also match across 618,140 bytes. This result covers the declared routine domain and saved files. Independent whole-forecast physics, whole-process byte identity and comparative speed remain unproved.
