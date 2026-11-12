# Tabulated Thermal Radiation

Revision 1.0 describes thermal emission at atmospheric layer faces and at the surface. A black body absorbs all incoming radiation and emits radiation according to its temperature. This model uses stored band averages of Planck's law, which describes that thermal spectrum.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`T`$ | Temperature, K |
| $`b`$ | A spectral band, which is a range of wavenumbers |
| $`\Delta\nu_b`$ | Band width, cm⁻¹ |
| $`\overline{J}_b(T)`$ | Mean radiance in the band, W cm⁻² sr⁻¹ (cm⁻¹)⁻¹ |
| $`E_b(T)`$ | Emitted energy flux in the band, W m⁻² |
| $`p_g`$ | Fraction assigned to spectral point $`g`$, dimensionless |
| $`P_g(T)`$ | Emitted energy flux assigned to that point, W m⁻² |

Wavenumber is the number of waves per unit distance. A steradian, written sr, measures solid angle. The factor $`\pi`$ converts isotropic radiance into upward flux, and $`10^4`$ converts square centimetres into square metres.

## Equations

**P01. Band Emission**

```math
E_b(T)=\pi\,10^4\,\Delta\nu_b\,\overline{J}_b(T).
```

Each band contains part of the thermal energy emitted at temperature $`T`$.

**P02. Spectral Partition**

```math
P_g(T)=p_g E_{b(g)}(T),\qquad \sum_{g\in b}p_g=1.
```

The fractions divide a band's energy among its spectral points without creating or removing energy. The function $`b(g)`$ identifies the band of point $`g`$.

## Inputs And Boundaries

The unchanged RRTMG model supplies 16 band widths, radiance tables at 181 temperatures from 160 K to 340 K, spectral fractions and band maps. The current forecast uses 140 longwave spectral points. Atmospheric temperatures are supplied at layer faces, and surface temperatures are supplied separately. Columns are independent. The model caps temperatures below the table range and extrapolates above its upper interpolation interval, with those limits stated in the [solver contract](../../../skills/md2fort/references/openifs/physics/planck_functions.md).
