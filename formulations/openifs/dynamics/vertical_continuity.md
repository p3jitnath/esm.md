# Vertical Continuity

Revision 1 describes air movement across the forecast’s pressure-coordinate layers.

Air can move across pressure-coordinate layers when horizontal wind transports pressure or when a mass source changes the air in a column. GPCTY calculates that coordinate mass flux and the pressure change following the air. Wind components use metres per second, pressure uses pascals and time uses seconds.

Let $`u_j`$ and $`v_j`$ be the layer winds, $`g_x`$ and $`g_y`$ the surface-pressure gradients, $`D_j`$ the horizontal divergence, $`\Delta p_j`$ the layer pressure depth and $`s_j`$ an optional specific mass source in inverse seconds. The dimensionless coordinate coefficient changes by $`\Delta B_j`$ through the layer. Calculate the pressure transport and layer divergence rate, both in pascals per second.

```math
q_j=u_j g_x+v_j g_y
```

```math
d_j=D_j\Delta p_j+\Delta B_j q_j-s_j\Delta p_j
```

Omit the last subtraction when the source is absent. The supplied finite-element vertical integration gives the accumulated rate $`I_j`$ at each full level and $`I_b`$ at the surface. The finite elements describe how a field changes within each layer. There is no mass flux through the top boundary.

Let $`B_j`$ be the supplied full-level coordinate coefficient and $`r_{p,j}`$ the inverse full-level pressure. The coordinate mass flux $`e_j`$ uses pascals per second, and the material pressure rate $`w_j`$ uses inverse seconds.

```math
e_j=B_j I_b-I_j
```

```math
w_j=(-I_j+B_j q_j)r_{p,j}
```

The forecast supplies the initial wind, pressure, horizontal divergence and optional mass source. The [solver contract](../../../skills/md2asm/references/openifs/dynamics/vertical_continuity.md) records the vertical integration and complete output representation.
