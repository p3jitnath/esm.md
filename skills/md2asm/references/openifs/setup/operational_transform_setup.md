# Operational Transform Setup

This utility prepares the permitted ectrans and FIAT transform libraries for the existing 9 km grid. Assembly owns its configuration, control records, calls and two region arrays. The native process uses no original OpenIFS routine or harness. The libraries own their internal transform storage and numerical method.

## Interface And Storage

The application binary interface (ABI) uses x0 through x3 for `md2asm_initialize_operational_transform_context(geometry, control, text, bytes)`. Geometry is a writable 17,096-byte record and control is a writable 304-byte record. Both need eight-byte alignment. Text is a complete mapped ASCII configuration buffer. All records and pointed arrays are mapped and disjoint. Return status in w0 is zero for success, one for allocation failure, two for unsupported input and three for an unexpected partition shape.

| Geometry input | Byte offset | Required value |
| --- | ---: | --- |
| Truncation, which limits the spectral wave count | 5172 | 1279 |
| Gaussian latitude-row count | 4872 | 2560 |
| Contiguous int32 longitude-row descriptor | 7640 | Halo bounds −1 through 2562 |
| Active longitude rows | Descriptor indices 1 through 2560 | Actual reduced-grid counts |

A reduced grid has different longitude counts on different latitude rows. The active counts are positive, symmetric about the equator, at most 5,136 and total 6,599,680. Four halo words outside the active range stay unchanged. The stored lower bound determines the first active address. The new resolution entry has the same four arguments and requires these dimensions before calling the library.

Control fields, public arguments and release rules follow the [owned transform contract](owned_transform_setup_contract.md). Use the selected serial process and region controls, Earth radius 6,371,229 m and split-storage flag one. Both region pointers start null. Initialise the public message library before this utility. The resolution handle is written at Geometry byte 5168. Release region metadata with `md2asm_release_transform_environment_metadata`, then finish the public context once with `md2asm_finish_external_transform_context`.

## Configuration And Calls

The new leaf `md2asm_operational_transform_configuration_group(text, bytes, selector)` takes x0 through x2, with selector one. It returns zero for supported input and two otherwise, without writing memory or using the stack. It selects the first uppercase NAMTRANS marker under the declared first-ten-column search rules. It accepts an empty group or false assignments to LUSEFLT and LFFTW. Member names and FALSE or .FALSE. values are case-insensitive. Spaces, line breaks, commas and comments are bounded by the supplied text size. A malformed or unsupported first group rejects immediately.

The actual file contains both false assignments before a later empty NAMTRANS group. The accepted environment phase still reads NAMTRANS0. The new main and resolution entries retain the original SUTRANS0/SUTRANS public-call order and active-row section. Truncation 1279 selects LUSEFLT false, LUSERPNM and LKEEPRPNM true, and LFFTW false. External floating-point flags and system error values propagate naturally.

Main and resolution frames are 80 and 384 bytes. The maximum nested assembly stack is 640 bytes, excluding library stack. Every frame is 16-byte aligned. Preserve x18, all required saved registers and the floating-point control register. No new floating-point arithmetic is introduced. Existing smaller-grid entries remain unchanged.

## Accepted Checks And Limits

Separate original and assembly-only processes pass complete setup and release on the actual configuration and row counts. All 28,032 packet bytes agree after three declared address correspondences, with owner payloads checked before addresses. The packet includes complete control and geometry records, both region payloads, all halo-row input, immediate status and released control. All eight native ABI checks pass. Two wrong-dimension refusals and four configuration cases pass before library setup. Public inquiries return 819,840 complex spectral coefficients and 6,599,680 grid points, consistent with the independently checked input dimensions and complete row list.

The native executable uses only the allowed public libraries and their dependencies. Private library arrays are not independently verified here. This qualifies transform setup at these inputs. Complete physical geometry, initial model state and an operational forecast require their own checks.
