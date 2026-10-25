// Contract: skills/md2asm/references/openifs/setup/runtime_field_registry.md.
// Only empty embedded groups select the distinct PTR/DATA assignment child.
#define md2asm_registry_register_surface md2asm_runtime_registry_register_surface
#define md2asm_registry_allocate_field md2asm_registry_allocate_runtime_surface_group
#include "registry_surface_method.S"
