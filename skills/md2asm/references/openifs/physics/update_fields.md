# Weather Field Transfer Contract

Revision 1 implements `UPDATE_FIELDS` from [the field update formulation](../../../../../formulations/openifs/physics/field_transfer.md), revision 1. The original source is `ifs-source/arpifs/phys_ec/update_fields.F90`. The [direct assembly](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/physics/update_fields.S) must supply every numerical stage.

## Ordered Arithmetic And Domain

Let $`K`$ count horizontal columns and $`N`$ count levels. Support $`0\leq K\leq4096`$ and $`0\leq N\leq1024`$, one-based selected columns `KIDIA..KFDIA` and empty ranges. Every present array has complete contiguous FP64 storage of shape $`K\times N`$, with columns contiguous. FP64 is the 64-bit floating-point format. Active arithmetic inputs and results are finite. A copy without arithmetic preserves arbitrary incoming bit patterns, including signed zeros and NaN payloads.

The physics object has the accepted 160-byte `TPHY2` layout. Its FP64 value at byte 8 is `TSPHY`, the finite nonnegative time interval in seconds. `KONFIG=1` performs a time update and `KONFIG=2` performs a transfer. Each active output first copies its matching `PI` when present. Otherwise it keeps its incoming value. In mode 1, separately round `PTA-PTS` when `PTS` is present, then `TSPHY*rate` and `output+product`. With no `PTS`, use `PTA` directly. Every active field in mode 1 requires `PTA`. Then separately add present `PA` and subtract present `PS`, in that order.

Each field is active only when `PO` is present and its optional `LDV` is absent or one. A false flag disables all reads and writes for that field. Source stages run through the thirteen fields in their supplied order. Disjoint owners permit independent cells and fields to share one loop without changing any rounding point. Require FPCR zero for nearest rounding with ties to even, gradual underflow and preserved signed zeros. Forbid contraction, fused multiply-add, reassociation and reduced precision.

## Ninety-Seven-Pointer ABI

The default entry `update_fields_` receives 97 address arguments with no scalar result. Registers `x0..x7` hold the first eight addresses and the caller's aligned stack holds the remaining 89. `ORIGINAL_SYMBOL` changes only the entry symbol. Arguments 1 through 6 are `YDPHY2, KONFIG, KIDIA, KFDIA, KLON, KLEV`. The five integer scalars use signed 32-bit storage.

Seven groups follow, each with thirteen corresponding fields, in the order `PI, PS, PA, LDV, PTA, PTS, PO`. An absent optional argument has a null address. Present logical flags use a 32-bit zero or one. Present numerical arrays align to eight bytes and integer flags to four. Metadata and numerical inputs stay read-only.

Different complete output owners are disjoint. A matching `PI` can share its output's complete owner for an in-place update. All other input/output overlaps are unsupported. No descriptor or hidden array length is required. The assembly preserves `x19..x30`, does not use `x18` or the preserved low halves of `v8..v15`, and restores its aligned stack. Its 880-byte stack frame saves the complete address list. It processes two columns with Arm vector instructions and one remaining column with scalar instructions. It needs no external numerical helper.

## Independent Checks And Canonical Bytes

Reuse the accepted timestep layout, optional-address convention and field-update arithmetic routes. The new check forms the exact rational source-minus-sink field balance independently of the rounded operations. It checks each cell and the sum over updated cells against the accumulated rounding-error bound, then checks manufactured nonnegative fields. A contraction witness, halfway rounding, cancellation, signed zeros and subnormals protect the ordered arithmetic.

Canonical bytes concatenate every complete present output owner in `PO1..PO13` order. The focused corpus checks both modes, optional input and increment combinations, absent outputs, absent or false flags, all thirteen field indices, in-place updates, interior columns, arbitrary copy bits, empty ranges, zero dimensions and the column and level limits. Acceptance requires zero differing bytes, unchanged inputs, protected bounds and preserved registers. The original passed 27 cases over 517,160 complete output bytes and 124,758 independent field-balance relations. The direct assembly passed both protected placements of those cases, with 1,034,320 bytes, 249,516 relations and 156 nonzero subnormal results. One additional case checked disabled NaN fields in the original and in both native placements, adding 624 original bytes and 1,248 native bytes. All checks had zero differences, unchanged inputs, preserved registers and FPCR zero on job 7240564, node nid010555, CPU 64. A paired relay also passed the 27 cases and the new disabled-field case, returning 517,784 complete output bytes with zero differences. No comparative timing or speed claim is available.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 observed 2,150 genuine calls. The same-input comparison covers 86,275,200 complete returned owner bytes with zero differences. Independent critical physics, unchanged inputs and the declared interface checks passed. All ten saved forecast files also match across 618,140 bytes. This result covers the declared routine domain and saved files. Independent whole-forecast physics, whole-process byte identity and comparative speed remain unproved.
