# Even And Odd Latitude Components

Formulation revision 1.0 describes complete PRFI2B. A Fourier component describes how a field changes with longitude. This calculation combines that component at matching northern and southern latitudes before the latitude transform.

Let $`n`$ be the northern component and $`s`$ its southern partner. Each quantity has the unit of its input field, such as kelvin for temperature. The even combination $`e`$ keeps its sign when the hemispheres are exchanged.

```math
e=n+s. \tag{PRF-01}
```

The odd combination $`o`$ changes its sign when the hemispheres are exchanged.

```math
o=n-s. \tag{PRF-02}
```

Recover the original samples with $`n=(e+o)/2`$ and $`s=(e-o)/2`$. At an equatorial point, both samples are the same, so the odd combination is zero.

The inputs are the supplied longitude components and matching latitude pairs. The grid can omit outer latitude pairs for a selected longitude wave. There is no time update or new boundary condition. The [md2fort contract](../../../skills/md2fort/references/openifs/dynamics/latitude_parity.md) records the original packing, rounded arithmetic and interface.
