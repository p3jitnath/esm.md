# Default Hybrid Vertical Coefficients

SUVV1 calls SUDEFO_VV1 to construct default vertical coefficients before it selects any initial-file override. The hybrid pressure law is $`p=A+Bp_s`$, where $`A`$ and $`p_s`$ have units of pascals and $`B`$ is dimensionless. This component owns the declared source constants for the selected ECMWF 19-level case and the shared one-level edge. It also writes reference pressure P0=101325 Pa. The actual initial-file coefficient selection remains a later, separate SUVV1 stage.

## Source And Interface

The source is arpifs/setup/sudefo_vv1.F90. The supported source branches are LDECMWF=true with KFLEV=19, and KFLEV=1 with either canonical logical value. The 31-level ECMWF table and the 15/21/24-level non-ECMWF tables remain unsupported. Canonical logical values are 32-bit zero or one. This bounded component does not claim those other source routes.

The raw entry md2asm_initialize_default_hybrid_coefficients receives LDECMWF in w0, KFLEV in w1, writable A and B arrays in x2 and x3, and a writable pressure word in x4. Each array has N+1 FP64 values indexed 0 through N. Output buffers are eight-byte aligned, disjoint and large enough for their complete extents, without address wrap. It returns zero in w0 on success or two before any write for an unsupported branch or invalid buffer relationship.

The leaf copies the original decimal literals rounded once to FP64. It performs no floating-point operation, allocates no storage and calls no external service. It preserves incoming FPCR, FPSR, errno, x18 and all required Arm 64-bit registers, with no stack frame. The caller owns the output buffers and their lifetime. No original callable, module-data address, type descriptor or virtual method is required.

## Native Binding

The original SUDEFO_VV1 five-pointer entry receives pointers to LDECMWF and KFLEV in x0 and x1, then A, B and P0 in x2 through x4. The native adapter reads the two canonical 32-bit scalar inputs and calls the raw leaf. It preserves required registers with a 32-byte, 16-byte-aligned frame. Unsupported input exits with code 121 before any coefficient byte changes. Diagnostic printing and DR_HOOK profiling are omitted; every source-assigned numerical word on the supported path is constructed.

The integer-only md2asm_default_hybrid_native_count_get getter returns completed native calls. SUVV1 calls this source routine once before its original input-file supersede stage. The candidate has no numerical fallback and no production packet of precomputed model state.

## Required Evidence

The focused source control compares complete A, B and P0 buffers and outer guards for the 19-level route and both one-level logical cases. Immediate ABI and raw status checks cover the leaf and the original five-pointer adapter. The decimal source literals remain in a separate verification reference, and an independent high-precision pressure check verifies increasing interface pressures and the exact top/bottom limits for the default table. The real original jump slot must bind the native entry without executing a setup body. Complete native forecast admission remains separate.

The [complete forecast comparison](../../../../../src/openifs/README.md#verification) passes for this selected route, with every final owner and saved file compared. Original startup and remaining runtime services still prevent an autonomous-executable claim.
