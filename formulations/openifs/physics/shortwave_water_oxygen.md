# Water And Oxygen Shortwave Radiation

Revision 1.0 describes the Sun's radiation between 7,700 and 8,050 inverse centimetres. This unit counts wave cycles per centimetre. Water vapour and oxygen absorb radiation in the lower atmosphere. The upper atmosphere uses oxygen absorption alone. Molecules also scatter some light.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`W,O,N`$ | Water, oxygen and total molecular columns, approximately $`10^{20}`$ molecules cm$`^{-2}`$ |
| $`a,r`$ | Oxygen intensity adjustment and reference mixture ratio, dimensionless |
| $`K`$ | Tabulated absorption coefficient, inverse molecular-column unit |
| $`C_s,C_f`$ | Water self and foreign continuum coefficients, inverse molecular-column unit |
| $`F_s,F_f`$ | Continuum density factors, dimensionless |
| $`R`$ | Molecular scattering coefficient, inverse molecular-column unit |
| $`\tau_A,\tau_R`$ | Absorption and scattering depths, dimensionless |

## Equations

**P01. Lower Atmosphere Mixture**

```math
Q=W+arO,\qquad s=\frac{W}{Q},\qquad \tau_A=QK(s)+W(F_sC_s+F_fC_f)+\frac{cO}{700}.
```

The combined molecular column sets the line absorption. Its water fraction selects the supplied spectral table. The water continuum describes absorption between individual spectral lines. The last term adds the oxygen continuum.

**P02. Upper Atmosphere**

```math
\tau_A=OaK_{\mathrm{upper}}+\frac{cO}{700}.
```

This branch uses oxygen alone and does not use the water continuum.

**P03. Scattering**

```math
\tau_R=NR.
```

More molecules cause more scattering. Absorption and scattering remain separate outputs.

## Parameters And Boundaries

Use $`a=1.6`$, $`r=0.022708`$, $`R=1.54\times10^{-8}`$ in the inverse molecular-column unit and the source-rounded constant $`c=\operatorname{FP64}(\operatorname{FP32}(4.35\times10^{-4}))`$. FP32 and FP64 mean 32-bit and 64-bit floating-point storage. The existing empirical tables supply spectral absorption and solar flux. Pressure and temperature select their adjacent entries. Each layer is independent, while a supplied tropopause index separates the two regions. Only columns facing the Sun are updated. The [md2asm contract](../../../skills/md2asm/references/openifs/physics/srtm_taumol22.md) supplies the complete interpolation and solar-layer rule.
