# Cloud Overlap Profile Setup

This component allocates the cloud-overlap profile and then evaluates the complete original `SUOVLP` calculation. Cloud overlap describes how cloudy layers align above each other. The earlier `SUALLO` stage owns allocation. The later radiation setup supplies the live standard-atmosphere heights and existing coefficients, without changing the physics.

For level $`k`$, height $`z_k`$ is in metres, coefficient $`a`$ is in inverse metres and coefficient $`b`$ has no unit. The profile value $`r_k`$ has no unit.

```math
r_k = a z_k + b.
```

Each level uses one rounded FP64 multiplication followed by one rounded addition. FP64 stores a real number in 64 bits. Levels run in increasing order. There is no fused operation. The floating-point control register must be zero, which selects the accepted rounding and underflow settings. The routine preserves the natural floating-point status flags and library error indicator.

The application binary interface, or ABI, defines the arguments and registers used by a call. `md2asm_create_cloud_overlap_storage(record, capacity, levels)` takes an aligned 64-byte record in `x0`, its byte capacity in `x1` and a 32-bit level count in `w2`. Supported counts are 1 through 256. The record's data address must initially be null. The accepted radiation-array allocator creates one contiguous FP64 owner with one-based bounds, leaving its payload untouched. The new descriptor becomes public only after allocation succeeds. Return zero means success, one means allocation failure and two means rejected input. Failure leaves the complete record unchanged.

`md2asm_initialize_cloud_overlap_profile(atmosphere, overlap, radiation, levels)` takes the complete 384-byte atmosphere record in `x0`, 64-byte overlap record in `x1`, 2,040-byte radiation record in `x2` and level count in `w3`. The height descriptor starts at byte 320. The two coefficients start at bytes 536 and 544. Both descriptors must describe contiguous one-based FP64 arrays of the declared length. All records and payloads must be mapped, eight-byte aligned, nonwrapping and disjoint. The entry checks their descriptors, ranges and finite inputs before any output write. Finite inputs must also keep the two operations within the supported finite range. Success returns zero. Rejection returns two without mutation. The caller retains all height and radiation bytes.

The selected source does not assign these coefficients during `SUECRAD`. They remain explicit live inputs from the incoming radiation record. The current owned record starts with zero bytes, so both coefficients are zero for that selected input. This is a storage policy, rather than a new physical default. The source still calculates the profile when the later overlap selector does not consume it.

`md2asm_release_cloud_overlap_storage(record, capacity)` frees this owner and clears only its data address. It accepts an already released record. Release occurs before its enclosing record is destroyed. All entries preserve the required Arm registers, including `x18`, with 16-byte stack alignment. Allocation uses a 144-byte frame, calculation uses 128 bytes and release uses 64 bytes, before child calls. External services are the accepted allocation child and libc allocation and error-indicator services. No OpenIFS callable, constructed state or module data supplies production.

Four genuine-source profiles, including the live 19-level atmosphere, match 12,584 complete record and payload bytes. Only the declared allocation address is joined between separate owners. All 301 independent high-precision linear relations pass. The focused gate also covers protected ranges, 13 atomic rejections, allocation failure, repeated release, ABI and natural status. A separate assembly process matches all 200 source-profile bytes and links only to libc. No full forecast follows from this component check.
