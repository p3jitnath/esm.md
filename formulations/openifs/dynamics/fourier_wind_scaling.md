# Fourier Wind Scaling

Revision 1 describes the latitude factor used by OpenIFS LDFOU2. A Fourier coefficient describes part of a field's variation with longitude. The symmetric part has the same value in the two hemispheres, while the antisymmetric part changes sign.

Let $`a`$ be Earth's radius in metres and $`\theta`$ be latitude in radians. The radius is 6371229 m for the frozen forecast. Let $`A`$ and $`S`$ be antisymmetric and symmetric wind coefficients in metres per second. The given latitude factor is $`r=1/(a\cos\theta)`$, in inverse metres.

```math
\tag{FW1}
\widetilde A=rA,\qquad
\widetilde S=rS,\qquad
r=\frac{1}{a\cos\theta}.
```

This equation converts linear wind coefficients to angular rates in inverse seconds. Apply it to the wind fields and latitudes selected for the given wave number. Keep other coefficients unchanged. The longitude coordinate is periodic, and the Gaussian latitudes remain away from the poles, so $`\cos\theta>0`$. The existing forecast supplies the initial Fourier coefficients and latitude factors.
