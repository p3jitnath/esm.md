# OpenIFS surface exchange

Revision 1.0 describes the basic surface energy and water balances in OpenIFS 48.1.1.

## The idea

The surface receives radiation and exchanges heat and water with the air. OpenIFS represents different surface types as tiles. Each tile occupies a known fraction of the grid cell.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`R,H,F_L,G`$ | Net incoming radiation, upward heat, upward latent heat and heat into the ground, in watts per square metre |
| $`E,L`$ | Upward water flux in kilograms per square metre per second and phase-change energy in joules per kilogram |
| $`\lambda,T_s,T_b`$ | Surface conductance in watts per square metre per kelvin and skin and underlying temperatures in kelvin |
| $`a_i,X_i,\overline X`$ | Tile area fraction, tile flux and grid-cell average flux |

## Equations

**P01. Skin energy balance**

```math
R=H+F_L+G,
\qquad
F_L=L E.
```

The latent heat flux is the phase-change energy multiplied by the water flux. The surface skin balances incoming radiation against the three outgoing energy terms.

**P02. Heat passed to the material below**

```math
G=\lambda(T_s-T_b).
```

A warmer skin transfers heat downwards. The configured surface type determines the conductance.

**P03. Combine the tiles**

```math
\overline X=\sum_i a_iX_i,
\qquad
\sum_i a_i=1.
```

Each tile contributes according to its area, so the average retains the flux units.

## Parameters, initial state, and boundaries

Tile fractions, vegetation, surface conductance, emissivity and starting temperatures come from the upstream state and configuration. Preserve their values. Soil, snow, lakes and sea ice store the energy and water received beneath the skin. Their separate balances require the corresponding model contracts.

The local SURFSEB and surfseb_ctl_mod sources define the skin balance and tile coupling, identified by the [source record](../../../src/openifs/README.md). Aerodynamic exchange, evaporation limits and coupling details belong in md2asm contracts.
