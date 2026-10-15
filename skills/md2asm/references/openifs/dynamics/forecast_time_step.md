# Forecast Time Step Contract

Output binding revision 2 retains STEPO from OpenIFS 48.1.1, original source `arpifs/control/stepo.F90`. Its [formulation](../../../../../formulations/openifs/dynamics/forecast_time_step.md) groups existing grid and wave physics. The primary entry is `md2asm_stepo_output_r2_7358525`. The retained parent comparisons and passing joint final-state and saved-file gate admit this selected route.

## Complete Ordered Step

Keep one process, 2,048 cells and 19 levels. The selected source first handles scheduled output, converts spectral fields to grid values, performs the complete grid scan and GP_MODEL route, converts the grid state back to spectral fields and applies SPCM. Preserve the direct IOPACK, inverse transform, output-aware SCAN2M, forward transform and spectral-calculation child order. SCAN2M retains selected FULLPOS output before GP_MODEL_HEAP2. No Fortran weather calculation supplies a numerical stage.

At steps zero, six, twelve, eighteen and twenty-four, use the exact nine-character history configuration AAAA00AAA. Use 0AAA00AAA at other weather updates. The two post-processing objects are present on those scheduled steps and retain the selected modes one, two and zero. Other model, correction, stochastic and observation alternatives are excluded by the frozen source guards.

## Interface And Services

The application binary interface, or ABI, defines how arguments and registers pass between calls. STEPO takes twelve ordinary addresses and a final eight-byte GNU character length of nine. The first eight addresses use x0 through x7, and the remaining four addresses and length use consecutive incoming stack slots. All object types and optional presence remain unchanged. A trajectory record has 512 bytes; its selected array index and actual allocation bounds must agree. Required real arrays are eight-byte-aligned, little-endian FP64 in their original layouts. Preserve complete owners, descriptors, aliases and inactive bytes.

The frame has 1,280 bytes and 16-byte alignment. Preserve x18, x19 through x29, the return address and required low halves of v8 through v15. Require FPCR zero and retain every child's FP64 rounding point, gradual underflow and signed zeros. Fused operations, contraction, reassociation and approximate numerical arithmetic are forbidden. Record immediate FPSR and errno before observation.

USER_CLOCK, OPDIS, the typed step-log writer and DR_HOOK remain original runtime services. The original log10 text-frequency route remains separate from weather fields. Output calculations use direct children, while selected output metadata and WROUTSPGB/WROUTGPGB file services remain declared Fortran dependencies. This callable step still requires the surrounding forecast and does not own initial loading.

## Acceptance And Build

Reuse unchanged child science and interfaces. The retained scheduled and ordinary parent comparisons, trajectory and optional-object bounds, raw status, ABI and child completion combine with the passing joint final-state and ten-file gate. The joint loop records 25 native STEPO calls.

Assemble the self-contained source with `gcc -c -fPIC -march=armv8.2-a+simd src/openifs/dynamics/forecast_time_step.S -o forecast_time_step.o`, then link the retained output-aware direct route and runtime services. Publication compares machine text, constants and relocation meanings with the retained object. No model or unchanged scientific check is repeated.
