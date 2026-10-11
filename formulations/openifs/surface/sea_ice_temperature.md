# Sea Ice Temperature

Revision 1 describes heat moving through layers of sea ice. Sun's radiation, thermal radiation and turbulent air exchange supply heat at the surface. The ocean fixes the temperature at the bottom. Heat moves from a warmer layer to a colder neighbour.

| Symbol | Meaning | Unit |
|---|---|---|
| $`T_j`$ | Temperature of ice layer $`j`$ | K |
| $`h_j`$ | Layer thickness | m |
| $`c`$ | Heat capacity per unit ice volume | J m$`^{-3}`$ K$`^{-1}`$ |
| $`k`$ | Ice thermal conductivity | W m$`^{-1}`$ K$`^{-1}`$ |
| $`Q`$ | Heat entering the upper surface | W m$`^{-2}`$ |
| $`T_f`$ | Ocean freezing temperature | K |
| $`T_m`$ | Maximum allowed ice temperature | K |

## Heat Balance

IT-1 gives the heat balance in each layer. A positive flux enters the layer.

```math
c h_j\frac{dT_j}{dt}=F_{j-1/2}-F_{j+1/2}.
```

For IT-2, conduction between neighbouring layer centres uses their separation.

```math
F_{j+1/2}=\frac{2k(T_j-T_{j+1})}{h_j+h_{j+1}},
\qquad F_{1/2}=Q,
\qquad F_{N+1/2}=\frac{k(T_N-T_f)}{h_N}.
```

The surface heat input is the sum of net shortwave radiation, net longwave radiation, sensible heat and the latent heat carried by the moisture flux. Sensible heat is energy carried by a temperature difference. Latent heat is energy carried by water changing phase.

## Inputs And Boundaries

The forecast supplies the initial temperatures, positive layer thicknesses, positive heat capacity, nonnegative conductivity and time interval. A common configuration has four ice layers. Its first three thicknesses are 0.07, 0.21 and 0.72 m, and the hemisphere's configured ice depth sets the final thickness. The ocean sets $`T_f`$ at the bottom. Limit the returned ice temperature to $`T_m`$ and record the removed heat in verification. Columns without sea ice return the freezing boundary temperature, limited by the same maximum.
