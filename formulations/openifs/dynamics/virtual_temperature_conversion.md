# Virtual Temperature

Revision 1.0 describes the initial temperature conversion used by SPECRT in OpenIFS 48.1.1.

## The idea

Moist air and dry air can have different densities at the same temperature and pressure. Virtual temperature is the temperature that dry air would need to give the same density and pressure as the moist mixture. For example, water vapour usually makes this temperature slightly higher than the measured temperature.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`T`$ | Mixture temperature in kelvin |
| $`T_v`$ | Virtual temperature in kelvin |
| $`R_m,R_d`$ | Mixture and dry-air gas constants in joules per kilogram per kelvin |
| $`p`$ | Pressure in pascals |
| $`\rho`$ | Mixture density in kilograms per cubic metre |

The [mixture formulation](thermodynamics.md) defines how water vapour, liquid water and ice contribute to the gas constant.

## Equations

**P01. Virtual temperature**

```math
T_v=\frac{R_mT}{R_d}.
```

The gas-constant ratio converts the mixture temperature to its dry-air equivalent.

**P02. The same pressure**

```math
p=\rho R_mT=\rho R_dT_v.
```

Both forms describe the same pressure and density. The conversion changes the temperature variable used in the equations and does not add heat to the air.

## Parameters, initial state, and boundaries

The dry-air gas constant is approximately 287.06 joules per kilogram per kelvin. Generation retains the exact upstream constant. Initial temperature and water fractions come from the forecast input files. The relation applies separately at each location and does not transport material across a boundary. The [md2asm contract](../../../skills/md2asm/references/openifs/input/initial_virtual_temperature_conversion.md) records the existing numerical method and ordered arithmetic.
