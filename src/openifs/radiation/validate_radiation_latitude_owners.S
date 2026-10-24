.arch armv8.2-a
.text
.p2align 4
.global md2asm_validate_radiation_latitude_owners
.type md2asm_validate_radiation_latitude_owners,%function
md2asm_validate_radiation_latitude_owners:
#define MD2ASM_LATITUDE_PREFLIGHT 1
#include "shared_radiation_latitude_release_admission.inc.S"
.Lrrli_released_empty:
 mov w0,#0
 ret
.Lrrli_release_bad:
 mov w0,#2
 ret
.size md2asm_validate_radiation_latitude_owners,.-md2asm_validate_radiation_latitude_owners
.section .note.GNU-stack,"",%progbits
