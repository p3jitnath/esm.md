# Repairing Small Or Negative Humidity

Revision 1.0.

Specific humidity $`q`$ is water-vapour mass divided by air mass, in kilograms per kilogram. A numerical update can make it smaller than a supplied minimum $`q_{\min}`$. This calculation corrects that shortage while taking water from the next layer down.

Let $`\Delta t`$ be the time step in seconds and $`\dot q`$ the supplied humidity tendency, in kilograms per kilogram per second. The missing amount is

```math
\delta q_i=\max(0,q_{\min}-(q_i+\Delta t\,\dot q_i)). \tag{P01}
```

Increase the layer's tendency by $`\delta q_i/\Delta t`$. For all layers above the bottom, reduce the next layer's tendency by

```math
\frac{\delta q_i}{\Delta t}\frac{\Delta p_i}{\Delta p_{i+1}}. \tag{P02}
```

Here $`\Delta p_i`$ is the layer's pressure thickness in pascals. The pressure ratio transfers equal water mass between the two layers. Process layers from the top down. The bottom correction adds water when no lower layer can supply it.

Let $`c_i`$ be the final tendency change caused by this correction. Its diagnostic flux increment $`F_i`$, in kilograms per square metre per second, is

```math
F_0=0, \qquad F_i=F_{i-1}-\frac{c_i\Delta p_i}{g}. \tag{P03}
```

Gravity $`g`$ is positive and is 9.80665 metres per second squared for the forecast.

## Supplied State And Boundaries

Supply finite humidity, a finite nonnegative minimum, a positive time step, and strictly increasing layer-edge pressures. Supply the humidity tendency when it is available, otherwise use zero. Process the requested columns. Add the diagnostic increment to the existing flux, keeping its top edge and inactive columns unchanged.
