# OpenIFS hybrid pressure

Revision 1.0 describes the vertical pressure coordinate in OpenIFS 48.1.1.

## The idea

OpenIFS follows atmospheric layers that stay near the ground at the surface and become nearly horizontal higher in the atmosphere. A vertical coordinate labels these layers. Each layer's pressure depends on fixed coordinate coefficients and the changing surface pressure.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`\eta`$ | Vertical coordinate, with no unit, increasing from the top towards the surface |
| $`p(\eta)`$ | Air pressure in pascals |
| $`p_s`$ | Surface air pressure in pascals |
| $`A(\eta)`$ | Fixed pressure coefficient in pascals |
| $`B(\eta)`$ | Fixed surface-pressure weight, with no unit |

## Equations

**P01. Pressure in a hybrid coordinate**

```math
p(\eta)=A(\eta)+B(\eta)p_s.
```

The first term fixes part of the pressure independently of the surface. The second term follows changes in surface pressure. Where the second term is large, layers follow the shape of the ground more closely.

## Parameters, initial state, and boundaries

The initial-condition file supplies the coordinate coefficients and the starting surface pressure. Preserve these values for the upstream forecast rather than choosing a new grid. At the surface, the coefficients give its pressure. Above the surface, the supplied profiles define the top and the pressure of each layer.

The local GPHPRE and YOMVERT sources define the pressure calculation and coefficient meanings. The [md2asm contract](../../../skills/md2asm/references/openifs/dynamics/gphpre.md) records the complete calculation and the pressure used within each layer. The [source record](../../../src/openifs/README.md) identifies the local implementation.
