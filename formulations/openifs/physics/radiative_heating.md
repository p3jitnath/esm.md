# Heating by Radiation

Revision 1. This input describes `RADHEATN` in the deterministic broadband weather model. Broadband means that all thermal wavelengths are combined into one interval. The inputs are the stored radiation fluxes, the current Sun angle, surface temperature, humidity and pressure levels.

Let $`F`$ be the net downward radiative flux in watts per square metre. A layer has upper and lower pressures $`p_u`$ and $`p_l`$ in pascals. Gravity $`g`$ is in metres per second squared. The layer's mass per unit area is $`(p_l-p_u)/g`$. If more energy enters the layer than leaves it, its temperature increases.

RH-1

```math
H=\frac{g(F_u-F_l)}{c_p(1+a q)(p_l-p_u)}.
```

Here, $`H`$ is the temperature tendency in kelvins per second, $`c_p`$ is dry-air heat capacity in joules per kilogram per kelvin, $`q`$ is the water-vapour mass fraction and $`a`$ gives the extra heat capacity of water vapour. Apply this equation separately to solar and thermal radiation, then add their combined effect to the supplied temperature tendency.

RH-2

```math
F_{\rm solar}=S\mu\mathcal{T},
\qquad
\mathcal{T}_{\rm direct}=\exp(-\tau/\mu).
```

The Sun's radiation $`S`$ is in watts per square metre. The cosine of its angle from the vertical is $`\mu`$. The transmission fraction $`\mathcal{T}`$ is dimensionless, and $`\tau`$ measures how strongly the atmosphere removes direct light. Set the incoming solar flux to zero at night. A change in Sun angle changes the distance that direct light travels through the atmosphere.

RH-3

```math
U_s\approx\epsilon\sigma T_s^4+(1-\epsilon)D_{\rm old}.
```

The upward thermal flux at the surface is $`U_s`$, its emissivity is $`\epsilon`$, its temperature is $`T_s`$ in kelvins and $`\sigma`$ is the Stefan–Boltzmann constant. The optional approximate update keeps the reflected downward thermal flux $`D_{\rm old}`$ fixed while updating surface emission. An empirical response then changes downward radiation by about one fifth of the upward change. This is an approximation between full radiation calculations.

| Input | Typical value or units |
| --- | --- |
| Gravity $`g`$ | 9.80665 m s$`^{-2}`$ |
| Dry-air heat capacity $`c_p`$ | About 1004.71 J kg$`^{-1}`$ K$`^{-1}`$ |
| Heat-capacity correction $`a`$ | About 0.837, dimensionless |
| Solar irradiance $`S`$ | About 1370 W m$`^{-2}`$ |
| Surface emissivity $`\epsilon`$ | Between zero and one |
| Skin temperature $`T_s`$ | Kelvin |
| Stored net and downward fluxes | W m$`^{-2}`$ |

The initial radiation state comes from the preceding full radiation calculation. Supply increasing pressure boundaries and the current humidity in each layer. The top boundary supplies incoming sunlight. The bottom boundary supplies the current surface temperature. Keep the stored clear-sky fluxes as the comparison without clouds. The md2asm contract defines the numerical updates and their acceptance limits.
