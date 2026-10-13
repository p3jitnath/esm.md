# Radiation Field Preparation

Revision 1 describes the physical inputs and outputs of `RADIATION_SCHEME`. It prepares a supplied weather state for the accepted radiation calculation, then returns energy fluxes for the atmosphere and surface. A flux is energy crossing one square metre each second, measured in W m⁻². This calculation does not advance time.

Pressure is $`p`$ in Pa, temperature is $`T`$ in K, and a mass mixing ratio $`q`$ is the mass of a substance divided by the mass of air in kg kg⁻¹. The supplied state contains cloud, gas and aerosol fields. An aerosol is a small particle suspended in air. Each layer lies between an upper and a lower pressure boundary.

Use gravity $`g=9.80665`$ m s⁻². The layer mass per unit area $`M`$ neglects the small effect of humidity.

```math
M=\frac{p_{\mathrm{lower}}-p_{\mathrm{upper}}}{g}. \tag{R1}
```

Combine cloud ice and snow for the ice optical calculation. Convert effective particle radii $`r_{\mu\mathrm m}`$ from micrometres to metres, and cloud overlap length $`L_{\mathrm{km}}`$ from kilometres to metres. The overlap length describes how quickly cloud patterns become less alike with height.

```math
q_{\mathrm{ice,total}}=q_{\mathrm{ice}}+q_{\mathrm{snow}},\qquad
r_{\mathrm m}=10^{-6}r_{\mu\mathrm m},\qquad L_{\mathrm m}=10^3L_{\mathrm{km}}. \tag{R2}
```

The radiation calculation supplies upward flux $`F_{\uparrow}`$ and downward flux $`F_{\downarrow}`$. Their difference gives the downward net flux. A spectral band is a selected interval of wavelengths. Supplied weights $`w_b`$ combine band fluxes into ultraviolet or photosynthetically active radiation, which is the radiation used by plants.

```math
F_{\mathrm{net}}=F_{\downarrow}-F_{\uparrow},\qquad
F_{\mathrm{weighted}}=\sum_b w_bF_b. \tag{R3}
```

The input also supplies the surface temperature, reflectivity, emissivity, Sun’s radiation and solar angle. Reflectivity and emissivity have no units. At the top boundary, incoming solar radiation follows the solar angle and incoming thermal radiation is zero. The surface absorbs, reflects and emits energy through the accepted inner radiation model. The initial state is the supplied weather state, and all unselected columns retain their incoming outputs.
