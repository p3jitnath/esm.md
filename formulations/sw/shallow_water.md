# Two-dimensional periodic shallow-water equations

## The idea

These equations describe a layer of water moving over a flat bottom. The water is shallow compared with the horizontal distance over which it moves. Gravity drives the flow; friction, rotation, and external forces are omitted. The velocities represent the average motion through the water depth, so the model follows horizontal flow and changes in the free surface.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`x,y`$ | Horizontal position, m |
| $`t`$ | Time, s |
| $`h`$ | Water depth, m; $`h>0`$ |
| $`u,v`$ | Water velocity in the x and y directions, m/s |
| $`g`$ | Gravitational acceleration, 9.81 m/s² |

A partial derivative, such as $`\partial h/\partial t`$, means the rate at which a quantity changes with one variable while the other variables stay fixed.

## Equations

**P01–P02. Conservation of water and momentum**

```math
\frac{\partial h}{\partial t}
+\frac{\partial(hu)}{\partial x}
+\frac{\partial(hv)}{\partial y}=0.
```

The depth changes when water flows into or out of a small region. If more water enters than leaves, the depth increases. If more leaves than enters, the depth decreases. Summing this balance over the whole domain gives conservation of water.

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

The last two equations describe horizontal motion. The products $`hu`$ and $`hv`$ are depth-weighted velocities, and the $`gh^2/2`$ terms account for water pressure. Gravity creates this pressure because the water above a point has weight. A difference in depth therefore produces a pressure difference that accelerates the water.

## Initial state and boundaries

The study uses a 1 m by 1 m square. Its boundaries are periodic: water leaving one side enters the opposite side with the same depth and velocity. The left and right edges are joined, as are the top and bottom edges, so a wave can cross an edge without reflecting from a wall.

A simple starting state is still water, with $`h=1`$ m and $`u=v=0`$. A dam-break example starts with depth 2 m in the left half, depth 1 m in the right half, and zero velocity everywhere. Gravity then moves water from the deeper region towards the shallower region, creating waves. The still-water case should remain unchanged and provides a simple physical check.

Physics revision: 1.0. [md2fort](../../skills/md2fort/SKILL.md) derives the numerical method and implementation; its [solver specification](shallow_water_specification.md) preserves the verified choices and equation IDs.
