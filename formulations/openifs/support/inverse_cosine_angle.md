# Angle From Its Cosine

Revision 1.

The solar model needs the angle at which the Sun crosses the horizon. A geometry calculation first gives the cosine of this angle. The inverse cosine converts that value back into an angle.

Let $`x`$ be the cosine, with no units, and let $`a`$ be the angle in radians. The relation is

```math
\cos(a)=x,\qquad -1\le x\le1,\qquad 0\le a\le\pi.
```

A value of 1 gives an angle of zero. A value of 0 gives a right angle, and a value of −1 gives an angle of $`\pi`$ radians. Each input has one answer within this half-circle. There is no time update, initial state or spatial boundary.

The [md2fort contract](../../../skills/md2fort/references/openifs/support/acos_original_rounding.md) defines the numerical calculation and its checked limits.
