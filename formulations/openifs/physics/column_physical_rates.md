# Column Physical Rates

Formulation revision 1 groups EC_PHYS and its supporting block driver EC_PHYS_DRV. An atmospheric column is a stack of air layers. Before the physical processes run, the caller prepares pressure, moist-air properties, height and the angle of sunlight. It then applies the [physical process sequence](physics_parameterisation_sequence.md) and forms the requested physical diagnostics.

Pressure uses pascals, height uses metres, temperature uses kelvin and wind uses metres per second. A mass fraction measures constituent mass divided by total moist-air mass, in kilograms per kilogram. Solar geometry describes the direction of sunlight through dimensionless angles and their trigonometric values. The existing [hydrostatic column equations](../dynamics/hydrostatic_grid_calculations.md) and [physical-increment equations](physics_increment.md) retain their meaning and parameters.

The coarse forecast supplies 2,048 horizontal cells and 19 levels. The block driver groups them into 86 blocks with 24 allocated columns each; the final block has eight active columns. The forecast supplies the initial state, physical coefficients and time intervals. The child models retain their existing surface, top and global boundaries. Grouping columns into blocks changes neither the physical equations nor the boundary conditions.

The LLM uses [md2fort](../../../skills/md2fort/SKILL.md) to record the [column and block assembly contract](../../../skills/md2fort/references/openifs/physics/column_physical_rates.md).
