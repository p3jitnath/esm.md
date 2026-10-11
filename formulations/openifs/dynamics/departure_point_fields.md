# Fields At A Departure Point

Formulation revision 1 defines the selected spherical Cartesian calculation in the original LARCINA routine. A semi-Lagrangian forecast follows air back to its earlier position, called the departure point. The trajectory calculation supplies its longitude, latitude and vertical position. This calculation finds nearby grid points and the weights needed to estimate a field at that position.

Longitude and latitude use radians. The vertical coordinate and interpolation weights have no unit. A supplied field and its interpolated result have the same units. The optional four fields are the original scaled wind components and vertical velocity.

If the neighbouring field values are $`f_i`$ and the interpolation weights are $`w_i`$, the estimate is

```math
f_d=\sum_i w_i f_i,\qquad \sum_i w_i=1.
```

The original selected interpolation and limiter control the weights. A constant supplied field must keep its value. Boundary stencils stay inside the supplied horizontal and vertical field storage. This formulation uses the spherical Cartesian trajectory mode without extra vertical-velocity smoothing.
