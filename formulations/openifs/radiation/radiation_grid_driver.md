# Radiation Grid Driver

Revision 1 describes the selected OpenIFS `RADINTG` calculation. It prepares sunlight and atmospheric fields, calls the radiation calculation and returns radiative fluxes. A flux is energy crossing a unit area per unit time. Shortwave radiation is sunlight, while longwave radiation is heat emitted by matter.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`\mu`$, $`\mu_e`$ | Supplied and effective solar-angle cosine, dimensionless |
| $`r`$ | Atmospheric curvature coefficient, dimensionless |
| $`p_-,p_+,p_h`$ | Adjacent layer pressures and their boundary pressure, Pa |
| $`T_-,T_+,T_h,T_s`$ | Adjacent layer, boundary and skin temperatures, K |
| $`I`$ | Incoming shortwave flux at the top, W m⁻² |
| $`D_s,U_s,U_t`$ | Downward surface, upward surface and upward top shortwave flux, W m⁻² |
| $`a`$ | Surface albedo, the reflected fraction of sunlight, dimensionless |
| $`t,q`$ | Atmospheric transmission and reflection fractions, dimensionless |
| $`F_s,F_s'`$ | Surface net shortwave flux before and after the albedo update, W m⁻² |

## Equations

**P01. Effective sunlight direction**

```math
c=r(r+2),\qquad
\mu_e=\begin{cases}
r/(\sqrt{\mu^2+c}-\mu),&\mu>10^{-10},\
r/\sqrt{c},&\mu\leq10^{-10}.
\end{cases}
```

The curvature correction keeps the effective cosine positive near the horizon. The later heating calculation supplies the actual sunlight strength.

**P02. Temperature at a layer boundary**

```math
T_h=\frac{T_-p_-(p_+-p_h)+T_+p_+(p_h-p_-)}{p_h(p_+-p_-)}.
```

Pressure weights combine the temperatures above and below the boundary. At the top, extrapolate from the first layer and its lower boundary. At the bottom, use the supplied skin temperature.

**P03. Shortwave transmission and reflection**

```math
D_s=tI+qU_s,\qquad U_t=qI+tU_s,
```

```math
t=\frac{ID_s-U_sU_t}{I^2-U_s^2},\qquad
q=\frac{IU_t-U_sD_s}{I^2-U_s^2}.
```

These relations account for sunlight transmitted through the atmosphere and light reflected back from the surface.

**P04. Surface albedo update**

```math
F_s'=\frac{It(1-a)}{1-aq},\qquad
D_s'=\frac{F_s'}{1-a},\qquad
\Delta F=F_s'-F_s.
```

Add the same net-flux change at each height before applying the final bounds. This preserves the difference between adjacent layer fluxes, which determines radiative heating.

## Parameters, initial state, and boundaries

The supplied state contains 2048 columns and nineteen atmospheric layers. The model and radiation grids coincide. The curvature coefficient is $`r=0.001277`$. Pressure increases towards the surface and remains positive. Temperature is in kelvin. Radiation uses the supplied gas, aerosol and cloud profiles; the parent does not advance time.

Albedo uses six spectral bands and stays between the supplied surface minimum and one. The local update limits its combined albedo to $`0.9999`$ and applies only when downward and net surface fluxes are positive and downward flux exceeds net flux. Cloud fraction stays between zero and one, and cloud water stays nonnegative. Droplet-forming particle concentrations use the retained land range 292–1743 cm⁻³ and ocean range 32–287 cm⁻³.

The top boundary receives the supplied sunlight. The bottom boundary uses the supplied surface temperature, emissivity and albedo. The accepted [radiation field preparation](radiation_field_preparation.md) calculation supplies atmospheric transport. The [solver contract](../../../skills/md2asm/references/openifs/radiation/radiation_grid_driver.md) records ordered arithmetic, storage, interfaces and actual checks.
