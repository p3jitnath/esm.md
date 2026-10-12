# Direct Fourier Analysis

Revision 1 describes a periodic longitude row in the coarse OpenIFS forecast. A field can be wind, temperature or another forecast quantity, and its Fourier coefficients keep the same units as that field. A wave number counts complete waves around the row.

The transform separates each row into waves. Equation P01 defines coefficient $`c_k`$ of wave $`k`$, where $`x_j`$ is the field value at longitude position $`j`$. Positions run from 0 through 63, and stored wave numbers run from 0 through 32. The imaginary unit $`i`$ has square minus one.

```math
c_k=\frac{1}{64}\sum_{j=0}^{63}x_j\exp\left(-\frac{2\pi i j k}{64}\right).\tag{P01}
```

The forecast keeps wave numbers 0 through 21. Equation P02 removes the shorter waves, while wave 0 keeps the row mean.

```math
\widehat c_k=\begin{cases}c_k,&0\le k\le21,\\0,&22\le k\le32.\end{cases}\tag{P02}
```

There are 64 equally spaced longitude positions and 32 latitude rows. The input is the current row supplied by the forecast. The longitude boundary is periodic, so the position after the final point is the first point. The transform does not advance time.
