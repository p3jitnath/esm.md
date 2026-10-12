# Direction From Two Cartesian Components

Revision 1. The two finite components $`x`$ and $`y`$ have matching units. The angle $`\theta`$ gives their direction in the plane, measured counterclockwise from the positive $`x`$ axis, in radians.

```math
\theta=\operatorname{atan2}(y,x), \qquad -\pi\le\theta\le\pi.
```

For a nonzero vector, $`\cos\theta=x/\sqrt{x^2+y^2}`$ and $`\sin\theta=y/\sqrt{x^2+y^2}`$. The signs of both components select the quadrant. One zero component lies on an axis. When both components are zero, there is no unique physical direction, so retain the original library's signed-zero axis convention for reproducible output.

The weather caller supplies horizontal Cartesian departure coordinates. Their direction gives longitude. Each calculation uses finite FP64 components and returns one FP64 angle. No boundary or time update belongs to this scalar calculation.
