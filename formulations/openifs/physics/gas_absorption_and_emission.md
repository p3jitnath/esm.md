# Gas Absorption and Thermal Emission

Revision 1.

Gas molecules absorb radiation at different wavelengths. Water vapour, carbon dioxide and ozone are important examples. A spectral sample represents a small part of the wavelength range. The optical depth $`\tau`$ measures how strongly a layer blocks radiation. It has no units.

```math
I_\mathrm{out}=I_\mathrm{in}\exp(-\tau).
```

Here $`I_\mathrm{in}`$ and $`I_\mathrm{out}`$ are incoming and transmitted radiation in watts per square metre. A large optical depth means less transmission. Gas amount, pressure and temperature determine optical depth through the model's fixed absorption tables.

The model stores pressure and temperature at layer boundaries. Their layer values are the mean of the two adjacent boundaries.

```math
p_\mathrm{layer}=\frac{p_\mathrm{top}+p_\mathrm{bottom}}{2},
\qquad
T_\mathrm{layer}=\frac{T_\mathrm{top}+T_\mathrm{bottom}}{2}.
```

Pressure is in pascals and temperature is in kelvin. Gas inputs are mass fractions in kilograms of gas per kilogram of air. All columns use the same layer boundaries.

A surface emits thermal radiation. Its albedo $`a`$ is the fraction it reflects, so its emitted part is proportional to $`1-a`$.

```math
F_\mathrm{surface}=(1-a)F_\mathrm{blackbody}.
```

A blackbody is an ideal surface that absorbs all incoming radiation. Each thermal spectral sample receives its share of the blackbody flux. The atmospheric boundaries also emit radiation at their local temperatures.

Sun's radiation enters from the top. A supplied solar irradiance sets the total incoming shortwave flux. A column below the horizon has no incoming sunlight. The model returns optical depth, the fraction of shortwave extinction caused by scattering, and optional emitted or incoming fluxes.
