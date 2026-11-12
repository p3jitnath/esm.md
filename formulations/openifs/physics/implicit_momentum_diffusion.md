# Implicit Momentum Diffusion

Revision 1 describes OpenIFS `VDFDIFM`. Mixing exchanges horizontal wind between air layers. Drag from hills slows the wind, while other model processes can add a prescribed wind change. The lower air also exchanges momentum with the surface. This revision has zero convective wind transport.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`u`$ | One horizontal wind component, metres per second |
| $`m`$ | Layer mass per unit horizontal area, kilograms per square metre |
| $`p,g`$ | Pressure in pascals and gravity in metres per second squared |
| $`C`$ | Mixing coefficient, kilograms per square metre per second |
| $`F`$ | Momentum flux between layers, pascals |
| $`d`$ | Drag coefficient, per second |
| $`f`$ | Prescribed wind change per second, metres per second squared |

## Equations

**P01. Layer momentum balance.**

```math
m_k=\frac{p_k-p_{k-1}}{g},
\qquad
F_k=C_k(u_{k+1}-u_k),
\qquad
m_k\frac{\partial u_k}{\partial t}=F_k-F_{k-1}-m_kd_ku_k+m_kf_k.
```

The index $`k`$ increases downward. The derivative $`\partial u/\partial t`$ means wind change per second. Flux differences transfer momentum between neighbouring layers. Drag removes wind momentum, and forcing supplies the other changes. The same equation applies to the second horizontal wind component.

## Parameters, initial state, and boundaries

The default gravity is $`9.80665\ \mathrm{m\,s^{-2}}`$. The caller supplies a positive time interval, old winds, increasing boundary pressures, nonnegative mixing and drag coefficients, prescribed wind changes and the two surface-current components. At least two layers take part in the solve. The momentum flux at the upper edge is zero. The bottom mixing term uses the supplied surface current in place of a lower air-layer wind.

The [md2fort skill](../../../skills/md2fort/SKILL.md) supplies the numerical method and its [VDFDIFM contract](../../../skills/md2fort/references/openifs/physics/vdfdifm.md), including the ordered arithmetic, storage and verification.
