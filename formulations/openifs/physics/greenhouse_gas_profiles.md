# Greenhouse-Gas Profiles

Revision 1.0.

Greenhouse gases absorb and emit heat radiation. A supplied climatology gives their average amounts at several latitudes and pressure layers. This calculation places those gas amounts on the weather model's layers. It does not evolve the gases in time.

Let $`p`$ be pressure in pascals, increasing from the top of the atmosphere towards the ground. Let $`q`$ be gas mass divided by air mass, in kilograms per kilogram. A layer's pressure-weighted gas amount is $`M=q\Delta p`$, in pascals.

## Latitude

The latitude input is the sine of geographic latitude. Between two neighbouring climatology latitudes, use weight $`w`$ from zero to one. The amount at the model latitude is

```math
M=(1-w)M_{\mathrm{south}}+wM_{\mathrm{north}}. \tag{P01}
```

At either pole, use the nearest supplied latitude.

## Pressure Layers

Let $`C(p)`$ be the total pressure-weighted gas amount above pressure $`p`$. Add complete climatology layers, then include the fraction of the layer that contains $`p`$. Thus $`C(0)=0`$, and $`C`$ is linear inside each supplied pressure interval. The model layer between pressures $`p_{i-1}`$ and $`p_i`$ has

```math
q_i=\frac{C(p_i)-C(p_{i-1})}{p_i-p_{i-1}}. \tag{P02}
```

This preserves the gas amount between the boundaries. Below the final climatology boundary, continue the final layer's concentration.

## Supplied State And Boundaries

Supply strictly increasing climatology pressures starting at zero, at least two latitude points, and finite nonnegative amounts. Model face pressures start at zero and increase strictly towards the ground. The monthly gas fields stay fixed during this calculation. Outputs change only in selected columns.

The [md2asm contract](../../../skills/md2asm/references/openifs/physics/greenhouse_gas_interpolation.md) gives the ordered calculation and assembly interface.
