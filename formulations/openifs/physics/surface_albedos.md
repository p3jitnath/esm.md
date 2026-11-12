# Surface Reflection Across Wavelengths

Revision 1 describes the surface values used by the OpenIFS radiation calculation. Albedo $`a`$ is the fraction of incoming radiation reflected by the ground. Emissivity $`\epsilon`$ is the fraction of ideal thermal radiation that the ground emits. Both are dimensionless and lie between zero and one. Direct sunlight and diffuse sunlight can have different albedos.

Surface values can be supplied in wavelength intervals that differ from the atmosphere's intervals. A nearest-interval map selects one supplied value. A weighted map combines overlapping intervals with nonnegative weights $`w_{ib}`$ whose sum is one for each atmospheric band $`b`$.

```math
a_b=\sum_i w_{ib}a_i,\qquad \sum_i w_{ib}=1.
```

This average preserves the range from zero to one. A spectral sample uses the atmospheric band assigned to it. Values already supplied for every spectral sample need no average.

The reflected fraction of thermal radiation is the complement of emissivity.

```math
a_i^{\mathrm{LW}}=1-\epsilon_i,\qquad
a_b^{\mathrm{LW}}=\sum_i w_{ib}(1-\epsilon_i).
```

The ground reflects one fraction and absorbs its complement. There is no time update or atmospheric layer calculation here. The numerical mapping and storage rules belong to [the md2fort contract](../../../skills/md2fort/references/openifs/physics/get_albedos.md).
