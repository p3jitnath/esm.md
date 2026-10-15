# Surface Field Unit Scaling

Revision 1 preserves the original model's initial surface units. The input contains soil, snow, vegetation, sea and lake fields on 2,048 grid points. This stage changes units before later surface bounds and physical adjustments.

For the model's height-based roughness and orography fields, multiply height $`z`$ in metres by gravitational acceleration $`g`$ in m/s² to obtain the stored geopotential value.

```math
z_{model}=g z. \tag{SUC1}
```

For selected water-depth fields, multiply depth $`d`$ in metres by liquid-water density $`\rho`$ in kg/m³ to obtain mass per ground area in kg/m².

```math
m_{water}=\rho d. \tag{SUC2}
```

The exact selected fields follow the original parameter codes. Fields already in model units retain the original multiplication by one. The legacy single-layer snow code has a different prescribed factor from the multilayer snow code. This note changes no source physics, initial values or field bounds.
