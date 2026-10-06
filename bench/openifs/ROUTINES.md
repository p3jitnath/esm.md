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

The T21 forecast profile contains 1,171 labelled regions. Of these labels, 1,002 uniquely match routine names in the inventory. The remaining 169 need source mapping or refer to external calls and code regions. This profile does not record every function call, so the exact number of required numerical routines remains unestablished. A complete call trace and a review of which routines perform numerical stages are needed before using that count to estimate the remaining assembly work.

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

All nine routines pass their critical checks and captured forecast calls. The [verification notes](README.md) state the evidence and its limits. Complete assembly coverage, raw whole-forecast states, independent whole-forecast physical checks and the external numerical-library arithmetic audit remain unfinished.

The user resumed work until 00:00 UTC on 2026-10-07, prioritising the coarse forecast. Work proceeds through its active numerical routines one at a time, with dynamics first and the remaining physical schemes later. For each routine, freeze its physics and md2asm contract, emit the complete assembly body, pass physical and exact-byte checks, then verify its forecast calls before proceeding.

To reproduce the build inventory, load GNU 12.3 and run the following command through srun in your own quiet exclusive allocation. The [counter](count_routines.py) uses Python's standard library and the existing compiler.

```bash
.runtime/python/bin/python bench/openifs/count_routines.py --workers 16
```
