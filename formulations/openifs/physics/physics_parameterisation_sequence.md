# Physical Process Sequence

Formulation revision 1 groups the physical processes used by CALLPAR. A parameterisation estimates the effect of a process that the forecast grid cannot represent directly, such as small turbulent air motions. The selected sequence includes radiation, turbulence, convection, cloud water, atmospheric waves, methane oxidation and exchanges with the surface.

A tendency is a rate of change per second. Wind uses metres per second, temperature uses kelvin and a constituent mass fraction uses kilograms per kilogram of moist air. Their tendencies therefore use metres per second squared, kelvin per second and kilograms per kilogram per second. The unchanged [physics-increment equations OIFS-I1 and OIFS-I2](physics_increment.md) describe how these rates change the state. The [radiation physics](../radiation/radiation_column_physics.md) and [methane physics](methane_humidity_tendency.md) retain their existing equations and parameters.

The surrounding forecast supplies pressure, temperature, wind, water species, surface conditions and physical coefficients. This coarse case has 19 atmospheric levels and at most 24 columns per visit. The existing child models retain their upper, lower and horizontal boundaries. Lake physics is enabled and coupled-ocean mixing is inactive. This grouping introduces no new physical equation or parameter.

The LLM uses [md2asm](../../../skills/md2asm/SKILL.md) to record the [complete caller contract](../../../skills/md2asm/references/openifs/physics/physics_parameterisation_sequence.md).
