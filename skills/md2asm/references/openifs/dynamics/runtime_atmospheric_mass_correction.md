# Runtime Atmospheric Mass Correction

The [assembly](../../../../../src/openifs/dynamics/runtime_atmospheric_mass_correction.S) implements the selected CORMASSDRY route from `arpifs/climate/cormassdry.F90`. It converts surface log pressure to grid-point pressure, applies the source map scaling and obtains a global weighted mean. It then updates the reference mean and logarithmic correction used by the model. Pressure is in pascals and the logarithmic ratio has no units.

## Interface And Calculation

`md2asm_runtime_cormassdry` keeps seven original address arguments in x0 through x6, then adds context (32 bytes) in x7. They are Geometry (20,400 bytes), YGFL, TDYN, spectral fields (2,992 bytes), the original PGP descriptor, int32 step and int32 LDGPMASCOR. YGFL and TDYN are members of the same complete Model at bytes 192 and 1564592. PGP retains its pointer presence but no element is consumed on this selected route. Context words are partition (4,096 bytes), grid-norm dependency (32 bytes), workspace byte limit and reserved zero. The dependency is the same record used by [grid-field norms](runtime_grid_field_norms.md). All records are mapped and aligned to eight bytes, with four-byte alignment for scalar integers.

The source LMASDRY and LDGPMASCOR controls are false. The public inverse transform retains SPEREE's exact argument order, actual resolution and vertical process count. Only the last vertical process set holds the surface-pressure spectral field. Its empty sections retain the parent array's physical strides and offset. All other optional transform arguments are absent.

On a process that owns no spectral pressure values, the producer supplies a one-element dummy spectral-pressure buffer, SP, with physical upper bound 1. Admission checks that buffer, while the inverse-transform descriptor keeps its first upper bound 0. The dummy bytes remain unchanged. Processes that own the field retain all active-span checks.

For each physical block, compute EXP of every log-pressure value before dividing each pressure by its map factor squared, using one FP64 multiplication and division. Geometry byte 9240 describes the contiguous local map factors. The accepted grid-point norm then gives GMASS0. At step zero, a zero GMASSI becomes GMASS0. GMASSINC is LOG of the rounded GMASS0/GMASSI ratio. TDYN offsets 4600, 4608 and 4616 hold these three scalars. Water-column integration and grid pressure rewriting are outside this selected route.

Live bounds are spectral degree from 1 through 8191, layers from 1 through 512, P from 1 through 4096, positive signed-int32 local count Q and B equal to ceil(Q/P). The actual MPI world, factor coordinates, phase-seven partition, spectral-pressure metadata and public transform owner must agree. One allocation of$`8(Q+PB)`$ bytes must fit the positive caller limit, at most 64 GiB. Final-block padding is untouched. Inputs and staged outputs are disjoint.

The 1536-byte aligned frame preserves x18 and all Arm callee-saved registers. FPCR is zero and natural floating status and library errno remain visible. Common admission, allocation agreement, full calculation, release and final agreement precede the three scalar stores. Return zero means success, one allocation refusal, two rejected inputs or children and three MPI failure. Controlled refusal preserves TDYN.

## Evidence

The [joint component evidence](runtime_grid_field_norms.md#evidence) includes initial reference assignment and a later logarithmic ratio on a genuine four-process transform, exact complete states, independent constant-pressure checks, guards and release. This accepts the selected component. Operational input, enclosing CNT4 and the complete saved forecast still need their joined checks.

The physical dummy-storage correction passes a focused four-process check at block widths 5 and 24. Across 44 calls, the comparison finds zero differences in 222,413,472 data bytes. Because processes use different memory addresses, a further 608 checks compare buffer owners and address offsets. All 96 independent mass checks and the interface check pass. The check covers initial and later mass correction, unchanged dummy bytes, malformed active and dummy spans, short workspace refusal and shared status. The original and assembly process groups close independently. This is component acceptance, with complete operational forecast acceptance still open.
