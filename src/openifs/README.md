# OpenIFS Assembly

These direct assembly routines calculate atmospheric motion, heating, radiation and surface changes. They are grouped by physical theme. A routine body means one original function or subroutine. Each accepted body has independent critical checks and exact comparisons within its declared input range.

## Coverage

The table describes the audited coarse T21 global forecast. Its groups overlap and must not be added. The latest checkpoint adds selected input, grid setup and physics dimension methods to the accepted weather calculations.

| Scope | Original bodies | Accepted assembly | Remaining |
| --- | ---: | ---: | ---: |
| Main forecast phase | 711 | 276 | 435 |
| Local calculations | 356 | 262 | 94 |
| Weather calculations | 255 | 255 | 0 |

There are 287 accepted original bodies overall, including VERDER outside the main forecast phase. Seven field-registry methods from the original template source are recorded separately from this inventory. Completing the weather list does not cover every model branch, setup routine or external dependency.

## Verification

The joint checkpoint uses one direct forecast time loop and 25 direct time updates. Its private update path writes each scheduled output once. Separate source and assembly forecasts start from the same binary inputs. Existing checks of unchanged children and completed numerical source-first/native stage pairs are reused. The 25 native update calls show completion; this gate does not compare raw state after every step.

| Compared output | Complete scope | Differing bytes |
| --- | ---: | ---: |
| Final state | 685 buffer owners, 27,486,113 bytes | 0 |
| Saved forecast files | 10 files, 618,140 bytes | 0 |
| Numerical status and step controls | 56 status bytes and 8 control bytes | 0 |

A buffer owner is a complete retained array or record in model memory. The final-state gate compares its numerical bytes and checks the recorded array layout. It applies the existing rules for address metadata without changing numerical values. The source archive fixes unused incoming storage before the first calculation. Both sea-ice albedo tables retain their 576 initialized bytes and bind their 768 unused bytes. The solar-fraction table retains 48 initialized bytes and binds 64 unused bytes. Each of the two terrain tables retains 16,384 initialized bytes and binds its 128-byte final-block tail. Source allocation and consumer bounds establish that these tails are unused. Complete before and after packets are retained, and every final byte remains compared. The status gate checks floating-point controls, exception flags and the system error value. The assembly also preserves the registers required by its application binary interface, or ABI. The original source's documented use of register x18 remains a separate source limit.

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

The executable still uses OpenIFS Fortran for model startup, remaining setup, typed metadata and retained reference forwards. The [direct power routine](../../skills/md2asm/references/openifs/support/power_original_rounding.md) now replaces the frozen C power helper and passes this same complete forecast gate. Other declared numerical and runtime boundaries remain. It is not an autonomous assembly forecast. Autonomous input loading, initialisation, complete calculation ownership and output remain a separate phase.

## Input And Setup Components

The assembly readers use the declared C ecCodes file-format library. A record contains one decoded field and its identifying labels. Separate controls check each stage, including malformed input, buffer bounds, final partial blocks and the Arm ABI. The original input files supply every decoded value.

| Accepted component | Complete comparison scope | Contract |
| --- | --- | --- |
| Spectral decoding and placement | 78 decoded records and 238,832 placed bytes | [Spectral placement](../../skills/md2asm/references/openifs/input/spectral_initial_state_placement.md) |
| Upper-air decoding and placement | 76 records and 2,509,824 model bytes, including padding | [Upper-air loading](../../skills/md2asm/references/openifs/input/upper_air_initial_state_loading.md) |
| Surface decoding, selection and conversion | 140 records, with 52 selected fields in original order | [Surface loading](../../skills/md2asm/references/openifs/input/initial_surface_state_loading.md) |
| Surface placement | Five complete owners containing 2,146,560 bytes | [Surface placement](../../skills/md2asm/references/openifs/input/initial_surface_state_placement.md) |
| Physics grid dimensions | Complete 192-byte records and 25 initialization / 2,150 update calls | [Grid dimensions](../../skills/md2asm/references/openifs/support/physics_grid_dimensions.md) |

The latest complete forecast uses the direct surface and upper-air loading routes. It also uses seven direct field-registry methods and direct serial Laplacian, Gaussian-latitude and spherical-grid setup. These routes pass the complete final-state and saved-file gate above. The [assembly surface startup stage](../../skills/md2asm/references/openifs/input/initial_surface_state_startup.md) now owns the earlier defaults across all allocated rows, with every one of 7,149,696 bytes in ten captured owners checked. Temporary typed getters still supply metadata to the input bridges.

The [latitude geometry constructor](../../skills/md2asm/references/openifs/setup/latitude_geometry_setup.md) also passes this forecast. The [spectral packing fit](../../skills/md2asm/references/openifs/output/spectral_packing_fit.md) runs 120 times with 5,280 direct logarithm calls and exact saved files. Original Fortran file writers and complete model construction remain unfinished.

## Local records

The exact ordered routine list, original source paths, build commands, critical checks and raw comparison records remain under ignored `.agents/` and `.runtime/` directories. The source audit covers 5,238 built Fortran bodies, including setup, input/output, support and disabled features. This total is not the number of weather routines that remain.
