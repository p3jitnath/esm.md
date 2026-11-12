# Persistent Scalar Request Service

Revision 1 extends the [assembly CUDA runtime](../cuda_runtime.md) to 160 exact entry names. A persistent worker is one GPU thread that waits for successive requests, so the host does not launch a new kernel for each eligible scalar calculation. This is a transport change. It preserves each original calculation, its input and output bytes, and its numerical status.

## Interfaces and Storage

The [host runtime](../../../../../src/openifs/support/gpu/cuda_runtime.S) keeps the original Arm application binary interface (ABI), which defines arguments and register duties. Its launch entry takes a zero-terminated name in x0, the original pointer vector in x1, and a [64-byte GPU context](../gpu_call_context.md) in x2. The unsigned values in w3, w4 and w5 give the grid width, block width and dynamic shared bytes. Preserve x18, the required saved registers, the floating-point control and status registers, and the C error slot, `errno`, under the existing runtime rules.

The [worker](../../../../../src/openifs/support/gpu/whole_scalar_mailbox_worker.ptx) takes the existing mailbox address. Each selected numerical body takes exactly two unsigned 64-bit address words: the unchanged original vector and context. It returns through the original caller-owned buffers and context, with no direct return word. Keep every original owner, alignment, bound, separation rule, alias, counter and lifetime valid until completion. The service adds no model input cache and no new numerical storage requirement to those original interfaces.

The process-owned mailbox remains 64 bytes with 64-byte alignment. Its request and completed sequence words are at bytes 0 and 8, the unsigned operation and transport error words are at bytes 16 and 20, and the original vector and context addresses are at bytes 24 and 32. Bytes 40 to 63 remain reserved. A release store publishes preceding writes; an acquire load makes those writes visible to the receiver. The sequence arithmetic keeps unsigned 64-bit wrap. The single process lock, stop operation and completion rules are unchanged.

## Selection and Ordered Execution

Only one block, one thread and zero dynamic shared bytes can use this service. A hash is a short integer made from a name. The host calculates a 32-bit hash of the complete entry name, probes a fixed table, and then compares every name byte. A hash collision therefore cannot select another calculation. Unknown names and other launch shapes use the original ordinary route. Before ordinary work, the runtime stops and joins an active worker; the next eligible request can restart it. Finalization joins the worker before releasing its storage.

Operation numbers 1 to 8 keep their original bodies and meaning. The 152 added names comprise 101 existing complete callable bodies and 51 complete entry extractions. The 101 existing bodies and their selected numerical objects remain unchanged. The 51 extractions occupy 41 replacement objects: each keeps every original instruction in one new callable, then retains the ordinary entry as a two-address wrapper. Do not link an old selected object together with its replacement. All other numerical providers remain linked once.

The new functions run with the same physical scalar shape as their original ordinary entries. Entries with shared storage, collective barriers, traps, exits, clock reads or other hardware-identity dependencies are excluded. Existing parallel entries in a replacement object remain literal and use the ordinary route. The complete CALL_SL and tracer-fixer serial wrappers are excluded, as are the monthly-service entries that require 128 threads.

The worker uses a balanced integer decision tree and reloads both argument addresses immediately before each body call. It preserves original arithmetic order, rounding points, numerical flags, the last source-ordered mathematical error, output bytes and unsigned counter wrap. It adds no floating-point operation. All original buffer and numerical admission checks stay in their complete bodies.

## Published Replacements

The table lists the complete-source replacements. Original routine and entry names remain in each source. The runtime and worker above complete this 43-object transport packet. Existing numerical children, the 101 reused bodies and their original contracts remain prerequisites; this table is not a complete forecast link recipe.

