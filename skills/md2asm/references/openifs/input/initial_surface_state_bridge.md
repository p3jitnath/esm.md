# Initial Surface-State Bridge

This direct assembly bridge replaces the selected original `SUGRIDG` input call. It validates the live model layout, then calls the [complete assembly surface loader](initial_surface_state_loading.md). Record decoding, field selection, unit changes and model-array placement all belong to that direct route. The original numerical `SUGRIDG` and `MODGRINML` bodies are not called.

## Original Interface

The nine original pointers are geometry, surface state, physics controls, atmosphere–ocean coupling controls, dynamics controls, file selector, returned orography flag, optional boundary-layer height and optional field input. The first eight use `x0` to `x7`, and the ninth uses the caller stack. This selected route requires file selector zero and absent optional arrays. Required objects must be mapped original GNU12 types. The file selector and returned flag require four-byte alignment. The returned orography flag is false.

Read-only local typed Fortran getters validate the complete five owner shapes and capacities, live source-order requests for 47 surface fields and five layered fields, their destination planes and the original physical constants and vegetation tables. They reject trajectory and unsupported configuration branches. These getters supply metadata and input constants only. They change no forecast field and perform no numerical stage. This temporary typed metadata boundary remains explicit.

Assembly copies the live sixteen-character `CFNIGG` path, removes trailing spaces and appends a zero byte. The loader reads that real input file through the declared ecCodes C file-format library. The original complete owner preimages remain inputs. Earlier surface defaults are a separate stage, so this bridge does not invent a zero initial state.

## ABI And Evidence

The application binary interface, or ABI, uses a 3008-byte frame aligned to sixteen bytes. Preserve the Arm saved integer registers, required vector-register halves and incoming `x18`. Restore incoming FPCR, FPSR and `errno` after metadata inspection, then retain all arithmetic status from the accepted direct loader. Unsupported metadata or a loader error stops with exit 116 and records a rejection. There is no numerical fallback.

Verification-only reporting writes ten little-endian 64-bit words to `native-surface-input-counters.bin` under `MD2ASM_NATIVE_SURFACE_INPUT_REPORT_DIR`. They contain revision, entries, completions, failures, rejection code, entry FPCR, entry FPSR, returned FPSR, entry `errno` and returned `errno`. Require positive entries, matching completions and zero failures and rejection.

Three genuine original-interface ABI cases pass, and the actual complete original packet matches every one of 2146560 owner bytes from the original preimages. FPCR zero, FPSR sixteen and `errno` two match the actual source call. Independent source and ABI review passes. The joint native forecast also passes every one of 27486113 bytes in 685 complete final owners and 618140 bytes in ten saved files, with matching immediate status and a positive native input counter. Accepted child physical and critical checks are reused. Complete model construction and the remaining typed metadata prevent a claim of full autonomous forecasting.
