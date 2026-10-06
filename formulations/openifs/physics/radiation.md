# OpenIFS radiation

Revision 1.0 describes the basic radiation balance in OpenIFS 48.1.1.

## The idea

The Sun supplies shortwave radiation. The Earth and atmosphere emit longwave radiation. Absorption warms a layer, while a net loss of radiation cools it. Clouds and gases change the fluxes, which are energy flows through one square metre.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`F_u,F_d,F`$ | Upward, downward and net upward radiation fluxes, in watts per square metre |
| $`p,T,t`$ | Pressure in pascals, temperature in kelvin and time in seconds |
| $`g,c_r`$ | Gravity in metres per second squared and the radiation heat capacity in joules per kilogram per kelvin |
| $`q_v,c_{p,d},c_{p,v}`$ | Vapour mass fraction in kilograms per kilogram and dry-air and vapour heat capacities in joules per kilogram per kelvin |

## Equations

**P01. Net upward radiation**

```math
F=F_u-F_d.
```

Upward energy flow is positive. Each flux includes its shortwave and longwave parts.

**P02. Radiation changes temperature**

```math
\left.\frac{\partial T}{\partial t}\right|_{\rm radiation}
=\frac{g}{c_r}\frac{\partial F}{\partial p},
\qquad
c_r=c_{p,d}+(c_{p,v}-c_{p,d})q_v.
```

Pressure increases downwards. A difference in net flux between a layer's boundaries gives its heating or cooling. The heat capacity follows the dry-air and vapour mixture used by the radiation-to-temperature conversion.

## Parameters, initial state, and boundaries

Normal Earth gravity is 9.80665 metres per second squared. The heat capacities are approximately 1004.71 and 1846.10 joules per kilogram per kelvin. Preserve their exact upstream values. Temperature, pressure, humidity, clouds, surface properties and absorption data come from the forecast inputs. The Sun supplies incoming radiation at the top, and the surface emits and reflects radiation at the bottom.

The local RADHEATN source defines the flux-to-temperature conversion. The radiation_flux module stores the upward and downward fluxes. Absorption, scattering, spectral intervals and configured updates require separate md2asm contracts, grounded in the [source record](../../../bench/openifs/source.json).
