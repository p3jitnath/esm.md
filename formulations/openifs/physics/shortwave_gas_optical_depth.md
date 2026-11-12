# Shortwave Gas Optical Depth

Revision 1.0.

## The idea

Shortwave radiation is the energy that arrives from the Sun. Atmospheric gases absorb part of it, while air molecules scatter part of it into other directions. The model represents different wavelengths with small groups called spectral bands. Each layer has one absorption and scattering value for each representative wavelength.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`\tau_a`$ | Gas absorption optical depth, dimensionless |
| $`\tau_s`$ | Molecular scattering optical depth, dimensionless |
| $`\tau`$ | Total optical depth, dimensionless |
| $`\omega`$ | Fraction of the total interaction caused by scattering, dimensionless |
| $`F`$ | Incoming solar energy per unit area and time, W/m² |
| $`\mu`$ | Cosine of the angle between sunlight and the upward vertical, dimensionless |

Optical depth measures how strongly one layer affects radiation. A larger optical depth means that radiation is more likely to interact with the layer. The scattering fraction is zero for pure absorption and one for pure scattering.

## Equations

**SGO-1. Total interaction**

```math
\tau=\tau_a+\tau_s.
```

Absorption and scattering contribute to the total optical depth.

**SGO-2. Scattering fraction**

```math
\omega=\frac{\tau_s}{\tau}.
```

This ratio gives the scattering part of the total interaction. The supplied layers must have positive total optical depth.

## Parameters, initial state and boundaries

Use the supplied gas amounts, absorption tables, molecular scattering coefficients and solar energy tables. The gases are water vapour, carbon dioxide, methane, oxygen and ozone. Molecular columns give molecule counts above unit area in the model's source-scaled units of approximately $`10^{20}`$ molecules/cm².

The fourteen bands contain 112 representative spectral points. This calculation has no time update. It receives the current atmospheric layers and evaluates them independently in each horizontal column. A column receives direct solar input when $`\mu>0`$. Night columns keep the caller's supplied output state.

The [md2fort contract](../../../skills/md2fort/references/openifs/physics/srtm_gas_optical_depth.md) records numerical choices, storage, interfaces and acceptance limits.
