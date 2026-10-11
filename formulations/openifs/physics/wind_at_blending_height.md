# Wind at the Blending Height

Revision 1. A blending height is the height where the surface model reads the atmospheric wind before it computes the wind nearer the ground. Between two atmospheric levels, this model uses a straight line for each wind component. It subtracts the surface current so that the result describes air motion relative to the moving surface.

Let $`z_b`$ be the blending height in m and $`g`$ be gravity in m/s². Geopotential $`\Phi`$ is gravitational energy per unit mass, in m²/s², and the blending geopotential is $`\Phi_b=gz_b`$. The upper and lower levels have geopotentials $`\Phi_u>\Phi_l`$ and wind vectors $`\boldsymbol U_u`$ and $`\boldsymbol U_l`$, in m/s. The weight of the upper level is

```math
w=\frac{\Phi_b-\Phi_l}{\Phi_u-\Phi_l},\qquad
\boldsymbol U_b=w\boldsymbol U_u+(1-w)\boldsymbol U_l. \tag{BLW-1}
```

Let $`\boldsymbol C`$ be the surface-current vector in m/s. The relative wind speed is

```math
F_b=\sqrt{(U_b-C_u)^2+(V_b-C_v)^2}. \tag{BLW-2}
```

Below the lowest atmospheric level, the model uses that level's wind. The supplied blending height must remain below the highest level. Atmospheric levels, winds, gravity, surface currents and selected columns come from the caller; this diagnostic has no time update and does not change those inputs.
