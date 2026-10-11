# Non-Orographic Gravity-Wave Drag

Revision 1. Gravity waves are small disturbances in air that move both vertically and horizontally. They can carry horizontal momentum from the lower atmosphere into higher layers. This model launches waves in four horizontal directions and follows twenty positive phase speeds in each direction. A phase speed is the speed at which a wave crest moves.

Let pressure p be in pascals, height-related energy z in joules per kilogram, temperature T in kelvin and horizontal wind u and v in metres per second. Air density rho is in kilograms per cubic metre. The buoyancy frequency N, in inverse seconds, measures the restoring force of a vertical displacement.

```math
\rho = \frac{p}{R_d T}, \qquad N^2 = \frac{g^2}{c_p T}\left(1+c_p\frac{\Delta T}{\Delta z}\right). \tag{G1}
```

Here g is gravity, R_d is the gas constant for dry air and c_p is its heat capacity. A positive lower bound on N squared keeps the launched waves in stable air. The lower boundary supplies a prescribed momentum flux in pascals. Each wave loses flux when the local wind reaches its phase speed or when its amplitude reaches the saturation limit.

```math
\frac{\partial u}{\partial t}=g\frac{\Delta F_u}{\Delta p}, \qquad \frac{\partial v}{\partial t}=g\frac{\Delta F_v}{\Delta p}. \tag{G2}
```

The fluxes F_u and F_v carry the eastward and northward momentum. Their pressure-weighted differences give the change of wind in each layer. The model sets the flux at the top boundary to zero. The launch height, launch flux, wavelength, spectral slope and saturation choice come from the original weather-model configuration. Initial wind, temperature, pressure and height come from the forecast state.
