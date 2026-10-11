# SURFRAD_CTL Contract

## Source and Scope

This contract covers the full 787-line original `surf/module/surfrad_ctl_mod.F90` routine, including all four albedo schemes, soil moisture emissivity, thermal band conversion, temperature dependent thermal weighting, monthly ice interpolation, the complete urban canyon child, lake ice, snow and both wind dependent cloud condensation nuclei calculations. A condensation nucleus is a small airborne particle on which a cloud droplet can form.

The qualified shape has 1 to 4096 columns, 9 or 10 tiles, 2 or 6 solar bands and 2 to 16 thermal emission bands. Requested thermal storage has either two bands or at least the configured thermal count. The selected column interval can be cropped or empty. Configured and requested solar counts match. The solar weights are positive and sum to one, and both visible and near infrared groups have positive weight. Fractional surface areas are nonnegative and sum to one, with lake area zero when lakes are disabled.

The surface temperature range is 160 to 340 K, wind is 0 to 80 m s$`^{-1}`$, and the solar angle cosine is 0 to 1. Tile albedos, emissivities, soil moisture and coverage fractions are dimensionless. Consumed soil capacity exceeds the wilting point. With soil-type-dependent parameters enabled, type zero directly selects a moisture weight of one, so its moisture and reserved capacity values are unused. The original setup gives both reserved capacity and wilting-point values zero. Snow table indices use the original nearest integer rule, with ties away from zero, within 0 to 20. Active lake ice is at or below 273.16 K. Inactive ice temperature may be zero, because it contributes no ice fraction. The urban child retains its accepted aspect ratio range 0.05 to 1.5 and wall and road albedos 0 to 1. Passive values do not acquire unsupported physical meanings.

## Interface and Storage

The entry has the original 43 address arguments, in source order. AArch64 passes the first eight in `x0` to `x7` and the other 35 in eight-byte caller stack slots. Integer and logical scalars are signed 32-bit values. Physical fields use binary64. GNU Fortran rank-one descriptors are 64 bytes and rank-two descriptors are 88 bytes. Descriptor rank, element type, element length, positive strides, full extents and bounded address spans are checked before a write. Real data and objects are eight-byte aligned, and integer data are four-byte aligned. Every complete output owner is separate from the input owners and other outputs.

The input objects have measured sizes `TCST` 128, `TLW` 304, `TSW` 240, `TRAD` 48, `TRDI` 1256, `TSOIL` 2416, `TFLAKE` 856 and `TURB` 472 bytes. The shortwave object owns the solar weights and two monthly ice tables. The soil object owns soil capacity and wilting-point arrays indexed from zero. The frozen local layout probe records their field offsets and nested descriptors. The assembly preserves these objects and descriptors.

There are eight full output owners, in argument order 34 through 41. They are diffuse spectral albedo, direct spectral albedo, diffuse broadband albedo, spectral emissivity, broadband emissivity, tile broadband albedo, land nuclei and ocean nuclei. Each complete owner is compared as little-endian raw bytes, including unselected columns and stride padding. Extra thermal bands remain untouched. The zero-difference limit preserves signed zeros and every declared output bit.

## Ordered Calculation

All operations use round-to-nearest with ties to even, gradual underflow and FPCR zero. Multiplication and addition remain separate, and every source dependency rounds to binary64 at its original boundary. No expression contraction, reassociation, approximate division, reduced precision or fast math is used. Reductions use increasing source index order.

The angle is `acos(mu)`, followed by its square and cube. The two three-term angular coefficients retain the original left-to-right addition and subtraction. The solar visible and near infrared sums retain their source index order. The temperature coordinate is `(T-Tstand)*(1/Tstand)`. Lake ice and water fractions are the original strict thickness comparison.

For a consumed moisture ratio, moisture emissivity first forms `1/(capacity-wilting)`, multiplies by the moisture excess and clips to zero and one. With soil-type-dependent parameters and soil type zero, it directly uses a moisture weight of one, preserving the complete original branch. Each band combines the first eight tile products from zero in order, then adds the urban product and then the lake product. Conversion to two thermal bands sums the configured old weights in order. Broad band thermal emission uses all six source polynomial coefficients in the original Horner order and the original six-band weighting, or the configured direct thermal weights.

