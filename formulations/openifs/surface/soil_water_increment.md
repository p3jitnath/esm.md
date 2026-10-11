# Soil Water And Drainage

Revision 1.0 uses the OpenIFS 48.1.1 SRFWINC routine. Soil water is described by its volume fraction $`\theta`$, measured in cubic metres of water per cubic metre of soil. A supplied weighted state $`\theta_*`$ combines the old and new water fractions with a weight $`0<\alpha\leq1`$.

```math
\theta_*=\alpha\theta_{\mathrm{new}}+(1-\alpha)\theta_{\mathrm{old}}. \tag{WI-1}
```

Water also moves between layers. The supplied gravity flux $`F_g`$ is positive downwards. Let $`w=\theta_*/\alpha`$ be the supplied scaled water state, $`K`$ be its supplied diffusion factor in metres, $`\rho`$ be water density in kilograms per cubic metre and $`\Delta t`$ be the time step in seconds. Between an upper and lower soil layer, the updated flux is

```math
F=F_g+\frac{\rho K}{\Delta t}(w_{\mathrm{upper}}-w_{\mathrm{lower}}). \tag{WI-2}
```

The flux is in kilograms per square metre per second. This expression moves water towards the layer with the smaller scaled water state. The previous soil calculation supplies the weighted states and diffusion factors. The recovered water is a preliminary state, and the following water-correction calculation handles deficits and excess water. The bottom flux is supplied drainage and stays fixed. Sea cells keep their old water fraction and have zero soil flux. The top flux and the loss through the bottom are copied to the supplied diagnostic storage.
