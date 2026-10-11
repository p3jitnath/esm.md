# OpenIFS assembly

Direct assembly routines are grouped into dynamics, physics and surface changes. Dynamics supplies pressure, air properties and atmospheric motion. Physics routines apply heating and other supplied rates. Surface routines update soil, snow, lake and tile states. Each routine must pass its critical physical checks and exact forecast-call comparisons within its declared input range before it is accepted.

## Coverage

A routine body is one function or subroutine that performs a calculation. These counts cover the audited T21 coarse global forecast phase. The groups overlap, so their counts must not be added. They do not cover every model branch or external dependency.

| Scope | Original bodies | Accepted assembly | Remaining |
| --- | ---: | ---: | ---: |
| Main forecast phase | 711 | 116 | 595 |
| Local calculations | 356 | 115 | 241 |
| Weather calculations | 255 | 113 | 142 |

There are 117 accepted assembly bodies overall. VERDER is outside the main forecast count. The ordered 142-routine weather queue and completed checks remain local. The latest twenty-four replacements cover complete shortwave gas optics, ten longwave bands, both atmospheric coefficient preparations, convection, saturation adjustment, gravity-wave drag, boundary-layer height, field transfer and implicit momentum diffusion. Each has genuine forecast calls. The contained GPRCP accumulation is also identified in its unchanged accepted parent, with 8,600 actual model stages and reused complete parent checks.

## Verification

Each accepted routine passes its declared critical physics and exact-output checks. The latest combined batch adds twenty-four bodies, with 2,150 through 234,868 actual calls per body. Every compared output byte agrees. All ten saved forecast files match over 618,140 bytes. Earlier accepted body checks and mathematical routes are reused. The run used own exclusive allocation 7240564 on nid010555, one process, one thread, CPU 16 and local memory binding.

The comparisons cover declared routine inputs and saved files. Whole-process byte identity, independent physics of the whole forecast and comparative forecast speed remain unproved. Historical full-storage mismatches are preserved in the local records. Individual numerical contracts define supported inputs, arithmetic, interfaces and scientific limits.

## Local records

OpenIFS 48.1.1 supplies the original model source. The complete source audit, build record, physical checks, routine comparison notes and saved-file evidence are retained locally under `.agents/` and `.runtime/`. The source audit counts 5,238 built Fortran routine bodies, including setup, input/output, support and disabled-feature placeholders. That total is not a count of weather calculations that all need assembly.
