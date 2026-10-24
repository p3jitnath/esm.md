/* skills/md2asm/references/openifs/radiation/live_radiation_first_interpolation.md.
 * Shared preceding-owner admission for the completed first RI state. */
.arch armv8.2-a
.text
#define MD2ASM_RAD_POINT_ENTRY md2asm_validate_first_interpolation_point_setup
#define MD2ASM_RAD_STORAGE_ZMU_RETIRED 1
#define MD2ASM_RAD_STORAGE_RETIRED_MAGIC 0x52414453544f5234
#define MD2ASM_RAD_VALIDATE_ONLY 1
#include "shared_live_radiation_point_release_body.inc.S"
.section .note.GNU-stack,"",%progbits
