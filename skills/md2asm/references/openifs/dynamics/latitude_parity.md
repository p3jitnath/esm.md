# OpenIFS Latitude Parity Contract

Contract revision 1.0 covers complete PRFI2B from local OpenIFS 48.1.1 and ectrans. It implements [even and odd latitude components](../../../../../formulations/openifs/dynamics/latitude_parity.md), revision 1.0, in [direct assembly](../../../../../src/openifs/dynamics/latitude_parity.S).

## Complete Packing

K is KFIELD, the number of input fields. Each field has real and imaginary longitude components, so each latitude has 2K entries. M is KM, the global longitude wave number, and L is KMLOC, its local table index. These counts have no units. NDGL is the number of latitude rows and NDGNH is their northern half, including an equator when present. Require 1 <= NDGL <= 4,096, NDGNH equal to (NDGL+1)/2 with integer division, and 0 <= K <= 4,096.

Require 0 <= NDGLU(M) <= NDGNH. Begin at J=max(NDGNH-NDGLU(M)+1,1) and finish at NDGNH. Each northern row J has southern partner NDGL+1-J. The supplied maps identify both rows in FOUBUF. The starting index is 2K times NSTAGT1B(NPROCL(row))+NPNTGTB1(L,row). Add the field entry, from one through 2K, to read each component. Every map index and complete input interval must lie in its owner. The original INTEGER4 sums and products must not overflow.

For each component, PSIA receives the separately rounded northern-plus-southern sum. PAIA receives the separately rounded northern-minus-southern difference. Other matrix entries and gaps remain unchanged. Empty selections and zero fields write no array bytes. The output has the input field's unit. There is no child calculation, omitted transform stage or time update.

## Arithmetic And Interface

Use FP64, the 64-bit floating-point format, with round-to-nearest and ties to even, gradual underflow and preserved zero signs. Each addition and subtraction rounds once. Consumed components and returned values are finite. Do not fuse or change the arithmetic order.

PRFI2B exports __prfi2b_mod_MOD_prfi2b with five address arguments in x0 through x4, KFIELD, KM, KMLOC, PAIA and PSIA. The first three point to four-byte signed integers. The outputs use GNU Fortran rank-two descriptors with base at byte zero, row stride at 40 and column stride at 64. Strides are measured in elements. Dummy indices begin at one. Require at least 2K rows and NDGNH columns, eight-byte aligned FP64 storage and complete owners that fit signed 64-bit address arithmetic. Signed output strides and gaps are supported. A consumed cell must not overlap a written cell from another argument.

The module pointers R, G and D refer to objects of 56, 208 and 2,584 bytes. R has NDGL at 20 and NDGNH at 28. G has the NDGLU rank-one INTEGER4 descriptor at 128. D has NPROCL at 1,136, NSTAGT1B at 1,328 and rank-two NPNTGTB1 at 1,480. Their original lower bounds determine the map indices. FOUBUF is the module's rank-one FP64 allocatable descriptor, with base at zero, stride at 40 and lower bound at 48. Its stride is one. Scalars, module objects, maps and complete FOUBUF bytes remain unchanged.

The stack stays aligned to 16 bytes. The 160-byte frame preserves x19 through x29 and the link register, leaving x18 and v8 through v15 unused. Contiguous outputs use two independent NEON lanes, which hold two FP64 values in one register. Other pitches use scalar loads and stores. No lane reads beyond the selected field interval. Performance measurements remain pending.

## Physics And Acceptance

The complete original passed independent even and odd reflection and northern/southern reconstruction checks before assembly emission. Twenty-four protected calls cover 91,584 complete output owner bytes and 10,960 physical relations. They include empty selections, zero fields, equatorial pairing, partial latitude sets, shifted map bounds, padded and negative output strides, both unreadable-page placements, signed zeros and subnormals. The frozen input corpus and canonical complete output bytes stay local. The direct native body passed the same frozen corpus with zero differing bytes and preserved registers and FPCR. Seven paired calls checked 25,120 complete parent-carrier bytes, including shared inactive storage. One active output alias was rejected before writing read-only output pages. Acceptance requires zero differing output bytes and FPCR zero.

## Actual Forecast Acceptance


| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| prfi2b_mod::prfi2b | 1,342 | 28,655,616 | Returned owner unions |

Shared saved-file evidence and its limits are in the [coverage record](../../../../../src/openifs/README.md#shared-coarse-forecast-evidence).
