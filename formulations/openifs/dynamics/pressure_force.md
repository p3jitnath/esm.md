# OpenIFS pressure force

Revision 1.0 describes the pressure force used by GPGRP in OpenIFS 48.1.1.

## The idea

Air moves from regions of higher pressure towards regions of lower pressure. This pressure force is part of the horizontal wind equation. A pressure gradient describes the pressure change per metre.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`\boldsymbol{a}_p`$ | Acceleration due to pressure, in metres per second squared |
| $`p`$ | Air pressure in pascals |
| $`\rho`$ | Air density in kilograms per cubic metre |
| $`\Phi`$ | Geopotential, in square metres per second squared |
| $`R_m,T`$ | Mixture gas constant in joules per kilogram per kelvin and temperature in kelvin |
| $`p_0`$ | A fixed positive reference pressure in pascals |
| $`\nabla_\eta`$ | Horizontal gradient along a model layer |

## Equations

**P01. Pressure acceleration**

```math
\boldsymbol{a}_p=-\frac{1}{\rho}\nabla p.
```

The negative sign points the acceleration towards lower pressure.

**P02. Pressure force on a model layer**

```math
\boldsymbol{a}_p=-\nabla_\eta\Phi-R_mT\nabla_\eta\ln(p/p_0).
```

Hydrostatic balance gives this form when a model layer changes height across the atmosphere. The first term accounts for that height change, and the second accounts for pressure change along the layer.

## Parameters, initial state, and boundaries

Use the geometry, pressures, air properties and gradients supplied by the forecast. At uniform pressure and height, the pressure acceleration is zero. This routine supplies the positive combined gradient, while the wind update applies its negative sign. The layer coefficients and exact arithmetic belong in the [md2asm contract](../../../skills/md2asm/references/openifs/dynamics/gpgrp.md).
