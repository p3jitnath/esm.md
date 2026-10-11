# Snow Water and Heat

Revision 1. This note describes the water and heat balance of a layered snowpack. Each layer holds ice and liquid water, and heat moves between neighbouring layers and the soil.

The total mass per unit ground area is $`M=I+W`$, where $`I`$ is ice mass and $`W`$ is liquid water mass, both in kg m$`^{-2}`$. Snowfall adds ice, rain adds water, and drainage removes water from the bottom. The signed ice flux $`E`$ includes evaporation or deposition.

```math
\frac{d}{dt}\sum_j M_j=P_{\mathrm{snow}}+E+P_{\mathrm{rain}}-R.
```

Each flux in this equation has units kg m$`^{-2}`$ s$`^{-1}`$. The runoff $`R`$ is water that leaves the snowpack.

Let $`C_j`$ be a layer's heat capacity per unit area in J m$`^{-2}`$ K$`^{-1}`$, and let $`F_j`$ be the net heat entering that layer in W m$`^{-2}`$. Let $`Q_j`$ be the signed energy rate used for melting or freezing.

```math
C_j\frac{dT_j}{dt}=F_j-Q_j,
\qquad
\frac{dW_j}{dt}=\frac{Q_j}{L}+\text{water entering}-\text{water leaving}.
```

The temperature $`T_j`$ is in K, and the latent heat $`L=333\,700`$ J kg$`^{-1}`$ is the energy needed to melt one kilogram of ice. Melting uses heat, while freezing releases heat. The melting temperature is $`273.16`$ K.

Use an ice heat capacity of $`2.05\times10^6/920`$ J kg$`^{-1}`$ K$`^{-1}`$ and a water heat capacity of $`4180`$ J kg$`^{-1}`$ K$`^{-1}`$. Supply each layer's initial mass, water mass, density and temperature, together with the surface heat input, soil temperature, soil conductivity, pressure and precipitation. The upper boundary receives the prescribed heat and mass fluxes, and the lower boundary exchanges heat with the soil and drains excess water.

The [md2asm contract](../../../skills/md2asm/references/openifs/surface/snow_water_energy.md) defines the time update, snow material formulas, ordered arithmetic and diagnostic fields.

If the ground is marked as having no resolved snow, any retained very thin snow is initialised as solid snow at the freezing temperature. The total snow mass follows the supplied snowfall and signed evaporation, while its liquid water is reset to zero. This initialisation does not solve the heat balance of a resolved snow layer.
