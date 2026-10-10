# Independent-Column Longwave Sensitivity Contract

Revision 1.0 implements [P01 and P02](../../../../../formulations/openifs/physics/longwave_surface_sensitivity.md) from `radiation_lw_derivatives::calc_lw_derivatives_ica` and `radiation_lw_derivatives::modify_lw_derivatives_ica` in the unchanged OpenIFS file `radiation/module/radiation_lw_derivatives.F90`. Both numerical entries share a direct assembly calculation, with separate mode selection before its loop.

## Ordered Arithmetic And Complete Update

Let RN mean one FP64 operation rounded to nearest, with ties to even. Form the surface total by starting at positive zero and adding `flux(g)` in increasing spectral-index order, rounding after each addition. Store each `q(g) = RN(flux(g)/total)` in private FP64 storage. Set the selected column's surface output to exactly one.

Visit layers from `nlev` down to one. At each layer, update every `q(g) = RN(q(g)*trans(g,layer))`. Form the new response by starting at positive zero and adding the rounded updated values in increasing spectral-index order. The assembly stores each rounded product before its immediate ordered-sum use, which keeps the original dependencies and saved values while avoiding another scratch read. For the modify entry, compute `a = RN(1-weight)`, then store `RN(RN(a*old) + RN(weight*response))`. The calculate entry stores the response directly. Both entries supply every layer and the surface boundary, with no driver-provided numerical stage.

Require FPCR zero, gradual underflow and preserved signed zeros. Fused arithmetic, reassociation, approximate division and reordered reductions are forbidden. The physical domain has finite transmissions in zero to one, nonnegative surface flux with a positive finite ordered total, and a weight in zero to one. Nonpositive spectral counts retain the original empty numerical update, with zero responses above a surface value of one, but do not describe a physical spectrum.

## Interface And Bounds

The Arm application binary interface supplies INTEGER4 pointers for `ng`, `nlev` and `icol` in `x0` through `x2`, followed by contiguous FP64 transmission and surface-flux arrays in `x3` and `x4`. Transmission uses Fortran order, with the spectral index contiguous and a layer pitch of `ng` cells. The calculate entry supplies the rank-two output descriptor in `x5`. The modify entry supplies an aligned FP64 weight pointer in `x5` and the output descriptor in `x6`.

The GNU Fortran descriptor stores its first logical cell pointer at byte zero, column stride at byte 40 and level stride at byte 64. The first zero stride maps to one, matching the unchanged original. The second stride is used directly. The descriptor's logical lower bound is one for both dimensions. Write only cells of the selected one-based column through level `nlev+1`, retaining every other output owner byte. Each reached cell has eight aligned bytes, and signed-stride output sections are supported. Arrays, scalar inputs and the descriptor are disjoint. The caller provides the declared capacities, `nlev` is nonnegative, the column is within the output bounds and `ng` is at most 4096.

The assembly owns `8*max(ng,0)` scratch bytes rounded upward to 16-byte alignment, at most 32 KiB. It uses caller-saved registers only, makes no external call and restores the entry stack pointer. All callee-saved registers, FPCR, inputs and descriptor bytes remain unchanged. The local live-pair wrapper calls the unchanged original on a cloned output owner, retaining its profiling calls, then returns the direct assembly's result on the actual owner. Profiling records are outside canonical numerical output.

## Acceptance

Require zero differing bytes across the complete returned owner against the strict original. Independent higher-precision calculations evaluate the weighted products in P01 directly, rather than reuse the ordered scratch update. Rounding bounds follow from the count of normalisation, attenuation and reduction operations, with gradual-underflow terms included. Check response bounds, attenuation between faces, transparent and opaque layers, a single spectral interval and weights zero and one. Protect empty spectral loops, zero layers, the selected column, signed descriptor strides, maximum scratch size, inputs, neighbours and the stack obligations. Reuse the accepted descriptor and protected-owner patterns, and keep critical acceptance distinct from live forecast acceptance. The assembly is written from this contract and built with the assembler and linker. Detailed records remain local under `.agents/weather24h/two-stream/` and `.runtime/openifs/weather24h-two-stream/`.

## Accepted Forecast Calls

The 2026-10-10 combined forecast passed calc_lw_derivatives_ica 51,200 calls, modify_lw_derivatives_ica 42,755 calls over 120,262,400 complete returned owner bytes, with zero differences. All ten saved files match over 618,140 bytes. The run used exclusive job 7240564 on nid010555, CPU 16 and local memory binding. Accepted child checks and unchanged arithmetic routes are reused. Whole-forecast independent physics, whole-process byte identity and comparative speed remain unproved.
