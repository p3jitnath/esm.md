# OpenIFS Assembly

These direct assembly routines calculate atmospheric motion, heating, radiation and surface changes. They are grouped by physical theme. A routine body means one original function or subroutine. Each accepted body has independent critical checks and exact comparisons within its declared input range.

## Coverage

The table describes the audited coarse T21 global forecast. Its groups overlap and must not be added. The checkpoint combines the remaining 14 weather routines with four separately verified supporting bodies. It covers cloud physics, turbulence, surface and lake calculations, and their forecast callers.

| Scope | Original bodies | Accepted assembly | Remaining |
| --- | ---: | ---: | ---: |
| Main forecast phase | 711 | 273 | 438 |
| Local calculations | 356 | 261 | 95 |
| Weather calculations | 255 | 255 | 0 |

There are 274 accepted original bodies overall, including VERDER outside the main forecast phase. Completing the weather list does not cover every model branch, setup routine or external dependency.

## Verification

The joint checkpoint uses one direct forecast time loop and 25 direct time updates. Its private update path writes each scheduled output once. Separate source and assembly forecasts start from the same binary inputs. Existing checks of unchanged children and completed numerical source-first/native stage pairs are reused. The 25 native update calls show completion; this gate does not compare raw state after every step.

| Compared output | Complete scope | Differing bytes |
| --- | ---: | ---: |
| Final state | 685 buffer owners, 27,486,113 bytes | 0 |
| Saved forecast files | 10 files, 618,140 bytes | 0 |
| Numerical status and step controls | 56 status bytes and 8 control bytes | 0 |

A buffer owner is a complete retained array or record in model memory. The final-state gate compares its numerical bytes and checks the recorded array layout. It applies the existing rules for address metadata without changing numerical values. The source archive fixes the unused 768-byte tail of an albedo table. Before the first native calculation, that tail is loaded as input. Its initialized 576-byte physical part already agrees. All 1,344 bytes remain in the final comparison. The status gate checks floating-point controls, exception flags and the system error value. The assembly also preserves the registers required by its application binary interface, or ABI. The original source's documented use of register x18 remains a separate source limit.

Two complete recorded call sets also pass exact replay. The cloud calculation matches all 2,150 calls across 561,408,000 complete buffer bytes. The lake calculation matches all 2,150 calls across 17,105,400 bytes. These checks include actual numerical status and the final partial block. They cover the original source calls through step 24 and retain raw unused storage. The [cloud contract](../../skills/md2asm/references/openifs/cloud_microphysics_contract.md) and [lake contract](../../skills/md2asm/references/openifs/surface/lake_temperature_profile.md) state their arithmetic and scientific limits.

## Reference and limits

The comparison uses a reviewed OpenIFS 48.1.1 reference with frozen inputs and arithmetic. Earlier reference versions and their different outputs remain local. Its essential qualifications are retained below.

| Reference area | Frozen qualification |
| --- | --- |
| Continuity | Assign positive zero to unused output slots while preserving every defined calculation. |
| Spectral and latitude transforms | Use independently checked matrix products with separate rounding after multiplication and addition. |
| Trajectory wind weights | Use the separately verified hyperbolic tangent function. |
| C4 leaf photosynthesis | Use physically valid equation roots and retain small carbon uptake in the canopy sum. |
| Radiation | Use fresh complete call pairs under the same runtime setup. An older cold replay has a recorded setup limit. |

The [numerical contracts](../../skills/md2asm/references/openifs/) define the supported branches, buffers, arithmetic and independent checks. A separate observer checks the humidity floor and finite ordered rates. Exact agreement can reproduce a shared scientific defect, so it does not establish independent physics of the whole forecast.

In a tested ice-formation call, the original lake update stores an average water temperature of 277.13 K, while its limited temperature profile can represent at most 276.334 K. The profile describes temperature changes with depth. The original lake equations remain unchanged. Complete forecast water and heat balances, whole-process byte identity and comparative forecast speed remain unverified.

The executable still uses OpenIFS Fortran for input, setup, metadata and retained reference forwards. It also depends on local numerical helpers, including the frozen C power helper. It is not an autonomous assembly forecast. Autonomous input loading, initialisation, complete calculation ownership and output remain a separate phase.

A separate [assembly input reader](../../skills/md2asm/references/openifs/input/initial_spectral_field_reader.md) loads the real spectral initial-condition file through the ecCodes C file-format library. All 78 decoded records match the reference across 315,744 value bytes and 1,872 label bytes. Critical error, buffer and register checks pass.

The [assembly placement stage](../../skills/md2asm/references/openifs/input/spectral_initial_state_placement.md) copies the 59 source-selected records into the original upper-air and surface layouts. Its 238,832 output bytes match a separate Fortran reference. A standalone assembly command owns both decoding and placement, with no OpenIFS or Fortran dependency. Model-object construction, remaining input fields and complete forecast initialisation remain separate work.

The [upper-air input reader](../../skills/md2asm/references/openifs/input/initial_upper_air_field_reader.md) decodes humidity and three cloud fields through the same assembly body. All 76 records match the reference across 1,245,184 value bytes and 1,824 label bytes. Its error and ABI checks pass, and its standalone command uses no OpenIFS or Fortran. Full model setup remains separate work.

The [upper-air placement](../../skills/md2asm/references/openifs/input/upper_air_initial_state_placement.md) copies those fields into the original eight-field model buffer. All 2,509,824 bytes match the independent reference, including 9,728 preserved padding bytes. Its critical buffer and ABI checks pass. This helper requires an explicit starting buffer and does not establish full model initialisation.

The [surface input reader](../../skills/md2asm/references/openifs/input/initial_surface_field_reader.md) retains all 140 records, including all twelve months of six seasonal fields. Its 2,293,760 value bytes and 5,600 date-bearing metadata bytes match the separate codec reference. Focused file, buffer and ABI checks pass. Physical conversions and complete model initialisation remain separate assembly work.

## Local records

The exact ordered routine list, original source paths, build commands, critical checks and raw comparison records remain under ignored `.agents/` and `.runtime/` directories. The source audit covers 5,238 built Fortran bodies, including setup, input/output, support and disabled features. This total is not the number of weather routines that remain.
