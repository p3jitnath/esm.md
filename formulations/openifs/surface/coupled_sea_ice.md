# Coupled Sea-Ice Surface Fields

Revision 1 follows OpenIFS ICESTATENEMO. An ocean model can supply the atmosphere with sea-ice thickness, snow thickness, reflected solar fraction and surface temperatures.

## The idea

Coupling means that two models exchange physical fields. This operation selects the ocean model's columns that belong to the current atmospheric block. It copies supplied values without changing their physical meaning.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`s`$ | Global index of the first atmospheric column, dimensionless |
| $`j`$ | Local atmospheric column index, dimensionless |
| $`X_g`$ | Supplied ocean field at global column $`g`$ |
| $`Y_j`$ | Copied atmospheric field at local column $`j`$ |

## Equations

**P01. Column mapping**

```math
Y_j=X_{s-1+j}.
```

The same mapping applies to ice thickness and snow thickness in metres, reflectivity as a fraction from zero to one, and sea and ice temperatures in kelvin.

## Parameters, initial state, and boundaries

Coupling must be enabled to copy a field. Each of the five fields is optional, and an absent field remains unchanged. A selected block lies inside the supplied global array. An empty block changes no field. Qualified thicknesses are nonnegative, reflectivity lies from zero to one and temperatures lie from 160 to 340 K.

The [md2fort contract](../../../skills/md2fort/references/openifs/surface/icestatenemo.md) specifies the exact copying and memory interface.
