# Physics Field Block Views

This component selects a block of an existing FP64 field without changing any numerical value. A view is an address and a record of dimensions and spacing. The original FIELD_MODULE source remains the separate control.

The direct entries md2asm_physics_field_view_3d and md2asm_physics_field_view_4d receive the output GNU Fortran descriptor in x0, a raw FIELD record in x1 and a one-based block index in w2. The output descriptors occupy 88 and 112 bytes. The field records occupy 328 and 400 bytes. Both records require eight-byte alignment and must be disjoint. Source fields and their numerical allocations remain live during use.

ACTIVE selects storage or the existing fallback VIEW. An active OWNED field selects DATA, while an active unowned field selects PTR. THREAD_BUFFER selects block one for the frozen one-thread forecast. Other active fields select the supplied block. The chosen block must lie inside the selected storage descriptor. The result removes the last storage dimension and retains each remaining element stride, with section bounds rebased to one. An inactive field copies its existing VIEW descriptor unchanged. No BLOCK_SIZE or ZERO option is supported by these entries, because the selected physics storage callers omit both options.

The direct leaf preserves x18, every saved general register and all vector registers. It makes no library call, uses no stack, changes no floating-point state and does not change errno. The caller supplies valid FP64 descriptor headers, mapped bounds and strides whose address calculations fit signed 64-bit arithmetic. Numerical storage, input records and output guards must remain unchanged.

Acceptance requires complete output descriptor agreement with the original typed GET_VIEW for owned, wrapped, inactive, thread-local, noncontiguous and final-block cases. The small verifier also checks unchanged complete numerical owners, input field records, bounds, FPCR, FPSR, errno and the Arm ABI. This component alone does not replace complete physics startup or establish an autonomous forecast.

The state block-binding forecast records 17,200 direct calls and preserves all complete final-owner and saved-file bytes. Its [parent contract](physics_state_block_binding.md) defines the selected context and masks.
