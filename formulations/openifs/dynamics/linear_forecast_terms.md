# Linear Forecast Terms

Revision 1.0 describes the physical input for OpenIFS LASSIE. Fast pressure and rotation effects act on moving air. The model prepares these effects at the current time and, when needed, the previous time.

## Basic Mathematics

Velocity components u and v have units m s⁻¹. Potential Φ is pressure energy per unit mass, in m² s⁻². The Coriolis parameter f has units s⁻¹ and describes Earth's rotation. Coordinates x and y have units m.

```math
\tag{LF-1}
\frac{\partial u}{\partial t}=-\frac{\partial\Phi}{\partial x}+fv,
\qquad
\frac{\partial v}{\partial t}=-\frac{\partial\Phi}{\partial y}-fu.
```

Divergence D measures horizontal expansion and has units s⁻¹. Vertical pressure balance turns D into a temperature rate and a rate of change in logarithmic surface pressure. The accepted pressure and divergence operators define these linear relations.

The moist-air gas constant R has units J kg⁻¹ K⁻¹. Rd is its dry-air value. When the stored temperature variable is RT/Rd, the model applies the corresponding gas-constant factor to its temperature term.

## Inputs And Boundaries

Supply current and previous velocities, divergence, temperature gradients and logarithmic pressure gradients. Also supply the reference vertical profile, the local Coriolis parameter and water mass fractions in kg kg⁻¹. The selected time scheme determines which previous fields are used.

Keep all output cells outside the selected columns unchanged. The [md2fort contract](../../../skills/md2fort/references/openifs/dynamics/lassie.md) defines the complete calls, arithmetic and storage. This routine prepares linear terms and does not advance the forecast by itself.
