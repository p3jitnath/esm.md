# Mixing below low cloud

Revision 1 describes the low-cloud mixing used by the original CUSTRAT routine.

## The idea

A parcel of warm, moist air can rise from the surface until the surrounding air stops it. Low cloud forms where the parcel cools enough for water to condense. Mixing exchanges heat and water between nearby layers, while preserving their column totals.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`T`$ | Air temperature, K |
| $`q`$ | Water vapour mass per unit air mass, kg kg$`^{-1}`$ |
| $`\Phi`$ | Geopotential energy per unit mass, J kg$`^{-1}`$ |
| $`c_p`$ | Dry-air heat capacity, J kg$`^{-1}`$ K$`^{-1}`$ |
| $`s=c_pT+\Phi`$ | Dry static energy per unit mass, J kg$`^{-1}`$ |
| $`\Delta p`$ | Pressure difference across a layer, Pa |
| $`g`$ | Gravitational acceleration, m s$`^{-2}`$ |
| $`J_q,J_s`$ | Upward water and energy exchange across a layer boundary, kg m$`^{-2}`$ s$`^{-1}`$ and W m$`^{-2}`$ |

## Equations

**P01. Exchange between layers**

```math
\frac{\Delta p}{g}\frac{dq}{dt}=J_{q,\mathrm{below}}-J_{q,\mathrm{above}},
\qquad
\frac{\Delta p}{g}\frac{ds}{dt}=J_{s,\mathrm{below}}-J_{s,\mathrm{above}}.
```

Each layer gains what enters through one boundary and loses what leaves through the other. The same exchange appears with opposite signs in neighbouring layers, so internal mixing preserves total water and energy.

## Parameters, initial state, and boundaries

The caller supplies temperature, water vapour, pressure, height and the time interval. The parcel starts 0.25 K warmer than the lowest model layer. The original model limits this mixing to its lower layers and to pressures at least 90% of surface pressure. Its cloud exchange coefficient is 10 m² s⁻¹, reduced to 2.5 m² s⁻¹ when the air above stops the parcel. The top and bottom edges of the selected mixing region have zero exchange.

The [solver contract](../../../skills/md2fort/references/openifs/convection/custrat.md) gives the numerical update and its verified limits.
