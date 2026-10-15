# Physics State Block Binding

This component replaces `md2asm_physics_storage_state_view`, which selects a physics state and views of one grid block. A view records an address, dimensions and element spacing. Numerical cloud-plane copies remain in the accepted direct physics caller.

The original C interface returns a state address from `md2asm_physics_storage_state_view(context, which, block, copy_mask)`. Register x0 carries the context, w1 and w2 carry signed 32-bit state and block indices, and x3 points at the four-byte result mask. The context spans 119,384 bytes with eight-byte alignment. Its eight 1,240-byte states start at byte 72,736. Supported indices are states 1 through 8 and blocks 1 through 86. The mask has four-byte alignment and is disjoint from the context and field storage.

Clear the mask, then select U, V, T, O3, Q, A, TKE, CLD, QL, QI, QR and QS in that source order. Each associated field supplies a complete descriptor through the [direct field-view leaves](physics_field_block_views.md). Null fields leave their old views unchanged. Associated QL, QI, QR and QS fields whose state mask is true set result bits zero through three. Return the complete state address in x0. No numerical array value is read or written.

Field-pointer and public-view declaration orders differ. Their named offsets are queried separately through the original GNU 12 types, with TKE before the cloud views in the public-view list. The [state storage contract](physics_state_storage.md) defines record ownership. Thread-buffer and inactive-view rules remain those of the direct leaves.

The entry uses a 96-byte aligned frame and calls only direct metadata children. It preserves x18, saved integer registers, vector state, floating-point controls and flags, and the library error value. The selected caller omits BLOCK_SIZE and ZERO, so no padding fill or numerical initialization is added. Unsupported top-level arguments terminate without an original Fortran fallback.

Four complete 119,384-byte contexts match the separate original service body, including returned addresses, masks and unchanged numerical owners. Ten seeded calling-interface checks pass. The complete forecast records 17,200 direct calls, with all 685 final owners and ten saved files exact. Other temporary physics services remain unfinished.
