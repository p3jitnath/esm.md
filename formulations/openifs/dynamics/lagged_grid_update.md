# Lagged Hydrostatic Grid Update

Revision 1.0 describes the final local update after transport in a hydrostatic atmosphere. Hydrostatic means that the vertical pressure change balances gravity. The input fields already contain the preceding forecast calculations.

## Physical Idea

Add stored wind, temperature and log-pressure increments. Each increment already includes its time-step factor and has the same unit as its field. Wind has units of metres per second. Temperature has units of kelvin. Log-pressure is a dimensionless stored pressure variable.

## Basic Mathematics

Let $`u,v,T,\ell`$ be the incoming fields and let $`b_u,b_v,b_T,b_\ell`$ be their increments. Equation L01 adds each increment.

```math
u'=u+b_u,\qquad v'=v+b_v,\qquad T'=T+b_T,\qquad \ell'=\ell+b_\ell.
```

When the model stores virtual temperature, equation L02 converts temperature using the moist-air gas constant $`R`$ and the dry-air gas constant $`R_d`$. Both gas constants have units of joules per kilogram per kelvin.

```math
T_v=T'\frac{R}{R_d}.
```

A stretched grid uses the positive dimensionless map factor $`m`$. Equation L03 converts the two stored wind components.

```math
u_{\rm physical}=\frac{u'}m,\qquad v_{\rm physical}=\frac{v'}m.
```

## Inputs And Boundaries

Use the current forecast fields, their computed increments, constituent mass fractions and the grid map factors. A mass fraction is the mass of a constituent divided by the total mass. Optional model stress contributes a further wind increment before L01. Only the active columns change. The accepted time filter updates its own stored fields as explained in the [solver contract](../../../skills/md2fort/references/openifs/dynamics/lagged_grid_update.md).
