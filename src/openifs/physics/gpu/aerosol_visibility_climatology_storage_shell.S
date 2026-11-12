// Contract: skills/md2fort-gpu/references/openifs/physics/aerosol_visibility_climatology.md.
/* Source build for the qualified private forecast graph.
 * Contract: skills/md2fort/references/openifs/dynamics/private_forecast_graph_sources.md.
 * Preserve the original interface, ordered arithmetic, and caller-owned storage. */
// Direct aerosol climatology, source RADACA. The retained shared qualification is reused.
// Original MACC mass output is kg/m2. The six legacy aerosol outputs are optical depths.
.text
.p2align 4
.macro CALL target
 stp x18,x30,[sp,#-16]!
 bl \target
 ldp x18,x30,[sp],#16
.endm
.global md2asm_aerosol_visibility_climatology_7358525
.type md2asm_aerosol_visibility_climatology_7358525,%function
md2asm_aerosol_visibility_climatology_7358525:
sub sp,sp,#4096
stp x29,x30,[sp,#0]
stp x19,x20,[sp,#16]
stp x21,x22,[sp,#32]
stp x23,x24,[sp,#48]
stp x25,x26,[sp,#64]
stp x27,x28,[sp,#80]
str x18,[sp,#96]
mov x29,sp
add x19,x29,#256
stp x0,x1,[x19,#0]
stp x2,x3,[x19,#16]
stp x4,x5,[x19,#32]
stp x6,x7,[x19,#48]
add x16,x29,#4096
mov w9,#8
.Lsave_args:
sub w10,w9,#8
ldr x11,[x16,w10,uxtw #3]
str x11,[x19,w9,uxtw #3]
add w9,w9,#1
cmp w9,#23
b.lt .Lsave_args
mrs x9,fpcr
cbnz x9,.Lreject
ldr x8,[x19,#40]
ldr w25,[x8]
ldr x8,[x19,#48]
ldr w26,[x8]
cmp w25,#24
b.ne .Lreject
cmp w26,#19
b.ne .Lreject
mov w27,w25
mov w28,w25
ldr x8,[x19,#24]
ldr w9,[x8]
sub w9,w9,#1
str w9,[x29,#480]
ldr x8,[x19,#32]
ldr w9,[x8]
sub w9,w9,#1
str w9,[x29,#484]
ldr w9,[x29,#480]
ldr w10,[x29,#484]
cmp w9,#0
b.lt .Lreject
cmp w10,w25
b.ge .Lreject
cmp w10,w9
b.lt .Lreject
ldr x8,[x19,#8]
ldr w9,[x8,#180]
cmp w9,#1
b.ne .Lreject
ldr x8,[x19,#8]
ldr w9,[x8,#184]
cmp w9,#61
b.ne .Lreject
ldr x8,[x19,#8]
ldr w9,[x8,#188]
cmp w9,#120
b.ne .Lreject
ldr x8,[x19,#8]
ldr w9,[x8,#196]
cmp w9,#12
b.ne .Lreject
ldr x8,[x19,#8]
ldr w9,[x8,#420]
cmp w9,#0
b.ne .Lreject
ldr x8,[x19,#8]
ldr w9,[x8,#424]
cmp w9,#1
b.ne .Lreject
ldr x8,[x19,#8]
ldr w9,[x8,#484]
cmp w9,#0
b.ne .Lreject
adrp x9,:got:__yomcst_MOD_rpi
ldr x9,[x9,:got_lo12:__yomcst_MOD_rpi]
ldr d0,[x9]
str d0,[x29,#544]
adrp x9,:got:__yomcst_MOD_rg
ldr x9,[x9,:got_lo12:__yomcst_MOD_rg]
ldr d0,[x9]
str d0,[x29,#552]
ldr x8,[x19,#0]
ldr d0,[x8,#4184]
str d0,[x29,#560]
ldr x8,[x19,#16]
mov x9,#35632
add x8,x8,x9
ldr d0,[x8]
str d0,[x29,#568]
ldr x0,[x19,#0]
add x0,x0,#0
bl .Lprofile
str x0,[x29,#3568]
ldr x0,[x19,#0]
add x0,x0,#64
bl .Lprofile
str x0,[x29,#3576]
ldr x0,[x19,#0]
add x0,x0,#128
bl .Lprofile
str x0,[x29,#3584]
ldr x0,[x19,#0]
add x0,x0,#192
bl .Lprofile
str x0,[x29,#3592]
ldr x0,[x19,#8]
add x0,x0,#1480
bl .Lprofile
str x0,[x29,#3600]
ldr x0,[x19,#8]
add x0,x0,#1544
bl .Lprofile
str x0,[x29,#3608]
ldr x0,[x19,#8]
add x0,x0,#1608
bl .Lprofile
str x0,[x29,#3616]
ldr x0,[x19,#8]
add x0,x0,#1672
bl .Lprofile
str x0,[x29,#3624]
ldr x0,[x19,#8]
add x0,x0,#1736
bl .Lprofile
str x0,[x29,#3632]
ldr x9,[x19,#16]
mov x10,#35632
add x9,x9,x10
mov x10,#744
add x9,x9,x10
str x9,[x29,#3440]
ldr x9,[x19,#16]
mov x10,#35632
add x9,x9,x10
mov x10,#27240
add x9,x9,x10
str x9,[x29,#3448]
ldr x9,[x19,#16]
mov x10,#35632
add x9,x9,x10
mov x10,#53736
add x9,x9,x10
str x9,[x29,#3456]
ldr x9,[x19,#16]
mov x10,#35632
add x9,x9,x10
movz x10,#14696
movk x10,#1,lsl #16
add x9,x9,x10
str x9,[x29,#3464]
ldr x9,[x19,#16]
mov x10,#35632
add x9,x9,x10
movz x10,#41192
movk x10,#1,lsl #16
add x9,x9,x10
str x9,[x29,#3472]
ldr x0,[x19,#16]
movz x9,#38168
movk x9,#2,lsl #16
add x0,x0,x9
add x0,x0,#1224
bl .Lclimate
str x0,[x29,#3480]
ldr x0,[x19,#16]
movz x9,#38168
movk x9,#2,lsl #16
add x0,x0,x9
add x0,x0,#1312
bl .Lclimate
str x0,[x29,#3488]
ldr x0,[x19,#16]
movz x9,#38168
movk x9,#2,lsl #16
add x0,x0,x9
add x0,x0,#1624
bl .Lclimate
str x0,[x29,#3496]
ldr x0,[x19,#16]
movz x9,#38168
movk x9,#2,lsl #16
add x0,x0,x9
add x0,x0,#1712
bl .Lclimate
str x0,[x29,#3504]
ldr x0,[x19,#16]
movz x9,#38168
movk x9,#2,lsl #16
add x0,x0,x9
add x0,x0,#2136
bl .Lclimate
str x0,[x29,#3512]
ldr x0,[x19,#16]
movz x9,#38168
movk x9,#2,lsl #16
add x0,x0,x9
add x0,x0,#2224
bl .Lclimate
str x0,[x29,#3520]
ldr x0,[x19,#16]
movz x9,#38168
movk x9,#2,lsl #16
add x0,x0,x9
add x0,x0,#2312
bl .Lclimate
str x0,[x29,#3528]
ldr x0,[x19,#16]
movz x9,#38168
movk x9,#2,lsl #16
add x0,x0,x9
add x0,x0,#2736
bl .Lclimate
str x0,[x29,#3536]
ldr x0,[x19,#16]
movz x9,#38168
movk x9,#2,lsl #16
add x0,x0,x9
add x0,x0,#2824
bl .Lclimate
str x0,[x29,#3544]
ldr x0,[x19,#16]
movz x9,#38168
movk x9,#2,lsl #16
add x0,x0,x9
add x0,x0,#2912
bl .Lclimate
str x0,[x29,#3552]
ldr x0,[x19,#16]
movz x9,#38168
movk x9,#2,lsl #16
add x0,x0,x9
add x0,x0,#3112
bl .Lclimate
str x0,[x29,#3560]
adrp x9,:got:__yomhook_MOD_lhook
ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
ldr w9,[x9]
str w9,[x29,#3992]
ldr w9,[x29,#3992]
cbz w9,.Lhook0_done
adr x0,.Lhook_name
adr x1,.Lhook_phase0
add x2,x29,#4000
mov x3,#6
CALL __yomhook_MOD_dr_hook_default8
.Lhook0_done:
sub sp,sp,#8,lsl #12
mov x20,sp
mov x0,x19
CALL md2asm_gpu_radaca_stage
ldr w9,[x29,#3992]
cbz w9,.Lhook1_done
adr x0,.Lhook_name
adr x1,.Lhook_phase1
add x2,x29,#4000
mov x3,#6
CALL __yomhook_MOD_dr_hook_default8
.Lhook1_done:
mov sp,x29
ldr x18,[sp,#96]
ldp x19,x20,[sp,#16]
ldp x21,x22,[sp,#32]
ldp x23,x24,[sp,#48]
ldp x25,x26,[sp,#64]
ldp x27,x28,[sp,#80]
ldp x29,x30,[sp,#0]
add sp,sp,#4096
ret
.Lreject:
CALL abort
brk #0
.size md2asm_aerosol_visibility_climatology_7358525,.-md2asm_aerosol_visibility_climatology_7358525
.Lprofile:
ldr x9,[x0]
cbz x9,.Lreject
tst x9,#7
b.ne .Lreject
ldrb w10,[x0,#28]
cmp w10,#1
b.ne .Lreject
ldr x10,[x0,#32]
cmp x10,#8
b.ne .Lreject
ldr x10,[x0,#40]
cmp x10,#1
b.ne .Lreject
ldr x10,[x0,#48]
cmp x10,#1
b.ne .Lreject
ldr x10,[x0,#56]
cmp x10,#20
b.ne .Lreject
ldr x10,[x0,#8]
add x10,x10,#1
add x0,x9,x10,lsl #3
ret
.Lclimate:
ldr x9,[x0]
cbz x9,.Lreject
tst x9,#7
b.ne .Lreject
ldrb w10,[x0,#28]
cmp w10,#2
b.ne .Lreject
ldr x10,[x0,#32]
cmp x10,#8
b.ne .Lreject
ldr x10,[x0,#40]
cmp x10,#1
b.ne .Lreject
ldr x10,[x0,#48]
cmp x10,#1
b.ne .Lreject
ldr x10,[x0,#56]
cmp x10,#120
b.ne .Lreject
ldr x10,[x0,#64]
cmp x10,#120
b.ne .Lreject
ldr x10,[x0,#72]
cmp x10,#1
b.ne .Lreject
ldr x10,[x0,#80]
cmp x10,#61
b.ne .Lreject
ldr x10,[x0,#8]
add x10,x10,#121
add x0,x9,x10,lsl #3
ret
 .global md2asm_aerosol_climatology_child_count_get
md2asm_aerosol_climatology_child_count_get:
cmp w0,#3
b.hs .Lcountzero
adrp x9,.Lcounts
add x9,x9,:lo12:.Lcounts
ldr x0,[x9,w0,uxtw #3]
ret
.Lcountzero:
mov x0,#0
ret
.section .rodata
.p2align 3
.Lreals:
.double 90.0,180.0,999.0,64.0,1000.0,1e6
.Lhook_name: .ascii "RADACA"
.p2align 2
.Lhook_phase0: .word 0
.Lhook_phase1: .word 1
.data
.p2align 3
.global md2asm_radaca_source_counter_storage
md2asm_radaca_source_counter_storage:
.Lcounts: .zero 24
.section .note.GNU-stack,"",%progbits
