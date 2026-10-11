# Soil Heat Capacity

Revision 1. Heat capacity tells us how much energy is needed to warm a material. Soil needs extra energy while its water melts, so its apparent heat capacity includes both ordinary warming and the phase change.

Let $`T`$ be temperature in kelvin, $`C_0`$ be ordinary volumetric heat capacity in joules per cubic metre per kelvin, $`L`$ be the latent heat of melting in joules per kilogram, $`\rho_w`$ be water density in kilograms per cubic metre and $`w`$ be the estimated volume fraction of soil water. With the frozen-water fraction $`f(T)`$, apparent heat capacity is

```math
C(T)=C_0-L\rho_w w\frac{df}{dT}.
\tag{SHC-1}
```

In the melting interval, the frozen fraction decreases smoothly

```math
f(T)=\frac{1-\sin(a(T-T_m))}{2},\qquad
a=\frac{\pi}{T_h-T_l}.
\tag{SHC-2}
```

Use $`T_l=270.16`$ kelvin, $`T_h=274.16`$ kelvin and $`T_m=272.16`$ kelvin. Outside this interval, the phase contribution is zero. Typical constants are $`L=333700`$ joules per kilogram and $`\rho_w=1000`$ kilograms per cubic metre.

Inputs are soil temperature, vegetation cover, soil type, water-holding capacity and ordinary material heat capacity. Urban cover mixes the top-layer soil and urban capacities. A sea-ice column uses its material capacity in the top layer, while ocean columns have zero soil capacity. The surrounding surface model supplies the initial temperatures and uses these capacities in its heat balance.
