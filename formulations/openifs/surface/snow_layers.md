# Vertical Snow Layers

Revision 1.0 defines the geometry used by OpenIFS `SRFSN_VGRID_MOD::SRFSN_VGRID`. A snowpack is divided into vertical layers. The division can change as snow accumulates, while keeping the same total depth.

Let $`m_j`$ be layer mass per unit area in kilograms per square metre and $`\rho_j`$ its density in kilograms per cubic metre. Equation P01 gives total snow depth $`H`$ in metres.

```math
H=\sum_{j=1}^{n}\frac{m_j}{\rho_j}.
```

Let $`h_j`$ be the new layer depths in metres. Equation P02 preserves the snowpack's geometry.

```math
h_j\geq0,\qquad\sum_{j=1}^{n}h_j=H.
```

The caller supplies finite, nonnegative layer masses and positive densities. It also supplies the minimum and maximum layer depths for ordinary snow and glaciers, the terrain-height variation in metres and the no-snow mask. A nonpositive maximum marks the accumulation layer that can receive remaining depth. Other maxima are nonnegative and all minima are nonnegative. The [md2fort contract](../../../skills/md2fort/references/openifs/surface/snow_grid.md) defines the accepted layer-selection policy and its rounding limits.

This child changes the vertical division without advancing time. The supplied mass and density define its initial geometry. Columns outside the requested range retain their output bytes.
