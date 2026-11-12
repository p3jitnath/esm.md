# Vertical integrals and derivatives

Revision 1 describes the physical operations used by OpenIFS VERDISINT, VERINT and VERDER. The [solver contract](../../../skills/md2fort/references/openifs/dynamics/verdisint.md) records their numerical method and interface.

## The idea

The vertical coordinate eta increases from zero at the atmosphere's top to one at the ground. An integral adds a field through part of this column. For example, pressure-weighted moisture integrated through the whole column gives its water mass per unit area. A derivative gives a field's rate of change with eta.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`\eta`$ | Vertical coordinate, dimensionless |
| $`f(\eta)`$ | Input field, with a unit set by its caller |
| $`I_t(\eta)`$ | Integral measured from the top, with the unit of $`f`$ |
| $`I_b(\eta)`$ | Integral measured from the ground, with the unit of $`f`$ |
| $`q`$ | Water mass divided by total air mass, kg kg$`^{-1}`$ |
| $`P_s`$ | Surface pressure, Pa |
| $`g`$ | Gravitational acceleration, m s$`^{-2}`$ |

## Equations

**V01. Integral from the top.**

```math
I_t(\eta)=\int_0^\eta f(s)\,ds.
```

This equation adds the input between the top and eta. If $`f=qP_s/g`$ is constant, its value at the ground is the column water mass, $`qP_s/g`$ in kg m$`^{-2}`$.

**V02. Integral from the ground.**

```math
I_b(\eta)=\int_1^\eta f(s)\,ds=I_t(\eta)-I_t(1).
```

For a positive constant field above the ground, this result is negative because the integration direction is upward. Hydrostatic pressure force uses a negative input field and therefore gives positive geopotential above the ground, in m² s$`^{-2}`$. Dividing this geopotential by g gives height in metres.

**V03. Vertical derivatives.**

```math
D_1(\eta)=\frac{df}{d\eta},
\qquad
D_2(\eta)=\frac{d^2f}{d\eta^2}.
```

The first derivative is the field's rate of change. The second derivative is the rate of change of that first derivative. Eta has no unit, so both results have the unit of the input.

## Parameters, initial state, and boundaries

The forecast has 19 vertical layers. Full levels lie within the layers, while half levels mark their edges. Their supplied eta positions state where the input and returned fields are measured.

These operations act on one supplied field. At the top and ground, the physical input states the field's value or its first derivative. The solver contract records how those boundaries select each calculation.
