# OpenIFS hydrostatic balance

Revision 1.0 describes the vertical pressure balance used by the hydrostatic OpenIFS 48.1.1 forecast.

## The idea

The weight of air is balanced by a pressure force. Pressure therefore decreases with height. OpenIFS uses this balance to relate pressure levels to geopotential, which is gravitational potential energy per unit mass.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`z`$ | Height in metres, increasing upwards |
| $`p`$ | Air pressure in pascals |
| $`\rho`$ | Air density in kilograms per cubic metre |
| $`g`$ | Gravitational acceleration in metres per second squared |
| $`\Phi`$ | Geopotential in square metres per second squared |
| $`R_m`$ | Mixture gas constant in joules per kilogram per kelvin |
| $`T`$ | Temperature in kelvin |
| $`p_s,\Phi_s`$ | Surface pressure and surface geopotential in the same units as $`p,\Phi`$ |
| $`p_0`$ | A fixed positive reference pressure in pascals |

## Equations

**P01. Pressure balances weight**

```math
\frac{dp}{dz}=-\rho g,
\qquad
\Phi=gz.
```

The derivative gives the pressure change per metre. Its negative sign shows that pressure decreases upwards.

**P02. Geopotential from pressure**

```math
\frac{d\Phi}{d\ln(p/p_0)}=-R_mT.
```

This equation follows from the pressure balance and the [ideal-gas relation](thermodynamics.md). The logarithm acts on a pressure ratio, so its argument has no unit. Integrating upwards from the surface gives the geopotential at each atmospheric level.

## Parameters, initial state, and boundaries

The normal Earth configuration uses $`g=9.80665\ \mathrm{m\,s^{-2}}`$. Surface geopotential, surface pressure, temperature and composition come from the forecast inputs. The surface geopotential anchors the vertical calculation. The equation applies at positive atmospheric pressure.

The local GPGEO, GPHPRE and YOMCST sources define the forecast calculation and constants, identified by the [source record](../../../src/openifs/README.md). Their layer integration and boundary arithmetic belong in a [md2fort contract](../../../skills/md2fort/SKILL.md).
