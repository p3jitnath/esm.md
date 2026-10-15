# Cloud Water and Rain

Air contains water vapour and small liquid drops or ice particles. These forms exchange water as the air changes temperature. Larger drops and snow fall into lower layers and can leave the column as precipitation.

The water fractions $`q_v, q_l, q_i, q_r, q_s`$ are kilograms of vapour, cloud liquid, cloud ice, rain and snow per kilogram of moist air. Temperature $`T`$ is in kelvin and pressure $`p`$ is in pascals. The cloud fraction $`a`$ is the cloudy part of each grid cell.

Internal changes conserve total water. Transfers between vapour and liquid or ice also change temperature through latent heat, which is the energy released or absorbed during a phase change.

```math
q_{\mathrm{total}} = q_v + q_l + q_i + q_r + q_s
```

```math
h = c_p T - L_v(q_l + q_r) - L_s(q_i + q_s)
```

Here $`c_p`$ is the heat capacity of air in joules per kilogram per kelvin. The constants $`L_v`$ and $`L_s`$ are the latent heats for liquid water and ice in joules per kilogram. Water and heat enter through supplied convective fluxes and leave through rain and snow at the bottom.

Use the retained coarse forecast packet for parameter values, initial water fractions and pressure boundaries. Keep the physical input separate from the ordered numerical contract.
