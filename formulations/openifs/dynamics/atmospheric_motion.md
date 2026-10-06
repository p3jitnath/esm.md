# OpenIFS atmospheric motion

Revision 1.0 describes the basic atmospheric equations of the hydrostatic OpenIFS 48.1.1 forecast.

## The idea

Weather changes as moving air carries mass, heat and water around the Earth. Pressure differences accelerate the air, while Earth's rotation changes its direction. Radiation, clouds and the surface supply additional heating, cooling and forces.

A derivative measures a rate of change. The material derivative follows a moving parcel of air, while a partial derivative changes one variable with the others fixed. A horizontal gradient points towards increasing values. A divergence measures how much flow leaves a small region.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`t,\eta`$ | Time in seconds and the vertical coordinate, with no unit |
| $`\mathbf{v}_h`$ | Horizontal air velocity in metres per second |
| $`\dot\eta`$ | Rate of change of vertical coordinate in inverse seconds |
| $`p,p_\eta`$ | Pressure and $`\partial p/\partial\eta`$, both in pascals |
| $`\nabla_\eta`$ | Horizontal derivative along a fixed coordinate surface |
| $`f,\mathbf{k}`$ | Coriolis frequency in inverse seconds and the upward unit vector |
| $`\Phi`$ | Geopotential in square metres per second squared |
| $`R_m,c_{p,m},T`$ | Mixture gas constant, heat capacity and temperature, as defined in [moist-air properties](thermodynamics.md) |
| $`\mathbf{a}_{\rm phys}`$ | Acceleration supplied by other physics, in metres per second squared |
| $`\omega`$ | Pressure change following the air, in pascals per second |
| $`Q`$ | Heating supplied by other physics, in watts per kilogram |
| $`S_\eta`$ | Added mass expressed as a pressure-coordinate rate, in pascals per second |
| $`p_0`$ | Fixed positive reference pressure in pascals |

## Equations

**P01. Change following the air**

```math
\frac{D}{Dt}
=
\frac{\partial}{\partial t}
+\mathbf{v}_h\cdot\nabla_\eta
+\dot\eta\frac{\partial}{\partial\eta}.
```

The three terms describe local change, horizontal transport and vertical transport.

**P02. Mass balance**

```math
\frac{\partial p_\eta}{\partial t}
+\nabla_\eta\cdot(p_\eta\mathbf{v}_h)
+\frac{\partial(p_\eta\dot\eta)}{\partial\eta}
=S_\eta.
```

A layer gains mass when more enters than leaves. The source is zero when no physical process adds or removes atmospheric mass.

**P03. Horizontal motion**

```math
\frac{D\mathbf{v}_h}{Dt}
+f\mathbf{k}\times\mathbf{v}_h
=
-\nabla_\eta\Phi
-R_mT\nabla_\eta\ln(p/p_0)
+\mathbf{a}_{\rm phys}.
```

The pressure and geopotential terms drive the motion. The cross product describes the deflection due to Earth's rotation. Horizontal vector derivatives follow the curved surface of the Earth.

**P04. Temperature change**

```math
\frac{DT}{Dt}
=
\frac{R_mT}{c_{p,m}p}\omega
+\frac{Q}{c_{p,m}},
\qquad
\omega=\frac{Dp}{Dt}.
```

Compression warms air when pressure rises along its path. The heating term includes radiation, phase changes and exchanges represented by the other physics calculations.

## Parameters, initial state, and boundaries

The normal Earth radius is 6,371,229 metres. The Coriolis frequency is $`f=2\Omega\sin\varphi`$, where $`\Omega`$ is Earth's rotation rate and $`\varphi`$ is latitude. The YOMCST source supplies the rotation rate and exact physical constants.

Initial winds, pressure, temperature, water fields and surface height come from the upstream forecast inputs. Longitude is periodic, so crossing its map edge reaches the other side of the globe. The top and the moving ground surface have no air flow through their coordinate boundaries. Surface physics can still add heat, water and forces.

The local dynamics sources and [IFS Dynamics and Numerical Procedures, CY48R1](https://www.ecmwf.int/sites/default/files/elibrary/2023/81369-ifs-documentation-cy48r1-part-iii-dynamics-and-numerical-procedures.pdf) define the model. The [source record](../../../bench/openifs/source.json) identifies the implementation. Numerical methods and exact arithmetic belong in the [md2asm skill](../../../skills/md2asm/SKILL.md).
