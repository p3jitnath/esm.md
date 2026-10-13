# OpenIFS assembly

Direct assembly routines are grouped into dynamics, physics and surface changes. Dynamics supplies pressure, air properties and atmospheric motion. Physics routines apply heating and other supplied rates. Surface routines update soil, snow, lake and tile states. Each routine must pass its critical physical checks and exact forecast-call comparisons within its declared input range before it is accepted.

## Coverage

A routine body is one function or subroutine that performs a calculation. These counts cover the audited T21 coarse global forecast phase. The groups overlap, so their counts must not be added. They do not cover every model branch or external dependency.

| Scope | Original bodies | Accepted assembly | Remaining |
| --- | ---: | ---: | ---: |
| Main forecast phase | 711 | 255 | 456 |
| Local calculations | 356 | 244 | 112 |
| Weather calculations | 255 | 241 | 14 |

There are 256 accepted original routine bodies with assembly replacements overall. VERDER is outside the main forecast count. The ordered 14-routine weather queue and completed checks remain local. The latest checkpoint accepts the radiation grid driver RADINTG, which adds one body to each scope. Accepted grid-point, spectral, Fourier, radiation, photosynthesis and interpolation proofs remain valid.

## Verification

Each accepted routine passes independent critical physics and exact-output checks within its declared input range. The latest checkpoint checks RADINTG in 25 complete forecast calls, with exact returned and read-only buffers, numerical status and native preserved registers. Three focused cases also check sunlight thresholds, night conditions and absorbing or reflecting surfaces. All ten saved files match across 618,140 bytes. Unchanged child physics and arithmetic proofs are reused. The run uses exclusive allocation 7358525 on nid010681, one process, one thread, CPU 32 and local memory binding.

| Routine | Complete comparisons | Compared buffer bytes | Differing bytes |
| --- | ---: | ---: | ---: |
| RADINTG | 25 calls | 329,519,200 | 0 |
| CPG | 4 full/partial pairs | 933,933,328 | 0 |
| CPG_DRV | 3 reset cases | 775,302,519 | 0 |
| SPCM | 25 calls | 117,642,025 | 0 |
| FOURIER_IN | 192 pairs | 306,441,984 | 0 |
| FOURIER_OUT | 160 pairs | 252,005,504 | 0 |

The [radiation grid contract](../../skills/md2asm/references/openifs/radiation/radiation_grid_driver.md) defines the complete direct parent, its assembly physics children, its frozen C power helper and 14,899,200 independent physical relations. The original reference keeps its original inner radiation stages. An older cold replay differs slightly from its archived return in both the original and direct implementations. That setup limit remains local. Acceptance uses fresh complete live pairs under one runtime setup and the exact saved files.

The [grid-point contract](../../skills/md2asm/references/openifs/dynamics/complete_grid_point_update.md) and [block-driver contract](../../skills/md2asm/references/openifs/dynamics/grid_point_block_driver.md) define the accepted stages and interfaces. The verifier uses the actual smaller allocations for inactive diagnostic outputs and checks their complete bytes. It preserves the raw addresses of legacy arrays with no source consumer, while retaining their real backing storage. Repeated CPG inputs with an already-checked row extent and control tuple use the separate reference in this verification run. The direct block-driver checks cover the initial reset and both sides of its periodic reset rule.

The [spectral driver contract](../../skills/md2asm/references/openifs/dynamics/spectral_calculation_driver.md) records all seven direct stages, exact numerical status and preserved registers. Four protected copy cases check 155,848 independent index relations and preserve inactive data. The existing physical and buffer-bound proofs of unchanged children are reused.

The transfer gate checks the first actual field-count and latitude tuple for each routine, including both latitude ends. It passes 581,504 independent word-copy relations, with zero raw-status or saved-register failures. Repeated calls with an already-checked tuple use the original reference in this verification run. The [packing contract](../../skills/md2asm/references/openifs/dynamics/fourier_buffer_packing.md) defines the complete buffers, supported inputs and assembly interface. The application binary interface, or ABI, states how arguments and registers pass between routines.

The continuity routine assigns positive zero to unused output slots that the original source left unset, while preserving every defined calculation. Its byte comparisons use a separate corrected Fortran reference, without changing any defined values in the saved files. The [continuity contract](../../skills/md2asm/references/openifs/dynamics/vertical_continuity.md) states this representation and its bounds.

The [spectral update](../../skills/md2asm/references/openifs/dynamics/spectral_semi_implicit_update.md), [latitude analysis](../../skills/md2asm/references/openifs/dynamics/legendre_wave_analysis.md) and [inverse reconstruction](../../skills/md2asm/references/openifs/dynamics/inverse_legendre_reconstruction.md) contracts use separately rounded matrix products. Their independently checked Fortran reference replaces the earlier fused vendor route for this comparison. The earlier source and saved files remain local. Their saved bytes differ, and the new direct forecast agrees exactly with the revised reference.

The [wind contract](../../skills/md2asm/references/openifs/trajectories/trajectory_wind_preparation.md) uses a separately verified hyperbolic tangent. This function shapes the vertical prediction weight. Its revised Fortran reference and the direct forecast produce identical saved files. The previous tangent reference and its different outputs remain local.

The complete C4 leaf source reference chooses physically valid roots and retains small gross carbon uptake through the canopy sum. It is checked independently against both carbon-limitation equations. The earlier C4 source and its qualification failures remain local. The direct body matches the corrected source in every observed leaf call and saved forecast file.

A separate observer checks the configured humidity floor in 2,150 matched CALLPAR returns and finite ordered rates over 972,800 active cells. It adds zero routines. Complete forecast-state bounds and full-column water and heat balance remain open.

The comparisons cover declared routine inputs and saved files. Whole-process byte identity, independent physics of the whole forecast and comparative forecast speed remain unproved. Historical full-storage mismatches are preserved in the local records. Individual numerical contracts define supported inputs, arithmetic, interfaces and scientific limits.

## Local records

OpenIFS 48.1.1 supplies the original model source. The complete source audit, build record, physical checks, routine comparison notes and saved-file evidence are retained locally under `.agents/` and `.runtime/`. The source audit counts 5,238 built Fortran routine bodies, including setup, input/output, support and disabled-feature placeholders. That total is not a count of weather calculations that all need assembly.
