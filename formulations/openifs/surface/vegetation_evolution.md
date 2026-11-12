# Vegetation evolution

Revision 1 describes the original SRFVEGEVOL update. A land column can contain several vegetation types, called tiles. Each tile carries leaves and structural material, such as stems and roots. The routine combines the tile values to describe the whole column.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`L_i`$ | Leaf area divided by ground area on tile $`i`$, square metres per square metre |
| $`s_i`$ | Leaf biomass per unit leaf area, kilograms per square metre of leaf |
| $`A_i`$ | Active leaf biomass, kilograms per square metre of ground |
| $`S_i,D_i`$ | Above-ground and below-ground structural biomass, kilograms per square metre of ground |
| $`v_i`$ | Fraction of ground covered by tile $`i`$, from 0 to 1 |
| $`w`$ | Weight of the evolving leaf state, from 0 to 1 |
| $`L_{c,i}`$ | Supplied seasonal leaf area, square metres per square metre |
| $`\Delta t`$ | Supplied physics time interval, seconds |

## Equations

**P01. Leaf area supplies active biomass.**

```math
A_i=s_i\left[wL_i+(1-w)L_{c,i}\right].
```

The supplied leaf mass converts leaf area to biomass. When $`w=0`$, the seasonal state supplies all active biomass. A positive weight also selects the complete [nitrogen decline update](nitrogen_decline.md), followed by the original daily leaf-gain update.

**P02. Tile values supply column values.**

```math
\overline{q}=\sum_i v_i q_i.
```

This equation gives the column leaf area, active and structural biomass, and biomass loss and gain. The uncovered part of the column contributes zero.

**P03. State changes supply tendencies.**

```math
\dot q_{\mathrm{new}}=\dot q_{\mathrm{old}}
+\frac{q_{\mathrm{new}}-q_{\mathrm{saved}}}{\Delta t}.
```

A tendency is a rate of change. This equation adds the returned leaf or structural change to the supplied tendency. Leaf tendencies have units per second; structural tendencies have units kilograms per square metre per second.

## Parameters, initial state, and boundaries

The caller supplies the initial state, vegetation tables, cover fractions, time interval and step number. The day has 86400 seconds. The selected physical scope uses 2 to 10 vegetation tiles, 2 to 4 soil layers and a time interval from 1 to 86400 seconds. Leaf area is from 0 to 20 and consumed temperatures are from 140 to 360 K.

The original step-zero branch clears accumulated respiration, biomass loss and biomass gain and saves the initial active biomass. The daily branch applies the supplied carbon-dioxide assimilation after conversion to biomass. Each land column is independent; there is no exchange across column boundaries.

The [solver contract](../../../skills/md2fort/references/openifs/surface/srfvegevol.md) records the original update order, complete storage interface and actual checks. This is a per-call model update; the checks do not establish biological accuracy of the caller's time schedule.
