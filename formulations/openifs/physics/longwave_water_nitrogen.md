# Longwave Water And Nitrogen Absorption

Revision 1.0 describes thermal radiation with wavenumbers from 10 to 350 cm$`^{-1}`$. A wavenumber is the number of wave cycles per centimetre. Water vapour absorbs this radiation through spectral lines and broad continua. Nitrogen contributes a smaller absorption term when molecules collide. Aerosols add their supplied absorption depth.

## Physical Inputs

Let $`W`$ be the water column in the model's approximately $`10^{20}`$ molecules cm$`^{-2}`$ scaling, $`p`$ the layer pressure in hPa and $`A`$ the aerosol optical depth. Pressure and temperature select the supplied absorption coefficients. A tropopause index selects lower or upper atmospheric data. Let $`C_s,C_f`$ be the dimensionless water self and foreign continuum depths, and $`C_N`$ the supplied nitrogen column and density factor multiplied by its absorption coefficient.

## Basic Mathematics

Let $`k`$ be the interpolated water line coefficient. The lower layer includes both water continua, while the upper layer includes the foreign continuum.

```math
\tau_L=c_L(p)(Wk_L+C_s+C_f+C_N)+A,\qquad
\tau_U=c_U(p)(Wk_U+C_f+C_N)+A. \tag{P01}
```

The supplied empirical pressure adjustment uses

```math
c_L(p)=\begin{cases}1-0.15(250-p)/154.4,&p<250,\\1,&p\ge250,\end{cases}
\qquad c_U(p)=1-0.15p/95.6. \tag{P02}
```

All optical depths and pressure adjustments are dimensionless. The numerical pressure constants use hPa. Let $`w_g`$ be the supplied dimensionless Planck weight for representative spectral point $`g`$. This weight describes how a band's thermal emission is divided across its spectral points.

```math
f_g=w_g. \tag{P03}
```

Ten representative spectral points describe this band. This calculation reads a supplied atmospheric state and does not advance time or solve radiation transport through the complete atmosphere.
