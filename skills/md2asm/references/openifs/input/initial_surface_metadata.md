# Direct Surface Metadata Readers

This component replaces all five local typed Fortran metadata getters in the selected complete surface startup route. It changes no physics, default choice, field map or numerical child. The existing original-interface bridges and accepted numerical stages remain separate and retain their verified operation order. Its original source and independent controls remain separate.

## Source Objects And Reads

The callers supply mapped original GNU12 geometry, surface, physics, coupling and model objects. Their precise offsets come from original typed `C_LOC` fixtures and true allocation-header records, retained locally. These are fixed original layouts, not expanded field views. Pointer and field descriptors must represent the original contiguous allocations. Each top-level array of field metadata retains its original one-based allocation bounds and is consumed from its first stored element. Vegetation tables and nested value, identifier and request arrays instead use their explicitly checked lower bounds. The reads use the actual live addresses, counts, lower and upper bounds, field identifiers, request flags and raw default constants. They do not substitute captured numerical outputs or invent starting values.

| Direct reader | Read-only source | Complete output bytes |
| --- | --- | ---: |
| `surface_startup_context.S` | Selected startup flags, geometry counts and three model component addresses | 64 |
| `surface_conversion_configuration.S` | Live physics constants and bounded vegetation tables | 2304 |
| `surface_owner_metadata.S` | Five complete original state-allocation descriptors | 512 |
| `surface_default_metadata.S` | All 33 source groups and their requested default values | 99904 |
| `surface_initial_context.S` | Source-order file requests and their checked model destinations | 2592 |

The default table has 64 owner rows of three 64-bit words and 4096 assignment rows of three words. Its final 64 bytes give status, owner count, assignment count, row count, block count and complete owner bytes. A two-dimensional metadata record has 64 bytes. A layered record has 288 bytes and contains the original allocation descriptors for identifiers, values and request flags. A true GNU12 allocation descriptor starts its dimension records at byte 40, with 24 bytes per dimension. The original typed fixtures independently establish every field offset used here.

Every default group retains the original source order. Only request flag minus one selects a default constant. A layered default reads its value only after that layer selects it, so an unallocated unused default table remains unused. The 47 fixed and five layered file requests must match the frozen identities and destination positions exactly. Only the first stored snow-layer identity and flag select each layered snow field, as in the original source. Unsupported requests or destinations return metadata status two, and the bridge stops before loading. Other metadata bytes after rejection are not consumed and are outside the error interface.

The vegetation reader accepts original contiguous allocations whose bounds contain indices zero through the supported maximum, from zero to 127. It preserves the raw bits of all copied values, including signed zeros and NaN payloads. It copies no entry beyond the consumed range. The descriptor reader checks every complete owner dimension and preserves the original allocated capacity. No reader examines a stored forecast field value or writes any input object.

## ABI And Remaining Boundary

The application binary interface, or ABI, retains each typed getter's pointer arguments, with the direct entry names ending in `_direct_`. The three short readers use no stack. The default reader uses a 192-byte aligned frame and the combined request reader uses an 800-byte aligned frame. All preserve `x18`, the Arm saved integer registers and all vector registers. Only ordinary integer instructions read and copy metadata, so FPCR, FPSR and `errno` remain unchanged.

The original-interface bridge copies differ only at their metadata call targets. All numerical objects and reporting code are unchanged. The linked component needs only the declared ecCodes C file-format library and C system services. It has no typed Fortran metadata or original numerical call. Original global names in the dynamic interface identify input data only. Model construction and other forecast routes are still outside this component, so it does not establish complete autonomous forecasting.

## Checks

The original typed layout fixtures cover all 33 surface groups and both field-metadata record types. Five startup contexts, six vegetation configurations and five complete-owner contexts agree with original typed access. The actual ten-owner object also gives exact complete default, owner, configuration and branch metadata. Three late default rejections and three request or destination rejections cover consumed-buffer and index failures. The selected layered signed-zero default and unallocated unused default tables also agree.

One combined actual startup replay passes three seeded Arm ABI and status cases with all five readers linked. Every one of 7,149,696 bytes in ten returned owners matches the original captured startup, including all 306 defaults and complete padding. Both native route counters are positive. The actual FPCR zero, FPSR sixteen and errno two match the source case. Accepted numerical and independent physical checks are reused. Independent source review and the complete native forecast pass. All 685 final owners and ten saved files match exactly. Original initialized objects remain explicit inputs.
