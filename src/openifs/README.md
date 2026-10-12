# OpenIFS assembly

Direct assembly routines are grouped into dynamics, physics and surface changes. Dynamics supplies pressure, air properties and atmospheric motion. Physics routines apply heating and other supplied rates. Surface routines update soil, snow, lake and tile states. Each routine must pass its critical physical checks and exact forecast-call comparisons within its declared input range before it is accepted.

## Coverage

A routine body is one function or subroutine that performs a calculation. These counts cover the audited T21 coarse global forecast phase. The groups overlap, so their counts must not be added. They do not cover every model branch or external dependency.

| Scope | Original bodies | Accepted assembly | Remaining |
| --- | ---: | ---: | ---: |
| Main forecast phase | 711 | 244 | 467 |
| Local calculations | 356 | 239 | 117 |
| Weather calculations | 255 | 237 | 18 |

There are 245 accepted assembly bodies overall. VERDER is outside the main forecast count. The ordered 18-routine weather queue and completed checks remain local. The latest checkpoint accepts the complete inverse spectral transform, which prepares wind and derivative coefficients and reconstructs latitude fields. Earlier checkpoints accept parcel-trajectory wind, complete grid-point calculations, latitude wave analysis, inverse latitude reconstruction and the inner radiation calculation.

## Verification

Each accepted routine passes independent critical physics and exact-output checks within its declared input range. The latest checkpoint accepts the complete inverse spectral transform with zero differing bytes in every compared caller buffer. All ten saved files match across 618,140 bytes. Unchanged child physics, arithmetic and interface proofs are reused. The run uses exclusive allocation 7358525 on nid010681, one process, one thread, CPU 16 and local memory binding.

| Latest routine | Complete calls | Compared buffer bytes | Differing bytes |
| --- | ---: | ---: | ---: |
| Inverse spectral transform | 1,144 | 3,074,651,888 | 0 |

The transform total includes all input and returned buffers, with 1,660,659,440 immutable bytes. Its actual profiling calls preserve the complete numerical status. The [transform contract](../../skills/md2asm/references/openifs/dynamics/inverse_spectral_transform.md) records the complete field map, child equations, supported shapes and raw ABI checks.

The continuity routine assigns positive zero to unused output slots that the original source left unset, while preserving every defined calculation. Its byte comparisons use a separate corrected Fortran reference, without changing any defined values in the saved files. The [continuity contract](../../skills/md2asm/references/openifs/dynamics/vertical_continuity.md) states this representation and its bounds.

The [spectral update](../../skills/md2asm/references/openifs/dynamics/spectral_semi_implicit_update.md), [latitude analysis](../../skills/md2asm/references/openifs/dynamics/legendre_wave_analysis.md) and [inverse reconstruction](../../skills/md2asm/references/openifs/dynamics/inverse_legendre_reconstruction.md) contracts use separately rounded matrix products. Their independently checked Fortran reference replaces the earlier fused vendor route for this comparison. The earlier source and saved files remain local. Their saved bytes differ, and the new direct forecast agrees exactly with the revised reference.

The [wind contract](../../skills/md2asm/references/openifs/trajectories/trajectory_wind_preparation.md) uses a separately verified hyperbolic tangent. This function shapes the vertical prediction weight. Its revised Fortran reference and the direct forecast produce identical saved files. The previous tangent reference and its different outputs remain local.

A separate observer checks the configured humidity floor in 2,150 matched CALLPAR returns and finite ordered rates over 972,800 active cells. It adds zero routines. Complete forecast-state bounds and full-column water and heat balance remain open.

The comparisons cover declared routine inputs and saved files. Whole-process byte identity, independent physics of the whole forecast and comparative forecast speed remain unproved. Historical full-storage mismatches are preserved in the local records. Individual numerical contracts define supported inputs, arithmetic, interfaces and scientific limits.

## Local records

OpenIFS 48.1.1 supplies the original model source. The complete source audit, build record, physical checks, routine comparison notes and saved-file evidence are retained locally under `.agents/` and `.runtime/`. The source audit counts 5,238 built Fortran routine bodies, including setup, input/output, support and disabled-feature placeholders. That total is not a count of weather calculations that all need assembly.
