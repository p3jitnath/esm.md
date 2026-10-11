# Mountain Wave Wind Drag

Revision 1. Small mountains can slow the wind even when the forecast grid does not resolve them. This model combines wave stress and the drag from air flowing around mountains.

Wind components $`u`$ and $`v`$ are in metres per second. Layer pressure thickness $`\Delta p`$ is in pascals, gravity $`g`$ is in metres per second squared, and wave stress $`\tau`$ is in pascals. The stress difference gives a wind acceleration

```math
a=-g\frac{\tau_{\mathrm{lower}}-\tau_{\mathrm{upper}}}{\Delta p}.
\tag{MWD-1}
```

The mountain direction distributes this acceleration between the two horizontal wind components. Where air flows around the mountain, a nonnegative coefficient $`\beta`$, measured in inverse seconds, instead gives a drag proportional to the wind

```math
\frac{\partial u}{\partial t}=-\beta u,\qquad
\frac{\partial v}{\partial t}=-\beta v.
\tag{MWD-2}
```

Inputs are pressure, temperature, wind, geopotential, mountain height variation, orientation, shape and slope. Density and stability follow the [mountain-wave setup](mountain_wave_setup.md). The [wave stress profile](gravity_wave_stress_profile.md) supplies the stress at layer faces. Mountain height variation above 50 metres activates this scheme. The other columns receive zero drag, and the surrounding forecast provides the input state and its top and bottom pressure faces.
