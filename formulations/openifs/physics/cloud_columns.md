# Cloud sample columns

Revision 1.0 describes the small cloudy columns used in radiation calculations. A weather grid cell can contain cloud at some heights and clear air at others. The model chooses each sample column using cloud cover and the overlap of neighbouring clouds.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`f_j`$ | Cloud fraction in layer $`j`$, without units |
| $`P_j`$ | Combined cloud fraction of adjacent layers, without units |
| $`C_j`$ | Cumulative cloud fraction through layer $`j`$, without units |
| $`H_j=C_{j+1}-C_j`$ | Extra cloud area introduced by the next layer, without units |
| $`a_j`$ | Weight for shared water samples in adjacent cloudy layers, without units |
| $`u`$ | Uniform sample in $`[0,1)`$, without units |

## Equations

**P01. Cloud below cloud**

```math
u f_j < f_{j+1}+f_j-P_j.
```

The right side is the area that both clouds share. This rule selects cloud in the lower layer with the appropriate conditional probability.

**P02. Cloud below clear air**

```math
u(C_j-f_j)<P_j-H_j-f_j.
```

This rule applies when the sample column is clear at the upper layer but already contains cloud farther above.

**P03. Shared water variation**

```math
u_2<a_j.
```

When this condition holds, reuse the preceding cloudy layer's water sample. Otherwise retain the new independent sample. The [sample distribution](cloud_water_samples.md) turns that sample into a water or optical-depth multiplier.

## Parameters, initial state and boundaries

Start at a selected cloudy top layer and stop at the lowest cloudy layer. Cloud fractions, cumulative cover, adjacent cover and added area come from the [cloud overlap model](cloud_overlap.md). Each weight is between zero and one. The [md2fort contract](../../../skills/md2fort/references/openifs/physics/cloud_columns.md) defines the exact random draw order, contiguous cloud groups and output storage.
