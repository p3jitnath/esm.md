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
| Reviewed mathematical stages, helpers and interfaces | 313 |
| Reviewed mathematical setup and diagnostic bodies | 38 |
| Reviewed driver, support, configuration and storage bodies | 451 |
| Bodies still needing source-role review | 664 |

The older profile has 1,171 labelled regions, so its labels do not give complete routine coverage. The current review covers 802 bodies, including 81 mathematical stages, 172 subordinate calculations, 60 mathematical interfaces, five setup bodies and 33 diagnostic bodies. An interface calls mathematical routines and can also delegate diagnostics. The 351 bodies with mathematical purposes form a source-purpose subtotal; this count does not establish which routines require assembly or give a numerical completion denominator. SGEMMXZ remains classified as runtime support because its accepted body is an empty compatibility return. During the main forecast phase, all 711 entered source bodies now have reviewed roles; another 835 run before it and 64 after it, with overlap between these sets.

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

All forty-seven public bodies pass their critical checks within their declared input ranges. Every captured forecast call also passes; VERDER has no visit in this case, so its acceptance uses the small verifier. The [verification notes](README.md) state the evidence and its limits. Complete assembly coverage, raw whole-forecast states, independent whole-forecast physical checks and the external numerical-library arithmetic audit remain unfinished.

Current work prioritises the coarse forecast. Work proceeds through its active numerical routines one at a time, with dynamics first and the remaining physical schemes later. For each routine, freeze its physics and md2asm contract, emit the complete assembly body, pass physical and exact-byte checks, then verify its forecast calls before proceeding.

## Next Coarse-Forecast Checkpoints

The exact source-linked list now assigns each of the 711 main-phase bodies to one group. A local expression calculates a value in that body. A delegate passes the calculation to another body. The compact [record](routines.json) identifies the complete names, original source evidence and checked call sites.

| Original main-phase work | Bodies |
| --- | ---: |
| Local weather or forcing expressions | 255 |
| Local geometry expressions | 1 |
| Local pressure and tracer corrections or returned means | 4 |
| Local output, reporting and control expressions | 96 |
| Numerical delegates, including physical output and corrections | 55 |
| Physical copy or lookup helpers | 2 |
| Other storage, control and service bodies | 298 |
| **All main-phase bodies** | **711** |

The first four rows contain 356 local-expression owners. The other rows contain 355 bodies without local expressions. The underlying list has thirteen disjoint groups, so printed statistics, physical output and runtime accounting remain separate. These ownership counts do not give an assembly completion denominator.

| Priority | Original bodies | Next required work |
| ---: | --- | --- |
| 1 | LASCAW | Complete the parent around verified interpolation helpers, including coordinates, weights and every output family. |
| 2 | SPCSI | Close its complete wave input, vertical matrix products, selected solve branch and final increments. |
| 3 | SPCM, SPCHOR | Close the selected implicit updates, transforms, corrections and damping. |
| 4 | CPGLAG | Preserve provisional-state additions, selected corrections and map factors. |
| 5 | CPG_GP_HYD, CPG_GP, GP_MODEL | Verify smaller weather stages before replacing their complete parents. |
| 6 | LAMINMAXINT, LAVENT | Verify neighbouring minima and maxima, then wind extrapolation and rotation. |
| 7 | PFIXER, QMFIXER, GPNORM1, GPNORM_TRANS, GPNORM_TRANS_CTL | Preserve physical means, latitude weights and ordered sums. |

LASCAW_CLO and LASCAW_VINTW are verified within their contracts. LASCAW_CLA is now also verified within its declared contract. The work list also retains 55 original call sites for named numerical and real-valued output dependencies. Intrinsic mathematics, other branches and process-wide sums can add work, so this bounded list is not a complete runtime graph.

GPCTY's unchanged finite-element source writes only the bottom of one returned pressure-divergence field. Repeated source calls leave 760 differing returned bytes at other levels. The current forecast uses the written level, but complete acceptance requires a corrected and independently reviewed output contract. This routine remains in Fortran.

The [current forecast record](forecast.json) lists all 47 accepted direct bodies. A matching name does not prove that a whole parent or every branch has been replaced. All nested calculations, external numerical dependencies, buffer bounds and selected physical consumers must be closed before an exact assembly denominator can be stated.

To reproduce the build inventory, load GNU 12.3 and run the following command through srun in your own quiet exclusive allocation. The [counter](count_routines.py) uses Python's standard library and the existing compiler.

```bash
.runtime/python/bin/python bench/openifs/count_routines.py --workers 16
```
