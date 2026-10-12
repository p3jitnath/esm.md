# Cartesian Departure Points

A moving air parcel carries heat and water. To update a grid cell, trace its air parcel backwards to its earlier position, then read the earlier fields at that position. `LARMES_XYZ` performs this trace on a sphere.

Let $`\boldsymbol{x}`$ be a Cartesian position on the unit sphere and let $`\boldsymbol{v}`$ be its velocity in sphere radii per second. The time interval $`\Delta t`$ is in seconds. The vertical coordinate $`\eta`$ is dimensionless and its rate $`w`$ is in reciprocal seconds.

```math
\frac{d\boldsymbol{x}}{dt}=\boldsymbol{v},\qquad \frac{d\eta}{dt}=w.
```

Longitude $`\lambda`$ and latitude $`\phi`$ describe the direction of the earlier Cartesian position $`(x_d,y_d,z_d)`$.

```math
\lambda=\operatorname{atan2}(y_d,x_d),\qquad \phi=\arcsin\left(\frac{z_d}{\sqrt{x_d^2+y_d^2+z_d^2}}\right).
```

Use the supplied time interval, arrival positions, earlier winds, full and half levels, and model boundaries. Keep the vertical position between the supplied top and bottom interpolation bounds. The solver contract defines the iteration, exact arithmetic and stored bytes.