| Source | Retained Ordinary Entries Wrapped |
| --- | --- |
| [vertical_spline_basis.ptx](../../../../../src/openifs/setup/gpu/vertical_spline_basis.ptx) | 1 |
| [complete_legendre_analysis_entry.ptx](../../../../../src/openifs/dynamics/gpu/complete_legendre_analysis_entry.ptx) | 1 |
| [physics_rate_closure.ptx](../../../../../src/openifs/dynamics/gpu/physics_rate_closure.ptx) | 1 |
| [convection_controller_stages.ptx](../../../../../src/openifs/convection/gpu/convection_controller_stages.ptx) | 1 |
| [forecast_control_phases.ptx](../../../../../src/openifs/setup/gpu/forecast_control_phases.ptx) | 3 |
| [pressure_force.ptx](../../../../../src/openifs/dynamics/gpu/pressure_force.ptx) | 1 |
| [thermal_pressure.ptx](../../../../../src/openifs/dynamics/gpu/thermal_pressure.ptx) | 1 |
| [hybrid_coordinate_setup.ptx](../../../../../src/openifs/setup/gpu/hybrid_coordinate_setup.ptx) | 1 |
| [wave_and_restart_setup_phases.ptx](../../../../../src/openifs/setup/gpu/wave_and_restart_setup_phases.ptx) | 2 |
| [orographic_parameter_field.ptx](../../../../../src/openifs/setup/gpu/orographic_parameter_field.ptx) | 1 |
| [standard_pressure_output_serial_entry.ptx](../../../../../src/openifs/fullpos/gpu/standard_pressure_output_serial_entry.ptx) | 1 |
| [output_boundary_phase.ptx](../../../../../src/openifs/fullpos/gpu/output_boundary_phase.ptx) | 1 |
| [output_metadata_phase.ptx](../../../../../src/openifs/fullpos/gpu/output_metadata_phase.ptx) | 1 |
| [output_norm_phase.ptx](../../../../../src/openifs/fullpos/gpu/output_norm_phase.ptx) | 1 |
| [spectral_fit_phase.ptx](../../../../../src/openifs/fullpos/gpu/spectral_fit_phase.ptx) | 1 |
| [transform_state_phase.ptx](../../../../../src/openifs/dynamics/gpu/transform_state_phase.ptx) | 1 |
| [real_fourier_transform_entries.ptx](../../../../../src/openifs/dynamics/gpu/real_fourier_transform_entries.ptx) | 3 |
| [carbon_assimilation_parameter_phase.ptx](../../../../../src/openifs/surface/gpu/carbon_assimilation_parameter_phase.ptx) | 1 |
| [carbon_assimilation_cell_phase.ptx](../../../../../src/openifs/surface/gpu/carbon_assimilation_cell_phase.ptx) | 1 |
| [soil_parameter_phase.ptx](../../../../../src/openifs/surface/gpu/soil_parameter_phase.ptx) | 1 |
| [soil_texture_average_phase.ptx](../../../../../src/openifs/surface/gpu/soil_texture_average_phase.ptx) | 1 |
| [surface_exchange_parameter_phase.ptx](../../../../../src/openifs/surface/gpu/surface_exchange_parameter_phase.ptx) | 1 |
| [surface_radiation_parameter_phase.ptx](../../../../../src/openifs/surface/gpu/surface_radiation_parameter_phase.ptx) | 1 |
| [urban_surface_parameter_phase.ptx](../../../../../src/openifs/surface/gpu/urban_surface_parameter_phase.ptx) | 1 |
| [vegetation_parameter_phase.ptx](../../../../../src/openifs/surface/gpu/vegetation_parameter_phase.ptx) | 1 |
| [vegetation_root_fraction_phase.ptx](../../../../../src/openifs/surface/gpu/vegetation_root_fraction_phase.ptx) | 1 |
| [pressure_field_entries.ptx](../../../../../src/openifs/fullpos/gpu/pressure_field_entries.ptx) | 2 |
| [pressure_temperature_stage_entry.ptx](../../../../../src/openifs/fullpos/gpu/pressure_temperature_stage_entry.ptx) | 1 |
| [spectral_wind_transform_entries.ptx](../../../../../src/openifs/dynamics/gpu/spectral_wind_transform_entries.ptx) | 2 |
| [spline_inverse_from_factors_phase.ptx](../../../../../src/openifs/setup/gpu/spline_inverse_from_factors_phase.ptx) | 1 |
| [spline_lu_factorization_phase.ptx](../../../../../src/openifs/setup/gpu/spline_lu_factorization_phase.ptx) | 1 |
| [spline_upper_triangular_inverse_entry.ptx](../../../../../src/openifs/setup/gpu/spline_upper_triangular_inverse_entry.ptx) | 1 |
| [state_updates.ptx](../../../../../src/openifs/physics/gpu/state_updates.ptx) | 2 |
| [field_transfer.ptx](../../../../../src/openifs/physics/gpu/field_transfer.ptx) | 1 |
| [vertical_coordinate_setup_phase.ptx](../../../../../src/openifs/setup/gpu/vertical_coordinate_setup_phase.ptx) | 1 |
| [wind_tendency.ptx](../../../../../src/openifs/dynamics/gpu/wind_tendency.ptx) | 1 |
| [interpolation_parallel_block_stages.ptx](../../../../../src/openifs/transport/gpu/interpolation_parallel_block_stages.ptx) | 1 |
| [prognostic_parallel_block_stages.ptx](../../../../../src/openifs/transport/gpu/prognostic_parallel_block_stages.ptx) | 1 |
| [vertical_pressure_integral.ptx](../../../../../src/openifs/dynamics/gpu/vertical_pressure_integral.ptx) | 1 |
| [interpolation_boundary_values.ptx](../../../../../src/openifs/dynamics/gpu/interpolation_boundary_values.ptx) | 1 |
| [vertical_parent_entries.ptx](../../../../../src/openifs/dynamics/gpu/vertical_parent_entries.ptx) | 3 |

## Acceptance and Limits

The changed transport passes 38 setup requests, 14 cached scalar-family requests and 19 admission controls within those requests. The verifier compares 3,108,704 complete owner bytes with zero differences, including guards, inactive storage, immediate status, saved registers, x18, `errno`, and all six actual counter owners near unsigned wrap. It uses five saved ordinary-GPU expectations without repeating those reference calls. The seven unchanged scalar families are interleaved twice to check ordinary joins, worker restart and refusal behavior. The owned process returned normally in 1.37 seconds under an explicit 14.13-second limit, and its process group was removed.

A separate native Arm probe passes 325 name-selection checks, including all 160 operation names, missing and suffixed names, and two distinct names with the same complete 32-bit hash. An independent source and native-code peer checks all complete-source inverses, all 101 reused argument chains, the original eight bindings, the balanced worker tree and 160 fresh native argument pairs. All 43 public objects rebuild byte-for-byte identically to their qualified local objects with `ptxas -arch=sm_90 --fmad=false -c` or the recorded Arm assembler command.

These checks qualify the changed shared transport. They reuse the accepted arithmetic, mathematical and independent physical evidence for unchanged bodies; they are not 152 new physical checks. Complete-forecast output agreement and comparative performance remain separate acceptance requirements. Detailed source pins, commands, results and process records stay in the ignored local runtime directory.
