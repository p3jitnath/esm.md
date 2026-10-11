# RRTM_TAUMOL15 Contract

Revision 1.0 preserves the complete OpenIFS Band15 calculation from [P01-P02](../../../../../formulations/openifs/physics/longwave_nitrous_oxide_carbon_dioxide_nitrogen.md). It writes dimensionless absorption depths and Planck weights at points 137 through 138 in each complete 140-point longwave output owner.

## Complete Numerical Update

Visit increasing active layer and column indices. Lower layers use nitrous oxide, carbon dioxide and the supplied lower tables. Upper layers copy the supplied Band15 aerosol word into each of the two depth outputs and write positive FP64 zero into each Planck output. This branch does not consume gas columns, ratios, pressure or temperature indices, interpolation weights, continua or the mixture cap. Preserve every incoming bit at other spectral points and allocated level tails.

At entry, divide the supplied reference columns to obtain $`R=\chi(4,1)/\chi(2,1)`$. This FP64 division belongs inside the direct leaf. The complete genuine reference atmosphere comes from the accepted SURRTRF setup.

Each lower pressure corner independently forms $`Q=\operatorname{RN}(N+\operatorname{RN}(rC))`$, then $`s=\min(\text{ONEMINUS},\operatorname{RN}(N/Q))`$. Here RN means one FP64 rounding. Form $`x=8s`$, truncate nonnegative $`x`$ to the zero-based mixture index $`j`$ and retain $`f=x-j`$. This matches the source MOD calculation, including signed zero. Prepare the independent Planck mixture through the same operations with reference ratio $`R`$.

With one-based source indices, the zero-based corner rows are $`I_0=9[5(J_P-1)+J_T-1]`$ and $`I_1=9[5J_P+J_{T1}-1]`$. The first corner uses temperature weights 00 and 10. The second uses 01 and 11. Each corner retains its own combined column, mixture index and fraction.

For $`0.125\le s\le0.875`$, form four rounded temperature-mixture weights from $`1-f`$ and $`f`$. Multiply these by the table words at rows $`I+j,I+j+1,I+j+9,I+j+10`$, then add the four products from left to right.

For $`s<0.125`$, set $`p=f-1`$. For $`s>0.875`$, set $`p=-f`$. Square $`p`$, then square that rounded square. Form $`h_0=p^4`$, $`h_1=(1-p)-2p^4`$ and $`h_2=p+p^4`$, rounding each operation. Multiply each coefficient by its temperature weight before multiplying by its table word. The low branch visits $`I+j,I+j+1,I+j+2,I+j+9,I+j+10,I+j+11`$ with coefficients $`h_0,h_1,h_2,h_0,h_1,h_2`$. The high branch visits $`I+j-1,I+j,I+j+1,I+j+8,I+j+9,I+j+10`$ with coefficients $`h_2,h_1,h_0,h_2,h_1,h_0`$. Add all six products in that order.

Multiply each complete corner sum by its own rounded $`Q`$. Add the first and second corner depths, then self continuum, foreign continuum, minor nitrogen and Band15 aerosol in that order. Each continuum subtracts adjacent temperature nodes, multiplies the rounded difference by its supplied fraction, adds the first node, then multiplies by its supplied density factor. Each Planck output subtracts adjacent selected mixture nodes, multiplies by the independent Planck fraction, then adds the first node. Do not normalise the supplied fractions.

The complete minor-nitrogen calculation uses the same reference ratio and rounded mixture as the Planck calculation. At each of two adjacent minor-temperature nodes, subtract adjacent mixture words, multiply the rounded difference by the reference mixture fraction and add the first word. Subtract the two rounded temperature results, multiply by the supplied minor-temperature fraction, then add the first result. Independently multiply the broadening-gas column by the supplied minor-density scale. Multiply that rounded factor by the complete interpolated nitrogen coefficient, then add it after the foreign continuum.

The minor table has nine mixture words at each of nineteen temperature nodes. Its zero-based first row is $`j+9(I_M-1)`$, where $`I_M`$ is the one-based minor-temperature index. The next temperature starts nine rows later. The identical Planck and nitrogen reference mixture may share one prepared index and fraction, preserving every required rounding point.

Atmospheric interpolation, aerosol preparation and genuine table setup are frozen input stages outside this leaf. No driver supplies an omitted numerical stage. The lower mixture route reuses the accepted [Band4 arithmetic](rrtm_taumol4.md).

## ABI, Bounds And Storage

The application binary interface (ABI) is GNU Fortran on little-endian AArch64. Thirty-one by-address arguments occupy x0-x7 and twenty-three eight-byte caller stack slots. Their source order is TDIMV, first column, last column, active level count, depth output, aerosol, four interpolation weights 00, 01, 10 and 11, foreign factor and fraction, foreign INTEGER4 index, pressure INTEGER4 index, two temperature INTEGER4 indices, scalar ONEMINUS, unused water input, carbon dioxide, nitrous oxide, tropopause INTEGER4 vector, self factor and fraction, self INTEGER4 index, Planck output, two nitrous-oxide-carbon-dioxide ratios, minor-temperature fraction, minor INTEGER4 index, minor-density scale and broadening-gas column. The water argument is present for the original interface and is not consumed.

