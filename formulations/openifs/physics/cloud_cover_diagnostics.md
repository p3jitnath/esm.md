# Cloud Cover Diagnostics

Revision 1. The inputs are each layer's cloud fraction $`f`$, liquid-water mass fraction $`q_l`$ and ice mass fraction $`q_i`$. The two mass fractions have units kg/kg. Pressure is in Pa, temperature is in K and latitude is in radians. The output gives the cloudy fraction of the whole column and of its high, middle and low parts.

Nearby clouds tend to overlap. Let $`\Delta z`$ be the distance between two layer centres in km, and let $`L`$ be a positive distance in km that controls how rapidly their overlap decreases.

```math
\alpha=\exp(-\Delta z/L).
```

For two layers with cloud fractions $`f`$ and $`g`$, their shared cloudy area is the mixture below. A weight of one gives maximum overlap, while zero gives independent clouds.

```math
s=\alpha\min(f,g)+(1-\alpha)fg,
\qquad
u=f+g-s.
```

Here $`s`$ is the shared fraction and $`u`$ is the fraction covered by either cloud. Apply the same probability model through the column.

| Parameter | Value or input |
| --- | --- |
| High-cloud pressure boundary | 0.45 times surface pressure |
| Low-cloud pressure boundary | 0.8 times surface pressure |
| Constant overlap distance | 2 km |
| Cloud cutoff | $`10^{-9}`$ |
| Pressure, temperature and water | Supplied forecast profiles |
| Column boundaries | Top pressure and surface pressure |

The distance can instead depend on latitude. With latitude $`\phi`$ in radians and $`\phi_d`$ in degrees, the two alternatives are $`L=2.899-0.02759\lvert\phi_d\rvert`$ and $`L=0.75+2.149\cos^2\phi`$, both in km.

The forecast supplies the initial layer states. Bound the cloud fraction used by radiation between the cutoff and one minus the cutoff. Keep liquid and ice where the bounded fraction exceeds the cutoff. Otherwise, set their radiation inputs to zero. This is a small-cloud filter, so it can discard condensate from those radiation inputs.
