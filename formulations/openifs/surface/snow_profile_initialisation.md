# Snow Profile Initialisation

Revision 1. This note describes the temperature, density and mass used to start a layered snow model.

Snow temperature $`T`$ is measured in kelvin, density $`\rho`$ in kilograms per cubic metre and layer depth $`h`$ in metres. The layer mass per unit area is $`m=\rho h`$, measured in kilograms per square metre. A seasonal snow column starts with its supplied mass and liquid water in the first layer. A glacier starts with a density of 300 kilograms per cubic metre in every layer.

Three features describe the initial column. They are the differences between soil and skin temperature, between soil and snow temperature, and the ratio of snow density to a supplied reference density. The nearest calibrated profile gives a temperature and density category.

```math
\mathbf{x}=(T_{soil}-T_{skin},\ T_{soil}-T_{snow},\ \rho/\rho_{ref}), \qquad j=\operatorname*{arg\,min}_{k}\lVert\mathbf{x}-\mathbf{c}_k\rVert_2.
```

The symbols I through E are fitted coefficients with units that make each term a density. The top density is a calibrated polynomial in albedo $`a`$, mean density and snow temperature. Albedo is the fraction of incoming radiation reflected by snow and has no units.

```math
\rho_{top}=I+A a+B\rho+C T_{snow}+D\rho^2+E a^2.
```

Day or night, snow depth and terrain select the supplied coefficients and profile centres. Top and bottom boundary temperatures are capped at the melting temperature where the initialisation requires that cap. The later snow update accounts for changes in energy and water.
