# Shortwave Absorption By Water, Oxygen And Ozone

Revision 1.0 describes sunlight with wavenumbers from 12,850 to 16,000 cm$`^{-1}`$. A wavenumber is the number of wave cycles per centimetre. Water vapour, oxygen and ozone absorb this radiation, while air molecules scatter part of it. The supplied table data represent these measured gas properties.

## Physical Inputs

Let $`W`$, $`O`$ and $`Z`$ be the water, oxygen and ozone columns in the model's approximately $`10^{20}`$ molecules cm$`^{-2}`$ scaling. Let $`N`$ be the total air column in the same scaling. Temperature and pressure select absorption coefficients from the supplied data. The tropopause separates lower and upper atmospheric layers. A positive solar zenith cosine selects daylight.

## Basic Mathematics

In a lower layer, combine water and oxygen with the fixed ratio $`r=0.124692`$ and use their fraction to select the table mixture.

```math
Q=W+rO,\qquad s=\frac{W}{Q}. \tag{P01}
```

Let $`k_L`$ be the lower mixture absorption coefficient, $`k_{Z,L}`$ the ozone coefficient and $`c_s,c_f`$ the water self and foreign continuum coefficients. A continuum describes broad absorption between individual spectral lines. The lower absorption depth is

```math
\tau_L=Qk_L+Zk_{Z,L}+W(c_s+c_f). \tag{P02}
```

The upper layer uses oxygen and ozone, with supplied coefficients $`k_U,k_{Z,U}`$.

```math
\tau_U=Ok_U+Zk_{Z,U}. \tag{P03}
```

Let $`R(s)`$ be the lower molecular-scattering coefficient for the mixture and $`R_U`$ its upper value. Let $`S(s)`$ be the incident solar flux at the selected lower reference layer, in W m$`^{-2}`$.

```math
\tau_R=NR(s)\quad\text{or}\quad NR_U,\qquad F_\odot=S(s). \tag{P04}
```

Optical depths are dimensionless and measure how strongly a layer attenuates radiation. Eight representative spectral points describe this interval. Night layers retain their supplied state. This leaf does not advance time or solve transport through the complete atmosphere.
