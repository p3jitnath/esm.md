# Runtime Orographic Gravity-Wave Parameters

Orographic gravity waves arise when air moves over mountains. This parameter calculation retains the selected original SUGWD equations and reads the atmospheric level count at runtime. It prepares model settings and does not calculate a wind tendency. The physical model remains the [mountain-wave formulation](../../../../../formulations/openifs/physics/mountain_wave_setup.md).

## Interface and Storage

The entry `md2asm_runtime_orographic_gravity_wave_parameter_fields` receives seven machine values. Registers `x0` through `x4` hold the addresses of the 96-byte TEGWD output record, L standard pressures, L+1 half-level A coefficients, L+1 half-level B coefficients and the hour-length scalar. Register `w5` contains the LEPHYS flag, either zero or one, and `w6` contains the live level count L, from 2 through 512. The coefficients define pressure at layer boundaries. Standard pressure and A coefficients are in pascals, B is dimensionless, and the hour length is 3,600 seconds.

The raw caller provides complete mapped spans with no address wrap, eight-byte alignment, and an output owner disjoint from every consumed input. Input pressures and the hour length are positive and finite. The hybrid coefficients must produce the accepted finite pressure profile. This raw entry relies on those caller bounds. It makes no allocation or external call. Its stack workspace has 8L bytes rounded up to a multiple of 16, at most 4,096 bytes. It preserves the required saved registers, the platform register x18 and the floating-point control register FPCR. FPCR must be zero. Floating-point status FPSR and the C error value errno keep their natural results.

## Source Calculations

For each level j, the source estimates pressure at the centre of a layer from its two boundaries. This temporary profile uses a fixed reference surface pressure of 80,000 Pa.

```math
p_j=\frac{A_j+A_{j+1}+80000(B_j+B_{j+1})}{2}
```

The calculation keeps each original rounded addition, multiplication and division. It searches the resulting pressures for the source lower-layer and upper-layer limits, including the original strict and inclusive comparisons. The wind-tendency limiter uses a pressure of 1,000 Pa when L is at most 19, and 5,000 Pa when L is larger. It scans the standard pressures in descending level order. LEPHYS equal to zero resets that limiter index to zero. These are original source branches and model constants.

The remaining constants and the two successive wind-limit assignments retain their source order. All eleven arithmetic and comparison instructions match the accepted body. Only integer loop bounds, the source threshold selection and aligned workspace sizing become runtime values. The default [cloud and wave parameter object](cloud_gravity_wave_setup.md) and the existing [runtime WMS parameter object](runtime_nonorographic_gravity_wave_parameters.md) retain complete byte identity through the shared include.

## Checks and Scope

Four retained original cases cover 19 and 137 levels with exact complete 96-byte outputs. Sixty-four new runtime calls and three unchanged 137-level baseline calls check complete data and raw floating-point status. Protected calls cover both buffer ends, levels 2, 3, 7, 19, 137, 256 and 512, both LEPHYS choices and a pressure-threshold case. No original numerical body or main Fortran executable is rebuilt or replayed.

Independent high-precision pressure intervals carry input and arithmetic rounding bounds into the threshold checks. These checks cover 23,136 pressure, index, constant and preservation relations. The interval budget is eight FP64 epsilons times the sum of input term magnitudes, plus eight smallest subnormal values. It applies only to the independent physical check. Every complete output comparison requires zero differing bytes.

A fresh actual 137-level Geometry and standard atmosphere provide STPRE, VAH and VBH through accepted assembly constructors. The calculation writes the real MODEL TEGWD record at byte offset 1,588,032. Its complete 96 bytes equal the retained source output, while every other MODEL byte, Geometry byte, configuration byte and pressure/coefficient input remains unchanged. The checks compare 4,367,080 complete bytes, with zero differences. All 67 observed native ABI masks are zero. The application binary interface, or ABI, defines arguments and saved registers.

The original formatted source leaves errno equal to zero after logging. The accepted raw numerical service preserves the incoming value 777. FPCR and FPSR are compared literally, and this logging boundary remains explicit. The new parameter library contains only assembly and has no original OpenIFS numerical dependency.

This raw parameter component does not complete the enclosing physical setup, wave parent, CALLPAR or forecast. A production caller must supply actual source-owned inputs, apply the declared source configuration and preserve the order of the mountain-wave and non-orographic-wave setup calls. The supported range of a complete forecast remains the intersection of all linked providers.
