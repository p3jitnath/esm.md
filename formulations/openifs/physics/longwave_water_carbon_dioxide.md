# Longwave Water And Carbon Dioxide Absorption

Revision 1.0 describes thermal radiation from 1,800 to 2,080 cm$`^{-1}`$. A wavenumber counts wave cycles per centimetre. Lower atmospheric layers absorb radiation through water and carbon-dioxide spectral lines, broad water absorption and aerosols.

## Physical Inputs

Let $`W,C`$ be the water and carbon-dioxide columns in the model's approximately $`10^{20}`$ molecules cm$`^{-2}`$ scaling. The supplied ratio $`r`$ places both gases on one scale. Let $`k`$ be the absorption coefficient selected by pressure, temperature and gas mixture. Let $`C_s,C_f`$ be dimensionless water self and foreign continuum depths. They describe water interactions with water molecules and with other gases. Let $`A`$ be the dimensionless aerosol depth.

## Basic Mathematics

The combined absorbing column $`Q`$ determines the line absorption below the tropopause, the boundary above most weather.

```math
Q=W+rC,\qquad \tau_L=Qk+C_s+C_f+A. \tag{P01}
```

This band parameterisation assigns no gas absorption or thermal emission weight above that boundary. Its upper depth therefore contains only the supplied aerosol.

```math
\tau_U=A,\qquad f_U=0. \tag{P02}
```

Eight representative spectral points describe the band. Supplied dimensionless Planck weights divide lower-layer thermal emission across these points.

## State And Boundaries

The leaf reads an existing atmospheric state. It does not advance time or calculate radiation transport through the complete atmosphere. The [md2fort contract](../../../skills/md2fort/references/openifs/physics/rrtm_taumol12.md) gives the numerical interpolation and complete assembly interface.
