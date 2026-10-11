# Longwave Carbon Dioxide Absorption

Revision 1.0 describes thermal radiation from 2,250 to 2,380 cm$`^{-1}`$. A wavenumber counts wave cycles per centimetre. Carbon dioxide absorbs through spectral lines. Water vapour supplies additional broad continuum absorption in lower layers, and aerosols add their supplied depth.

## Physical Inputs

Let $`C`$ be the carbon-dioxide column in the model's approximately $`10^{20}`$ molecules cm$`^{-2}`$ scaling. Pressure and temperature select the supplied line coefficient $`k`$. Let $`C_s,C_f`$ be dimensionless water self and foreign continuum depths, which describe water interactions with water molecules and with other gases. Let $`A`$ be the dimensionless aerosol depth.

## Basic Mathematics

The tropopause, the boundary above most weather, separates the lower and upper data. Only lower layers include water continua in this band.

```math
\tau_L=Ck_L+C_s+C_f+A,\qquad
\tau_U=Ck_U+A. \tag{P01}
```

Two representative spectral points describe this band. Supplied dimensionless Planck weights divide thermal emission across them.

```math
f_g=w_g. \tag{P02}
```

## State And Boundaries

The leaf reads an existing atmospheric state. It does not advance time or calculate radiation transport through the complete atmosphere. The [md2asm contract](../../../skills/md2asm/references/openifs/physics/rrtm_taumol14.md) gives the numerical interpolation and complete assembly interface.
