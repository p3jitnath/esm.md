# Prognostic Departure Update

Revision 1 follows the selected hydrostatic OpenIFS LAPINEB route. A hydrostatic model balances the vertical pressure force against gravity. This routine forms a provisional future state from values carried by the air and terms evaluated at the arrival point. A later forecast stage completes the coupled pressure calculation.

The transported fields are horizontal wind in metres per second, temperature in kelvin and constituent mass fractions in kilograms per kilogram. A constituent can be water vapour, cloud water or ice. The surface pressure is stored through the dimensionless quantity $`s=\log(p_s/p_0)`$, where $`p_s`$ is pressure in pascals and $`p_0=1\ \mathrm{Pa}`$.

For a transported scalar $`X`$, the basic equation states that its change while following the air equals its physical source $`S_X`$.

```math
\frac{\partial X}{\partial t}+\boldsymbol{v}\cdot\nabla X=S_X.
```

Here $`t`$ is time in seconds, $`\boldsymbol{v}`$ is the air velocity and $`\nabla X`$ describes how the field changes with position. The source includes the physical terms required by the enclosing forecast. The wind components must use the same local east and north directions before their contributions are combined.

Use the caller's grid, level pressures, initial fields, physical constants and departure-point data. The enclosing forecast supplies horizontal and vertical boundary values. This routine preserves every cell outside the requested column range.
