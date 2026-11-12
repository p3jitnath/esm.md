# OpenIFS surface-state change

Revision 1.0 describes the surface-state change used by CPSPE in OpenIFS 48.1.1. This note covers one part of the forecast model.

## The idea

The surface includes soil, snow, lakes and the upper ocean. Other physics calculations supply each field's tendency, which means its rate of change. For example, a positive temperature tendency warms the surface. This update applies those supplied tendencies without calculating their physical causes.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`t`$ | Time in seconds |
| $`q`$ | A surface quantity with its declared unit $`U_q`$ |
| $`r_q`$ | Supplied rate of change of $`q`$, in $`U_q\,\mathrm{s}^{-1}`$ |
| $`T_s`$ | Surface temperature in kelvin |
| $`r_T`$ | Supplied temperature tendency in kelvin per second |

Each field has its own unit. Temperature fields use kelvin, and lake thickness fields use metres. A generic extra field keeps the unit declared by the process that owns it.

## Equations

**P01. Change from a supplied tendency**

```math
\frac{dq}{dt}=r_q.
```

The derivative on the left is the rate of change of the surface quantity. A positive tendency increases that quantity, and a negative tendency decreases it.

**P02. Surface-temperature example**

```math
\frac{dT_s}{dt}=r_T.
```

OpenIFS supplies the temperature tendency from its surface physics. The update itself introduces no extra heat source.

## Parameters, initial state, and boundaries

Initial states, tendencies and the effective time interval come from the calling forecast. This update has no fixed physical parameters and does not choose a new initial condition. Columns are updated independently, with no transport across their edges.

The [md2fort contract](../../../skills/md2fort/references/openifs/surface/cpspe.md) records the upstream discrete update, field layouts and exact arithmetic. The [source routine](https://github.com/ecmwf-ifs/openifs/blob/main/ifs-source/arpifs/phys_ec/cpspe.F90) documents the field interface. The local OpenIFS 48.1.1 source is the implementation reference.
