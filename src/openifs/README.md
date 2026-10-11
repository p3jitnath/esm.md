# OpenIFS assembly

Direct assembly routines are grouped into dynamics, physics and surface changes. Dynamics supplies pressure, air properties and atmospheric motion. Physics routines apply heating and other supplied rates. Surface routines update soil, snow, lake and tile states. Each routine must pass its critical physical checks and exact forecast-call comparisons within its declared input range before it is accepted.

## Coverage

A routine body is one function or subroutine that performs a calculation. These counts cover the audited T21 coarse global forecast phase. The groups overlap, so their counts must not be added. They do not cover every model branch or external dependency.

| Scope | Original bodies | Accepted assembly | Remaining |
| --- | ---: | ---: | ---: |
| Main forecast phase | 711 | 200 | 511 |
| Local calculations | 356 | 199 | 157 |
| Weather calculations | 255 | 197 | 58 |

There are 201 accepted assembly bodies overall. VERDER is outside the main forecast count. The ordered 58-routine weather queue and completed checks remain local. The latest combined batch accepts 42 complete atmospheric, surface, snow, transport and spectral bodies from genuine model calls.

## Verification

Each accepted routine passes independent critical physics and exact-output checks. The latest batch adds 42 complete bodies with positive actual calls. Every compared owner byte agrees, and all ten saved files match across 618,140 bytes. The earlier twenty-four-body and corrected fourteen-body native closures also pass their saved-file gate. Unchanged physical, mathematical and interface checks are reused. The run uses exclusive allocation 7240564 on nid010555, one process, one thread, CPU16 and local memory binding.

The comparisons cover declared routine inputs and saved files. Whole-process byte identity, independent physics of the whole forecast and comparative forecast speed remain unproved. Historical full-storage mismatches are preserved in the local records. Individual numerical contracts define supported inputs, arithmetic, interfaces and scientific limits.

## Local records

OpenIFS 48.1.1 supplies the original model source. The complete source audit, build record, physical checks, routine comparison notes and saved-file evidence are retained locally under `.agents/` and `.runtime/`. The source audit counts 5,238 built Fortran routine bodies, including setup, input/output, support and disabled-feature placeholders. That total is not a count of weather calculations that all need assembly.
