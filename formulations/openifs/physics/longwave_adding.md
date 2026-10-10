# Thermal Radiation Through Air

Revision 1 describes longwave radiation in OpenIFS. Longwave radiation carries heat emitted by the ground and the atmosphere. Divide the air into $`N`$ layers and follow each selected wavelength interval separately. At boundary $`j`$, let $`U_j`$ and $`D_j`$ be the upward and downward heat fluxes, measured in watts per square metre, W m$`^{-2}`$. Boundary 1 is the top and boundary $`N+1`$ is the ground.

For each layer, $`t_j`$ and $`r_j`$ are the transmitted and reflected fractions. The layer emits $`e_j^u`$ upwards and $`e_j^d`$ downwards, both in W m$`^{-2}`$. The fractions have no units, lie between zero and one, and satisfy $`t_j+r_j\leq1`$.

```math
U_j=r_jD_j+t_jU_{j+1}+e_j^u \tag{LW-A1}
```

```math
D_{j+1}=t_jD_j+r_jU_{j+1}+e_j^d \tag{LW-A2}
```

Each equation adds radiation reflected within the layer, radiation transmitted through it, and heat emitted by the air. A layer without scattering has $`r_j=0`$, so it sends radiation only forwards or emits new radiation.

There is no incoming heat radiation at the top. At the ground, $`E_s`$ is the emitted heat flux and $`a_s`$ is the reflected fraction of downward radiation.

```math
D_1=0,\qquad U_{N+1}=E_s+a_sD_{N+1} \tag{LW-A3}
```

The emitted fluxes are nonnegative and $`0\leq a_s\leq1`$. The forecast supplies their values. The [no-scattering contract](../../../skills/md2asm/references/openifs/physics/calc_fluxes_no_scattering_lw.md) records the numerical update and assembly interface. Cloudy layers can also reflect radiation and require a separate adding update.
