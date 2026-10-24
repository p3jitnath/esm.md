/* Free the actual ZMU owner after accepted point setup. See skills/md2asm/references/openifs/radiation/live_radiation_setup_through_zmu_retirement.md. */
.arch armv8.2-a
.text
#define MD2ASM_RAD_POINT_ENTRY md2asm_retire_live_radiation_zmu
#define MD2ASM_RAD_RETIRE_ZMU 1
#include "shared_live_radiation_point_release_body.inc.S"
.section .note.GNU-stack,"",%progbits
