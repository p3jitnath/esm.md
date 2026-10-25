# Runtime Field Registry Release

A registry records where model fields are stored. Its metadata belongs to the registry, while most physical arrays belong to other model owners. This assembly entry releases a complete successful [runtime registry](runtime_field_registry.md) after all private clones and field consumers have finished.

## Interface And Ownership

`md2asm_release_runtime_field_registry` receives FIELDS in x0 and its byte capacity in x1. FIELDS has 529,288 mapped bytes and eight-byte alignment. Its owned VARIABLE record has 72,696 bytes, and its surface-variable record has 160,800 bytes. All complete metadata records and owned allocations must be mapped, nonwrapping and source-disjoint. A null FIELDS address is a no-op. Return w0 zero means success. Return two refuses an invalid top-level range or differing shared/private array owner before any write.

The call accepts a completed successful construction. Cleanup after partial construction remains a separate enclosing error path. The original registry and all private clones must have separate lifetimes, and no clone may still use its field records. Each of the eighteen private array bases must agree with its shared base when this entry starts.

The source tables identify 105 scalar variables, eighteen variable-array families, 284 surface-variable declarations and nineteen embedded surface groups. Each variable owns up to six FIELD metadata records. An array descriptor stores its address, type, bounds and stride. Rank means the number of array dimensions. FIELD records have `112+72*rank` bytes, and VARIABLE records have `224+168*rank` bytes. Their existing descriptors determine the number of array elements.

The FIELD ownership flag separates allocated temporary data from borrowed physical arrays. Ordinary owned fields have matching PTR and DATA bases. The accepted runtime surface-group constructor can instead return two distinct complete owned allocations. This entry releases both once in that specific form. A distinct interior or borrowed PTR is outside the contract. The original Fortran FIELD finalizer releases DATA and nullifies PTR, so ownership of the extra native allocation comes from the explicit runtime-group contract.

Release processes surface variables and groups, then the main variables and their arrays. Embedded group records remain part of their enclosing surface record. Borrowed numerical pointers are opaque and are neither read nor freed. After release, only the pointer words at FIELDS bytes 529,272 and 529,280 become zero. Other FIELDS bytes remain unchanged. A second release is a no-op.

The application binary interface, or ABI, preserves x18, x19 through x29, the required halves of v8 through v15, sixteen-byte stack alignment, floating-point control and status, and errno. The largest nested assembly frame use is 368 bytes. Only public C `free` and the errno-address service are called. The entry uses no floating-point arithmetic, original OpenIFS function, constructor or method table.

## Shared Tables And Checks

The existing field-variable, registry-registration and surface-registration sources provide six unchanged read-only tables. `MD2ASM_PUBLISH_REGISTRY_CLEANUP_LAYOUTS` exposes their addresses beside the normal entries. `MD2ASM_REGISTRY_LAYOUT_ONLY` assembles only those tables. Every complete default object remains identical, and the table-only objects contain no instructions or relocations. No table is maintained as a second copy of the source layout.

The bounded check rebuilds only declared typed pointers in two previously accepted native metadata graphs, with one and seven blocks. It invokes no original registry constructor or numerical calculation. The new release frees all 4,366 expected allocations exactly once and checks every trailing owner guard. Both graphs include ten independently owned PTR/DATA pairs. All eight pre-write refusals, two successful releases, two repeated releases and the null call preserve the required registers, floating-point state and errno.

Borrowed pointer slots use a protected opaque buffer in this retirement-only check. Complete FIELDS preservation is checked in process, while the final two pointers become zero. The allocation recorder validates every free and then calls real C `free`. A separate independent review confirms the default library bindings, full instructions, exact tables and ownership rules. Newly rebuilt complete memory images and individual free events are not separately archived.

This result covers successful-registry retirement and its declared ownership rules. Actual full-grid registry construction, partial-failure cleanup, complete physics calls and forecast acceptance remain open. Existing numerical and physical checks are reused.
