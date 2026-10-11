# Surface Roughness

Revision 1.0 describes the complete eight- or nine-tile nonurban surface model. A tile is one surface type inside a grid cell, such as sea, vegetation or snow. Roughness length is a positive distance that represents how the surface slows the wind.

## Basic Mathematics

Let $`U`$ be wind speed at height $`z`$, let $`u_*`$ be the friction velocity that measures surface drag, and let $`z_0`$ be roughness length. All speeds use metres per second and both lengths use metres. For neutral air, which has no temperature-driven rise or fall, equation R01 gives the wind profile.

```math
U=\frac{u_*}{\kappa}\ln\left(1+\frac{z}{z_0}\right),\qquad
z_0=\frac{\nu}{u_*}+\frac{\alpha u_*^2}{g}.
```

Here $`\kappa`$ and the wave coefficient $`\alpha`$ have no unit. Gravity $`g`$ has units of metres per square second. The effective viscosity $`\nu`$ has units of square metres per second.

For each tile, the two surface stresses $`\tau_x,\tau_y`$ have units of pascals. Air density $`\rho`$ has units of kilograms per cubic metre. Equation R02 relates stress to friction velocity.

```math
u_*^2=\frac{\sqrt{\tau_x^2+\tau_y^2}}{\rho}.
```

Rising warm air adds a velocity correction when the buoyancy flux $`B`$ is positive. This flux has units of square metres per cubic second. The supplied boundary-layer height $`h`$ uses metres. Equation R03 adds the free-convection correction.

```math
u_*^2\leftarrow u_*^2+0.002(Bh)^{2/3}.
```

## Inputs And Boundaries

Use the current wind, pressure, temperature, humidity, surface heat and moisture fluxes, snow depth, ice state and surface fractions. Supply positive gas and heat-capacity constants, roughness parameters and vegetation tables. The standard profile coefficient is $`\kappa=0.4`$. Apply the supplied vegetation, snow, ice and wave transfer laws to each tile. Only active columns change, except that a prescribed fixed-roughness setting covers its complete arrays. Use nine tiles when the lake model is active. Detailed laws and frozen calculations belong in the solver contracts.
