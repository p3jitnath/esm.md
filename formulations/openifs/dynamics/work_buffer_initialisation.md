# Forecast Work-Buffer Initialisation

Revision 1. GPINISLB prepares work arrays before a weather update. It also selects liquid water, ice, rain and snow for radiation. Each water quantity is a mass fraction in kg/kg.

Let $`\theta`$ be the supplied dimensionless switch, with value zero or one, and let $`x`$ be an earlier forecast field. Its prepared value is either zero, a copy of $`x`$, or $`\theta x`$, according to the declared transport method and time level.

```math
x_{\mathrm{work}}\in\{0,\ x,\ \theta x\}.
```

The semi-Lagrangian method follows moving air. It clears fields that will later receive transported values. The Eulerian method works on fixed grid cells. Its first iteration can use earlier values, while later iterations clear the appropriate fields. The caller supplies the field selections.

Let $`\nu`$ be the pressure-normalised vertical velocity in $`\mathrm{s}^{-1}`$ and $`p>0`$ the hydrostatic pressure in Pa. The prepared pressure velocity is

```math
\omega=\nu p,
```

where $`\omega`$ has units of Pa/s. The tangent-linear branch, which describes a small change to the model state, leaves this nonlinear product untouched. Supplied nonhydrostatic wave fields are copied when their declared branch is enabled.

Keep selected water mass fractions finite and nonnegative. Use finite consumed fields and a positive pressure for the product. The initial work arrays are supplied by the caller. Leave inactive columns and unused fields unchanged. The [md2asm contract](../../../skills/md2asm/references/openifs/dynamics/gpinislb.md) defines every field selection and the output-buffer arrangement.
