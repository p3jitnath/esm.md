# Initial Forecast Field Storage

This helper allocates one stable FIELDS record for the selected CNT0 and SU0YOMB forecast path. FIELDS holds atmospheric and surface arrays. Its numerical children construct their records directly at their final addresses. The helper owns only the enclosing allocation and CNT0's STATE_MODEL association. It supplies no calculation, complete constructor or prepared forecast state.

The creator ABI is `int md2asm_create_initial_fields_storage(model, owner)`, using x0 and x1. MODEL has 4,275,088 mapped bytes, and owner addresses a writable eight-byte word which starts at zero. Both addresses are nonzero, aligned to eight bytes, nonwrapping and disjoint over their complete bounds. The owned MODEL must remain alive until all field consumers finish. FPCR must be zero. Return zero publishes the new owner, one reports allocation failure without publication, and two rejects the interface before allocation or mutation.

The helper calls calloc for exactly 529,288 zero bytes. Zero supplies the explicit incoming-storage policy, including null owner words and source-default false VARIABLES switches. Later source producers must establish every required field and declaration default before its first use. The helper stores the borrowed MODEL address at byte 1,840. It leaves the GEOM pointer at 1,832 and FIELD pointer at 1,848 null, matching this initial source stage. It does not apply the different generic FIELDS_CREATE method or clone VARIABLES.

| Embedded record | Offset | Bytes | Later producer |
| --- | ---: | ---: | --- |
| TGMV | 1,856 | 1,560 | Owned grid-motion constructor |
| TGFL | 3,416 | 1,096 | Owned grid-point constructor |
| TSURF | 4,512 | 18,224 | Owned selected surface startup |
| SPECTRAL_FIELD | 22,736 | 2,992 | Owned serial spectral constructor |
| TEC_PHYS_FIELDS | 25,728 | 704 | Required physics-field construction |

The accepted TGFL utility already owns CNT0's YRGFL.YGFL association together with its selected SUSC2C allocations. It receives fresh TGFL storage and associates MODEL's field configuration at byte 192 before any later consumer uses it. This helper therefore leaves the complete TGFL record zero for that unchanged utility. Geometry, MODEL and all embedded owners have separate lifetimes. Reserved space for flux diagnostics, field containers and the registry does not claim that those source producers are complete.

The release ABI is `int md2asm_release_initial_fields_storage(owner)`, using x0. Its mapped, aligned and nonwrapping eight-byte word is null or contains a successful live allocation from this helper. A null owner is a successful no-op. The caller must first release every embedded child resource, then call this release before releasing MODEL. It frees only the enclosing allocation and clears the owner word. It does not free MODEL or repeat child-lifetime checks. A malformed owner-word interface returns two before mutation.

Both entries preserve x18, x19–x29, the required low halves of v8–v15, stack alignment, FPCR, FPSR and errno. Creation uses an 80-byte frame, and release uses 64 bytes. Only integer address and store instructions are required. The external boundary contains libc calloc, free and the errno-address service. No original OpenIFS module, callable, constructor, method table or captured record is a production input.

Typed queries confirm the complete record sizes, embedded offsets and pointer-slot addresses from the genuine source declarations. Two source-association cases compare every one of 1,058,576 bytes at the same live MODEL addresses, with zero differences. The reference executes the exact STATE_MODEL association statement from CNT0 on the same zero incoming field storage. Independent relations check that association and the untouched sibling views. Native and reference ABI/status checks pass, including incoming flags zero and 24. Five malformed interfaces reject without mutation, one forced calloc failure leaves the owner null, and an empty release succeeds.

A separate assembly main runs allocation and release with owned storage and only PATH in its environment. It depends only on libc and the system loader. This proves the component boundary. Full FIELDS construction, embedded child integration, the forecast controller and the final physical and saved-output gates remain separate work. No forecast or unchanged numerical verification was run for this storage helper.
