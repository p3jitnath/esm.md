# Physics increments

Revision 1.0 describes how a known physical rate changes a state over a short time. Wind has units of metres per second, temperature has units of kelvin, and a mass fraction has units of kilograms per kilogram. A tendency is the rate of change of one of these quantities per second.

## Basic mathematics

Let $`X`$ be a state and $`S_X`$ its tendency. For example, a heating rate of 0.001 kelvin per second raises temperature by 3.6 kelvin over one hour.

```math
\frac{dX}{dt}=S_X. \tag{OIFS-I1}
```

A constant rate acting for $`\Delta t`$ seconds produces the following change.

```math
\Delta X=S_X\Delta t. \tag{OIFS-I2}
```

## Supplied state and boundaries

The calling forecast supplies the state, physical tendencies and time interval. Use each quantity's stated units. The first forecast step may skip this increment because its initial state is prepared separately. Only the supplied atmospheric columns and levels change, and boundary storage keeps its earlier state.

The [md2fort contract](../../../skills/md2fort/references/openifs/physics/gpaddslphy.md) records the complete GPADDSLPHY update and its exact arithmetic.
