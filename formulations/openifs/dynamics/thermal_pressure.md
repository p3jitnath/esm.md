# OpenIFS thermal pressure

Revision 1.0 describes the temperature and composition terms used by GPRT in OpenIFS 48.1.1.

## The idea

Pressure depends on temperature and the gas constant of the air mixture. Their product appears in atmospheric pressure forces and in the calculation of height from pressure. A horizontal gradient describes how a quantity changes from one place to another.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`R_m,R_d,R_v`$ | Mixture, dry-air and water-vapour gas constants, in joules per kilogram per kelvin |
| $`T,T_v`$ | Temperature and virtual temperature, in kelvin |
| $`H`$ | Gas constant times temperature, in square metres per second squared |
| $`q_v`$ | Water-vapour mass fraction, in kilograms per kilogram |
| $`\nabla`$ | Horizontal gradient, which measures change per metre |

Virtual temperature is the temperature that dry air would need to have the same pressure and density as the moist mixture.

## Equations

**P01. Thermal pressure term**

```math
H=R_mT=R_dT_v.
```

**P02. Horizontal change**

```math
\nabla H=T\nabla R_m+R_m\nabla T.
```

For a mixture of dry air and water vapour, $`\nabla R_m=(R_v-R_d)\nabla q_v`$. If the supplied gradients already describe virtual temperature, $`\nabla H=R_d\nabla T_v`$. These are two ways to describe the same physical dependence.

## Parameters, initial state, and boundaries

Use the exact gas constants, temperature, mixture properties and gradients supplied by the forecast. Typical Earth values are about 287.06 and 461.52 joules per kilogram per kelvin for dry air and water vapour. This local calculation changes no neighbouring cell. Its ordered arithmetic and the forecast's coordinate scaling belong in the [md2asm contract](../../../skills/md2asm/references/openifs/dynamics/gprt.md).
