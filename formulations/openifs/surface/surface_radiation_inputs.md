# Surface Radiation Inputs

Revision 1 follows OpenIFS SURFRAD_LAYER. Surface reflection and thermal emission depend on the weather, the season and the state of sea ice supplied by a coupled ocean model.

## The idea

Horizontal wind has an eastward component and a northward component. Their combined speed helps set the number of particles on which clouds can form. The forecast date selects seasonal sea-ice reflectivity, and an optional ocean model supplies the current ice reflectivity.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`u,v`$ | Eastward and northward wind at the lowest model level, in m s$`^{-1}`$ |
| $`w`$ | Combined horizontal speed, in m s$`^{-1}`$ |
| $`t`$ | Elapsed forecast time, in seconds |
| $`a_i`$ | Sea-ice reflectivity supplied by the ocean model, dimensionless |

## Equations

**P01. Horizontal speed**

```math
w=\sqrt{u^2+v^2}.
```

Squaring the two components and adding them gives the squared total speed. The square root returns the speed in its original units.

**P02. Forecast date**

```math
\mathrm{date}(t)=\mathrm{initial\ date}+t\ \mathrm{seconds}.
```

Each day has 86,400 seconds. The [calendar](../physics/calendar_days.md) gives the month lengths, and [coupled sea-ice fields](coupled_sea_ice.md) give the local ice reflectivity. These inputs feed the [surface-radiation model](surface_radiation.md).

## Parameters, initial state, and boundaries

Use finite wind components whose combined speed is at most 80 m s$`^{-1}`$. The initial date is a valid Gregorian date. Sea-ice reflectivity lies from zero to one when supplied. The selected columns belong to the local model block, and unselected columns keep their previous values.

The [md2asm contract](../../../skills/md2asm/references/openifs/surface/surfrad_layer.md) defines the complete numerical operation and memory interface.
