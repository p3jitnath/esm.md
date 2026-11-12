# Cloud water samples

Revision 1.0 describes how a weather model represents different cloud water amounts within one grid cell. Instead of assigning the same water amount to every small column, the model chooses a positive sample multiplier. Radiation then sees columns with different cloud water amounts.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`W`$ | Mean cloud water amount, in the caller's water units |
| $`W_i`$ | Cloud water amount in sample column $`i`$, in the same units |
| $`r_i`$ | Positive sample multiplier, without units |
| $`f`$ | Standard deviation divided by the mean, without units |
| $`c`$ | Fraction of samples below a chosen value, without units |

The standard deviation measures the spread of values about their mean. A larger $`f`$ therefore describes more varied cloud water amounts.

## Equations

**P01. Sample scaling**

```math
W_i=W\,r_i.
```

**P02. Mean and spread**

```math
\operatorname{mean}(r)=1,\qquad
\operatorname{mean}\bigl((r-1)^2\bigr)=f^2.
```

The source uses a lognormal distribution, for which the logarithm of each positive multiplier follows a bell-shaped distribution. A stored table supplies the sample multiplier for a chosen spread and fraction $`c`$. These equations describe the underlying distribution and do not require a small finite sample to reproduce its mean exactly.

## Parameters, initial state and boundaries

Use $`0\leq f\leq4`$ and $`0\leq c\leq1`$ with the caller's fixed sample table. There is no time update in this helper. The [md2fort contract](../../../skills/md2fort/references/openifs/physics/pdf_sampler.md) defines table interpolation and clipping at the table edges.
