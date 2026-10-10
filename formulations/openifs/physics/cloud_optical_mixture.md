# Liquid and Ice Cloud Radiation

Revision 1.0. This input uses the SOCRATES liquid-droplet model and the Fu ice model.

Cloud droplets and ice particles absorb and scatter radiation. A layer's optical depth $`\tau`$ measures its total interaction with light. Its scattering depth $`S`$ measures scattering alone. The difference is absorption. The dimensionless asymmetry factor $`g`$ describes the average direction of scattering.

## Basic Mathematics

Pressure increases downwards. The pressure difference $`\Delta p`$ across a layer gives its air mass per area when divided by gravity. The liquid or ice mixing ratio $`q`$, in kilograms per kilogram, gives the corresponding water path $`M`$ in kilograms per square metre. For a partly cloudy cell, divide by its cloud fraction $`f`$ to obtain the water path inside the cloud.

```math
M = \frac{q\,\Delta p}{g_{\mathrm{gravity}}\,f}, \qquad g_{\mathrm{gravity}} = 9.80665\ \mathrm{m\,s^{-2}}. \tag{P01}
```

A homogeneous cloud fills the whole cell, so use $`f = 1`$ for this conversion. The droplet and ice models use their water paths, effective particle radii in metres, and supplied band coefficients to determine their separate optical properties.

Combine liquid and ice by adding their optical and scattering depths. Weight their scattering directions by the amount of scattering.

```math
\tau = \tau_{\mathrm{liq}}+\tau_{\mathrm{ice}}, \qquad S = S_{\mathrm{liq}}+S_{\mathrm{ice}}, \qquad \omega = \frac{S}{\tau}. \tag{P02}
```

Here $`\omega`$ is the fraction of interaction caused by scattering.

```math
g_{\mathrm{mix}} = \frac{g_{\mathrm{liq}}S_{\mathrm{liq}}+g_{\mathrm{ice}}S_{\mathrm{ice}}}{S}. \tag{P03}
```

When longwave scattering is omitted, use only the absorption depth.

```math
\tau_{\mathrm{abs}} = (\tau_{\mathrm{liq}}-S_{\mathrm{liq}})+(\tau_{\mathrm{ice}}-S_{\mathrm{ice}}). \tag{P04}
```

## State and Boundaries

Provide layer-edge pressures, cloud fractions, liquid and ice mixing ratios, particle radii, and the two model coefficient tables. Process the requested columns and levels. Clear cells have zero optical properties. Apply the documented cloud forward-scattering correction at the stage selected by the radiation configuration. All optical depths are dimensionless.
