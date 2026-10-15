# Wind At Pressure Levels

Revision 1 describes the supplied wind profile and the requested pressure levels. The eastward wind component is $`u`$ and the northward component is $`v`$, both measured in metres per second. Pressure $`p`$ is measured in pascals and decreases with height.

The forecast supplies wind and pressure at the model levels. It also supplies two requested output pressures for each selected column. The output describes the same wind profile at those pressures. A constant wind profile must remain constant. The model values, their ordering and the selected pressure coordinates are physical inputs to this calculation.

The selected logarithmic coordinate is $`x=\ln(p/p_0)`$, where $`p_0`$ is one pascal. Both $`x`$ and its differences have no unit. The supplied positive pressures and distinct neighbouring levels define this coordinate. The calculation retains the source upper-level continuation and the source constant lowest-level extension where that lower boundary applies.

This diagnostic uses the current forecast state without advancing time. Only the selected columns and requested levels can change; the other stored values keep their input bytes. The [solver contract](../../../skills/md2asm/references/openifs/physics/pressure_level_wind_interpolation.md) records the frozen interpolation, storage and checks.
