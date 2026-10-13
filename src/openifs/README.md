# OpenIFS assembly

Direct assembly routines are grouped into dynamics, physics and surface changes. Dynamics supplies pressure, air properties and atmospheric motion. Physics routines apply heating and other supplied rates. Surface routines update soil, snow, lake and tile states. Each routine must pass its critical physical checks and exact forecast-call comparisons within its declared input range before it is accepted.

## Coverage

A routine body is one function or subroutine that performs a calculation. These counts cover the audited T21 coarse global forecast phase. The groups overlap, so their counts must not be added. They do not cover every model branch or external dependency.

| Scope | Original bodies | Accepted assembly | Remaining |
| --- | ---: | ---: | ---: |
| Main forecast phase | 711 | 247 | 464 |
| Local calculations | 356 | 241 | 115 |
| Weather calculations | 255 | 239 | 16 |

There are 248 accepted original routine bodies with assembly replacements overall. VERDER is outside the main forecast count. The ordered 16-routine weather queue and completed checks remain local. The latest checkpoint accepts complete radiation-field preparation, C3/C4 leaf photosynthesis and interpolation boundaries. The boundary routine adds one main-phase body and no weather body. Earlier inverse-transform, trajectory, latitude-analysis and inner-radiation proofs remain valid.

## Verification

Each accepted routine passes independent critical physics and exact-output checks within its declared input range. The latest checkpoint compares every declared input and returned buffer of three complete replacements. All ten saved files match across 618,140 bytes. Unchanged child physics, arithmetic and interface proofs are reused. The run uses exclusive allocation 7358525 on nid010681, one process, one thread, CPU 16 and local memory binding.

| Latest routine | Complete calls | Compared buffer bytes | Differing bytes |
| --- | ---: | ---: | ---: |
| Radiation-field preparation | 6,400 | 33,449,395,200 | 0 |
| Plant photosynthesis | 6,450 | 77,271,000 | 0 |
| Interpolation boundaries | 2,150 | 11,130,739,200 | 0 |

The totals include all declared buffer views, with repeated bytes where views overlap. Actual profiling calls retain the original control and preserve numerical status. The [radiation contract](../../skills/md2asm/references/openifs/radiation/radiation_field_preparation.md), [photosynthesis contract](../../skills/md2asm/references/openifs/surface/plant_photosynthesis.md) and [boundary contract](../../skills/md2asm/references/openifs/dynamics/interpolation_boundary_values.md) define complete fields, ordered calculations, supported inputs and ABI requirements. The application binary interface, or ABI, states how arguments and registers pass between routines.

The continuity routine assigns positive zero to unused output slots that the original source left unset, while preserving every defined calculation. Its byte comparisons use a separate corrected Fortran reference, without changing any defined values in the saved files. The [continuity contract](../../skills/md2asm/references/openifs/dynamics/vertical_continuity.md) states this representation and its bounds.

The [spectral update](../../skills/md2asm/references/openifs/dynamics/spectral_semi_implicit_update.md), [latitude analysis](../../skills/md2asm/references/openifs/dynamics/legendre_wave_analysis.md) and [inverse reconstruction](../../skills/md2asm/references/openifs/dynamics/inverse_legendre_reconstruction.md) contracts use separately rounded matrix products. Their independently checked Fortran reference replaces the earlier fused vendor route for this comparison. The earlier source and saved files remain local. Their saved bytes differ, and the new direct forecast agrees exactly with the revised reference.

The [wind contract](../../skills/md2asm/references/openifs/trajectories/trajectory_wind_preparation.md) uses a separately verified hyperbolic tangent. This function shapes the vertical prediction weight. Its revised Fortran reference and the direct forecast produce identical saved files. The previous tangent reference and its different outputs remain local.

The complete C4 leaf source reference chooses physically valid roots and retains small gross carbon uptake through the canopy sum. It is checked independently against both carbon-limitation equations. The earlier C4 source and its qualification failures remain local. The direct body matches the corrected source in every observed leaf call and saved forecast file.

A separate observer checks the configured humidity floor in 2,150 matched CALLPAR returns and finite ordered rates over 972,800 active cells. It adds zero routines. Complete forecast-state bounds and full-column water and heat balance remain open.

The comparisons cover declared routine inputs and saved files. Whole-process byte identity, independent physics of the whole forecast and comparative forecast speed remain unproved. Historical full-storage mismatches are preserved in the local records. Individual numerical contracts define supported inputs, arithmetic, interfaces and scientific limits.

## Local records

OpenIFS 48.1.1 supplies the original model source. The complete source audit, build record, physical checks, routine comparison notes and saved-file evidence are retained locally under `.agents/` and `.runtime/`. The source audit counts 5,238 built Fortran routine bodies, including setup, input/output, support and disabled-feature placeholders. That total is not a count of weather calculations that all need assembly.
