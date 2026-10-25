# ECMWF Soil Diagnostic Class Counts

A diagnostic class groups stored variables or fluxes that a later calculation will report. This entry supplies the fourteen selected soil class counts from `SUNDDH`, lines 555–561 and 591–597. Each value is a dimensionless signed int32 count. The live configuration must select `LECMWF=true`. The entry keeps the seven variable assignments before the seven flux assignments, as in the source.

| Variable count | Value | MODEL byte | Flux count | Value | MODEL byte |
| --- | ---: | ---: | --- | ---: | ---: |
| NDHVTLS | 3 | 4,233,140 | NDHFTLS | 9 | 4,233,144 |
| NDHVTSS | 6 | 4,233,148 | NDHFTSS | 9 | 4,233,152 |
| NDHVTTS | 4 | 4,233,156 | NDHFTTS | 11 | 4,233,160 |
| NDHVTIS | 4 | 4,233,164 | NDHFTIS | 9 | 4,233,168 |
| NDHVSSS | 1 | 4,233,172 | NDHFSSS | 4 | 4,233,176 |
| NDHVIIS | 1 | 4,233,180 | NDHFIIS | 3 | 4,233,184 |
| NDHVWLS | 2 | 4,233,188 | NDHFWLS | 8 | 4,233,192 |

The application binary interface, or ABI, is `int md2asm_initialize_ecmwf_soil_diagnostic_class_counts(MODEL, model_bytes, configuration, configuration_bytes)`, using x0 through x3. The complete writable MODEL has 4,275,088 bytes, and the immutable configuration has 67,616 bytes. Both records are mapped, eight-byte aligned, nonwrapping and disjoint. Configuration byte 0 names this MODEL, byte 16 names the same Geometry as MODEL byte 8, byte 24 holds the accepted configuration marker, and byte 40,104 is the canonical true LECMWF flag. All consumed owner records remain live for the call.

Return zero means that all fourteen assignments completed. Return two means that a span, alignment, owner identity, marker or selected source control was refused before a write. Complete mapped storage remains a caller requirement. Only the 56 listed output bytes change. This integer leaf has no stack, allocation, external call or floating-point instruction. It preserves x18 through x30, all vector registers, FPCR, FPSR and errno. Caller-saved integer registers and integer flags are scratch. The same assembled code reads no resolution-dependent dimension.

The joint dimensions check uses genuine four-rank Geometry, MODEL and configuration owners. Two distinct incoming preimages change only these fourteen output words before the separate original and native assignments run. All 34,200,704 complete MODEL bytes per route agree across four ranks and both preimages. Bytes outside the fourteen assignments remain unchanged. Every native and original observation has ABI mask zero and matching immediate raw status. Six pre-write refusals pass on every rank. The original control contains the exact selected source statements and is used only for verification.

This accepts the selected count producer required by [physics dimension initialization](../support/physics_grid_dimensions.md). The total soil variable and flux calculations between and after these source groups, the other SUNDDH branches, the enclosing forecast setup and a complete forecast remain separate. No complete SUNDDH routine replacement or weather calculation is counted here. The failed earlier scalar-prefix attempt remains unaccepted; the successful check uses the genuine completed distributed Geometry without a patched grid.
