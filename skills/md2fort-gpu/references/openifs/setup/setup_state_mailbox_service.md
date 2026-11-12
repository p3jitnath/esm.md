# Complete Setup Mailbox Service

This component sends a complete setup span through the existing [GPU request service](../cuda_runtime.md). A span is the fixed sequence of original instructions between retained host boundaries. The [PTX module](../../../../../src/openifs/setup/gpu/setup_state_mailbox_service.ptx) retains all 285 original mode bodies and their ordered arithmetic. It supplies one ordinary entry, `md2asm_gpu_r23_setup_span`, and one shared callable, `md2asm_gpu_mailbox_setup_span_body`. The seven earlier scalar service families keep their original bodies.

The application binary interface (ABI) defines the addresses and storage that each call needs. Both device routes take `original_vector:u64` and `common_context:u64`, where `u64` is an unsigned 64-bit address word. They return no direct value. The 24-byte vector holds the source-state, environment and completion addresses. The common context has 64 bytes, revision 1 and the original error, flag and event fields. Its words at byte offsets 48 and 56 hold the capacity-record address and its exact 96-byte size.

| Owner | Bytes | Required contents |
| --- | --- | --- |
| Source state | 832 | Original general and vector registers, source stack pointer, floating-point control and status, and private errno state |
| Environment | 640 | Original six effect-owner bindings and fixed source address tables |
| Completion | 16 | Original source result, saved errno and completion flag |
| Source stack gap | 14,336 | Original space below the captured source stack pointer |
| Source frame | 65,536 | Original live source stack contents |
| Auxiliary record | 32 | Original private mathematical-work owner pointers |
| Capacity record | 96 | Original exact owner sizes, source-gap address and mode |

Retain eight-byte owner alignment and 16-byte source-stack alignment. The source stack pointer equals the gap base plus 14,336 bytes. The floating-point control register must select the original rounding and gradual-underflow policy. Mode occupies an unsigned 32-bit word at capacity byte 80, with range 0 to 284; its following high word is zero. Every original reserved word, complete range check and alias rule remains in the shared body. In particular, environment bytes 32 to 47 start at zero. The original host packers supply the fixed address tables and all referenced owners; this service does not build or cache model state.

The host chooses request kind 8 only when the entry name is exactly `md2asm_gpu_r23_setup_span`, the grid and block each contain one element, and shared storage is zero. The persistent worker uses the same one-thread launch shape and reloads both argument words before the call. Other names and shapes use their original route, including ordinary-entry refusal for an unsupported setup shape. Original admission finishes before a model write.

The original 64-byte mailbox and request lock are unchanged. A release store publishes a request only after its arguments are ready. The GPU acquire load observes that request; the GPU release store publishes completion after all output writes. The host acquire load completes before the caller reads results or releases any owner. Stop acknowledgement and stream completion precede ordinary launches and final release. All aliases and borrowed buffers stay live through that acknowledgement.

The body preserves complete source state, inactive bytes, original flags, last ordered errno event and all six effect-owner identities. Each request clears only the original writable common diagnostics before execution. Returned source flags combine with incoming flags in the original order; a zero event preserves incoming errno. Unsigned counter wrap, allowed counter aliases, mode branches and source failure rules are unchanged. The setup body calls the same numerical span providers as its ordinary predecessor; those imported providers remain once in the device image.

The changed transport passed 38 setup requests and 14 cached requests from the unchanged seven families. All 3,108,704 compared bytes matched. Five accepted ordinary GPU calls supplied complete expected owner images for normal multiplication, signed zero, overflow, underflow and incoming-event clearing. Nineteen controls checked complete prewrite refusal images. The checks include full private state and surrounding guards, six actual counter words, floating-point flags, errno, x18 and saved-register rules. Recorded CUDA calls distinguish service requests from ordinary fallback and verify stop and restart.

No new CPU, Fortran or physical reference was called. Complete source inverses retain the original 285-mode body, all seven earlier family bodies and the accepted request protocol. Their unchanged mathematical and physical evidence is reused. The dynamic transport check uses the retained register-only setup mode 72; it does not replay all setup modes. These results accept the transport component. Full forecast exact outputs and quiet-node performance remain separate requirements.
