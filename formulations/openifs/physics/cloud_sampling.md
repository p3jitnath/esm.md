# Cloud Sampling For Radiation

Revision 1.0 describes small cloudy columns used to calculate how clouds change the flow of radiation. A model grid cell can contain several cloud layers. Each sample represents a vertical line through the cloudy part of that cell.

| Symbol | Meaning and unit |
| --- | --- |
| $`f_j`$ | Cloud fraction in layer $`j`$, without units |
| $`C_j`$ | Fraction covered by cloud in layers one through $`j`$, without units |
| $`u`$ | Uniform random sample in $`[0,1)`$, without units |
| $`\alpha_j`$ | Overlap weight between neighbouring layers, without units |
| $`s>0`$ | Scale for overlap of cloud water variations, without units |
| $`m_{g,j}`$ | Optical-depth multiplier for sample $`g`$ and layer $`j`$, without units |

**P01. Select The First Cloud**

```math
j_{\mathrm{top}}=\min\{j\mid uC_n\leq C_j\}.
```

The interval between neighbouring cumulative cloud fractions gives the chance that the first cloud occurs in that layer. The [cloud overlap model](cloud_overlap.md) supplies these fractions.

**P02. Share Cloud Water Variations**

```math
a_j=\alpha_j^{\,1/s}.
```

This weight controls how often neighbouring cloudy layers share the same water sample. Zero gives independent samples, and one gives identical samples. The [cloud column rules](cloud_columns.md) locate lower clouds, and the [sample distribution](cloud_water_samples.md) supplies their multipliers.

## Parameters, Initial State And Boundaries

Use exponential-random cloud overlap, with fractions and overlap weights between zero and one. Start from an integer random seed. Layers without cloud have multiplier zero. If the total cloud fraction is below the positive threshold, report zero cloud cover and preserve the unused multiplier array. The [md2asm contract](../../../skills/md2asm/references/openifs/physics/cloud_sampling.md) fixes the calculations, supported inputs and exact random draw order.
