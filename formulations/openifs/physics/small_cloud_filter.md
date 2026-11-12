# Removing Negligible Cloud

Revision 1. The original routine is `radiation_cloud::crop_cloud_fraction`.

## The idea

A model should treat a very small cloud amount as clear air. A tiny covered area can otherwise produce an unrealistically large water amount inside that cloud. Remove the cloud fraction when either its area or its total water content falls below a supplied threshold.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`f`$ | Fraction of a grid cell covered by cloud, no unit |
| $`q_l,q_i`$ | Liquid and ice water per unit air mass, kg kg⁻¹ |
| $`f_{\min}`$ | Smallest retained cloud fraction, no unit |
| $`q_{\min}`$ | Smallest retained cloud water amount, kg kg⁻¹ |

## Equations

**P01. Total cloud water**

```math
q=q_l+q_i
```

**P02. Filtered cloud fraction**

```math
f_{\mathrm{new}}=
\begin{cases}
0,& f<f_{\min}\ \text{or}\ q<q_{\min},\\
f,&\text{otherwise}.
\end{cases}
```

Equality retains the cloud. This filter changes the area fraction and leaves the two water amounts unchanged. Supply nonnegative water amounts, fractions between zero and one, and finite nonnegative thresholds. Apply the rule to the selected columns and all layers. This local diagnostic needs no time or spatial boundary condition.

The [md2fort contract](../../../skills/md2fort/references/openifs/physics/crop_cloud_fraction.md) records the stored-number comparisons and interface.
