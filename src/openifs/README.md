# OpenIFS assembly

Direct assembly routines are grouped into dynamics, physics and surface changes. Dynamics supplies pressure, air properties and atmospheric motion. Physics routines apply heating and other supplied rates. Surface routines update soil, snow, lake and tile states. Each routine must pass its critical physical checks and exact forecast-call comparisons within its declared input range before it is accepted.

## Coverage

A routine body is one function or subroutine that performs a calculation. These counts cover the audited T21 coarse global forecast phase. The groups overlap, so their counts must not be added. They do not cover every model branch or external dependency.

| Scope | Original bodies | Accepted assembly | Remaining |
| --- | ---: | ---: | ---: |
| Main forecast phase | 711 | 91 | 620 |
| Local calculations | 356 | 90 | 266 |
| Weather calculations | 255 | 88 | 167 |

There are 92 accepted assembly bodies overall. VERDER is outside the main forecast count. The ordered 167-routine weather queue and completed checks remain local. The latest fourteen replacements cover gas and cloud optics, gas and ozone profiles, humidity, convection, diffusion increments and state updates. Each has genuine forecast calls.

## Verification

Each accepted routine passes its declared critical physics and exact-output checks. The latest combined batch adds fourteen bodies. It counts 57,600 direct greenhouse-profile child calls, while each other new body has between 2,150 and 19,350 actual calls. Every compared output byte agrees. All ten saved forecast files match over 618,140 bytes. Earlier accepted body checks and mathematical routes are reused. The run used own exclusive allocation 7240564 on nid010555, one process, one thread, CPU 16 and local memory binding.

The comparisons cover declared routine inputs and saved files. Whole-process byte identity, independent physics of the whole forecast and comparative forecast speed remain unproved. Historical full-storage mismatches are preserved in the local records. Individual numerical contracts define supported inputs, arithmetic, interfaces and scientific limits.

## Local records

OpenIFS 48.1.1 supplies the original model source. The complete source audit, build record, physical checks, routine comparison notes and saved-file evidence are retained locally under `.agents/` and `.runtime/`. The source audit counts 5,238 built Fortran routine bodies, including setup, input/output, support and disabled-feature placeholders. That total is not a count of weather calculations that all need assembly.
