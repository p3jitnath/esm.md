# Model Transform Callers

The original TRANSINV_MDL, TRANSDIR_MDL, TRANSINVH and TRANSDIRH callers move the weather state between spectral coefficients and grid values. A spectral coefficient is the weight of one spatial wave. Their original sources are the same-named files in arpifs/transform/. The unchanged assembly children perform the complete transforms; the accepted [spectral formulation](../../../../../formulations/openifs/dynamics/inverse_spectral_transform.md) defines the represented waves.

The selected forecast has 2048 horizontal points, 19 levels and 24 rows per block. Its 86th block has eight active rows, and surface pressure has 506 spectral words. The inverse caller copies the pressure coefficients, sets four gradient planes to positive zero at step zero, and reconstructs the two current planes at positive steps. The direct caller analyses the gradient planes before the main state and stores the resulting pressure coefficients. The source order and all child arithmetic stay frozen.

The application binary interface, or ABI, passes the first eight values in x0 through x7 and the rest on the stack. Each address has eight bytes, and each hidden character length is an eight-byte integer. The original counts and frame sizes are:

| Original routine | Ordinary addresses | Hidden lengths | Frame bytes |
| --- | ---: | ---: | ---: |
| TRANSINV_MDL | 38 | 0 | 2304 |
| TRANSDIR_MDL | 7 | 1 | 2048 |
| TRANSINVH | 12 | 9 | 1152 |
| TRANSDIRH | 7 | 1 | 384 |

The assembly retains all four private entry names, source address order and hidden lengths. It preserves x18, x19 through x29 and the return address, with a stack aligned to 16 bytes. It does not use preserved floating-point registers. An array descriptor is a record containing its data address, shape and strides. GNU array descriptors retain their complete bounds, signed offsets, column-first strides and inactive bytes. Present owners must cover every consumed plane; source-inactive optional addresses remain null or retain their declared descriptor without reading its data.

The inverse pressure descriptor goes to INV_TRANS argument 18, KVSETSC2, instead of argument 14, KVSETSC. The direct pressure descriptor goes to DIR_TRANS argument 13, KVSETSC2, instead of argument 9, KVSETSC. These argument numbers start at zero. The two corrected integer stores are 880 to 912 and 456 to 488 in their respective outgoing argument tables. Their descriptors, backing buffers and numerical children are unchanged. The retained focused object proofs preserve constants, child relocations and the ordered instruction stream apart from these stores.

The qualified route keeps the selected scalar and tracer counts, absent transform callbacks and the original source control guards. FPCR, the floating-point control register, must be zero. Complete numerical children retain separate FP64 rounding, signed zeros and gradual underflow. Source profiling, progress records, module selectors, allocation and the retained external-transform interface remain explicit dependencies. These callers are not a standalone transform or an autonomous forecast.

The private current R3 source retains the accepted inverse binding and adds the direct binding correction. Its focused source and object receipts are reused; this publication copy changes only comments. The retained enclosing-owner checks and joint final-state, immediate-status, ABI, positive-call and ten-file gate pass for these selected bindings. No new physical test, model run or timing result is claimed.
