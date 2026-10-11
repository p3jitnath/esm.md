# Diagnostic Boundary-Layer Height

Revision 1 describes `VDFDPBL`. The atmospheric boundary layer is the lowest part of the atmosphere, where the surface strongly affects the air. A Richardson number compares the stabilising effect of warm air above cooler air with the mixing effect of wind.

Let $`\Phi`$ be geopotential in square metres per square second, $`T`$ temperature in kelvin, $`q`$ specific humidity in kilograms per kilogram, and $`u,v`$ the wind components in metres per second. Let $`c_p`$ be the specific heat of dry air in joules per kilogram per kelvin and $`\eta`$ the dimensionless humidity correction. Equation B1 gives the virtual dry static energy $`S`$ in joules per kilogram, which includes the effect of water vapour.

```math
S=c_pT(1+\eta q)+\Phi.
\tag{B1}
```

Use the lowest model level as the reference, marked by $`b`$. Equation B2 gives the bulk Richardson number $`R`$, a dimensionless measure of stability.

```math
R=\frac{(\Phi-\Phi_b)(S-S_b-\epsilon)}
         {(S-\Phi)\max(w_{\min}^2,u^2+v^2)}.
\tag{B2}
```

Set $`\epsilon=10^{-10}`$ joules per kilogram, $`w_{\min}=0.1`$ metres per second and the critical Richardson number to $`R_c=0.25`$. Scan upwards from the lowest level. At the first pair of levels where $`R`$ rises above $`R_c`$, interpolate between their geopotential heights $`\Phi/g`$, where $`g`$ is gravitational acceleration in metres per square second.

If no crossing occurs, return the prescribed height $`1000/r_p`$ metres, where $`r_p`$ is a positive dimensionless planet factor. Supply positive temperatures, admissible humidity and geopotential that increases upwards. Apply the diagnostic to selected columns, preserving other output cells. No neighbour boundary condition is needed. The [md2asm contract](../../../skills/md2asm/references/openifs/physics/vdfdpbl.md) fixes the ordered calculations and interface.
