# OpenIFS cloud sample interpolation

Revision 1.0 freezes `radiation_pdf_sampler::sample_from_pdf` and the matching complete `radiation_cloud_generator::sample_from_pdf_simd` body from OpenIFS 48.1.1. Their original sources are `radiation/module/radiation_pdf_sampler.F90` and `radiation/module/radiation_cloud_generator.F90`. The [physical input](../../../../../formulations/openifs/physics/cloud_water_samples.md) describes the cloud water distribution. Both entries calculate one sample by bilinear interpolation, which combines the four table values beside the requested point.

## Ordered calculation

Use FP64, the 64-bit floating-point format, with every operation rounded separately to nearest with ties to even. FPCR must be zero. Preserve signed zeros and gradual underflow, and forbid fused arithmetic, reassociation, approximate arithmetic and reduced precision. `RN` below means one FP64 rounding. The table has `ncdf>=2` fraction points and `nfsd>=2` spread points, a first spread `fsd1` and a positive stored reciprocal spread interval `inv_fsd_interval`.

First calculate `wcdf=RN(RN(cdf*(ncdf-1))+1)`. Convert `wcdf` to a signed 32-bit integer by truncation towards zero, then clamp that index to `[1,ncdf-1]`. Subtract the exactly converted index from `wcdf` and clamp the rounded weight to `[0,1]`. Next calculate `wfsd=RN(RN(RN(fsd-fsd1)*inv_fsd_interval)+1)` and apply the same index and weight rules using `nfsd`. Both coordinates must fit signed 32-bit conversion before clamping. The physical inputs have `0<=cdf<=1` and `0<=fsd<=4`, while additional arithmetic cases cover clipping beyond those ranges.

Let `x` and `y` be the final fraction and spread weights, and let `v00`, `v01`, `v10` and `v11` be the four table values in increasing fraction and spread order. Subtract each weight from one once, preserving its rounded bits, then evaluate this sequence.

```math
\begin{aligned}
a&=\operatorname{RN}(1-x),\qquad b=\operatorname{RN}(1-y),\\
t_1&=\operatorname{RN}(\operatorname{RN}(ab)v_{00}),\\
t_2&=\operatorname{RN}(\operatorname{RN}(ay)v_{01}),\\
s_2&=\operatorname{RN}(t_1+t_2),\\
t_3&=\operatorname{RN}(\operatorname{RN}(xb)v_{10}),\\
s_3&=\operatorname{RN}(s_2+t_3),\\
t_4&=\operatorname{RN}(\operatorname{RN}(xy)v_{11}),\\
v&=\operatorname{RN}(s_3+t_4).
\end{aligned}
```

All table values and arithmetic results are finite. The table defines the distribution used by the unchanged caller; this helper does not regenerate or independently validate its fitted lognormal values.

## ABI and table layout

The application binary interface, ABI, defines arguments and preserved registers. Each AArch64 entry takes four addresses in `x0` through `x3`, for the sampler, one FP64 spread, one FP64 fraction and one mutable FP64 output. The PDF-module entry receives a 16-byte GNU Fortran polymorphic class wrapper, whose first eight bytes point to the sampler object and whose second eight bytes hold its method table address. The cloud-generator entry receives the object address directly. Both branches enter the same complete assembly interpolation body.

The object occupies 112 readable bytes aligned to eight bytes. Its four-byte `ncdf` and `nfsd` are at bytes 0 and 4, its FP64 `fsd1` and reciprocal interval at bytes 8 and 16, and its rank-two GNU array descriptor starts at byte 24. The table base address is at byte 24, element offset at byte 32, first-dimension stride at byte 64 and second-dimension stride at byte 88. The descriptor's dimension bounds contain every selected one-based table index. Its declared extent agrees with `ncdf` and `nfsd`. At index `(i,j)`, the table address is base plus eight times `(offset+i*stride1+j*stride2)`. The usual contiguous table has `stride1=1`, `stride2=ncdf` and `offset=-1-ncdf`.

The class, object, table, scalar inputs and output are disjoint. The scalar buffers occupy exactly eight bytes aligned to eight bytes, and all selected table addresses are aligned and readable. The class wrapper, object, full table and scalar inputs remain unchanged. The body preserves `x19` through `x29`, the low 64 bits of `v8` through `v15`, the aligned stack pointer and FPCR, and does not use `x18`. No stack frame or numerical helper is needed.

## Independent checks and acceptance

A high-precision Decimal reference interpolates along each table row by differences, then interpolates the two row results. It computes coordinates from exact input values and clips them at the table edges. Constant and affine tables give known samples, and every result must remain between the four selected corner values within its rounding budget. The budget is `(32+8*ncdf+8*nfsd)*2^-52*max(1,abs(corners))`, allowing coordinate and interpolation rounding for the declared critical sizes. Guard pages protect the exact scalar and object bounds and the complete table, and an immediate ABI observer checks saved registers and FPCR.

Critical checks compare both original entries to their native entries and an independent ordered FP64 reference, requiring zero differing bytes. They cover corner and interior weights, index ties, clipping, small and larger tables, signed zero and both object interfaces. Canonical output is the complete eight-byte returned FP64 sample in little-endian order. Live observers keep counts for both original symbols separately and compare the complete actual returned sample, with independent interpolation checks. The queued PDF-module name and the additional cloud-generator body remain distinct in coverage records. A combined forecast batch and all ten saved files must pass before either entry is counted as accepted for its executed scope. Statistical quality of the lookup table and whole-forecast physical verification remain outside these entries.

## Accepted forecast calls

The 2026-10-10 combined forecast on exclusive job 7240564, nid010555, CPU 16 with local memory binding passed 25,715,069 actual calls over 205,720,552 compared returned bytes, with zero differences. All ten saved forecast files match over 618,140 bytes. Earlier accepted verification is reused. Whole-forecast independent physics, whole-process byte identity and comparative speed remain unproved. The extra cloud-generator entry remains critical-verified, with zero actual calls in this forecast, and is excluded from the new accepted count.
