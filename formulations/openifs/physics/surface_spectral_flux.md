# Surface Spectral Radiation

Revision 1.0.

Radiation carries energy to the ground. The downward flux $`F`$ is power per area, in watts per square metre. Shortwave radiation comes from the Sun. It reaches the ground as a direct beam or as diffuse light scattered by air, clouds and particles. Longwave radiation comes from the thermal emission of the atmosphere.

## Basic Mathematics

The radiation solver divides the spectrum into small samples. Add the samples assigned to a spectral band $`b`$.

```math
F_b = \sum_{k\ \mathrm{in}\ b}F_k, \qquad F_b^{\mathrm{total}} = F_b^{\mathrm{diffuse}} + F_b^{\mathrm{direct}}. \tag{P01}
```

A plant canopy can use a different set of bands. A weight $`w_{ab}`$ states the fraction of source band $`b`$ that belongs to canopy band $`a`$.

```math
F_a^{\mathrm{canopy}} = \sum_b w_{ab}F_b. \tag{P02}
```

The weights are nonnegative. When each source band is divided fully between canopy bands, its weights sum to one and the total energy flux is preserved. A simpler choice assigns each source band to its nearest canopy band. A canopy can also use the original spectral samples directly.

## State and Boundaries

Provide the surface spectral fluxes, sample-to-band assignments and any canopy weights. Process the requested atmospheric columns. Clear-sky fluxes describe the same atmosphere with clouds removed. Shortwave canopy diffuse flux is the weighted total minus the weighted direct flux. This is a surface calculation, so it does not update the atmosphere.
