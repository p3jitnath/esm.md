# Thermal Radiation Through Cloudy Columns

This model follows thermal radiation that moves upward and downward through the atmosphere. Clouds change the amount that each layer reflects, transmits and emits. The surface emits heat and reflects part of the radiation that reaches it.

Let $`U_{g,k}`$ and $`D_{g,k}`$ be upward and downward fluxes at boundary $`k`$ and spectral point $`g`$, in W m$`^{-2}`$. A spectral point is one weighted part of the radiation spectrum. A layer has reflection and transmission fractions $`r_{g,k}`$ and $`t_{g,k}`$. Its upward and downward emissions are $`s^\uparrow_{g,k}`$ and $`s^\downarrow_{g,k}`$, in W m$`^{-2}`$.

The layer transfers radiation between its upper and lower boundaries.

```math
U_{g,k-1}=r_{g,k}D_{g,k-1}+t_{g,k}U_{g,k}+s^\uparrow_{g,k},
\qquad
D_{g,k}=t_{g,k}D_{g,k-1}+r_{g,k}U_{g,k}+s^\downarrow_{g,k}.
\tag{P01}
```

Let $`c`$ be the fraction covered by cloud, with $`0\le c\le1`$. For either upward or downward radiation, the column flux is the weighted mean of its clear and cloudy parts.

```math
F_k=cF_k^{\mathrm{cloud}}+(1-c)F_k^{\mathrm{clear}},
\qquad
F_k=\sum_g F_{g,k}.
\tag{P02}
```

No downward thermal radiation enters at the top. At the surface, $`E_g`$ is emitted flux in W m$`^{-2}`$ and $`a_g`$ is the reflected fraction, with $`0\le a_g\le1`$.

```math
D_{g,0}=0,
\qquad
U_{g,L}=E_g+a_gD_{g,L}.
\tag{P03}
```

The supplied state contains layer optical depth, cloud fraction, cloud overlap, boundary thermal emission, surface emission and surface reflectivity. Optical depth, cloud fraction and overlap are dimensionless. The captured forecast uses 19 layers, 140 spectral points, 16 bands and 8 columns. It calculates clear radiation, cloud scattering and the surface response. Aerosol scattering is disabled. Numerical choices and assembly details belong in the solver contract.
