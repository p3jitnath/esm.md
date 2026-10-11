# Associated Legendre Basis

Revision 1.

A weather field varies with latitude and longitude. A spherical basis describes this variation as a sum of smooth waves. This input defines the dimensionless latitude part of each wave. The input $`x=\sin\phi`$ is the sine of latitude $`\phi`$, so $`-1\le x\le1`$.

Let $`P_n(x)`$ be the ordinary Legendre polynomial of degree $`n`$. The first two polynomials are $`P_0(x)=1`$ and $`P_1(x)=x`$. The normalised associated function for integer order $`m`$ is

```math
\overline P_n^m(x)=
\sqrt{\frac{(2n+1)(n-m)!}{(n+m)!}}\,
(1-x^2)^{m/2}\,
\frac{d^mP_n(x)}{dx^m}.
\tag{LG1}
```

The symbol $`d^m/dx^m`$ means take the derivative $`m`$ times, and $`n!`$ means the product of integers from 1 to $`n`$. Degree and order satisfy $`0\le m\le n`$. These values have no units.

For a chosen maximum degree $`N`$, calculate every pair with $`0\le m\le n\le N`$. The input latitude can include either pole. At a pole, functions with $`m>0`$ are zero. This function has no time update, initial state or spatial boundary cells.
