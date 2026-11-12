# Spectral Horizontal Diffusion

Formulation revision 1. The original routine name is SPCHOR.

Horizontal diffusion smooths small waves in the atmosphere. We write the global fields as spherical waves, with one coefficient for the strength of each wave. The degree counts spatial variation, and the order counts variation around a latitude circle. This model smooths orders greater than zero and preserves order zero.

Vorticity measures spinning motion and divergence measures spreading motion. Their coefficients have units of inverse seconds. Temperature coefficients use kelvin. Let $`x`$ be either wind coefficient and let $`d_x`$ be its supplied nonnegative diffusion rate in inverse seconds. Equation SHD-1 reduces the wave strength over time $`t`$, measured in seconds.

```math
\frac{dx}{dt}=-d_x x \qquad \text{(SHD-1)}
```

Let $`T`$ be a temperature coefficient in kelvin, $`P`$ be a dimensionless logarithmic surface-pressure coefficient, $`C`$ be a supplied correction in kelvin and $`d_T`$ be the temperature diffusion rate in inverse seconds. Equation SHD-2 moves temperature toward $`CP`$. Use the earlier pressure state, which this stage preserves.

```math
\frac{dT}{dt}=-d_T(T-CP) \qquad \text{(SHD-2)}
```

The coarse forecast supplies 19 atmospheric levels, degrees through 21, 22 local orders and a 3,600-second time interval. Its initial coefficients and rates come from the frozen forecast state and parameter tables. Longitude wraps around the Earth, and the spherical waves represent both poles. Preserve pressure, constituents and diagnostic fields in this selected model. The md2fort contract defines the numerical method and the complete update.
