# Convective Initial State

Formulation revision 1 describes the air state used to begin rising and sinking convection. The numerical contract is [CUININ](../../../skills/md2fort/references/openifs/physics/cuinin.md).

## Physical Idea

The atmosphere is divided into layers. A half level is a face between two layers. Convection needs temperature, humidity and wind at these faces before it can calculate how air rises or sinks.

Dry static energy $`s`$ combines heat and gravitational potential energy. In equation I1, $`c_p`$ is the heat capacity of dry air in joules per kilogram per kelvin, $`T`$ is temperature in kelvin and $`\Phi`$ is geopotential in joules per kilogram.

```math
s=c_pT+\Phi. \tag{I1}
```

## Basic Mathematics

The half-level state uses the greater dry static energy from its two neighbouring layers. Equation I2 converts that energy back to a temperature. Subscript $`h`$ marks the half level.

```math
T_h=\frac{\max(s_{j-1},s_j)-\Phi_h}{c_p}. \tag{I2}
```

At selected interior faces, condensation or evaporation brings the supplied saturation humidity towards the value at the adjusted temperature. If $`\delta q`$ is the condensed mass fraction and $`L`$ is latent heat in joules per kilogram, equation I3 describes the coupled heat and water changes. Positive condensation warms the air and reduces its water vapour. Negative condensation represents evaporation.

```math
\Delta T=\frac{L(T)}{c_p}\delta q,\qquad \Delta q=-\delta q. \tag{I3}
```

The liquid and ice mixture for $`L(T)`$ is given by H3 in [Convective Heat and Moisture](convective_heat_moisture.md). The adjusted environmental humidity cannot be negative.

## Parameters and Initial State

Use the source-defined dry-air heat capacity, about 1005 J kg⁻¹ K⁻¹, and the liquid and ice latent heats from H3. The caller supplies layer temperature, humidity, saturation humidity, wind, geopotential and positive face pressure. Temperature uses kelvin, humidity uses kilograms of water vapour per kilogram of moist air, wind uses metres per second, pressure uses pascals and geopotential uses square metres per square second.

The initial face saturation array is supplied by the caller. The numerical contract records the saturation formula and the two coupled adjustments. Rising and sinking air start with the same face temperature and humidity. Their liquid-water content starts at zero.

## Boundaries

The upper boundary copies the first layer's temperature and humidity. The lower boundary uses the last layer's dry static energy and supplied face geopotential, and copies the last layer's humidity. Each plume's wind starts from the preceding layer, with the first layer used at the upper boundary. Columns outside the selected interval retain their input bytes.
