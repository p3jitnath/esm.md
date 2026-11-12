# Longwave Sensitivity To Surface Emission

Revision 1.0 describes how a small increase in thermal radiation from the surface reaches each atmospheric level. The independent-column approximation treats each vertical column separately and excludes longwave scattering. The surface spectrum keeps its shape as its total energy changes.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`F_g`$ | Upward surface radiation in spectral interval $`g`$, W m⁻² |
| $`T_{g,j}`$ | Fraction transmitted through layer $`j`$, from zero to one, dimensionless |
| $`N`$ | Number of atmospheric layers, dimensionless |
| $`d_j`$ | Change in upward radiation at face $`j`$ per unit change at the surface, dimensionless |
| $`a`$ | Weight assigned to a new sensitivity, from zero to one, dimensionless |

A face is the boundary between two atmospheric layers. Face $`N+1`$ is the surface, and smaller face numbers are higher in the atmosphere.

## Equations

**P01. Surface Energy Attenuation**

```math
 d_{N+1}=1,\qquad
 d_j=\sum_g\frac{F_g}{\sum_hF_h}\prod_{k=j}^{N}T_{g,k}.
```

Each spectral contribution loses energy as it passes upward through the layers. The sum combines those contributions into the response of total upward radiation.

**P02. Weighted Update**

```math
 d_j^{\mathrm{updated}}=(1-a)d_j^{\mathrm{old}}+a d_j,\qquad
 d_{N+1}^{\mathrm{updated}}=1.
```

The weighted update mixes a previous response with a newly calculated response. The surface response stays exactly one.

## Inputs And Boundaries

Surface spectral radiation is nonnegative and has a positive finite total. Layer transmissions lie between zero and one. The surface starts with unit sensitivity, and each atmospheric layer attenuates it. There is no interaction with another column in this local calculation. The [solver contract](../../../skills/md2fort/references/openifs/physics/lw_derivatives_ica.md) supplies the ordered sums, complete layer update and array interface.
