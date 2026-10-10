# OpenIFS routine audit

The audit counts Fortran functions and subroutines defined in the source files of the completed OpenIFS 48.1.1 forecast build. A routine body contains the statements that do its work. The count includes internal routines, which are written inside another routine or program.

| Item | Count |
| --- | ---: |
| Routine bodies | 5,238 |
| Subroutines | 4,690 |
| Functions | 548 |
| Internal routines, included above | 341 |
| Disabled-feature stubs, included above | 413 |
| Bodies after excluding stubs | 4,825 |
| Built Fortran input files | 3,287 |

A stub is a placeholder for an unavailable feature. The 4,825 other bodies also include setup, input/output, support code and physics that this forecast does not use. This is an exact build inventory, so it must not be reported as 4,825 numerical routines that all need assembly.

The tool checks each built input with GNU Fortran 12.3 and the original build settings. It excludes interface declarations, modules, program entry blocks and compiler-added helpers. Empty bodies count, and alternate ENTRY names share one body. The compilation database lists 3,675 Fortran inputs, but 388 belong to targets that were not built and are excluded.

Two count passes produced identical inventory bytes. All built inputs passed, and the 4,071 recorded source files, forecast executable and seven scientific libraries retain their earlier hashes. The [compact record](routines.json) also identifies seven generated Fortran inputs and their source templates. Full names, source paths, reports and the profile mapping remain in ignored .runtime/openifs/routine-audit/.

A complete T21 call trace now records when each built Fortran routine starts and returns. A separate build adds these notifications without changing the original strict build or its archives. All 153,696,355 entry/return pairs are balanced, with no lost events. Every observed address resolves to one of 1,466 source bodies, seven compiler cleanup helpers or two program startup wrappers. All ten saved forecast files match the strict reference by direct byte comparison.

| Active-source review | Count |
| --- | ---: |
| Active Fortran routine bodies | 1,466 |
| Bodies without existing profiling markers | 372 |
| Reviewed mathematical stages, helpers and interfaces | 302 |
| Reviewed mathematical setup and diagnostic bodies | 35 |
| Reviewed driver, support, configuration and storage bodies | 398 |
| Bodies still needing source-role review | 731 |

The older profile has 1,171 labelled regions, so its labels do not give complete routine coverage. The current review covers 735 bodies, including 81 mathematical stages, 165 subordinate calculations, 56 mathematical interfaces, five setup bodies and 30 diagnostic bodies. An interface calls mathematical routines and can also delegate diagnostics. The 337 bodies with mathematical purposes form a source-purpose subtotal; this count does not establish which routines require assembly or give a numerical completion denominator. SGEMMXZ remains classified as runtime support because its accepted body is an empty compatibility return. During the main forecast phase, 711 source bodies run and 644 have reviewed roles; another 835 run before it and 64 after it, with overlap between these sets.

The trace excludes local C/C++ bodies and uninstrumented external libraries, including numerical libraries. It records routine visits for this T21 case and does not prove every branch or other configurations. The compact [coverage record](routines.json) preserves counts, commands, evidence hashes and these limits. Complete events, source mappings and review evidence stay in ignored .runtime/openifs/routine-audit/ and .runtime/openifs/runs/.

| Routine | Verified assembly work |
| --- | --- |
| CPSPE | Complete surface-state update |
| GPRCP | Complete moist-air properties, including its internal accumulation |
| GPPWC | Complete pressure-weighted column integral |
| GPRT | Complete thermal pressure and horizontal derivatives |
| GPGRP | Complete pressure-gradient force in both vertical schemes |
| GPMKTEND | Complete wind, temperature and tracer state-change rates |
| GPADDSLPHY | Complete physical increments with vertical boundary storage |
| GP_TNDLAGADIAB_UV | Complete pressure, Coriolis and Rayleigh wind tendencies |
| GPGRXYB | Complete pressure coefficients and their horizontal gradients |
| GPTCO3 | Complete ozone and signed scalar-column integral |
| GP_SPV | Complete surface pressure and both horizontal derivatives |
| GPHPRE | Complete layer pressures, pressure weights and optional outputs |
| VERDISINT, VERINT, VERDER | Complete defined vertical integration and derivative branches, with a private ordered matrix helper |
| GPGEO | Complete gravitational energy from pressure and temperature |
| GPGRGEO | Complete horizontal gravitational-energy derivatives |
| GPTF1, GPTF2 | Complete two-part time filter |
| CTVTOT | Complete temperature from the moist-air equation of state |

All forty public bodies pass their critical checks within their declared input ranges. Every captured forecast call also passes; VERDER has no visit in this case, so its acceptance uses the small verifier. The [verification notes](README.md) state the evidence and its limits. Complete assembly coverage, raw whole-forecast states, independent whole-forecast physical checks and the external numerical-library arithmetic audit remain unfinished.

Current work prioritises the coarse forecast. Work proceeds through its active numerical routines one at a time, with dynamics first and the remaining physical schemes later. For each routine, freeze its physics and md2asm contract, emit the complete assembly body, pass physical and exact-byte checks, then verify its forecast calls before proceeding.

## Next coarse-forecast stages

The next review order follows the pressure and flow calculations needed by the coarse forecast. The call counts come from the existing T21 profile. A call count says how often a routine ran, not how much assembly work it needs.

| Order | Routine | Recorded calls | Required work |
| --- | --- | ---: | --- |
| 1 | GP_SPV | 2,150 | Complete and verified, including all time-level decisions |
| 2 | GPHPRE | 14,649 | Complete and verified, including shared top and optional outputs |
| 3 | VERDISINT | 21,559 | Complete and verified, including native integral and matrix dependencies |
| 4 | GPGEO | 4,300 | Complete and verified gravitational energy |
| 5 | GPGRGEO | 2,150 | Complete and verified horizontal energy derivatives |
| 6 | GPCTY | 2,150 | Source review pending a correction for unwritten returned bytes |
| 7 | GPTF1 | 2,150 | Complete and verified first filter stage |
| 8 | GPTF2 | 2,150 | Complete and verified second filter stage |
| 9 | CTVTOT | 2,150 | Complete and verified moist-air temperature |

A time filter removes unwanted oscillation between successive time levels. The [pressure math library](../../skills/md2asm/references/openifs/pressure_math.md) freezes separate exp and log arithmetic. Vertical integration now has complete native dependencies and independent checks on the actual forecast grid.

GPCTY's unchanged finite-element source writes only the bottom of one returned pressure-divergence field. Repeated runs with identical mathematical inputs and different prior storage leave 760 differing output bytes at other levels. The current forecast uses only the written level, but exact acceptance requires every returned byte, so this routine remains in Fortran until its source contract is corrected and independently reviewed.

These nine entries are completed or reviewed priorities, rather than a complete list of remaining numerical routines. SIGAM, SITNU, SPFILT, SPCIMPFINIT, SPCIMPFPOST, SPCIMPFSOLVE, SIMPLICO, LAITLI, LAIDDI and LAITRI now also have verified complete bodies. Verified physics includes CPQTUV and CUBIDIAG for transport, liquid and Fu ice-cloud optics, delta scaling, longwave gas preparation and shortwave spectral bands 25, 26 and 27. The [current forecast record](forecast.json) lists all 40 accepted bodies. Continue source-role review on the remaining active forecast calculations before each new physics contract, preserving the original source and all audit evidence.

To reproduce the build inventory, load GNU 12.3 and run the following command through srun in your own quiet exclusive allocation. The [counter](count_routines.py) uses Python's standard library and the existing compiler.

```bash
.runtime/python/bin/python bench/openifs/count_routines.py --workers 16
```
