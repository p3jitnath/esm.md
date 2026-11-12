# Heat Transfer Between Snow Layers

Revision 1.0. OpenIFS `SRFSN_WEBAL_MOD::TRISOLVER` calculates the new temperature of a vertical snow column. The surrounding model supplies the heat capacity, heat transfer and heat input for each layer.

Let $`T_j`$ be the temperature of layer $`j`$ in kelvin. Let $`a_j`$, $`b_j`$ and $`c_j`$ be the lower, central and upper coefficients in watts per square metre per kelvin. Let $`f_j`$ be the heat input in watts per square metre. Equation P01 states each layer's heat balance.

```math
a_jT_{j-1}+b_jT_j+c_jT_{j+1}=f_j.
```

There are $`n\geq1`$ active layers. The first equation has no lower neighbour and the last has no upper neighbour. Surface and soil heat inputs are included in the supplied coefficients and heat input. The caller supplies the previous state when it forms these inputs.

The coefficients and heat inputs are the parameters for this calculation. They must give finite solutions through the complete elimination in the [md2fort contract](../../../skills/md2fort/references/openifs/surface/snow_trisolver.md). This child has no separate time step or initial temperature to choose.
