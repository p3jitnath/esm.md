# Radiation Energy in Wavelength Bands

Revision 1. The original routine is `radiation_flux::indexed_sum`.

## The idea

A radiation model calculates energy flow at many wavelength points. A band groups nearby wavelength points. Add each point's energy flow to its assigned band so that the total energy is retained, apart from the rounding of the stored numbers.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`F_j`$ | Energy flow assigned to wavelength point $`j`$, W m⁻² |
| $`b_j`$ | Integer band number for point $`j`$, no unit |
| $`B_b`$ | Total energy flow in band $`b`$, W m⁻² |

## Equation

**P01. Band energy flow**

```math
B_b=\sum_{j\,\text{with}\,b_j=b}F_j
```

Each point belongs to one valid band. An empty band has zero energy flow. This diagnostic uses given radiation values and has no time update or spatial boundary condition.

The [md2asm contract](../../../skills/md2asm/references/openifs/physics/indexed_sum.md) specifies the addition order and assembly interface.
