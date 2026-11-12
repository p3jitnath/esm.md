# Plume Air Exchange

Revision 1. Original routine `cuentr` in `arpifs/phys_ec/cuentr.F90`.

A rising plume can mix with nearby air. Entrainment means air entering the plume, while detrainment means air leaving it. This calculation supplies the exchanged mass flux across one layer for an active plume above its cloud base.

Let $`M`$ be the upward plume mass flux in kg m$`^{-2}`$ s$`^{-1}`$, $`\Delta z`$ the layer thickness in m, and $`\lambda\ge0`$ the detrainment coefficient in m$`^{-1}`$. The exchanged mass flux $`D`$ has units kg m$`^{-2}`$ s$`^{-1}`$. This original routine sets the entrainment flux $`E`$ to zero.

```math
D=\lambda M\Delta z,\qquad E=0.
```

Geopotential $`\Phi`$ has units m$`^2`$ s$`^{-2}`$ and measures gravitational potential energy per unit mass. Gravity $`g`$ has units m s$`^{-2}`$. It gives the layer thickness from the geopotential difference.

```math
\Delta z=\frac{\Phi_{\mathrm{upper}}-\Phi_{\mathrm{lower}}}{g}.
```

An optional stochastic perturbation represents uncertainty in the detrainment coefficient. Its supplied dimensionless random field is $`r`$, with configured mean $`\mu`$ and amplitude $`\sigma`$. The exponential keeps the perturbed coefficient nonnegative.

```math
\lambda_{\mathrm{pert}}=\lambda\exp(\mu+\sigma r).
```

Runtime input supplies positive gravity, layer geopotential, nonnegative plume mass flux and detrainment coefficient, cloud-base levels, active-plume flags and any perturbation configuration. If work is disabled, all outputs keep their incoming bytes. Otherwise, selected columns without an eligible plume have zero exchange flux. The [md2fort contract](../../../skills/md2fort/references/openifs/physics/cuentr.md) defines the exact flags, arithmetic and storage.
