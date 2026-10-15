# Forecast Time Loop Contract

Output binding revision 4 retains CNT4 from OpenIFS 48.1.1, original source `arpifs/control/cnt4.F90`. Its [formulation](../../../../../formulations/openifs/dynamics/forecast_time_loop.md) groups existing forecast physics. The primary entry is `md2asm_cnt4_output_r2_7358525`. The joint final-state, status, ABI, completion-count and saved-output gate passes for this selected CNT4 route.

## Time And Output Schedule

Keep the frozen coarse state with 2,048 cells, 19 levels and a 3,600-second step. Run steps zero through twenty-five: steps zero through twenty-four perform 25 complete weather updates, and step twenty-five closes the calendar and diagnostic work. Copy the stored TSTEP to TDT on every step. For event time, multiply the step number by TSTEP, add the separately rounded 0.5, then apply the original integer truncation.

Initialise selected diagnostics, construct each integer event schedule through direct MONIO_T and preserve all original calendar, forcing, norm and STEPO call positions. History and selected FULLPOS outputs occur at hours zero, six, twelve, eighteen and twenty-four. Preserve modes one, two and zero and the retained empty physical and ocean request handling. Numerical output calculations use the complete direct FULLPOS route. The spectral norm uses the corrected explicit false optional argument.

The output controller retains the original configuration-zero rule that requests logarithmic surface pressure on model levels even after a pressure-level scan has selected it. Existing field calculations, request packing and file encoding supply that second record in the original order.

The caller owns its schedule descriptors, post-processing data and empty coupling buffers. Keep the configured lower bounds, descriptor strides, fields, deterministic metadata and output encoding. Coupled-ocean, chemistry, predictor correction, stochastic, observation and optional outer correction routes are inactive. Reject unsupported source-selected controls before public writes.

## Interface And Remaining Dependencies

The application binary interface, or ABI, retains ten object addresses and no hidden character length. The first eight use x0 through x7, and the remaining two use consecutive eight-byte incoming stack slots. All inputs must already contain the source-defined initialised forecast objects; optional presence remains unchanged. The frame has 8,192 bytes and 16-byte alignment. Required real buffers are eight-byte-aligned, little-endian FP64 with the original field and cell order. Every used view must fit its complete owner, preserving aliases, readonly data and inactive storage.

Preserve x18, x19 through x29, the return address and required low halves of v8 through v15. Require FPCR zero, separately rounded FP64 arithmetic, round-to-nearest with ties to even, gradual underflow and signed zeros. Contraction, fused operations, reassociation and approximate arithmetic are forbidden. Capture immediate FPSR and errno before observation.

GET_NSIM4D, DR_HOOK, GSTATS, USER_CLOCK, GRIBIOFLUSH, SIGPOST and LOGDIS remain original runtime dependencies. The LOGDIS call passes its six required arguments in x0 through x5. The original call omits the optional character argument CDSTEP. Supply a null address in x6 and a zero hidden character length in x7, so optional presence matches the original interface. This adds no numerical stage. FULLPOS still uses declared Fortran request metadata and file encoding services. This is a callable assembly loop; it has no standalone entry or assembly-owned input loader and does not establish autonomy.

## Complete Incoming Storage

The original surface-reflection table allocates 12 months and 14 radiation bands, where a band is a group of wavelengths. This setup initialises six bands and leaves the remaining allocation unused. The canonical binary input retains the complete 1344-byte table. Before the first native CNT4 call, require the 576 initialised bytes to match and load the remaining 768 input bytes from that canonical file. Record the complete incoming table before and after binding. The direct-call counter must still be zero and the original step marker must be minus 999. The original active reflection values and all forecast calculations remain unchanged, and every final table byte remains in the comparison.

## Acceptance And Build

Reuse the frozen child science, accepted output-request scope and completed numerical source-first/native pairs. The joint forecast completes one native CNT4 call and 25 native STEPO calls. Its 685 final-state owners, totalling 27,486,113 bytes, and all ten saved files, totalling 618,140 bytes, have zero differing bytes under the frozen comparison rules. Immediate FPCR, FPSR and errno agree, and native ABI checks pass. The completion counts show that all scheduled native updates ran; this gate does not compare raw state after every step.

Assemble the self-contained source with `gcc -c -fPIC -march=armv8.2-a+simd src/openifs/dynamics/forecast_time_loop.S -o forecast_time_loop.o`, then link the frozen output-aware child graph and declared runtime services. Publication compares machine text, constant bytes and relocation meanings with the retained object.
