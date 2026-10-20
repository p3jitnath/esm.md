# Parallel Surface Radiation Columns

This component runs independent surface columns on different GPU blocks. A column represents the land, lake or ocean surface beneath one atmospheric grid point. It retains the [surface radiation physics](../../../../../formulations/openifs/surface/surface_radiation_inputs.md), the [original private controller interface](private_radiation_controller.md) and every ordered 64-bit floating-point operation. Soil, canopy, lake, radiation-controller and tile-boundary calculations use their qualified assembly children.

The application binary interface (ABI) defines the values passed between assembly routines. Each GPU entry takes two 64-bit addresses, original_vector and common_context, aligned to eight bytes. The vector has six words containing the 832-byte state address, 160-byte environment address, 32-byte result address, private-storage address, private-storage size and an internal control word. The context is 64 bytes and points to the original 96-byte capacity record. The source image has 51,200 bytes, with the original stack pointer 14,336 bytes after its start and aligned to 16 bytes. The required floating-point control word is zero.

The Arm dispatcher retains the launch service interface. Registers x0, x1 and x2 hold the original kernel name, vector address and context address. Registers w3, w4 and w5 hold the grid width, block width and shared-memory size. Register w0 returns the launch status. The boundary uses a 16-byte aligned stack, saves the complete integer and vector registers, and preserves numerical flags, integer conditions and the error indicator around allocation and release. The original serial launch remains available.

The parallel route requires mode two, one through 32 active columns and separate writable column outputs. Each output row has an eight-byte stride. A two-dimensional output has a band pitch of at least eight times the declared column capacity. Admission checks complete bounds, address wrap, alignment and separation of model data, state, source, environment, protocol records and counter storage. Valid inputs outside this narrower parallel domain use the unchanged serial GPU route.

Private storage needs 19,546,112 bytes. Each worker has a separate state, source image, output mapping and four counter totals. Logical pointers keep their original bits. Only effective memory addresses select private storage, so copied source and register values retain their original pointer identities.

| Ordered launch | Blocks | Threads per block | Purpose |
| --- | ---: | ---: | --- |
| Prepare | 1 | 1 | Admit owners and copy exact before-images |
| Workers | 32 | 1 | Run one original column per active block |
| Join | 1 | 1 | Check completion and publish original-order effects |

Every active worker publishes a completion marker after its final writes. The join checks all markers and error words before changing original source, state, fields or counters. Missing completion or a rejected private calculation selects the unchanged serial route from the preserved original state. Each accepted column executes its numerical calculation once. This route uses no result cache or ordered numerical replay.

The final original column supplies the complete returned state and source frame. A source proof identifies which bytes every column writes. The join then repairs only the fields that carry information between columns. Numerical status flags use bitwise OR. The saved and final error indicators use the last actual error event in original column and call order, including a repeated write of the same error code. The lake helper tail uses the last column that called the exponential helper. Four actual counter totals retain their original owner addresses, admitted exact aliases and unsigned 64-bit wrap rule. No output bit or pointer is masked or normalised.

Acceptance covers four complete parallel state/source comparisons, one naturally selected stride-24 serial case and two forced serial cases. Seven retained complete-parent records contain 942,536 output bytes with zero differences. Full state/source comparisons, actual near-wrap counters, flags, the error indicator, register obligations, seeded upper vector halves, five sparse-join controls and four whole-owner prewrite controls pass. The completed prefix of an earlier interrupted fixture is reused explicitly. Independent physical and mathematical checks for unchanged numerical children remain applicable. This component record does not establish complete-forecast acceptance or runtime.

The new sources are the [ordered GPU stages](../../../../../src/openifs/surface/gpu/surface_radiation_parallel_columns.ptx), [typed child requests](../../../../../src/openifs/surface/gpu/surface_radiation_column_requests.ptx) and [Arm launch boundary](../../../../../src/openifs/surface/gpu/surface_radiation_parallel_calls.S). They rebuild to the exact accepted whole-object bytes. Their required private numerical providers remain separate. The following symbols identify the required column composition and raw child bindings.

| Required provider role | Exact symbol |
| --- | --- |
| Ordered column body | bulk_state_md2asm_r23_surface_radiation_wrapper_controller_complete_source_values_surface_columns |
| Soil water | md2asm_gpu_mailbox_soil_water_body_surface_columns |
| Canopy light | md2asm_gpu_mailbox_canopy_light_body_surface_columns |
| Lake energy | md2asm_gpu_mailbox_lake_energy_body_surface_columns |
| Radiation controller | md2asm_gpu_r23_radiation_controller_body_surface_columns |
| Tile boundary | md2asm_gpu_r23_tile_boundary_body_surface_columns |

The accepted local integration record retains the seven private child and state-adapter objects, the original serial providers and the single changed host storage shell. These large private composition sources are not duplicated in this supplement. The three new files are a component extension rather than a standalone linkable forecast. Local records retain complete provider commands, source provenance, raw comparisons and timing variation. Complete-image integration and forecast acceptance remain separate.
