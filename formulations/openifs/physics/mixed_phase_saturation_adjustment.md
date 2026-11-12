# Mixed-Phase Saturation Adjustment

Revision 1. Air can hold different amounts of water vapour at different temperatures. This calculation estimates a new vapour amount while accounting for the heat released by condensation or absorbed by evaporation.

Let $`T`$ be temperature in kelvin and $`q`$ the mass of vapour per kilogram of air. Let $`q_s(T,p)`$ be saturation humidity at pressure $`p`$ in pascals. Let $`c`$ be the transferred water per kilogram of air. Positive $`c`$ describes condensation, and negative $`c`$ describes evaporation. The updates are

```math
q'=q-c,\qquad c_p(T'-T)=L(T)c. \tag{QSATMIX-01}
```

The heat capacity $`c_p`$ has units J kg$`^{-1}`$ K$`^{-1}`$, and the mixed latent heat $`L(T)`$ has units J kg$`^{-1}`$. A smooth liquid fraction changes from zero at 250.16 K to one at 273.16 K. It blends the liquid and ice saturation laws and their latent heats.

| Parameter | Value |
| --- | --- |
| Liquid latent heat | 2,500,800 J kg$`^{-1}`$ |
| Ice latent heat | 2,834,500 J kg$`^{-1}`$ |
| Heat capacity | 1,004.7088578330674 J kg$`^{-1}`$ K$`^{-1}`$ |

The input is one trial cell state, with no spatial boundary. The cloud caller uses this estimate to choose condensation or evaporation, then limits actual evaporation by the available cloud water. The [md2fort contract](../../../skills/md2fort/references/openifs/physics/qsatmixadj.md) defines the complete two-iteration calculation and its supported numerical domain.
