# SRTM_TAUMOL22 Contract

Revision 1.0 preserves the complete OpenIFS Band22 leaf from [P01-P03](../../../../../formulations/openifs/physics/shortwave_water_oxygen.md). Two representative spectral points are active and all sixteen original points remain in storage. Molecular columns use the original approximately $`10^{20}`$ molecules cm$`^{-2}`$ scaling. Optical depth is dimensionless and the solar output is W m$`^{-2}`$.

## Complete Numerical Update

Use two layer-major passes in increasing layer and column order. A solar zenith cosine strictly greater than zero selects daylight. The first pass updates daylight layers at or below the supplied tropopause. The second pass updates daylight layers above it. Night cells, unused spectral points and vertical tails retain every incoming bit.

For a lower layer, first multiply the FP64 intensity adjustment 1.6 by the frozen mixture ratio. Multiply that rounded result by oxygen and add water. Divide water by the combined column, then replace a fraction greater than or equal to its supplied cap with that cap. Multiply the capped fraction by eight. Truncation towards zero gives the interval index, while the original MOD operation gives its fraction. On the nonnegative domain below eight, subtracting the converted integer reproduces MOD, including signed zero.

The lower table has nine mixture entries, five temperature entries and thirteen pressure entries, so its flattened row count is 585 per stored spectral point. With one-based source indices $`J_P,J_T,J_{T1}`$ and mixture interval $`j`$, the first rows are $`I_0=[5(J_P-1)+(J_T-1)]9+j`$ and $`I_1=[5J_P+(J_{T1}-1)]9+j`$. Form each four-product sum in coefficient-first order with weights 00, 10, 01 and 11, retaining a rounded addition after each product. Blend the adjacent mixture sums with separately rounded one minus the mixture fraction and the fraction itself, then multiply by the combined column.

For each lower continuum, subtract the first coefficient from its adjacent temperature coefficient, multiply by the supplied temperature fraction and add the first coefficient. Multiply these results by their density factors, add self then foreign contributions, multiply by water and add to line absorption. Finally add the oxygen continuum, formed as a separately rounded multiplication of oxygen by the FP32-promoted 4.35E-4 constant followed by division by 700.

The upper table has five temperature entries and forty-seven pressure entries, giving 235 rows per stored point. Its rows are $`I_0=5(J_P-13)+(J_T-1)+1`$ and $`I_1=5(J_P-12)+(J_{T1}-1)+1`$. Form the weight-first four-product sum in 00, 10, 01 and 11 order. Multiply oxygen by 1.6, multiply by this rounded sum and add the same oxygen continuum. This branch must not read water or continuum inputs.

Multiply the total molecular column by the frozen Rayleigh coefficient in both branches and write it separately. The solar-layer selector starts at each column's tropopause. A lower-layer pressure index below the frozen reference followed by a next-layer index at or above it replaces the selector with the smaller of the next layer and the tropopause. Updates follow the original chronological loop order. At the currently selected lower layer, interpolate the solar flux between adjacent mixture entries with subtraction, multiplication and addition. Upper layers do not write solar flux.

## ABI, Bounds And Storage

The application binary interface (ABI) is GNU Fortran on little-endian AArch64. Twenty-six source-order reference pointers occupy x0-x7 and eighteen eight-byte stack slots. The order is TDIMV, first column, last column, active level count, four FP64 interpolation fields 00, 01, 10 and 11, INTEGER4 pressure and two temperature-index fields, FP64 mixture cap, water column, total molecular column, oxygen column, INTEGER4 tropopause, FP64 self factor and fraction, INTEGER4 self index, FP64 foreign factor and fraction, INTEGER4 foreign index, then solar flux, absorption depth, scattering depth and solar zenith cosine.

TDIMV occupies 32 bytes and its first INTEGER4 field is the allocated vertical extent. Input fields use active column as the fastest index, followed by allocated level. Three complete output owners hold columns by sixteen spectral points for solar flux and columns by allocated levels by sixteen points for both optical depths. All arrays have their true complete capacities and required four-byte or eight-byte alignment. Outputs and read-only inputs are disjoint.

