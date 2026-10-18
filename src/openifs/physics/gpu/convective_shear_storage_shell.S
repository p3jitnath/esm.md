// Contract: skills/md2asm-gpu/references/openifs/physics/convective_wind_shear.md.
// Pressure-level wind interpolation: PPUV and the complete frozen PPITPQ branch.
// Physics: formulations/openifs/physics/pressure_level_wind_interpolation.md.
// Contract: skills/md2asm/references/openifs/physics/pressure_level_wind_interpolation.md.
// Original sources: arpifs/pp_obs/ppuv.F90 and arpifs/pp_obs/ppitpq.F90.
// Unchanged pressure-bracket, linear interpolation and CAPESHEAR entries remain in this shared body.
.text
.arch armv8-a
.macro CALL symbol
bl \symbol
.endm
.global md2asm_convective_energy_wind_shear_7358525
.type md2asm_convective_energy_wind_shear_7358525,%function
md2asm_convective_energy_wind_shear_7358525:
mov x16,sp
sub sp,sp,#9,lsl #12
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
str x30,[sp,#696]
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
ldr x9,[x16,#8]
str x9,[x19,#72]
ldr x9,[x16,#16]
str x9,[x19,#80]
ldr x9,[x19,#8]
ldrsw x20,[x9]
cmp x20,#24
b.ne .Lcapeshear_reject
ldr x9,[x19,#16]
ldrsw x21,[x9]
cmp x21,#1
b.ne .Lcapeshear_reject
ldr x9,[x19,#32]
ldrsw x9,[x9]
cmp x9,#19
b.ne .Lcapeshear_reject
ldr x9,[x19,#24]
ldrsw x22,[x9]
cmp x22,#24
b.eq .Lcapeshear_end_shape
cmp x22,#8
b.ne .Lcapeshear_reject
.Lcapeshear_end_shape:
sub x21,x21,#1
sub x22,x22,#1
adrp x9,:got:__yomhook_MOD_lhook
ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
ldr w9,[x9]
cbz w9,.Lcapeshear_hook_skip_0
adr x0,.Lcapeshear_name
adr x1,.Lphase0
add x2,sp,#784
mov x3,#9
CALL __yomhook_MOD_dr_hook_default8
.Lcapeshear_hook_skip_0:
add x9,sp,#1024
str x9,[x19,#88]
add x9,sp,#1408
str x9,[x19,#96]
add x9,sp,#8,lsl #12
add x9,x9,#912
str x9,[x19,#104]
add x9,sp,#8,lsl #12
add x9,x9,#1296
str x9,[x19,#112]
mov x0,x19
mov w1,#1
CALL md2asm_gpu_convective_shear_stage
ldr x0,[x19,#8]
ldr x1,[x19,#16]
ldr x2,[x19,#24]
ldr x3,[x19,#32]
adr x4,.Lfour
ldr x5,[x19,#40]
ldr x6,[x19,#48]
add x7,sp,#1792
add x9,sp,#4,lsl #12
add x9,x9,#768
str x9,[sp,#0]
CALL md2asm_ppinit_7358525
ldr x0,[x19,#8]
ldr x1,[x19,#16]
ldr x2,[x19,#24]
ldr x3,[x19,#32]
adr x4,.Ltwo
adr x5,.Lfour
add x6,sp,#1024
ldr x7,[x19,#40]
ldr x9,[x19,#48]
str x9,[sp,#0]
add x9,sp,#7,lsl #12
add x9,x9,#3840
str x9,[sp,#8]
add x9,sp,#8,lsl #12
add x9,x9,#512
str x9,[sp,#16]
add x9,sp,#8,lsl #12
add x9,x9,#704
str x9,[sp,#24]
add x9,sp,#8,lsl #12
add x9,x9,#896
str x9,[sp,#32]
add x9,sp,#8,lsl #12
add x9,x9,#904
str x9,[sp,#40]
CALL md2asm_ppflev_wind_two_targets_7358525
ldr x0,[x19,#8]
ldr x1,[x19,#16]
ldr x2,[x19,#24]
ldr x3,[x19,#32]
adr x4,.Ltwo
adr x5,.Lone
adr x6,.Lfour
add x7,sp,#7,lsl #12
add x7,x7,#3840
add x9,sp,#8,lsl #12
add x9,x9,#512
str x9,[sp,#0]
add x9,sp,#8,lsl #12
add x9,x9,#896
str x9,[sp,#8]
add x9,sp,#1408
str x9,[sp,#16]
add x9,sp,#1792
str x9,[sp,#24]
add x9,sp,#4,lsl #12
add x9,x9,#768
str x9,[sp,#32]
ldr x9,[x19,#56]
str x9,[sp,#40]
ldr x9,[x19,#64]
str x9,[sp,#48]
add x9,sp,#8,lsl #12
add x9,x9,#912
str x9,[sp,#56]
add x9,sp,#8,lsl #12
add x9,x9,#1296
str x9,[sp,#64]
CALL md2asm_ppuv_wind_log_pressure_7358525
mov x0,x19
mov w1,#2
CALL md2asm_gpu_convective_shear_stage
adrp x9,:got:__yomhook_MOD_lhook
ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
ldr w9,[x9]
cbz w9,.Lcapeshear_hook_skip_1
adr x0,.Lcapeshear_name
adr x1,.Lphase1
add x2,sp,#784
mov x3,#9
CALL __yomhook_MOD_dr_hook_default8
.Lcapeshear_hook_skip_1:
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
ldr x30,[sp,#696]
ldr d8,[sp,#712]
ldr d9,[sp,#720]
ldr d10,[sp,#728]
ldr d11,[sp,#736]
ldr d12,[sp,#744]
ldr d13,[sp,#752]
ldr d14,[sp,#760]
ldr d15,[sp,#768]
add sp,sp,#9,lsl #12
ret
.size md2asm_convective_energy_wind_shear_7358525,.-md2asm_convective_energy_wind_shear_7358525
.Lcapeshear_reject:
brk #406
.section .rodata
.balign 8
.Ltarget_pressure: .double 50000.0,92500.0
.Lone: .word 1
.Ltwo: .word 2
.Lfour: .word 4
.Lphase0: .word 0
.Lphase1: .word 1
.Lwind_ppflev_name: .ascii "PPFLEV"
.Lwind_ppintp_name: .ascii "PPINTP"
.Lppitpq_name: .ascii "PPITPQ"
.Lppuv_name: .ascii "PPUV"
.Lcapeshear_name: .ascii "CAPESHEAR"
.section .note.GNU-stack,"",%progbits
