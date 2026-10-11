# Fourier Metric Contract

Revision 1.0 derives from [Fourier Wind And Gradients](../../../../../formulations/openifs/spectral_transforms/fourier_metric.md). The original queued entry is `fsc_mod::fsc`. Direct [fsc.S](../../../../../src/openifs/spectral_transforms/fsc.S) supplies its complete Gaussian-grid numerical body.

## Supported Inputs

The runtime geometry flag `LATLON` must be false. The latitude–longitude output branch remains outside this contract because it applies a separate trigonometric phase shift. Geometry objects `D`, `F` and `G` must be associated, with valid stored bounds and a positive finite supplied metric. `KGL` and `MYSETW` must select stored entries. Wave counts, field counts and stagger offsets are nonnegative. Every consumed field value and returned calculated value must be finite. Untouched locations can contain arbitrary bits, including signed zero and NaN payloads.

Matrices support signed element and column strides, including padded and reversed views. Their logical elements must be distinct. Separate arguments may occupy disjoint field views of one shared allocation, as in the original `ftinv_ctl` caller. Written logical elements cannot overlap a different source view. An inactive argument can refer to the caller’s shared dummy array. Its field values are not used.

## Ordered Calculation

Let `J` be `D%NPTRLS(MYSETW)+KGL-1`, `M=G%NMEN(J)` and `S=D%NSTAGTF(KGL)`. Read `g=F%RACTHE(J)`. The setup defines this metric as `1/(a*cos(latitude))`, so it includes the Earth’s radius.

Scale the `2*KF_UV` wind fields in columns `S+1` through `S+2*(M+1)` by `g`. If `KF_SCDERS>0`, scale the `KF_SCALARS` northward-derivative fields in those columns by `g`. Each FP64 multiplication rounds separately.

For each integer wave `m=0..M`, set `r=S+2*m+1`, `j=r+1` and `k=RN(g*FP64(m))`, where `RN` means round to nearest with ties to even. If `LUVDER` is true, write `PUVDERS(:,r)=RN((-PUV(:,j))*k)` and `PUVDERS(:,j)=RN(PUV(:,r)*k)`. Wind values here are the separately rounded scaled values. If scalar derivatives are enabled, apply the same two assignments to `PSCALAR` and `PEWDERS`. Negation precedes multiplication. Preserve signed zeros, gradual underflow and every intermediate rounding point. Do not fuse the metric factors or use fused multiply-add.

The body uses FP64 Arm Advanced SIMD for two adjacent fields when both needed field strides are one. Scalar loops handle other strides and odd field counts. These paths perform the same independent operations. The body has no external numerical child and changes no geometry.

## Interface And Bounds

The GNU Fortran entry `__fsc_mod_MOD_fsc` receives nine addresses. `KGL`, `KF_UV`, `KF_SCALARS` and `KF_SCDERS` are INTEGER4 scalars. `PUV`, `PSCALAR`, `PNSDERS`, `PEWDERS` and `PUVDERS` are rank-two FP64 GNU descriptors. The first eight addresses arrive in `x0..x7` and the last arrives at the entry stack pointer. The caller stack is 16-byte aligned. Scalars and descriptors require natural alignment, and field elements require eight-byte alignment. The 176-byte frame preserves `x19..x30`, leaves `d8..d15` unchanged and does not change FPCR.

A matrix descriptor is 88 bytes. Its first logical element is the data address at offset 0. Element strides are at offsets 40 and 64. Stored dummy lower bounds and offset do not change first-element addressing. Every active field and column must fit its supplied extents. Global component descriptors instead use their stored offset and the declared index.

The metadata layout is GNU OpenIFS-specific. `D` is 2,584 bytes, with `NSTAGTF` at 1,000 and `NPTRLS` at 1,200. `F` is 728 bytes, with `RACTHE` at 280. `G` is 208 bytes, with `NMEN` at 64. These rank-one descriptors use data at 0, element offset at 8, stride at 40 and bounds at 48 and 56. Module symbols supply `MYSETW`, `LATLON` and `LUVDER`. Geometry and scalar inputs remain byte-identical.

## Acceptance

Before generation, the original body passed 26 protected cases and 13,304 independent metric, complex-gradient, constant-wave and orthogonality relations. These checks use high-precision physical equations, independently of the source loop. The corpus covers zero fields, wave numbers 0 through 512, odd field counts, signed strides, shifted global bounds, subnormal values, signed zeros and untouched NaN payloads. The native body passes those 26 cases and two focused shared-array cases, with zero differences across 420,240 complete owner bytes and 27,062 independent source/native physical relations. Protected buffer edges, immediate saved-register checks and FPCR zero pass. Six paired smoke calls compare 13,952 complete owner-union bytes and pass 531 physical relations, including the caller’s shared views.

The live checker preserves the original caller’s shared allocation views. It clones each overlapping owner union once, restores descriptor-relative addresses and compares every returned owner byte against the original call. Only declared output elements may change, and scalar input elements remain identical. Independent finite physical checks accompany each admitted live call. Genuine geometry and call counts must be recorded before claiming forecast coverage. Complete forecast acceptance additionally requires zero differing saved-file bytes. Local build, check and relay records remain under the ignored runtime folder.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 passes these positive actual calls with zero differing bytes. Each byte scope describes the complete owners compared by that routine.

| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| fsc_mod::fsc | 1,600 | 2,186,528,256 | Complete input and returned owner unions |

All ten saved files also match across 618,140 bytes. The accepted critical physics and interface checks are reused. These checks cover the declared routine domains and saved files. Whole-forecast physical verification, whole-process byte identity and comparative timing remain open in the [coverage record](../../../../../src/openifs/README.md).
