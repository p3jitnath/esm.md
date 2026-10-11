# Surface Weather Elements

Revision 1. Surface tiles represent water, ice, vegetation, snow, soil, lakes and urban ground. This model combines their heat and water fluxes, then reports wind at 10 m, temperature and dewpoint at 2 m, wind gusts and skin temperature.

A tile fraction $`f_t`$ is the part of a grid cell covered by tile $`t`$. Each fraction lies between zero and one, and the fractions sum to one. Let $`H_t`$ be sensible heat flux in W/m², $`E_t`$ be water flux in kg/(m² s), and $`T_t`$ be skin temperature in K. Their cell means are

```math
\bar H=\sum_t f_t H_t,\qquad
\bar E=\sum_t f_t E_t,\qquad
\bar T=\sum_t f_t T_t. \tag{SWX-1}
```

If $`T_\mathrm{old}`$ is the previous mean skin temperature and $`\Delta t`$ is the time interval in s, the added skin-temperature rate is

```math
\delta\dot T=\frac{\bar T-T_\mathrm{old}}{\Delta t}. \tag{SWX-2}
```

The wind profile depends on surface roughness and atmospheric stability. Roughness is a length in m that describes surface drag. Stability describes whether warm air rises easily or whether temperature stratification resists vertical motion. Neutral conditions give a logarithmic wind profile, while stability corrections describe warming or cooling.

A wind gust adds a positive increase to the 10 m wind speed. Let $`u_\tau`$ be the friction velocity from surface stress in m/s, $`z_i`$ be a mixing length in m, and $`B`$ be buoyancy flux in m²/s³. The original empirical gust model uses

```math
G=\lvert\boldsymbol U_{10}\rvert+
7.2u_\tau
\left(1+\frac{0.5}{12}\max\left(0,\frac{z_i\kappa B}{u_\tau^3}\right)\right)^{1/3}. \tag{SWX-3}
```

Here $`\kappa=0.4`$ is the dimensionless von Kármán constant. Dewpoint is the temperature at which the reported water vapour reaches saturation. It cannot exceed the reported air temperature.

Inputs are the original tile fractions and fluxes, positive temperatures and pressure, atmospheric wind and humidity, roughness lengths, ocean currents and surface settings. Snow uses the supplied sublimation heat in J/kg. Optional ocean skin physics changes the water tile before the final temperature mean. The initial state and selected horizontal boundaries come from the weather caller.
