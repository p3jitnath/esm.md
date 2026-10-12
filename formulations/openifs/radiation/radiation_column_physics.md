# Radiation Through An Atmospheric Column

This model calculates how sunlight and thermal radiation move through a column of air. Gas, clouds and aerosol particles absorb and scatter radiation. Aerosols are small particles in air. The surface emits thermal radiation and reflects part of the downward radiation.

Optical depth $`\tau`$ is a dimensionless measure of how much material blocks radiation. For one clear or cloudy sample, the optical depths add. The cloud term is zero in a clear sample.

```math
\tau=\tau_{\mathrm{gas}}+\tau_{\mathrm{aerosol}}+\tau_{\mathrm{cloud}}.
\tag{P01}
```

Let $`F_{g,k}`$ be flux at spectral point $`g`$ and atmospheric boundary $`k`$, in W m$`^{-2}`$. A spectral point represents one weighted part of the spectrum. The total flux is the sum of its spectral contributions. A band contains a group of spectral points.

```math
F_k=\sum_g F_{g,k},
\qquad
F_{b,k}=\sum_{g\in b}F_{g,k}.
\tag{P02}
```

The supplied state contains boundary pressure in Pa, temperature in K, gas and aerosol mass fractions in kg kg$`^{-1}`$, cloud fraction, particle radius in m, surface temperature, albedo and emissivity. Albedo is the reflected fraction. Emissivity is the emitted fraction of black-body radiation. Both lie between zero and one. Cloud optical properties and clear or cloudy transport follow their verified physical models.

No downward thermal radiation enters at the top. Sunlight enters at the top according to the solar irradiance and the cosine of the solar angle. The surface provides thermal emission and reflected sunlight. This is an instantaneous radiation calculation for a supplied atmospheric state. Numerical methods and assembly interfaces belong in the solver contract.
