# Budyko–Sellers energy balance

## The idea

This model describes how the Earth's average surface temperature changes with latitude. Sunlight adds heat, radiation removes heat, and heat transport smooths temperature differences between neighbouring latitude bands. Conditions are averaged over longitude and the year. Each latitude band has one temperature, so the model describes broad climate patterns and the balance between incoming and outgoing energy.

## Symbols

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

## Equations

**P01. Heat balance**

```math
\begin{aligned}
C\frac{\partial T}{\partial t}
&=(1-\alpha)Q[1+s_2P_2(\mu)]-(A+BT)\\
&\quad+D\frac{\partial}{\partial\mu}
\left[(1-\mu^2)\frac{\partial T}{\partial\mu}\right].
\end{aligned}
```

The left side is stored heat changing with time. The three terms on the right are absorbed sunlight, heat lost through radiation, and heat received from neighbouring latitude bands. Each term is a power per area, measured in W/m². When their sum is positive, the surface warms; when it is negative, the surface cools. The heat capacity sets how quickly the temperature responds.

The function $`P_2`$ gives a simple variation with latitude, and $`s_2`$ sets its strength:

```math
P_2(\mu)=\frac{3\mu^2-1}{2},\qquad Q=\frac{S_0}{4}.
```

Here $`S_0`$ is the incoming solar flux. The factor 1/4 converts sunlight intercepted by a disc to an average over a sphere. The latitude function makes the average sunlight stronger near the Equator and weaker near the poles.

**P02. Reflected sunlight**

```math
\alpha(T,\mu)=
\begin{cases}
a_i,&T\leq T_f,\\
a_0+a_2P_2(\mu),&T>T_f.
\end{cases}
```

Cold cells use the ice value $`a_i`$. Warmer cells use the latitude-dependent value. This reflected fraction is called albedo: a value of 0.62 means that 62% of the incoming sunlight is reflected. The threshold $`T_f`$ is the temperature at which the ice rule applies.

## Parameters, initial state, and boundaries

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

Physics revision: 1.1. [md2asm](../skills/md2asm/SKILL.md) derives the numerical method and implementation; its [solver contract](../skills/md2asm/references/budyko_sellers.md) preserves the verified choices and equation IDs.
