# Heat exchange with the surface skin

Revision 1 describes the complete OpenIFS VLAMSK model. The surface skin is a thin layer that exchanges heat with the snow, soil, water or vegetation below it. A conductance measures how easily that heat moves.

| Symbol | Meaning and unit |
| --- | --- |
| λ | Surface conductance, W per square metre per kelvin |
| T_s, T_b | Skin and underlying temperatures, K |
| Δt | Time interval, s |
| m, ρ, h | Snow mass per area, kg per square metre; density, kg per cubic metre; and depth, m |
| k | Thermal conductivity, W per metre per kelvin |
| C | Snow heat capacity per area, J per square metre per kelvin |
| w, φ, f | Soil water fraction, pore fraction and frozen fraction, dimensionless |

**P01. Heat transfer**

```math
H=\lambda(T_s-T_b).
```

Each surface type starts with its original lookup value. Water uses 20 W per square metre per kelvin. Snow uses 7, deep glacier snow uses 8, and melting snow uses 50 W per square metre per kelvin. Some coupled water surfaces use a large value of 10¹⁰ W per square metre per kelvin to keep their temperatures close.

**P02. Forest snow response**

```math
h=\frac{m}{\rho},\qquad C=\max(h_{\min},h)c_v\frac{\rho}{\rho_i},\qquad
\lambda_{\mathrm{forest}}=\frac{\lambda_0}{1+\Delta t\,\lambda_0/C}.
```

Here h_min is the roughness depth, c_v is the volumetric heat capacity and ρ_i is ice density. This rule reduces heat exchange when the snow layer has little stored heat.

**P03. Optional snow conductivity**

```math
k_s=2.5\,10^{-6}\rho^2-1.23\,10^{-4}\rho+0.024,\qquad
\lambda_s=\frac{2k_s}{\max(0.01,h)}.
```

**P04. Optional soil conductivity**

```math
f=
\begin{cases}
1,&T_b\le T_-,\\
[1-\sin(a(T_b-T_m))]/2,&T_-<T_b<T_+,\\
0,&T_b\ge T_+,
\end{cases}
\qquad
E=b\log_{10}[\max(e_0,w/\phi)]+c,
```

```math
k_{\mathrm{sat}}=k_0 k_i^{\phi f}k_w^{\phi(1-f)},\qquad
k_{\mathrm{soil}}=\max[0.19,\min(2,k_d+E(k_{\mathrm{sat}}-k_d))],\qquad
\lambda_{\mathrm{soil}}=\frac{2k_{\mathrm{soil}}}{d}.
```

The temperatures T_- and T_+ mark the freezing interval, T_m is its midpoint and a=π/(T_+−T_-). The original defaults use T_-=270.16 K, T_+=274.16 K, e_0=0.1, b=c=1, k_i=2.2 and k_w=0.57 W per metre per kelvin. The powers use the numerical conductivities relative to 1 W per metre per kelvin, so their bases are dimensionless. The dry conductivity k_d, saturation coefficient k_0, porosity φ and first-layer depth d depend on the soil type. The coefficient k_0 supplies the final conductivity unit.

The routine calculates conductance independently at each selected column. It receives the current temperatures, snow and soil state; it does not advance those fields or impose a spatial boundary condition. The [solver contract](../../../skills/md2asm/references/openifs/surface/vlamsk.md) gives the arithmetic, buffer limits and verification.
