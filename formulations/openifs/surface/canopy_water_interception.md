# Canopy Water Interception

Revision 1 describes water held on vegetation. A canopy is the collection of leaves and branches above the ground. It receives rain and dew, loses water by evaporation and passes the remaining rain to the soil.

| Symbol | Meaning | Unit |
|---|---|---|
| $`W`$ | Water stored on vegetation | kg m$`^{-2}`$ |
| $`C`$ | Maximum water storage | kg m$`^{-2}`$ |
| $`f_i`$ | Ground fraction of surface type $`i`$ | 1 |
| $`E_i`$ | Moisture flux for surface type $`i`$, positive toward the surface | kg m$`^{-2}`$ s$`^{-1}`$ |
| $`P`$ | Rainfall rate | kg m$`^{-2}`$ s$`^{-1}`$ |
| $`T`$ | Rainfall that reaches the soil | kg m$`^{-2}`$ s$`^{-1}`$ |
| $`v`$ | Vegetation cover fraction | 1 |
| $`a`$ | Fraction of intercepted rain | 1 |

## Water Balance

CW-1 gives the canopy water change during one interval. A surface type is one part of a model cell, such as wet vegetation, bare soil or an urban area.

```math
W'-W=\Delta t\left(\sum_i F_i+P-T\right).
```

Here $`F_i`$ is the moisture flux actually stored by the canopy. Evaporation cannot remove more water than the canopy holds. Dew and rain cannot add more water than its remaining capacity.

CW-2 gives the rain mass stored before a second rain source is processed.

```math
I=\min(C-W,\Delta t\,Pva),\qquad
W'=W+I,\qquad T=P-\frac{I}{\Delta t}.
```

Convective rain falls over a fraction $`s`$ of the ground. Apply CW-2 to the local rain rate $`P/s`$ and multiply the stored mass by $`s`$ to obtain its ground average. Process large-scale rain first and convective rain second.

## Inputs And Boundaries

The forecast supplies the previous storage, capacity, time interval, vegetation fractions, surface type fractions, rain and evaporation rates. Fractions lie from zero to one, capacity and time are positive, and rain is nonnegative. Forest snow evaporation is removed from the high-vegetation snow moisture flux before dew is collected. Dew can enter through wet vegetation, low vegetation, high vegetation, forest snow, bare soil and urban surfaces.

Use the configured water-balance repair to limit the initial storage to the physical range. The legacy option restores the previous storage after recording that initial repair, and verification accounts for this restored amount separately. For sea columns, canopy storage and canopy evaporation are zero, and rainfall passes through unchanged.
