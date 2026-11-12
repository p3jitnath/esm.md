# Owned Operational Upper-Air Initial State

This parent owns the 9 km grid-point field context and loads all 959 upper-air records for 137 atmospheric layers. It joins the accepted [operational context](../setup/operational_grid_point_field_context.md) and [complete file loader](operational_upper_air_initial_state_loading.md). The new calculations are integer addresses and an explicit incoming padding stage. The physical fields and all floating-point values retain the accepted reader and placement rules.

## Interface and ownership

The application binary interface is ``int md2asm_create_loaded_operational_upper_air_state(path, namespace, output)``, with arguments in x0, x1 and x2. The path is readable and zero-terminated within 4,096 bytes. The namespace occupies 1,359,136 readable bytes, and output is a writable eight-byte pointer slot. Namespace and output need eight-byte alignment. Every consumed span is mapped and nonwrapping, and the complete spans are mutually disjoint.

The caller retains namespace until the returned context is released. The accepted [field-configuration producer](../setup/operational_grid_field_configuration.md) supplies the complete live field descriptions. This parent stores that borrowed address without changing the descriptions. The enclosing caller releases its namespace owner after every borrowing field context is released.

The parent uses the explicit controls 17, 137, 388217, 9, 3, 0 and 0. They create 388,217 blocks of 17 positions, with nine main fields, three physics fields and two empty companion owners. The complete 1,104-byte context and its four allocations occupy 86,799,110,834 bytes before allocator overhead. The paired release is `md2asm_release_operational_gridpoint_field_context`, which frees all five allocations once and leaves the borrowed namespace live.

## Incoming padding and ordered calls

The final block contains eight physical positions and nine unused positions, called padding. Before loading, the parent sets positive zero in exactly the copied fields' padding: zero-based block 388216, rows 8–16, layers 0–136 and slots 0–6. Using those indices, the byte offset in GFL is

```math
8igl(r+17(l+137(s+9b))igr).
```

The 959 disjoint ranges each contain 72 bytes, for 69,048 bytes in total. Their first offset is 65,099,164,672, and their layer pitch is 136 bytes. This rule defines incoming unused storage at fresh allocation. It precedes both the independent verification producer and the direct producer. Every other incoming GFL, GFLSLP and empty-owner byte is preserved by this stage. The earlier coarse-grid padding observation is separate evidence.

After argument and floating-point-mode checks, create the accepted context, apply this incoming rule, then call the unchanged complete upper-air loader with GFL capacity 65,099,332,296 bytes. The loader copies seven physical fields, clears both complete diagnostic fields and preserves the copied-field padding. Its private allocation adds 50,632,783,320 bytes, so the minimum live production storage is 137,431,894,154 bytes before public-codec temporaries, small caller records and allocator overhead. Publish the returned context pointer only after complete success. Any acquired context is released on loading failure.

Return zero means success. Return one rejects arguments or floating-point mode before mutation. A constructor error returns its code plus 16, while a loader error returns its code plus 32 after cleanup. The caller's output slot remains unchanged on failure. The 80-byte frame has 16-byte alignment and preserves x18, the required saved integer and vector registers, the floating-point control and status registers, and errno. Creation requires FPCR zero, the accepted Arm floating-point mode.

Production uses direct assembly children and their public C/ecCodes services. It has no original OpenIFS procedure, global, constructor, harness or numerical fallback. Original source and independent language controls remain separate verification references.

## Completed checks and limits

The complete new owned load matches all 65,099,332,296 GFL bytes from the retained independent operational loading control under the same incoming rule. All 4,416 checked context bytes, 65,099,332,302 unchanged companion-owner bytes and 12,232,224 borrowed namespace bytes agree. Nine ABI and status calls have zero register-failure masks. A failed file read and a failed scratch allocation establish the 69,048-byte incoming stage before placement, while constructor failure and four argument or mode refusals complete the cleanup and no-publication checks. All 544 heap-guard bytes remain intact, and every acquired allocation is released.

The complete numerical result and the remaining failure paths are bound by separate terminal records after a fixture allocation-count correction. The source and numerical body did not change, and the full loading check was reused.

Qualification used an owned exclusive node with host memory spread over four CPU memory regions. The complete check stayed within its declared memory limits. Detailed resource records remain local, with no full-forecast speedup claimed.

The unchanged original-assignment placement, codec, field meanings and independent physical checks are reused. This result does not establish complete SUGRIDUG diagnostics, every later field consumer, complete model ownership or a 9 km forecast. Detailed source, input, build, fixture-revision and terminal records remain locally under `.runtime/`.
