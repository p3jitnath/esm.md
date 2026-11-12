# Departure-Field Transport

## Physical Idea

Air carries wind, heat and water as it moves. During the transport part of a time step, a small parcel of air keeps its transported properties. The forecast applies forces, heating and water conversion in separate calculations. This formulation supplies the physical transport idea for LARCINB and its interpolation children.

## Basic Mathematics

Let $`\phi`$ be a transported property, $`t`$ time in seconds, $`\mathbf{x}`$ position in metres, and $`\mathbf{v}`$ air velocity in metres per second. The transport equation is

```math
\frac{\partial \phi}{\partial t} + \mathbf{v}\cdot\nabla\phi = 0.
\tag{DT-1}
```

Here $`\nabla\phi`$ describes how the property changes with position. Equation DT-1 states that movement carries the property without changing its value inside the parcel.

Let $`\mathbf{x}_d`$ be the departure position, where that parcel began the time step, and let $`\Delta t`$ be the time interval in seconds. The same idea gives

```math
\phi(\mathbf{x},t+\Delta t) = \phi(\mathbf{x}_d,t).
\tag{DT-2}
```

The wider forecast supplies the departure positions. LARCINB evaluates the supplied fields at those positions and returns them to the wider forecast.

## Fields And Inputs

| Field | Meaning | Units |
| --- | --- | --- |
| $`u`$ and $`v`$ | Horizontal wind components | m s$`^{-1}`$ |
| $`T`$ | Air temperature | K |
| $`q`$ | Water mixing ratio, including humidity and cloud or precipitation water | kg kg$`^{-1}`$ |
| $`a`$ | Fraction of a cell covered by cloud | 1 |

The caller supplies the initial fields, departure positions, time interval and any separate equation contributions. Supplied mass-continuity quantities retain their caller's units. This transport step introduces no new physical parameter.

## Initial State And Boundaries

Use the state and boundary conditions already supplied by the forecast. This component does not create a new atmosphere or alter the physical boundary conditions. Constant fields must remain constant during transport, and a positive transported scalar must obey the accepted child's neighbour bounds.

## Generation

Formulation revision 1 defines DT-1 and DT-2. The numerical method, ordered arithmetic, complete interfaces and acceptance limits are in [Departure-Field Transport](../../../skills/md2fort/references/openifs/dynamics/departure_field_transport.md).
