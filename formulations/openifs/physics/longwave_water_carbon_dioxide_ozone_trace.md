# Longwave Gas Mixtures And Trace Absorption

Revision 1.0 describes thermal radiation from 700 to 820 cm$`^{-1}`$. A wavenumber counts wave cycles per centimetre. Water and carbon dioxide provide the main lower-layer absorption. Ozone and carbon dioxide provide the main upper-layer absorption.

## Physical Inputs

Let $`W,C,O,X`$ be the supplied water, carbon-dioxide, ozone and carbon-tetrachloride columns. Gas columns use the model's approximately $`10^{20}`$ molecules cm$`^{-2}`$ scaling. Carbon tetrachloride is a trace gas, a gas present in small amounts. Supplied ratios $`r_W,r_O`$ place the main gases on common scales. Pressure, temperature and gas mixture select coefficients $`k_L,k_U,k_O`$. Let $`k_X`$ be the trace-gas coefficient. Let $`C_s,C_f,A`$ be dimensionless self-continuum, foreign-continuum and aerosol depths. The continua describe broad water absorption caused by interactions with water and other molecules.

## Basic Mathematics

Below the tropopause, the boundary above most weather, water and carbon dioxide form a combined absorbing column.

```math
Q_L=W+r_W C,\qquad
\tau_L=Q_Lk_L+C_s+C_f+Ok_O+Xk_X+A. \tag{P01}
```

Above this boundary, ozone and carbon dioxide form the combined column. The same trace gas and supplied aerosol still contribute.

```math
Q_U=O+r_O C,\qquad
\tau_U=Q_Uk_U+Xk_X+A. \tag{P02}
```

Sixteen representative spectral points describe the band. Supplied dimensionless Planck weights divide thermal emission across those points.

## State And Boundaries

The leaf reads an existing atmospheric state. It does not advance time or calculate radiation transport through the complete atmosphere. The [md2asm contract](../../../skills/md2asm/references/openifs/physics/rrtm_taumol5.md) gives the numerical interpolation and complete assembly interface.
