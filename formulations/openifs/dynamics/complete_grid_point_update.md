# Complete Grid-Point Update

Formulation revision 1 groups the physical calculations used by CPG. A grid point represents an atmospheric column. The update prepares pressure, height, wind and water fields, applies physical rates, then prepares the fields used to move air between columns.

The unchanged physical equations are defined in [forecast grid calculations](forecast_grid_calculations.md), [hydrostatic balance](hydrostatic_grid_calculations.md), [transport terms](transport_equation_terms.md) and the supplied physical-rate calculations. Wind uses metres per second, temperature uses kelvin, pressure uses pascals and water content uses kilograms per kilogram of moist air.

Let $`q_{j,f}`$ be the value of field $`f`$ at local column $`j`$, and let $`I(j)`$ give its position in the transport buffer. These indices have no unit. Equation CPG-P01 states that moving a field to its mapped position preserves its value and unit.

```math
q^{\mathrm{transport}}_{I(j),f}=q^{\mathrm{local}}_{j,f}\qquad\text{(CPG-P01)}
```

The selected coarse forecast has 2,048 horizontal cells and 19 atmospheric levels. Each visit handles at most 24 columns. The surrounding forecast supplies the initial state, time intervals, grid geometry and physical parameters. Child calculations retain their existing global boundaries. Only active columns are copied, so the unused end of a partial block remains unchanged. This grouping adds no physical parameter or boundary condition.

The LLM uses [md2asm](../../../skills/md2asm/SKILL.md) to record the [assembly contract](../../../skills/md2asm/references/openifs/dynamics/complete_grid_point_update.md).
