# Two-Level Transport Terms

Revision 1. LATTEX_DNT prepares the terms that a weather model transports between two successive states. A semi-Lagrangian method follows moving air back to an earlier position. The caller later interpolates these terms at that position.

Let $`q`$ be a forecast field, such as temperature in K or wind velocity in m/s. Let $`A`$ be its supplied nonlinear change over half a time step and $`B`$ its supplied semi-implicit linear term. Both have the units of $`q`$. Let $`x`$ be a dimensionless time-weighting parameter. The combined residual is

```math
R=A+(1+x)B.
```

Let $`p=1+\delta`$ and $`m=1-\delta`$, where $`0\le\delta\le1`$ controls time weighting. A non-extrapolated transport change uses $`mA`$. Stable extrapolation adds a chosen fraction of the residual change, with dimensionless mixing weight $`0\le w\le1`$ and earlier residual $`R_{\mathrm{old}}`$.

```math
L=mA+w(R-R_{\mathrm{old}}).
```

The final-point contribution uses $`pR`$. A centred alternative uses $`p(3R-R_{\mathrm{old}})/2`$. A corrector repeats the update with a preliminary new state. The supplied arrays already contain earlier terms, so each declared contribution is added to them.

The initial states, time weights and method flags come from the caller. Use finite consumed fields and valid time weights. Leave inactive columns, padding and unused fields unchanged. The [md2asm contract](../../../skills/md2asm/references/openifs/dynamics/lattex_dnt.md) defines the complete ordered update and diagnostic terms.
