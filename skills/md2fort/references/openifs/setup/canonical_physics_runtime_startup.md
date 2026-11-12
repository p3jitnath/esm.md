# Canonical physics runtime startup

The runtime record stores five small controls read by turbulence and cloud physics. The entry `int md2asm_initialize_canonical_physics_runtime_inputs(void)` connects the accepted [runtime-input producer](ecmwf_physics_control_fields.md) to the single `md2asm_owned_surface_runtime_inputs` object used by the physics graph. A canonical object is the one declared storage owner for all its named aliases.

The entry takes no arguments and receives no caller buffer. Its sixteen bytes of direct AArch64 assembly obtain the linked owner address, pass its exact 32-byte capacity and tail-branch to `md2asm_initialize_ecmwf_physics_runtime_inputs`. A tail branch transfers control without another return frame. The accepted child returns zero on success or two on refusal; the entry returns that result without changing it. It preserves `x18`, the saved registers, the stack pointer, FPCR, FPSR and the error number. The linked object has eight-byte alignment and a mapped, nonwrapping 32-byte span.

| Alias | Offset in bytes | Width in bytes | Selected value |
| --- | ---: | ---: | --- |
| `__yommp0_MOD_lscmec` | 0 | 4 | false |
| `__yomobs_MOD_lvdftraj` | 4 | 4 | false |
| `__yomct0_MOD_lrough` | 8 | 4 | false |
| `__yomct0_MOD_rextz0m` | 16 | 8 | positive FP64 zero |
| `__yomct0_MOD_rextz0h` | 24 | 8 | positive FP64 zero |

FP64 means the 64-bit floating-point format. Bytes 12 through 15 are padding and remain unchanged. The accepted source assigns the first two flags false; the other fields retain the documented fresh-storage policy. The actual admitted namelist has no `LSCMEC` override. Call this startup entry after admitting that configuration and before a turbulence or cloud consumer reads the record. An unsupported configuration needs its own producer contract.

The focused gate poisoned the actual object before the call, then checked all 32 bytes, preserved padding, both neighbours, all five alias addresses and three actual consumer address joins. Both immediate ABI calls preserved FPCR zero, incoming FPSR values zero and 24, and error number 777. All twelve mathematical counter owners and the physical, clock and thermal objects remained unchanged. The accepted producer's complete default object and loaded instructions were exact, and the new shared link supplied no second storage owner.

The complete 206-object helper graph, its 228 scalar comparisons, the earlier 148 EXP comparisons and the existing producer refusal checks were reused. This checkpoint does not construct or accept the complete 80-byte `CALLPAR` context, its 35 original argument owners, a weather parent or a forecast. Those owners still require their actual producer order, selected control branches and lifetimes.
