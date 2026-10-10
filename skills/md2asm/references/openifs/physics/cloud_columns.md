# OpenIFS exponential-random cloud column

Revision 1.0 freezes the complete `radiation_cloud_generator::generate_column_exp_ran` body from `radiation/module/radiation_cloud_generator.F90` in OpenIFS 48.1.1. The [physical input](../../../../../formulations/openifs/physics/cloud_columns.md) defines the layer-selection probabilities and sharing of cloud water samples. The complete direct body calls the verified [uniform stream](../support/random_stream.md) and [PDF interpolation](pdf_sampler.md) assembly children, including all their numerical stages.

## Draw order and ordered arithmetic

Use FP64, the 64-bit floating-point format, with separately rounded operations, nearest rounding with ties to even, gradual underflow and preserved signed zeros. FPCR is zero. Forbid fused arithmetic, reassociation, approximate arithmetic and reduced precision. Inputs are finite consistent cloud fractions and cover probabilities, valid nonnegative spread values and sharing weights between zero and one.

First draw `iend+1-itrigger` uniform values for finding clouds, including the final unused cloud-location value. Start a contiguous cloudy group with one layer. Visit layers `itrigger+1` through `iend+1` in that order. Below an existing cloud, multiply the next cloud-location sample by the upper fraction and compare it strictly below the separately rounded sum of lower and upper fractions minus pair cover. Below clear air, subtract the upper fraction from cumulative cover, multiply by the next sample, and compare strictly below pair cover minus overhang minus upper fraction, with each subtraction separately rounded.

When cloud ends, or the final sentinel layer is reached, draw one complete group of uniform values for water variation, then another complete group for sharing decisions. Do this in that order even for an empty group, whose two zero-length calls leave the stream unchanged. For cloudy group positions two through the group length, strictly compare the sharing sample against the corresponding interface weight and copy the previous variation sample when the condition holds. Then sample each cloudy layer through the complete PDF assembly in increasing layer order. Clear layers and other sample columns retain their incoming output bytes. Set the group length to zero after every fill.

## ABI, private storage and mutation

The application binary interface, ABI, defines function arguments and preserved registers. Fourteen ordinary addresses are passed in their source order. Registers `x0` through `x7` contain addresses of four-byte sample count `ng`, four-byte level count `nlev`, four-byte selected column `ig`, mutable 2448-byte stream, readable 112-byte PDF object, `nlev` FP64 fractions, `nlev-1` FP64 pair covers and `nlev` FP64 cumulative covers. The incoming stack holds addresses of overhang, spread, sharing weight, top-layer integer, bottom-layer integer and output matrix, at byte offsets 0, 8, 16, 24, 32 and 40.

Overhang and sharing arrays have `nlev-1` FP64 values, and spread has `nlev`. The output matrix has `ng*nlev` FP64 values in Fortran column-major order, so column `ig` in layer `j` is at element offset `(j-1)*ng+ig-1`. Require `ng>=1`, `1<=ig<=ng` and `1<=itrigger<=iend<=nlev`. The selected top layer contains cloud. All counts and address offsets fit their declared widths, buffers are disjoint, integer addresses align to four bytes, and FP64 and object addresses align to eight bytes. The caller provides stack space for a 224-byte header and three `nlev` FP64 arrays, rounded up to 16-byte alignment.

Only the stream and declared cloudy output elements may change. Every other matrix element, all physical inputs and every sampler byte remain unchanged. The direct body saves `x19` through `x29` and the return address, preserves the low 64 bits of `v8` through `v15`, restores the aligned incoming stack pointer and FPCR, and does not use `x18`. Its native children are bound inside the assembled closure, so an evaluation driver supplies no missing random or sample stage.

## Critical physics and acceptance

The independent reference uses the mathematical lagged integer queue for all draws, conditional cloud probabilities, group sharing and independently written ordered interpolation. Manufactured all-cloud and maximum-overlap columns must fill every selected layer. Alternating clear layers must retain their incoming output values. Random overlap exercises isolated and repeated cloud groups, and shared samples are tested at weights zero and one. Complete output matrices and complete stream bytes compare directly against the original, with zero differing bytes. Guard pages check all argument bounds and an immediate assembly observer checks saved registers and FPCR.

Canonical returned bytes concatenate the complete 2448-byte stream and complete output matrix in increasing storage order, encoded little-endian. The paired forecast observer repeats the same-input original/native comparison for every actual column call. Accepted children and their original critical evidence are reused, with no repeated full-stream scientific scan. The combined forecast and ten saved files passed, so this body is accepted. The parent cloud_generator's other overlap branches and external power function remain separate dependencies.

## Accepted Forecast Calls

The 2026-10-10 combined forecast passed generate_column_exp_ran 11,730,600 calls over 256,154,595,200 complete returned owner bytes, with zero differences. All ten saved files match over 618,140 bytes. The run used exclusive job 7240564 on nid010555, CPU 16 and local memory binding. Accepted child checks and unchanged arithmetic routes are reused. Whole-forecast independent physics, whole-process byte identity and comparative speed remain unproved.
