# Aerosol Forward Scattering

Revision 1. The original routine is `radiation_aerosol_optics::delta_eddington_extensive`.

## The idea

An aerosol is a small particle suspended in air. Some light scattered by aerosols continues almost straight ahead. Delta scaling treats that narrow forward part as transmitted light and adjusts the remaining scattering.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`\tau`$ | Total optical depth, a dimensionless measure of light removed from a beam |
| $`s`$ | Scattering optical depth, dimensionless |
| $`q`$ | Scattering depth multiplied by its mean directional factor, dimensionless |
| $`g`$ | Mean directional factor, dimensionless |
| $`f`$ | Forward scattering fraction, dimensionless |
| A prime | A quantity after the adjustment |

## Equations

**P01. Forward fraction**

For positive scattering depth, use the ratio below. Set $`g=0`$ when there is no scattering.

```math
g=\frac{q}{s},\qquad f=g^2.
```

**P02. Adjusted optical properties**

```math
\tau'=\tau-sf,\qquad s'=s(1-f),\qquad q'=\frac{s'g}{1+g}.
```

The same forward contribution is removed from total depth and scattering depth. The absorption depth $`\tau-s`$ stays unchanged. The directional transport depth $`\tau-q`$ also stays unchanged.

## Inputs and boundaries

Supply finite values with $`0\leq q\leq s\leq\tau`$. Each call adjusts one wavelength band at one location. The calculation has no time update or spatial boundary condition.

The [md2fort contract](../../../skills/md2fort/references/openifs/physics/delta_eddington_extensive.md) records storage, rounding and verification.
