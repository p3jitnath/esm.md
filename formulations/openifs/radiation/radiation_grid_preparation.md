# Radiation Inputs on the Weather Grid

Revision 1.0 describes radiation preparation for the captured coarse forecast. Each column contains atmospheric layers. Pressure uses pascals, temperature uses kelvin, and water content uses kilograms of water per kilogram of moist air.

The input stores the natural logarithm of the numerical surface pressure in pascals. The natural logarithm is the inverse of the exponential function. The symbol $`\ell_s`$ denotes this logarithm and $`p_s`$ denotes the surface pressure. Equation R1 recovers that pressure.

```math
p_s=\exp(\ell_s).
```

The index $`h`$ labels a layer boundary and $`k`$ labels a layer. Each boundary uses supplied coefficients. The fixed coefficient $`A_h`$ has units of pascals, and $`B_h`$ is a dimensionless fraction. Equation R2 combines them with the surface pressure.

```math
p_h=A_h+B_hp_s.
```

The selected vertical representation combines simple shapes called basis functions to describe a layer. Its positive integration weight $`W_k`$ and full-layer pressure $`p_{f,k}`$ use separate coefficient pairs in equation R3. Both have units of pascals. The fixed coefficients $`D_{A,k}`$ and $`A_{f,k}`$ use pascals, and the other two coefficients are dimensionless. The weight need not equal the difference between boundary pressures.

```math
W_k=D_{A,k}+D_{B,k}p_s,
\qquad p_{f,k}=A_{f,k}+B_{f,k}p_s.
```

The sunlight-angle cosine gives the projection of sunlight onto a horizontal surface. The accepted sunlight stage averages the illuminated part of the radiation interval. Other accepted children prepare the land mask, surface reflectivity, emissivity, cloud cover and equilibrium water-vapour content.

Use the complete captured atmospheric and surface state. This stage prepares radiation fields without advancing time. The selected forecast uses two time levels, no transported aerosol fields, six shortwave bands and two longwave emissivity bands. Set rain-water and rain-rate radiation fields to positive zero. [The contract](../../../skills/md2fort/references/openifs/radiation/radiation_grid_preparation.md) records the numerical method and interface.
