# Periodic angle projections

Revision 1.

## The idea

An angle describes a direction. Picture a point on a circle of radius one. Cosine gives its horizontal position, and sine gives its vertical position. These two projections also describe seasonal phases, solar directions and periodic waves in a weather model.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`\theta`$ | Supplied angle, in radians. One full turn is $`2\pi`$ radians. |
| $`c`$ | Horizontal projection, dimensionless. |
| $`s`$ | Vertical projection, dimensionless. |

## Equations

**P01. Direction projections**

```math
c=\cos\theta,\qquad s=\sin\theta.
```

The angle selects a direction, and the two projections give its components.

**P02. Unit circle and repeated turns**

```math
c^2+s^2=1,\qquad
\sin(\theta+2\pi)=\sin\theta,\qquad
\cos(\theta+2\pi)=\cos\theta.
```

The first relation keeps the point on the circle. Adding a full turn returns the same direction.

## Parameters, initial state, and boundaries

The radius is one, and there are no other physical parameters. Each call starts from its supplied angle. At zero angle, the horizontal projection is one and the vertical projection is zero. Angles repeat after each full turn.

The [md2fort contract](../../../skills/md2fort/references/openifs/support/sin_cos_original_rounding.md) records the supported numerical angle range, ordered arithmetic, storage and verification.
