# Snow Exponential Profiles

Revision 1. A layered snow model needs a temperature and density at each depth. An exponential curve provides a smooth first estimate from the supplied boundary and mean values.

Depth $`z`$ is measured in metres, temperature $`T`$ in kelvin and density $`\rho`$ in kilograms per cubic metre. A positive coefficient $`C`$, measured in inverse metres, controls how quickly a profile changes with depth.

```math
T(z)=A_T+B_T e^{-C_T z}, \qquad \rho(z)=A_\rho+B_\rho e^{-C_\rho z}.
```

The coefficients A and B have the units of their temperature or density field. Two supplied reference values determine A and B. Temperature uses the top and bottom conditions. Density uses the top and middle conditions. The selected profile category supplies C.

The first estimate follows the supplied melting-temperature limit, density limits, middle-layer conditions and glacier conditions. Columns without enough snow retain their previous values. Later updates adjust the column mass and energy.
