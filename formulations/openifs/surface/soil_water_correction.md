# Soil Water Corrections

Revision 1 describes water stored on vegetation and in a soil column. A soil layer can hold water up to its saturation level. Excess water becomes runoff, which is water that leaves the column. This calculation also repairs a negative water amount after the preceding time update.

| Symbol | Meaning | Unit |
|---|---|---|
| $`L`$ | Water on vegetation | kg m$`^{-2}`$ |
| $`L_{\max}`$ | Vegetation water capacity | kg m$`^{-2}`$ |
| $`h_j`$ | Thickness of layer $`j`$ | m |
| $`\theta_j`$ | Water volume divided by soil volume | 1 |
| $`\theta_{\mathrm{sat}}`$ | Saturation water fraction for the soil type | 1 |
| $`\rho_w`$ | Liquid water density | kg m$`^{-3}`$ |
| $`\Delta t`$ | Time between updates | s |

## Water Storage

SC-1 gives the water mass per unit ground area in the column. Each layer contributes its thickness times its water fraction times the water density.

```math
M=L+\rho_w\sum_jh_j\theta_j.
```

SC-2 transfers vegetation overflow into the top soil layer.

```math
q=\max(0,L-L_{\max}),\qquad L'=L-q,\qquad
\theta_1'=\theta_1+\frac{q}{\rho_wh_1}.
```

For SC-3, a negative layer amount is set to zero and its water deficit is passed to the next layer. Water above saturation leaves as runoff.

```math
d_j=\min(\theta_j,0),\qquad
\widetilde{\theta}_j=\theta_j-d_j,\qquad
r_j=\max(0,\widetilde{\theta}_j-\theta_{\mathrm{sat}}),\qquad
\theta_j'=\widetilde{\theta}_j-r_j.
```

The deficit adds $`h_jd_j/h_{j+1}`$ to the next layer. The runoff mass is $`\rho_wh_jr_j`$. A deficit at the bottom has no lower layer to supply water. The repair therefore adds that missing amount to the model state, and the verification records this amount separately.

## Inputs And Boundaries

Use positive layer thicknesses, positive time and positive water density. The forecast supplies the soil type, saturation values and current water amounts. Common four-layer thicknesses are 0.07, 0.21, 0.72 and 1.89 m, and liquid water density is 1000 kg m$`^{-3}`$. The saturation level can be one shared value or a value for each soil type. Apply the correction to land columns. Sea columns have zero deep runoff and zero surface-to-deep water exchange.
