# Optional Daily Climate Storage Contract

Revision 1 records the optional daily `CLIMR` owner from `arpifs/setup/sumcclag.F90`. CLIMR stores local daily climate fields. SUMCCLAG lines 163 to 461 place its allocation inside `IF (LMCCEC)`. The [assembly source](../../../../../src/openifs/setup/optional_daily_climate_storage.S) therefore accepts both logical values and leaves this owner unallocated when the flag is false.

## Interface And Bounds

The application binary interface, or ABI, defines argument locations and register duties. `md2asm_initialize_runtime_climate_storage` receives `GEOMETRY` in `x0`, `MODEL` in `x1` and the address of the four-byte `NSTOP` value in `x2`. Geometry must contain at least 20,400 bytes, and Model must contain at least 4,275,088 bytes. Both roots require eight-byte alignment. `NSTOP` requires four-byte alignment. The caller supplies complete live owners and valid readable input spans.

The local point count `Q` is the signed word at Geometry byte 7,376. The global point count is at byte 7,388. Both must be positive, and `Q` must not exceed the global count. Each fits a positive signed 32-bit integer. `NSTOP` must be from zero through 2,147,483,646, so adding one does not overflow. The floating-point control register, FPCR, must be zero before entry.

`LMCCEC` is the logical word at Model byte 1,562,896. Only zero and one are admitted. The retained supported profile also requires zero at Model bytes 1,562,884, 1,562,900, 1,562,916, 1,562,932, 1,562,960, 1,562,888, 1,578,012, 1,578,092, 1,578,112 and 1,578,116, with value two at byte 1,578,264. These comparisons include disabled coupler and mixed-layer modes. They remain required when `LMCCEC` is zero. The CLIMR base word at Model byte 1,562,744 must be null before initialization.

## Ownership And Source Behaviour

After every admission check, a false `LMCCEC` returns success without allocation, stores, stack movement or floating-point operations. It preserves all Model bytes, including the remaining descriptor words and climate counters. A descriptor is the record that holds an array address, shape and strides. Undefined or previously stored counter values are preserved rather than replaced with assumed defaults.

When `LMCCEC` is one, the retained body allocates `120*Q` bytes for fifteen FP64 fields at one time level. It sets the selected field metadata and initializes the payload to the original missing value of minus 999. The enabled allocation and initialization body is byte-exact to its retained version. This revision adds no new claim about its complete numerical use.

`md2asm_release_runtime_climate_storage` takes the Model address in `x0`. A null CLIMR base returns success without writes or a free call, so release is repeatable for the inactive owner. For a nonnull base, release clears that base and calls public `free` once. The containing Model and its descriptor must remain live until release finishes.

Both entries return status in `w0`. Zero means success, one means allocation failure, and two means admission refusal. Initialization uses a 192-byte frame only on the enabled path. Release uses a 16-byte frame only when it frees an owner. The stack keeps 16-byte alignment. Both entries preserve `x18` and the required callee-saved registers. Their assembly adds no floating-point arithmetic. The new inactive path preserves FPCR, the floating-point exception register FPSR and `errno` without calling a public allocator. The value `errno` records a system-library error.

## Completed Check And Limits

One eight-call process checked inactive initialization and release twice, invalid logical values minus one and two, a false-path unsupported `LMCC04` coupler flag and a nonempty owner. The full Geometry, Model and step spans were readonly during each call. All 34,363,936 compared bytes were unchanged. Allocation and free counts stayed zero, with ABI mask zero, FPCR zero, FPSR 16 and `errno` 777. The process and its group were closed.

The source inverse reproduces the selected old object. A focused instruction projection preserves the enabled body, release body, constants and relocation meanings. The published source assembles with the same flags to the exact accepted object. These checks qualify the changed allocation decision only. They do not accept the complete setup parent, runtime parent, full raw state or autonomous forecast. The [runtime time-parent contract](../physics/runtime_model_time_and_forcing.md) records the matching daily-call condition.
