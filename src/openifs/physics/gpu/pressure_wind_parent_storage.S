// Contract: skills/md2asm-gpu/references/openifs/physics/pressure_wind_interpolation.md.
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
.global md2asm_ppuv_wind_log_pressure_7358525
.type md2asm_ppuv_wind_log_pressure_7358525,%function
md2asm_ppuv_wind_log_pressure_7358525:
mov x16,sp
sub sp,sp,#3,lsl #12
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
ldr x9,[x16,#24]
str x9,[x19,#88]
ldr x9,[x16,#32]
str x9,[x19,#96]
ldr x9,[x16,#40]
str x9,[x19,#104]
ldr x9,[x16,#48]
str x9,[x19,#112]
ldr x9,[x16,#56]
str x9,[x19,#120]
ldr x9,[x16,#64]
str x9,[x19,#128]
ldr x9,[x19,#0]
ldrsw x20,[x9]
cmp x20,#24
b.ne .Lppuv_reject
ldr x9,[x19,#8]
ldrsw x21,[x9]
cmp x21,#1
b.ne .Lppuv_reject
ldr x9,[x19,#24]
ldrsw x9,[x9]
cmp x9,#19
b.ne .Lppuv_reject
ldr x9,[x19,#16]
ldrsw x22,[x9]
cmp x22,#24
b.eq .Lppuv_end_shape
cmp x22,#8
b.ne .Lppuv_reject
.Lppuv_end_shape:
sub x21,x21,#1
sub x22,x22,#1
ldr x9,[x19,#32]
ldr w9,[x9]
cmp w9,#2
b.ne .Lppuv_reject
ldr x9,[x19,#40]
ldr w9,[x9]
cmp w9,#1
b.ne .Lppuv_reject
ldr x9,[x19,#48]
ldr w9,[x9]
cmp w9,#4
b.ne .Lppuv_reject
adrp x9,:got:__yomppvi_MOD_lrppuv_cstext
ldr x9,[x9,:got_lo12:__yomppvi_MOD_lrppuv_cstext]
ldr w9,[x9]
cbnz w9,.Lppuv_reject
adrp x9,:got:__yomppvi_MOD_lrppuv_callitpq
ldr x9,[x9,:got_lo12:__yomppvi_MOD_lrppuv_callitpq]
ldr w9,[x9]
cmp w9,#1
b.ne .Lppuv_reject
// The complete source quadratic child now owns its active and inactive cells.
adrp x9,:got:__yomhook_MOD_lhook
ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
ldr w9,[x9]
cbz w9,.Lppuv_hook_skip_0
adr x0,.Lppuv_name
adr x1,.Lphase0
add x2,sp,#784
mov x3,#4
CALL __yomhook_MOD_dr_hook_default8
.Lppuv_hook_skip_0:
mov x23,#1
.Lppuv_copy_level:
mov x24,x21
.Lppuv_copy_cell:
madd x26,x23,x20,x24
sub x10,x26,x20
ldr x9,[x19,#104]
ldr d0,[x9,x10,lsl #3]
add x9,sp,#1024
str d0,[x9,x26,lsl #3]
ldr x9,[x19,#112]
ldr d0,[x9,x10,lsl #3]
add x9,sp,#1,lsl #12
add x9,x9,#768
str d0,[x9,x26,lsl #3]
add x24,x24,#1
cmp x24,x22
b.le .Lppuv_copy_cell
add x23,x23,#1
cmp x23,#19
b.le .Lppuv_copy_level
add x9,sp,#1024
str x9,[x19,#136]
add x9,sp,#1,lsl #12
add x9,x9,#768
str x9,[x19,#144]
mov x0,x19
CALL md2asm_gpu_wind_continuation_stage
ldr x0,[x19,#0]
ldr x1,[x19,#8]
ldr x2,[x19,#16]
ldr x3,[x19,#24]
ldr x4,[x19,#32]
ldr x5,[x19,#40]
ldr x6,[x19,#48]
ldr x7,[x19,#56]
adr x9,.Lfour
str x9,[sp,#0]
ldr x9,[x19,#64]
str x9,[sp,#8]
ldr x9,[x19,#72]
str x9,[sp,#16]
ldr x9,[x19,#80]
str x9,[sp,#24]
ldr x9,[x19,#88]
str x9,[sp,#32]
ldr x9,[x19,#96]
str x9,[sp,#40]
add x9,sp,#1024
str x9,[sp,#48]
ldr x9,[x19,#120]
str x9,[sp,#56]
CALL md2asm_ppintp_wind_log_pressure_7358525
ldr x0,[x19,#0]
ldr x1,[x19,#8]
ldr x2,[x19,#16]
ldr x3,[x19,#24]
ldr x4,[x19,#32]
ldr x5,[x19,#40]
ldr x6,[x19,#48]
ldr x7,[x19,#56]
adr x9,.Lfour
str x9,[sp,#0]
ldr x9,[x19,#64]
str x9,[sp,#8]
ldr x9,[x19,#72]
str x9,[sp,#16]
ldr x9,[x19,#80]
str x9,[sp,#24]
ldr x9,[x19,#88]
str x9,[sp,#32]
ldr x9,[x19,#96]
str x9,[sp,#40]
add x9,sp,#1,lsl #12
add x9,x9,#768
str x9,[sp,#48]
ldr x9,[x19,#128]
str x9,[sp,#56]
CALL md2asm_ppintp_wind_log_pressure_7358525
mov x23,#0
.Lppuv_below_target:
ldr x9,[x19,#72]
ldr w9,[x9,x23,lsl #2]
cbz w9,.Lppuv_below_next
mov x24,x21
.Lppuv_below_cell:
madd x26,x23,x20,x24
ldr x9,[x19,#64]
ldr w9,[x9,x26,lsl #2]
cbz w9,.Lppuv_below_cell_next
add x10,x24,#456
add x9,sp,#1024
ldr d0,[x9,x10,lsl #3]
ldr x9,[x19,#120]
str d0,[x9,x26,lsl #3]
add x9,sp,#1,lsl #12
add x9,x9,#768
ldr d0,[x9,x10,lsl #3]
ldr x9,[x19,#128]
str d0,[x9,x26,lsl #3]
.Lppuv_below_cell_next:
add x24,x24,#1
cmp x24,x22
b.le .Lppuv_below_cell
.Lppuv_below_next:
add x23,x23,#1
cmp x23,#2
b.lt .Lppuv_below_target
ldr x0,[x19,#0]
ldr x1,[x19,#8]
ldr x2,[x19,#16]
ldr x3,[x19,#24]
ldr x4,[x19,#32]
ldr x5,[x19,#40]
ldr x6,[x19,#48]
adr x7,.Lfour
ldr x9,[x19,#80]
str x9,[sp,#0]
ldr x9,[x19,#88]
str x9,[sp,#8]
add x9,sp,#1024
str x9,[sp,#16]
ldr x9,[x19,#120]
str x9,[sp,#24]
CALL md2asm_ppitpq_wind_selected_identity_7358525
ldr x0,[x19,#0]
ldr x1,[x19,#8]
ldr x2,[x19,#16]
ldr x3,[x19,#24]
ldr x4,[x19,#32]
ldr x5,[x19,#40]
ldr x6,[x19,#48]
adr x7,.Lfour
ldr x9,[x19,#80]
str x9,[sp,#0]
ldr x9,[x19,#88]
str x9,[sp,#8]
add x9,sp,#1,lsl #12
add x9,x9,#768
str x9,[sp,#16]
ldr x9,[x19,#128]
str x9,[sp,#24]
CALL md2asm_ppitpq_wind_selected_identity_7358525
adrp x9,:got:__yomhook_MOD_lhook
ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
ldr w9,[x9]
cbz w9,.Lppuv_hook_skip_1
adr x0,.Lppuv_name
adr x1,.Lphase1
add x2,sp,#784
mov x3,#4
CALL __yomhook_MOD_dr_hook_default8
.Lppuv_hook_skip_1:
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
add sp,sp,#3,lsl #12
ret
.size md2asm_ppuv_wind_log_pressure_7358525,.-md2asm_ppuv_wind_log_pressure_7358525
.Lppuv_reject:
brk #406
.section .rodata
.balign 8
.Lphase0:.word 0
.Lphase1:.word 1
.Lfour:.word 4
.Lppuv_name:.ascii "PPUV"
.section .note.GNU-stack,"",%progbits
