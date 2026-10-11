# Gravity-Wave Stress Profile

Revision 1. Original routine `gwprofil` in `arpifs/phys_ec/gwprofil.F90`.

Air flowing over hills can create gravity waves. These waves carry momentum upward. When a wave breaks or reaches a critical level, where the wind stops supporting its motion, the upward momentum flux decreases. This calculation forms the wave-stress profile from the ground upward.

Let $`\tau`$ be wave stress in Pa, $`\rho`$ air density in kg m$`^{-3}`$, $`N^2>0`$ the square of the buoyancy frequency in s$`^{-2}`$, and $`U>0`$ the wind component along the wave in m s$`^{-1}`$. A buoyancy frequency measures how quickly a displaced air parcel oscillates. Let $`C`$ be the positive stress factor supplied by density, wind, stability and terrain. The squared wave displacement $`D`$ has units m$`^2`$.

```math
D=\frac{\tau_{\mathrm{below}}}{C},\qquad
\alpha=\frac{\sqrt{N^2D}}{U}.
```

The dimensionless mean-flow Richardson number $`R`$ compares stable buoyancy with wind shear. The wave changes this measure to $`R_w`$. The configured positive threshold $`R_c`$ marks wave breaking.

```math
R_w=\frac{R(1-\alpha)}{(1+\alpha\sqrt{R})^2}.
```

If $`R_w<R_c`$, choose the limiting displacement that gives $`R_w=R_c`$. The new stress cannot exceed the stress below. A critical level has zero wave stress. The blocked lower layer keeps the ground stress. Between the two specified terrain levels, stress varies linearly with pressure.

Runtime input supplies the ground stress, pressure at each half level in Pa, terrain-height variation in m, positive density and stability, projected wind, and the blocking and critical levels. Its parent calculation supplies $`R\ge R_c`$ and positive stability and wind. Columns without active gravity-wave drag keep their incoming stress. The [md2asm contract](../../../skills/md2asm/references/openifs/physics/gwprofil.md) defines the numerical floor, exact update and complete storage.
