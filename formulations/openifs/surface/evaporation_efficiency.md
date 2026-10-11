# Surface Evaporation Efficiency

Revision 1.1. Water evaporates from soil and plants when the air can take more water vapour. Surface resistance and the amount of stored water can limit this loss. A tile is one surface type, such as soil, vegetation or snow.

Let $`q_a`$ and $`q_s`$ be air humidity and saturation humidity in kg kg$`^{-1}`$. Let $`C`$ be the moisture exchange coefficient in kg m$`^{-2}`$ s$`^{-1}`$, and let $`b`$ be a dimensionless evaporation efficiency. The upward water flux is $`E`$ in kg m$`^{-2}`$ s$`^{-1}`$.

```math
E=bC(q_s-q_a).
\tag{P01}
```

Air density $`\rho`$ is in kg m$`^{-3}`$. Pressure $`p`$ is in Pa, air temperature $`T_a`$ is in K, and the dry-air gas constant $`R_d`$ is in J kg$`^{-1}`$ K$`^{-1}`$. The dimensionless factor $`\epsilon`$ accounts for water vapour. Surface resistance $`r`$ is in s m$`^{-1}`$.

```math
\rho=\frac{p}{R_dT_a(1+\epsilon q_a)},
\qquad
b=\frac{1}{1+Cr/\rho}.
\tag{P02}
```

For an interception store, water caught on plants, let $`W>0`$ be its capacity in kg m$`^{-2}`$ and $`\Delta t`$ the time step in s. Limit evaporation so that it cannot remove more than this amount in one step.

```math
E\Delta t\le W.
\tag{P03}
```

A canopy above snow has canopy resistance $`r_c`$ and resistance $`r_s`$ between the snow and canopy, both in s m$`^{-1}`$. Their moisture coefficients are $`b_c`$ and $`b_s`$.

```math
b_c=\frac{1}{1+Cr_c/\rho+r_c/r_s},
\qquad
b_s=\frac{1}{1+Cr_s/\rho+r_s/r_c}.
\tag{P04}
```

The source applies the snow coefficient when $`r_c>1`$ s m$`^{-1}`$. It uses $`r_s=1200/h`$, where 1200 J m$`^{-3}`$ K$`^{-1}`$ represents air heat capacity per volume and $`h`$ is the supplied canopy heat conductance in W m$`^{-2}`$ K$`^{-1}`$.

The surface heat term $`s`$ is in J kg$`^{-1}`$. Skin temperature $`T_s`$ is in K, dry-air heat capacity $`c_p`$ is in J kg$`^{-1}`$ K$`^{-1}`$, and $`a`$ is a dimensionless correction for moist-air heat capacity.

```math
s=c_pT_s\left[1+a\left(bq_s+(1-b)q_a\right)\right].
\tag{P05}
```

The supplied OpenIFS surface setup uses $`a=0`$. The same equations also describe the unstressed vegetation coefficient using its supplied resistance. Inputs are one atmospheric state and surface state. This diagnostic calculation has no spatial boundary update.
