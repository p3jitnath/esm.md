# Longwave Transmission Without Scattering Contract

Revision 2 retains [P01 and P02](../../../../../formulations/openifs/physics/no_scattering_longwave.md) from `radiation_two_stream::calc_no_scattering_transmittance_lw` in the unchanged OpenIFS file `radiation/module/radiation_two_stream.F90`. It returns layer transmission and two thermal emission terms. Layer combination and the rest of the radiation solver remain separate routines.

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

Use the shared accepted scalar and four-value EXP routes. Each vector lane follows the same separately rounded arithmetic and exact table words as the scalar route, within its tested one-ulp accuracy scope. An ulp is the spacing between neighbouring FP64 values. Require FPCR zero, gradual underflow and preserved signed zeros. Fused operations, reassociation and approximate division are forbidden.

## Interface And Bounds

The Arm application binary interface supplies seven ordinary addresses in `x0` through `x6`. They address an INTEGER4 count, then contiguous FP64 arrays for optical depth, top source, bottom source, transmission, upward emission and downward emission. Each reached array cell occupies eight aligned bytes, with the requested count supplied by the caller. Inputs and the three outputs are disjoint. A nonpositive count writes no output and reads no array cells.

The assembly owns a 128-byte stack frame with 16-byte alignment. It preserves `x19` through `x26`, `x29`, `x30` and the low 64 bits of `d8` through `d11`, while other saved registers are untouched. Only the three output arrays are mutable. The driver supplies no omitted numerical calculation.

When at least four cells remain, integer guards require every depth to be strictly above the unchanged threshold and below 256. These positive finite depths give negative EXP arguments with magnitudes above `2^-54` and below 425, inside the qualified four-value domain. Two independent two-lane groups retain each cell's complete ordered expression. The child preserves full `q8` through `q15` and `q24` through `q31`, so both groups can keep their live state across the call. Every load and store stays within the next four cells. Mixed groups, excluded depths and the final one to three cells use the unchanged scalar point.

The counted four-value call adds four to the existing scalar EXP counter, with unsigned 64-bit wrap. The scalar thick branch adds one and the thin branch adds none. The admitted group contains no status observer, flag clear or errno service. Its final outputs, sticky floating-point status, errno and counters match the scalar cell order; intermediate status snapshots are outside this private interval.

## Acceptance

A 39-case independent verifier integrates the linearly varying thermal source with 100 decimal digits. A direct series for small depths preserves subnormal scales without subtracting two nearly equal numbers. Outward rounding intervals and the stated thin-layer approximation bounds set the scientific limits before generation. Critical cases include transparent and isothermal layers, steep thermal gradients, the exact branch threshold and its two neighbouring FP64 values, and exponential underflow. The accepted source record has a largest thick-branch error of about `5.09e-11` W m⁻² and a largest thin-branch error of about `9.18e-4` W m⁻² for the tested extreme source contrast. Preserve the thin-layer approximation rather than presenting it as an exact physical solution.

Compare complete returned owners with the unchanged strict original, requiring zero differing bytes. Reuse the accepted EXP routes, array guards and live comparison pattern. Protect input immutability, output bounds, empty counts and FPCR. The assembly is written directly from this contract and built with the assembler and linker. Detailed records remain local under `.agents/weather24h/two-stream/` and `.runtime/openifs/weather24h-two-stream/`.

## Current qualification

The four-cell route passes 143 focused cases and 4,576 protected native calls. All 3,778,944 output bytes and 3,788,096 read-only bytes match the accepted scalar assembly. The checks cover empty counts, mixed and thin groups, all remainders, depth boundaries, nonfinite source values, seeded sticky flags and counter wrap. The native ABI mask is zero, and immediate final FPSR, FPCR, errno and counter observations agree. The independent 39-case thermal-integral evidence is reused because the physical equations and approximation limits are unchanged.

Matched component measurements pass on four declared physical input profiles with varied depths and 24, 140, 27 and 143 cells. All 48 accepted pairs favour the four-cell route and preserve every checked owner byte, status value and EXP count. These profiles reuse retained physical source values and do not describe actual forecast frequencies. Detailed measurements and rejected pairs remain local.

The changed [autonomous forecast](../input/standalone_weather_forecast.md) matches all 685 numerical owners, 560 descriptor relationships and 27,486,113 raw bytes. All ten saved files over 618,140 bytes and 59 final-field views match exactly. The native ABI mask is zero, with natural FPCR, FPSR and errno of zero, 25 and zero. All six ordinary runs in three matched pairs also retain every saved file and final field, with checks outside timing. The [README](../../../../../README.md) reports the joint complete-process result. Known process-boundary differences and whole-forecast physical-budget limits remain unchanged.
