# OpenIFS assembly

Direct assembly routines are grouped into dynamics, physics and surface changes. Dynamics supplies pressure, air properties and atmospheric motion. Physics routines apply heating and other supplied rates. Surface routines update soil, snow, lake and tile states. Each routine must pass its critical physical checks and exact forecast-call comparisons within its declared input range before it is accepted.


## Coverage

A routine body is one function or subroutine that performs a calculation. These counts cover the audited T21 coarse global forecast phase. The groups overlap, so their counts must not be added. They do not cover every model branch or external dependency.

| Scope | Original bodies | Accepted assembly | Remaining |
| --- | ---: | ---: | ---: |
| Main forecast phase | 711 | 52 | 659 |
| Local calculations | 356 | 51 | 305 |
| Weather calculations | 255 | 49 | 206 |

There are 53 accepted assembly bodies overall. VERDER is outside the main forecast count. The exact ordered 206-routine weather queue is kept locally in `.agents/weather-routine-queue-7207705.tsv`. The next routine is adding_ica_sw, which transports radiation through atmospheric layers. Its original calls are captured, but its full independent physics check reached the 15-minute execution limit and is not accepted.

## Verification

Each accepted routine passes its declared critical physics and exact-output checks. The latest forecast retains 50 complete earlier original/assembly paired streams over 7,595,504,008 bytes, adds 6,400 same-input Band 21 pairs over 361,958,400 returned bytes, and matches ten saved files over 618,140 bytes. Every accepted comparison has zero differing bytes. The run used own exclusive allocation 7207705 on nid011311, one process, one thread, CPU 16 and local memory binding.

The comparisons cover declared routine inputs and saved files. Whole-process byte identity, independent physics of the whole forecast and comparative forecast speed remain unproved. Historical full-storage mismatches are preserved in the local records. Individual numerical contracts define supported inputs, arithmetic, interfaces and scientific limits.

## Local records

OpenIFS 48.1.1 supplies the original model source. The complete source audit, build record, physical checks, routine comparison notes and saved-file evidence are retained locally under `.agents/` and `.runtime/`. The source audit counts 5,238 built Fortran routine bodies, including setup, input/output, support and disabled-feature placeholders. That total is not a count of weather calculations that all need assembly.
