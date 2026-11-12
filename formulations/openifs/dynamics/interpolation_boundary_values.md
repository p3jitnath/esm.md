# Interpolation Boundary Values

This operation prepares two extra layers just outside a model column. These layers hold work values for interpolation, which estimates a value between stored points. It leaves the physical model levels unchanged.

Revision 1. Let $`L`$ be the number of physical levels, a count without a physical unit, and let $`X`$ be a selected work field. The two extra layers have the same units as $`X`$. Their boundary values are

```math
X_0=0,\qquad X_{L+1}=0. \tag{P01}
```

The selected forecast has 19 physical levels. The initial work values come from the preceding dynamics calculations. Each selected boundary value becomes positive zero, and all other stored values remain unchanged.

The [solver contract](../../../skills/md2fort/references/openifs/dynamics/interpolation_boundary_values.md) defines the selected fields and their stored representations.
