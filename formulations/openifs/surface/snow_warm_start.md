# Snow At The Start Of A Forecast

Revision 1, SW-1. This initialization turns one supplied snow state into a layered snowpack. Each layer has a temperature, density, total water mass and liquid water mass.

The total water mass per square metre must remain the same. If $`m_k`$ is the mass in layer $`k`$ and $`M`$ is the supplied total, then

```math
\sum_k m_k=M. \tag{SW-1}
```

Density $`\rho_k`$ is in kilograms per cubic metre. Layer depth $`h_k`$ is in metres, so $`m_k=\rho_k h_k`$ is in kilograms per square metre. Snow temperature is in kelvin. Liquid water must be between zero and the layer's total water mass.

The supplied snow mass, density and temperature describe the starting snow state. Soil and skin temperatures provide its lower and upper thermal conditions. Terrain height variation, snow cover, sunlight direction and snow albedo help select a measured profile. Albedo is the fraction of incoming sunlight reflected by snow.

Start from one supplied snow temperature, density and total water mass. The melting temperature is 273.16 kelvin. Deep snow can represent a glacier. Columns without snow retain their supplied state. The md2fort contract describes how layers and profiles are reconstructed and checked.
