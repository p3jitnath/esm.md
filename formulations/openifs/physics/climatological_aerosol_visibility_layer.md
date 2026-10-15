# Climatological aerosol visibility layer

Revision 1. This formulation describes the selected `CLIMAER_LAYER` route in the OpenIFS reference forecast.

Aerosols are small particles suspended in air. They reduce visibility because they scatter and absorb light. The layer uses aerosol climatology, pressure, temperature, humidity and cloud water to calculate horizontal visibility.

Let $`T_{j,k}`$ be air temperature in kelvin, $`p_{j,k}`$ be full-level pressure in pascals and $`p^h_{j,k}`$ be pressure at a layer boundary. The column index is $`j`$ and the level index is $`k`$. The reference combines the neighbouring air temperatures with pressure weights to obtain the temperature used by the aerosol profile:

```math
T^h_{j,k} =
\frac{T_{j,k-1}p_{j,k-1}(p_{j,k}-p^h_{j,k}) + T_{j,k}p_{j,k}(p^h_{j,k}-p_{j,k-1})}
{p^h_{j,k}(p_{j,k}-p_{j,k-1})}.
```

The top boundary uses the reference extrapolation from the first two air levels. The bottom boundary uses the stored skin temperature. The aerosol profile supplies aerosol layer mass in kilograms per square metre.

Lowest-layer relative humidity is specific humidity divided by saturation specific humidity. Aerosol layer mass is converted to mass mixing ratio in grams per kilogram by multiplying it by $`1000g/\Delta p`$, where $`g`$ is gravitational acceleration in metres per second squared and $`\Delta p`$ is the lowest-layer pressure difference in pascals. The shortwave aerosol calculation uses the reference band that contains 550 nanometres and returns extinction in inverse kilometres.

The visibility calculation combines aerosol extinction with molecular scattering and the contributions from liquid cloud water, ice, rain and snow. The initial state, surface temperature, aerosol tables and constants come from the unchanged reference forecast. The selected route uses 24 columns and 19 air levels.
