/* Release the 13 owners left after source statement 1620. */
.arch armv8.2-a
.text
#define MD2ASM_RAD_POINT_ENTRY md2asm_release_retired_radiation_setup
#define MD2ASM_RAD_STORAGE_ZMU_RETIRED 1
#include "shared_live_radiation_point_release_body.inc.S"
.section .note.GNU-stack,"",%progbits
