# OpenIFS column water

Revision 1.0 describes the pressure-based column-water calculation in OpenIFS 48.1.1.

## The idea

A column of air contains water at different heights. Adding the water in each layer gives its mass above one square metre of ground. Hydrostatic balance relates each layer's air mass to its pressure difference.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`p,p_t`$ | Air pressure and pressure at the top, in pascals |
| $`q(p)`$ | Water mass fraction, in kilograms per kilogram |
| $`g`$ | Gravitational acceleration in metres per second squared |
| $`W(p)`$ | Water mass above pressure $`p`$, in kilograms per square metre |

## Equations

**P01. Add water through the column**

```math
W(p)=\frac{1}{g}\int_{p_t}^{p}q(p')\,dp'.
```

The pressure difference divided by gravity gives air mass per unit area. Multiplying by the water fraction gives water mass. The integral adds these contributions from the top downwards.

## Parameters, initial state, and boundaries

The normal Earth configuration uses $`g=9.80665\ \mathrm{m\,s^{-2}}`$. Water fractions and layer pressures come from the forecast state. At the top, $`W(p_t)=0`$. At the ground, the result is the whole column's water mass.

The local GPPWC and YOMCST sources define this calculation, identified by the [source record](../../bench/openifs/source.json). The layer approximation, ordered arithmetic and interface belong in the [md2asm contract](../../skills/md2asm/references/openifs/gppwc.md).
