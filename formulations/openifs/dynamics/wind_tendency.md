# Horizontal wind tendencies

Revision 1.0 describes how pressure, Earth's rotation and damping change horizontal wind. Let $`U`$ and $`V`$ be wind components in metres per second. Their rates of change use metres per second squared.

## Basic equations

The supplied pressure terms $`G_L`$ and $`G_M`$ are accelerations. The Coriolis parameter $`f`$ measures the effect of Earth's rotation and has units of inverse seconds. The damping accelerations are $`F_U`$ and $`F_V`$.

```math
\frac{dU}{dt}=-G_L+fV+F_U,\qquad
\frac{dV}{dt}=-G_M-fU+F_V. \tag{OIFS-W1}
```

Coriolis acceleration changes the direction of motion. It does no work on the wind because its acceleration is perpendicular to the velocity.

## Damping and supplied state

Rayleigh damping removes motion at a rate $`r`$, in inverse seconds. Isotropic damping acts equally on both wind components.

```math
F_U=-rU,\qquad F_V=-rV. \tag{OIFS-W2}
```

Directional damping acts only across the local north direction. Let $`l`$ and $`m`$ be the dimensionless components of the north unit vector. With $`w=mU-lV`$, the damping is

```math
F_U=-rmw,\qquad F_V=rlw. \tag{OIFS-W3}
```

The forecast supplies the current wind, pressure terms, direction and damping rate at each atmospheric level. A separate gravity-wave scheme may replace this damping. Only the supplied columns and levels change. Use the same coordinate scale for wind and acceleration.

The [md2asm contract](../../../skills/md2asm/references/openifs/dynamics/wind_tendency.md) records the complete GP_TNDLAGADIAB_UV update and preserves the upstream arithmetic.
