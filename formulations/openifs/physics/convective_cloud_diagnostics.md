# Convective Cloud Diagnostics

Revision 1.0 describes CUCCDIA, which supplies cloud position and rain information to the radiation calculation. Convection is the upward movement of warm, moist air. This diagnostic rule estimates the water carried out of a rising air column rather than solving the cloud's full life cycle.

Let $`q_b`$ and $`q_t`$ be the water-vapour mass fractions at the cloud base and top, in kg/kg. Let $`l_b`$ be the liquid-water mass fraction at the base, in kg/kg. The upward air-mass flux $`m`$ has units kg/(m² s), and the supplied rain flux $`R`$ has the same units.

```math
\tag{CCD-1}
F = \max\left[m\max\left(q_b+l_b-q_t,\;0.05q_b\right),\;R\right].
```

The inner maximum retains at least five percent of the base vapour as the diagnosed transported water. The outer maximum keeps the supplied rain flux when it is larger. This is an empirical diagnostic rule, so the five-percent value is a model parameter.

Let $`P`$ be the stored rain diagnostic and $`n`$ the number of time steps between full radiation calculations. Between those calculations, accumulate the contribution with $`w=1/\max(n-1,1)`$.

```math
\tag{CCD-2}
P_{\mathrm{new}}=P+wF.
```

At a fresh diagnostic interval, set $`P_{\mathrm{new}}=F`$. Retain the lowest cloud base and highest cloud top reached during an accumulation interval. Levels are numbered downward from one, so a larger base index means a lower base. Only columns marked as convective are changed. The existing state, time-step index and radiation frequency select the update, and columns outside the selected range keep their values.