TDIMV occupies 32 bytes and begins with the allocated vertical extent. Let $`n`$ be the active column count and $`V`$ the allocated level count. Inputs store columns fastest, then allocated levels. Aerosol storage holds columns by allocated levels by sixteen bands and this leaf reads the fifteenth band. Complete outputs store columns by 140 spectral points by allocated levels, with zero-based offset $`c+n(g+140l)`$. INTEGER4 arrays need four-byte alignment and FP64 arrays need eight-byte alignment. Complete owner capacities are present and input owners are disjoint from output owners.

Support empty work, shifted positive column labels, up to 4,096 columns and 512 active and allocated levels, with allocated extent at least the active count. Tropopause indices range from zero through the active level count. Consumed lower pressure indices range from 1 through 12, both temperature indices from 1 through 4, foreign indices from 1 through 3 and self indices from 1 through 9. Lower minor-temperature indices range from 1 through 18. The lower mixture stride is nine.

Consumed lower gas columns and ratios and all active aerosol depths are finite and nonnegative. The lower scalar cap is finite and strictly between zero and one. Rounded combined corner and Planck columns are strictly positive. Consumed weights, continuum factors and fractions are finite with magnitude at most $`2^{20}`$, and the original extrapolation remains supported. The lower minor-temperature fraction obeys the same finite magnitude bound. Consumed broadening-gas columns and minor-density scales are finite and nonnegative, with finite rounded products. Declared intermediate values and outputs remain finite. Unused upper arguments need no numerical values.

The unchanged reduced line table has 585 rows per spectral point. Self and foreign continua have ten and four nodes. Planck storage has two spectral words at each of nine mixture nodes. The genuine reference atmosphere has seven species at 59 levels. The minor table has 171 rows per spectral point. Original setup groups sixteen points in sizes eight and eight. Line and continuum coefficients use normalised quadrature weights. Planck fractions use unweighted sums.

Preserve x19-x29, the link register and sixteen-byte stack alignment, leaving x18 and d8-d15 untouched. The complete direct leaf uses a fixed 528-byte frame for saved pointers, registers, its reference ratio and reusable corner weights, minor-temperature fraction and rounded nitrogen scale. It makes no external numerical calls.

## Arithmetic And Acceptance

Use FP64 round-to-nearest with ties to even, gradual underflow, signed zeros and FPCR zero. Every declared operation rounds separately. Forbid fused arithmetic, reassociation, approximate instructions and reduced precision.

The small verifier checks complete lower mixture absorption, continua, minor nitrogen and reference Planck mixtures and exact upper aerosol copies with positive-zero Planck words. It compares complete original and native output owners. Cases cover all nine corner-branch combinations, both sides of mixture thresholds and exact ties, mixture bins, pressure and temperature limits, the strict cap, poisoned unused upper inputs, extrapolated weights, zero species, signed zeros, tiny and subnormal columns, empty work, shifted columns, odd counts and vertical tails. Read-only inputs and guard pages check preservation and bounds.

The frozen independent physical bound is $`1024\epsilon C+1024u`$, where $`\epsilon=2^{-52}`$, $`u=2^{-1074}`$ and $`C`$ is the sum of absolute mathematical contributions. Independent weighted reductions use $`128\epsilon C+128u`$ and Planck sums use $`32\epsilon\lvert S\rvert+32u`$. These scientific bounds are separate from the zero-byte native agreement limit.

## Reusable Implementation Choice

Prepare both complete pressure-corner mixtures once per lower atmospheric cell and reuse them across two spectral points. Prepare the identical Planck and minor-nitrogen reference mixture once, then share its rounded index and fraction. The aerosol-only upper branch directly copies one supplied word and writes positive zero without touching unused numerical inputs. These choices preserve the complete arithmetic while reducing repeated preparation. Comparative speed requires quiet-node forecast measurements.

## Accepted Evidence

The genuine original setup passed 1,558 independent reductions at 100 decimal digits and exact agreement for 3,104 source literal words, including the complete nitrogen table. It reused the accepted complete 413-word reference-atmosphere proof. The fifteenth RADRRTM record supplies 74,880 bytes of original line coefficients. Supplied Planck node sums remain unchanged.

The native verifier passed 512 guarded placements, 35,072 independent physical relations and 25,661,440 complete output-owner bytes with zero differences. It covered 6,820 lower and 10,716 upper cells, 4,840 low-mixture checks, 5,720 middle-mixture checks, 3,080 high-mixture checks and 6,820 minor-nitrogen contributions. It preserved 25,380,864 untouched output bytes, read-only inputs, unchanged coefficient owners and FPCR zero. The first numerical run passed.

The composable paired relay passed 80 parent calls, 160 independent relations and 224,000 complete output-owner bytes with zero differences. It covered 36 lower and 44 upper cells, with 24 checks for each lower mixture branch and 36 minor-nitrogen contributions. The all-upper case permits its unused NaN cap and poisoned gas inputs. It preserved 222,720 untouched bytes and FPCR zero. Full-forecast acceptance and comparative timing remain separate stages.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 observed 6,400 genuine calls. The same-input comparison covers 2,179,072,000 complete returned owner bytes with zero differences. Independent critical physics, unchanged inputs and the declared interface checks passed. All ten saved forecast files also match across 618,140 bytes. This result covers the declared routine domain and saved files. Independent whole-forecast physics, whole-process byte identity and comparative speed remain unproved.
