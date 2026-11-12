# Cloud Saturation Adjustment

Revision 1. Rising air cools and can form cloud. Warming air can evaporate cloud water. Radiation, vertical motion, turbulent mixing and convective transport change temperature or humidity, so this model adjusts cloud water and cloud cover after those changes.

Let $`q,L,I`$ be the masses of vapour, cloud liquid and cloud ice per kilogram of air. Let $`T`$ be temperature in kelvin and $`a\in[0,1]`$ be cloud fraction. A dot means change per second. Water transfer and latent heating obey

```math
\dot q+\dot L+\dot I=0,\qquad c_p\dot T=L_w\dot L+L_i\dot I. \tag{SATADJ-01}
```

The heat capacity $`c_p`$ has units J kg$`^{-1}`$ K$`^{-1}`$. The latent heats $`L_w,L_i`$ have units J kg$`^{-1}`$. These equations preserve water and connect phase changes to heating or cooling. The amount that can evaporate is limited by the available cloud liquid and ice.

| Parameter | Value |
| --- | --- |
| Liquid latent heat $`L_w`$ | 2,500,800 J kg$`^{-1}`$ |
| Ice latent heat $`L_i`$ | 2,834,500 J kg$`^{-1}`$ |
| Heat capacity $`c_p`$ | 1,004.7088578330674 J kg$`^{-1}`$ K$`^{-1}`$ |
| Homogeneous-freezing threshold | 235.16000000000003 K |
| Gravity | 9.80665 m s$`^{-2}`$ |

Each cell supplies its initial temperature, water amounts and cloud fraction, plus existing changes from other processes. Its layer pressures describe the vertical grid. New condensate is liquid above the freezing threshold and ice below it. Existing cloud evaporation retains its liquid and ice proportions. The caller supplies forcing and boundaries, and no transport between cells occurs in this adjustment itself.

The [md2fort contract](../../../skills/md2fort/references/openifs/physics/cloud_satadj.md) records the complete numerical update, diagnostic budgets and verified child calculations.
