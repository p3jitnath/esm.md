# Longwave Water Line And Continuum Absorption

Revision 1.0 describes thermal radiation from 1,390 to 1,480 cm$`^{-1}`$. A wavenumber counts wave cycles per centimetre. Water vapour absorbs through narrow spectral lines and a broad background called a continuum. Aerosols add their supplied absorption.

## Physical Inputs

Let $`W`$ be the water column in the model's approximately $`10^{20}`$ molecules cm$`^{-2}`$ scaling. Pressure and temperature select the supplied line coefficient $`k`$. Let $`C_s,C_f`$ be dimensionless self and foreign continuum depths. The self continuum describes interactions with water molecules, while the foreign continuum describes interactions with other gases. Let $`A`$ be the dimensionless aerosol depth.

## Basic Mathematics

The tropopause, the boundary above most weather, separates the lower and upper data. Lower layers include both continua. Upper layers include the foreign continuum.

```math
\tau_L=Wk_L+C_s+C_f+A,\qquad
\tau_U=Wk_U+C_f+A. \tag{P01}
```

Six representative spectral points describe this band. The supplied dimensionless Planck weights $`w_g`$ divide thermal emission across these points.

```math
f_g=w_g. \tag{P02}
```

## State And Boundaries

The leaf reads an existing atmospheric state. It does not advance time or calculate radiation transport through the complete atmosphere. The [md2asm contract](../../../skills/md2asm/references/openifs/physics/rrtm_taumol10.md) gives the numerical interpolation and complete assembly interface.
