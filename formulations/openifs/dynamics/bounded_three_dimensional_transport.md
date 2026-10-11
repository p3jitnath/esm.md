# Bounded Three-Dimensional Transport

Revision 1.0 describes the physical input for OpenIFS LAITRIQM3D. A moving air parcel carries a quantity q, such as temperature in K or a water mass fraction in kg kg⁻¹. The solver estimates that quantity at the parcel's previous position from nearby grid values.

## Basic Mathematics

For transport without a source, q stays constant along the parcel path. Velocity u has units m s⁻¹, position x has units m and time t has units s. The gradient ∇q gives the change in q per metre in each direction.

```math
\tag{BT-1}
\frac{\partial q}{\partial t}+\mathbf{u}\cdot\nabla q=0.
```

A constant field must remain constant. A bounded estimate must also stay between the nearby minimum and maximum when the selected limiter is active. A limiter is a rule that stops interpolation from creating a new extreme.

```math
\tag{BT-2}
q_{\min}\leq q_{\mathrm{new}}\leq q_{\max}.
```

## Inputs And Boundaries

Supply finite nearby field values, parcel-position fractions from zero to one, and ordered layer coordinates. Derive the selected minimum and maximum from the eight surrounding values. The model keeps quantities outside the selected output columns unchanged.

The [md2asm contract](../../../skills/md2asm/references/openifs/dynamics/laitriqm3d.md) records the original thirty-two-point estimate, both limiting rules and the optional vertical correction. This note does not claim that the local correction proves global mass conservation.
