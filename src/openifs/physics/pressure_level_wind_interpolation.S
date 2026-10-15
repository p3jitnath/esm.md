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
.global md2asm_ppflev_wind_two_targets_7358525
.type md2asm_ppflev_wind_two_targets_7358525,%function
md2asm_ppflev_wind_two_targets_7358525:
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
ldr x9,[x19,#0]
ldrsw x20,[x9]
cmp x20,#24
b.ne .Lwind_ppflev_reject
ldr x9,[x19,#8]
ldrsw x21,[x9]
cmp x21,#1
b.ne .Lwind_ppflev_reject
sub x21,x21,#1
ldr x9,[x19,#16]
ldrsw x22,[x9]
cmp x22,#24
b.eq .Lwind_ppflev_end_shape
cmp x22,#8
b.ne .Lwind_ppflev_reject
.Lwind_ppflev_end_shape:
sub x22,x22,#1
ldr x9,[x19,#24]
ldrsw x9,[x9]
cmp x9,#19
b.ne .Lwind_ppflev_reject
ldr x9,[x19,#40]
ldrsw x9,[x9]
cmp x9,#4
b.ne .Lwind_ppflev_reject
ldr x9,[x19,#32]
ldrsw x28,[x9]
cmp x28,#2
b.ne .Lwind_ppflev_reject
.Lwind_ppflev_out_shape:
adrp x9,:got:__yomhook_MOD_lhook
ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
ldr w9,[x9]
cbz w9,.Lwind_ppflev_hook_skip_0
adr x0,.Lwind_ppflev_name
adr x1,.Lphase0
add x2,sp,#784
mov x3,#6
CALL __yomhook_MOD_dr_hook_default8
.Lwind_ppflev_hook_skip_0:
mov x23,#1
.Lwind_ppflev_max_level:
mul x26,x23,x20
add x26,x26,x21
ldr x9,[x19,#56]
ldr d0,[x9,x26,lsl #3]
add x24,x21,#1
.Lwind_ppflev_max_cell:
cmp x24,x22
b.gt .Lwind_ppflev_max_done
madd x10,x23,x20,x24
ldr d1,[x9,x10,lsl #3]
fmaxnm d0,d0,d1
add x24,x24,#1
b .Lwind_ppflev_max_cell
.Lwind_ppflev_max_done:
add x10,sp,#1024
str d0,[x10,x23,lsl #3]
add x23,x23,#1
cmp x23,#19
b.le .Lwind_ppflev_max_level
mov x23,#0
.Lwind_ppflev_target:
mul x26,x23,x20
add x26,x26,x21
ldr x9,[x19,#48]
ldr d0,[x9,x26,lsl #3]
add x24,x21,#1
.Lwind_ppflev_min_cell:
cmp x24,x22
b.gt .Lwind_ppflev_min_done
madd x10,x23,x20,x24
ldr d1,[x9,x10,lsl #3]
fminnm d0,d0,d1
add x24,x24,#1
b .Lwind_ppflev_min_cell
.Lwind_ppflev_min_done:
str d0,[sp,#1200]
mov x24,x21
mov w9,#20
ldr x10,[x19,#72]
.Lwind_ppflev_initial_index:
madd x26,x23,x20,x24
str w9,[x10,x26,lsl #2]
add x24,x24,#1
cmp x24,x22
b.le .Lwind_ppflev_initial_index
mov x27,#0
mov x25,#1
.Lwind_ppflev_search_level:
add x9,sp,#1024
ldr d0,[x9,x25,lsl #3]
ldr d1,[sp,#1200]
fcmp d0,d1
b.le .Lwind_ppflev_search_next
mov x24,x21
.Lwind_ppflev_search_cell:
madd x26,x23,x20,x24
ldr x9,[x19,#72]
ldr w10,[x9,x26,lsl #2]
cmp w10,#20
b.ne .Lwind_ppflev_search_cell_next
madd x10,x25,x20,x24
ldr x11,[x19,#56]
ldr d0,[x11,x10,lsl #3]
ldr x11,[x19,#48]
ldr d1,[x11,x26,lsl #3]
fcmp d0,d1
b.le .Lwind_ppflev_search_cell_next
str w25,[x9,x26,lsl #2]
add x27,x27,#1
.Lwind_ppflev_search_cell_next:
add x24,x24,#1
cmp x24,x22
b.le .Lwind_ppflev_search_cell
.Lwind_ppflev_search_next:
sub x9,x22,x21
add x9,x9,#1
cmp x27,x9
b.eq .Lwind_ppflev_search_done
add x25,x25,#1
cmp x25,#19
b.le .Lwind_ppflev_search_level
.Lwind_ppflev_search_done:
add x23,x23,#1
cmp x23,x28
b.lt .Lwind_ppflev_target
mov x23,#0
.Lwind_ppflev_full_target:
mov x24,x21
.Lwind_ppflev_full_cell:
madd x26,x23,x20,x24
ldr x9,[x19,#72]
ldr w25,[x9,x26,lsl #2]
mov w10,#19
cmp w25,w10
csel w25,w25,w10,lt
str w25,[x9,x26,lsl #2]
sub x10,x25,#1
madd x10,x10,x20,x24
ldr x11,[x19,#64]
ldr d0,[x11,x10,lsl #3]
ldr x11,[x19,#48]
ldr d1,[x11,x26,lsl #3]
fsub d0,d0,d1
fcmp d0,#0.0
b.ge .Lwind_ppflev_full_index
add w25,w25,#1
.Lwind_ppflev_full_index:
mov w10,#19
cmp w25,w10
csel w25,w25,w10,lt
mul x10,x20,x28
add x10,x26,x10
str w25,[x9,x10,lsl #2]
ldr w11,[x9,x26,lsl #2]
mul x10,x20,x28
lsl x10,x10,#1
add x10,x26,x10
str w11,[x9,x10,lsl #2]
mul x10,x20,x28
add x10,x10,x10,lsl #1
add x10,x26,x10
str w25,[x9,x10,lsl #2]
add x24,x24,#1
cmp x24,x22
b.le .Lwind_ppflev_full_cell
add x23,x23,#1
cmp x23,x28
b.lt .Lwind_ppflev_full_target
mov x23,#0
.Lwind_ppflev_flag_target:
mov w27,#0
mov w25,#0
mov x24,x21
.Lwind_ppflev_flag_cell:
madd x26,x23,x20,x24
ldr x9,[x19,#48]
ldr d0,[x9,x26,lsl #3]
mov x10,#18
madd x10,x10,x20,x24
ldr x9,[x19,#64]
ldr d1,[x9,x10,lsl #3]
fcmp d0,d1
cset w11,gt
ldr x9,[x19,#80]
str w11,[x9,x26,lsl #2]
orr w27,w27,w11
mov x10,#19
madd x10,x10,x20,x24
ldr x9,[x19,#56]
ldr d1,[x9,x10,lsl #3]
fcmp d0,d1
cset w11,gt
ldr x9,[x19,#88]
str w11,[x9,x26,lsl #2]
orr w25,w25,w11
add x24,x24,#1
cmp x24,x22
b.le .Lwind_ppflev_flag_cell
ldr x9,[x19,#96]
str w27,[x9,x23,lsl #2]
ldr x9,[x19,#104]
str w25,[x9,x23,lsl #2]
add x23,x23,#1
cmp x23,x28
b.lt .Lwind_ppflev_flag_target
adrp x9,:got:__yomhook_MOD_lhook
ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
ldr w9,[x9]
cbz w9,.Lwind_ppflev_hook_skip_1
adr x0,.Lwind_ppflev_name
adr x1,.Lphase1
add x2,sp,#784
mov x3,#6
CALL __yomhook_MOD_dr_hook_default8
.Lwind_ppflev_hook_skip_1:
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
.size md2asm_ppflev_wind_two_targets_7358525,.-md2asm_ppflev_wind_two_targets_7358525
.Lwind_ppflev_reject:
brk #405
.global md2asm_ppintp_wind_log_pressure_7358525
.type md2asm_ppintp_wind_log_pressure_7358525,%function
md2asm_ppintp_wind_log_pressure_7358525:
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
ldr x9,[x19,#0]
ldrsw x20,[x9]
cmp x20,#24
b.ne .Lwind_ppintp_reject
ldr x9,[x19,#8]
ldrsw x21,[x9]
cmp x21,#1
b.ne .Lwind_ppintp_reject
sub x21,x21,#1
ldr x9,[x19,#16]
ldrsw x22,[x9]
cmp x22,#24
b.eq .Lwind_ppintp_end_shape
cmp x22,#8
b.ne .Lwind_ppintp_reject
.Lwind_ppintp_end_shape:
sub x22,x22,#1
ldr x9,[x19,#24]
ldrsw x9,[x9]
cmp x9,#19
b.ne .Lwind_ppintp_reject
ldr x9,[x19,#48]
ldrsw x9,[x9]
cmp x9,#4
b.ne .Lwind_ppintp_reject
ldr x9,[x19,#32]
ldrsw x27,[x9]
cmp x27,#2
b.ne .Lwind_ppintp_reject
.Lwind_ppintp_out_shape:
ldr x9,[x19,#40]
ldrsw x9,[x9]
cmp x9,#1
b.ne .Lwind_ppintp_reject
ldr x9,[x19,#64]
ldrsw x28,[x9]
cmp x28,#4
b.ne .Lwind_ppintp_reject
adrp x9,:got:__yomhook_MOD_lhook
ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
ldr w9,[x9]
cbz w9,.Lwind_ppintp_hook_skip_0
adr x0,.Lwind_ppintp_name
adr x1,.Lphase0
add x2,sp,#784
mov x3,#6
CALL __yomhook_MOD_dr_hook_default8
.Lwind_ppintp_hook_skip_0:
mov x23,#0
.Lwind_ppintp_level:
mov x24,x21
.Lwind_ppintp_cell:
madd x26,x23,x20,x24
ldr x9,[x19,#80]
ldr w10,[x9,x23,lsl #2]
cbz w10,.Lwind_ppintp_eval
ldr x9,[x19,#72]
ldr w10,[x9,x26,lsl #2]
cbnz w10,.Lwind_ppintp_next
.Lwind_ppintp_eval:
mul x9,x20,x27
sub x10,x28,#1
madd x9,x9,x10,x26
ldr x10,[x19,#56]
ldrsw x25,[x10,x9,lsl #2]
madd x9,x25,x20,x24
ldr x10,[x19,#112]
ldr d0,[x10,x9,lsl #3]
sub x9,x9,x20
ldr d1,[x10,x9,lsl #3]
fsub d1,d0,d1
ldr x10,[x19,#88]
ldr d2,[x10,x26,lsl #3]
madd x9,x25,x20,x24
add x9,x9,#1440
ldr x10,[x19,#96]
ldr d3,[x10,x9,lsl #3]
fsub d2,d2,d3
fmul d1,d1,d2
sub x9,x9,x20
ldr x10,[x19,#104]
ldr d2,[x10,x9,lsl #3]
fmul d1,d1,d2
fadd d0,d0,d1
ldr x10,[x19,#120]
str d0,[x10,x26,lsl #3]
.Lwind_ppintp_next:
add x24,x24,#1
cmp x24,x22
b.le .Lwind_ppintp_cell
add x23,x23,#1
cmp x23,x27
b.lt .Lwind_ppintp_level
adrp x9,:got:__yomhook_MOD_lhook
ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
ldr w9,[x9]
cbz w9,.Lwind_ppintp_hook_skip_1
adr x0,.Lwind_ppintp_name
adr x1,.Lphase1
add x2,sp,#784
mov x3,#6
CALL __yomhook_MOD_dr_hook_default8
.Lwind_ppintp_hook_skip_1:
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
.size md2asm_ppintp_wind_log_pressure_7358525,.-md2asm_ppintp_wind_log_pressure_7358525
.Lwind_ppintp_reject:
brk #405
.global md2asm_ppitpq_wind_quadratic_r3_7358525
.type md2asm_ppitpq_wind_quadratic_r3_7358525,%function
.global md2asm_ppitpq_wind_selected_identity_7358525
.type md2asm_ppitpq_wind_selected_identity_7358525,%function
md2asm_ppitpq_wind_quadratic_r3_7358525:
md2asm_ppitpq_wind_selected_identity_7358525:
mov x16,sp
sub sp,sp,#1,lsl #12
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
ldr x9,[x19,#0]
ldrsw x20,[x9]
cmp x20,#24
b.ne .Lppitpq_reject
ldr x9,[x19,#8]
ldrsw x21,[x9]
cmp x21,#1
b.ne .Lppitpq_reject
ldr x9,[x19,#24]
ldrsw x9,[x9]
cmp x9,#19
b.ne .Lppitpq_reject
ldr x9,[x19,#16]
ldrsw x22,[x9]
cmp x22,#24
b.eq .Lppitpq_end_shape
cmp x22,#8
b.ne .Lppitpq_reject
.Lppitpq_end_shape:
sub x21,x21,#1
sub x22,x22,#1
ldr x9,[x19,#32]
ldr w9,[x9]
cmp w9,#2
b.ne .Lppitpq_reject
ldr x9,[x19,#40]
ldr w9,[x9]
cmp w9,#1
b.ne .Lppitpq_reject
ldr x9,[x19,#48]
ldr w9,[x9]
cmp w9,#4
b.ne .Lppitpq_reject
ldr x9,[x19,#56]
ldr w9,[x9]
cmp w9,#4
b.ne .Lppitpq_reject
adrp x9,:got:__yomhook_MOD_lhook
ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
ldr w9,[x9]
cbz w9,.Lppitpq_hook_skip_0
adr x0,.Lppitpq_name
adr x1,.Lphase0
add x2,sp,#784
mov x3,#6
CALL __yomhook_MOD_dr_hook_default8
.Lppitpq_hook_skip_0:
mov x23,#0
.Lppitpq_target:
mov x24,x21
.Lppitpq_cell:
madd x26,x23,x20,x24
ldr x9,[x19,#64]
ldr d0,[x9,x26,lsl #3]
add x10,x24,#1488
ldr x9,[x19,#72]
ldr d1,[x9,x10,lsl #3]
// Strict source comparison signals invalid for a quiet NaN and skips it.
fcmpe d0,d1
b.pl .Lppitpq_next_cell
// Pressure method4 stores full-level logarithms at levels1,2,3.
sub x10,x10,#24
ldr d2,[x9,x10,lsl #3]
add x10,x10,#48
ldr d3,[x9,x10,lsl #3]
ldr x9,[x19,#80]
add x10,x24,#24
ldr d4,[x9,x10,lsl #3]
add x10,x10,#24
ldr d5,[x9,x10,lsl #3]
add x10,x10,#24
ldr d6,[x9,x10,lsl #3]
// Two denominator products retain the source subtraction order.
fsub d7,d1,d2
fsub d16,d2,d3
fmul d7,d7,d16
fsub d17,d1,d3
fmul d17,d17,d16
// First correction: (f2-f1)*(p-p2)*(p-p3)/den1.
fsub d18,d5,d4
fsub d19,d0,d1
fmul d18,d18,d19
fsub d20,d0,d3
fmul d18,d18,d20
fdiv d18,d18,d7
// Second correction: (f2-f3)*(p-p1)*(p-p2)/den2.
fsub d20,d5,d6
fsub d21,d0,d2
fmul d20,d20,d21
fmul d20,d20,d19
fdiv d20,d20,d17
fadd d18,d5,d18
fsub d18,d18,d20
ldr x9,[x19,#88]
str d18,[x9,x26,lsl #3]
.Lppitpq_next_cell:
add x24,x24,#1
cmp x24,x22
b.le .Lppitpq_cell
add x23,x23,#1
cmp x23,#2
b.lt .Lppitpq_target
adrp x9,:got:__yomhook_MOD_lhook
ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
ldr w9,[x9]
cbz w9,.Lppitpq_hook_skip_1
adr x0,.Lppitpq_name
adr x1,.Lphase1
add x2,sp,#784
mov x3,#6
CALL __yomhook_MOD_dr_hook_default8
.Lppitpq_hook_skip_1:
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
add sp,sp,#1,lsl #12
ret
.size md2asm_ppitpq_wind_selected_identity_7358525,.-md2asm_ppitpq_wind_selected_identity_7358525
.size md2asm_ppitpq_wind_quadratic_r3_7358525,.-md2asm_ppitpq_wind_quadratic_r3_7358525
.Lppitpq_reject:
brk #406
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
mov x24,x21
.Lppuv_top:
add x10,x24,#1488
ldr x9,[x19,#88]
ldr d8,[x9,x10,lsl #3]
sub x10,x10,x20
ldr x9,[x19,#96]
ldr d9,[x9,x10,lsl #3]
fmul d8,d8,d9
ldr x9,[x19,#104]
ldr d0,[x9,x24,lsl #3]
add x10,x24,x20
ldr d1,[x9,x10,lsl #3]
fsub d0,d0,d1
fmul d0,d8,d0
fadd d0,d1,d0
add x9,sp,#1024
str d0,[x9,x24,lsl #3]
ldr x9,[x19,#112]
ldr d0,[x9,x24,lsl #3]
ldr d1,[x9,x10,lsl #3]
fsub d0,d0,d1
fmul d0,d8,d0
fadd d0,d1,d0
add x9,sp,#1,lsl #12
add x9,x9,#768
str d0,[x9,x24,lsl #3]
add x24,x24,#1
cmp x24,x22
b.le .Lppuv_top
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
mov x23,#0
.Lcapeshear_pressure_target:
mov x24,x21
.Lcapeshear_pressure_cell:
madd x26,x23,x20,x24
adr x9,.Ltarget_pressure
ldr d0,[x9,x23,lsl #3]
add x9,sp,#1024
str d0,[x9,x26,lsl #3]
CALL log
add x9,sp,#1408
str d0,[x9,x26,lsl #3]
add x24,x24,#1
cmp x24,x22
b.le .Lcapeshear_pressure_cell
add x23,x23,#1
cmp x23,#2
b.lt .Lcapeshear_pressure_target
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
mov x24,x21
.Lcapeshear_final_cell:
add x9,sp,#8,lsl #12
add x9,x9,#912
ldr d0,[x9,x24,lsl #3]
add x10,x24,x20
ldr d1,[x9,x10,lsl #3]
fsub d0,d0,d1
add x9,sp,#8,lsl #12
add x9,x9,#1296
ldr d1,[x9,x24,lsl #3]
ldr d2,[x9,x10,lsl #3]
fsub d1,d1,d2
fmul d0,d0,d0
fmul d1,d1,d1
fadd d0,d0,d1
ldr x9,[x19,#72]
ldr d1,[x9,x24,lsl #3]
fmul d0,d1,d0
fsqrt d0,d0
ldr x9,[x19,#80]
str d0,[x9,x24,lsl #3]
add x24,x24,#1
cmp x24,x22
b.le .Lcapeshear_final_cell
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
