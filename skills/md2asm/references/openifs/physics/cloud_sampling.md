# OpenIFS Cloud Sampling Parent

Revision 1.0 freezes the complete forecast-configured radiation_cloud_generator::cloud_generator calculation from OpenIFS 48.1.1. The [physical input](../../../../../formulations/openifs/physics/cloud_sampling.md) defines conditioned cloud-top selection and shared water variations. The frozen forecast uses exponential-random overlap, whose source scheme number is one. Maximum-random and exponential-exponential schemes remain outside this entry's admitted domain.

## Domain And Complete Update

Require 1 to 4 096 samples and 1 to 512 layers, a positive finite cloud threshold at most one, finite fractions and overlap weights between zero and one, and a positive finite decorrelation scale with finite reciprocal. Spread inputs and PDF tables follow the accepted [PDF contract](pdf_sampler.md). The seed follows the accepted signed-integer [random stream](../support/random_stream.md) semantics, including negative seeds. The optional beta flag can be absent, false or true under the accepted [cloud-cover contract](cloud_overlap.md). All inputs are readable over their declared extents, and mutable outputs are disjoint.

First call the complete accepted exponential-random cloud-cover body. Copy its final cumulative fraction to total cover. Form each overhang as the next cumulative fraction minus the current fraction, with one separate rounding. If total cover is strictly below the threshold, overwrite only total cover with positive zero and preserve every incoming multiplier bit, including unused NaN payloads. Otherwise locate the first and last positive cloud fractions by increasing layer index.

Copy all overlap weights. From the first cloudy layer through the interface above the last, replace each strictly positive weight by P02 through the source-compatible power primitive. Preserve zero weights and copied interfaces outside this interval. Zero the entire sample-by-layer matrix. Initialise the private random stream from the seed, then consume exactly the sample count of top-location values in one call. Visit columns in increasing order. Multiply each top sample by total cover, start at the first cloud and advance while that product is strictly greater than cumulative cover and the last cloud has not been reached. Pass that top, the last cloud and complete arrays to the accepted [column body](cloud_columns.md), which performs every location draw, sharing decision and PDF interpolation. No evaluation driver supplies a numerical stage.

Use FP64 with nearest rounding and ties to even, gradual underflow, signed zeros and FPCR zero. Ordinary solver operations have separate rounding points, with no contraction, reassociation, approximate division or reduced precision. The private opaque power primitive reproduces the original library's twenty internal single-rounded steps through exact integer rounding and emits no fused floating-point instruction. Reuse its locally frozen proof without global power interposition. This source-defined power boundary remains distinct from separately rounded solver arithmetic.

## ABI, Storage And Mutation

The Arm application binary interface, ABI, defines argument order and preserved registers. Thirteen addresses follow the source order. Registers x0 through x7 hold sample count, level count, scheme, seed, threshold, fractions, overlap weights and decorrelation scale. The incoming stack holds spread, the 112-byte sampler, multiplier matrix, total cover and optional beta flag at offsets 0, 8, 16, 24 and 32 bytes. Integers and logicals use four bytes, and FP64 values use eight. Fortran column-major storage puts sample g in layer j at element (j-1)*ng+g-1.

Fractions and spread have nlev entries, overlap has nlev-1, and the complete matrix has ng*nlev. A single layer reads no overlap element. A 2 800-byte private header contains the complete 2 448-byte stream, descriptor, arguments and counters. Additional aligned storage contains four level-sized arrays, one sample-sized array and six child stack arguments. Address products fit their declared widths. Integer addresses align to four bytes, FP64 buffers and objects to eight, and the stack to sixteen. Inputs and complete sampler/table owners remain unchanged. Only total cover and, for cloudy columns, the complete matrix may change.

The body preserves x19 through x29, the return address, low 64 bits of v8 through v15, stack alignment and FPCR. It does not use x18. Scheme and scalar limits are checked before output writes. The complete cover, stream, PDF and column children are privately bound, with their unchanged accepted proofs reused.

## Critical Physics And Acceptance

Independent probability checks form cloud union from shared area and verify monotone cumulative cover. The first-cloud interval widths sum to total cover, so dividing by that cover gives a probability distribution. The integer random queue, accepted conditional cloud rules and independent PDF interpolation provide an expected complete matrix without supplying a native stage. Single, all-cloud, separated-cloud, threshold, zero-sharing and full-sharing cases cover the new parent decisions. New power operands are checked against high-precision mathematics and genuine source bits, reusing the unchanged general helper proof.

Protected owner placements check complete readonly inputs, matrix and total-cover bytes, unused NaN payloads, scalar boundaries, all thirteen argument positions, saved registers and FPCR. Canonical bytes concatenate the complete matrix and total cover in increasing storage order, using little-endian encoding. Require zero differing bytes against the unchanged original before the paired relay or saved-file gate.

## Local Readiness

The complete configured parent passes 58 protected calls, 163 488 returned owner bytes and 44 415 independent parent relations with zero differences. Twenty-five new power operand pairs include the retained square-counterexample and a subnormal weight. Fourteen paired calls add 1 344 compared bytes, including valid zero-valued sample endpoints. Complete readonly owners, unused clear-column NaN bits, all thirteen argument positions, saved registers and FPCR pass. A final twelve-call paired check qualifies the unique private random-consumer binding without repeating unchanged child mathematics. Local cloud_sampling_parent_7240564/ready.json retains exact source, object, primitive and command identities.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 passes these positive actual calls with zero differing bytes. Each byte scope describes the complete owners compared by that routine.

| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| radiation_cloud_generator::cloud_generator | 102,400 | 1,961,984,000 | Complete routine owners |

All ten saved files also match across 618,140 bytes. The accepted critical physics and interface checks are reused. These checks cover the declared routine domains and saved files. Whole-forecast physical verification, whole-process byte identity and comparative timing remain open in the [coverage record](../../../../../src/openifs/README.md).
