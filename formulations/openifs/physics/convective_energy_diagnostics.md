# Convective energy diagnostics

CUANCAPE2 estimates the energy that a rising parcel of air can gain, and the energy that opposes its rise. These outputs are convective available potential energy, called CAPE, and convective inhibition, called CIN. Both have units J/kg. Inputs are full-level and half-level pressure in Pa, temperature in K and specific humidity in kg/kg. A half level is a boundary between two atmospheric layers.

Potential temperature $`\theta`$ is the temperature that air would have at the reference pressure $`p_0`$. Equivalent potential temperature $`\theta_e`$ also includes the parcel's water vapour. Here $`\kappa=R_d/c_p`$, where $`R_d`$ is the dry-air gas constant in J/(kg K), $`c_p`$ is heat capacity in the same units, $`q`$ is specific humidity and $`L`$ is latent heat in J/kg.

```math
\theta=T(p_0/p)^{\kappa},\qquad
\theta_e=\theta\exp\left(\frac{Lq}{c_pT}\right).
```

The approximate estimate compares the parcel's equivalent potential temperature with the saturated environment, written $`\theta_{e,s}`$. It adds positive buoyancy work after condensation. The layer pressure thickness is $`\Delta p`$, and $`\epsilon_v`$ is the model's humidity correction for virtual temperature.

```math
\Delta E=\left(\frac{\theta_e}{\theta_{e,s}}-1\right)
\frac{\Delta p}{p}R_dT(1+\epsilon_vq).
```

The routine selects the departure layer with the largest approximate CAPE. It also lifts that parcel and parcels mixed over the lowest 5000 and 10000 Pa, using saturation adjustment to estimate their CAPE and CIN. Mixing includes complete layers. It uses the initialized OpenIFS physical constants, including the ice and liquid latent heats, and keeps the original condensation-temperature floor of 160 K.

There is no time update or lateral boundary in this diagnostic. The supplied atmospheric column is the initial state, and its level pressures define the vertical boundaries. This formulation preserves the physical model of arpifs/phys_ec/cuancape2.F90.
