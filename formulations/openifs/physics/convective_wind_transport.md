# Convective Wind Transport

Revision 1.0. This input describes the forecast with stochastic perturbations disabled.

Convection moves air up and down through an atmospheric column. Those plumes transport horizontal wind momentum. The environmental and plume wind speeds are in metres per second. Their mass fluxes are in kilograms per square metre per second.

Let $`F`$ be a vertical momentum flux, formed by multiplying plume mass flux by the relevant wind difference. Its change across a layer produces a wind acceleration $`a`$.

```math
a_i=\frac{g}{\Delta p_i}(F_{i+1}-F_i). \tag{P01}
```

Here $`g`$ is gravity in metres per second squared and $`\Delta p_i`$ is the layer pressure thickness in pascals. Acceleration is in metres per second squared. Apply the same calculation to both horizontal wind components.

For an explicit update, add this acceleration to the existing tendency. A partly or fully implicit update instead solves a column system before converting its wind change back to acceleration.

```math
A_i u_{i-1}+B_i u_i=R_i. \tag{P02}
```

The supplied dimensionless transport settings and time step determine $`A_i`$ and $`B_i`$. The forcing $`R_i`$ has the wind unit. Each row connects a layer to the preceding layer.

## Supplied State And Boundaries

Supply cloud flags and top and base levels, layer and edge pressures, environmental and plume winds, current and previous plume mass fluxes, a positive time step and the existing wind tendencies. Gravity is 9.80665 metres per second squared for the forecast. Pressure increases downwards. Process selected convective columns. The bottom momentum flux is zero. In the explicit method, continue the cloud-base flux towards the surface using the supplied pressure fraction, squared for midlevel convection. Other columns and levels retain their tendencies.
