# Convective Saturation Adjustment

Formulation revision 1 describes heat and water changes when an air parcel condenses or evaporates water. The numerical contract is [CUADJTQ](../../../skills/md2fort/references/openifs/physics/cuadjtq.md).

## Physical Idea

Saturation humidity is the water-vapour mass fraction at which air can hold no more vapour at a given temperature and pressure. Condensation removes excess vapour and releases heat. Evaporation adds vapour and uses heat. The rising-air, sinking-air and environmental cases use different limits on these changes.

Let $`T`$ be temperature in kelvin, $`q`$ be specific humidity in kilograms per kilogram and $`p`$ be pressure in pascals. The saturation vapour pressure $`e(T)`$ is measured in pascals. Its empirical liquid and ice expressions use the source-defined thermodynamic parameters. The liquid fraction is a bounded quadratic transition, as in H3 of [Convective Heat and Moisture](convective_heat_moisture.md).

## Basic Mathematics

Equation A1 converts saturation vapour pressure to specific humidity. The constant $`r`$ is the source-defined ratio of water-vapour and dry-air gas constants minus one. The saturation pressure ratio $`z`$ is capped at one half by the model.

```math
z=\min\left(\frac12,\frac{e(T)}{p}\right),\qquad q_s=\frac{z}{1-rz}. \tag{A1}
```

If $`\delta q`$ is the condensed mass fraction, equation A2 gives the coupled change. Here $`L(T)`$ is latent heat in joules per kilogram and $`c_p`$ is heat capacity in joules per kilogram per kelvin.

```math
\Delta T=\frac{L(T)}{c_p}\delta q,\qquad \Delta q=-\delta q. \tag{A2}
```

Positive condensation warms the air. A negative value represents evaporation and cools it. The numerical contract records the two corrections used to approach saturation while preserving this heat and water relationship.

## Parameters and Supplied State

Liquid latent heat is 2 500 800 J kg⁻¹ and ice latent heat is 2 834 500 J kg⁻¹. Dry-air heat capacity is source-defined, about 1005 J kg⁻¹ K⁻¹. The liquid endpoint is 273.16 K. The ice endpoint is 250.16 K for the standard environment and 235.16 K for convection. A liquid-only option uses the liquid endpoint expression at every supplied temperature.

The caller supplies pressure, temperature, humidity, a selected level and column flags. Rising-air adjustment permits condensation. Sinking-air adjustment permits evaporation at its first correction. Environment adjustment permits either direction. The source-defined second correction and optional liquid-only selection remain in the numerical contract.

## Boundaries

This routine changes only one selected level in the chosen columns. Modes that use column flags leave false columns unchanged. Other modes process every selected column. The remaining levels and all input flags retain their bytes. The accepted domain is normal physics with the tangent-linear flag false.
