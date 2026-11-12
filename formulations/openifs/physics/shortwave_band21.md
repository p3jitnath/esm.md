# Shortwave Absorption in Band 21

Revision 1.0 describes the basic Band 21 absorption and scattering physics in OpenIFS 48.1.1.

## The idea

Water vapour and carbon dioxide absorb some of the Sun’s radiation as it passes through the atmosphere. Air molecules also scatter radiation. Band 21 covers wavenumbers from 6150 to 7700 cm⁻¹, where a wavenumber counts wave cycles per centimetre. The calculation finds the strength of absorption and scattering in each atmospheric layer.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`N_w,N_c,N_a`$ | Water, carbon dioxide and total molecular columns, approximately $`10^{20}`$ molecules/cm² per source unit |
| $`r`$ | Dimensionless weight for the carbon dioxide column |
| $`Q`$ | Combined absorbing column, in the same source column unit |
| $`k_g`$ | Absorption coefficient at representative spectral point $`g`$, in inverse source column units |
| $`C_{s,g},C_{f,g}`$ | Water self and foreign continuum coefficients, including their density factors, in inverse source column units |
| $`R`$ | Molecular-scattering coefficient, in inverse source column units |
| $`\tau_{G,g},\tau_R`$ | Dimensionless absorption and scattering optical depths |

A molecular column counts molecules above a unit area. Optical depth measures how strongly a layer removes radiation. The self continuum describes interactions between water molecules. The foreign continuum describes interactions between water and other molecules.

## Equations

**P01. Combined absorber**

```math
Q=N_w+rN_c.
```

The weighted carbon dioxide column adds to the water column. The absorption table also depends on pressure, temperature and the share of water in this combined column.

**P02. Absorption and scattering**

```math
\tau_{G,g}=Qk_g+N_w(C_{s,g}+C_{f,g}),
\qquad \tau_R=N_aR.
```

The first term gives absorption by the main gases. The second adds the water continuum. The upper-atmosphere branch uses $`C_{s,g}=0`$. Molecular scattering depends on the total molecular column.

## Parameters, initial state, and boundaries

Use the original pressure and temperature fields, gas columns, tropopause index, coefficient tables and their recorded binary values. The tropopause index separates the lower and upper calculation. The original column scale is the rounded source value of `1.E-20`, rather than an exact decimal conversion.

Use the original solar reference flux in W/m². The supplied atmospheric state defines each layer. There is no separate time update in this calculation.

The [md2fort contract](../../../skills/md2fort/references/openifs/physics/srtm_taumol21.md) records the numerical method and implementation.
