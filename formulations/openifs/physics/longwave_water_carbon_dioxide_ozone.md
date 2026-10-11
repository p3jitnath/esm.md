# Longwave Water, Carbon Dioxide And Ozone Absorption

Revision 1.0 describes thermal radiation from 630 to 700 cm$`^{-1}`$. A wavenumber counts wave cycles per centimetre. Water vapour and carbon dioxide absorb below the tropopause, the boundary above most weather. Ozone and carbon dioxide absorb above it. Supplied aerosols also absorb.

## Physical Inputs

Let $`X`$ be water below the tropopause or ozone above it, and let $`C`$ be carbon dioxide. Columns use the model's approximately $`10^{20}`$ molecules cm$`^{-2}`$ scaling. Let $`r_0,r_1`$ be the supplied dimensionless ratios that combine the two gases at neighbouring reference pressures. The line coefficients $`k_0,k_1`$ depend on the supplied pressure, temperature and gas mixture. Let $`C_s,C_f`$ be the dimensionless water self and foreign continuum depths, and $`A`$ the dimensionless aerosol depth.

## Basic Mathematics

The combined gas columns are $`Q_0,Q_1`$. Each contributes absorption through its own coefficient.

```math
Q_0=X+r_0C,\qquad Q_1=X+r_1C,\qquad
\tau_L=Q_0k_0+Q_1k_1+C_s+C_f+A. \tag{P01}
```

Higher layers use ozone and carbon dioxide, with no water continuum. Their supplied spectral correction is $`d_g`$, where $`g`$ identifies a representative spectral point.

```math
\tau_U=d_g(Q_0k_0+Q_1k_1+A). \tag{P02}
```

There are fourteen representative points. The first seven corrections equal one. The remaining seven are 0.92, 0.88, 1.07, 1.10, 0.99, 0.88 and 0.943. A supplied reference atmosphere also determines dimensionless Planck weights, which divide the band's thermal emission across these points.

## State And Boundaries

The leaf reads an existing atmospheric state. It does not advance time or calculate radiation transport through the complete atmosphere. The tropopause selects the lower or upper absorption data. The [md2asm contract](../../../skills/md2asm/references/openifs/physics/rrtm_taumol4.md) defines the numerical interpolation and complete assembly interface.
