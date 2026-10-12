# OpenIFS assembly

Direct assembly routines are grouped into dynamics, physics and surface changes. Dynamics supplies pressure, air properties and atmospheric motion. Physics routines apply heating and other supplied rates. Surface routines update soil, snow, lake and tile states. Each routine must pass its critical physical checks and exact forecast-call comparisons within its declared input range before it is accepted.

## Coverage

A routine body is one function or subroutine that performs a calculation. These counts cover the audited T21 coarse global forecast phase. The groups overlap, so their counts must not be added. They do not cover every model branch or external dependency.

| Scope | Original bodies | Accepted assembly | Remaining |
| --- | ---: | ---: | ---: |
| Main forecast phase | 711 | 243 | 468 |
| Local calculations | 356 | 238 | 118 |
| Weather calculations | 255 | 236 | 19 |

There are 244 accepted assembly bodies overall. VERDER is outside the main forecast count. The ordered 19-routine weather queue and completed checks remain local. The latest checkpoint accepts complete wind preparation for parcel trajectories. The previous checkpoint accepts complete grid-point calculations, latitude wave analysis, inverse latitude reconstruction and the inner radiation calculation.

## Verification

Each accepted routine passes independent critical physics and exact-output checks within its declared input range. The latest checkpoint passes the complete wind body and the existing surface calculation with zero differing bytes. Every compared array byte agrees, and all ten saved files match across 618,140 bytes. The earlier twenty-four-body and corrected fourteen-body native groups also pass their saved-file gate. Unchanged physical, mathematical and interface checks are reused. The run uses exclusive allocation 7259755 on nid010824, one process, one thread, CPU 16 and local memory binding.

| Latest routine | Complete calls | Compared buffer bytes | Differing bytes |
| --- | ---: | ---: | ---: |
| Parcel trajectory wind | 2,150 | 23,201,050,000 | 0 |
| Surface weather calculation | 2,150 | 73,065,600 | 0 |

The wind comparison includes all input and returned buffers. The surface total covers returned buffers. Its pressure calculation preserves the original multiplication order.

The continuity routine assigns positive zero to unused output slots that the original source left unset, while preserving every defined calculation. Its byte comparisons use a separate corrected Fortran reference, without changing any defined values in the saved files. The [continuity contract](../../skills/md2asm/references/openifs/dynamics/vertical_continuity.md) states this representation and its bounds.

The [spectral update](../../skills/md2asm/references/openifs/dynamics/spectral_semi_implicit_update.md), [latitude analysis](../../skills/md2asm/references/openifs/dynamics/legendre_wave_analysis.md) and [inverse reconstruction](../../skills/md2asm/references/openifs/dynamics/inverse_legendre_reconstruction.md) contracts use separately rounded matrix products. Their independently checked Fortran reference replaces the earlier fused vendor route for this comparison. The earlier source and saved files remain local. Their saved bytes differ, and the new direct forecast agrees exactly with the revised reference.

The [wind contract](../../skills/md2asm/references/openifs/trajectories/trajectory_wind_preparation.md) uses a separately verified hyperbolic tangent. This function shapes the vertical prediction weight. Its revised Fortran reference and the direct forecast produce identical saved files. The previous tangent reference and its different outputs remain local.

A separate observer checks the configured humidity floor in 2,150 matched CALLPAR returns and finite ordered rates over 972,800 active cells. It adds zero routines. Complete forecast-state bounds and full-column water and heat balance remain open.

The comparisons cover declared routine inputs and saved files. Whole-process byte identity, independent physics of the whole forecast and comparative forecast speed remain unproved. Historical full-storage mismatches are preserved in the local records. Individual numerical contracts define supported inputs, arithmetic, interfaces and scientific limits.

## Local records

OpenIFS 48.1.1 supplies the original model source. The complete source audit, build record, physical checks, routine comparison notes and saved-file evidence are retained locally under `.agents/` and `.runtime/`. The source audit counts 5,238 built Fortran routine bodies, including setup, input/output, support and disabled-feature placeholders. That total is not a count of weather calculations that all need assembly.