Calendar interpolation uses the original day-15 branch, adjacent month wrap and previous-month day count. Its two weights are retained without changing their rounding. Sea ice scale factors retain the ordered product and division with the full configured solar sums. The complete direct CANALB child runs once on the selected interval and supplies the urban canyon albedo.

Each solar band retains its full tile calculation. The four-component scheme selects direct and diffuse coefficients, the six-component scheme adds angular products in source order, the two-component scheme copies diffuse to direct, and the default scheme copies the background albedo. Bounds remain `min(1-floor,max(value,floor))`. Urban roof and canyon fractions retain their distinct divisions. Ocean direct albedo uses the original `mu**1.4` route. Snow visible interpolation and near infrared recovery retain their original order and clipping. Forest snow uses the original nearest integer table row. Urban snow retains both nested mixtures and its denominator. Lake albedo retains the complete exponential mixture.

Tile broadband sums use `old + sun*(diffuse+direct)*0.5`. Diffuse and direct cell means start with the first tile product and add tile products 2 through 8 in order, then urban and lake. Diagnostic broadband albedo adds the solar-weighted diffuse mean. All source stages are emitted directly, and the caller supplies no missing numerical stage.

Ocean and land nuclei preserve the two wind branches and their original constants. Ocean wind above 30 m s$`^{-1}`$ uses 327, and wind above 15 uses the separate exponential branch. Land retains its small branch discontinuity at 15. Both use original-rounding private LOG10 and POWER boundaries. The radiation LOG10 entry accepts finite values from 2$`^{-40}`$ through 2$`^{20}`$. It has a unique symbol and no global libm override.

## Evidence

Before emission, 22 protected complete original calls produced 1,004,672 output bytes and passed 48,198 independent relations using 120-digit arithmetic. The independent check uses polynomial powers instead of Horner evaluation, convex tile mixtures, radiation partition, complete spectral and broadband outputs, the piecewise wind laws and unchanged accepted canyon energy evidence. Its rounding budget is 4096 binary64 unit roundoffs times the relation scale. The largest residual used 0.001537 of that budget. It also checked 115,512 untouched output words. The canonical raw owners and exact source status are frozen locally.

The final assembly passed 44 protected placements with 2,009,344 output bytes and zero differences, exact fresh floating point status and errno, 96,396 independent relations and 231,024 untouched output words. Six complete 43-address ABI calls preserve all callee-saved registers, stack alignment, FPCR, seeded status and errno. Ten shared-owner rejection checks leave all eight outputs unchanged. Eight paired complete calls compare 29,504 bytes and count eight genuine original and private native canyon calls, including 1,488 exact child input and output bytes. Two profiled complete calls compare 10,208 bytes and retain their status and errno. Two source-first physical rejection checks also leave all public outputs unchanged. The private canyon source body is unchanged apart from its unique symbol. Its small local wrapper only records real calls and supplies no arithmetic. This checkpoint does not claim full forecast scientific acceptance or measured performance.

The original default reserved zero-capacity branch has a focused original-first proof of two protected calls, 6,392 complete bytes and 4,137 independent 120-digit relations. Four protected paired placements match 12,784 bytes with zero differences and 8,274 additional independent relations. A consumed positive-soil-type zero-capacity ratio remains rejected with all 3,808 public bytes unchanged. This update changes only the source-first admission guard. Every numerical and interface object, the fixed absolute runtime link and previous accepted proofs remain unchanged.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 passes these positive actual calls with zero differing bytes. Each byte scope describes the complete owners compared by that routine.

| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| surfrad_ctl_mod::surfrad_ctl | 2,150 | 130,032,000 | Native private radiation child, complete layer owners and unchanged child proof |

All ten saved files also match across 618,140 bytes. The accepted critical physics and interface checks are reused. These checks cover the declared routine domains and saved files. Whole-forecast physical verification, whole-process byte identity and comparative timing remain open in the [coverage record](../../../../../src/openifs/README.md).
