# Aerosol Height Profiles

Revision 1.

Aerosols are small particles suspended in air. This model gives the fraction of each aerosol type's optical thickness between the top of the atmosphere and one pressure level. Optical thickness measures how strongly material removes light from a beam, and its fraction has no units.

Let $`\eta`$ be pressure divided by surface pressure. It increases from zero at the top to one at the surface. Let $`H`$ be the aerosol height scale in metres, and use an atmospheric height scale $`H_a=8434\ \mathrm{m}`$. An exponential decrease with height gives the normalized profile in Equation AVP-1. The exponent is at least one, so particles are no more broadly distributed than the air.

```math
\alpha=\max(1,H_a/H),\qquad C(\eta)=\eta^\alpha.
\tag{AVP-1}
```

The fraction in a layer between two pressure levels is the difference in Equation AVP-2. An increasing pressure coordinate must give a nonnegative layer fraction.

```math
\Delta C=C(\eta_{\mathrm{lower}})-C(\eta_{\mathrm{upper}}).
\tag{AVP-2}
```

| Aerosol type | Default height scale | Units |
| --- | --- | --- |
| Sea salt | 1000 | m |
| Dust | 3000 | m |
| Organic matter | 2000 | m |
| Black carbon | 1000 | m |
| Sulphate | 4000 | m |

The dust height can change with the season. Supply a positive height scale for each type and increasing pressure levels between zero and one. At a zero-pressure top boundary, the cumulative fraction is zero. At the surface, the cumulative fraction is one.
