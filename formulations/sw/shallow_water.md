# Two-dimensional periodic shallow-water equations

## Model Idea

The model follows the depth and depth-averaged horizontal motion of water over a flat bottom. Water depth is small compared with the horizontal distance over which the water moves. Gravity drives the flow, with friction, rotation and external forces omitted.

## Symbols and Units

| Symbol | Meaning and unit |
| --- | --- |
| $`x,y`$ | Horizontal position, m |
| $`t`$ | Time, s |
| $`h`$ | Water depth, m; $`h>0`$ |
| $`u,v`$ | Water velocity in the x and y directions, m/s |
| $`g`$ | Gravitational acceleration, 9.81 m/s² |

A partial derivative, such as $`\partial h/\partial t`$, means the rate at which a quantity changes with one variable while the other variables stay fixed.

## Governing Equations

**P01–P02. Conservation of water and momentum**

```math
\frac{\partial h}{\partial t}
+\frac{\partial(hu)}{\partial x}
+\frac{\partial(hv)}{\partial y}=0.
```

The depth rises where inflow exceeds outflow and falls where outflow exceeds inflow. Summing this balance over the whole domain gives conservation of water.

```math
\frac{\partial(hu)}{\partial t}
+\frac{\partial(hu^2+gh^2/2)}{\partial x}
+\frac{\partial(huv)}{\partial y}=0.
```

```math
\frac{\partial(hv)}{\partial t}
+\frac{\partial(huv)}{\partial x}
+\frac{\partial(hv^2+gh^2/2)}{\partial y}=0.
```

The last two equations give the motion in the x and y directions. The products $`hu`$ and $`hv`$ are depth-weighted velocities. The $`gh^2/2`$ terms represent pressure from the weight of the water, so a difference in depth accelerates the flow.

## State and Boundaries

The model uses a 1 m by 1 m square with periodic boundaries. Water leaving any side enters the opposite side with the same depth and velocity, so waves cross the edges without reflecting.

Still water starts with $`h=1`$ m and $`u=v=0`$ and should remain unchanged. The dam break starts at rest with 2 m depth in the left half and 1 m in the right half, causing waves as water flows towards the shallower side.

The physics revision is 1.0. The [solver specification](shallow_water_specification.md) records the verified choices derived with [md2fort](../../skills/md2fort/SKILL.md).
