# Longwave Two-Stream Coefficient Contract

Revision 1.0 implements [P01](../../../../../formulations/openifs/physics/two_stream_gammas_lw.md) from `radiation_two_stream::calc_two_stream_gammas_lw` in the unchanged OpenIFS file `radiation/module/radiation_two_stream.F90`. Each spectral point is independent, with no omitted radiation transport stage.

## Ordered Arithmetic

Let RN mean one FP64 operation rounded to nearest, with ties to even. The constant `L` has the original FP64 value of 1.66, and `H = L*0.5` is an exact power-of-two scaling of its bits. For each point, calculate `f = RN(H*omega)`, `a = RN(1+g)`, `b = RN(f*a)`, `gamma1 = RN(L-b)`, `c = RN(1-g)` and `gamma2 = RN(f*c)`. Each operation rounds separately. Require FPCR zero, gradual underflow and preserved signed zeros. Fused arithmetic and reassociation are forbidden.

## Interface And Bounds

The Arm application binary interface supplies an INTEGER4 count pointer in `x0`, then GNU Fortran descriptors for `omega`, `g`, `gamma1` and `gamma2` in `x1` through `x4`. Reuse the accepted [rank-one descriptor contract](calc_two_stream_gammas_sw.md). Byte zero addresses the first logical cell, and byte 40 holds the signed element stride, with zero interpreted as one. Each reached cell has eight aligned bytes. Inputs, outputs and descriptors are disjoint, and the caller supplies the requested count. Negative-stride sections are supported. A nonpositive count writes no output and reads no array cells.

The leaf assembly uses only caller-saved registers, has no stack frame or external call, and preserves all callee-saved registers, FPCR, inputs and descriptor bytes. It uses a scalar loop for every supported stride and count.

## Acceptance

Require zero differing bytes for all returned output cells and unchanged owner bytes against the unchanged strict original. Independent higher-precision checks use `gamma1-gamma2 = L*(1-omega)` and `gamma1+gamma2 = L*(1-omega*g)`, with rounding bounds from the six elementary operations and operand scales. Critical cases protect absorption and conservative limits, forward and backward scattering, signed zeros, subnormal inputs, empty counts and signed descriptor strides. Reuse the accepted guard and preload patterns, with no new broad ABI or dependency audit. Keep native critical acceptance separate from live forecast acceptance. The assembly is written directly from this contract and built with the assembler. Detailed records remain local under `.agents/weather24h/two-stream/` and `.runtime/openifs/weather24h-two-stream/`.

## Accepted forecast calls

The 2026-10-10 combined forecast on exclusive job 7240564, nid010555, CPU 16 with local memory binding passed 292,394 actual calls over 654,962,560 compared returned bytes, with zero differences. All ten saved forecast files match over 618,140 bytes. Earlier accepted verification is reused. Whole-forecast independent physics, whole-process byte identity and comparative speed remain unproved.
