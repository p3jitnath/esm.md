# OpenIFS formulations

OpenIFS is a global weather model. It combines atmospheric motion with radiation, clouds, rainfall and exchanges with the surface. The local source used here is OpenIFS 48.1.1, identified by the [source record](../../bench/openifs/source.json).

The notes contain the physical idea and basic equations. The md2asm contracts contain the numerical method, ordered arithmetic and assembly interface. A complete routine is verified separately before it replaces the corresponding Fortran routine in the forecast.

| Forecast part | Basic formulation | Assembly coverage |
| --- | --- | --- |
| Atmospheric motion | [Motion and heat](dynamics/atmospheric_motion.md) | Complete time filters, SITNU and spectral stages, other stages pending |
| Surface pressure | [Logarithm and derivatives](dynamics/surface_pressure.md) | Complete GP_SPV routine |
| Vertical pressure | [Hybrid pressure](dynamics/hybrid_pressure.md) | Complete GPHPRE routine |
| Vertical force balance | [Hydrostatic balance](dynamics/hydrostatic_balance.md) | Complete GPGEO, GPGRGEO and SIGAM routines |
| Vertical operations | [Integrals and derivatives](dynamics/vertical_operators.md) | Complete defined VERDISINT, VERINT and VERDER branches |
| Moist-air properties | [Mixture properties](dynamics/thermodynamics.md) | Complete GPRCP and CTVTOT routines |
| Thermal pressure | [Temperature and gradients](dynamics/thermal_pressure.md) | Complete GPRT routine |
| Pressure-gradient coefficients | [Hybrid-pressure derivatives](dynamics/pressure_gradient_coefficients.md) | Complete GPGRXYB routine |
| Horizontal pressure force | [Pressure gradients](dynamics/pressure_force.md) | Complete GPGRP routine |
| Wind accelerations | [Rotation and damping](dynamics/wind_tendency.md) | Complete GP_TNDLAGADIAB_UV routine |
| State-change rates | [Changes per second](dynamics/state_rates.md) | Complete GPMKTEND rates and CPQTUV state update |
| Physics increments | [Changes from physical rates](physics/physics_increment.md) | Complete GPADDSLPHY routine |
| Column water | [Water mass](dynamics/column_water.md) | Complete GPPWC routine |
| Surface-state change | [Surface change](surface/surface_state.md) | Complete CPSPE routine |
| Clouds and precipitation | [Water and phase changes](physics/clouds.md) | Pending |
| Convection | [Plume transport](physics/convection.md) | Complete CUBIDIAG helper, other stages pending |
| Turbulent mixing | [Vertical transport](physics/vertical_mixing.md) | Pending |
| Radiation | [Radiation balance](physics/radiation.md) | Complete liquid and Fu ice optics and cloud delta scaling, radiative transfer pending |
| Soil, snow, lakes and surface exchange | [Skin balance and tiles](surface/surface_exchange.md) | CPSPE update only, storage balances pending |
| Column ozone | [Ozone mass](physics/column_ozone.md) | Complete GPTCO3 integral, also used for signed moisture rates |
| Atmospheric composition | [Tracer balance](physics/atmospheric_composition.md) | Transport and chemical rates pending |
| Ocean waves and coupling | [Wave action](waves/ocean_waves.md) | Pending |

These basic balances do not yet cover every configured physical process. Source-derived closure relations, which specify rates and coefficients, and complete numerical contracts are still needed before assembly generation.

Forty-nine public assembly bodies pass independent small checks within their declared input ranges. Their observed calls also pass exact byte comparisons inside the coarse forecast. The [verification record](../../bench/openifs/README.md) states the exact coverage. The remaining numerical stages and whole-forecast independent physics checks are still needed.
