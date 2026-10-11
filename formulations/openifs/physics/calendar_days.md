# Calendar Days

Revision 1 follows the calendar used by OpenIFS UPDCAL. Calendar dates select seasonal surface properties, such as the reflectivity of sea ice.

## The idea

A date advances by a whole number of days. Each month has a fixed length, except February, which has one extra day in a leap year. The Gregorian rule gives a leap year every four years, with an exception for century years unless the year is divisible by 400.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`d,m,y`$ | Day of month, month number and year, dimensionless integers |
| $`n`$ | Number of days added, in days |
| $`L_m(y)`$ | Number of days in month $`m`$ of year $`y`$ |

## Equations

**P01. Leap year**

```math
\mathrm{leap}(y)=[4\mid y]\land([100\nmid y]\lor[400\mid y]).
```

The square brackets mean that the statement is true. A true leap-year statement makes February 29 days long.

**P02. Date update**

```math
\mathrm{date}_1=\mathrm{date}_0+n\ \mathrm{days}.
```

An added day moves to the first day of the next month when the current month ends, and December moves to January of the next year.

## Parameters, initial state, and boundaries

The initial date is valid and has year 1600 through 3000. The qualified forward update adds at most 36,600 days. A backward update stays within its initial year. The result includes the final date and the lengths of all twelve months. There are no spatial boundaries.

The [md2asm contract](../../../skills/md2asm/references/openifs/physics/updcal.md) defines the exact integer steps and memory interface.
