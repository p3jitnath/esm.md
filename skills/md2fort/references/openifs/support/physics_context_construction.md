# Physics Context Construction And Release

## Purpose

These two assembly entries create and release the storage used by one physics call. They do not calculate a weather update. Existing geometry, configuration and input field objects must already exist.

## Interface

`md2asm_physics_storage_initialise` receives a pointer to 53 input addresses in x0 and four scratch addresses in x1. It returns a new 119,384-byte context in x0. Every borrowed input must remain valid until finish. The Arm 64-bit procedure interface is used, including preserved registers, a 16-byte-aligned stack, the floating-point control and status registers, and errno.

`md2asm_physics_storage_finish` receives the context in x0 after its block views have been released. It frees each owned object once. It does not free borrowed input data.

## Ownership And Order

Construction copies the complete field-variable record and separately copies its 18 allocated global metadata arrays. Their complete associated descriptors and elements are retained. Private pointer arrays remain borrowed aliases until the begin-block service replaces them. The recursive source types contain no further allocated components in those global elements.

Two state records borrow input fields and six state records own their source-selected temporary fields. The empty physics-record array has a complete allocated-empty descriptor. Dimension, surface, auxiliary, radiation, flux, diagnostic, surface-diagnostic, auxiliary-local, surface-local, key and perturbation-local records are created in source order through direct assembly children. Release follows the original state, physics-array, work-record and global-array cleanup order.

The context metadata has an explicit zero representation before source-defined assignments. Unassigned private source words are not numerical outputs. Newly allocated numerical payloads are left for their producers. Complete associated descriptors, all source-defined metadata and every produced numerical owner remain in the forecast comparison.

## Bounds And Dependencies

The supported incoming global arrays are allocated, contiguous and one-based. Their element size is 728 bytes. Counts and byte products must fit the supported 64-bit allocation size. Parent record offsets, array descriptor layouts and all 233 work-field interfaces are retained in the typed layout records beside the local verifier.

The implementation uses calloc, malloc, memcpy, free, the operating-system errno accessor and a nonreturning allocation-failure exit. It calls direct assembly storage children. It does not call an OpenIFS Fortran procedure or type constructor. Receiving existing model objects remains a startup dependency, so these entries do not establish a complete autonomous forecast.

## Acceptance

Two source-derived cases cover allocated-empty global arrays and mixed global arrays with active states. A third focused case uses different activity flags, null incoming ozone fields and distinct field addresses for the two time levels. The declared mask order is ozone, water vapour, aerosol, cloud liquid, cloud ice, rain, snow and turbulent kinetic energy. They compare complete source-defined metadata, all deep copies, borrowed pointer relationships, 233 work-field headers and nine explicit surface-group addresses. The checks report zero differing defined bytes. Four accepted native interface calls from the first two cases are reused, and the focused case adds two successful native interface calls. The original control's platform-register difference during release is recorded separately. An independent source, ownership and interface review passes. The selected complete forecast check passes.

The lifetime counter returns successful construction at index 0 and successful release at index 1. A complete forecast must have equal positive counts, with no constructor-only calls, and must preserve the complete final-owner and saved-file comparison.

The [complete forecast check](../../../../../src/openifs/README.md#verification) passes for the selected route. Its declared upstream data and branch limits remain in force.

The [address services](physics_context_address_services.md) select shared records. The [block services](physics_context_block_services.md) prepare and release each physics block.
