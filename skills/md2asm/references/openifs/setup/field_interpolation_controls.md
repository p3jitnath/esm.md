# Field Interpolation Controls

This component owns the complete ten-flag block in section 1.08 of original `SUDYN`, lines 807 through 827. These flags select interpolation options that limit new peaks and troughs when the model estimates a field between stored grid points. A Boolean flag has the four-byte integer value one for true or zero for false. The component preserves the source choices and performs no numerical interpolation.

The source reads the live `LSLAG` flag from MODEL and the live `NCONF` and `LECMWF` values from the existing platform record. `LSLAG` selects semi-Lagrangian transport, which follows estimated air movement. `NCONF` identifies the configured model route, and `LECMWF` selects its ECMWF defaults. The three outputs `LQMHW`, `LQMHT` and `LQMP` are true exactly when `LSLAG` is true and either `NCONF` is 1, 302 or 904, or `LECMWF` is false and `NCONF` is 131. The other seven outputs are always false in this source block.

The direct C interface is `int md2asm_initialize_field_interpolation_controls(MODEL,capacity,platform16)`. Registers x0, x1 and x2 carry those three arguments. MODEL has at least 4,275,088 mapped bytes and eight-byte alignment. The read-only platform record has 16 mapped bytes, four-byte alignment and no overlap with MODEL. Its first two signed 32-bit words hold `NCONF` and `LECMWF`; its remaining eight bytes are not consumed. Both spans must not wrap the address space. All signed 32-bit `NCONF` values are supported, and both input Boolean flags must be zero or one.

The typed MODEL offsets are fixed by the original module definitions. `LSLAG` is at byte 1,564,160. The ten outputs form forty consecutive bytes, as shown below.

| Original member | MODEL byte offset | Source value |
| --- | ---: | --- |
| LQMW | 1,568,928 | False |
| LQMHW | 1,568,932 | Derived Boolean |
| LQMT | 1,568,936 | False |
| LQMHT | 1,568,940 | Derived Boolean |
| LQMP | 1,568,944 | Derived Boolean |
| LQMHP | 1,568,948 | False |
| LQMPD | 1,568,952 | False |
| LQMHPD | 1,568,956 | False |
| LQMVD | 1,568,960 | False |
| LQMHVD | 1,568,964 | False |

All checks finish before the first output store. Return zero means success, and return two means an invalid checked interface or Boolean input. Refusal leaves MODEL and the platform record unchanged. Successful calls change exactly the ten named words. The leaf uses only caller-saved integer registers, makes no external call and uses no stack or allocation. It preserves x18, every required saved register, all vector registers, FPCR, FPSR and errno. No release stage is needed.

The verification reference retains the unchanged complete original Boolean block inside a typed wrapper. The separate logical check uses a configuration membership table and verifies all ten flags. Exact comparisons include the complete MODEL record and the complete platform record, with an explicit current R17 input case. Critical checks cover all selected source branches, unsupported Boolean values, buffer extents, alignment, overlap and the native application binary interface. The enclosing changed forecast remains a separate acceptance gate.

The accepted local gate covers 32 Boolean truth-table cases and the complete current R17 MODEL input. The source, direct leaf and independent membership table agree on all ten output words, with zero differing bytes across 141,077,904 complete MODEL bytes. Both records retain their 64-byte guards on each side, and all read-only platform bytes remain unchanged. Eleven refused calls preserve both records. Every native and source call passes the saved-register check and preserves FPCR, seeded FPSR and errno. No forecast was run for this isolated leaf.
