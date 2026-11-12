# Radiation Band Sum Contract

The physics input is [spectral_band_sum.md](../../../../../formulations/openifs/physics/spectral_band_sum.md), revision 1, equation P01. Preserve the original `radiation_flux::indexed_sum` calculation.

## Calculation

Set every destination band to positive FP64 zero. Visit the source points in increasing dummy-index order, starting at 1. Read the INTEGER4 band number, add that source value to the current band value, round to FP64, and store the result before visiting the next point. A repeated band number therefore has a fixed addition order. Do not combine, reorder or reduce additions in parallel. An empty source still clears all destination bands.

All source values are finite and intermediate sums must remain finite. Source and index arrays have equal extents. Every band number is between 1 and the destination extent. The arrays occupy disjoint buffers.

## Interface and storage

`md2asm_openifs_indexed_sum` receives pointers to the source, index and destination GNU Fortran 12 descriptors in x0, x1 and x2. A descriptor's first pointer addresses its first logical element. Its first stride is at byte 40, with lower and upper bounds at bytes 48 and 56. The upper bound minus the lower bound plus one gives the extent. A zero first stride means one, as in the original assumed-shape interface. Source and destination strides count 8-byte FP64 elements. Index strides count 4-byte integers.

The dummy indices start at 1 regardless of descriptor lower bounds. Signed strides and gaps are supported when all addressed cells lie inside the supplied buffers. The caller supplies naturally aligned pointers and valid indices. Only logical destination cells change. Source values, indices and gaps remain unchanged.

The leaf body uses only caller-saved x0–x17 and d0–d1. It does not use x18, callee-saved registers, a stack frame or external helpers. Return through the unchanged link register.

## Output and acceptance

Keep each output cell's original FP64 bits, including signed zeros and subnormal values. Use FPCR equal to zero, with nearest-even rounding and gradual underflow. Reject every differing output byte against the strict original.

The small verifier checks empty sources and destinations, repeated indices, all band endpoints, signed and gapped strides, zero-stride metadata, cancellation, signed zeros and subnormal values. It compares full destination owners and unchanged input owners. Independent exact rational arithmetic checks the energy sum for each band and bounds the error by the sum of the actual rounding errors at its ordered additions. Critical and live forecast checks passed. No comparative timing result is claimed.

The small original/native check passes 385 calls over 174,144 complete owner bytes with zero differences and 12,576 independent physical relations. The composable paired relay passes the same cases. Both bodies use only caller-saved registers and contain no fused or approximate floating-point instructions.

## Accepted Forecast Calls

The 2026-10-10 combined forecast passed indexed_sum 307,200 calls over 27,852,800 complete returned owner bytes, with zero differences. All ten saved files match over 618,140 bytes. The run used exclusive job 7240564 on nid010555, CPU 16 and local memory binding. Accepted child checks and unchanged arithmetic routes are reused. Whole-forecast independent physics, whole-process byte identity and comparative speed remain unproved.
