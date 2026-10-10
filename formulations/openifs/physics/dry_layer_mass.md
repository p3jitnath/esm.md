# Dry Atmospheric Layer Mass

Revision 1. The original routine is `radiation_thermodynamics::get_layer_mass`.

## The idea

Air pressure is the weight of the air above a horizontal area. The pressure increase across a layer therefore gives its dry mass per square metre. This calculation neglects the effect of water vapour.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`p_t`$ | Pressure at the top of a layer, Pa |
| $`p_b`$ | Pressure at the bottom of a layer, Pa |
| $`g`$ | Acceleration due to gravity, 9.80665 m s⁻² |
| $`m`$ | Dry mass per horizontal area, kg m⁻² |

## Equation

**P01. Mass from pressure**

```math
m=\frac{p_b-p_t}{g}
```

The bottom pressure is at least the top pressure, so the layer mass is nonnegative. Adding the masses of adjacent layers gives the mass between their outer pressure boundaries.

## Inputs and boundaries

Supply finite, nonnegative pressures that increase down each atmospheric column. The pressure at each interface is an input. This diagnostic calculation has no time update or lateral boundary condition.

The [md2asm contract](../../../skills/md2asm/references/openifs/physics/get_layer_mass.md) records the ordered arithmetic and assembly interface.
