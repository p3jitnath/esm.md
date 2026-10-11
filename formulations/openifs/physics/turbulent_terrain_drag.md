# Turbulent Drag From Small Hills

Revision 1 describes the unchanged OpenIFS routine `vdftofdc`.

## The Idea

Small hills slow the wind by producing turbulent motion near the ground. The model uses the variation in terrain height to estimate a positive drag coefficient. A later momentum equation uses this coefficient to remove wind energy.

## Symbols

| Symbol | Meaning and Unit |
| --- | --- |
| $`h`$ | Height above the ground, in metres |
| $`u,v`$ | Horizontal wind components, in metres per second |
| $`\sigma`$ | Standard deviation of terrain height, in metres |
| $`U`$ | Wind speed with a small positive lower limit, in metres per second |
| $`D`$ | Drag coefficient, in inverse seconds |
| $`r`$ | Planetary scale factor, with no unit |
| $`p`$ | Height exponent, approximately 1.2, with no unit |

## Equations

**D1. Wind Speed**

```math
U=\sqrt{\max(0.1^2,u^2+v^2)}.
```

The small lower limit keeps the speed positive when the wind is still.

**D2. Terrain Drag**

```math
D=C\sigma^2U
\exp\!\left[-\left(\frac{h}{1500/r}\right)^{1.5}\right]h^{-p},
\qquad
0<h\le5000/r.
```

The positive constant $`C`$ combines the model's terrain parameters and supplies the units needed for $`D`$. The exponential makes the effect decrease with height. Above $`5000/r`$ metres, the coefficient is zero.

## Parameters, Initial State, and Boundaries

The standard planet uses $`r=1`$ and gravitational acceleration $`9.80665`$ metres per second squared. Height comes from geopotential divided by gravitational acceleration. Geopotential is gravitational potential energy per unit mass, measured in square metres per square second.

The caller supplies the wind, geopotential, terrain variation and positive drag parameters. Flat terrain returns zero drag. The [md2asm contract](../../../skills/md2asm/references/openifs/physics/vdftofdc.md) retains the original stored constants and the height cutoff.
