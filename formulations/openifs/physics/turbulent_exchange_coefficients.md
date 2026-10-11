# Turbulent Exchange Coefficients

Revision 1 describes the complete OpenIFS VDFEXCU physical calculation.

Turbulence mixes heat and horizontal momentum between adjacent atmospheric layers. A positive diffusion coefficient moves a quantity from a higher value towards a lower value. Heat diffusion reduces temperature differences, while momentum diffusion reduces wind differences.

The mixing length uses height $`z`$ and a limiting length $`l`$, both in metres. The dimensionless von Kármán constant $`\kappa`$ is 0.4.

```math
l_m = \frac{\kappa z l}{\kappa z+l}
```

The Richardson number $`R_i`$ measures the effect of density layering relative to wind shear. Each diffusion coefficient is the wind-shear magnitude times the squared mixing length and its stability factor.

```math
K_m = \left\lvert\frac{\partial \mathbf{u}}{\partial z}\right\rvert l_m^2 F_m(R_i),
\qquad
K_h = \left\lvert\frac{\partial \mathbf{u}}{\partial z}\right\rvert l_m^2 F_h(R_i)
```

$`K_m`$ and $`K_h`$ have units of square metres per second. Stable layering reduces mixing. Surface buoyancy flux and cloud-top radiative cooling add mixing within the boundary layer. Cloud-top entrainment depends on the temperature jump across its top. The supplied configuration can reduce diffusion in the stratosphere, the region above the lower atmosphere.

The input supplies layer temperature, specific humidity, wind, geopotential, pressure, surface fluxes, cloud levels, latitude and surface roughness. It also supplies the boundary-layer category, surface friction-speed floor and any configured positive stochastic factors. The bottom layer and unselected columns retain their incoming output bytes. The complete ordered update is recorded in the [solver contract](../../../skills/md2asm/references/openifs/physics/vdfexcu.md).
