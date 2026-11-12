# Shortwave Two-Stream Coefficient Contract

Revision 1.0 implements [P01](../../../../../formulations/openifs/physics/two_stream_gammas_sw.md) from the unchanged OpenIFS routine `radiation_two_stream::calc_two_stream_gammas_sw` in `radiation/module/radiation_two_stream.F90`. The calculation applies the physical coefficient formulas separately at each spectral point. It does not supply a radiation transport stage.

## Ordered Arithmetic

Let RN mean one FP64 operation rounded to nearest, with ties to even. For each point, calculate `f = RN(0.75*g)`, `a = RN(1.25+f)`, `b = RN(omega*a)`, `gamma1 = RN(2-b)`, `c = RN(0.75-f)`, `gamma2 = RN(omega*c)`, `d = RN(mu*f)` and `gamma3 = RN(0.5-d)`. All constants are exact binary values. Each multiply, add and subtract rounds separately. Require FPCR zero, gradual underflow and preserved signed zeros. Do not use fused arithmetic or reassociation.

## Interface And Bounds

The Arm application binary interface places an INTEGER4 count pointer in `x0`, an aligned FP64 solar-angle pointer in `x1`, and GNU Fortran array descriptors for `omega`, `g`, `gamma1`, `gamma2` and `gamma3` in `x2` through `x6`. Each descriptor supplies its first logical cell address at byte zero and its signed element stride at byte 40. A zero stride means one, matching the original entry. Each reached cell occupies eight aligned bytes, and the caller supplies storage for the requested count, including negative-stride sections. Descriptors and inputs are read-only. Output arrays are disjoint from inputs and each other. A nonpositive count writes no output and reads no array cells.

The assembly uses caller-saved integer registers and FP registers `d0` through `d7` and `d16`. It needs no stack storage, makes no external call and preserves all callee-saved registers, FPCR and descriptor bytes. There is one scalar path for every supported stride and count, so no vector remainder or alignment assumption is hidden.

## Acceptance And Output

Compare every returned output cell and untouched owner byte with the unchanged strict Fortran library, with zero differing bytes. Independent higher-precision checks use the equivalent physical identities `gamma1-gamma2 = 2*(1-omega)` and `gamma1+gamma2 = 2-omega*(0.5+1.5*g)`, together with the direct beam coefficient. Include transparent absorption, conservative scattering, forward and backward scattering, horizon and vertical sunlight, signed zeros, small subnormal inputs, nonpositive counts and positive, negative and zero descriptor strides. A per-expression rounding bound follows from its elementary operation count and operand scale. Guard pages protect the declared array bounds.

Critical native acceptance and forecast acceptance are recorded separately. The direct assembly is written from this contract and built with the assembler. The original machine code is inspected only to confirm the ABI and separate rounding, and is not used as generated solver source. Detailed checks remain local under `.agents/weather24h/two-stream/` and `.runtime/openifs/weather24h-two-stream/`.

## Accepted forecast calls

The 2026-10-10 combined forecast on exclusive job 7240564, nid010555, CPU 16 with local memory binding passed 1,265,194 actual calls over 3,400,841,472 compared returned bytes, with zero differences. All ten saved forecast files match over 618,140 bytes. Earlier accepted verification is reused. Whole-forecast independent physics, whole-process byte identity and comparative speed remain unproved.
