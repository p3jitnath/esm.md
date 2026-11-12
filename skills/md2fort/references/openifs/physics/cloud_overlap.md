# OpenIFS cumulative cloud overlap

Revision 1.0 freezes the complete `radiation_cloud_cover::cum_cloud_cover_exp_ran` body from OpenIFS 48.1.1, in `radiation/module/radiation_cloud_cover.F90`. The [physical input](../../../../../formulations/openifs/physics/cloud_overlap.md) defines adjacent and cumulative cover. The routine uses maximum overlap for a weight of one and random overlap for a weight of zero, with intermediate weights connecting the two cases.

## Ordered FP64 calculations

Use FP64, the 64-bit floating-point format, with each operation rounded separately to nearest with ties to even. FPCR must be zero. Preserve signed zeros and gradual underflow, and forbid fused arithmetic, reassociation, approximate division and reduced precision. Inputs are finite cloud fractions and weights between zero and one. The optional beta conversion permits infinite intermediate reciprocals for zero or extremely small beta, as in the original source, while its returned coefficient remains finite.

The overlap input is alpha unless the optional logical argument is present and true. When it is beta below one, let `RN` mean one FP64 rounding and calculate the following sequence. Beta equal to one gives alpha exactly one.

```math
\begin{aligned}
d&=\lvert\operatorname{RN}(f_j-f_{j+1})\rvert,\\
a&=\operatorname{RN}(1-\beta),\\
b&=\operatorname{RN}(a\,d),\\
c&=\operatorname{RN}(1/\beta),\\
e&=\operatorname{RN}(d+c),\\
h&=\operatorname{RN}(e-1),\\
i&=\operatorname{RN}(b/h),\\
\alpha&=\operatorname{RN}(\beta+i).
\end{aligned}
```

For each interface, multiply alpha by the larger fraction. Independently subtract alpha from one, add the two fractions, multiply the two fractions, subtract that product from their sum, then multiply by one minus alpha. Add the two separately rounded contributions and store the pair cover. These operations implement P01 without contraction.

Start the clear fraction at `RN(1-f_1)` and copy the first fraction directly to the first cumulative output. At each interface, if the upper fraction is at least `1-10*epsilon(FP64)`, set the clear fraction to positive zero. This threshold has FP64 bits `0x3fefffffffffffec`. Otherwise subtract pair cover from one, multiply by the previous clear fraction, subtract the upper fraction from one, then divide the rounded product by that rounded denominator. Finally subtract the clear fraction from one and store cumulative cover. Each dependency preserves its own rounding point.

## ABI and storage

The application binary interface, ABI, defines the argument registers and preserved registers. The AArch64 entry receives six ordinary addresses. Register `x0` points to a four-byte level count `n>=1`, `x1` to `n` FP64 cloud fractions, `x2` to `n-1` FP64 overlap weights, `x3` to `n` mutable FP64 cumulative outputs and `x4` to `n-1` mutable FP64 pair outputs. Register `x5` is either null or an address of a four-byte Fortran logical. Zero means false and one means true. A count of one has no overlap or pair elements, so their addresses need not be accessible.

Every FP64 buffer is aligned to eight bytes, the integer and logical to four bytes, and all buffers are disjoint. Inputs, level count and optional logical remain unchanged. Outputs contain every declared element and no other bytes. The count and all address offsets fit their declared integer widths. The body preserves `x19` through `x29`, the low 64 bits of `v8` through `v15`, the aligned stack pointer and FPCR, and does not use `x18`. The complete beta conversion is inside this body, with no external numerical helper.

## Independent checks and acceptance

An independent probability calculation forms the shared cloudy fraction as alpha times the smaller fraction plus one minus alpha times the product of the two fractions. Subtracting this shared area from the sum gives the adjacent union. A high-precision Decimal calculation then propagates the clear probability using P02. Manufactured endpoint cases check maximum overlap, random overlap, clear layers, fully cloudy layers and a single layer. Near-one and tiny-beta cases protect the original threshold and reciprocal behaviour. Guard pages protect every buffer, and input buffers remain read-only.

Compare every native output bit against the original and an independently written ordered FP64 reference. Independent probability checks retain their separate rounding bounds. The immediate assembly observer checks preserved registers and FPCR. Canonical returned bytes are all cumulative FP64 values followed by all pair FP64 values, in increasing level order and little-endian encoding. Accept only zero differing bytes for exact agreement. A same-input paired forecast batch and all ten saved files must pass before this body is counted as an accepted forecast replacement. Whole-forecast physical verification and comparative timing remain unfinished.

## Accepted forecast calls

The 2026-10-10 combined forecast on exclusive job 7240564, nid010555, CPU 16 with local memory binding passed 307,200 actual calls over 59,801,600 compared returned bytes, with zero differences. All ten saved forecast files match over 618,140 bytes. Earlier accepted verification is reused. Whole-forecast independent physics, whole-process byte identity and comparative speed remain unproved.
