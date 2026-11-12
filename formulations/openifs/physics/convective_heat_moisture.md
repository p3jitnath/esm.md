# Convective Heat and Moisture

Formulation revision 1 describes heat and water transport through a vertical atmospheric column. This input follows OpenIFS CUDTDQN. The implementation contract is [CUDTDQN](../../../skills/md2fort/references/openifs/physics/cudtdqn.md).

## Physical Idea

Convection is the movement of warm air upwards and cooler air downwards. These air currents carry energy and water vapour. Water can also freeze, melt, evaporate or enter a cloud. Those changes must appear in the heat and water budgets.

A layer has pressure thickness $`\Delta p`$ in pascals. Its mass per unit horizontal area is $`\Delta p/g`$ in kilograms per square metre, where $`g`$ is gravity. Temperature $`T`$ is measured in kelvin. Specific humidity $`q`$ is the mass of water vapour divided by the mass of moist air.

## Basic Mathematics

Let $`E`$ be the combined upward and downward energy transport in watts per square metre. Let $`Q`$ be the combined water-vapour transport in kilograms per square metre per second. Subscripts $`j`$ and $`j+1`$ mark the upper and lower faces of a layer. The terms $`S_E`$ and $`S_q`$ describe local energy and water changes from condensate and precipitation. Equation H1 converts the net transport into a temperature change.

```math
\frac{dT_j}{dt}=\frac{g}{c_p\Delta p_j}\left(E_{j+1}-E_j+S_{E,j}\right). \tag{H1}
```

Equation H2 gives the corresponding water-vapour change.

```math
\frac{dq_j}{dt}=\frac{g}{\Delta p_j}\left(Q_{j+1}-Q_j+S_{q,j}\right). \tag{H2}
```

Latent heat is the energy released or absorbed when water changes phase. Equation H3 gives a smooth mixture of liquid and ice values. The liquid fraction $`a`$ is zero at or below $`T_i`$ and one at or above $`T_w`$. The function $`\operatorname{clip}(x,0,1)`$ keeps a value between zero and one.

```math
a(T)=\left[\operatorname{clip}\left(\frac{T-T_i}{T_w-T_i},0,1\right)\right]^2,\qquad L(T)=a(T)L_v+[1-a(T)]L_s. \tag{H3}
```

## Parameters and Supplied State

| Symbol | Meaning | Value or units |
| --- | --- | --- |
| $`g`$ | Gravity | 9.80665 m s⁻² |
| $`c_p`$ | Heat capacity of dry air | Source-defined value, about 1005 J kg⁻¹ K⁻¹ |
| $`L_v`$ | Latent heat of vaporisation | 2 500 800 J kg⁻¹ |
| $`L_s`$ | Latent heat of sublimation | 2 834 500 J kg⁻¹ |
| $`L_m=L_s-L_v`$ | Latent heat of melting | 333 700 J kg⁻¹ |
| $`T_w`$ | Liquid endpoint | 273.16 K |
| $`T_i`$ | Ice endpoint for convection | 235.16 K |
| $`\Delta t`$ | Physics time interval | Supplied in seconds |

The caller supplies pressure, temperature, humidity, geopotential, air mass transport, heat and water transport, cloud-water transport, detrained cloud water and precipitation. Geopotential is gravitational potential energy per unit mass, measured in square metres per square second. The initial state includes temperature and humidity tendencies from earlier physical processes.

## Boundaries and Scope

The caller selects the active columns and the first updated layer. Pressure increases downwards. The bottom face has no further convective air transport. Cloud water and precipitation still contribute to the bottom layer. Inactive tendencies retain their input values. The accepted implementation covers normal physics, including the explicit and implicit updates. The numerical contract records the ice-energy correction and the limits of a source-defined diagnostic.
