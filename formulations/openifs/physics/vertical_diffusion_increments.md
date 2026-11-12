# Vertical Diffusion Increments

Revision 1 describes OpenIFS `VDFINCR`. Vertical diffusion exchanges air between neighbouring heights and changes wind, heat and water. Drag from hills also changes wind. Lost wind energy becomes heat.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`u,v`$ | Horizontal wind components, metres per second |
| $`a_u,a_v`$ | Wind change per second, metres per second squared |
| $`p`$ | Air pressure, pascals |
| $`g`$ | Gravitational acceleration, metres per second squared |
| $`\Delta t`$ | Time interval, seconds |
| $`E,D`$ | Wind energy and its loss per unit mass, joules per kilogram |
| $`F`$ | Momentum flux, pascals |

## Equations

**P01. Wind and energy changes.**

```math
u_{\mathrm{after}}=u_{\mathrm{before}}+\Delta t\,a_u,
\qquad
v_{\mathrm{after}}=v_{\mathrm{before}}+\Delta t\,a_v,
\qquad
E=\frac{u^2+v^2}{2},
\qquad
D=E_{\mathrm{before}}-E_{\mathrm{after}}.
```

Apply these relations first to vertical diffusion, then to hill drag. Add both wind changes to the existing wind tendency. Add each energy loss divided by the time interval to the heat tendency. Add the supplied diffusion water tendency to the existing water tendency. The model's heat variable combines temperature, height and cloud-water effects.

**P02. Momentum transport through the column.**

```math
F_k=F_{k-1}-\frac{p_k-p_{k-1}}{g}\,a_k,
\qquad
F_0=0.
```

Here $`k`$ identifies a layer from the top downward. Its pressure difference divided by gravity gives its mass per unit horizontal area. Compute a separate momentum flux for each wind component and drag tendency. The hill part of turbulent drag is included in vertical diffusion and also recorded separately.

## Parameters, initial state, and boundaries

The default gravity is $`9.80665\ \mathrm{m\,s^{-2}}`$. The caller supplies a positive time interval, old winds, existing tendencies, diffusion and hill-drag tendencies, and pressure at every layer boundary. Pressure increases or stays equal toward the ground. All supplied calculations remain finite. The upper momentum flux is zero. The bottom flux records the total transfer through the column.

The [md2fort skill](../../../skills/md2fort/SKILL.md) supplies the numerical method and its [VDFINCR contract](../../../skills/md2fort/references/openifs/physics/vdfincr.md), including the ordered arithmetic, storage and checks.
