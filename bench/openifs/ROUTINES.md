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
| Reviewed numerical-purpose bodies, including interfaces and helpers | 39 |
| Reviewed numerical seed-setup body | 1 |
| Reviewed support, configuration and storage bodies | 226 |
| Bodies still needing source-role review | 1,200 |

The older profile has 1,171 labelled regions, so its labels do not give complete routine coverage. The source review must distinguish numerical calculations from setup and support before we can count the routines that need assembly. The 1,466 active bodies must therefore not be used as the numerical completion denominator. During the main forecast phase, 711 source bodies run; another 835 run before it and 64 after it, with overlap between these sets.

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

All twelve routines pass their critical checks and captured forecast calls. The [verification notes](README.md) state the evidence and its limits. Complete assembly coverage, raw whole-forecast states, independent whole-forecast physical checks and the external numerical-library arithmetic audit remain unfinished.

Current work prioritises the coarse forecast. Work proceeds through its active numerical routines one at a time, with dynamics first and the remaining physical schemes later. For each routine, freeze its physics and md2asm contract, emit the complete assembly body, pass physical and exact-byte checks, then verify its forecast calls before proceeding.

## Next coarse-forecast stages

The next review order follows the pressure and flow calculations needed by the coarse forecast. The call counts come from the existing T21 profile. A call count says how often a routine ran, not how much assembly work it needs.

| Order | Routine | Recorded calls | Required work |
| --- | --- | ---: | --- |
| 1 | GP_SPV | 2,150 | Complete and verified, including all time-level decisions |
| 2 | GPHPRE | 14,649 | Complete and verified, including shared top and optional outputs |
| 3 | VERDISINT | 21,559 | Ordered vertical integration for the finite-element scheme |
| 4 | GPGEO | 4,300 | Height-related gravitational energy from pressure and temperature |
| 5 | GPGRGEO | 2,150 | Horizontal derivatives of that gravitational energy |
| 6 | GPCTY | 2,150 | Air-mass continuity and vertical pressure motion |
| 7 | GPTF1 | 2,150 | First part of the time filter |
| 8 | GPTF2 | 2,150 | Second part of the time filter |

A time filter removes unwanted oscillation between successive time levels. The [pressure math library](../../skills/md2asm/references/openifs/pressure_math.md) now freezes non-fused exp and log arithmetic for both assembly and Fortran. GPHPRE now passes those boundary, optional-output and shared-top checks. Vertical integration next requires an ordered matrix product and complete VERINT and VERDER dependencies.

These eight entries are review priorities, not a complete count of remaining numerical routines. The six unfinished entries require individual contracts, complete assembly and the same physical and byte checks as the twelve accepted routines. Keep the original sources and measured inventory unchanged, then review the remaining physical schemes.

To reproduce the build inventory, load GNU 12.3 and run the following command through srun in your own quiet exclusive allocation. The [counter](count_routines.py) uses Python's standard library and the existing compiler.

```bash
.runtime/python/bin/python bench/openifs/count_routines.py --workers 16
```
