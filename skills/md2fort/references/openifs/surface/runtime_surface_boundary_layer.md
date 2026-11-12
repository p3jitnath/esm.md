# Runtime surface boundary layer

The selected entry implements the original `SURFBC_LAYER` call. It reads surface fields, classifies each selected column, and divides its area among water, ice, vegetation, snow, bare soil and lake tiles. It then runs the original SURFBC checks on tile signs, total area and bare soil cover. The numerical child and these checks keep their accepted FP64 instruction order.

## Entry and source order

[`runtime_surface_boundary_layer.S`](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/surface/runtime_surface_boundary_layer.S) selects the complete seven-address layer and 42-address SURFBC adapter from [`selected_surface_layer_adapters.S`](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/surface/selected_surface_layer_adapters.S). It exports `md2asm_surface_boundary_layer_layout_r2_7358525`. The default build still includes every original layer and reproduces the complete previously accepted object. The selected build leaves out unrelated snow, surface-wind and turbulence entries.

The seven arguments are pointers in `x0` through `x6`, in this order. An application binary interface (ABI) specifies these addresses and the registers that a call must preserve.

| Argument | Typed input | Complete record size, bytes |
|---|---|---:|
| 1 | `YDSURF`, the surface-field metadata | 18,224 |
| 2 | `YDEPHY`, the physics control record inside the actual MODEL | 448 |
| 3 | `KDIM`, the dimensions and selected interval | 192 |
| 4 | `PAUX`, the auxiliary fields | 1,992 |
| 5 | `LLKEYS`, the output surface flags | 664 |
| 6 | `PSURF`, the input and output surface fields | 13,680 |
| 7 | `SURFL`, the local surface fields | 2,096 |

The layer makes the same 42-address call as the original source. Its field sections use 12 separate field-index owners from `YDSURF%YSD_VF` and one from `YDSURF%YSP_SL`. The complete map is in [`selected_surfbc_layer_argument_addresses.inc.S`](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/surface/selected_surfbc_layer_argument_addresses.inc.S). SURFBC obtains the actual surface parameter object through GET_SURF, appends its soil, vegetation, lake and ocean records, and calls the unchanged 45-address [tile calculation](surfbc_ctl.md). Its parameter record offsets are 7,680, 10,336, 4,104 and 5,640 bytes, respectively.

The selected layer uses a 16,384-byte stack frame; its nested adapter uses another 16,384 bytes. Both preserve `x18`, `x19` through `x30`, and the required low halves of `v8` through `v15`. The stack pointer stays aligned to 16 bytes. These entries have the original void return interface. Floating-point control register FPCR must be zero, which selects the accepted rounding and underflow rules. The layer does not reset floating-point status FPSR or the C error value `errno`.

## Live bounds and storage

Let $`P`$ be the live column count. The selected interval must satisfy $`1\leq\mathrm{first}\leq\mathrm{last}\leq P`$, with $`1\leq P\leq4096`$. The selected provider supports 8 through 16 tiles, with at least 9 when the lake option is active. The snow descriptor has 1 through 64 layers. These are intersections with the accepted child bounds; the parent does not extend a child through a wider admission check. This surface calculation does not use an atmospheric level loop. The ownership gate uses the actual 137-level vertical Geometry.

The checked route uses complete, dense GNU Fortran descriptors with lower bounds 1 and live extents. The first dimension holds $`P`$ rows; the second dimension holds the live field count, snow layers or tile count. A descriptor records the base address, element size, strides and bounds. Each selected field index must be within its actual second dimension. The 25 complete backing arrays comprise 9 input owners and 16 output owners. All full output owners, including columns outside the selected interval, are compared.

Callers must provide complete live mapped record, descriptor, scalar and array spans, with no address wrap. Records and FP64 arrays must be aligned to 8 bytes; logical and integer arrays and each of the 13 field-index scalars must be aligned to 4 bytes. Each field-index scalar is a separate live mapped four-byte owner. All mutable arrays must be mutually disjoint and disjoint from input arrays, all records and index scalars, the complete MODEL, the complete surface parameter object and every parameter table. The unchanged raw layer checks dimensions and source bounds, but does not prove all these pointer capacities or alias relations. These remain explicit caller prerequisites.

Tile fractions and covers are dimensionless; snow and canopy water are stored as kilograms per square metre, and snow density is in kilograms per cubic metre. The tile child retains all its [physical input limits](surfbc_ctl.md), including finite category values, covers, positive canopy capacity and snow density, and its existing treatment of finite signed stored canopy water and lake ice thickness. A caller must supply values within those limits. This checkpoint does not change their arithmetic, clipping rules or scientific limits.

