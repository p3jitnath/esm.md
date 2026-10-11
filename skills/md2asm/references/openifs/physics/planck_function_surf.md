# Surface Thermal Emission Contract

The [physics input](../../../../../formulations/openifs/physics/surface_thermal_emission.md) describes a surface's heat radiation. The direct body implements the complete radiation_ifs_rrtm::planck_function_surf calculation from radiation/module/radiation_ifs_rrtm.F90. This helper supports the later gas-optics caller and is outside the remaining weather-routine count.

## Frozen Calculation

Use the unchanged YOERRTWN tables TOTPLNK, with 181 temperatures and sixteen bands, and DELWAVE, with sixteen normalising widths. Rows represent 160 to 340 kelvin. Band 16 integrates from 2600 inverse centimetres to infinity. Its width of 650 inverse centimetres normalises the tabulated value and does not truncate this all-band integral. The [original AER implementation](https://github.com/AER-RC/RRTMG_LW/blob/master/src/rrtmg_lw_setcoef.f90#L211) explains this distinction.

For each selected column, temperature below 160 kelvin selects row one and fraction zero. Temperature from 160 up to 339 kelvin selects integer row INT(T − 159) and fraction T − INT(T). Temperature at or above 339 kelvin selects row 180 and fraction T − 339. These rules preserve the original cap, interpolation and extrapolation.

First form ZFLUXFAC with separately rounded FP64 operations 2 × ASIN(1), then multiplication by 10000. Its ASIN(1) input is the independently qualified bit pattern 3ff921fb54442d18. For each band, multiply ZFLUXFAC by DELWAVE. Subtract the adjacent table values, multiply that difference by the temperature fraction, add the lower table value, then multiply by the band factor. Multiply the stored band flux by the selected PFRAC value. Preserve each rounding point. Require FPCR zero, gradual underflow and signed zeros, with no fused, reassociated or approximate arithmetic.

The ordinary solver uses i_band_from_g_lw and spectral point g. Solver value three, called Spartacus, uses i_band_from_reordered_g_lw and i_g_from_reordered_g_lw instead. The output is the same complete spectral flux owner in either branch. Process columns with a private sixteen-word band store. This changes independent visit order but preserves all arithmetic dependencies and every output bit. Input and output owners must be distinct.

## Six-Address Interface

The application binary interface (ABI) passes addresses for first column, last column, config, temperature descriptor, PFRAC and output in x0 through x5. Column integers use four-byte words. FP64 owners use eight-byte words and alignment. The direct body exports md2asm_planck_function_surf and the original Fortran entry __radiation_ifs_rrtm_MOD_planck_function_surf. A private original alias is available when linking complete callers.

Support zero to 4096 selected columns, first labels from one, one to 140 spectral points and one to sixteen bands. Consumed temperatures are finite and between 1 and 4096 kelvin. Consumed fractions are finite, nonnegative and at most one. Every consumed band and reordered spectral index must be valid. Unused fractions and unused descriptors are not read.

The verified GNU config occupies 20040 bytes. Its spectral count is at byte 20000, band count at 20008 and solver integer at 624. The ordinary-band, reordered-band and reordered-point descriptors start at bytes 10608, 10864 and 10736. They describe contiguous four-byte integer elements from lower label one, with offset minus one and stride one. Their upper bound must cover the spectral count and must not exceed 4096.

Temperature uses a 64-byte rank-one GNU descriptor for eight-byte elements. Its base addresses the first dummy element, and byte 40 gives its element stride. The assumed-shape dummy normalises its lower bound to one, so column j reads base + 8 × (j − 1) × stride. The owner must cover all selected addresses, including a negative stride. Its dummy extent must cover the last label and must not exceed 16384 elements, while stride magnitude must not exceed 4096. Empty work returns before consuming these owners.

Let n be the selected column count and G the spectral count. PFRAC stores columns first and 140 spectral points second, occupying 1120n bytes. Output stores G points first and columns second, occupying 8Gn bytes. Each value uses native-endian FP64 encoding. Preserve all bytes outside output capacity. Use a fixed aligned frame with a 128-byte private band store. Preserve x19 through x29, the return address, x18, low halves of v8 through v15 and FPCR.

## Focused Evidence

The shared table check matches all 2896 source literal bit patterns and sixteen widths. Independent Planck integrals at every table temperature have maximum relative error 0.000153935, within the frozen 0.0005 limit. The first fifteen bands use 32- and 64-point quadrature, while the final tail uses independent 16- and 32-term series evaluation. Their maximum relative disagreement is 1.12 × 10^-15. The ASIN(1) singleton differs from a 150-digit Machin-series reference by 0.276 units in the last place.

Before assembly emission, 72 protected original placements pass 55176192 complete returned bytes, 6897024 independent emission relations and 788280 spectral-partition relations. Cases include empty work, shifted columns, odd sizes, both solver branches, both ends of protected pages, temperature strides one, two and minus two, and both cap and extrapolation branches. Input owners are read-only, and unused owners contain invalid values to detect unintended consumption.

The independent emission error bound is sixteen FP64 epsilons times the absolute conditioned flux, with sixteen minimum subnormals for underflow. The partition bound adds the number of spectral points to this operation allowance. Require the same focused physical and bounds checks, zero different complete output bytes, immediate ABI observation and a paired original/native adapter before caller acceptance. Local evidence is under .runtime/openifs/planck_surface_7240564/. The native body passes the same 72 protected calls and 55176192 complete output bytes with zero differences. Two focused placements each pass the immediate six-address ABI observer and the paired adapter over 816 output bytes, with 102 emission and eighteen partition relations. Machine instructions contain no fused or approximate arithmetic. Actual caller acceptance remains pending.
