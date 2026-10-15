# Lake Temperature Profile

Formulation revision 1 records the retained physical profile used by FLAKE_DRIVER and FLAKEENE. A lake model stores a mixed upper layer and a deeper temperature profile. Heat exchange and sunlight change the mean water temperature, while ice and mixing change the profile.

Let $`D`$ be lake depth and $`h`$ mixed-layer depth, both in metres. Mixed, mean and bottom water temperatures $`T_m,T_{\mathrm{mean}},T_b`$ use kelvin. The profile shape $`C`$ has no unit. Equation LTP-P01 gives the mean temperature of that profile.

```math
T_{\mathrm{mean}}=\left[1-C\left(1-\frac{h}{D}\right)\right]T_m+C\left(1-\frac{h}{D}\right)T_b\qquad\text{(LTP-P01)}
```

The forecast supplies depth, previous states, optical coefficients and the time interval. Heat flux uses watts per square metre, evaporation uses kilograms per square metre per second and wind stress uses newtons per square metre. Existing [lake radiation](lake_radiation.md) and ice boundaries remain unchanged. The [md2asm contract](../../../skills/md2asm/references/openifs/surface/lake_temperature_profile.md) records the stock update and its known temperature-profile limitation.
