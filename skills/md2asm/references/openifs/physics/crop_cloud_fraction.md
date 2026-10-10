# Small Cloud Filter Contract

The physics input is [small_cloud_filter.md](../../../../../formulations/openifs/physics/small_cloud_filter.md), revision 1, equations P01 and P02. Preserve `radiation_cloud::crop_cloud_fraction` from the strict original.

## Calculation

Visit layers from 1 to the cloud fraction array's second extent, then columns from `istartcol` to `iendcol`, inclusive. Compare the stored fraction with the fraction threshold. When it is smaller, store positive FP64 zero. Otherwise add the stored liquid and ice water values, round their sum to FP64, and compare that rounded sum with the water threshold. Store positive zero only when the sum is smaller. Retain the original fraction bits in every other case.

Both comparisons are strict. Equality retains the cloud. Near the water threshold, the rounded sum controls the decision. Its exact physical sum can differ by the single addition's rounding error. Do not replace this rule with an approximate comparison or change either threshold. Empty layers or column ranges write nothing.

## Interface and storage

`md2asm_openifs_crop_cloud_fraction` takes the class wrapper, first INTEGER4 column, last INTEGER4 column, FP64 fraction threshold and FP64 water threshold in x0–x4. The class wrapper's first pointer addresses the cloud data object. It contains 88-byte GNU Fortran 12 array descriptors. Liquid water, ice water and cloud fraction begin at data bytes 0, 88 and 352.

For each descriptor, the data pointer and element offset are at bytes 0 and 8, the second stride at byte 64, and the second lower and upper bounds at bytes 72 and 80. The arrays have lower bounds of 1 and contiguous first dimensions. For column $`i`$ and layer $`k`$, the element address is the data pointer plus $`8(e+i+k s_2)`$ bytes, where $`e`$ is the element offset and $`s_2`$ is the second stride. The first stride is one. This is the original allocatable-array address rule. Row gaps and signed second strides are supported when every selected address is inside its buffer.

The caller supplies disjoint cloud arrays, valid selected columns and naturally aligned metadata, FP64 values and thresholds. Other cloud members remain unchanged. Profiling hooks stay in the local verification wrapper. The leaf uses only caller-saved x0–x17 and d0–d4, without x18, callee-saved registers, a stack frame or external calls.

## Output and acceptance

Only selected cloud fraction cells can change. Preserve all other fraction cells, all liquid and ice water cells, both thresholds and all descriptors. Use FPCR equal to zero and compare complete output owners against the strict original with zero differing bytes.

The small verifier covers empty and partial ranges, single and multiple layers, threshold equality and adjacent FP64 values, signed zeros, subnormal water, row gaps and signed second strides. Independent exact rational sums establish the physical water decision outside its single-rounding interval. Cases inside that interval must still match the original stored-number decision exactly. Critical and live forecast checks passed. Comparative timing is not available.

The small original/native check passes 576 calls over 375,552 complete owner bytes with zero differences and 22,440 independent physical relations. The composable paired relay passes the same cases. Both bodies use only caller-saved registers and contain no fused or approximate floating-point instructions.

## Accepted Forecast Calls

The 2026-10-10 combined forecast passed crop_cloud_fraction 6,400 calls over 7,782,400 complete returned owner bytes, with zero differences. All ten saved files match over 618,140 bytes. The run used exclusive job 7240564 on nid010555, CPU 16 and local memory binding. Accepted child checks and unchanged arithmetic routes are reused. Whole-forecast independent physics, whole-process byte identity and comparative speed remain unproved.
