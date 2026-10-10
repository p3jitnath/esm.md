# Cloud Overlap Length

Revision 1.0.

Adjacent layers can share the same clouds. The overlap weight $`\alpha`$ is one for fully shared clouds and approaches zero when their positions become independent. A decorrelation length $`L`$, in metres, sets the distance over which this sharing decreases.

## Basic Mathematics

For pressure $`p`$ in pascals and air temperature $`T`$ in kelvin, hydrostatic balance gives the distance $`\Delta z`$ between two pressure surfaces. Use the mean temperature between those surfaces.

```math
\Delta z = \frac{R_d T}{g}\ln\left(\frac{p_{\mathrm{lower}}}{p_{\mathrm{upper}}}\right), \qquad \alpha = \exp\left(-\frac{\Delta z}{L}\right). \tag{P01}
```

Here $`R_d = 287.058\ \mathrm{J\,kg^{-1}\,K^{-1}}`$ is the dry-air gas constant and $`g = 9.80665\ \mathrm{m\,s^{-2}}`$ is gravity. Pressure increases towards the ground, so $`\Delta z`$ is nonnegative and $`0 \leq \alpha \leq 1`$.

A simpler option uses a fixed atmospheric scale height $`H = 8000\ \mathrm{m}`$ instead of the measured temperature.

```math
\Delta z = H\ln\left(\frac{p_{\mathrm{lower}}}{p_{\mathrm{upper}}}\right). \tag{P02}
```

## State and Boundaries

Provide pressure and temperature at the edges of each model layer, together with a positive decorrelation length. The output contains one overlap weight between each adjacent pair of layers. The atmosphere can be stored from the top down or from the ground up. The pressure at the outer top edge can be zero because this calculation uses the next pressure edge.
