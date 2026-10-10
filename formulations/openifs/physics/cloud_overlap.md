# Cloud overlap

Revision 1.0 describes the cloudy area seen from above an atmospheric column. Each model layer has a cloud fraction. Clouds in different layers can partly cover the same area, so adding their fractions would count some cloud twice.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`f_j`$ | Cloud fraction in layer $`j`$, without units |
| $`\alpha_j`$ | Overlap weight between adjacent layers, without units |
| $`P_j`$ | Combined cloud fraction of layers $`j`$ and $`j+1`$, without units |
| $`C_j`$ | Cloud fraction seen above the bottom of layer $`j`$, without units |

## Equations

**P01. Adjacent cloud cover**

```math
P_j=\alpha_j\max(f_j,f_{j+1})+(1-\alpha_j)(f_j+f_{j+1}-f_jf_{j+1}).
```

When $`\alpha_j=1`$, the smaller cloud lies under the larger cloud. When $`\alpha_j=0`$, the two cloud areas overlap as independent samples.

**P02. Cumulative cloud cover**

```math
1-C_{j+1}=(1-C_j)\frac{1-P_j}{1-f_j}.
```

The left side is the fraction of the column that remains clear. A fully cloudy layer makes every lower cumulative cover equal to one.

## Parameters, initial state and boundaries

Use $`0\leq f_j\leq1`$ and $`0\leq\alpha_j\leq1`$. Start at the top layer with $`C_1=f_1`$. The [md2asm contract](../../../skills/md2asm/references/openifs/physics/cloud_overlap.md) defines the optional overlap input conversion and the numerical rule near a fully cloudy layer.
