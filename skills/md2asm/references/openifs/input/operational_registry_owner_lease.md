# Operational Registry Owner Lease

The [assembly parent](../../../../../src/openifs/input/operational_registry_owner_lease.S) creates model storage at its final addresses, loads the initial state and joins a field registry to 87 actual numerical array owners. A registry stores descriptions and addresses of arrays; it does not duplicate their numerical values. The 87 owners comprise 21 Geometry arrays, four motion arrays, two general arrays, 34 surface arrays, five tile arrays and 21 radiation arrays. A sixth TEC physics-array owner remains live beside the five registered tiles.

The lease is an 8944-byte record that keeps the addresses and construction phase needed for release. It builds on the [enclosing model storage](../setup/operational_enclosing_model_storage.md), [registry](../setup/runtime_field_registry.md) and [registry release](../setup/runtime_field_registry_release.md) contracts. This composition adds no new physical equation or arithmetic method. It preserves each admitted child's source order, numerical method and external-library boundary.

## Entry points and bounds

`md2asm_create_actual_registry_owner_lease` takes seven arguments in `x0` through `x6`: the live startup owner of 9968 bytes; the complete Geometry sidecar of 1872 bytes; zero-terminated spectral, surface and upper-air file paths; a 120-byte table of alias destinations; and a fresh eight-byte output slot. The table holds the addresses of fifteen distinct eight-byte words, initially zero. The caller keeps these words and the table live until release.

The startup, sidecar and their referenced records must be complete, mapped and valid under their child contracts. Every address range must avoid integer wraparound. Mutable ranges and referenced numerical owners must be separate where the child contracts require this. Records and pointer words have eight-byte alignment, and the stack has sixteen-byte alignment. The caller supplies one exclusive construction and reader lifetime for the canonical parameter storage.

Success returns zero in `w0` and publishes the lease address through the output slot. Before registry construction, a child failure follows the recorded source phase and attempts normal cleanup. A failed setup cannot supply numerical work. A nonzero registry result publishes a fatal retained lease; the assembly main must report the setup error and terminate the process.

`md2asm_release_actual_registry_owner_lease` takes the address of the eight-byte output slot in `x0`. It returns zero after normal release and clears that slot. An already empty slot succeeds. Invalid state or a fatal retained lease returns two before any write. Any unexpected child-release refusal is also a terminal setup error; this contract provides no recovery route for it.

Both parent entries preserve the Arm saved-register rules and use aligned 256-byte frames. Creation retains the admitted natural floating-point status and error-number effects of its children. Release saves and restores the floating-point control register, floating-point status register and `errno`, the library error-number word. The caller enters with floating-point control zero, as required by the existing arithmetic contracts.

## Lease layout and source order

| Byte offset | Contents |
| ---: | --- |
| 0 | Eight-byte marker `0x52474c31` |
| 8, 16, 24 | Model-owner, startup-owner and Geometry-sidecar addresses |
| 32, 40 | Eight-byte completed phase and setup status |
| 48, 52 | Four-byte microwave count and registry result |
| 56 | Eight-byte fatal-partial flag |
| 64, 808 | Radiation namespace, 744 bytes; climate selection, 2640 bytes |
| 3448, 3560 | Upstream radiation record and radiation table, 112 bytes each |
| 3672, 3736 | Physics and hydrostatic contexts, 64 bytes each |
| 3800, 4544 | Dynamics maps, 744 bytes; pressure output, 4400 bytes |

The selected order is canonical physical constants; model and configuration; canonical dynamics and clock; physics controls; Lagrangian and saved-departure storage; dynamics maps and initial physics interval; the ECMWF physics prefix; early radiation setup and its 21 owners; the six TEC owners; the remaining tendency, motion and spectral producers; distributed terrain; surface and upper-air loading; next-time storage; and registry construction. The registry uses INIT, Geometry, motion, general, surface, ECMWF physics and radiation registration in source order.

The terrain producer receives the actual loaded spectral OROG view and live source controls. All four ranks enter its two public inverse transforms. Its three blocked terrain arrays remain live through every registry and metadata reader. The canonical physical, dynamical and thermal buffers are the same storage used by the selected helper graph; later convection outputs remain in that thermal storage.

The [physics-control forwarder](../../../../../src/openifs/setup/operational_registry_physics_controls.S) takes configuration in `x0`, actual configuration text in `x1` and its byte count in `x2`. The configuration span reaches byte 51512; text is at most 262144 bytes. It retains the supported controls and empty `NAMDYNA_STATIC` and `NAMTESTVAR` checks of [physics runtime data](../setup/physics_runtime_data_bindings.md), then writes the same five false words at the actual canonical 608-byte owner. Its 80-byte frame, bounds checks, fresh-storage policy and reserved bytes are unchanged. This explicit source policy does not infer an arbitrary live flag from zero-filled memory.

## Lifetime and failure policy

Every registry reader and borrowed work record must finish before release. Normal release frees the successful registry first, then terrain, six TEC owners, 21 radiation owners, three Planck owners, cloud eta, model storage and the lease. It clears all fifteen caller-supplied aliases. Geometry and startup release last, after their final readers. A caller retires any context or view that depends on these owners before release.

For the admitted allocation-failure case, the first 160800-byte surface-registry request is allocation ordinal 104. Construction returns status 122 with registry result two, phase 110 and fatal flag one. The registry retains exactly 103 allocations and 111481 requested bytes. Its upstream model, radiation, TEC and other allocations also remain live. Release returns two and preserves the complete lease, output slot, aliases and borrowed owners. Process exit is the sole disposal; successful finalization and numerical continuation are excluded.

## Qualification and limits

A genuine four-rank assembly check used the same input files and four-process configuration as the existing Fortran reference. The main Fortran executable stayed unchanged. The live dimensions were block width 17, 137 levels, point-count word 1649920 and block-count word 97055. This is the inherited admitted specialization. Other resolutions require the input-adapter extensions and their own owner checks before any broader support claim.

On all four ranks, native registry construction produced 2183 metadata owners and 772240 requested bytes. One live 96-byte context publication then matched all twelve pointer and policy words, including the unique assembly-owned false weather-hook control. Its exact allowed changes to clock, configuration and runtime words matched; all other observed bytes and guards remained unchanged. The separately configured public FIAT profiling word stayed false. Normal release cleared every alias and output slot, released all direct allocations and left equal allocation and release counts of 293706 per rank. Registry and work guard mappings and retained raw snapshots became empty.

The isolated failure check observed the exact declared prefix and refused release on all four ranks, then exited directly. The verifier's zero exit status means that this failure-policy check passed; it does not convert setup status 122 into successful model construction. Resource monitors and controllers passed, and independent checks found no remaining owned process, process group or old Slurm-step process after either mode.

The gate reuses the accepted registry correspondence and three- and seven-record work checks. The new joined observations establish actual storage, context publication and release.

The gate used per-process address-space and sampled resident-memory limits of 256 and 224 GiB, with a 256 GiB limit on this job's total memory on each node. One GiB is 1,073,741,824 bytes. Both modes met their admitted memory and process deadlines. Some public-library allocations remain until process exit, within a separately recorded envelope. All direct owners were released on the normal path. Detailed memory records and cutoff observations remain local and are not forecast timings.

This checkpoint accepts actual storage, owner association, context publication and lifetime for the stated configuration. It does not accept whole SUPHY, the complete ten-record update order, CALLPAR, a weather time step or an autonomous forecast. Unchanged scientific and mathematical banks, private helper routes, counters and status interfaces remain in force.
