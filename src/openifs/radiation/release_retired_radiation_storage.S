/* Release the eight storage owners left after ZMU retirement. */
.arch armv8.2-a
.text
#define MD2ASM_RAD_RELEASE_ENTRY md2asm_release_retired_radiation_transform_storage
#define MD2ASM_RAD_STORAGE_ZMU_RETIRED 1
#include "shared_radiation_storage_release_body.inc.S"
.section .note.GNU-stack,"",%progbits
