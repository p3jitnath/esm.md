# Convective Energy Diagnostics on the GPU

The [CPU contract](../../../../md2asm/references/openifs/physics/convective_energy_diagnostics.md) fixes the parcel calculation in CUANCAPE2. Convective energy and inhibition are in joules per kilogram. The application binary interface (ABI) retains 13 original address arguments, both public aliases, the 4,096-byte frame, complete owners and original alignment and register rules. All 151 floating-point sites, including 55 in trailing private helpers, use qualified GPU calculations or exact word copies. Six POWER, three EXP and one LOG call keep their original operand words, order and rounding.

Each temporary 128-byte call area preserves live source values, integer condition flags and the return address. The complete 12-address adjustment child remains in source order with its absent optional null argument. Parent and child share the actual exponential and power counters. Positive finite logarithms retain their uncounted interface. Finite inputs, positive increasing pressures, complete disjoint owners and a serial host caller remain inherited conditions. Fourteen structural guards check the native interface before output writes. The complete host contains no weather floating-point calculation.

Eighteen GPU and eighteen selected CPU calls match 27,648 mutable output bytes and 302,400 complete owner bytes. Eight original Fortran calls supply primary references. The unchanged 1,584 independent parcel-energy and pressure relations are reused after exact agreement. All 888 retained original POWER words match. Independent 120- and 240-digit checks cover 2,229 actual mathematical argument-result pairs within their declared one-ULP sample limit. An ULP is the spacing between adjacent FP64 values. The largest EXP error is about 0.504 ULP. Both source reviews and complete provider checks pass. Complete forecast and performance acceptance remain separate.

## Ordered Parcel Ascent

A parcel is a small volume of air that the calculation follows through the atmospheric layers. The selected parent retains its 13 original address arguments, 4,096-byte caller frame and source-visible temporary writes. The first four complete phases retain their accepted providers. Each of the three ordered parcels then uses one collective GPU launch for initialisation, descending pre-adjustment, complete CUADJTQ saturation adjustment, post-adjustment and final output. The original FP64 operations, their rounding points and the order within each column stay fixed.

The entry `md2asm_gpu_convective_recomputed_parcel` takes two 64-bit addresses: a 16-byte address vector and a 64-byte revision-1 context, each aligned to 8 bytes. The vector names a complete 1,024-byte header and a 32-byte output record. The context retains a pointer to a separate 256-byte record. Header bytes 512–575 and 576–639 hold the two child contexts, while bytes 640–655 and 656–751 hold their address vectors. All new complete buffers are checked against the consumed model, coefficient, counter, context and caller-frame owners before numerical writes. The original parent bounds remain 1–4,096 columns and 4–512 layers, with the original active-column interval and lower ascent limit. An empty ascent still runs initialisation and output without consuming unused child pointers.

One GPU block contains 128 threads, with no dynamic shared memory. Every thread reaches each stage barrier, and the next stage begins only after the complete preceding stage returns. A refusal of the added storage conditions selects the original host sequence before any numerical write. An original numerical failure retains its completed writes, flags, error and actual helper counts, then reaches the existing fatal boundary. It does not restart a partially completed parcel. The original parent-cached controls and each child's live scalar loads retain their original boundaries.

The shared EXP, FAST and WIDE counters retain their actual storage and unsigned 64-bit wrap: adding one after the largest value returns zero. A synchronous host-dispatch count records only a real host launch. A device call does not create a synthetic host entry.

Five complete retained parent calls matched 84,000 owner bytes, including unchanged inputs, inactive values, immediate ABI state and actual numerical counters. Five focused storage, empty-ascent and fatal-prefix controls matched 278,996 guarded bytes. All comparisons had zero differing bytes. The twelve existing canonical files and 1,584 independent parcel-energy and pressure relations were reused, with no new CPU, Fortran or physics-reference call. Matched complete-call timing selected this component separately. Complete forecast acceptance remains a separate requirement.

The five new assembly sources provide the selected parcel entry, its private collective children, the launch adapter and the selected parent. They retain the original entry symbols. The selected parent is a separate provider from the earlier public storage shell, so a link must select one complete parent. The earlier coarse phase adapters and their ordinary fallback kernels remain qualified private dependencies in the local provider map. The unchanged CUADJTQ numerical values are also defined in the public saturation-adjustment source.

- [parcel_ascent_phase.ptx](../../../../../src/openifs/physics/gpu/parcel_ascent_phase.ptx) supplies `recomputed_phase_private.ptx` from the accepted local packet.

- [parcel_saturation_adjustment.ptx](../../../../../src/openifs/physics/gpu/parcel_saturation_adjustment.ptx) supplies `saturation_adjustment_private.ptx` from the accepted local packet.

- [ordered_parcel_ascent.ptx](../../../../../src/openifs/physics/gpu/ordered_parcel_ascent.ptx) supplies `convective_parcel_fusion.ptx` from the accepted local packet.

- [ordered_parcel_ascent_calls.S](../../../../../src/openifs/physics/gpu/ordered_parcel_ascent_calls.S) supplies `convective_parcel_fusion_calls.S` from the accepted local packet.

- [convective_parcel_energy_parent.S](../../../../../src/openifs/physics/gpu/convective_parcel_energy_parent.S) supplies `convective_energy_storage_shell.S` from the accepted local packet.
