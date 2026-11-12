# Shortwave Two-Stream Coefficients

Revision 1.0 describes the shortwave coefficient calculation in OpenIFS. Shortwave radiation is energy from the Sun. A two-stream model represents scattered radiation with one upward flow and one downward flow.

## The Idea

A particle can absorb radiation or scatter it into another direction. The scattering fraction and preferred direction determine three coefficients that connect these flows. This calculation prepares each spectral point, a small part of the radiation spectrum, independently.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`\omega`$ | Fraction of interactions that scatter radiation, from zero to one, dimensionless |
| $`g`$ | Mean cosine of the scattering angle, from minus one to one, dimensionless |
| $`\mu`$ | Cosine of the solar zenith angle, from zero to one in daylight, dimensionless |
| $`\gamma_1,\gamma_2,\gamma_3`$ | Coefficients that couple radiation flows, dimensionless |

## Equations

**P01. Shortwave Coupling**

```math
\gamma_1=2-\omega\left(\frac54+\frac34g\right),\qquad
\gamma_2=\frac34\omega(1-g),\qquad
\gamma_3=\frac12-\frac34\mu g.
```

The first coefficient describes the loss from a diffuse flow. The second couples the upward and downward diffuse flows. The third distributes energy scattered from the direct beam. It is a coupling coefficient rather than a probability, so its value can be negative for strongly forward scattering.

## Parameters And Boundaries

Inputs are the scattering fraction and asymmetry at each spectral point, with one solar angle for the layer. There is no time update or spatial boundary in this local calculation. The [solver contract](../../../skills/md2fort/references/openifs/physics/calc_two_stream_gammas_sw.md) fixes the arithmetic and array interface.
