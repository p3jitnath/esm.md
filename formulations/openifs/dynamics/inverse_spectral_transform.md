# Inverse Spectral Transform

Formulation revision 2. A weather model can store its fields as waves on a sphere. This step turns those wave sizes into Fourier coefficients at each latitude. It also derives wind from vorticity and divergence, which describe rotation and expansion of horizontal flow. It performs no time update.

Let $`m`$ be the east–west wave order and $`n`$ the degree, which also describes latitude variation. Let $`N`$ be the highest degree carried by the working field. Let $`c_{n,m}`$ be a field's spectral coefficient and $`P_{n,m}(\mu)`$ its dimensionless associated Legendre pattern at $`\mu=\sin(\phi)`$, where $`\phi`$ is latitude.

```math
f_m(\phi)=\sum_{n=m}^{N}c_{n,m}P_{n,m}(\sin\phi).
\tag{IS1}
```

A coefficient and its reconstructed working field have the same units. Temperature uses kelvin, while vorticity and divergence use inverse seconds. The wind calculation first forms working fields $`U_c=a\cos\phi\,u`$ and $`V_c=a\cos\phi\,v`$. Here $`a`$ is the sphere's radius in metres, and $`u,v`$ are wind speeds in metres per second, so $`U_c,V_c`$ use square metres per second. Later stages convert them into wind speeds. A scalar derivative uses $`D f=\cos\phi\,\partial f/\partial\phi`$, which preserves the field's units and stays finite at the poles. These equations are explained in the [latitude and wind formulation](spectral_latitude_operators.md).

Use truncation 21 and 32 Gaussian latitude positions. The northern and southern values combine the antisymmetric half $`A`$, which changes sign across the equator, and symmetric half $`S`$, which keeps its sign.

```math
f_{\mathrm{north}}=A+S,\qquad f_{\mathrm{south}}=S-A.
\tag{IS2}
```

The input is the complete captured spectral state and accepted dimensionless basis tables. Longitude is periodic and the spherical basis supplies pole behaviour. The md2asm contract records the representation, ordered arithmetic, field maps, complete output bytes and checked bounds.
