# OpenIFS state-change rates

Revision 1.0 describes the wind, temperature and tracer rates used by GPMKTEND in OpenIFS 48.1.1.

## The idea

A tendency is the rate at which a state changes. The dynamics calculates a later atmospheric state, and the physics schemes need the change per second. This calculation connects those two parts of the forecast.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`X`$ | A wind component in metres per second, temperature in kelvin or a tracer mass fraction in kilograms per kilogram |
| $`S_X`$ | Rate of change of $`X`$ per second |
| $`\Delta t`$ | Positive time interval in seconds |
| $`\Delta X`$ | Change in $`X`$ over that interval, in the same units as $`X`$ |

A tracer is a material carried by the air, such as water vapour or another atmospheric constituent. Wind tendencies use metres per second squared, temperature tendencies use kelvin per second and tracer tendencies use kilograms per kilogram per second.

## Equations

**P01. State-change rate**

```math
\frac{dX}{dt}=S_X.
```

**P02. Constant change over an interval**

```math
\Delta X=S_X\Delta t.
```

The second equation relates a constant rate to the resulting change. The md2asm contract defines how the supplied earlier and later states give the average rate for the interval.

## Parameters, initial state, and boundaries

Use the positive interval and the two states supplied by the forecast. Include the tracers selected by its configuration, preserving their units. A state that does not change has a zero tendency. This local calculation does not move material between cells. The complete ordered update belongs in the [md2asm contract](../../../skills/md2asm/references/openifs/dynamics/gpmktend.md).
