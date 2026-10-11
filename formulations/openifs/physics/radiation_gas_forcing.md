# Radiation Gas and Solar Forcing

Revision 1. This input supplies slowly changing gas amounts and Sun's radiation to the weather model. The gas amounts control infrared absorption, while incoming sunlight supplies energy.

The [gas time series](greenhouse_timeseries.md) gives each gas volume mixing ratio c_g. A radiation calculation also needs its mass mixing ratio q_g in kilograms of gas per kilogram of dry air. Equation U1 converts between them. M_g and M_air are the gas and dry-air molar masses, measured in grams per mole.

```math
q_g = c_g\frac{M_g}{M_{\mathrm{air}}}. \tag{U1}
```

| Gas | Molar mass, g/mol |
| --- | --- |
| Dry air | 28.9644 |
| Carbon dioxide | 44.0095 |
| Methane | 16.04 |
| Nitrous oxide | 44.013 |
| Nitrogen dioxide | 46.01 |
| CFC11 | 137.3686 |
| CFC12 | 120.914 |
| HCFC22 | 86.469 |
| Carbon tetrachloride | 153.823 |

Nitrogen dioxide uses the supplied placeholder ratio 0.00000000005. It is retained in the radiation state, although the present RRTM radiation scheme does not use it.

The [solar time series](solar_irradiance.md) gives incoming radiation in watts per square metre. A supplied scalar can override this value. The constant-forcing option instead uses 1366 W/m².

The forecast starts on 15 October 2004. Dates use decimal years and the source's mean 365.25-day calendar. Each update reads the gas and solar inputs at the current date, or at the middle of a requested fixed year. This update has no spatial boundary.
