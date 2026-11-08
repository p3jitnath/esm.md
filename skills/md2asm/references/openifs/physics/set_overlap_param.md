# Cloud Overlap Setup Contract

Revision 1.0. The physical input is [cloud_overlap_length.md](../../../../../formulations/openifs/physics/cloud_overlap_length.md). The original routines are `radiation_cloud::set_overlap_param` and the separate `radiation_cloud::set_overlap_param_approx` in `radiation/module/radiation_cloud.F90`. Only the first name is in the current weather queue.

## Interface and Storage

Both routines receive five addresses. Register `x0` points to a 16-byte class wrapper whose first word points to a 792-byte cloud object. Register `x1` points to the 264-byte thermodynamics object, `x2` to the FP64 length in metres, and `x3` and `x4` to optional INTEGER4 first and last columns. A null optional address selects column one or the complete column count.

A GNU rank-two FP64 descriptor occupies 88 bytes. Its data pointer and element offset are at bytes 0 and 8, element size at 16, type metadata at 24, and span at 32. Dimension one has element stride, lower bound and upper bound at 40, 48 and 56. Dimension two has these fields at 64, 72 and 80. Element `A(i,j)` is at `base + 8*(offset + i*stride1 + j*stride2)`. Pressures and temperatures occupy the first two thermodynamics descriptors. The overlap descriptor begins at cloud-object byte 704.

All descriptors and data are eight-byte aligned and lie in valid buffers. All three arrays are contiguous because the original fields are allocatable arrays. Their first stride is one and second stride is the column count. Pressure and temperature use one-based bounds, at least one column, and at least three edges. Pressure has a consistent monotonic direction in all selected columns, with strictly positive pressures wherever the logarithm uses them. Temperature and length are finite and positive. The selected column bounds are within the allocated arrays, and an empty range leaves existing overlap values unchanged. Inputs, output and object storage do not overlap.

If the overlap data pointer is null, allocate `ncol*(nlev-1)*8` bytes through the ordinary C allocator. This creates a contiguous one-based shape `(ncol,nlev-1)` with element offset `-1-ncol`, element size and span eight, and metadata word `0x0000030200000000`. Allocation failure is outside the accepted domain. Preserve every unrelated object byte. Existing allocation metadata remains unchanged. In a fresh allocation, columns outside the requested range are unspecified until a later call writes them.

## Complete Ordered Calculation

Use FP64 round-to-nearest with ties to even, gradual underflow and preserved signed zeros. The FP control register is zero. Each division, multiplication, logarithm and exponential completes before its consumer. Do not fuse, reassociate or approximate these operations. Reuse the accepted scalar LOG and EXP route in `.runtime/openifs/strict-math/libpressure-math.so` for both the original and direct calls.

Let `nlev` be the pressure edge count minus one. The rounded ratio `R_d/g` has bits `0x403d4592b265ab8d`. Form the full factor `-(R_d/g)/L` and the half factor `-(0.5*(R_d/g))/L` with distinct divisions. Determine the storage direction by comparing pressures at edges two and one in the first selected column.

For top-to-ground storage, interface one uses pressure ratio `p(3)/p(2)`, temperature `T(2)` and the full factor. Each later interface `j` uses `p(j+2)/p(j)`, `T(j+1)` and the half factor. For ground-to-top storage, every interface before the last uses `p(j)/p(j+2)`, `T(j+1)` and the half factor. The last uses `p(nlev-1)/p(nlev)`, `T(nlev)` and the full factor. First multiply the factor by temperature, then multiply by the rounded logarithm of the rounded pressure ratio, and apply the accepted EXP body.

The approximate sibling uses factor `-8000/L` and no temperature multiplication. Its top-to-ground ratio is `p(j+2)/p(j+1)`, and its ground-to-top ratio is `p(j)/p(j+1)`. It writes every interface of each selected column.

## Output and Acceptance

Compare all existing output bytes, including inactive columns. For a fresh allocation, compare the complete descriptor except its process-specific data pointer, plus every requested overlap value. All other object bytes, input arrays, optional bounds and length remain unchanged. Require zero differing canonical bytes.

Independently derive the height from 100-digit hydrostatic logarithms and check the exponential probability within `64*2^-52` in absolute value. Reuse the accepted LOG and EXP accuracy checks. Protect selected ranges, both pressure orders, both allocation branches, optional bounds, and saved registers with one small critical verifier. Record live forecast calls separately from these cases. No timings or complete-forecast acceptance are implied by the critical result.

The direct source is [set_overlap_param.S](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/physics/set_overlap_param.S). It uses a 192-byte aligned stack frame, preserves `x19` through `x29` and the link register, and uses no saved FP registers. The allocator and accepted scalar math functions preserve the same ABI obligations.

## Accepted Forecast Calls

The 2026-10-10 combined forecast passed set_overlap_param 51,200 calls over 58,982,400 complete returned owner bytes, with zero differences. All ten saved files match over 618,140 bytes. The run used exclusive job 7240564 on nid010555, CPU 16 and local memory binding. Accepted child checks and unchanged arithmetic routes are reused. Whole-forecast independent physics, whole-process byte identity and comparative speed remain unproved. The approximate sibling had zero live calls and is excluded from the new count.
