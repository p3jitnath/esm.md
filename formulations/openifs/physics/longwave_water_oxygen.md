# Longwave Water And Oxygen Absorption

Revision 1.0 describes thermal radiation from 1,480 to 1,800 cm$`^{-1}`$. A wavenumber counts wave cycles per centimetre. Water vapour absorbs through narrow lines and broad continua. Oxygen supplies a smaller absorption term, and aerosols add their supplied depth.

## Physical Inputs

Let $`W,O`$ be water and oxygen columns in the model's approximately $`10^{20}`$ molecules cm$`^{-2}`$ scaling. Pressure and temperature select the supplied line coefficient $`k`$ and oxygen coefficient $`m`$. Let $`s_O`$ be the dimensionless oxygen density scale. Let $`C_s,C_f`$ be dimensionless self and foreign continuum depths. These describe water interactions with water molecules and with other gases. Let $`A`$ be the dimensionless aerosol depth.

## Basic Mathematics

The tropopause, the boundary above most weather, separates the lower and upper absorption data. Both branches include oxygen. Higher layers omit the self continuum.

```math
M=Os_Om,\qquad
\tau_L=Wk_L+C_s+C_f+M_L+A,\qquad
\tau_U=Wk_U+C_f+M_U+A. \tag{P01}
```

Eight representative spectral points describe this band. The supplied dimensionless Planck weights $`w_g`$ divide thermal emission across them.

```math
f_g=w_g. \tag{P02}
```

## State And Boundaries

The leaf reads an existing atmospheric state. It does not advance time or calculate radiation transport through the complete atmosphere. The [md2asm contract](../../../skills/md2asm/references/openifs/physics/rrtm_taumol11.md) gives the numerical interpolation and complete assembly interface.
