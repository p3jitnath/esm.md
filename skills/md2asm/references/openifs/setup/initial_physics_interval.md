# Initial Physics Interval

SUPHY2 first sets the physics interval TSPHY to one second. Later UPDTIM replaces it with the current physics interval. This small producer owns only that initial assignment, so initial SUCLDP parameter setup can receive the source one-second input. It does not implement the remaining SUPHY2 calculations.

The Arm interface is `int md2asm_initialize_owned_initial_physics_interval(MODEL, capacity)` in registers x0 and x1. MODEL is the actual caller-owned 4,275,088-byte record, aligned to eight bytes. Its full span is mapped and nonwrapping, and capacity covers the full record. The caller selects the admitted ECMWF setup and calls this entry before the initial parameter stages. FPCR, the floating-point control register, is zero.

The entry writes the exact FP64 bits `3ff0000000000000` at MODEL offset 4,150,016. They represent 1 second. Every other byte remains unchanged. Return zero means success; return two refuses before a write. The integer leaf has no private frame, allocation or external call. It preserves x18, all required saved registers, FPCR, the arithmetic status FPSR and errno. It does not change rounding or simulate an arithmetic flag.

Two actual-owner calls cover incoming FPSR zero and 24. Five atomic refusals cover null and misaligned addresses, a short capacity, a wrapping span and nonzero FPCR. Seven application binary interface (ABI) observations pass with zero masks. The ABI specifies argument locations and saved registers. Complete MODEL, Geometry, configuration and 20 defined raw-status bytes per case give 30,541,868 compared bytes with zero differences. The proof changes only the declared eight-byte interval. Original numerical banks, the accepted full default object and the main Fortran executable remain unchanged. No original numerical call or new routine credit is claimed.

The enclosing order remains initial interval of 1 second, initial physical parameter setup including SUCLDP, then the accepted UPDTIM current interval of 450 seconds before the bounded convection call. Full live-level SUPHY2, complete initialisation and the autonomous forecast remain separate requirements.
