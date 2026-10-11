# Snow Density

Snow becomes denser under its own weight, changes in ice crystals, absorbed liquid water and wind. This model follows the density of each snow layer in kilograms per cubic metre.

## Basic Mathematics

Let $`\rho`$ be snow density, $`m`$ be snow mass per unit ground area in kilograms per square metre, and $`V=m/\rho`$ be snow volume per unit ground area in metres. Fresh snowfall adds mass $`m_f`$ with density $`\rho_f`$ to the top layer.

```math
\rho_{\mathrm{mix}}=\frac{m+m_f}{m/\rho+m_f/\rho_f}.
```

SN-RHO-02 mixes the old snow and fresh snow through their total mass and volume. The minimum denominator used when both masses are zero belongs to the solver contract.

Let $`T`$ be the near-surface air temperature in kelvin and $`U=\sqrt{u^2+v^2}`$ be wind speed in metres per second. The model estimates fresh-snow density with SN-RHO-01.

```math
\rho_f=\max\left(50,\ 109+6(T-273.16)+26\sqrt{U}\right).
```

Let $`r_o`$, $`r_m`$ and $`r_w`$ be positive rates in inverse seconds from snow weight, crystal changes and retained water. Let $`r_c`$ be the wind compaction rate in kilograms per cubic metre per second. SN-RHO-03 describes how these processes increase density.

```math
\frac{\mathrm d\rho}{\mathrm dt}=\rho(r_o+r_m+r_w)+r_c.
```

## Parameters, Initial State and Boundaries

| Quantity | Value or input |
| --- | --- |
| Minimum fresh-snow density | 50 kg m⁻³ |
| Density in a cell with no snow | 100 kg m⁻³ |
| Density limit for a nonempty updated layer | 500 kg m⁻³ |
| Freezing reference temperature | 273.16 K |
| Fresh-snow coefficients | 109 kg m⁻³, 6 kg m⁻³ K⁻¹ and 26 kg m⁻³ (m s⁻¹)⁻¹ᐟ² |
| Initial state | Layer density, snow mass, temperature and liquid-water mass |
| Surface input | Snowfall, wind and near-surface temperature |

Snowfall enters through the upper boundary. The pressure and wind calculations proceed from the top layer to the bottom layer. A cell with no snow receives the reference density, and cells outside the selected region keep their incoming values. Revision 1 preserves SN-RHO-01 to SN-RHO-03.
