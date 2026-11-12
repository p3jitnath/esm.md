# Sunlight Through Patchy Clouds

Revision 1 defines how clear and cloudy areas contribute to shortwave radiation. Shortwave radiation comes from the Sun. Optical depth $`\tau`$ measures how strongly a layer blocks it. The scattering fraction $`\omega`$ is the fraction that is scattered, and $`g`$ describes its forward direction. These quantities have no units.

For gas, aerosol and cloud components, add their optical depths. Weight the scattering fraction by optical depth and the direction factor by scattering strength.

```math
\tau=\tau_{\mathrm{gas}}+\tau_{\mathrm{cloud}},\qquad
\omega=\frac{\omega_{\mathrm{gas}}\tau_{\mathrm{gas}}+\omega_{\mathrm{cloud}}\tau_{\mathrm{cloud}}}{\tau},\qquad
g=\frac{g_{\mathrm{gas}}\omega_{\mathrm{gas}}\tau_{\mathrm{gas}}+g_{\mathrm{cloud}}\omega_{\mathrm{cloud}}\tau_{\mathrm{cloud}}}{\omega\tau}. \tag{P01}
```

Use zero scattering or direction when its denominator is zero. A sampled cloud pattern represents the overlap of cloudy areas between layers. Its total cover $`c`$ is between zero and one. Average the clear and cloudy fluxes using their area fractions. Flux $`F`$ has units W m$`^{-2}`$.

```math
F=cF_{\mathrm{cloudy}}+(1-c)F_{\mathrm{clear}}. \tag{P02}
```

At the top, prescribe incoming sunlight and its direction. At the surface, prescribe direct and diffuse reflection fractions between zero and one. At night, shortwave flux is zero. Use the supplied optical properties, cloud fractions, overlap weights, cloud-variation table and reproducible random seed. The [solver contract](../../../skills/md2fort/references/openifs/physics/solver_mcica_sw.md) chooses the spectral transport, sampling and arithmetic.
