# Forecast Time Step

Formulation revision 1 groups the calculations used by STEPO. The atmosphere is represented both by grid values and by spectral coefficients. A spectral coefficient gives the strength of a global spatial wave. Converting between these representations allows the forecast to apply local column physics and global wave calculations to the same atmospheric state.

Use the unchanged [grid-driver physics](complete_forecast_grid_driver.md) and [spectral forecast physics](spectral_calculation_driver.md). Temperature uses kelvin, wind uses metres per second, water mass fractions use kilograms per kilogram and logarithmic surface pressure has no unit. Each existing child formulation defines its own variables and physical equations.

The supplied initial state has 2,048 horizontal cells and 19 levels. The surrounding forecast supplies its coefficients, grid geometry, time interval and output requests. The spectral representation describes the whole sphere, and the child grid calculations retain their existing surface and upper boundaries. This grouping adds no physical model or parameter.

The LLM uses [md2fort](../../../skills/md2fort/SKILL.md) to record the [time-step contract](../../../skills/md2fort/references/openifs/dynamics/forecast_time_step.md).
