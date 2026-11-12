# Gas Concentration Units

Revision 1.0 describes the amount of a gas relative to the surrounding air. A mass mixing ratio compares masses. A volume mixing ratio compares molecule amounts, which also equals the volume fraction for ideal gases at the same pressure and temperature.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`q_g`$ | Gas mass divided by air mass, kg kg⁻¹ |
| $`x_g`$ | Gas amount divided by air amount, mol mol⁻¹ |
| $`M_g`$ | Molar mass of the gas, g mol⁻¹ |
| $`M_a`$ | Molar mass of air, 28.970 g mol⁻¹ |
| $`y_g`$ | Stored concentration number, dimensionless |
| $`s_g`$ | Factor that converts the stored number into its physical ratio, dimensionless |

A mole is an amount of substance containing a fixed number of molecules. Molar mass is the mass of one mole. For parts per million by volume, the stored number has $`s_g=10^{-6}`$.

## Equations

**P01. Mass And Mole Conversion**

```math
q_g=x_g\frac{M_g}{M_a},\qquad x_g=q_g\frac{M_a}{M_g}.
```

The ratio of molar masses converts between molecule amount and mass without changing the gas that is present.

**P02. Stored Scale**

```math
r_g=s_g y_g.
```

Here $`r_g`$ is the physical mixing ratio in the stored mass or volume convention. A change of storage scale changes $`y_g`$ while preserving the physical amount.

## Parameters

| Gas code | Gas | Molar mass, g mol⁻¹ |
| --- | --- | --- |
| 1 | Water vapour, H₂O | 18.0152833 |
| 2 | Carbon dioxide, CO₂ | 44.011 |
| 3 | Ozone, O₃ | 47.9982 |
| 4 | Nitrous oxide, N₂O | 44.013 |
| 5 | Carbon monoxide, CO | 28.0101 |
| 6 | Methane, CH₄ | 16.043 |
| 7 | Oxygen, O₂ | 31.9988 |
| 8 | CFC-11 | 137.3686 |
| 9 | CFC-12 | 120.914 |
| 10 | HCFC-22 | 86.469 |
| 11 | Carbon tetrachloride, CCl₄ | 153.823 |
| 12 | Nitrogen dioxide, NO₂ | 46.0055 |

## Inputs And Boundaries

The caller supplies stored concentrations, their unit convention and scale, and flags that identify the gases present. Concentrations are finite and nonnegative, and physical scale factors are positive and finite. An absent gas has zero concentration. Each column and atmospheric level is independent. The [solver contract](../../../skills/md2fort/references/openifs/physics/gas_unit_conversion.md) defines reading, storage updates and ordered arithmetic.
