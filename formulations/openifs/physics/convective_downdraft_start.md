# Convective Downdraft Initial State

Formulation revision 1 describes the height where a rain-cooled mixture can begin to sink. The numerical contract is [CUDLFSN](../../../skills/md2fort/references/openifs/physics/cudlfsn.md).

## Physical Idea

A convective cloud contains rising air. Rain can evaporate into surrounding air and cool it. A mixture of this cooled air and cloud air can be colder and denser than its surroundings, so it can form a downdraft.

Let $`T`$ be temperature in kelvin, $`q`$ be specific humidity in kilograms per kilogram and $`\Phi`$ be gravitational potential energy per unit mass in joules per kilogram. Heat capacity $`c_p`$ has units of joules per kilogram per kelvin. Latent heat $`L(T)`$ has units of joules per kilogram and changes with the liquid and ice fractions.

## Basic Mathematics

Equation D1 estimates the energy of saturated air. The routine finds its lowest value in the interior model levels before looking for sinking air. Here $`q_s`$ is saturation humidity.

```math
h_s=c_pT+\Phi+L(T)q_s. \tag{D1}
```

Evaporation adjusts environmental air towards saturation through [Convective Saturation Adjustment](convective_saturation_adjustment.md). Equation D2 then mixes equal masses of adjusted environment and cloud air.

```math
T_m=\frac{T_{\mathrm{cloud}}+T_{\mathrm{wet}}}{2},\qquad q_m=\frac{q_{\mathrm{cloud}}+q_{\mathrm{wet}}}{2}. \tag{D2}
```

The mixture can sink when its virtual temperature $`T_m(1+r q_m)`$ is lower than that of the original environment. The dimensionless constant $`r`$ is the ratio of water-vapour and dry-air gas constants minus one. Available rain must also exceed the source-defined evaporation threshold.

## Parameters and Supplied State

The caller supplies environmental and cloud temperature, humidity, pressure, gravitational potential, cloud top and base levels, rain flux and cloud-base upward mass flux. The source parameter $`\epsilon`$ sets the downward mass flux to $`M_d=-\epsilon M_u`$, in kilograms per square metre per second.

The accepted branch uses the convective liquid–ice transition from 235.16 K to 273.16 K. Liquid and ice latent heats are 2 500 800 and 2 834 500 J kg⁻¹. Dry-air heat capacity is source-defined, about 1005 J kg⁻¹ K⁻¹. The enabled-downdraft flag and mass-flux fraction are supplied by the source configuration.

## Boundaries

The search excludes the top two and bottom two model levels. Starting states are written only at the first accepted level of each selected column. A disabled or unsuccessful column keeps its supplied flux and state arrays, while its downdraft flag is false and its top index is one beyond the model bottom. Normal physics is supported, with the tangent-linear flag false.
