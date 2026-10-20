# Parallel Tracer Mass Correction on the GPU

TRMFIXERS corrects tracer mass after air parcels move. This supplement preserves the equations, arithmetic order and supported inputs in the [complete tracer contract](tracer_mass_correction.md). It distributes independent original blocks and columns across the GPU.

The application binary interface (ABI) retains sixteen original addresses, a 64-byte common context and a 1,536-byte specific record. The host allocates 9,869,184 bytes of private scratch with 8-byte alignment. Complete bounds, descriptor identities and the original separation of writable owners are checked before output changes. The declared grid has 2,048 active points, nineteen layers and 86 blocks of 24 columns, with eight active columns in the final block. Original permitted input aliases remain supported.

A GPU block is a group of threads that can wait for each other. Each worker block uses 32 threads to share its original columns; inactive threads still join required waits. A norm here is the original weighted summary of a field. Vertical chains and each field's latitude and longitude sums keep their original order. The Arm host retains its original register, x18, floating-point state and errno rules.

| Stage | GPU blocks | Threads per block | Work |
| --- | ---: | ---: | --- |
| Prepare | 1 | 1 | Check the complete graph and prepare metadata and private effect owners. |
| Private copies | 1 | 256 | Copy every word of the complete surface and tracer buffers. |
| Surface pressure | 86 | 32 | Evaluate the two original exponentials at each active point. |
| Pressure correction | 1 | 1 | Run the unchanged complete PFIXER and its ordered norm. |
| Boundary and mass | 86 | 32 | Form pressure boundaries, vertical integrals and packed masses. |
| Mass norm | 1 | 32 | Keep each field's ordered sum, then calculate mass differences and scales. |
| Weights | 86 | 32 | Run the original interpolation, power function and integral chains. |
| Weight norm | 1 | 32 | Keep each field's ordered sum, then calculate corrections. |
| Limiter | 86 | 32 | Apply the original neighbour bounds and cell correction. |
| Commit | 1 | 32 | Check all block markers, then copy complete outputs and publish effects. |

The complete private surface buffer has 16,512 bytes, and the complete tracer buffer has 1,882,368 bytes. Each copy thread transfers distinct eight-byte words with a stride of 256 words. All threads wait before the leader marks header byte 112 as ready. Later numerical stages check this marker before reading the private fields. Complete admission, source bounds, numerical work and output commitment keep their original rules.

The stages retain complete private copies of the new surface and tracer owners, including inactive rows and the unselected tracer plane. They combine floating-point flags with integer bit operations, retain the last nonzero errno event in source order, and publish actual counter deltas with unsigned 64-bit wrap. The six effect owners keep their original identities. A private refusal discards private work and selects the unchanged serial GPU entry before any public output or effect changes.

The [ten private PTX sources](../../../../../src/openifs/transport/gpu/parallel_tracer_mass/) retain the accepted symbols. The [Arm host](../../../../../src/openifs/transport/gpu/tracer_mass_correction_calls.S) owns the fixed launch sequence. The interpolation adapter uses the [shared complete interpolation worker](../../../../../src/openifs/transport/gpu/shared_linear_interpolation_worker.ptx) once; later CALL_SL publication must reuse that source. Original serial, descriptor and scalar arithmetic providers remain once in the device closure. The NVIDIA target is sm_90, with fused arithmetic disabled. Each public source rebuilds to its accepted whole object.

Eight retained genuine calls match 15,191,040 complete output bytes and 169,671,840 read-only bytes, with zero differences. Immediate status, errno, ABI state, actual counter wrap and all 86 block markers agree. The serial fallback is unused in these calls. Five changed admission and launch controls preserve 164,881,600 whole-owner bytes. The 36 unchanged controls and accepted independent mass-conservation, pressure, integral, interpolation, extrema and ordered-norm checks are reused. No new reference or physical calculation was run for this parent gate.

The separate 256-thread copy revision passes the same eight genuine cases with the same exact outputs, status and effects. All ten launches and the new copy marker agree. Three new copy-entry controls preserve 98,928,960 whole-owner bytes, covering short scratch, an unprepared header and an incorrect thread count. The 41 unchanged controls and accepted physical evidence are reused.

These checks accept the declared component. They do not establish complete-forecast agreement or a forecast speedup.
