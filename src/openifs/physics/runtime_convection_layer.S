/* Contract: skills/md2asm/references/openifs/physics/runtime_convection_layer.md.
 * Original17 typed addresses; complete numerical children remain unchanged. */
.arch armv8.2-a
.text
.p2align 4
.macro CALL target
 str x18,[sp,#3024]
 bl \target
 ldr x18,[sp,#3024]
.endm
#define MD2ASM_RUNTIME_OWNED_CONVECTION 1
#include "shared_convection_layer_arguments.inc.S"
#include "shared_physics_layer_first_address.inc.S"
.Ldispatch_reject:
 ldr x19,[sp,#816]
 ldr x20,[sp,#824]
 ldr x21,[sp,#832]
 ldr x22,[sp,#840]
 ldr x23,[sp,#848]
 ldr x24,[sp,#856]
 ldr x25,[sp,#864]
 ldr x26,[sp,#872]
 ldr x27,[sp,#880]
 ldr x28,[sp,#888]
 ldr x29,[sp,#800]
 ldr x30,[sp,#808]
 add sp,sp,#8192
 mov w0,#2
 ret
.section .rodata
.p2align 2
.Ldispatch_phase0:.word 0
.Ldispatch_phase1:.word 1
.Lconvection_layer_name:.ascii "CONVECTION_LAYER"
.section .note.GNU-stack,"",%progbits
