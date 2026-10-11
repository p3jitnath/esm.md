# Surface Radiation

Revision 1

The surface reflects part of the incoming sunlight and emits thermal radiation. Water, soil, snow, ice, vegetation, lakes and buildings have different radiative properties. A surface tile is one of these surface types within a model grid cell.

Let $`f_t`$ be the area fraction of tile $`t`$. The fractions are dimensionless and sum to one. Albedo $`a_t`$ is the fraction of sunlight reflected by a tile. Emissivity $`e_t`$ is its thermal emission relative to a perfect emitter at the same temperature. Both coefficients lie between zero and one.

```math
a = \sum_t f_t a_t, \qquad e = \sum_t f_t e_t.
```

For each spectral band, these equations combine the tile properties into the cell properties. Direct sunlight and diffuse sunlight have separate albedos. Solar band weights combine the spectral values into a broad band value.

```math
F_{\mathrm{reflected}} = a F_{\mathrm{incoming}}, \qquad F_{\mathrm{absorbed}} = (1-a)F_{\mathrm{incoming}}.
```

The radiation fluxes $`F`$ have units of W m$`^{-2}`$. These two parts conserve the incoming sunlight. Surface temperature is in K, soil moisture is a volume fraction, lake ice thickness is in m and wind speed is in m s$`^{-1}`$. Monthly sea ice tables vary with the calendar date. Snow, moist soil and urban canyons change the tile coefficients.

The initial state supplies the surface temperature, water and ice state, tile fractions, incoming sun angle and stored spectral tables. This local calculation has no spatial boundary. Its complete numerical contract is in [SURFRAD_CTL](../../../skills/md2asm/references/openifs/surface/surfrad_ctl.md).
