# OpenIFS moist-air properties

Revision 1.0 describes the mixture properties calculated by GPRCP in OpenIFS 48.1.1.

## The idea

Air contains dry gases and water. Water can be vapour, liquid or ice, and each form changes the mixture's response to pressure and heat. A mass fraction gives a constituent's mass divided by the total mixture mass. The forecast configuration decides which constituents contribute to these properties.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`q_j`$ | Mass fraction of constituent $`j`$, in kilograms per kilogram |
| $`q_d`$ | Mass fraction treated as dry air, in kilograms per kilogram |
| $`R_j,R_d,R_m`$ | Constituent, dry-air and mixture gas constants, in joules per kilogram per kelvin |
| $`c_{p,j},c_{p,d},c_{p,m}`$ | Heat capacities at constant pressure, in joules per kilogram per kelvin |
| $`\kappa`$ | Ratio of the mixture gas constant to its heat capacity, with no unit |
| $`p,\rho,T`$ | Pressure in pascals, density in kilograms per cubic metre and temperature in kelvin |

Heat capacity is the heat needed to raise one kilogram by one kelvin. A sum over $`j`$ includes the constituents selected by the forecast configuration. The remaining fraction uses dry-air properties.

## Equations

**P01. Mixture fractions**

```math
q_d=1-\sum_j q_j.
```

**P02. Mixture properties**

```math
R_m=q_dR_d+\sum_j q_jR_j,
\qquad
c_{p,m}=q_dc_{p,d}+\sum_j q_jc_{p,j},
\qquad
\kappa=\frac{R_m}{c_{p,m}}.
```

Each constituent contributes according to its mass fraction. Liquid water and ice have zero gas constant in this calculation, while their heat capacities remain nonzero.

**P03. Ideal-gas pressure**

```math
p=\rho R_mT.
```

At the same temperature and density, a change in composition changes the pressure.

## Parameters, initial state, and boundaries

The local constants give approximately $`R_d=287.06`$ and $`R_v=461.52`$ joules per kilogram per kelvin for dry air and water vapour. Their heat capacities are approximately 1004.71 and 1846.10 joules per kilogram per kelvin. Liquid water uses 4218 and ice uses 2106 joules per kilogram per kelvin. These rounded values explain the physics. Generation must retain the exact upstream constant values.

Initial constituent fractions come from the forecast state. This calculation changes mixture properties at each point and does not transport material across boundaries. The GPRCP and YOMCST sources define constituent selection and exact constants, identified by the [source record](../../bench/openifs/source.json). Ordered arithmetic and the complete interface belong in a [md2asm contract](../../skills/md2asm/references/openifs/gprcp.md).
