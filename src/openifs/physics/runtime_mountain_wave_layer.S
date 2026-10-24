/* Runtime GWDRAG_LAYER uses complete accepted GWDRAG children.
 * Contract: skills/md2asm/references/openifs/physics/runtime_mountain_wave_layer.md.
 * Original8 ordinary addresses remain in x0..x7. A ninth stack address
 * names context64, whose initialized physical520 owner has exact aliases.
 * P1..128 and L6..512;8192-byte frame; no public write on new refusals.
 * Preserve x18, saved registers and original field bounds.
 */
.text
.p2align 4
.macro CALL target
 str x18,[sp,#3024]
 bl \target
 ldr x18,[sp,#3024]
.endm
.global md2asm_runtime_mountain_wave_layer
.type md2asm_runtime_mountain_wave_layer,%function
md2asm_runtime_mountain_wave_layer:
 mov x16,sp
 mov x12,x3
 cbz x12,.Lruntime_refuse
 tst x12,#7
 b.ne .Lruntime_refuse
 ldr w9,[x12,#12]
 sub w10,w9,#1
 cmp w10,#127
 b.hi .Lruntime_refuse
 ldr w10,[x12,#48]
 sub w11,w10,#6
 cmp w11,#506
 b.hi .Lruntime_refuse
 ldp w11,w14,[x12]
 cmp w11,#1
 b.lt .Lruntime_refuse
 add w15,w9,#1
 cmp w11,w15
 b.gt .Lruntime_refuse
 sub w11,w11,#1
 cmp w14,w11
 b.lt .Lruntime_refuse
 cmp w14,w9
 b.gt .Lruntime_refuse
 ldr x13,[x16,#0]
 cbz x13,.Lruntime_refuse
 tst x13,#7
 b.ne .Lruntime_refuse
 adds x11,x13,#64
 b.cs .Lruntime_refuse
 ldr x11,[x13,#16]
 cbz x11,.Lruntime_refuse
 tst x11,#7
 b.ne .Lruntime_refuse
 ldr x14,[x11,#8]
 cbnz x14,.Lruntime_refuse
 ldr x11,[x11]
 cbz x11,.Lruntime_refuse
 tst x11,#3
 b.ne .Lruntime_refuse
 ldr w11,[x11]
 cbnz w11,.Lruntime_refuse
 ldr x11,[x13,#8]
 cbz x11,.Lruntime_refuse
 tst x11,#3
 b.ne .Lruntime_refuse
 ldr x11,[x13]
 cbz x11,.Lruntime_refuse
 tst x11,#7
 b.ne .Lruntime_refuse
 adrp x14,:got:md2asm_owned_initial_physical_constants
 ldr x14,[x14,:got_lo12:md2asm_owned_initial_physical_constants]
 cmp x11,x14
 b.ne .Lruntime_refuse
 ldr w14,[x11,#512]
 cmp w14,#1
 b.ne .Lruntime_refuse
 sub sp,sp,#8192
 str x29,[sp,#800]
 str x30,[sp,#808]
 mov x29,sp
 str x19,[sp,#816]
 str x20,[sp,#824]
 str x21,[sp,#832]
 str x22,[sp,#840]
 str x23,[sp,#848]
 str x24,[sp,#856]
 str x25,[sp,#864]
 str x26,[sp,#872]
 str x27,[sp,#880]
 str x28,[sp,#888]
 add x19,sp,#1024
 str x13,[x19,#280]
 str x0,[x19,#0]
 str x1,[x19,#8]
 str x2,[x19,#16]
 str x3,[x19,#24]
 str x4,[x19,#32]
 str x5,[x19,#40]
 str x6,[x19,#48]
 str x7,[x19,#56]
 mrs x9,fpcr
 cbnz x9,.Ldispatch_reject
 ldr x21,[x19,#24]
 /* Live dimensions were checked before this frame was acquired. */
#include "shared_mountain_wave_layer_arguments.inc.S"
 /* GWSETUP forms these three source constants even for an empty interval.
  * The qualified child returns early, so this enclosing source route retains
  * those original scalar operations and their natural exception flags. */
 ldr x9,[x19,#24]
 ldp w10,w11,[x9]
 cmp w10,w11
 b.le .Lempty_source_constants_done
 ldr x9,[x19,#280]
 ldr x9,[x9]
 ldr d2,[x9,#112]
 ldr d3,[x9,#184]
 ldr d4,[x9,#200]
 fmov d1,#1.0
 fdiv d0,d1,d3
 fmul d0,d2,d2
 fdiv d0,d0,d4
 fadd d0,d2,d2
 fdiv d0,d1,d0
.Lempty_source_constants_done:
 mov w0,#0
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
 ret
.size md2asm_runtime_mountain_wave_layer,.-md2asm_runtime_mountain_wave_layer
// Read the first declared element. A null zero-size view stays null.
.Ldispatch_first:
ldr x8,[x0]
cbnz x8,1f
mov x0,#0
ret
1:
ldr x9,[x0,#8]
ldrb w10,[x0,#28]
ldr x11,[x0,#40]
ldr x12,[x0,#48]
madd x9,x11,x12,x9
cmp w10,#1
b.eq .Ldispatch_first_done
ldr x11,[x0,#64]
ldr x12,[x0,#72]
cmp x1,#0
csel x12,x12,x1,eq
madd x9,x11,x12,x9
cmp w10,#2
b.eq .Ldispatch_first_done
ldr x11,[x0,#88]
ldr x12,[x0,#96]
cmp x2,#0
csel x12,x12,x2,eq
madd x9,x11,x12,x9
cmp w10,#3
b.eq .Ldispatch_first_done
ldr x11,[x0,#112]
ldr x12,[x0,#120]
madd x9,x11,x12,x9
.Ldispatch_first_done:
ldr x11,[x0,#32]
madd x0,x9,x11,x8
ret
.Ldispatch_reject:
CALL abort
brk #0
 .Lruntime_refuse:
 mov w0,#2
 ret
.section .rodata
.p2align 2
.Ldispatch_phase0:.word 0
.Ldispatch_phase1:.word 1
.Lgwdrag_layer_name:.ascii "GWDRAG_LAYER"
.Lradflux_layer_name:.ascii "RADFLUX_LAYER"
.Lconvection_layer_name:.ascii "CONVECTION_LAYER"
.Lcloud_layer_name:.ascii "CLOUD_LAYER"
.section .note.GNU-stack,"",%progbits
