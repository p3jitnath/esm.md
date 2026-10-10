# Longwave Two-Stream Coefficients

Revision 1.0 describes the longwave coefficient calculation in OpenIFS. Longwave radiation is thermal energy emitted by the Earth and atmosphere. A two-stream model represents scattered radiation with one upward flow and one downward flow.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`\omega`$ | Fraction of interactions that scatter radiation, from zero to one, dimensionless |
| $`g`$ | Mean cosine of the scattering angle, from minus one to one, dimensionless |
| $`L`$ | Fixed diffuse-path factor of 1.66, dimensionless |
| $`\gamma_1,\gamma_2`$ | Coefficients that describe loss and exchange between radiation flows, dimensionless |

## Equations

**P01. Longwave Coupling**

```math
\gamma_1=L\left[1-\frac{\omega}{2}(1+g)\right],\qquad
\gamma_2=\frac{L\omega}{2}(1-g).
```

The first coefficient describes loss from a diffuse flow. The second connects the upward and downward flows. Their difference is $`L(1-\omega)`$, so absorption vanishes when every interaction scatters radiation.

## Parameters And Boundaries

Inputs are the scattering fraction and direction preference at each spectral point. The factor $`L`$ approximates the longer paths of diffuse radiation through the layer. This calculation has no time update or spatial boundary. The [solver contract](../../../skills/md2asm/references/openifs/physics/calc_two_stream_gammas_lw.md) fixes the arithmetic and array interface.
