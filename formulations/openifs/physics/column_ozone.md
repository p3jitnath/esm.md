# Column ozone

Revision 1.0 describes ozone mass above one square metre of Earth's surface. Ozone absorbs radiation, so its column amount is a useful weather-model diagnostic. A mass fraction gives the mass of ozone divided by the mass of air.

| Symbol | Meaning | Unit |
| --- | --- | --- |
| $`q_{O_3}`$ | Ozone mass fraction | kg/kg |
| $`p`$ | Air pressure | Pa |
| $`g`$ | Gravitational acceleration | m/s² |
| $`M_{O_3}`$ | Column ozone mass | kg/m² |

The model assumes that air pressure supports the weight of the air above it. Its ozone balance is

```math
\tag{O3-1}
M_{O_3}=\frac{1}{g}\int_{p_{\mathrm{top}}}^{p_{\mathrm{surface}}}q_{O_3}\,dp.
```

Each pressure layer supplies its pressure thickness and ozone mass fraction. Use the forecast's fixed gravitational acceleration, normally 9.80665 m/s². A uniform mass fraction gives that fraction times the air-column mass. A column without ozone has zero ozone mass.

The initial state is the supplied atmospheric ozone field. Integrate from the model top to the surface without adding ozone fluxes at either boundary. This diagnostic does not advance the ozone field in time.
