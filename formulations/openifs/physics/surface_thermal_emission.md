# Surface Thermal Emission

Revision 1 describes the heat radiation emitted by a surface at temperature $` T `$, measured in kelvin. A warmer surface emits more energy. The model divides this radiation into sixteen frequency bands.

For a black surface, power per unit area per unit wavenumber is

```math
B_\kappa(T)=\frac{2\pi h c^2\kappa^3}{\exp(hc\kappa/(k_\mathrm{B}T))-1}. \tag{PFS-1}
```

Wavenumber $`\kappa`$ is inverse wavelength, measured in inverse metres. Planck's constant is $`h=6.62607015\times10^{-34}`$ joule seconds, light speed is $`c=299792458`$ metres per second, and Boltzmann's constant is $`k_\mathrm{B}=1.380649\times10^{-23}`$ joules per kelvin.

A band receives the integral of this spectrum over its wavenumber range. A supplied fraction $`w_g`$ assigns the band's radiation to spectral point $`g`$.

```math
F_g(T)=w_g\int_{\text{band }g}B_\kappa(T)\,\mathrm d\kappa. \tag{PFS-2}
```

The resulting flux $`F_g`$ is in watts per square metre. Fractions have no units and sum to one within each complete band. The last band includes the high-wavenumber tail above 2600 inverse centimetres. The existing RRTM tables supply the band integrals.

The forecast supplies surface temperature and spectral fractions for each selected column. This calculation has no time update or spatial boundary. The [md2fort contract](../../../skills/md2fort/references/openifs/physics/planck_function_surf.md) records the original table interpolation and array interface.
