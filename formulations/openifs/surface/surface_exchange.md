# Surface Exchange

Revision 1. Wind moves momentum, heat and water between the surface and the lowest atmosphere layer. Stable air reduces this mixing, while surface heating increases it.

Let $`U`$ be wind speed relative to the surface in metres per second, $`\rho`$ air density in kilograms per cubic metre and $`\kappa`$ the dimensionless von Kármán constant. Let $`M`$, $`H`$, $`Q`$ and $`C`$ describe the dimensionless wind, temperature, moisture and tracer profiles. A tracer is a substance carried by the air.

```math
c_m=\frac{\rho U\kappa^2}{M^2},\qquad
c_h=\frac{\rho U\kappa^2}{MH},\qquad
c_q=\frac{\rho U\kappa^2}{MQ}.
```

These coefficients give momentum, heat and water transfer in kilograms per square metre per second. Heat and tracer transfer without density have units of metres per second.

```math
k_h=\frac{c_h}{\rho},\qquad
k_c=\frac{U\kappa^2}{MC}.
```

Each profile combines a logarithmic height ratio with a stability correction $`\psi`$. Here $`z`$ is height in metres, $`z_0`$ a roughness length in metres and $`L`$ the Obukhov length in metres. The ratio $`z/L`$ describes atmospheric stability.

```math
M=\ln\!\left(\frac{z}{z_{0m}}\right)-\psi_m(z/L)+\psi_m(z_{0m}/L).
```

Heat, water and tracer profiles use their corresponding roughness lengths and corrections. The retained OpenIFS parameter set supplies the empirical stable and unstable functions, $`\kappa`$, a minimum squared wind speed and the height used for convective mixing.

The inputs are the current surface state and the lowest atmosphere layer. Pressure is in pascals, temperature in kelvins, humidity in kilograms per kilogram, wind in metres per second and geopotential in square metres per square second. Each column is independent. The [md2fort contract](../../../skills/md2fort/references/openifs/surface/vexcs.md) specifies the numerical method, complete iteration and verification limits.
