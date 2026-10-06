# OpenIFS formulations

OpenIFS is a global weather model. It combines atmospheric motion with radiation, clouds, rainfall and exchanges with the surface. The local source used here is OpenIFS 48.1.1, identified by the [source record](../../bench/openifs/source.json).

The notes contain the physical idea and basic equations. The md2asm contracts contain the numerical method, ordered arithmetic and assembly interface. A complete routine is verified separately before it replaces the corresponding Fortran routine in the forecast.

| Forecast part | Basic formulation | Assembly coverage |
| --- | --- | --- |
| Atmospheric motion | [Motion and heat](atmospheric_motion.md) | Pending |
| Vertical pressure | [Hybrid pressure](hybrid_pressure.md) | Pending |
| Vertical force balance | [Hydrostatic balance](hydrostatic_balance.md) | Pending |
| Moist-air properties | [Mixture properties](thermodynamics.md) | Complete GPRCP routine |
| Column water | [Water mass](column_water.md) | Complete GPPWC routine |
| Surface-state change | [Surface change](surface_state.md) | Complete CPSPE routine |
| Clouds and precipitation | [Water and phase changes](clouds.md) | Pending |
| Convection | [Plume transport](convection.md) | Pending |
| Turbulent mixing | [Vertical transport](vertical_mixing.md) | Pending |
| Radiation | [Radiation balance](radiation.md) | Pending |
| Soil, snow, lakes and surface exchange | [Skin balance and tiles](surface_exchange.md) | CPSPE update only, storage balances pending |
| Atmospheric composition | [Tracer balance](atmospheric_composition.md) | Pending |
| Ocean waves and coupling | [Wave action](ocean_waves.md) | Pending |

These basic balances do not yet cover every configured physical process. Source-derived closure relations, which specify rates and coefficients, and complete numerical contracts are still needed before assembly generation.

The three assembly routines pass critical checks and captured calls within the coarse upstream forecast. The [verification record](../../bench/openifs/README.md) states the exact coverage. The remaining numerical stages and whole-forecast independent physics checks are still needed.
