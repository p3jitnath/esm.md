# Sun's Radiation Through Snow

Revision 1 describes the unchanged OpenIFS routine `srfsn_ssrabs_mod::srfsn_ssrabs`.

## The Idea

Snow absorbs part of the Sun's radiation and passes the rest into deeper snow and the soil. A thicker layer passes less radiation. The model uses snow density to estimate grain size, which sets the rate at which radiation decreases with depth.

## Symbols

| Symbol | Meaning and Unit |
| --- | --- |
| $`I`$ | Radiation entering a layer, in watts per square metre |
| $`d`$ | Layer depth, in metres |
| $`k`$ | Radiation extinction rate, in inverse metres |
| $`\rho`$ | Snow density, in kilograms per cubic metre |
| $`g`$ | Estimated snow grain size, in metres |
| $`f_t`$ | Fraction of the surface covered by snow tile $`t`$ |

## Equations

**S1. Transmission Through One Layer**

```math
I_{\mathrm{out}}=I_{\mathrm{in}}\exp(-kd),
\qquad
I_{\mathrm{absorbed}}=I_{\mathrm{in}}-I_{\mathrm{out}}.
```

The exponential factor is the fraction of radiation that crosses the layer. Transmitted radiation becomes the input to the next layer.

**S2. Depth and Grain Size**

```math
d=\max(0,\min(d_{\max},m/\rho)),
\qquad
g=\min(g_{\max},a_1+a_3\rho^4),
\qquad
k=\max(k_{\min},\min(k_{\max},c\rho/\sqrt{g})).
```

Here $`m`$ is snow mass per square metre. The constants limit the layer depth, grain size and extinction rate to the model's physical ranges.

**S3. Surface Average**

```math
Q_j=\sum_{t\in\{5,7\}}f_tQ_{t,j}.
```

The two snow tiles contribute according to their surface fractions. The snow heat equation subtracts radiation leaving the top layer and adds radiation absorbed by deeper layers. Radiation below the active snow enters the soil.

## Parameters, Initial State, and Boundaries

The standard limits are $`d_{\max}=1`$ metre, $`g_{\max}=0.002796`$ metre, $`k_{\min}=5`$ and $`k_{\max}=50`$ inverse metres. The constants are $`a_1=0.00016`$ metre, $`a_3=1.1\times10^{-13}`$ with units that make $`a_3\rho^4`$ a length, and $`c=0.0038`$ with units that make $`c\rho/\sqrt{g}`$ an inverse length.

The caller supplies snow mass, density, radiation and surface fractions. Transport outputs start at zero. Columns without snow return zero radiation in every snow and soil channel. The [md2fort contract](../../../skills/md2fort/references/openifs/surface/srfsn_ssrabs.md) defines the ordered calculations and their checks.
