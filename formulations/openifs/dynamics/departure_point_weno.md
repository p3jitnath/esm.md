# Departure-Point Weather Interpolation

Revision 1.

Air moves temperature, water and momentum between grid cells. A departure point is the earlier position of the air that arrives at a grid cell. Let $`q`$ denote the transported field, with its original physical units, and let $`\mathbf{u}`$ denote air velocity in metres per second.

```math
\frac{\partial q}{\partial t}+\mathbf{u}\cdot\nabla q=0. \tag{WENO-1}
```

The equation states that the field moves with the air. During one transport step, use the old field at the parcel's departure position $`\mathbf{x}_d`$.

```math
q^{n+1}(\mathbf{x})=q^n(\mathbf{x}_d). \tag{WENO-2}
```

The supplied stencil is the small set of neighbouring old cells used to estimate this value. It includes six vertical positions and four horizontal rows. Supply the old field, departure-point indices, horizontal and vertical interpolation weights and boundary flags. The field retains its units, such as kelvin for temperature or kilograms of water per kilogram of air for a water mass fraction. All weights are dimensionless.

Use the supplied exponent, normally 2, to reduce the influence of rough vertical stencils. The named WENO method means weighted essentially non-oscillatory interpolation. Optional limiters prevent values outside the nearby field range. A supplied vertical factor can carry a limiter's removed amount to the next level. The numerical contract explains the precise ordering and the limits of that local correction.

The initial state is the supplied old field. The supplied top and bottom flags select the supported boundary stencils. Preserve cells outside the requested interval. This input does not prescribe a new grid, transport velocity or global conservation law.
