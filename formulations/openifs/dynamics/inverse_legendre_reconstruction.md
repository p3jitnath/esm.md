# Inverse Legendre Reconstruction

Revision 2 describes `LEINV_MOD::LEINV`. This calculation converts spherical-harmonic coefficients into latitude-dependent Fourier fields. A spherical harmonic is a wave pattern on a sphere, and the associated Legendre function gives its latitude pattern. Fourier fields describe the east–west waves before their final conversion to physical grid values.

For zonal order $`m`$, degree $`n`$, latitude coordinate $`\mu=\sin\phi`$, spectral coefficient $`c_n^m`$ and dimensionless normalised associated Legendre function $`P_n^m`$, latitude reconstruction adds the contribution of each degree. Latitude $`\phi`$ is measured in radians, while $`\mu`$ is dimensionless. The coefficients and the reconstructed field $`f_m`$ have the same units.

```math
f_m(\mu)=\sum_n c_n^m P_n^m(\mu). \tag{LEINV-1}
```

The source stores even and odd north–south parity separately. A symmetric field has the same value at opposite latitudes, while an antisymmetric field changes sign. `LEINV` reconstructs both halves, and the accepted hemisphere routine combines them by addition in the north and subtraction in the south.

The selected forecast truncation is 21, with 32 Gaussian latitudes and 16 positions in each hemisphere. Gaussian latitudes are chosen for accurate integration. Orders are 0 through 21. Order zero has no east–west variation, so its imaginary output components are positive zero. The original input state is the supplied spectral coefficient buffer and the unchanged normalised basis tables. Only the supplied northern latitude range is reconstructed; the subsequent hemisphere routine supplies the matching southern field.
