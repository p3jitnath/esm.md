# Complete Forecast Grid Driver

Formulation revision 1 groups the physical calculations used by GP_MODEL. A grid cell represents an atmospheric column. Wind moves air between columns, pressure forces change the wind and physical processes change heat and water. The driver joins these existing effects without adding a new physical equation.

The unchanged equations are defined in the [complete grid-point update](complete_grid_point_update.md), [transport terms](transport_equation_terms.md), [lagged hydrostatic update](lagged_grid_update.md) and physical child models. Wind uses metres per second, pressure uses pascals, temperature uses kelvin and water content uses kilograms per kilogram of moist air. A tendency is the rate of change of a field per second.

The selected global grid has 2,048 horizontal cells and 19 levels. The forecast supplies its initial state, surface conditions, coefficients and time intervals. Longitude wraps around Earth and the existing child models retain their top, surface and pole conditions. Grouping the calculations changes no physical parameter or boundary.

The LLM uses [md2asm](../../../skills/md2asm/SKILL.md) to record the [driver contract](../../../skills/md2asm/references/openifs/dynamics/complete_forecast_grid_driver.md).
