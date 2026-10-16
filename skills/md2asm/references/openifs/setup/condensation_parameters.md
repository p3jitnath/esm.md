# Large Scale Condensation Parameters

Revision 1 constructs the complete sixteen-byte TECND record from SUCOND. The two source parameters bound the small values used by the large-scale condensation scheme. REPFLM prevents division by a vanishing ice flux, while REPQMI establishes a minimum specific humidity in the source water treatment. Their source values and FP64 representations remain unchanged. The source describes REPFLM as a minimum flux but does not declare its unit.

The ABI is int md2asm_initialize_condensation_parameters(output, capacity). Registers x0 and x1 contain a writable eight-byte-aligned sixteen-byte record and capacity of at least sixteen bytes. The complete consumed range must be mapped and nonwrapping. Return zero on success or two before mutation for invalid basic input. The record receives REPFLM equal to 1e-24 at byte zero and REPQMI equal to 1e-8 kilograms per kilogram at byte eight. Every record byte is source-defined and no allocation or release is needed.

This integer-only leaf stores the original rounded FP64 literal words and preserves all registers required by the Arm ABI, x18, FPCR, FPSR and errno. It requires no original module data, constructor, MODEL, procedure table, captured parameter record or callable. Complete genuine SUCOND output, independent positivity and magnitude checks, guarded bounds, immediate status and a pure assembly entry are required. Original diagnostic printing remains verification-only and its immediate service status is recorded separately. This producer introduces no new physical equation, forecast or performance measurement.

## Recorded Result

Three complete genuine SUCOND calls agree in all 48 bytes and preserve the complete incoming status, including the supported inherited rounding mode in the integer-only case. The native and genuine source ABI masks are zero. Four invalid basic inputs reject without mutation. The joint independent parameter check confirms both literal roundings, their positive magnitudes and their ordering. The pure assembly process emits all 88 combined TVDF and TECND bytes exactly and has no library dependency. No forecast or timing was run.
