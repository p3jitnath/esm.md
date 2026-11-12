# Base-Ten Logarithm

Revision 1. Equation LOG10-01 describes a dimensionless ratio, which compares two quantities with the same unit. Its base-ten logarithm gives the exponent needed to recover that ratio.

```math
10^y=x,\qquad y=\log_{10}(x). \tag{LOG10-01}
```

Here $`x`$ is a positive ratio, and $`y`$ is its logarithm. For example, $`\log_{10}(0.1)=-1`$ and $`\log_{10}(10)=1`$. This relation helps convert soil moisture into a heat-conductivity coefficient. The admitted ratio is $`2^{-40}\le x\le32`$. No initial state or boundary condition is needed for this scalar relation.

The [md2fort contract](../../../skills/md2fort/references/openifs/support/log10_original_rounding.md) defines its rounded calculation and interface.
