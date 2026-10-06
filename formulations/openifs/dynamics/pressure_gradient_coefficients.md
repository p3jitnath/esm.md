# Pressure-gradient coefficients

Revision 1.0 describes how a change in surface pressure changes the pressure within an atmospheric layer. Pressure uses pascals. A hybrid coordinate combines a fixed pressure contribution with a contribution from the local surface pressure.

```math
p_h=A_h+B_hp_s. \tag{OIFS-PG1}
```

Here $`p_h`$ is pressure at a layer boundary, $`p_s`$ is surface pressure, $`A_h`$ has units of pascals, and $`B_h`$ is dimensionless. The calling forecast supplies these coefficients and the current pressure state.

## Basic gradients

Let $`x`$ be a horizontal distance in metres. A pressure gradient describes how pressure changes as we move along $`x`$. The layer coefficients stay fixed during this calculation.

```math
\frac{\partial p_h}{\partial x}=B_h\frac{\partial p_s}{\partial x}. \tag{OIFS-PG2}
```

A dimensionless quantity $`q(p_s)`$ also changes with surface pressure. The chain rule gives its horizontal gradient.

```math
\frac{\partial q}{\partial x}=\frac{dq}{dp_s}\frac{\partial p_s}{\partial x}. \tag{OIFS-PG3}
```

The numerical method supplies the pressure-related quantities used in the forecast. Their coefficients have units of inverse pascals, while their gradients have units of inverse metres. Other coordinate scales retain their corresponding units. Only the supplied columns and atmospheric levels change.

The [md2asm contract](../../../skills/md2asm/references/openifs/dynamics/gpgrxyb.md) records the complete GPGRXYB stage, including its pressure approximations.
