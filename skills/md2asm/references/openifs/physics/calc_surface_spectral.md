# Surface Spectral Flux Contract

Revision 1.0. Use [surface_spectral_flux.md](../../../../../formulations/openifs/physics/surface_spectral_flux.md) for the physical input. The original routine is `radiation_flux::calc_surface_spectral` in `radiation/module/radiation_flux.F90`. It converts surface sample fluxes into radiation and canopy bands without changing the atmosphere.

## Interface and Storage

The four argument registers contain addresses. Register `x0` points to a 16-byte class wrapper whose first word points to the 3,360-byte flux object. Register `x1` points to the 20,040-byte configuration object. Registers `x2` and `x3` point to INTEGER4 first and last column indices. An empty interval changes no output values.

Flux fields use contiguous GNU rank-two FP64 descriptors of 88 bytes. Element `A(i,j)` is at `base + 8*(offset + i*stride1 + j*stride2)`. The pointer and element offset are at 0 and 8, element size at 16, type metadata at 24, and span at 32. Each dimension stores its stride, lower bound and upper bound at 40, 48 and 56 or at 64, 72 and 80. The sample or band index starts at one. The column index can have a different lower bound. The first stride is one and the second stride is the row count.

| Flux field | Object byte |
| --- | ---: |
| Longwave samples | 2000 |
| Shortwave diffuse and direct samples | 2176, 2264 |
| Clear-sky diffuse and direct samples | 2352, 2440 |
| Shortwave total and direct bands | 2528, 2616 |
| Clear-sky total and direct bands | 2704, 2792 |
| Longwave canopy bands | 2880 |
| Shortwave diffuse and direct canopy bands | 2968, 3056 |

The configuration contains INTEGER4 logical flags and band counts. Its sample maps are contiguous one-based rank-one INTEGER4 descriptors of 64 bytes. Its weights use the rank-two FP64 descriptor above.

| Configuration field | Byte |
| --- | ---: |
| Nearest shortwave or longwave assignment | 708, 712 |
| Enable longwave, shortwave or clear sky | 6848, 6852, 6856 |
| Save shortwave surface bands | 7948 |
| Enable shortwave or longwave canopy outputs | 7976, 7980 |
| Use complete shortwave or longwave sample spectrum | 7984, 7988 |
| Radiation band to shortwave or longwave canopy map | 10304, 10368 |
| Shortwave or longwave canopy weights | 10432, 10520 |
| Longwave or shortwave sample-to-band map | 10864, 10928 |
| Shortwave or longwave band count | 20004, 20008 |

All descriptors and FP64 buffers are eight-byte aligned, and INTEGER4 data are four-byte aligned. Every active input and output is allocated with positive row counts and sufficient dimensions for the requested columns. Active radiation band counts are positive. Inactive descriptors can have a null pointer and unspecified remaining metadata. Read an inactive descriptor only when its branch becomes active. Different fields and objects do not overlap. Sample-to-band indices and canopy-map indices are inside their destination bounds. Fluxes and weights are finite and nonnegative, with signed zero permitted. Weighted shortwave canopy output requires saved shortwave surface bands. The private stack space contains one longwave band column and one gathered INTEGER4 sample map. Their complete aligned stack footprint is at most one MiB. The assembly computes temporary sizes only for active branches. These arrays supply no omitted numerical stage.

## Complete Ordered Calculation

Use the accepted direct [indexed_sum](indexed_sum.md) child, whose unique symbol is `md2asm_openifs_indexed_sum`. It clears each band to positive zero and adds sample values in increasing sample order. Build the correct array sections inside the direct assembly caller, including a gathered nearest-canopy map when needed.

If shortwave and saved surface bands are enabled, first sum direct samples into direct bands and diffuse samples into total-band storage. Add direct bands to that storage once. Repeat these steps for clear-sky fields when enabled.

For complete-spectrum canopy output, copy sample bits directly. For nearest-band canopy output, compose the radiation-band and canopy-band maps, then apply the direct indexed sum. For weighted canopy output, clear each destination to positive zero, visit radiation bands in increasing order, and add each nonzero weight times its band flux. Round each product before the sum. Skip both signs of zero weight. Shortwave diffuse canopy output is the completed weighted total minus the completed weighted direct flux. Longwave weighted output first sums samples into radiation bands, then applies the weights.

The original processes independent columns and output fields in separate loops. The direct caller can complete one column at a time because the fields do not overlap and each output cell keeps the same ordered arithmetic. All FP64 operations use round-to-nearest with ties to even, gradual underflow and preserved signed zeros. The FP control register is zero. Do not use fused arithmetic, reassociation, reduced precision or approximate operations.

## Output and Acceptance

Canonical output consists of every byte in the seven band and canopy arrays, including unchanged columns and inactive branches. Keep descriptor, object, configuration, map, weight and input-flux bytes unchanged. Require zero differing canonical bytes and preserve the saved registers and FP control register.

Independently sum the radiation energy through the band and canopy mappings with 100-digit arithmetic. The absolute comparison bound is `(32+8*sample_count+8*band_count)*2^-52*max(1,sum(abs(sample_flux)))`. Weights that sum to one preserve the total energy apart from this rounding bound. The one critical verifier covers full, nearest and weighted canopy routes, enabled and disabled solvers, clear sky, empty and cropped columns, different column lower bounds, and subnormal inputs. Reuse the accepted child verification instead of repeating its internal tests.

The direct source is [calc_surface_spectral.S](../../../../../src/openifs/physics/calc_surface_spectral.S). It saves `x19` through `x29` and the link register, uses an aligned private stack frame, and calls only the complete direct indexed-sum child. Record a live paired forecast separately before claiming forecast acceptance.

## Accepted Forecast Calls

The 2026-10-10 forecast passed calc_surface_spectral 6,400 calls over 27,852,800 complete returned bytes with zero differences. All ten saved files match over 618,140 bytes. It used exclusive job 7240564 on nid010555, CPU 16 and local memory binding. Accepted child and math checks are reused. Whole-forecast independent physics, whole-process byte identity and comparative speed remain unproved. Actual calls use the nearest-band shortwave branch. Other declared spectral branches remain covered by the small critical corpus.
