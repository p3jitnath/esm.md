# Live disabled stochastic physics forwarding

This entry connects the live configuration and model records to the accepted disabled `SURAND1` setup. It uses the model clock produced by `SURIP` and the dynamics controls produced by `SUDYN`. It does not replace the setup stages between those source calls. The supported input has a present, empty `NAMSTOPH` group; an absent group and active stochastic schemes are outside this entry.

The implementation is [live_disabled_stochastic_physics_forwarding.S](../../../../../src/openifs/setup/live_disabled_stochastic_physics_forwarding.S). Its unchanged child and equations are defined in [disabled_stochastic_physics_setup.md](disabled_stochastic_physics_setup.md). The early clock producer is [operational_time_integration.S](../../../../../src/openifs/setup/operational_time_integration.S).

## Interface and bounds

`md2asm_initialize_live_disabled_stochastic_physics` receives eight arguments in registers `x0` through `x7` and returns a status in `w0`.

| Registers | Input | Required bytes |
|---|---|---:|
| `x0`, `x1` | Geometry address and capacity | 20,400 |
| `x2`, `x3` | MODEL address and capacity | 4,275,088 |
| `x4`, `x5` | configuration address and capacity | 67,616 |
| `x6`, `x7` | namelist text address and byte count | 1 to 262,144 |

The three records must have 8-byte alignment. All four input ranges must be mapped, nonzero, separate and free from address overflow. A capacity may exceed the required span, but the span above defines each overlap check. The caller retains every owner through setup and its later readers. The entry allocates no storage.

The configuration must refer to the supplied MODEL at offset 0 and Geometry at offset 16. MODEL offset 8 must refer to the same Geometry. Configuration offset 24 must contain the marker `0x47314346`. The selected controls are `NCONF=1`, `LECMWF=true` and `LELAM=false`, read at configuration offsets 35,688, 40,104 and 35,872. `LELAM` selects the global model; it is distinct from `LR2D`.

The configuration time step at offset 51,704 must match both `TSTEP` and the early `TDT` at MODEL offsets 1,359,528 and 1,359,536. All three are FP64 values in seconds. Their common value must be finite, positive and no greater than 1,000,000 seconds. The wrapper reads these live values and contains no time-step literal. Later `UPDTIM` states are outside this early setup interface.

## Source order and mutations

The source calls `SURIP` in `SU0YOMA` before `SU0YOMB`. Within `SU0YOMB`, `SUDYN` precedes `INI_CUCONVCA`, which precedes `SURAND1`. The caller must complete those actual producers in that order. MODEL's embedded STOPH record must already have the declared type defaults and unallocated pointer descriptors; zero allocation alone does not establish these source prerequisites.

The wrapper forwards MODEL+4,126,168 as the 2,904-byte STOPH record, MODEL+1,564,592 as TDYN, MODEL+1,359,328 as TRIP, configuration+168 as the physical radius in metres, and the supplied Geometry and text. It passes these final addresses directly to the accepted child. The child writes its declared 416 bytes inside STOPH, including `LFORCENL=false` and `LSTOPH_SPBS_T=false`; all other MODEL, Geometry, configuration and text bytes are preserved. A refused guard or nonempty `NAMSTOPH` returns status 2 before these writes. Status 0 denotes successful child completion.

The application binary interface (ABI) requires preservation of `x18`, the saved integer and vector registers, the stack pointer, the floating-point control register and `errno`. The control register must be zero on entry, which selects the qualified rounding and exception settings. The child retains its natural floating-point status changes. The wrapper has a 96-byte frame with 16-byte alignment; the wrapper and child require at most 176 bytes of stack together. No original OpenIFS global, constructor, method table or verification wrapper supplies this production stage.

## Qualification and limits

An independent source and loaded-code review checked the complete 552-byte wrapper, its 8-byte constant, the corrected `LELAM` address and its actual unchanged child target. The accepted source-child numerical records were reused. A single detached check then used captured live Geometry, MODEL and configuration records with three explicit owner-address rebases. It reused the accepted runtime diffusion output and early 450-second clock; it made no original, factory, Geometry, input-loading, transform or diffusion call.

The 15-call combined check passed one cellular setup, one live stochastic setup, four forwarding refusals, two outer-owner creation attempts, one refused, two first/final global perturbation updates, two finalizations and three releases. Complete saved pre/post records confirmed the 110 cellular bytes and 416 STOPH bytes, while every other byte followed its declared preservation rule. All calls passed ABI, status, rounding and `errno` checks. The public FIAT profiling word was preserved. The global perturbation check observed three real allocations and three matching frees, refused release while the dummy owner was live, restored its four verification allocation slots, closed guarded mappings and left no child process. Dummy payload bytes were not read.

The changed forwarding refusals cover short configuration capacity, a mismatched Geometry association, a later `TDT` and a nonempty `NAMSTOPH`.

The child supports its declared runtime wave and row bounds, including `NSMAX` from 1 to 4,096 and `NDGLG` from 1 to 8,192. This forwarding check used global 137 and local 69 levels, wave 1,279, 2,560 rows and the captured block metadata. It proves the changed transport and lifetime boundary for that fixture. It does not accept an additional forecast resolution, full `SUDYN`, complete `SUPHY`, the whole ten-record driver order or a forecast. The separate full diffusion coefficient and storage provider keeps its own narrower limits until extended. The main Fortran executable remains unchanged.
