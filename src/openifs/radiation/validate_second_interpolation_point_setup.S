/* Source interfaces, bounds and source-order scope: skills/md2asm/references/openifs/radiation/live_radiation_second_interpolation.md. */
.arch armv8.2-a
.text
#define MD2ASM_RAD_POINT_ENTRY md2asm_validate_second_interpolation_point_setup
#define MD2ASM_RAD_STORAGE_ZMU_RETIRED 1
#define MD2ASM_RAD_STORAGE_RETIRED_MAGIC 0x52414453544f5235
#define MD2ASM_RAD_VALIDATE_ONLY 1
#include "shared_live_radiation_point_release_body.inc.S"
.section .note.GNU-stack,"",%progbits
