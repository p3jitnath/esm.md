# Longwave Transmission Without Scattering Contract

Revision 1.0 implements [P01 and P02](../../../../../formulations/openifs/physics/no_scattering_longwave.md) from `radiation_two_stream::calc_no_scattering_transmittance_lw` in the unchanged OpenIFS file `radiation/module/radiation_two_stream.F90`. It returns layer transmission and two thermal emission terms. Layer combination and the rest of the radiation solver remain separate routines.

## Ordered Arithmetic And Method

Let RN mean one FP64 operation rounded to nearest, with ties to even. Each operator below rounds separately. The factor `L` keeps the original FP64 bits of 1.66. The branch threshold is `0x3f50624de0000000`, or 0.0010000000474974513, because the original source literal has FP32 precision before promotion. Replacing this with FP64 0.001 changes the method at the threshold.

```text
c = L*od
if od > threshold
    T = EXP(-c)
    q = (bottom-top)/c
    up = (q+top) - T*(q+bottom)
    down = (bottom-q) - T*(top-q)
else
    T = 1-c
    up = (c*0.5)*(top+bottom)
    down = up
```

The thick-layer branch is the analytical solution for a thermal source that changes linearly across the layer. The thin-layer branch retains the original first-order approximation, which makes both emission terms equal. For nonnegative depth, the transmission approximation error is at most `c*c/2`. Each emission approximation error is at most `max(top,bottom)*c*c/2`. These limits follow by integrating `1-exp(-x) <= x`, and are separate from FP64 rounding.

Use the shared accepted non-fused scalar EXP route, with its tested one-ulp accuracy scope. An ulp is the spacing between neighbouring FP64 values. Require FPCR zero, gradual underflow and preserved signed zeros. Fused operations, reassociation and approximate division are forbidden.

## Interface And Bounds

The Arm application binary interface supplies seven ordinary addresses in `x0` through `x6`. They address an INTEGER4 count, then contiguous FP64 arrays for optical depth, top source, bottom source, transmission, upward emission and downward emission. Each reached array cell occupies eight aligned bytes, with the requested count supplied by the caller. Inputs and the three outputs are disjoint. A nonpositive count writes no output and reads no array cells.

The assembly owns a 128-byte aligned stack frame. It preserves `x19` through `x26`, `x29`, `x30` and `d8` through `d11`, while other callee-saved registers are untouched. Only the three output arrays are mutable. One shared EXP call occurs in each thick cell, and no external call occurs in the thin branch. The driver supplies no omitted numerical calculation.

## Acceptance

A 39-case independent verifier integrates the linearly varying thermal source with 100 decimal digits. A direct series for small depths preserves subnormal scales without subtracting two nearly equal numbers. Outward rounding intervals and the stated thin-layer approximation bounds set the scientific limits before generation. Critical cases include transparent and isothermal layers, steep thermal gradients, the exact branch threshold and its two neighbouring FP64 values, and exponential underflow. The accepted source record has a largest thick-branch error of about `5.09e-11` W m⁻² and a largest thin-branch error of about `9.18e-4` W m⁻² for the tested extreme source contrast. Preserve the thin-layer approximation rather than presenting it as an exact physical solution.

Compare complete returned owners with the unchanged strict original, requiring zero differing bytes. Reuse the accepted scalar EXP route, array guards and live comparison pattern. Protect input immutability, output bounds, empty counts and FPCR. Keep critical native acceptance separate from live forecast acceptance. The assembly is written directly from this contract and built with the assembler and linker. Detailed records remain local under `.agents/weather24h/two-stream/` and `.runtime/openifs/weather24h-two-stream/`.

## Accepted forecast calls

The 2026-10-10 combined forecast on exclusive job 7240564, nid010555, CPU 16 with local memory binding passed 972,800 actual calls over 3,268,608,000 compared returned bytes, with zero differences. All ten saved forecast files match over 618,140 bytes. Earlier accepted verification is reused. Whole-forecast independent physics, whole-process byte identity and comparative speed remain unproved.
