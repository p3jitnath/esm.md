# OpenIFS clouds and precipitation

Revision 1.0 describes the basic water and phase-change balances in OpenIFS 48.1.1.

## The idea

Water moves between vapour, liquid and ice. Cloud particles can become rain or snow, which falls towards the ground. Phase changes also transfer heat between water and air.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`\rho,q_j`$ | Air density in kilograms per cubic metre and water-class mass fraction in kilograms per kilogram |
| $`\mathbf v,\mathbf F_j`$ | Air velocity in metres per second and additional water flux in kilograms per square metre per second |
| $`S_j`$ | Rate of water transfer into class $`j`$, in kilograms per kilogram per second |
| $`C_{vl},C_{vi},C_{li}`$ | Net vapour-to-liquid, vapour-to-ice and liquid-to-ice transfer rates, in kilograms per kilogram per second |
| $`L_v,L_s,L_f`$ | Energy per kilogram for vaporisation, sublimation and melting, in joules per kilogram |
| $`Q_{\rm phase}`$ | Heating by phase changes, in watts per kilogram |

## Equations

**P01. Water-class balance**

```math
\frac{\partial(\rho q_j)}{\partial t}
+\nabla\cdot(\rho q_j\mathbf v+\mathbf F_j)=\rho S_j.
```

The derivative measures change and the divergence measures net outflow. The five main classes are vapour, cloud liquid, cloud ice, rain and snow. Internal transfers conserve water, so their sources sum to zero. Falling precipitation contributes to the additional flux.

**P02. Heat from phase changes**

```math
Q_{\rm phase}=L_vC_{vl}+L_sC_{vi}+L_fC_{li}.
```

Condensation and freezing release heat. Reversing a transfer changes its sign and consumes heat. The liquid and ice terms include all particles in the corresponding phase.

## Parameters, initial state, and boundaries

At 273.16 kelvin, upstream values are 2,500,800 joules per kilogram for vaporisation and 2,834,500 for sublimation. Their difference gives 333,700 for melting. Latent energies can depend on temperature, and their exact configured treatment must be preserved. Initial water classes, cloud fraction and temperature come from the forecast. Precipitation reaching the ground enters the surface water balance.

The local CLOUDSC and SUPHEC sources define the phase processes and constants, identified by the [source record](../../../src/openifs/README.md). Rates for condensation, particle growth, falling and evaporation require their source-derived md2asm contracts.
