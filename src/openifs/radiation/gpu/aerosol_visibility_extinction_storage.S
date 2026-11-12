// Contract: skills/md2fort-gpu/references/openifs/radiation/aerosol_visibility_extinction.md.
/* Source build for the qualified private forecast graph.
 * Contract: skills/md2fort/references/openifs/dynamics/private_forecast_graph_sources.md.
 * Preserve the original interface, ordered arithmetic, and caller-owned storage. */
// Original aerosol_sw_extinction. Coefficients are m2/kg and mixing ratios are kg/kg.
// The caller's g/kg conversion produces km-1 for this visibility diagnostic.
.text
.p2align 4
.macro CALL target
 stp x18,x30,[sp,#-16]!
 bl \target
 ldp x18,x30,[sp],#16
.endm
.global md2asm_shortwave_aerosol_extinction_7358525
.type md2asm_shortwave_aerosol_extinction_7358525,%function
md2asm_shortwave_aerosol_extinction_7358525:
sub sp,sp,#512
stp x29,x30,[sp,#128]
stp x19,x20,[sp,#144]
stp x21,x22,[sp,#160]
stp x23,x24,[sp,#176]
stp x25,x26,[sp,#192]
stp x27,x28,[sp,#208]
mov x29,sp
add x19,sp,#256
stp x0,x1,[x19,#0]
stp x2,x3,[x19,#16]
stp x4,x5,[x19,#32]
stp x6,x7,[x19,#48]
ldr w25,[x0]
ldr w20,[x1]
ldr w21,[x2]
mov x22,x3
ldr w26,[x4]
cmp w25,#24
b.ne .Lae_reject
cmp w20,#1
b.lt .Lae_reject
cmp w21,w25
b.gt .Lae_reject
cmp w26,#10
b.ne .Lae_reject
mov x16,#6912
ldr w9,[x22,x16]
cmp w9,#12
b.ne .Lae_reject
mov x16,#17812
ldr w9,[x22,x16]
cmp w9,#12
b.ne .Lae_reject
mov x16,#17828
ldr w9,[x22,x16]
cmp w9,#1
b.ne .Lae_reject
sub w20,w20,#1
adrp x9,:got:__yomhook_MOD_lhook
ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
ldr w9,[x9]
str w9,[sp,#360]
 mov x16,#11608
 add x0,x22,x16
 mov w1,#1
 bl .Lae_desc
 mov x23,x0
 mov x16,#11672
 add x0,x22,x16
 mov w1,#1
 bl .Lae_desc
 mov x24,x0
 mov x16,#11736
 add x0,x22,x16
 mov w1,#2
 bl .Lae_desc
 mov x27,x0
 mov x16,#12264
 add x0,x22,x16
 mov w1,#3
 bl .Lae_desc
 mov x28,x0
 mov x16,#13736
 add x0,x22,x16
 mov w1,#1
 bl .Lae_desc
 mov x0,x0
 str x0,[sp,#352]
 mov w9,#0
.Lae_validate_classes:
 ldr w10,[x23,w9,uxtw #2]
 cmp w10,#1
 b.lt .Lae_reject
 cmp w10,#3
 b.gt .Lae_reject
 add w9,w9,#1
 cmp w9,#12
 b.lt .Lae_validate_classes
 ldr w9,[sp,#360]
 cbz w9,.Lae_hook0_done
 adr x0,.Lae_hook_name
 adr x1,.Lae_phase0
 add x2,sp,#368
 mov x3,#46
 CALL __yomhook_MOD_dr_hook_default8
.Lae_hook0_done:
// Eight resolved source owners and four integer metadata words.
str x20,[sp]
str x21,[sp,#8]
mov x16,#11808
add x16,x22,x16
ldp x9,x10,[x16]
sub x9,x10,x9
add x9,x9,#1
cmp x9,#1
b.lo .Lae_reject
cmp x9,#4096
b.hi .Lae_reject
str x9,[sp,#16]
mov x16,#12360
add x16,x22,x16
ldp x9,x10,[x16]
sub x9,x10,x9
add x9,x9,#1
cmp x9,#1
b.lo .Lae_reject
cmp x9,#4096
b.hi .Lae_reject
str x9,[sp,#24]
ldr x0,[x19,#40]
ldr x1,[x19,#48]
ldr x2,[x19,#56]
mov x3,x23
mov x4,x24
mov x5,x27
mov x6,x28
ldr x7,[sp,#352]
// The complete storage host preserves x18, so the original push-call macro
// is not used at this new stack-argument boundary.
bl md2asm_gpu_visibility_extinction_host
.Lae_done:
 ldr w9,[sp,#360]
 cbz w9,.Lae_hook1_done
 adr x0,.Lae_hook_name
 adr x1,.Lae_phase1
 add x2,sp,#368
 mov x3,#46
 CALL __yomhook_MOD_dr_hook_default8
.Lae_hook1_done:
ldp x19,x20,[sp,#144]
ldp x21,x22,[sp,#160]
ldp x23,x24,[sp,#176]
ldp x25,x26,[sp,#192]
ldp x27,x28,[sp,#208]
ldp x29,x30,[sp,#128]
add sp,sp,#512
ret
.Lae_reject:
CALL abort
brk #0
.size md2asm_shortwave_aerosol_extinction_7358525,.-md2asm_shortwave_aerosol_extinction_7358525
// Return the first stored descriptor element, retaining the original bias and lower bounds.
.Lae_desc:
ldr x9,[x0]
ldr x10,[x0,#8]
mov w11,#0
.Lae_desc_dimension:
mov w12,#24
umaddl x12,w11,w12,x0
ldr x13,[x12,#40]
ldr x14,[x12,#48]
madd x10,x13,x14,x10
add w11,w11,#1
cmp w11,w1
b.lt .Lae_desc_dimension
ldr x11,[x0,#32]
madd x0,x10,x11,x9
ret
.section .rodata
.Lae_hook_name: .ascii "radiation_aerosol_optics:aerosol_sw_extinction"
.p2align 2
.Lae_phase0: .word 0
.Lae_phase1: .word 1
.section .note.GNU-stack,"",%progbits