The adapter allocates $`16P`$ bytes for two complete FP64 column work arrays, fills both with positive zero, accumulates tiles in original order, and frees the allocation before returning. The original fatal behaviour for unsupported dimensions, failed storage or failed physical checks remains outside the accepted call domain. An empty interval is outside this selected adapter's domain.

## Actual owners and association

The accepted vertical startup and vertical-system constructors create and retain the 20,400-byte Geometry. The actual MODEL allocator then creates the 4,275,088-byte MODEL and writes its address to the existing owned MODEL slot. MODEL borrows Geometry, so Geometry must remain alive through every MODEL consumer and must be released after MODEL. This checkpoint uses the vertical Geometry fields needed by this allocator and surface call; it does not claim a complete horizontal Geometry or loaded weather state.

The unchanged complete surface constructor, SUSURF, receives explicit accepted raw controls and actual radiation and optimisation inputs. It creates the 11,584-byte surface parameter object and its 79 numerical table owners. The selected controls use nine tiles and five snow layers. No numerical parameter value is computed by the checking driver, and no original registry or original global supplies a production value.

[`model_surface_parameter_association.S`](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/setup/model_surface_parameter_association.S) performs only the source-ordered pointer association. `md2asm_attach_selected_model_surface(MODEL, capacity, result16)` requires the actual allocated MODEL, capacity of at least 4,275,088 bytes, a live 16-byte constructor result, and its actual 11,584-byte surface owner. It stores the surface owner address from result16[0] at MODEL byte offset 1,578,328, which is `YDEPHY%YSURF`; `YDEPHY` starts at MODEL offset 1,577,888. The matching detach entry clears only that exact association. Both return 0 on success and 2 on refusal, preserve ABI and status, and make no numerical calculation or allocation.

The association entry checks alignment, complete nonwrapping MODEL/result/surface spans, their separation, the actual owned MODEL address, and the old handle value before writing. The result must come from the live accepted constructor; the raw interface cannot establish its allocation history from a pointer alone. An accepted caller keeps the result and all table owners alive until detach and surface release. It then releases MODEL before Geometry.

The selected link owns a read-only four-byte false profiling policy in [`surface_boundary_hook_policy.S`](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/surface/surface_boundary_hook_policy.S). GET_SURF is the actual assembly metadata service in [`surface_parameter_lookup.S`](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/support/surface_parameter_lookup.S). The checked native closure contains accepted assembly bodies and public support libraries, with no original OpenIFS numerical routine. The isolated check defines only the same eight-byte MODEL slot that the production bootstrap owns; the actual allocator writes this slot. That checking storage is not a second production model or registry.

## Acceptance and remaining scope

Twelve genuine original calls and twelve native calls cover $`P=1,8,17,4096`$, full and partial nonempty intervals, and placement against both protected buffer boundaries. Each route satisfies 207,000 independent area, snow, canopy and classification relations. The total 1,294,104 complete output and status bytes agree exactly. Each route also preserves 54,173,536 input and parameter bytes, including all surface tables and the complete actual MODEL and Geometry. The 2,184 output bytes outside selected intervals remain unchanged.

The independent relations reuse the accepted tile check's extended-precision area and canopy equations and its unchanged tolerance of 2,048 FP64 machine epsilons times the stated magnitude scale plus 2,048 smallest subnormal values. The checker does not reproduce the assembly instruction sequence. All native ABI masks are zero. All original source masks are 2 because the original code uses `x18` as scratch; this known reference limitation is disclosed separately from the exact numerical and status comparisons.

A transparent source observer records all 42 actual child-boundary associations before forwarding to the original numerical SURFBC; the gate checks those captured addresses and descriptors against the typed input owners. The original SURFBC library's GET_SURF lookup slot is independently shown to reach the actual owned assembly getter. The native getter slot and both actual local numerical branch targets are also checked. Sixteen new association refusal cases preserve complete owners, ABI, FPCR, FPSR and `errno`; successful detach and reattach preserve status and restore the exact handle.

The full default adapter object, the accepted private tile object, and the actual MODEL allocator object retain complete object identity. The selected tile's default and private aliases also retain every instruction and data byte. Existing parameter-constructor and tile numerical evidence is reused without replay. The main Fortran executable is unchanged. This is a checked component provider; complete CALLPAR forwarding, complete surface setup in a loaded weather state, and a complete autonomous forecast remain separate gates.
