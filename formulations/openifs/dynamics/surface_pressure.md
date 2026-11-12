# OpenIFS surface pressure

Revision 1.0 describes surface pressure and its horizontal derivatives in OpenIFS 48.1.1.

## The idea

Surface pressure measures the weight of the air above the ground. OpenIFS stores its logarithm, which is a convenient way to represent a positive pressure. The exponential function converts that stored value back to pressure.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`p_s`$ | Surface air pressure in pascals |
| $`p_*`$ | Reference pressure of 1 Pa |
| $`s`$ | Stored logarithm of $`p_s/p_*`$, with no unit |
| $`x`$ | A horizontal coordinate, measured in metres for this explanation |

## Equations

**SP01. Recover surface pressure**

```math
p_s=p_*e^s.
```

**SP02. Recover its horizontal derivative**

```math
\frac{\partial p_s}{\partial x}
=p_s\frac{\partial s}{\partial x}.
```

The first equation gives a positive pressure. The second follows from the chain rule, which describes how the derivative of a function changes when its input changes. Apply the same equation in the other horizontal direction.

## Parameters, initial state, and boundaries

The forecast's initial file supplies the logarithm and its horizontal derivatives. The reference pressure is 1 Pa. The global forecast has no lateral edge, and this conversion adds no new boundary condition. Preserve the model's own horizontal coordinate scaling. The [md2fort contract](../../../skills/md2fort/references/openifs/dynamics/gp_spv.md) records storage, time levels and numerical arithmetic.
