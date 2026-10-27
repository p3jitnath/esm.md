# Runtime Spectral Pressure And Rotation

The [semi-implicit formulation](../../../../../formulations/openifs/dynamics/spectral_semi_implicit_update.md) treats fast atmospheric waves through a linear solve. The [spectral calculation](../../../../../formulations/openifs/dynamics/spectral_calculation_driver.md) connects that solve to each time update. These assembly children retain the source coefficients, wave order and separately rounded FP64 operations. The supplied field units remain unchanged. The time step is in seconds, and the planet's angular velocity is in inverse seconds.

## Interfaces

An application binary interface, or ABI, specifies how arguments and saved registers pass between routines. Each entry uses the Arm ABI, preserves x18 and the required general and vector registers, and requires FPCR zero. Scalar integers have four bytes, pointers have eight bytes, and numerical values use FP64. Scalars require four-byte alignment and complete records require eight-byte alignment. Every complete array allocation and descriptor must remain mapped through its last read. Output may share input storage only where the original interface permits it, retaining source load and store order.

| Assembly Entry | Original Arguments And Added Context | Frame |
| --- | --- | ---: |
| [md2asm_runtime_spectral_rotation_prepare](../../../../../src/openifs/dynamics/runtime_spectral_rotation_prepare.S) | Geometry, time record, dynamics, wave index, first coefficient, unused last coefficient, vorticity descriptor and auxiliary descriptor. A physical520 pointer is argument9 at incoming stack byte0 | 224 bytes |
| [md2asm_runtime_spectral_rotation_correct](../../../../../src/openifs/dynamics/runtime_spectral_rotation_correct.S) | The same first six pointers, then divergence and vorticity descriptors. Physical520 is argument9 at incoming stack byte0 | 256 bytes |
| [md2asm_runtime_pressure_wave_solve](../../../../../src/openifs/dynamics/runtime_pressure_wave_solve.S) | Geometry, time record, dynamics, two false nonhydrostatic flags, the complete-wave flag, input and output rank-two descriptors. Context32 is argument9 at incoming stack byte0 | 1024 bytes |
| [md2asm_runtime_simplico_workspace](../../../../../src/openifs/dynamics/runtime_pressure_recurrence_workspace.S) | Thirteen original scalar and raw-array pointers for the wave solve, followed by private workspace as argument14 at incoming stack byte40 | 288 bytes |

The pressure context contains partition4096, physical520, a native workspace budget in bytes and reserved zero. The partition must associate the same Geometry and have completed phase7, meaning that its coefficient maps are ready. Physical520 contains the planet's angular velocity at byte96. The caller admits source-supported hydrostatic controls, which assume vertical pressure balance. Other physical modes require their declared route.

## Bounds And Storage

Read the live maximum wave degree from Geometry5172, global layers from5224, local layers from5228, coefficient count from5200 and selected wave count from5212. The source extension admits maximum degree1through8191 and global layers1through512, with positive local layers no greater than the global count. Coefficient starts, selected waves and selected levels come from their complete source descriptors. First and last coefficient ranges must fit the fields. Rotation children require a wave index from zero through the maximum degree and a private allocation of40times(degree+2)bytes. Each allocation is freed after its final coefficient reader. These declared source bounds are wider than the numerically qualified cases below.

The pressure parent owns one allocation. Let $`N`$ be the maximum degree, $`L`$ the local layer count and $`S`$ the local coefficient count. The required storage $`B`$, in bytes, is

```math
B = 16LS + 8[5(N+2)+L] + 16(N+1)L.
```

The last term is the reusable recurrence workspace. The caller's positive budget is at most 64 GiB. All processes agree shape and allocation status before entering communication. The recurrence child borrows exactly $`16(N+1)L`$ bytes and performs no allocation. Its coefficient vectors include every degree that it reads, with the source endpoint padding.

Prepare and correct rotation factors in the original order, then retain the real or complex pressure recurrence for each selected wave. A complex coefficient has real and imaginary parts. Wave zero retains the source positive-zero imaginary part. The pressure parent uses the qualified runtime transposes to move coefficients between process layouts. Its named frame slots bind the current wave index and squared time factor to the same stores and child arguments. No driver supplies a numerical stage.

Return zero on success, one for collective allocation refusal or two for unsupported input. A nonzero result invalidates that update. Release all acquired private storage before a returned failure. The [terminal entry](../../../../../src/openifs/dynamics/runtime_spectral_update_abort.S) calls public MPI_Abort with error3 when an inner child cannot return a valid state. MPI is the public library used to communicate between processes. These children call no original OpenIFS calculation or global owner.

## Evidence And Limits

The joined component check passes ten source/native pairs and one native prewrite budget refusal. It compares47,279,604complete nonaddress bytes and1282typed pointer relations. Pointers refer to live owners and offsets, so their addresses are checked as relations while every numerical output byte is compared directly. All4807independent pressure residuals and703934independent rotation values pass. The corrected pressure allocation, input guards, native ABI, raw FPCR/FPSR and process cleanup pass. Source and native natural error values are retained. Earlier failed checks remain local and do not count as accepted results.

Pressure, implicit update and the two enclosing spectral configurations are numerically qualified at degree21with19layers and one process using one thread. Rotation additionally passes degree1279with137layers at waves zero and1279. The larger operational spectral parent, its multithreaded route and the full saved forecast files remain unverified. These component results establish no operational runtime or whole-forecast speedup.
