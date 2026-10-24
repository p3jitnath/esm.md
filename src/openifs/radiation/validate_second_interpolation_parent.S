/* Source interfaces, bounds and source-order scope: skills/md2asm/references/openifs/radiation/live_radiation_second_interpolation.md. */
.arch armv8.2-a
.text
#define MD2ASM_HALO_RELEASE_ENTRY md2asm_validate_second_interpolation_parent
#define MD2ASM_HALO_POINT_VALIDATOR md2asm_validate_second_interpolation_point_setup
#define MD2ASM_HALO_VALIDATE_ONLY 1
#include "shared_live_radiation_halo_release_body.inc.S"
#include "shared_radiation_halo_agreement.inc.S"
.section .note.GNU-stack,"",%progbits
