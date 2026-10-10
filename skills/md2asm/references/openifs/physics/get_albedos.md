# Surface Spectral Albedo Mapping

Revision 1 implements `radiation_single_level::get_albedos` from [the surface reflection formulation](../../../../../formulations/openifs/physics/surface_albedos.md), revision 1. The original source is `ifs-source/radiation/module/radiation_single_level.F90`, SHA-256 `83e2481fa87f51aa2ba1a983165bed6f862e36e54ad171fe16741972be3f0342`. The [direct assembly](../../../../../src/openifs/physics/get_albedos.S) supplies the complete mapping, complement and ordered weighted reductions.

Let $`C`$ count selected horizontal columns, $`G`$ count output spectral samples, $`B`$ count atmospheric bands and $`K`$ count supplied surface intervals. Support $`1\leq C,G\leq4096`$ and $`1\leq B,K\leq256`$ in each spectrum. Selected first and last column indices lie within the supplied owners, and empty selected ranges write nothing. Albedos and emissivities are finite fractions in $`[0,1]`$. Each weight is nonnegative and each band has weight sum one. All band and nearest-interval maps have valid one-based indices.

## Ordered Mathematics

Full-spectrum mapping copies each supplied shortwave sample and computes each thermal reflection as `1.0-emissivity`. Nearest mapping first maps a reordered spectral sample to its band, then maps that band to its supplied surface interval.

Weighted mapping starts each band's value at positive zero, visits supplied intervals in increasing order and skips a weight that compares equal to zero, including negative zero. For shortwave, multiply `weight*albedo` and add that rounded product to the current band value. For longwave, first round `1.0-emissivity`, then multiply `weight*complement` and add that rounded product. Map the completed band values to output spectral samples. Do not average emissivity first and then subtract it from one, since this changes rounding.

If the direct shortwave input is absent, nearest and weighted modes copy the completed diffuse output. The original full-spectrum branch instead leaves the incoming direct output bytes unchanged. Preserve that behaviour and make no physical claim about this undefined direct field. An absent optional thermal output is never accessed.

## Original GNU ABI And Owners

The application binary interface, or ABI, fixes the seven ordinary pointers in `x0` through `x6`. They address a 16-byte class wrapper, 4-byte first and last column integers, a 20,040-byte configuration object, direct and diffuse shortwave output owners, and the optional longwave output owner. The class wrapper's first pointer addresses a read-only 624-byte surface object. Its other pointer is the original type table and is not read by the numerical body.

Original GNU allocatable descriptors contain a data pointer at byte zero, an element offset at byte 8, an element length at byte 16 and an element span at byte 32. Each dimension stores stride, lower bound and upper bound at byte offsets 40, 48 and 56, followed by the next dimension at 64, 72 and 80. Strides and offsets count elements. The owner address for one-based subscripts is `data+element_size*(offset+sum(index*stride))`. These allocatable owners are contiguous, with first stride one, and have valid lower bounds and complete storage.

| Surface field | Object byte offset |
| --- | --- |
| `sw_albedo` descriptor | 128 |
| `sw_albedo_direct` descriptor | 216 |
| `lw_emissivity` descriptor | 304 |

| Configuration field | Object byte offset |
| --- | --- |
| `do_nearest_spectral_sw_albedo`, `do_nearest_spectral_lw_emiss` | 708, 712 |
| `use_canopy_full_spectrum_sw`, `use_canopy_full_spectrum_lw` | 7984, 7988 |
| `i_albedo_from_band_sw`, `i_emiss_from_band_lw` descriptors | 10304, 10368 |
| `sw_albedo_weights`, `lw_emiss_weights` descriptors | 10432, 10520 |
| `i_band_from_reordered_g_lw`, `i_band_from_reordered_g_sw` descriptors | 10864, 10928 |
| `n_g_sw`, `n_g_lw`, `n_bands_sw`, `n_bands_lw` | 19996, 20000, 20004, 20008 |

Integer and logical values use four bytes. Real values use FP64, the 64-bit floating-point format. Integer pointers align to four bytes and FP64, object and descriptor pointers align to eight bytes. Input owners can share storage. Each output is disjoint from all other owners and stores spectral samples contiguously before moving to the next selected column. Optional absent addresses are zero.

The default symbol is `__radiation_single_level_MOD_get_albedos` with no returned scalar value. `ORIGINAL_SYMBOL` can change only the symbol. The assembly preserves `x19` through `x30`, leaves `x18` and the preserved low 64 bits of `v8` through `v15` untouched, and restores its aligned stack. Its fixed frame is 160 bytes and its private scratch is $`16\max(B_{\mathrm{SW}},B_{\mathrm{LW}})`$ bytes. Two independent horizontal columns share a weighted-band pass, followed by one scalar remainder. This reuses each completed band value for every mapped spectral sample and does not add numerical work to a driver.

Require FPCR zero for nearest rounding with ties to even, gradual underflow and preserved signed zeros. All products, additions and complements round separately. There is no fused arithmetic, approximation, reassociation, reduced precision or external numerical call.

## Physical Checks And Canonical Bytes

The genuine strict OpenIFS shared-library routine passed 21 critical cases with 106,464 complete returned bytes and 13,287 independent physical relations. Exact rational arithmetic checks each weighted average against its mathematical value using the exact rounding errors of the stated operations. Defined outputs stay in the physical range from zero to one. Cases cover every mapping mode, optional output, direct fallback and untouched full-spectrum direct owner, one and paired columns, odd remainders, negative selected column indices, reordered spectral samples, padded host columns, signed zeros, subnormals, emissivity close to one and the interval and spectral count limits.

Canonical bytes concatenate complete direct and diffuse shortwave output owners, followed by the longwave owner when present, in Fortran order and little-endian FP64. Include the untouched owner in the full-spectrum absent-direct branch. Acceptance requires zero differing bytes, unchanged inputs and no normalisation or masking. The native body passed 46 protected calls and 213,840 complete returned bytes with zero differences, including 84 nonzero subnormal values. These calls check unchanged owners, both guarded placements, preserved registers, stack restoration and FPCR. An independent-mode case adds 57 physical relations, giving 13,344 in total, and an empty selected range leaves every input unchanged. Seven representative relay calls passed 1,704 complete bytes. Batched same-input forecast checks passed.


## Accepted Forecast Calls

The 2026-10-10 forecast passed get_albedos 6,400 calls over 149,094,400 complete returned bytes with zero differences. All ten saved files match over 618,140 bytes. It used exclusive job 7240564 on nid010555, CPU 16 and local memory binding. Accepted child and math checks are reused. Whole-forecast independent physics, whole-process byte identity and comparative speed remain unproved.
