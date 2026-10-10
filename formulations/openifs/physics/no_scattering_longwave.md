# Longwave Transmission Without Scattering

Revision 1.0 describes thermal radiation passing through one atmospheric layer in OpenIFS. The layer absorbs radiation and emits its own thermal energy. It does not scatter radiation into another direction.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`\tau`$ | Optical depth, which measures absorption along a vertical path, dimensionless |
| $`D,U`$ | Downward and upward radiation flows, W m⁻² |
| $`B`$ | Thermal source term determined by temperature, W m⁻² |
| $`B_t,B_b`$ | Source terms at the top and bottom of the layer, W m⁻² |
| $`L`$ | Diffuse-path factor of 1.66, dimensionless |

## Equations

**P01. Absorption And Emission**

A derivative here means the rate of change as the path moves deeper into the layer.

```math
\frac{dD}{d\tau}=-LD+LB(\tau),\qquad
\frac{dU}{d\tau}=LU-LB(\tau).
```

The source $`B`$ changes linearly between $`B_t`$ and $`B_b`$. Absorption removes incoming energy, while local thermal emission supplies new energy.

**P02. Transmission**

```math
T=e^{-L\tau}.
```

The fraction $`T`$ of incoming diffuse radiation crosses the layer without absorption.

## Parameters And Boundaries

Inputs are a nonnegative layer optical depth and nonnegative source terms at its two faces. To find emission from the layer alone, set incoming downward radiation at the top and incoming upward radiation at the bottom to zero. A transparent layer transmits all incoming energy and emits no energy. The [solver contract](../../../skills/md2asm/references/openifs/physics/calc_no_scattering_transmittance_lw.md) preserves the original small-depth approximation and exact arithmetic.
