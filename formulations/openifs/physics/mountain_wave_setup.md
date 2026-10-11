# Mountain Wave Setup

Revision 1. Air that flows over hills can form waves. These waves carry momentum and can slow the large-scale wind. This formulation describes the local atmospheric and mountain properties needed to start that calculation.

Let $`z`$ be height in metres, $`p`$ pressure in pascals, $`T`$ temperature in kelvin and $`\rho`$ air density in kilograms per cubic metre. Horizontal wind components $`u`$ and $`v`$ have units of metres per second. Mountain height variation $`h`$ is measured in metres. Mountain orientation $`\theta`$ is measured in radians, and its shape ratio $`\gamma`$ is dimensionless.

The ideal-gas equation gives density. The buoyancy frequency $`N`$ measures the restoring force when a parcel of air moves vertically. A positive squared frequency means that the air resists vertical motion.

```math
\rho=\frac{p}{R_dT},\qquad
N^2=\frac{g}{T}\left(\frac{dT}{dz}+\frac{g}{c_p}\right).
```

Here $`g`$ is gravitational acceleration, $`R_d`$ is the gas constant for dry air and $`c_p`$ is its specific heat at constant pressure. Typical Earth values are $`g=9.80665`$ metres per second squared, $`R_d\approx287`$ joules per kilogram per kelvin and $`c_p\approx1005`$ joules per kilogram per kelvin.

Let $`U`$ be wind along the relevant mountain direction. The Richardson number $`Ri`$ compares stable layering with vertical wind shear. The dimensionless mountain height $`M`$ compares the restoring force over a vertical distance with the flow speed.

```math
Ri=\frac{N^2}{(dU/dz)^2},\qquad
M=\int\frac{N}{\lvert U\rvert}\,dz.
```

The input state supplies pressure at layer centres and faces, temperature, horizontal wind and geopotential, which is gravitational potential energy per unit mass in square metres per second squared. It also supplies mountain height variation, orientation and shape ratio. Columns are independent, pressure increases towards the surface and geopotential decreases towards the surface. This setup reads a complete local column and does not advance time or exchange information across horizontal boundaries.