Support zero active work, shifted positive column labels, up to 4,096 active columns, up to 512 active and allocated levels, and allocated extent at least the active count. For every daylight lower layer, its genuine next pressure row must fit the allocated extent. Lower pressure indices lie from 1 through 12, upper indices from 13 through 58, and temperature indices from 1 through 4. Lower self indices lie from 1 through 9 and foreign indices from 1 through 2. Upper water and continuum fields are unused and need no numerical values. Daylight lower combined columns are positive and finite. Mixture caps are positive and strictly below one. Supplied band strides are nine and one.

Read the unchanged model tables through their existing module symbols. ABSA and ABSB occupy 74,880 and 30,080 bytes, self and foreign reduced tables occupy 1,280 and 384 bytes, and solar storage occupies 1,152 bytes. The model's table setup is outside this leaf and is a frozen input stage. Its absent, zero and one continuum modes have separate original snapshots. Independent 100-decimal checks validate the two eight-point weighted reductions and the unweighted solar sums using the original supplied empirical data. This establishes numerical table preparation and makes no new claim about empirical-table accuracy.

Preserve x19-x29, the link register, caller stack arguments and 16-byte stack alignment. Leave x18 and d8-d15 untouched. The only private variable storage is one INTEGER4 solar selector per column. No high-level helper supplies a numerical stage.

## Arithmetic And Acceptance

Use FP64 round-to-nearest with ties to even, gradual underflow, signed zeros and FPCR zero. Every multiply, add, subtract and divide rounds separately. Forbid fused operations, reassociation, approximate instructions and reduced precision. Literal 1.6 is FP64, while 4.35E-4 retains its source FP32 rounding before exact widening to FP64. The denominator 700 is exact.

One small verifier checks independent absorption, continuum, scattering and solar relations against the original's complete output owners, then compares the direct native output byte for byte. Critical cases cover all mixture intervals, cap ties, table vertices, continuum endpoints, lower solar chronology, night columns, untouched storage, empty work and the next-row bound. Signed interpolation factors are allowed as the original extrapolation contract requires. Nonnegative absorption is asserted for bounded interpolation cases, while any actual extrapolated negative result must be recorded and investigated.


The independent higher-precision physical relations use the frozen bound $`1024\epsilon C+1024u`$, where $`\epsilon=2^{-52}`$, $`u=2^{-1074}`$ and $`C`$ is the sum of the absolute mathematical contribution sizes. The absorption size includes each separately weighted line and continuum contribution, the scattering size is the absolute molecular-column product, and the solar size is the sum of the absolute adjacent-node contributions. Original table reductions use $`128\epsilon C+128u`$ for weighted coefficient sums and $`32\epsilon\lvert S\rvert+32u`$ for unweighted solar sums, where $`S`$ is the exact higher-precision solar sum. These bounds were fixed before execution and remain separate from the zero-byte implementation limit.

## Accepted Evidence

Three original continuum setup routes passed 5,052 independent table relations at 100 decimal digits, with exact agreement for 1,056 source literal words. The native verifier passed 768 guarded placements, 54,372 independent physical relations and 4,853,760 complete output-owner bytes with zero differing bytes. Cases included 9,468 lower cells, 15,024 upper cells, 5,388 solar cells and 4,418,784 preserved storage bytes. Input owners remained read-only and FPCR remained zero.

The composable paired relay then passed 48 parent calls, 120 independent physical relations and 13,824 complete owner bytes with zero differences. This included 24 lower cells, 24 upper cells, 24 solar cells and 12,864 preserved storage bytes. The relay is ready for a full forecast batch. These checks establish the declared leaf contract and do not yet claim a completed full-forecast replacement or comparative timing.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 observed 6,400 genuine calls. The same-input comparison covers 255,590,400 complete returned owner bytes with zero differences. Independent critical physics, unchanged inputs and the declared interface checks passed. All ten saved forecast files also match across 618,140 bytes. This result covers the declared routine domain and saved files. Independent whole-forecast physics, whole-process byte identity and comparative speed remain unproved.
