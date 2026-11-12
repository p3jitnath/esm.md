# Ocean Skin Temperature

Revision 1. The ocean skin is the thin layer of water that exchanges heat with the air. Loss of heat can make this layer colder than the water below it. Sun's radiation can also create a warm layer near the surface. The model updates skin temperature by adding these two effects to sea-surface temperature.

## Basic Mathematics

Let $`T_s`$ be sea-surface temperature in kelvin, $`\Delta T_c\leq0`$ the cool-skin change, and $`\Delta T_w\geq0`$ the warm-layer change. The new skin temperature is given by O01.

```math
T_{\mathrm{skin}}=T_s+\Delta T_w+\Delta T_c. \tag{O01}
```

A cool layer of thickness $`\delta`$ metres conducts an upward heat flux $`Q_c`$ in watts per square metre. Water conductivity $`k_w=0.6\ \mathrm{W\,m^{-1}\,K^{-1}}`$ gives O02.

```math
\Delta T_c=-\frac{\delta Q_c}{k_w}. \tag{O02}
```

The warm layer receives net radiation and surface heat exchange. Let $`F`$ be that input divided by water heat capacity per unit volume, in kelvin metres per second. Let $`a`$ be the inverse-depth coefficient in inverse metres and $`b`$ the turbulent mixing rate in inverse seconds. Its physical time balance is O03.

```math
\frac{\mathrm{d}\Delta T_w}{\mathrm{d}t}=aF-b\Delta T_w,\qquad \Delta T_w\geq0. \tag{O03}
```

Wind stress controls the friction velocity and therefore the mixing rate. Langmuir circulation is extra mixing caused by wind-driven surface waves. It can multiply that rate by a factor from one to ten.

## Inputs And Boundaries

Supply the time interval in seconds, solar and thermal radiation and sensible and latent heat fluxes in watts per square metre, stress components in pascals, wind and wave-drift components in metres per second, previous skin temperature and sea-surface temperature in kelvin. Supply gravity, air heat capacity, latent heat of evaporation and the positive planet-size scale. Water density is $`1025\ \mathrm{kg\,m^{-3}}`$ and water heat capacity is $`4190\ \mathrm{J\,kg^{-1}\,K^{-1}}`$. The warm depth is three metres divided by the scale. Separate switches enable cooling, warming and Langmuir mixing.

Each column uses its own inputs. There is no exchange between neighbouring columns. Columns outside the selected interval retain their complete output bytes. The previous skin temperature supplies the initial warm-layer state. The [md2fort contract](../../../skills/md2fort/references/openifs/surface/ocean_skin_temperature.md) supplies the empirical wall relation, full time update and source rounding.
