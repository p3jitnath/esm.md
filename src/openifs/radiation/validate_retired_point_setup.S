.arch armv8.2-a
.text
#define MD2ASM_RAD_POINT_ENTRY md2asm_validate_retired_point_setup
#define MD2ASM_RAD_STORAGE_ZMU_RETIRED 1
#define MD2ASM_RAD_STORAGE_RETIRED_MAGIC 0x52414453544f5232
#define MD2ASM_RAD_VALIDATE_ONLY 1
#include "shared_live_radiation_point_release_body.inc.S"
.section .note.GNU-stack,"",%progbits
