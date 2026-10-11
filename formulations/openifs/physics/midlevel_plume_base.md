# Midlevel Plume Base

Revision 1. Original routine `cubasmcn` in `arpifs/phys_ec/cubasmcn.F90`.

A rising plume carries warm, moist air upward. This calculation starts a plume near the middle of a column when convection is enabled, no plume already occupies that level, and the air is sufficiently moist. A plume is a narrow column of moving air.

Let $`T`$ be the air temperature in K, $`q`$ the water-vapour mass fraction in kg kg$`^{-1}`$, and $`q_s`$ its saturation value. Let $`\Phi`$ be geopotential in m$`^2`$ s$`^{-2}`$, which gives gravitational potential energy per unit mass. The subscripts $`e`$ and $`b`$ denote the environment and the new plume base. The specific heat $`c_p`$ has units J kg$`^{-1}`$ K$`^{-1}`$.

The plume starts when $`q_e>0.80q_s`$ and the existing convection and level flags allow it. It keeps the environment's dry static energy, the sum of sensible heat and gravitational potential energy.

```math
c_p T_b+\Phi_b=c_p T_e+\Phi_e,\qquad q_b=q_e.
```

Let $`\omega`$ be pressure change per unit time in Pa s$`^{-1}`$, and let $`g`$ be gravitational acceleration in m s$`^{-2}`$. Negative $`\omega`$ indicates ascent. The upward mass flux $`M`$ has units kg m$`^{-2}`$ s$`^{-1}`$ and lies between a small positive floor and the configured limit $`M_{\max}`$.

```math
M=\min\!\left(M_{\max},\max\!\left(10^{-6},-\frac{\omega}{g}\right)\right).
```

The initial dry-static-energy flux is $`M(c_pT_b+\Phi_b)`$ in J m$`^{-2}`$ s$`^{-1}`$, and the vapour flux is $`Mq_b`$ in kg m$`^{-2}`$ s$`^{-1}`$. Initial liquid water, liquid flux, precipitation change and rain are zero. Cells that do not start a plume keep their incoming state. Runtime configuration supplies $`c_p`$, $`g`$ and $`M_{\max}\ge10^{-6}`$.

The [md2asm contract](../../../skills/md2asm/references/openifs/physics/cubasmcn.md) defines the source's ordered arithmetic, flags and storage.
