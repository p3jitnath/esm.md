# Initial Surface-State Startup

The selected original `SUGRIDF` route first sets defaults and then loads the initial surface fields. This direct assembly entry preserves that order. It calls [all-row default assignment](initial_surface_default_assignment.md) followed by the accepted [complete surface input bridge](initial_surface_state_bridge.md). The [physical formulation](../../../../../formulations/openifs/input/surface_initial_state_conversion.md) and loading children retain their accepted equations and arithmetic.

## Original Interface

The ten original pointers are geometry, surface state, model configuration, file selector, orography array descriptor, returned orography flag, optional boundary-layer height, optional climatology flag, optional reset flag and optional initial month. Registers `x0` to `x7` carry the first eight, and the caller stack carries the last two. Require mapped original GNU12 objects, file selector zero and absent boundary-layer height, climatology and reset arguments. An absent reset argument selects defaults in the original source. The month and orography values are unused in this selected route. The returned orography flag is false.

Typed read-only getters require the original GRIB input branch, no climatology or aquaplanet branch, 24 rows, 86 blocks and 2048 physical points. They return original component addresses and live default maps, shapes and constants. They perform no forecast calculation and remain an explicit local Fortran metadata boundary.

## State And ABI

Allocate 99904 private bytes for a bounded 64-owner table, 4096 default assignments and status. Read default constants only for source request flag minus one. The direct assignment leaf writes every allocated row of each selected plane, including the final 16 padding rows. Then the complete direct loading bridge writes the physical grid points only. Every other byte retains its original preimage or declared default. The actual selected ten allocations total 7149696 bytes.

The application binary interface, or ABI, uses a 352-byte frame aligned to sixteen bytes. Preserve `x18`, the saved integer registers and required vector-register halves. Restore incoming FPCR, FPSR and `errno` after metadata and allocation, then preserve the numerical return status across deallocation. The numerical children retain frozen FP64 operation order. Unsupported metadata or a child error stops with exit 116 and a recorded rejection, with no original numerical fallback. The declared ecCodes C interface and ordinary allocation and file services remain explicit dependencies.

Closing `GPNORM2` and `GPNORM3` startup console statistics and timing instrumentation are omitted. They change no forecast field. The actual immediate source status still agrees exactly. Other seeded status cases check this input route and do not claim arbitrary flag equivalence to omitted diagnostic calculations.

## Evidence

Three genuine original-interface ABI cases pass against separate whole-slice defaults and placement. The complete actual typed replay also matches every one of 7149696 bytes in ten original owners, including all 306 defaults and full padding. It starts from every original incoming byte, with no invented zero state. FPCR zero, FPSR sixteen and `errno` two match the actual original call. Independent source and ABI peer review passes.

The joint native forecast passes all 27486113 bytes in 685 complete final owners and 618140 bytes in ten saved files. Both startup and surface input counters are positive, with matching status and no numerical observer. Each counter has the same ten-word format as the input bridge, in `native-surface-startup-counters.bin` under `MD2ASM_NATIVE_SURFACE_STARTUP_REPORT_DIR` and `native-surface-input-counters.bin` under `MD2ASM_NATIVE_SURFACE_INPUT_REPORT_DIR`. Accepted child physical and critical checks are reused. Other model construction and the retained typed metadata still prevent a claim of a fully autonomous forecast.
