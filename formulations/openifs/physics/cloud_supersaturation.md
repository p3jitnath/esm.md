# Cloud Supersaturation Adjustment

Revision 1. Supersaturation means that air contains more water vapour than its saturation limit. This model turns excess vapour into cloud water and releases heat. A grid cell can contain cloudy air and clear air, so its limit depends on the cloud fraction.

Let $`T`$ be temperature in kelvin, $`q`$ the mass of vapour per kilogram of air, $`a`$ the cloud fraction and $`p`$ pressure in pascals. Let $`c\ge0`$ be the condensed water per kilogram of air, $`\alpha\in[0,1]`$ its liquid fraction, and $`L_w,L_i`$ the latent heats of liquid and ice formation in J kg$`^{-1}`$. The heat capacity $`c_p`$ has units J kg$`^{-1}`$ K$`^{-1}`$. The water and heat changes satisfy

```math
\Delta q=-c,\qquad \Delta q_w=\alpha c,\qquad \Delta q_i=(1-\alpha)c, \tag{CLOUD-01}
```

```math
c_p\Delta T=L_w\Delta q_w+L_i\Delta q_i. \tag{CLOUD-02}
```

These equations preserve water and turn the released heat into a temperature rise. A smooth liquid fraction changes from zero at 250.16 K to one at 273.16 K. Cloudy air uses this mixed-phase saturation limit. Clear air allows a larger ice supersaturation limit, and condensation can increase the cloud fraction.

| Parameter | Value |
| --- | --- |
| Water latent heat $`L_w`$ | 2,500,800 J kg$`^{-1}`$ |
| Ice latent heat $`L_i`$ | 2,834,500 J kg$`^{-1}`$ |
| Heat capacity $`c_p`$ | 1,004.7088578330674 J kg$`^{-1}`$ K$`^{-1}`$ |
| Homogeneous-freezing threshold | 235.16000000000003 K |
| Actual cloud relaxation fraction | 1/10,800 per call |

In the mixed-phase mode, the routine returns both the water and heat changes. In the threshold mode, the cloud caller chooses liquid above the freezing threshold and ice below it, then computes its corresponding heat change. The routine's returned mixed-phase temperature is a diagnostic in that route.

Inputs are individual cell states, and no spatial boundary is needed. A negative temporary humidity must produce no condensation. The [md2fort contract](../../../skills/md2fort/references/openifs/physics/cloud_supersatcheck.md) defines the saturation laws, complete rounded calculation, admitted activity and caller responsibilities.
