# Runtime Configured Model Initialisation

A distributed forecast divides the grid among processes. Its interpolation halo is the extra edge region needed to use neighbouring values. Apply the user's configuration before this region is built, then keep every control in storage owned by the assembly caller. The supplied first NAMPAR1 group sets LSLONDEM false. This selects the fixed halo exchange route in CALL_SL.

## Interfaces and Storage

All entries use the Arm application binary interface. Arguments start at x0, return values use x0, and stack frames have 16-byte alignment. They preserve x18 and the required saved registers. Complete declared input ranges must stay mapped and must not wrap around the address space. Borrowed inputs remain live until return.

| Entry | Arguments | Result |
| --- | --- | --- |
| md2asm_initialize_operational_interpolation_policy | text, byte count, policy16, capacity | 0 on success or 2 on refusal |
| md2asm_complete_runtime_operational_interpolation_halo | Geometry, capacity, MODEL, capacity, partition, capacity, configuration, policy16 | 0 on success, 1 on allocation failure or 2 on refusal |
| md2asm_create_runtime_configured_initialized_operational_model | startup, Geometry sidecar, spectral path, surface path, upper-air path, alias table, fresh output slot | The existing stage status and owned result |
| md2asm_operational_initial_norm_result_bytes | Geometry | A 64-bit byte count or zero on invalid dimensions |

The policy has four 32-bit logical words, in order LSYNC_SLCOM, LSLDEBUG, LSLONDEM and LSYNC_TRANS. Their defaults are false, false, true and false. The bounded first-NAMPAR1 reader applies admitted literal overrides before publishing any output. It accepts 1 through 262144 input bytes, requires a disjoint 16-byte output with four-byte alignment, and leaves that output unchanged on refusal. Its private scanner uses 32 temporary bytes. It performs no floating-point arithmetic.

Geometry, MODEL, partition and configuration contain 20,400, 4,275,088, 4,096 and 67,616 mapped bytes, with eight-byte alignment. The halo caller has a 288-byte frame. It reads the source LELAM flag from configuration and applies policy LSLONDEM before the accepted spherical-width calculation and distributed-map child. Processes agree admission and local preparation before the next communication stage. Failure restores every changed MODEL scalar and releases staged owners. Release remains the accepted distributed interpolation-buffer release.

## Runtime Dimensions and Bounds

The halo calculation reads latitude and polar-row counts from live Geometry. Its caller admits 2 through 65536 latitudes and 1 through 1024 extra polar rows. It uses positive field counts from the live SUSLB producer. It does not require a particular block width or vertical layer count. The linked map provider still supports only its qualified route with 2,560 latitudes, halo width 25, two extra polar rows and four processes. This child limit applies to the composed entry.

Let $`L`$ be the global layer count at byte 5224 of Geometry, $`S`$ the spectral truncation at byte 5172, and $`R`$ the norm-result length in bytes. Five means and a surface norm contribute 48 bytes. Four layer vectors and four matrices with one row per layer and one column per wave supply the rest.

```math
R = 48 + 32L(S+2).
```

The integer count helper admits 1 through 4096 layers and truncation 0 through 65534. At 137 layers and truncation 1279, it returns 5,615,952 bytes. The initialized parent keeps its 256-byte frame, derives this allocation at runtime, reads process count from the live partition and derives terrain bytes from the spectral descriptor's lower and upper bounds. An empty terrain view keeps one valid allocation byte. Its existing 64-byte result owner and release rules are unchanged. The previous default-policy initializer and its API remain available.

## Checks and Limits

Five independent Fortran namelist cases establish the policy bytes. The actual four-process halo join checks the changed control before its consumer, retained source metadata, map boundaries, guards, ABI, coordinated refusals and cleanup. A second block width 31 checks the runtime halo caller on the same physical grid. Nine small cases check norm-storage lengths and invalid dimensions. The initialized-parent check reaches the real configured halo, then uses a verification-only stop before large model work and exercises production cleanup. This stop is absent from the production library.

The existing Geometry, model configuration, input and spectral-norm children retain their declared fixed-profile limits. Later runtime input, terrain and norm forwarding has source/interface coverage until the next complete initialization join. No previous large numerical bank was replayed, and these component checks do not establish a complete forecast or a second physical resolution. The floating-point control register, FPCR, must select the frozen mode. Natural child arithmetic flags and errno remain observable.
