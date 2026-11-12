// Contract: skills/md2fort-gpu/references/openifs/physics/pressure_coordinates.md.
// Selected pressure-coordinate calculations emitted directly as AArch64 source.
.text
.p2align 4
.macro CALL target
 str x18,[sp,#696]
 bl \target
 ldr x18,[sp,#696]
.endm
.global md2asm_ppinit_7358525
.type md2asm_ppinit_7358525,%function
md2asm_ppinit_7358525:
mov x16,sp
sub sp,sp,#4096

str x19,[sp,#608]
str x20,[sp,#616]
str x21,[sp,#624]
str x22,[sp,#632]
str x23,[sp,#640]
str x24,[sp,#648]
str x25,[sp,#656]
str x26,[sp,#664]
str x27,[sp,#672]
str x28,[sp,#680]
str x29,[sp,#688]
str x30,[sp,#704]
str d8,[sp,#712]
str d9,[sp,#720]
str d10,[sp,#728]
str d11,[sp,#736]
str d12,[sp,#744]
str d13,[sp,#752]
str d14,[sp,#760]
str d15,[sp,#768]
add x19,sp,#256
str x0,[x19,#0]
str x1,[x19,#8]
str x2,[x19,#16]
str x3,[x19,#24]
str x4,[x19,#32]
str x5,[x19,#40]
str x6,[x19,#48]
str x7,[x19,#56]
ldr x9,[x16,#0]
str x9,[x19,#64]
ldr x9,[x19,#0]
ldrsw x20,[x9]
cmp x20,#24
b.ne .Lppinit_reject
ldr x9,[x19,#8]
ldrsw x21,[x9]
cmp x21,#1
b.ne .Lppinit_reject
sub x21,x21,#1
ldr x9,[x19,#16]
ldrsw x22,[x9]
cmp x22,#24
b.eq .Lppinit_end_shape
cmp x22,#8
b.ne .Lppinit_reject
.Lppinit_end_shape:
sub x22,x22,#1
ldr x9,[x19,#24]
ldrsw x9,[x9]
cmp x9,#19
b.ne .Lppinit_reject
ldr x9,[x19,#32]
ldrsw x9,[x9]
cmp x9,#4
b.ne .Lppinit_reject
adrp x9,:got:__yomhook_MOD_lhook
ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
ldr w9,[x9]
cbz w9,.Lppinit_hook_skip_0
adr x0,.Lppinit_name
adr x1,.Lphase0
add x2,sp,#784
mov x3,#6
CALL __yomhook_MOD_dr_hook_default8
.Lppinit_hook_skip_0:
mov x0,x19
CALL md2asm_gpu_pressure_coordinates_stage
adrp x9,:got:__yomhook_MOD_lhook
ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
ldr w9,[x9]
cbz w9,.Lppinit_hook_skip_1
adr x0,.Lppinit_name
adr x1,.Lphase1
add x2,sp,#784
mov x3,#6
CALL __yomhook_MOD_dr_hook_default8
.Lppinit_hook_skip_1:
ldr x19,[sp,#608]
ldr x20,[sp,#616]
ldr x21,[sp,#624]
ldr x22,[sp,#632]
ldr x23,[sp,#640]
ldr x24,[sp,#648]
ldr x25,[sp,#656]
ldr x26,[sp,#664]
ldr x27,[sp,#672]
ldr x28,[sp,#680]
ldr x29,[sp,#688]
ldr x30,[sp,#704]
ldr d8,[sp,#712]
ldr d9,[sp,#720]
ldr d10,[sp,#728]
ldr d11,[sp,#736]
ldr d12,[sp,#744]
ldr d13,[sp,#752]
ldr d14,[sp,#760]
ldr d15,[sp,#768]
add sp,sp,#4096
ret
.size md2asm_ppinit_7358525,.-md2asm_ppinit_7358525
.Lppinit_reject:
brk #405
.section .rodata
.balign 8
.Lphase0:.word 0
.Lphase1:.word 1
.Lppinit_name:.ascii "PPINIT"
.section .note.GNU-stack,"",%progbits
