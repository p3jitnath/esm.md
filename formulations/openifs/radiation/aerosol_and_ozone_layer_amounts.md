# Aerosol and Ozone Layer Amounts

Revision 1. RADACT prepares the aerosol and ozone fields used by radiation. An aerosol is a small particle suspended in air. The selected forecast uses monthly aerosol climate tables and a prescribed ozone column, with no volcanic event or random perturbation.

Pressure $`p`$ is in pascals (Pa), and gravity $`g`$ is in metres per second squared. A layer lies between an upper pressure $`p_u`$ and a larger lower pressure $`p_l`$. Its air mass per unit area, $`m`$ in kilograms per square metre, follows from hydrostatic balance.

```math
m = \frac{p_l-p_u}{g}. \tag{AAD1}
```

The monthly tables provide an aerosol column mass $`M_j`$ for each species $`j`$, in kilograms per square metre. Nearby latitude and longitude values determine its value at the forecast location. The dimensionless cumulative profile $`F_j(p)`$ gives the fraction of that mass above pressure $`p`$.

```math
A_j(p) = M_j F_j(p). \tag{AAD2}
```

The weight $`w`$, between zero and one, selects the part below the stratosphere, which is the upper region of the atmosphere. The aerosol mass mixing ratio $`q_j`$ is aerosol mass divided by the air mass in the layer, in kilograms per kilogram.

```math
q_j = w\frac{A_j(p_l)-A_j(p_u)}{m}. \tag{AAD3}
```

For ozone, $`Q`$ is the total pressure-weighted column amount in Pa. The shape parameter $`H`$ has units of $`\mathrm{Pa}^{3/2}`$. The cumulative amount $`O(p)`$ grows with pressure, so its difference gives the ozone amount in each layer.

```math
O(p) = Q\frac{p^{3/2}}{p^{3/2}+H},
\qquad
O_{\mathrm{layer}} = O(p_l)-O(p_u). \tag{AAD4}
```

The other returned aerosol fields describe optical depth, a dimensionless measure of how strongly particles block radiation. Each field has the prescribed lower limit $`\tau_{\min}`$.

```math
\tau_{\mathrm{returned}}=\max(\tau,\tau_{\min}). \tag{AAD5}
```

The fixed gravity is 9.80665 metres per second squared. The optical-depth floor is 1e-12, which is dimensionless. The temperature-profile exponent is 30, and the upper-region threshold is 999 Pa.

The input is the captured climate tables, cumulative profiles, non-negative boundary pressures, temperatures in kelvin, and coordinates on the original unrotated grid. The calculation starts at a top pressure of zero and proceeds towards the surface. It changes only selected output columns. All prescribed input tables remain unchanged.

The [solver contract](../../../skills/md2asm/references/openifs/radiation/aerosol_and_ozone_preparation.md) records the interpolation and complete ordered calculation.
