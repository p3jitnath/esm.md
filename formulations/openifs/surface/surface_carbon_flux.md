# Surface Carbon Flux

## The Idea

Revision 1 defines the carbon exchange calculation used by SRFCOTWO. Plants take carbon dioxide from the air during photosynthesis, while plants and soil return it during respiration. The model combines low and high vegetation over each surface cell. Positive carbon-dioxide flux means transfer from the air to the surface.

## Basic Mathematics

Let $`c_v`$ be the fraction of the cell covered by vegetation class $`v`$. Let $`G_v`$, $`D_v`$ and $`R_v`$ be gross photosynthesis, dark respiration and soil respiration, measured in kilograms of carbon dioxide per square metre per second. Dark respiration is the release of carbon dioxide by plant metabolism. The total flux $`F_{\mathrm{CO_2}}`$ is

```math
F_{\mathrm{CO_2}}=\sum_{v=1}^{2}c_v\left(G_v-D_v-R_v\right). \tag{SC-1}
```

Soil respiration increases with soil temperature and depends on available liquid water and snow cover. Let $`f_w`$ and $`f_s`$ be factors between zero and one for water and snow. Let $`R_{0,v}`$ be the reference respiration rate, and let $`Q_{10}(T)`$ describe its temperature sensitivity. For soil temperature $`T`$ in degrees Celsius,

```math
R_v=f_w f_s R_{0,v}\left[Q_{10}(T)\right]^{(T-25)/10}. \tag{SC-2}
```

The model also estimates methane release from wet ground. Let $`w`$ be the wetland fraction, $`s_{\phi}`$ the latitude factor, $`q_v`$ the methane temperature factor and $`T_1`$ the top-layer temperature in degrees Celsius. Its calibrated methane diagnostic $`M_v`$ uses the reference carbon-dioxide mass rate. This note retains the original interface unit, kilograms of carbon dioxide per square metre per second, for that calibrated diagnostic.

```math
M_v=2s_{\phi}w f_w f_s R_{0,v}q_v^{(T_1-25)/10}. \tag{SC-3}
```

Methane release is zero for frozen topsoil, zero wetland fraction, zero reference rate or a zero methane factor. The cell methane flux is negative when methane leaves the surface.

## Parameters, Initial State And Boundaries

The supplied state contains four soil layers, soil and vegetation types, liquid-water fractions, soil temperatures, snow depth, surface fractions and the canopy fluxes. Air temperature is in kelvin, pressure in pascals, specific humidity in kilograms per kilogram and snow depth in metres. Surface fractions, root fractions and leaf area index have no units.

The freezing reference is 273.16 kelvin, and the methane latitude bands have edges at −25 and 25 degrees. Respiration and methane tables depend on vegetation type. The time interval is supplied in seconds. Daily net assimilation accumulates the supplied net canopy rate over this interval, while a separate record retains the maximum assimilation per unit air density and leaf area. The forecast supplies the initial records and the parameter tables. Low and high vegetation use the original surface tile map. Only the requested cell interval changes, and cells outside it retain their previous values.

The derived [solver contract](../../../skills/md2asm/references/openifs/surface/surface_carbon_flux.md) records the model's temperature function, snow and water factors, source constants, storage and arithmetic.
