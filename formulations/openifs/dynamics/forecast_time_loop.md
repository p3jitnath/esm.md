# Forecast Time Loop

Formulation revision 1 groups the forecast progression used by CNT4. Starting from a supplied atmospheric state, the forecast repeatedly applies the [time-step physics](forecast_time_step.md) and updates the date-dependent forcing. The requested outputs show how the state changes with time.

The existing child equations describe motion, pressure, heating, water and surface changes. A physical tendency is a rate of change per second, as defined by the unchanged [physics-increment equations](../physics/physics_increment.md). Wind uses metres per second, temperature uses kelvin, pressure uses pascals and water mass fractions use kilograms per kilogram.

The coarse global case has 2,048 cells and 19 levels. Its initial state, start date, forcing data, coefficients and output requests come from the supplied forecast. All child boundary conditions remain unchanged. Running the same physical calculations at successive times adds no physical equation or parameter.

The LLM uses [md2asm](../../../skills/md2asm/SKILL.md) to record the [complete loop contract](../../../skills/md2asm/references/openifs/dynamics/forecast_time_loop.md).
