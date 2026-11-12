// Contract: skills/md2fort-gpu/references/openifs/physics/wind_pressure_brackets.md.
// Pressure-level wind interpolation: PPUV and the complete frozen PPITPQ branch.
// Physics: formulations/openifs/physics/pressure_level_wind_interpolation.md.
// Contract: skills/md2fort/references/openifs/physics/pressure_level_wind_interpolation.md.
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
mov x0,x19
CALL md2asm_gpu_wind_brackets_stage
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
.section .rodata
.balign 8
.Lphase0:.word 0
.Lphase1:.word 1
.Lwind_ppflev_name:.ascii "PPFLEV"
.section .note.GNU-stack,"",%progbits
