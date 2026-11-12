# Sunlight in a Lake

Revision 1. Water and ice absorb Sun's radiation. Radiation becomes weaker with depth, and the absorbed part heats the lake.

Let $`I(0)`$ be the radiation flux entering a material in W m$`^{-2}`$, $`z`$ the depth in m and $`k`$ the extinction coefficient in m$`^{-1}`$. This coefficient measures how strongly the material absorbs radiation.

```math
I(z)=I(0)e^{-kz}.
```

A material can use several wavelength bands. If $`f_b`$ is the fraction in band $`b`$, the fractions sum to one and the transmitted flux is

```math
I(z)=I(0)\sum_b f_b e^{-k_bz}.
```

The mean radiation flux between depths $`a`$ and $`b`$ is its depth integral divided by the layer thickness.

```math
\overline I_{a,b}=\frac{1}{b-a}\int_a^b I(z)\,dz.
```

Supply the incoming radiation, lake depth, ice thickness, upper mixed-layer depth and the band properties of water and ice. The mixed layer is the upper water region that has nearly uniform temperature. Radiation enters through the surface and leaves at the lake bottom. The difference is the radiation absorbed by the water.

The reference water uses $`k=3`$ m$`^{-1}`$. Clear water can use two bands with fractions 0.1 and 0.9 and coefficients 2 and 0.2 m$`^{-1}`$. White and blue ice use 17.1 and 8.4 m$`^{-1}`$, while opaque ice uses $`10^7`$ m$`^{-1}`$. The model clips lake depth to 2–50 m, uses an ice threshold of $`10^{-9}`$ m and a minimum mixed-layer thickness of 0.01 m.

The [md2fort contract](../../../skills/md2fort/references/openifs/surface/lake_radiation.md) defines the interface fluxes, thin-layer limits and ordered arithmetic.
