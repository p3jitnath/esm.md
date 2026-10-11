# Longwave Water Absorption

Revision 1.0 describes thermal radiation with wavenumbers from 350 to 500 cm$`^{-1}`$. A wavenumber is the number of wave cycles per centimetre. Water vapour absorbs through spectral lines and broad continua, and aerosols add their supplied absorption depth.

## Physical Inputs

Let $`W`$ be the water column in the model's approximately $`10^{20}`$ molecules cm$`^{-2}`$ scaling, $`p`$ the layer pressure in hPa and $`A`$ the aerosol optical depth. Pressure and temperature select the supplied line coefficients. The tropopause separates lower and upper data. Let $`C_s,C_f`$ be the dimensionless water self and foreign continuum depths.

## Basic Mathematics

Let $`k_L,k_U`$ be the lower and upper line coefficients. The lower layer includes both continua and a supplied pressure adjustment. The upper layer uses the foreign continuum.

```math
c(p)=1-0.05\frac{p-100}{900},\qquad
\tau_L=c(p)(Wk_L+C_s+C_f)+A,\qquad
\tau_U=Wk_U+C_f+A. \tag{P01}
```

Optical depths and pressure adjustments are dimensionless. All numerical pressure constants use hPa. Let $`w_g`$ be the supplied dimensionless Planck weight that divides a band's thermal emission across representative spectral points.

```math
f_g=w_g. \tag{P02}
```

Twelve representative points describe this band. This leaf reads a supplied state and does not advance time or solve radiation transport through the complete atmosphere.
