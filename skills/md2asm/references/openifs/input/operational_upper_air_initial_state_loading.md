# Operational Upper-Air Initial-State Loading

This assembly loads all 959 upper-air records for the 9 km, 137-layer case. It joins the accepted [field reader](operational_gridpoint_field_readers.md) and [placement stage](operational_upper_air_initial_state_placement.md). It adds allocation, call order and cleanup. It performs no new physical arithmetic.

## Interface and Storage

The application binary interface (ABI) defines the argument registers and saved state. The entry `md2asm_load_operational_upper_air_initial_state` receives a readable zero-terminated path in x0, the mutable model-buffer address in x1 and its unsigned 64-bit byte capacity in x2. The output must be nonnull, eight-byte aligned, mapped and nonwrapping. Its shape is 17 by 137 by 9 by 388,217 in Fortran order and requires 65,099,332,296 bytes. Capacity beyond that span remains unchanged. The caller supplies the complete incoming state, including padding.

The input file is `ICMGGacflINIUA`. Its records each contain 6,599,680 values. The reader defines field identities and metadata. Placement copies seven fields, writes positive zero to two diagnostic fields and retains the padding of copied fields. Mass fractions have units kg/kg. Cloud fraction has no unit. Every copied value retains its complete 64-bit representation.

## Ordered Calls and Errors

Validate the output span and floating-point mode before allocation or file access. Allocate one 50,632,783,320-byte buffer through C `malloc`. The first 50,632,744,960 bytes hold decoded values. The remaining 38,360 bytes hold 959 rows of five signed 64-bit metadata words. All byte counts and address operations use 64-bit integers. A completed-record counter occupies eight local stack bytes.

Call the direct reader with both exact private capacities. Only after complete decoding succeeds, call the direct placement stage on the caller's unchanged model buffer. Release the private allocation once through C `free` on every acquired path.

| Return value | Meaning |
| --- | --- |
| 0 | Complete load |
| 1 | Invalid argument, output span or floating-point mode |
| 2 | Private allocation failed |
| Reader code plus 16 | Decoding failed |
| Placement code plus 32 | Placement refused its inputs |

An invalid input, failed allocation or decoding error leaves the complete model buffer unchanged. The placement stage validates every record before its first write. The path must remain readable until decoding returns. It is an input path, rather than part of the model state.

## Register and Library Boundary

The floating-point control register, FPCR, must be zero for the accepted codec route. The parent preserves FPCR, the floating-point status register FPSR, the C error indicator `errno`, the platform register x18 and all required saved integer and vector registers. Its stack frame has 112 bytes and retains 16-byte alignment. The parent uses no floating-point instructions for calculations.

Production calls use direct assembly children, the public C ecCodes file-format interface, ordinary file services and C allocation/runtime services. No original OpenIFS routine, global state, constructor or Fortran verification tool supplies a production stage. This component remains separate from complete `SUGRIDUG`, diagnostic norms, full model construction and forecast acceptance.

## Acceptance

The complete native load matches an independent C control that streams one public-codec field at a time into its own model buffer. All 65,099,332,296 output bytes agree from the same arbitrary preimage. Five native ABI/status calls pass. Four refusals protect the entire output against writes and cover short capacity, unsupported FPCR, allocation failure and a genuine wrong row-length list. The private allocation and release counts balance on every path, and 2,672 outer guard and capacity bytes remain unchanged. All mappings are released.

An independent source/interface review passes. Production dependencies contain only public ecCodes and C services. The unchanged reader and placement proofs are reused, with no repeated child test bank. The check is a component verification, not a forecast timing or complete original input-routine claim. Exact input, source, build and critical records remain locally under `.runtime/`.
