# OpenIFS convection

Revision 1.0 describes the basic plume transport balance in OpenIFS 48.1.1.

## The idea

A rising plume carries warm, moist air through its surroundings. It takes in surrounding air and releases some plume air. These exchanges are called entrainment and detrainment. Sinking plumes also transport air.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`z,\rho,a,w`$ | Height in metres, density in kilograms per cubic metre, plume area fraction and vertical speed in metres per second |
| $`M`$ | Upward plume mass flux in kilograms per square metre per second |
| $`q_p,q_e`$ | Plume and surrounding water fractions, in kilograms per kilogram |
| $`F_q`$ | Water transport relative to the surroundings, in kilograms per square metre per second |
| $`E,D`$ | Entrainment and detrainment per unit height, in kilograms per cubic metre per second |

## Equations

**P01. Plume mass and water transport**

```math
M=\rho aw,
\qquad
F_q=M(q_p-q_e).
```

The mass flux depends on plume area and speed. A wetter rising plume transports extra water upwards.

**P02. Mass exchanged with the surroundings**

```math
\frac{dM}{dz}=E-D.
```

Entrainment increases plume mass, while detrainment reduces it.

## Parameters, initial state, and boundaries

The configured scheme distinguishes deep, shallow and mid-level convection. Cloud-base mass flux and exchange rates depend on the forecast state and configured parameters. Preserve those choices rather than substituting fixed rates. Starting temperature, moisture and wind come from the surrounding air. Plumes exchange heat and water with the atmospheric layers and produce precipitation.

The local CUBASEN, CUASCN and CUMASTR sources define plume initiation and ascent, identified by the [source record](../../../bench/openifs/source.json). Their trigger rules, closure relations and ordered updates belong in md2asm contracts.
