# Shortwave Atmospheric Inputs

Revision 1.0 prepares each air layer for the absorption and scattering equations.

## Physical Idea

Gas molecules absorb radiation, while air molecules also scatter it. The absorption depends on pressure and temperature. Water vapour also interacts with itself and with the other gases, so those two contributions need separate amounts.

## Basic Maths

Let N_d be the dry-air column and N_w the water-vapour column, both in molecules per square centimetre. The total molecular column N_m includes both amounts.

```math
N_m = N_d + N_w. \qquad \text{[SAI-1]}
```

Let p be layer pressure in hPa and T temperature in kelvin. The dimensionless factor s compares the layer density with dry air at 1013 hPa and 296 K. Water abundance w is the ratio of water molecules to dry-air molecules.

```math
s = \frac{p}{1013}\frac{296}{T},
\qquad
w = \frac{N_w}{N_d}. \qquad \text{[SAI-2]}
```

The factors f and a separate interactions with other gases from water's own interactions.

```math
f = \frac{s}{1+w},
\qquad
a = wf. \qquad \text{[SAI-3]}
```

## Inputs And Boundaries

Supply each layer's pressure, temperature, dry-air amount and molecular amounts for water, carbon dioxide, ozone, methane and oxygen. Require positive pressure, temperature and dry-air amount, with nonnegative gas amounts. Only columns receiving the Sun's radiation need this preparation. Other columns retain their supplied output state.

The [md2fort contract](../../../skills/md2fort/references/openifs/physics/srtm_setcoef.md) records the table interpolation and the model's gas units.
