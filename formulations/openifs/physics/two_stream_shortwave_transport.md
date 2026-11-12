# Shortwave Radiation Through One Layer

Revision 1.0 describes the local shortwave transport calculation in OpenIFS. Radiation from the Sun can pass through an atmospheric layer, scatter upward or downward, or be absorbed. A two-stream model represents scattered radiation by one upward flow and one downward flow.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`\tau`$ | Optical depth, which measures the amount of interaction along a vertical path, dimensionless |
| $`D,U`$ | Downward and upward diffuse energy flows divided by incoming beam energy, dimensionless |
| $`B`$ | Unscattered beam energy divided by incoming beam energy, dimensionless |
| $`\omega`$ | Fraction of interactions that scatter radiation, from zero to one, dimensionless |
| $`\mu`$ | Cosine of the solar zenith angle, positive in daylight, dimensionless |
| $`\gamma_1,\gamma_2,\gamma_3`$ | The [shortwave coupling coefficients](two_stream_gammas_sw.md), dimensionless |

## Equations

**P01. Flow Through Optical Depth**

A derivative here means the rate of change as the path moves deeper into the layer.

```math
\frac{dD}{d\tau}=-\gamma_1D+\gamma_2U+\omega(1-\gamma_3)B,
\qquad
\frac{dU}{d\tau}=-\gamma_2D+\gamma_1U-\omega\gamma_3B.
```

The first two terms describe loss and exchange between diffuse flows. The final term supplies radiation scattered from the direct beam.

**P02. Direct Beam Decay**

```math
\frac{dB}{d\tau}=-\frac{B}{\mu}.
```

A longer slanted path causes stronger attenuation. Beam energy is measured in a plane perpendicular to the Sun's direction, so the energy crossing a horizontal plane has the extra factor $`\mu`$.

## Parameters And Boundaries

The layer has constant coefficients and a supplied optical depth. For diffuse reflection and transmission, supply unit downward diffuse radiation at the top and zero upward radiation at the bottom. For beam scattering, supply a unit direct beam at the top, zero downward diffuse radiation at the top and zero upward radiation at the bottom. This calculation returns five layer coefficients, with no time update or neighbouring-layer calculation. The [solver contract](../../../skills/md2fort/references/openifs/physics/calc_reflectance_transmittance_sw.md) records the original numerical safeguards and exact arithmetic.
