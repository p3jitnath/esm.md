# Convective Final Fluxes

Revision 1. Rising and sinking air carry heat and water through a convective cloud. This calculation combines their fluxes, then follows rain and snow towards the ground.

A mass flux $`M`$ has units kg m⁻² s⁻¹. Temperature $`T`$ is in K, water content $`q`$ is in kg kg⁻¹, specific heat $`c_p`$ is in J kg⁻¹ K⁻¹, and gravitational potential $`\Phi`$ is in J kg⁻¹. Subtract the heat and water carried by the surrounding air to obtain the cloud's excess transport.

```math
F_h^{\mathrm{excess}}=F_h-M(c_pT+\Phi),
\qquad
F_q^{\mathrm{excess}}=F_q-Mq.
```

Rain flux $`R`$ and snow flux $`S`$ have units kg m⁻² s⁻¹. Condensation adds precipitation, detrainment transfers some precipitation out of the rising cloud, and evaporation removes falling precipitation. Melting moves mass from snow into rain without changing their combined water mass.

```math
\Delta(R+S)=\text{precipitation source}-\text{detrainment}-\text{evaporation}.
```

Pressure increases towards the surface. A pressure-based taper reduces cloud mass flux below cloud base. A limiter keeps the sinking mass flux below 98% of the rising mass flux. Evaporation cannot remove more precipitation than is available, and it also depends on the air's remaining capacity to hold water.

Use the supplied temperatures, humidities, pressures, cloud levels and convective fluxes. Retain the original melting, cloud-cover and evaporation parameters. The top rain and snow fluxes are zero. This formulation covers normal physics. The separate linearised physics model is outside its present domain.
