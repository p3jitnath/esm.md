# Scalar Power

Revision 1. Equation POW-01 raises a numerical base $`x`$ to an exponent $`y`$ and returns $`z`$. The exponent has no physical unit. Each calling model defines the physical meaning and units of its base and result.

```math
z=x^y. \tag{POW-01}
```

For example, $`4^{1/2}=2`$. A positive base permits any real exponent, while a negative base needs an integer exponent for a real result. No initial state or spatial boundary is needed for this scalar relation.

The [numerical contract](../../../skills/md2asm/references/openifs/support/power_original_rounding.md) defines the frozen calculation, special values and interface.
