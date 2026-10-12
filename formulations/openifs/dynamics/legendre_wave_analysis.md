# Legendre Wave Analysis

Formulation revision 1 describes one latitude-wave analysis. Its solver contract records the numerical method and implementation.

A field on the Earth can be written as a sum of wave patterns. Fourier waves describe the east–west variation. Associated Legendre functions describe the north–south variation. Multiplying a field by one of these patterns and integrating gives its wave coefficient.

Let $`\phi`$ be latitude in radians and $`x=\sin\phi`$. For a selected east–west order $`m`$, let $`F_m(x)`$ be the supplied latitude field. The order counts the east–west wave variation. The degree $`n`$ also describes its latitude variation. Both are integers, with $`n\ge m\ge0`$. Treat the cosine and sine components separately.

| Symbol | Meaning | Units |
| --- | --- | --- |
| $`x`$ | Sine of latitude | Dimensionless |
| $`F_m`$ | Supplied latitude field at order $`m`$ | Units of that field |
| $`P_{nm}`$ | Normalised associated Legendre pattern | Dimensionless |
| $`a_{nm}`$ | Returned wave coefficient | Same units as $`F_m`$ |

For example, a temperature field and its coefficients both use kelvin. Choose the pattern normalisation in E1.

```math
\text{E1}\qquad \frac12\int_{-1}^{1}P_{nm}(x)^2\,\mathrm{d}x=1.
```

Equation E2 extracts the coefficient of each supplied pattern.

```math
\text{E2}\qquad a_{nm}=\frac12\int_{-1}^{1}F_m(x)P_{nm}(x)\,\mathrm{d}x.
```

The inputs are the current field components and their latitude patterns. The current model supplies orders zero through twenty-one. Use all degrees supplied for each order, including the extra wind degree. This operation has no separate time evolution or initial-condition calculation.

Longitude repeats after one full circle, and the field must stay bounded at the poles. The full latitude interval is $`-1\le x\le1`$. The [solver contract](../../../skills/md2asm/references/openifs/dynamics/legendre_wave_analysis.md) explains how the integrals become discrete sums and how the complete source interface is preserved.
