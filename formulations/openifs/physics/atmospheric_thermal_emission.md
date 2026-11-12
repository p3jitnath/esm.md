# Atmospheric Thermal Emission

A warm layer emits longwave radiation. Its emitted energy increases with temperature. The original OpenIFS tables divide that energy into sixteen ranges of wavelength, called bands. A gas model supplies a fraction for each sample within a band.

Let $`T`$ be temperature in kelvin, $`F_b(T)`$ the blackbody energy flux in band $`b`$ in watts per square metre, and $`p_g`$ the dimensionless fraction for spectral sample $`g`$. Its emitted flux is

```math
F_g(T)=p_gF_{b(g)}(T).
```

Here $`b(g)`$ selects the band of sample $`g`$. When the sample fractions in a band sum to one, their emitted fluxes sum to the band's flux. Across the spectrum, blackbody emission follows the approximate relation $`F(T)=\sigma T^4`$, where $`\sigma`$ is the Stefan–Boltzmann constant in watts per square metre per kelvin to the fourth power.

Use the supplied temperatures at the boundaries between model layers and the supplied gas fractions. Temperatures are finite and nonnegative. The radiation tables and their original spectral ranges remain unchanged. The [solver contract](../../../skills/md2fort/references/openifs/physics/planck_function_atmos.md) explains the original temperature interpolation and storage.
