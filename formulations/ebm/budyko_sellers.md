# Budyko–Sellers energy balance

## Model Idea

The model gives one surface temperature per latitude band, using conditions averaged over longitude and the year. Sunlight adds heat, radiation removes it, and transport smooths temperature differences between neighbouring bands.

## Symbols and Units

| Symbol | Meaning and unit |
| --- | --- |
| $`T`$ | Surface temperature, °C |
| $`t`$ | Time, s |
| $`\mu=\sin\varphi`$ | Latitude coordinate; −1 at the South Pole and 1 at the North Pole |
| $`C`$ | Heat capacity per area, J/(m² K) |
| $`Q`$ | Mean incoming sunlight, W/m² |
| $`\alpha`$ | Fraction of sunlight reflected, between 0 and 1 |
| $`A,B`$ | Radiation constants, W/m² and W/(m² K) |
| $`D`$ | Heat transport strength, W/(m² K) |

Latitude $`\varphi`$ is measured in radians. A temperature change of 1 °C equals a change of 1 K. A partial derivative measures change with one variable while the other variables stay fixed.

## Governing Equations

**P01. Heat balance**

```math
\begin{aligned}
C\frac{\partial T}{\partial t}
&=(1-\alpha)Q[1+s_2P_2(\mu)]-(A+BT)\\
&\quad+D\frac{\partial}{\partial\mu}
\left[(1-\mu^2)\frac{\partial T}{\partial\mu}\right].
\end{aligned}
```

Stored heat changes at the rate given by absorbed sunlight, radiative losses and exchange with neighbouring bands. Each term is a power per area [W/m²]. The surface warms when the sum is positive and cools when it is negative, with heat capacity setting the response rate.

The function $`P_2`$ gives the variation with latitude, and $`s_2`$ sets its strength.

```math
P_2(\mu)=\frac{3\mu^2-1}{2},\qquad Q=\frac{S_0}{4}.
```

The factor 1/4 converts the incoming solar flux $`S_0`$ intercepted by a disc to a spherical average. The latitude function gives stronger sunlight near the Equator and weaker sunlight near the poles.

**P02. Reflected sunlight**

```math
\alpha(T,\mu)=
\begin{cases}
a_i,&T\leq T_f,\\
a_0+a_2P_2(\mu),&T>T_f.
\end{cases}
```

Albedo is the fraction of incoming sunlight reflected, so 0.62 means 62% is reflected. Cells at or below the threshold $`T_f`$ use the ice value $`a_i`$, and warmer cells use the latitude-dependent value.

## Parameters and Boundaries

| Parameter | Study value |
| --- | --- |
| $`C`$ | 41,813,000 J/(m² K) |
| $`A,B,D`$ | 210 W/m²; 2 W/(m² K); 0.555 W/(m² K) |
| $`S_0,s_2`$ | 1365.2 W/m²; −0.48 |
| $`a_0,a_2,a_i`$ | 0.3; 0.078; 0.62 |
| $`T_f`$ | −10 °C |

Start with $`T(\mu,0)=12-40P_2(\mu)`$ °C. This starts at 32 °C at the Equator and −28 °C at the poles. No heat crosses either pole:

```math
D(1-\mu^2)\frac{\partial T}{\partial\mu}=0
\qquad\text{at }\mu=-1,\ 1.
```

The physics revision is 1.1. The [solver specification](budyko_sellers_specification.md) records the verified choices derived with [md2fort](../../skills/md2fort/SKILL.md).
