# Fourier Hemisphere Reconstruction

Revision 1 uses the same equations as OpenIFS ASRE1B.

A Fourier coefficient describes one wave in a field, such as wind or temperature. For matching northern and southern latitudes, the symmetric part has the same value in both hemispheres. The antisymmetric part has opposite signs. Each coefficient has the units of its original field.

Let $`S`$ be the symmetric coefficient and $`A`$ the antisymmetric coefficient. The northern value $`N`$ and southern value $`T`$ are

```math
N = S + A, \qquad T = S - A. \tag{FR1}
```

These equations reconstruct the original field from its two parts. Conversely, $`S=(N+T)/2`$ and $`A=(N-T)/2`$.

Use paired Gaussian latitudes, which are the latitudes used by this OpenIFS spectral grid. The caller supplies the active waves and their coefficients. Preserve every coefficient outside the selected wave and latitudes. This step has no time update, initial condition or physical boundary flux.
