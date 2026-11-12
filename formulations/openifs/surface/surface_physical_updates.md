# Surface Physical Updates

Formulation revision 1 groups SURFEXCDRIVER_CTL, VSURF and SURFTSTP_CTL. Surface tiles represent land, vegetation, water, snow and ice within one grid cell. The selected child models prepare surface humidity and resistance, exchange heat and water with the air, then advance soil, snow, lake and vegetation states.

Temperature uses kelvin, heat flux uses watts per square metre and evaporation uses kilograms per square metre per second. Water and snow mass use kilograms per square metre; layer depths use metres. Tile fractions have no unit. Existing [surface exchange](surface_exchange.md), [surface energy](surface_skin_energy.md), [snow water and energy](snow_water_energy.md) and [soil diffusion](soil_column_diffusion.md) retain their physical equations.

The sea-humidity correction retains the supplied dimensionless salt factor in both saturation humidity and its temperature derivative. Permanent-snow resets impose an explicit water source or sink, rather than a closed local water boundary. The forecast supplies the state, coefficients and time interval for nine tiles and four soil layers. Only declared active columns change, except for source-defined whole-array writes. The [md2fort contract](../../../skills/md2fort/references/openifs/surface/surface_physical_updates.md) records these interfaces and update rules.
