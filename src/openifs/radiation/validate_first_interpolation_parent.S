/* skills/md2asm/references/openifs/radiation/live_radiation_first_interpolation.md.
 * Shared preceding-owner admission for the completed first RI state. */
.arch armv8.2-a
.text
#define MD2ASM_HALO_RELEASE_ENTRY md2asm_validate_first_interpolation_parent
#define MD2ASM_HALO_POINT_VALIDATOR md2asm_validate_first_interpolation_point_setup
#define MD2ASM_HALO_VALIDATE_ONLY 1
#include "shared_live_radiation_halo_release_body.inc.S"
#include "shared_radiation_halo_agreement.inc.S"
.section .note.GNU-stack,"",%progbits
