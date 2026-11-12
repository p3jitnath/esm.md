# Longwave Atmospheric Inputs

Revision 1.0 prepares each air layer for thermal absorption.

## Physical Idea

Water, carbon dioxide, ozone and other gases absorb thermal radiation. Their interaction strengths depend on the layer's pressure, temperature and molecular amounts. Molecules of other gases also change absorption, so the calculation keeps their total amount separately.

## Basic Maths

Let N_d be the dry-air column and N_w the water-vapour column, both in molecules per square centimetre. The total molecular column is N_m. Let p be pressure in hPa and T temperature in kelvin.

```math
N_m = N_d + N_w,
\qquad
s = \frac{p}{1013}\frac{296}{T},
\qquad
w = \frac{N_w}{N_d}. \qquad \text{[LAI-1]}
```

The factors f and a separate water interactions with other gases from water's own interactions.

```math
f = \frac{s}{1+w},
\qquad
a = wf. \qquad \text{[LAI-2]}
```

A small carbon-dioxide correction accounts for the departure from a supplied reference amount. Its temperature factor decreases at lower temperatures.

```math
C = (N_{\mathrm{CO_2}}-N_{\mathrm{ref}})
\frac{272.63\exp(-1919.4/T)}{(8.7604\times10^{-4})T}. \qquad \text{[LAI-3]}
```

Here the carbon-dioxide amounts use the model's scaled molecular units. The constants 1919.4 and 272.63 have units K and K respectively, and 8.7604 × 10⁻⁴ is dimensionless. The [md2fort contract](../../../skills/md2fort/references/openifs/physics/rrtm_setcoef_140gp.md) records the reference amount and gas scaling.

## Inputs And Boundaries

Supply each layer's pressure, temperature, dry-air amount, broadening-gas amount and selected gas amounts. Require positive pressure, temperature and dry-air amount, with nonnegative gas amounts. Preparation has no horizontal exchange. Rows outside the supplied layer range retain their initial output state.
