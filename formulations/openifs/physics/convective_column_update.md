# Convective Column Update

Revision 1.

Warm, moist air can rise through cooler surrounding air. The rising cloud exchanges heat, water and momentum with its surroundings, and some condensed water falls as rain or snow. This calculation supplies the resulting changes to a weather model.

## Basic Mathematics

Let $`q_v`$ be water vapour and $`q_c`$ be condensed water, both in kg/kg. Their sum is total water.

```math
q_t=q_v+q_c. \tag{CUM-1}
```

Let $`T`$ be temperature in K, $`c_p`$ be specific heat in J/(kg K), $`\phi`$ be gravitational potential energy in J/kg, and $`L`$ be the latent heat for the water phase in J/kg. The cloud carries liquid or ice static energy.

```math
h=c_pT+\phi-Lq_c. \tag{CUM-2}
```

A layer between upper pressure $`p_t`$ and lower pressure $`p_b`$, both in Pa, has mass per unit area $`m`$ in kg/m². Here $`g`$ is gravitational acceleration in m/s².

```math
m=\frac{p_b-p_t}{g}. \tag{CUM-3}
```

An upward transported quantity enters a layer through its bottom face and leaves through its top face. Its layer change follows the difference between these two fluxes, with added exchange between the cloud and its environment. Water also changes phase and can leave as precipitation.

## Inputs and Parameters

The weather model supplies temperature, water content, wind, pressure, gravitational potential energy, surface heat and water fluxes, and a timestep in seconds. Levels run from the top of the atmosphere to the surface. It also supplies the cloud settings and the existing rates of change that this calculation updates.

| Parameter | Value | Unit |
| --- | ---: | --- |
| Gravitational acceleration | 9.80665 | m/s² |
| Dry-air specific heat | 1004.7088578330674 | J/(kg K) |
| Latent heat of vaporisation | 2500800 | J/kg |
| Latent heat of sublimation | 2834500 | J/kg |
| Water phase reference temperature | 273.16 | K |

The forecast supplies the initial state and the cloud settings. The focused examples use a 600 s timestep, and the accepted interface also checks the timestep provided by each caller.

## Boundaries

The surface supplies the heat and water fluxes. The calculation returns cloud transport, rain, snow and changes to temperature, humidity and wind. Clouds that do not form carry no cloud transport. Deep, shallow and mid-level clouds retain their original source rules.

This weather domain uses deterministic cloud calculations and no active chemical tracer transport. The [md2asm contract](../../../skills/md2asm/references/openifs/physics/cumastrn.md) records the complete numerical update, its direct assembly children and the verified interface.
