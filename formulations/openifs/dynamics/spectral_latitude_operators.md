# Latitude Derivatives And Wind Patterns

Formulation revision 1.0 describes calculations on a spherical surface. Let latitude be $`\phi`$ in radians and set $`\mu=\sin\phi`$. A spectral field stores the strength of each smooth latitude pattern rather than its value at each point. Its degree $`n`$ sets its latitude structure, while the integer $`m`$ gives the number of repetitions around longitude.

## Latitude Derivative

The north–south derivative uses the operator below. Multiplying by the cosine of latitude keeps this working derivative finite at the poles. It preserves the field's units.

```math
D f=(1-\mu^2)\frac{\partial f}{\partial\mu}
=\cos\phi\,\frac{\partial f}{\partial\phi}.
\tag{SL1}
```

The latitude patterns are normalized associated Legendre functions. These are polynomials with a factor that accounts for longitude variation. Differentiating one pattern joins the two neighbouring degrees. The model supplies their fixed coefficients.

## Winds And Their Sources

Vorticity $`\zeta`$ measures local rotation, while divergence $`\delta`$ measures spreading. Both have units of inverse seconds. Let the sphere's radius $`a`$ be in metres. The stream function $`\psi`$ describes rotational flow and the velocity potential $`\chi`$ describes spreading flow. Both have units of square metres per second.

```math
\psi_{n,m}=-\frac{a^2\zeta_{n,m}}{n(n+1)},
\qquad
\chi_{n,m}=-\frac{a^2\delta_{n,m}}{n(n+1)}
\quad(n>0).
\tag{SL2}
```

The constant degree has no wind contribution. With $`i^2=-1`$, multiplying a coefficient by $`im`$ gives its longitude derivative. Complex coefficients use two real numbers to store the cosine and sine parts.

```math
U_c=im\chi-D\psi,\qquad V_c=im\psi+D\chi.
\tag{SL3}
```

Here $`U_c=a\cos\phi\,u`$ and $`V_c=a\cos\phi\,v`$ are wind working fields, with units of square metres per second. The eastward and northward wind speeds $`u,v`$ have units of metres per second.

The reverse calculation uses different working fields, $`U_d=au/\cos\phi`$ and $`V_d=av/\cos\phi`$. These come from the surrounding transform stages. Define $`Bf=Df-2\mu f`$.

```math
a^2\zeta=imV_d-BU_d,\qquad
a^2\delta=imU_d+BV_d.
\tag{SL4}
```

These are separate spatial calculations and have no time step, initial state or physical boundary condition. Their spectral end rows and exact storage belong to the md2fort contract.
