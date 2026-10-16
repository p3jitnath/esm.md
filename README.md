# esm.md

esm.md generates Arm assembly from short physics and mathematics notes in Markdown. Assembly is a processor’s low-level instruction language. We compare it with Fortran, Julia, and compiled Python on a Neoverse V2 processor, using identical 64-bit floating-point calculations.

The tables show median speed in million complete cell updates per second for optimised solvers across twelve quiet-node runs. Each update advances one cell by one full time step. All seven variants, including the unchanged vanilla language controls, pass independent physics checks and produce identical output bytes. Detailed results, including the controls and timing variation, are kept with the local research records.

## Shallow water

This model follows water depth and horizontal flow over a flat bottom. Gravity creates waves when the depth is uneven. Each grid has the stated number of cells in both horizontal directions.

| Grid | Assembly | Fortran | Julia | Python |
| --- | ---: | ---: | ---: | ---: |
| 64² | 89.80 | 84.94 | 78.39 | 56.40 |
| 256² | 95.31 | 81.51 | 77.00 | 56.42 |
| 1024² | 82.66 | 72.23 | 70.77 | 52.61 |

## Budyko–Sellers energy balance

This model gives one average temperature for each latitude band. The Sun’s radiation warms the surface, radiation cools it, and heat moves between neighbouring bands. The grid size is the number of bands from the South Pole to the North Pole.

| Grid | Assembly | Fortran | Julia | Python |
| --- | ---: | ---: | ---: | ---: |
| 128 | 650.56 | 510.74 | 531.46 | 548.93 |
| 4096 | 599.68 | 498.27 | 509.81 | 493.75 |
| 65536 | 590.51 | 488.69 | 489.47 | 514.88 |

Start with the [short template](formulations/TEMPLATE.md), [shallow-water maths](formulations/sw/2d_periodic.md), or [energy-balance maths](formulations/ebm/budyko_sellers.md). The [md2asm skill](skills/md2asm/SKILL.md) supplies the numerical and implementation details and retains the measured assembly optimisations.

The published tree contains Markdown and assembly. Build instructions and the local comparison protocol are in the [evaluation notes](skills/md2asm/SKILL.md). [AGENTS.md](AGENTS.md) defines the first-year-undergraduate writing convention. Local tools, language controls, data and the poster remain outside Git.

## OpenIFS development

The openifs-md branch extends this workflow to OpenIFS 48.1.1. Assembly replaces 373 original routine bodies within their selected input and calculation scopes, and seven field-registry methods that store array addresses and dimensions. Their small checks cover independent physical relations within declared input ranges, with known source limits recorded below. The checked forecast-call cases pass exact byte comparisons in a coarse global forecast.

| Check | Coverage | Differing bytes |
| --- | --- | ---: |
| Radiation-field preparation | 6,400 complete calls | 0 |
| Plant photosynthesis | 6,450 complete C3/C4 calls | 0 |
| Interpolation boundaries | 2,150 complete calls | 0 |
| Fourier coefficient transfer | 352 complete field-count/latitude pairs | 0 |
| Spectral forecast step | 25 complete calls and seven direct stages | 0 |
| Complete final state | 685 buffers across 27,486,113 bytes | 0 |
| Saved forecast files | 10 files across 618,140 bytes | 0 |

The latest verified forecast starts on 15 October 2004 and advances 24 hours on 2,048 grid points with 19 atmospheric levels. Assembly now owns the selected surface and upper-air file-loading routes, field registration, surface defaults, several grid setup stages, physics dimension updates, state and work-record storage, field block views, complete physics-call storage, standard-atmosphere setup, the scalar exponential, selected output request preparation and GRIB file writing. The selected input routes now read their metadata in assembly. Model startup, other setup and storage services, and retained reference forwards still use Fortran. Complete OpenIFS ownership and independent whole-forecast physical checks remain unfinished. External libraries and their interfaces may remain, including ecCodes, transforms, Atlas and mathematical functions. Whole-forecast speed has not been measured. The [OpenIFS verification note](src/openifs/README.md) gives the latest evidence and the limits of complete-storage comparisons.

The separate [standalone initial-state executable](skills/md2asm/references/openifs/input/owned_trajectory_initial_state.md) reads the original GRIB files and live configuration through assembly. It constructs selected records at their final MODEL and FIELDS addresses, including complete selected Meteo-France physics parameters, initial virtual-temperature conversion, diagnostic flux state, spectral norms, trajectory storage, working arrays and three field containers. The new storage connection preserves field bytes and passes live metadata and ABI checks. Accepted source comparisons remain the evidence for unchanged producers. Permitted file-format, transform, mathematical and runtime services remain explicit, with no original OpenIFS library or harness. Separate accepted components now own grid-point norms, forecast schedule switches, live timers, reporting bindings, cloud-overlap setup and serial output distribution. Their remaining parent connections, climate inputs and output setup are required before a full autonomous forecast.

The [basic formulations](formulations/openifs/README.md) explain the physical balances. The [coverage tables](src/openifs/README.md) give accepted counts and verification limits. All **255 audited weather and forcing routines** in this T21 main phase have accepted assembly replacements. The overlapping broader lists still have 91 local calculations and 358 main-forecast bodies remaining. The ordered original routine names and source paths remain in the local records.

## Notes

The original urban setup stores `RSBCONS=5.67e+08`, although its comment describes the Stefan–Boltzmann constant. This source value is preserved. Urban flux is disabled in the tested forecast, and this coefficient is excluded from the independent physical validation.

In a tested ice-formation call, the OpenIFS lake update stores an average water temperature of 277.13 K, while its limited temperature profile can represent at most 276.334 K. The profile describes how water temperature changes with depth. We retain the original OpenIFS equations and update rules, and report this known limitation separately from exact assembly byte agreement. Independent whole-forecast physics remains unverified.

For the complete-storage comparison, both forecasts use the same incoming bytes in unused parts of the sea-ice albedo, solar-fraction, terrain and spherical-geometry tables. Their initialized physical values must already agree before only the source-unused input tails are loaded, ahead of the first calculation. Every returned byte remains in the comparison. The [direct power routine](skills/md2asm/references/openifs/support/power_original_rounding.md) passes this complete forecast gate without the original C power helper.
