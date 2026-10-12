# Spectral Semi-Implicit Atmospheric Update

Revision 1. This note uses the pressure and rotation physics in [atmospheric motion](atmospheric_motion.md). It describes the physical input. The [md2asm solver contract](../../../skills/md2asm/references/openifs/dynamics/spectral_semi_implicit_update.md) defines the numerical update and exact arithmetic.

## Physical Idea

Air moves when pressure changes across the atmosphere. Divergence $`D`$ measures how quickly air spreads from a region, in inverse seconds. Temperature $`T`$ is in kelvin. The model's logarithmic surface-pressure field $`q`$ has no unit. Geopotential $`\Phi`$ is gravitational potential energy per unit mass, in square metres per square second.

The hydrostatic operator $`\Gamma(T,q)`$ obtains geopotential from temperature and pressure. The vertical operators $`\tau(D)`$ and $`\nu(D)`$ give temperature and logarithmic pressure change rates from divergence. Their units are kelvin per second and inverse seconds. Each operator integrates through the atmosphere.

## Basic Mathematics

A spectral coefficient gives the amplitude of a smooth wave on the sphere. Degree $`n`$ describes its spatial scale. The spherical Laplacian coefficient $`\lambda_n`$ has units of inverse square metres. The pressure part of the update follows equations S01 through S03.

```math
\begin{aligned}
\Phi &= \Gamma(T,q),\\
\frac{\mathrm{d}D}{\mathrm{d}t} &= -\lambda_n\Phi, \tag{S01}\\
\frac{\mathrm{d}T}{\mathrm{d}t} &= -\tau(D), \tag{S02}\\
\frac{\mathrm{d}q}{\mathrm{d}t} &= -\nu(D). \tag{S03}
\end{aligned}
```

Earth's rotation also couples neighbouring wave coefficients. Its full atmospheric-motion equation is retained. The solver includes those rotation terms when it solves for the new divergence.

## Parameters And State

| Quantity | Value In The Current Coarse Forecast | Unit |
| --- | ---: | --- |
| Dry-air gas constant | 287.0596736665907 | J kg⁻¹ K⁻¹ |
| Gas constant divided by heat capacity | 2/7 | None |
| Earth's angular speed | 7.292115083046062 × 10⁻⁵ | s⁻¹ |
| Forecast time interval | 3600 | s |
| Vertical levels | 19 | None |
| Maximum spectral degree | 21 | None |

The initial temperature, divergence, logarithmic pressure and rotation contribution come from the preceding forecast calculation. The atmosphere uses the supplied positive pressure levels and layer widths. The global sphere has no lateral edge. The vertical pressure integrals use the source's declared top and ground boundaries. Their numerical matrices and boundary selectors belong to the solver contract.
