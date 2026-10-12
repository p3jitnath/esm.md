# OpenIFS assembly

Direct assembly routines are grouped into dynamics, physics and surface changes. Dynamics supplies pressure, air properties and atmospheric motion. Physics routines apply heating and other supplied rates. Surface routines update soil, snow, lake and tile states. Each routine must pass its critical physical checks and exact forecast-call comparisons within its declared input range before it is accepted.

## Coverage

A routine body is one function or subroutine that performs a calculation. These counts cover the audited T21 coarse global forecast phase. The groups overlap, so their counts must not be added. They do not cover every model branch or external dependency.

| Scope | Original bodies | Accepted assembly | Remaining |
| --- | ---: | ---: | ---: |
| Main forecast phase | 711 | 226 | 485 |
| Local calculations | 356 | 223 | 133 |
| Weather calculations | 255 | 221 | 34 |

There are 227 accepted assembly bodies overall. VERDER is outside the main forecast count. The ordered 34-routine weather queue and completed checks remain local. The latest checkpoint accepts complete time and solar forcing, prognostic transport and radiation-grid preparation. Two earlier supporting transport bodies add to the main count only.

## Verification

Each accepted routine passes independent critical physics and exact-output checks within its declared input range. The latest checkpoint passes three complete numerical parents with zero differing returned bytes. Every compared array byte agrees, and all ten saved files match across 618,140 bytes. The earlier twenty-four-body and corrected fourteen-body native groups also pass their saved-file gate. Unchanged physical, mathematical and interface checks are reused. The run uses exclusive allocation 7259755 on nid010824, one process, one thread, CPU16 and local memory binding.

| Latest routine | Complete calls | Returned bytes | Differing bytes |
| --- | ---: | ---: | ---: |
| Time and solar forcing | 26 | 138,847,904 | 0 |
| Prognostic transport | 2,150 | 236,465,600 | 0 |
| Radiation-grid preparation | 2,150 | 201,652,800 | 0 |

A separate observer checks the configured humidity floor in 2,150 matched CALLPAR returns and finite ordered rates over 972,800 active cells. It adds zero routines. Complete forecast-state bounds and full-column water and heat balance remain open.

The comparisons cover declared routine inputs and saved files. Whole-process byte identity, independent physics of the whole forecast and comparative forecast speed remain unproved. Historical full-storage mismatches are preserved in the local records. Individual numerical contracts define supported inputs, arithmetic, interfaces and scientific limits.

## Local records

OpenIFS 48.1.1 supplies the original model source. The complete source audit, build record, physical checks, routine comparison notes and saved-file evidence are retained locally under `.agents/` and `.runtime/`. The source audit counts 5,238 built Fortran routine bodies, including setup, input/output, support and disabled-feature placeholders. That total is not a count of weather calculations that all need assembly.
