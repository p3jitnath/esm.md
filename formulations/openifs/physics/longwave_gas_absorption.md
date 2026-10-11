# Complete Longwave Gas Absorption

Revision 1 describes absorption of Earth's thermal radiation across sixteen frequency bands. Water vapour, carbon dioxide, ozone, nitrous oxide, methane, oxygen, trace gases and aerosols affect different bands. Each of the 140 spectral points represents part of a band.

Optical depth $`\tau_g`$ measures absorption without units. The spectral transmission $`\mathcal T_g`$ decreases as absorption increases.

```math
\mathcal T_g=\exp(-\tau_g). \tag{LWG-1}
```

Each band combines the supplied gas columns with unchanged empirical absorption coefficients. The tables also supply a Planck fraction, which assigns thermal emission to each spectral point. Gas columns, layer pressure, interpolation factors, tropopause position and aerosol depths come from the forecast's atmospheric preparation.

Use the existing [band physics](longwave_water_nitrogen.md) and the other fifteen linked band formulations through the [complete md2asm contract](../../../skills/md2asm/references/openifs/physics/rrtm_gas_optical_depth.md). This caller joins the bands and returns their outputs. It has no separate time update or spatial boundary.
