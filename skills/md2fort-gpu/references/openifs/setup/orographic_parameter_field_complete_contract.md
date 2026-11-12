# Complete Orographic Parameter Field on the GPU

This phase moves one complete gravity-wave parameter calculation to the GPU. Gravity waves carry momentum through the atmosphere. This setup selects pressure levels and drag parameters for waves produced by mountains. The [original contract](../../../../md2fort/references/openifs/setup/cloud_gravity_wave_setup.md) defines the physics, the supported 19-level profiles and the source checks.

The Arm entry remains `md2asm_orographic_gravity_wave_parameter_fields`. Registers x0 through x4 contain the output record, reference pressures, two pressure-coefficient arrays and the address of RHOUR. Register w5 contains LEPHYS, which is 0 or 1. RHOUR is 3600 seconds. Pressure is measured in pascals, while the second coefficient array is dimensionless. The unchanged owning parent validates these physical inputs before the numerical child runs.

One GPU thread executes the complete source order. It forms all 19 midpoint pressures in descending level order, storing each separately rounded result in 152 private bytes. It then scans the midpoints in ascending order, scans the reference pressures in descending order and writes the original parameters. Every add, multiply and divide uses the existing qualified FP64 status helper. Both tendency divisions, 20/RHOUR and 80/RHOUR, execute before the second result replaces the first stored result. Finite input bounds justify the direct comparisons. The phase retains every original threshold and store, including overwritten stores.

The private entry `md2asm_gpu_orographic_parameter_field` takes an argument vector and a 64-byte context. It requires one block with one thread and no dynamic shared memory. The vector contains the addresses of a 48-byte input record and a 16-byte completion record. The input record contains the five original pointers, LEPHYS as a 32-bit integer and a zero reserved word. The context points to eight 64-bit capacity words for the input, completion and five numerical owners, followed by a zero reserved word.

| Owner | Required bytes | Access |
| --- | ---: | --- |
| Argument vector | 16 | Read |
| Context | 64 | Read and write |
| Capacities | 64 | Read |
| Input record | 48 | Read |
| Completion | 16 | Write |
| Output parameter record | 96 | Write |
| Reference pressures | 152 | Read |
| First pressure coefficients | 160 | Read |
| Second pressure coefficients | 160 | Read |
| RHOUR | 8 | Read |

Every owner must align to eight bytes and cover its complete range without address overflow. Read-only views may overlap. An overlap involving the context, completion or output record is rejected before numerical writes. The caller retains every owner until the launch completes. The existing physical domain remains a caller obligation. A shape or context-revision error returns 36300 in the context, a range or writable-overlap error returns 36301 and a reserved-field or LEPHYS error returns 36302. A null or misaligned context, or an existing nonzero context error, returns without numerical work.

The Arm transport uses a 2048-byte frame, preserves x18 and all saved registers, prepares the runtime and launches once. It restores the floating-point control register and incoming errno. It joins the returned sticky numerical flags with the incoming floating-point status. These flags record events such as an inexact rounded result. The phase leaves the context error-event field and the actual mathematical-call counters unchanged. The GPU uses no heap allocation and no captured output in production.

Three retained genuine source cases compare all 288 parameter bytes exactly, including a pressure-threshold profile and disabled physics. Immediate application binary interface checks, numerical status, incoming errno, actual counter storage, guards and unchanged input bytes pass. Twenty-six complete 8192-byte images cover the changed transport and its critical rejection paths. The existing 651 grouped physical relations are reused. Native inspection confirms the eight ordered numerical call sites and ten range calls. These are component checks. Complete forecast agreement and performance remain separate requirements.
