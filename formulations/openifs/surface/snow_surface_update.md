# Snow-Covered Surface Update

Revision 1 describes snow on land in the complete OpenIFS multilayer snow driver. Snow can receive precipitation and radiation, exchange heat with the ground, melt, freeze and release water.

Snow mass $`M`$ and liquid water $`W`$ are measured in kg m$`^{-2}`$. Snow temperature $`T`$ is in kelvin. The time step $`\Delta t`$ is in seconds. Snowfall $`P_s`$, rain $`P_r`$, evaporation $`E`$ and runoff $`R`$ are in kg m$`^{-2}`$ s$`^{-1}`$. Positive evaporation adds snow water in this convention.

```math
\text{SN-1}\qquad M'=M+\Delta t(P_s+P_r+E-R).
```

The prime denotes the state after one update. This equation balances incoming and outgoing water across the full snow column.

Let $`f_5`$ and $`f_7`$ be the fractions covered by exposed and forest snow. The snow-covered fraction is $`f=\max(f_5+f_7,10^{-7})`$. Snow receives fraction $`f`$ of the available rain, while the remaining fraction reaches the ground.

```math
\text{SN-2}\qquad P_{r,\mathrm{snow}}=fP_r,\qquad P_{r,\mathrm{ground}}=(1-f)P_r.
```

Snow heat storage changes through sensible heat, latent heat, shortwave and longwave radiation and ground heat. Sensible heat is heat exchanged because air and snow have different temperatures. Latent heat accompanies evaporation, freezing and melting. The freezing temperature is 273.16 K and the latent heat of melting is 333700 J kg$`^{-1}`$.

The initial state supplies each layer's mass, liquid water, density and temperature, together with snow albedo, which is the fraction of incoming sunlight reflected by snow. Boundary inputs supply rain, snowfall, radiation, turbulent heat exchange, air pressure and the temperature and water content of the top soil layer. The [md2asm contract](../../../skills/md2asm/references/openifs/surface/srfsn_driver.md) defines the complete numerical update.
