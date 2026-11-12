# Saturation Humidity

Revision 1 describes `SATUR`. Saturation humidity is the largest amount of water vapour that air can hold in equilibrium with liquid water or ice. Temperature sets the vapour pressure, and total air pressure converts that pressure to a mass fraction.

Let $`T`$ be temperature in kelvin, $`p`$ be air pressure in pascals and $`q_s`$ be saturation specific humidity in kilograms of vapour per kilogram of moist air. Let $`e_w`$ and $`e_i`$ be saturation vapour pressures over water and ice. Equation S1 gives these two pressures.

```math
e_w(T)=e_0\exp\left(\frac{a_w(T-T_0)}{T-b_w}\right),\qquad
e_i(T)=e_0\exp\left(\frac{a_i(T-T_0)}{T-b_i}\right).
\tag{S1}
```

The liquid fraction $`\alpha`$ changes smoothly from zero at the ice threshold $`T_i`$ to one at the water threshold $`T_w`$. Equation S2 uses this fraction to blend the two pressures. The function `clamp` keeps a value within the stated limits.

```math
\alpha(T)=\min\left(1,\left[\frac{\operatorname{clamp}(T,T_i,T_w)-T_i}{T_w-T_i}\right]^2\right),\qquad
e_s(T)=\alpha e_w+(1-\alpha)e_i.
\tag{S2}
```

Let $`R_d`$ and $`R_v`$ be the gas constants of dry air and water vapour, in joules per kilogram per kelvin, and let $`\epsilon=R_d/R_v`$. Equation S3 follows the ideal-gas relation for the vapour mass fraction.

```math
q_s(T,p)=\frac{\epsilon e_s(T)}{p-(1-\epsilon)e_s(T)}.
\tag{S3}
```

| Quantity | Value |
| --- | --- |
| Reference temperature $`T_0`$ and water threshold $`T_w`$ | 273.16 K |
| Reference vapour pressure $`e_0`$ | 611.21 Pa |
| Water coefficients $`a_w,b_w`$ | 17.502, 32.19 K |
| Ice coefficients $`a_i,b_i`$ | 22.587, −0.7 K |
| Ordinary ice threshold $`T_i`$ | 250.16 K |
| Convective ice threshold $`T_i`$ | 235.16 K |
| Dry-air gas constant $`R_d`$ | 287.0596736665907 J kg⁻¹ K⁻¹ |
| Vapour gas constant $`R_v`$ | 461.5249933083879 J kg⁻¹ K⁻¹ |

Supply temperature and positive air pressure at each selected grid cell. This calculation has no time evolution or neighbour boundary condition. Cells outside the selected columns and levels keep their incoming bytes. The [md2fort contract](../../../skills/md2fort/references/openifs/physics/satur.md) fixes the supported range, pressure cap, arithmetic and interface.
