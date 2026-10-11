# Angle From Its Sine

Revision 1.

The urban surface model needs the angle at which sunlight enters a street between buildings. The inverse sine converts a sine value into an angle.

Let $`x`$ be the sine, with no units, and let $`a`$ be the angle in radians. Choose the angle between two right angles, so each input has one answer.

```math
\sin(a)=x,\qquad -1\le x\le1,\qquad -\frac{\pi}{2}\le a\le\frac{\pi}{2}.
```

A sine of zero gives an angle of zero. A sine of 1 gives a positive right angle, and a sine of −1 gives a negative right angle. This calculation has no time update, initial state or spatial boundary.

The [md2asm contract](../../../skills/md2asm/references/openifs/support/asin_original_rounding.md) defines the numerical method and its checked limits.
