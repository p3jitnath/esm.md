# Surface Initial-State Conversion

Revision 1. This formulation describes the original OpenIFS input adjustments for the selected coarse grid with five snow layers. These operations prepare an initial state, rather than advance a forecast in time. They retain the original land, sea, snow and lake rules.

The land fraction is $`m`$, with $`m\leq 0.5`$ treated as sea. At sea points, the original rule copies the first soil temperature into the remaining soil temperatures, removes soil and skin water, and removes snow. Two supplied ocean flags determine whether the skin temperature is also copied. Temperatures are in kelvin (K), and lake depths are in metres (m).

For each snow layer, let $`D_l`$ and $`W_l`$ be the water-equivalent snow mass and liquid-water mass per unit ground area, both in kg/m². Remove negative amounts, then remove all snow and liquid water when the total ice amount is not positive. Limit each snow temperature to the supplied freezing temperature $`T_f`$.

```math
D_l\leftarrow\max(0,D_l),\qquad W_l\leftarrow\max(0,W_l),\qquad T_l\leftarrow\min(T_l,T_f).
```

For low and high vegetation, multiply the supplied cover fractions by the corresponding table cover values to obtain $`c_L`$ and $`c_H`$. The table also supplies leaf area indices $`a_L`$ and $`a_H`$, which are leaf areas divided by ground area. With the supplied water-capacity scale $`W_0`$ in kg/m², limit skin water $`W_s`$ in kg/m² to the original capacity.

```math
W_{\max}=W_0(1-c_L-c_H+c_La_L+c_Ha_H),\qquad W_s\leftarrow\max(0,\min(W_{\max},W_s)).
```

Set sea ice to zero at or below its supplied minimum fraction. For lake depth $`d`$, mixed-layer depth $`h`$ and bottom temperature $`T_b`$, retain the original limits.

```math
h\leftarrow\max(0,\min(\max(2\,\mathrm{m},d),h)),\qquad T_b\leftarrow\max(273.15\,\mathrm{K},T_b).
```

A missing sea temperature becomes $`T_f`$, and missing sea ice becomes zero. When ocean currents are enabled, missing currents and currents over land become zero. The md2asm contract defines field identities, table access and ordered arithmetic. No new physical model is introduced here.
