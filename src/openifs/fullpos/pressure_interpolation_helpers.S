/* Source build for the qualified private forecast graph.
 * Contract: skills/md2asm/references/openifs/dynamics/private_forecast_graph_sources.md.
 * Preserve the original interface, ordered arithmetic, and caller-owned storage. */
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
mov x23,#1
.Lppinit_level:
mov x24,x21
.Lppinit_cell:
mul x26,x23,x20
add x26,x26,x24
ldr x9,[x19,#40]
ldr d0,[x9,x26,lsl #3]
ldr x10,[x19,#56]
str d0,[x10,x26,lsl #3]
sub x9,x26,x20
ldr x10,[x19,#48]
ldr d1,[x10,x9,lsl #3]
add x9,x26,#480
ldr x10,[x19,#56]
str d1,[x10,x9,lsl #3]
CALL log
add x9,x26,#960
ldr x10,[x19,#56]
str d0,[x10,x9,lsl #3]
sub x9,x26,x20
ldr x10,[x19,#48]
ldr d0,[x10,x9,lsl #3]
CALL log
add x9,x26,#1440
ldr x10,[x19,#56]
str d0,[x10,x9,lsl #3]
add x24,x24,#1
cmp x24,x22
b.le .Lppinit_cell
add x23,x23,#1
cmp x23,#19
b.le .Lppinit_level
mov x24,x21
.Lppinit_top:
ldr x9,[x19,#40]
ldr d0,[x9,x24,lsl #3]
ldr x10,[x19,#56]
str d0,[x10,x24,lsl #3]
movz x9,#39322
movk x9,#39321,lsl #16
movk x9,#39321,lsl #32
movk x9,#16313,lsl #48
fmov d0,x9
add x9,x24,#480
str d0,[x10,x9,lsl #3]
movz x9,#21781
movk x9,#48053,lsl #16
movk x9,#27569,lsl #32
movk x9,#49154,lsl #48
fmov d0,x9
add x9,x24,#960
str d0,[x10,x9,lsl #3]
add x9,x24,#1440
str d0,[x10,x9,lsl #3]
add x24,x24,#1
cmp x24,x22
b.le .Lppinit_top
mov x23,#0
.Lppinit_diff_method:
mov x25,#0
.Lppinit_diff_level:
mov x24,x21
.Lppinit_diff_cell:
mov x9,#480
mul x26,x23,x9
madd x26,x25,x20,x26
add x26,x26,x24
ldr x10,[x19,#56]
add x9,x26,x20
ldr d0,[x10,x9,lsl #3]
ldr d1,[x10,x26,lsl #3]
fsub d0,d0,d1
movz x9,#0
movk x9,#0,lsl #16
movk x9,#0,lsl #32
movk x9,#16368,lsl #48
fmov d1,x9
fdiv d0,d1,d0
ldr x10,[x19,#64]
str d0,[x10,x26,lsl #3]
add x24,x24,#1
cmp x24,x22
b.le .Lppinit_diff_cell
add x25,x25,#1
cmp x25,#18
b.le .Lppinit_diff_level
add x23,x23,#1
cmp x23,#4
b.lt .Lppinit_diff_method
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
.global md2asm_ppflev_7358525
.type md2asm_ppflev_7358525,%function
md2asm_ppflev_7358525:
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
b.ne .Lppflev_reject
ldr x9,[x19,#8]
ldrsw x21,[x9]
cmp x21,#1
b.ne .Lppflev_reject
sub x21,x21,#1
ldr x9,[x19,#16]
ldrsw x22,[x9]
cmp x22,#24
b.eq .Lppflev_end_shape
cmp x22,#8
b.ne .Lppflev_reject
.Lppflev_end_shape:
sub x22,x22,#1
ldr x9,[x19,#24]
ldrsw x9,[x9]
cmp x9,#19
b.ne .Lppflev_reject
ldr x9,[x19,#40]
ldrsw x9,[x9]
cmp x9,#4
b.ne .Lppflev_reject
ldr x9,[x19,#32]
ldrsw x28,[x9]
cmp x28,#4
b.eq .Lppflev_out_shape
cmp x28,#19
b.ne .Lppflev_reject
.Lppflev_out_shape:
adrp x9,:got:__yomhook_MOD_lhook
ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
ldr w9,[x9]
cbz w9,.Lppflev_hook_skip_0
adr x0,.Lppflev_name
adr x1,.Lphase0
add x2,sp,#784
mov x3,#6
CALL __yomhook_MOD_dr_hook_default8
.Lppflev_hook_skip_0:
mov x23,#1
.Lppflev_max_level:
mul x26,x23,x20
add x26,x26,x21
ldr x9,[x19,#56]
ldr d0,[x9,x26,lsl #3]
add x24,x21,#1
.Lppflev_max_cell:
cmp x24,x22
b.gt .Lppflev_max_done
madd x10,x23,x20,x24
ldr d1,[x9,x10,lsl #3]
fmaxnm d0,d0,d1
add x24,x24,#1
b .Lppflev_max_cell
.Lppflev_max_done:
add x10,sp,#1024
str d0,[x10,x23,lsl #3]
add x23,x23,#1
cmp x23,#19
b.le .Lppflev_max_level
mov x23,#0
.Lppflev_target:
mul x26,x23,x20
add x26,x26,x21
ldr x9,[x19,#48]
ldr d0,[x9,x26,lsl #3]
add x24,x21,#1
.Lppflev_min_cell:
cmp x24,x22
b.gt .Lppflev_min_done
madd x10,x23,x20,x24
ldr d1,[x9,x10,lsl #3]
fminnm d0,d0,d1
add x24,x24,#1
b .Lppflev_min_cell
.Lppflev_min_done:
str d0,[sp,#1200]
mov x24,x21
mov w9,#20
ldr x10,[x19,#72]
.Lppflev_initial_index:
madd x26,x23,x20,x24
str w9,[x10,x26,lsl #2]
add x24,x24,#1
cmp x24,x22
b.le .Lppflev_initial_index
mov x27,#0
mov x25,#1
.Lppflev_search_level:
add x9,sp,#1024
ldr d0,[x9,x25,lsl #3]
ldr d1,[sp,#1200]
fcmp d0,d1
b.le .Lppflev_search_next
mov x24,x21
.Lppflev_search_cell:
madd x26,x23,x20,x24
ldr x9,[x19,#72]
ldr w10,[x9,x26,lsl #2]
cmp w10,#20
b.ne .Lppflev_search_cell_next
madd x10,x25,x20,x24
ldr x11,[x19,#56]
ldr d0,[x11,x10,lsl #3]
ldr x11,[x19,#48]
ldr d1,[x11,x26,lsl #3]
fcmp d0,d1
b.le .Lppflev_search_cell_next
str w25,[x9,x26,lsl #2]
add x27,x27,#1
.Lppflev_search_cell_next:
add x24,x24,#1
cmp x24,x22
b.le .Lppflev_search_cell
.Lppflev_search_next:
sub x9,x22,x21
add x9,x9,#1
cmp x27,x9
b.eq .Lppflev_search_done
add x25,x25,#1
cmp x25,#19
b.le .Lppflev_search_level
.Lppflev_search_done:
add x23,x23,#1
cmp x23,x28
b.lt .Lppflev_target
mov x23,#0
.Lppflev_full_target:
mov x24,x21
.Lppflev_full_cell:
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
b.ge .Lppflev_full_index
add w25,w25,#1
.Lppflev_full_index:
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
b.le .Lppflev_full_cell
add x23,x23,#1
cmp x23,x28
b.lt .Lppflev_full_target
mov x23,#0
.Lppflev_flag_target:
mov w27,#0
mov w25,#0
mov x24,x21
.Lppflev_flag_cell:
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
b.le .Lppflev_flag_cell
ldr x9,[x19,#96]
str w27,[x9,x23,lsl #2]
ldr x9,[x19,#104]
str w25,[x9,x23,lsl #2]
add x23,x23,#1
cmp x23,x28
b.lt .Lppflev_flag_target
adrp x9,:got:__yomhook_MOD_lhook
ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
ldr w9,[x9]
cbz w9,.Lppflev_hook_skip_1
adr x0,.Lppflev_name
adr x1,.Lphase1
add x2,sp,#784
mov x3,#6
CALL __yomhook_MOD_dr_hook_default8
.Lppflev_hook_skip_1:
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
.size md2asm_ppflev_7358525,.-md2asm_ppflev_7358525
.Lppflev_reject:
brk #405
.global md2asm_ppsta_7358525
.type md2asm_ppsta_7358525,%function
md2asm_ppsta_7358525:
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
ldr x9,[x19,#8]
ldrsw x20,[x9]
cmp x20,#24
b.ne .Lppsta_reject
ldr x9,[x19,#16]
ldrsw x21,[x9]
cmp x21,#1
b.ne .Lppsta_reject
sub x21,x21,#1
ldr x9,[x19,#24]
ldrsw x22,[x9]
cmp x22,#24
b.eq .Lppsta_end_shape
cmp x22,#8
b.ne .Lppsta_reject
.Lppsta_end_shape:
sub x22,x22,#1
ldr x9,[x19,#32]
ldrsw x27,[x9]
cmp x27,#20
b.gt .Lppsta_reject
cmp x27,#1
b.lt .Lppsta_reject
ldr x9,[x19,#40]
ldrsw x28,[x9]
cmp x28,#1
b.ne .Lppsta_reject
ldr x9,[x19,#0]
ldr w10,[x9]
movz w11,#20560
movk w11,#17746,lsl #16
cmp w10,w11
b.ne .Lppsta_reject
ldrb w10,[x9,#4]
cmp w10,#70
b.ne .Lppsta_reject
ldr x9,[x19,#80]
cmp x9,#5
b.ne .Lppsta_reject
adrp x9,:got:__yomhook_MOD_lhook
ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
ldr w9,[x9]
cbz w9,.Lppsta_hook_skip_0
adr x0,.Lppsta_name
adr x1,.Lphase0
add x2,sp,#784
mov x3,#5
CALL __yomhook_MOD_dr_hook_default8
.Lppsta_hook_skip_0:
fmov d0,xzr
str d0,[sp,#1024]
adrp x9,:got:__yomsta_MOD_vtsur
ldr x9,[x9,:got_lo12:__yomsta_MOD_vtsur]
ldr d0,[x9]
str d0,[sp,#1104]
adrp x9,:got:__yomvert_MOD_vp00
ldr x9,[x9,:got_lo12:__yomvert_MOD_vp00]
ldr d0,[x9]
str d0,[sp,#1184]
adrp x9,:got:__yomsta_MOD_vdtdz1
ldr x9,[x9,:got_lo12:__yomsta_MOD_vdtdz1]
ldr d0,[x9]
str d0,[sp,#1264]
adrp x9,:got:__yomsta_MOD_vztrop
ldr x9,[x9,:got_lo12:__yomsta_MOD_vztrop]
ldr d0,[x9]
str d0,[sp,#1032]
adrp x9,:got:__yomsta_MOD_vttrop
ldr x9,[x9,:got_lo12:__yomsta_MOD_vttrop]
ldr d0,[x9]
str d0,[sp,#1112]
adrp x9,:got:__yomsta_MOD_vptrop
ldr x9,[x9,:got_lo12:__yomsta_MOD_vptrop]
ldr d0,[x9]
str d0,[sp,#1192]
adrp x9,:got:__yomsta_MOD_vdtdz2
ldr x9,[x9,:got_lo12:__yomsta_MOD_vdtdz2]
ldr d0,[x9]
str d0,[sp,#1272]
adrp x9,:got:__yomsta_MOD_vzstra
ldr x9,[x9,:got_lo12:__yomsta_MOD_vzstra]
ldr d0,[x9]
str d0,[sp,#1040]
adrp x9,:got:__yomsta_MOD_vtstra
ldr x9,[x9,:got_lo12:__yomsta_MOD_vtstra]
ldr d0,[x9]
str d0,[sp,#1120]
adrp x9,:got:__yomsta_MOD_vpstra
ldr x9,[x9,:got_lo12:__yomsta_MOD_vpstra]
ldr d0,[x9]
str d0,[sp,#1200]
adrp x9,:got:__yomsta_MOD_vdtdz3
ldr x9,[x9,:got_lo12:__yomsta_MOD_vdtdz3]
ldr d0,[x9]
str d0,[sp,#1280]
adrp x9,:got:__yomsta_MOD_vzstr2
ldr x9,[x9,:got_lo12:__yomsta_MOD_vzstr2]
ldr d0,[x9]
str d0,[sp,#1048]
adrp x9,:got:__yomsta_MOD_vtstr2
ldr x9,[x9,:got_lo12:__yomsta_MOD_vtstr2]
ldr d0,[x9]
str d0,[sp,#1128]
adrp x9,:got:__yomsta_MOD_vpstr2
ldr x9,[x9,:got_lo12:__yomsta_MOD_vpstr2]
ldr d0,[x9]
str d0,[sp,#1208]
adrp x9,:got:__yomsta_MOD_vdtdz4
ldr x9,[x9,:got_lo12:__yomsta_MOD_vdtdz4]
ldr d0,[x9]
str d0,[sp,#1288]
adrp x9,:got:__yomsta_MOD_vzstpo
ldr x9,[x9,:got_lo12:__yomsta_MOD_vzstpo]
ldr d0,[x9]
str d0,[sp,#1056]
adrp x9,:got:__yomsta_MOD_vtstpo
ldr x9,[x9,:got_lo12:__yomsta_MOD_vtstpo]
ldr d0,[x9]
str d0,[sp,#1136]
adrp x9,:got:__yomsta_MOD_vpstpo
ldr x9,[x9,:got_lo12:__yomsta_MOD_vpstpo]
ldr d0,[x9]
str d0,[sp,#1216]
adrp x9,:got:__yomsta_MOD_vdtdz5
ldr x9,[x9,:got_lo12:__yomsta_MOD_vdtdz5]
ldr d0,[x9]
str d0,[sp,#1296]
adrp x9,:got:__yomsta_MOD_vzmeso
ldr x9,[x9,:got_lo12:__yomsta_MOD_vzmeso]
ldr d0,[x9]
str d0,[sp,#1064]
adrp x9,:got:__yomsta_MOD_vtmeso
ldr x9,[x9,:got_lo12:__yomsta_MOD_vtmeso]
ldr d0,[x9]
str d0,[sp,#1144]
adrp x9,:got:__yomsta_MOD_vpmeso
ldr x9,[x9,:got_lo12:__yomsta_MOD_vpmeso]
ldr d0,[x9]
str d0,[sp,#1224]
adrp x9,:got:__yomsta_MOD_vdtdz6
ldr x9,[x9,:got_lo12:__yomsta_MOD_vdtdz6]
ldr d0,[x9]
str d0,[sp,#1304]
adrp x9,:got:__yomsta_MOD_vzmes2
ldr x9,[x9,:got_lo12:__yomsta_MOD_vzmes2]
ldr d0,[x9]
str d0,[sp,#1072]
adrp x9,:got:__yomsta_MOD_vtmes2
ldr x9,[x9,:got_lo12:__yomsta_MOD_vtmes2]
ldr d0,[x9]
str d0,[sp,#1152]
adrp x9,:got:__yomsta_MOD_vpmes2
ldr x9,[x9,:got_lo12:__yomsta_MOD_vpmes2]
ldr d0,[x9]
str d0,[sp,#1232]
adrp x9,:got:__yomsta_MOD_vdtdz7
ldr x9,[x9,:got_lo12:__yomsta_MOD_vdtdz7]
ldr d0,[x9]
str d0,[sp,#1312]
adrp x9,:got:__yomsta_MOD_vzmepo
ldr x9,[x9,:got_lo12:__yomsta_MOD_vzmepo]
ldr d0,[x9]
str d0,[sp,#1080]
adrp x9,:got:__yomsta_MOD_vtmepo
ldr x9,[x9,:got_lo12:__yomsta_MOD_vtmepo]
ldr d0,[x9]
str d0,[sp,#1160]
adrp x9,:got:__yomsta_MOD_vpmepo
ldr x9,[x9,:got_lo12:__yomsta_MOD_vpmepo]
ldr d0,[x9]
str d0,[sp,#1240]
adrp x9,:got:__yomsta_MOD_vdtdz8
ldr x9,[x9,:got_lo12:__yomsta_MOD_vdtdz8]
ldr d0,[x9]
str d0,[sp,#1320]
adrp x9,:got:__yomsta_MOD_vzabov
ldr x9,[x9,:got_lo12:__yomsta_MOD_vzabov]
ldr d0,[x9]
str d0,[sp,#1088]
adrp x9,:got:__yomsta_MOD_vtabov
ldr x9,[x9,:got_lo12:__yomsta_MOD_vtabov]
ldr d0,[x9]
str d0,[sp,#1168]
adrp x9,:got:__yomsta_MOD_vpabov
ldr x9,[x9,:got_lo12:__yomsta_MOD_vpabov]
ldr d0,[x9]
str d0,[sp,#1248]
adrp x9,:got:__yomsta_MOD_vdtdz9
ldr x9,[x9,:got_lo12:__yomsta_MOD_vdtdz9]
ldr d0,[x9]
str d0,[sp,#1328]
mov x23,#0
.Lppsta_coeff:
add x9,sp,#1184
ldr d0,[x9,x23,lsl #3]
CALL log
add x9,sp,#1424
str d0,[x9,x23,lsl #3]
add x9,sp,#1184
ldr d1,[x9,x23,lsl #3]
movz x9,#0
movk x9,#0,lsl #16
movk x9,#0,lsl #32
movk x9,#16368,lsl #48
fmov d0,x9
fdiv d0,d0,d1
add x9,sp,#1344
str d0,[x9,x23,lsl #3]
fmov d0,xzr
add x9,sp,#1264
ldr d1,[x9,x23,lsl #3]
fcmp d1,#0.0
b.eq .Lppsta_zero_gradient
movz x9,#0
movk x9,#0,lsl #16
movk x9,#0,lsl #32
movk x9,#16368,lsl #48
fmov d0,x9
fdiv d0,d0,d1
.Lppsta_zero_gradient:
add x9,sp,#1504
str d0,[x9,x23,lsl #3]
add x23,x23,#1
cmp x23,#9
b.lt .Lppsta_coeff
mov x23,#0
.Lppsta_class_level:
mov x24,x21
.Lppsta_class_cell:
madd x26,x23,x20,x24
ldr x9,[x19,#48]
ldr d0,[x9,x26,lsl #3]
mov x25,#0
add x9,sp,#1184
.Lppsta_class_layer:
add x10,x25,#1
ldr d1,[x9,x10,lsl #3]
fcmp d0,d1
b.ge .Lppsta_class_done
add x25,x25,#1
cmp x25,#8
b.lt .Lppsta_class_layer
.Lppsta_class_done:
add x9,sp,#1664
str w25,[x9,x26,lsl #2]
add x24,x24,#1
cmp x24,x22
b.le .Lppsta_class_cell
add x23,x23,#1
cmp x23,x27
b.lt .Lppsta_class_level
adrp x9,:got:__yomcst_MOD_rd
ldr x9,[x9,:got_lo12:__yomcst_MOD_rd]
ldr d0,[x9]
adrp x9,:got:__yomcst_MOD_rg
ldr x9,[x9,:got_lo12:__yomcst_MOD_rg]
ldr d1,[x9]
fdiv d0,d0,d1
str d0,[sp,#1592]
mov x23,#0
.Lppsta_eval_level:
mov x24,x21
.Lppsta_eval_cell:
madd x26,x23,x20,x24
add x9,sp,#1664
ldrsw x25,[x9,x26,lsl #2]
add x9,sp,#1264
ldr d1,[x9,x25,lsl #3]
fcmp d1,#0.0
b.eq .Lppsta_eval_isothermal
fneg d1,d1
ldr d2,[sp,#1592]
fmul d1,d1,d2
ldr x9,[x19,#48]
ldr d0,[x9,x26,lsl #3]
add x9,sp,#1344
ldr d2,[x9,x25,lsl #3]
fmul d0,d0,d2
CALL pow
movz x9,#0
movk x9,#0,lsl #16
movk x9,#0,lsl #32
movk x9,#16368,lsl #48
fmov d1,x9
fsub d0,d0,d1
add x9,sp,#1104
ldr d1,[x9,x25,lsl #3]
add x9,sp,#1504
ldr d2,[x9,x25,lsl #3]
fmul d1,d1,d2
fmul d0,d1,d0
add x9,sp,#1024
ldr d2,[x9,x25,lsl #3]
fadd d0,d2,d0
fsub d2,d0,d2
add x9,sp,#1264
ldr d3,[x9,x25,lsl #3]
fmul d2,d3,d2
add x9,sp,#1104
ldr d1,[x9,x25,lsl #3]
fadd d1,d1,d2
b .Lppsta_eval_store
.Lppsta_eval_isothermal:
add x9,sp,#1104
ldr d1,[x9,x25,lsl #3]
ldr d2,[sp,#1592]
fmul d2,d1,d2
ldr x9,[x19,#56]
ldr d3,[x9,x26,lsl #3]
add x9,sp,#1424
ldr d4,[x9,x25,lsl #3]
fsub d3,d3,d4
fmul d2,d2,d3
add x9,sp,#1024
ldr d0,[x9,x25,lsl #3]
fsub d0,d0,d2
.Lppsta_eval_store:
ldr x9,[x19,#64]
str d1,[x9,x26,lsl #3]
adrp x9,:got:__yomcst_MOD_rg
ldr x9,[x9,:got_lo12:__yomcst_MOD_rg]
ldr d2,[x9]
fmul d0,d0,d2
ldr x9,[x19,#72]
str d0,[x9,x26,lsl #3]
add x24,x24,#1
cmp x24,x22
b.le .Lppsta_eval_cell
add x23,x23,#1
cmp x23,x27
b.lt .Lppsta_eval_level
adrp x9,:got:__yomhook_MOD_lhook
ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
ldr w9,[x9]
cbz w9,.Lppsta_hook_skip_1
adr x0,.Lppsta_name
adr x1,.Lphase1
add x2,sp,#784
mov x3,#5
CALL __yomhook_MOD_dr_hook_default8
.Lppsta_hook_skip_1:
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
.size md2asm_ppsta_7358525,.-md2asm_ppsta_7358525
.Lppsta_reject:
brk #405
.global md2asm_ppintp_7358525
.type md2asm_ppintp_7358525,%function
md2asm_ppintp_7358525:
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
b.ne .Lppintp_reject
ldr x9,[x19,#8]
ldrsw x21,[x9]
cmp x21,#1
b.ne .Lppintp_reject
sub x21,x21,#1
ldr x9,[x19,#16]
ldrsw x22,[x9]
cmp x22,#24
b.eq .Lppintp_end_shape
cmp x22,#8
b.ne .Lppintp_reject
.Lppintp_end_shape:
sub x22,x22,#1
ldr x9,[x19,#24]
ldrsw x9,[x9]
cmp x9,#19
b.ne .Lppintp_reject
ldr x9,[x19,#48]
ldrsw x9,[x9]
cmp x9,#4
b.ne .Lppintp_reject
ldr x9,[x19,#32]
ldrsw x27,[x9]
cmp x27,#4
b.eq .Lppintp_out_shape
cmp x27,#19
b.ne .Lppintp_reject
.Lppintp_out_shape:
ldr x9,[x19,#40]
ldrsw x9,[x9]
cmp x9,#1
b.ne .Lppintp_reject
ldr x9,[x19,#64]
ldrsw x28,[x9]
cmp x28,#2
b.ne .Lppintp_reject
adrp x9,:got:__yomhook_MOD_lhook
ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
ldr w9,[x9]
cbz w9,.Lppintp_hook_skip_0
adr x0,.Lppintp_name
adr x1,.Lphase0
add x2,sp,#784
mov x3,#6
CALL __yomhook_MOD_dr_hook_default8
.Lppintp_hook_skip_0:
mov x23,#0
.Lppintp_level:
mov x24,x21
.Lppintp_cell:
madd x26,x23,x20,x24
ldr x9,[x19,#80]
ldr w10,[x9,x23,lsl #2]
cbz w10,.Lppintp_eval
ldr x9,[x19,#72]
ldr w10,[x9,x26,lsl #2]
cbnz w10,.Lppintp_next
.Lppintp_eval:
mul x9,x20,x27
add x9,x26,x9
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
add x9,x9,#480
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
.Lppintp_next:
add x24,x24,#1
cmp x24,x22
b.le .Lppintp_cell
add x23,x23,#1
cmp x23,x27
b.lt .Lppintp_level
adrp x9,:got:__yomhook_MOD_lhook
ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
ldr w9,[x9]
cbz w9,.Lppintp_hook_skip_1
adr x0,.Lppintp_name
adr x1,.Lphase1
add x2,sp,#784
mov x3,#6
CALL __yomhook_MOD_dr_hook_default8
.Lppintp_hook_skip_1:
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
.size md2asm_ppintp_7358525,.-md2asm_ppintp_7358525
.Lppintp_reject:
brk #405
.global md2asm_ppt_7358525
.type md2asm_ppt_7358525,%function
md2asm_ppt_7358525:
mov x16,sp
sub sp,sp,#24576

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
ldr x9,[x16,#64]
str x9,[x19,#128]
ldr x9,[x16,#72]
str x9,[x19,#136]
ldr x9,[x16,#80]
str x9,[x19,#144]
ldr x9,[x16,#88]
str x9,[x19,#152]
ldr x9,[x16,#96]
str x9,[x19,#160]
ldr x9,[x16,#104]
str x9,[x19,#168]
ldr x9,[x16,#112]
str x9,[x19,#176]
ldr x9,[x16,#120]
str x9,[x19,#184]
ldr x9,[x16,#128]
str x9,[x19,#192]
ldr x9,[x16,#136]
str x9,[x19,#200]
ldr x9,[x19,#0]
ldrsw x20,[x9]
cmp x20,#24
b.ne .Lppt_reject
ldr x9,[x19,#8]
ldrsw x21,[x9]
cmp x21,#1
b.ne .Lppt_reject
sub x21,x21,#1
ldr x9,[x19,#16]
ldrsw x22,[x9]
cmp x22,#24
b.eq .Lppt_end_shape
cmp x22,#8
b.ne .Lppt_reject
.Lppt_end_shape:
sub x22,x22,#1
ldr x9,[x19,#24]
ldrsw x9,[x9]
cmp x9,#19
b.ne .Lppt_reject
ldr x9,[x19,#48]
ldrsw x9,[x9]
cmp x9,#4
b.ne .Lppt_reject
ldr x9,[x19,#32]
ldrsw x27,[x9]
cmp x27,#4
b.eq .Lppt_out_shape
cmp x27,#19
b.ne .Lppt_reject
.Lppt_out_shape:
ldr x9,[x19,#40]
ldrsw x9,[x9]
cmp x9,#1
b.ne .Lppt_reject
ldr x9,[x19,#184]
cbz x9,.Lppt_reject
ldr x9,[x19,#192]
cbnz x9,.Lppt_reject
ldr x9,[x19,#200]
cbnz x9,.Lppt_reject
adrp x9,:got:__yomct0_MOD_loldpp
ldr x9,[x9,:got_lo12:__yomct0_MOD_loldpp]
ldr w9,[x9]
cbnz w9,.Lppt_reject
adrp x9,:got:__yomhook_MOD_lhook
ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
ldr w9,[x9]
cbz w9,.Lppt_hook_skip_0
adr x0,.Lppt_name
adr x1,.Lphase0
add x2,sp,#784
mov x3,#3
CALL __yomhook_MOD_dr_hook_default8
.Lppt_hook_skip_0:
mov x23,#1
.Lppt_departure_level:
mov x24,x21
.Lppt_departure_cell:
madd x26,x23,x20,x24
sub x10,x26,x20
ldr x9,[x19,#168]
ldr d0,[x9,x10,lsl #3]
mov x9,#19648
add x9,sp,x9
str d0,[x9,x26,lsl #3]
ldr x9,[x19,#184]
ldr d1,[x9,x26,lsl #3]
adrp x9,:got:__yomcst_MOD_rd
ldr x9,[x9,:got_lo12:__yomcst_MOD_rd]
ldr d2,[x9]
fmul d1,d1,d2
ldr x9,[x19,#160]
ldr d2,[x9,x10,lsl #3]
fdiv d1,d1,d2
fsub d0,d0,d1
add x9,sp,#4096
str d0,[x9,x26,lsl #3]
mov x9,#7936
add x9,sp,x9
str d2,[x9,x26,lsl #3]
add x24,x24,#1
cmp x24,x22
b.le .Lppt_departure_cell
add x23,x23,#1
cmp x23,#19
b.le .Lppt_departure_level
ldr x9,[x19,#0]
str x9,[sp,#8]
ldr x9,[x19,#8]
str x9,[sp,#16]
ldr x9,[x19,#16]
str x9,[sp,#24]
ldr x9,[x19,#32]
str x9,[sp,#32]
ldr x9,[x19,#40]
str x9,[sp,#40]
ldr x9,[x19,#64]
str x9,[sp,#48]
ldr x9,[x19,#72]
str x9,[sp,#56]
ldr x9,[x19,#176]
str x9,[sp,#64]
adr x9,.Lppref
str x9,[sp]
mov x9,#15616
add x9,sp,x9
str x9,[sp,#72]
mov x9,#5
str x9,[sp,#80]
ldr x0,[sp,#0]
ldr x1,[sp,#8]
ldr x2,[sp,#16]
ldr x3,[sp,#24]
ldr x4,[sp,#32]
ldr x5,[sp,#40]
ldr x6,[sp,#48]
ldr x7,[sp,#56]
ldr x9,[sp,#64]
str x9,[sp,#0]
ldr x9,[sp,#72]
str x9,[sp,#8]
ldr x9,[sp,#80]
str x9,[sp,#16]
str x18,[sp,#696]
.reloc ., R_AARCH64_CALL26, md2asm_ppsta_7358525
.inst 0x94000000
ldr x18,[sp,#696]
mov x24,x21
.Lppt_top_copy:
add x10,x24,x20
add x9,sp,#4096
ldr d0,[x9,x10,lsl #3]
str d0,[x9,x24,lsl #3]
mov x9,#7936
add x9,sp,x9
ldr d0,[x9,x10,lsl #3]
str d0,[x9,x24,lsl #3]
add x24,x24,#1
cmp x24,x22
b.le .Lppt_top_copy
mov w9,#2
str w9,[sp,#816]
ldr x9,[x19,#0]
str x9,[sp,#1024]
ldr x9,[x19,#8]
str x9,[sp,#1032]
ldr x9,[x19,#16]
str x9,[sp,#1040]
ldr x9,[x19,#24]
str x9,[sp,#1048]
ldr x9,[x19,#32]
str x9,[sp,#1056]
ldr x9,[x19,#40]
str x9,[sp,#1064]
ldr x9,[x19,#48]
str x9,[sp,#1072]
ldr x9,[x19,#56]
str x9,[sp,#1080]
add x9,sp,#816
str x9,[sp]
ldr x9,[x19,#80]
str x9,[sp,#8]
ldr x9,[x19,#96]
str x9,[sp,#16]
ldr x9,[x19,#64]
str x9,[sp,#24]
ldr x9,[x19,#128]
str x9,[sp,#32]
ldr x9,[x19,#136]
str x9,[sp,#40]
mov x9,#7936
add x9,sp,x9
str x9,[sp,#48]
mov x9,#11776
add x9,sp,x9
str x9,[sp,#56]
ldr x0,[sp,#1024]
ldr x1,[sp,#1032]
ldr x2,[sp,#1040]
ldr x3,[sp,#1048]
ldr x4,[sp,#1056]
ldr x5,[sp,#1064]
ldr x6,[sp,#1072]
ldr x7,[sp,#1080]
str x18,[sp,#696]
.reloc ., R_AARCH64_CALL26, md2asm_ppintp_7358525
.inst 0x94000000
ldr x18,[sp,#696]
mov x23,#0
.Lppt_quad_level:
mov x24,x21
.Lppt_quad_cell:
madd x26,x23,x20,x24
ldr x9,[x19,#96]
ldr w10,[x9,x23,lsl #2]
cbz w10,.Lppt_quad_eval
ldr x9,[x19,#80]
ldr w10,[x9,x26,lsl #2]
cbz w10,.Lppt_quad_eval
ldr x9,[x19,#88]
ldr w10,[x9,x26,lsl #2]
cbnz w10,.Lppt_quad_next
adrp x9,:got:__yomppvi_MOD_lnots_t
ldr x9,[x9,:got_lo12:__yomppvi_MOD_lnots_t]
ldr w9,[x9]
cbz w9,.Lppt_surface_temp_interp
ldr x9,[x19,#72]
ldr d0,[x9,x26,lsl #3]
mov x10,#19
madd x10,x10,x20,x24
add x10,x10,#1440
ldr x9,[x19,#128]
ldr d1,[x9,x10,lsl #3]
fsub d0,d0,d1
sub x11,x10,x20
ldr d2,[x9,x11,lsl #3]
fsub d2,d1,d2
fdiv d0,d0,d2
mov x10,#19
madd x10,x10,x20,x24
mov x9,#19648
add x9,sp,x9
ldr d1,[x9,x10,lsl #3]
sub x10,x10,x20
ldr d2,[x9,x10,lsl #3]
fsub d2,d1,d2
fmul d0,d0,d2
fadd d0,d1,d0
b .Lppt_quad_store
.Lppt_surface_temp_interp:
mov x10,#19
madd x10,x10,x20,x24
add x11,x10,#960
ldr x9,[x19,#128]
ldr d0,[x9,x11,lsl #3]
ldr x9,[x19,#72]
ldr d1,[x9,x26,lsl #3]
fsub d1,d0,d1
add x11,x10,#1440
ldr x9,[x19,#128]
ldr d2,[x9,x11,lsl #3]
fsub d0,d0,d2
fdiv d0,d1,d0
ldr x9,[x19,#144]
ldr d1,[x9,x24,lsl #3]
mov x9,#19648
add x9,sp,x9
ldr d2,[x9,x10,lsl #3]
fsub d2,d2,d1
fmul d0,d0,d2
fadd d0,d1,d0
b .Lppt_quad_store
.Lppt_quad_eval:
mul x9,x20,x27
add x9,x9,x9,lsl #1
add x9,x26,x9
ldr x10,[x19,#56]
ldrsw x25,[x10,x9,lsl #2]
madd x10,x25,x20,x24
add x11,x10,#1440
ldr x9,[x19,#128]
ldr d0,[x9,x11,lsl #3]
ldr x9,[x19,#72]
ldr d1,[x9,x26,lsl #3]
fsub d1,d0,d1
sub x12,x11,x20
ldr x9,[x19,#128]
ldr d2,[x9,x12,lsl #3]
fsub d3,d0,d2
fdiv d1,d1,d3
fadd d2,d2,d0
sub x12,x10,x20
add x12,x12,#960
ldr d4,[x9,x12,lsl #3]
movz x9,#0
movk x9,#0,lsl #16
movk x9,#0,lsl #32
movk x9,#16384,lsl #48
fmov d5,x9
fmul d4,d5,d4
fsub d2,d2,d4
fdiv d2,d2,d3
movz x9,#0
movk x9,#0,lsl #16
movk x9,#0,lsl #32
movk x9,#16392,lsl #48
fmov d3,x9
fmul d2,d3,d2
fmul d2,d2,d1
movz x9,#0
movk x9,#0,lsl #16
movk x9,#0,lsl #32
movk x9,#16368,lsl #48
fmov d3,x9
fsub d3,d1,d3
fmul d2,d2,d3
fadd d1,d1,d2
add x9,sp,#4096
ldr d2,[x9,x10,lsl #3]
sub x11,x10,x20
ldr d3,[x9,x11,lsl #3]
fsub d3,d3,d2
fmul d1,d3,d1
ldr x9,[x19,#176]
ldr d0,[x9,x26,lsl #3]
adrp x9,:got:__yomcst_MOD_rd
ldr x9,[x9,:got_lo12:__yomcst_MOD_rd]
ldr d3,[x9]
fmul d0,d0,d3
mov x9,#11776
add x9,sp,x9
ldr d3,[x9,x26,lsl #3]
fdiv d0,d0,d3
fadd d0,d0,d2
fadd d0,d0,d1
.Lppt_quad_store:
ldr x9,[x19,#176]
str d0,[x9,x26,lsl #3]
.Lppt_quad_next:
add x24,x24,#1
cmp x24,x22
b.le .Lppt_quad_cell
add x23,x23,#1
cmp x23,x27
b.lt .Lppt_quad_level
ldr x9,[x19,#112]
ldr w9,[x9]
cbz w9,.Lppt_no_extrap
adrp x9,:got:__yomcst_MOD_rg
ldr x9,[x9,:got_lo12:__yomcst_MOD_rg]
ldr d0,[x9]
movz x9,#0
movk x9,#0,lsl #16
movk x9,#16384,lsl #32
movk x9,#16543,lsl #48
fmov d1,x9
fmul d1,d1,d0
str d1,[sp,#856]
movz x9,#0
movk x9,#0,lsl #16
movk x9,#34816,lsl #32
movk x9,#16547,lsl #48
fmov d2,x9
fmul d2,d2,d0
fsub d2,d2,d1
movz x9,#0
movk x9,#0,lsl #16
movk x9,#0,lsl #32
movk x9,#16368,lsl #48
fmov d1,x9
fdiv d1,d1,d2
str d1,[sp,#872]
adrp x9,:got:__yomsta_MOD_rdtdz1
ldr x9,[x9,:got_lo12:__yomsta_MOD_rdtdz1]
ldr d1,[x9]
fneg d1,d1
adrp x9,:got:__yomcst_MOD_rd
ldr x9,[x9,:got_lo12:__yomcst_MOD_rd]
ldr d2,[x9]
fmul d1,d1,d2
fdiv d1,d1,d0
str d1,[sp,#880]
mov x24,x21
.Lppt_alpha_cell:
ldr x9,[x19,#120]
ldr d0,[x9,x24,lsl #3]
ldr d1,[sp,#856]
fsub d2,d0,d1
ldr d3,[sp,#872]
fmul d2,d2,d3
fmov d3,xzr
fmaxnm d2,d3,d2
movz x9,#0
movk x9,#0,lsl #16
movk x9,#0,lsl #32
movk x9,#16368,lsl #48
fmov d3,x9
fminnm d2,d3,d2
adrp x9,:got:__yomcst_MOD_rd
ldr x9,[x9,:got_lo12:__yomcst_MOD_rd]
ldr d3,[x9]
fmul d2,d3,d2
movz x9,#0
movk x9,#0,lsl #16
movk x9,#40960,lsl #32
movk x9,#16498,lsl #48
fmov d3,x9
ldr x9,[x19,#152]
ldr d4,[x9,x24,lsl #3]
fsub d3,d3,d4
fmov d4,xzr
fminnm d3,d4,d3
fmul d2,d2,d3
fmaxnm d0,d0,d1
fdiv d2,d2,d0
ldr d1,[sp,#880]
fadd d2,d1,d2
fmaxnm d2,d4,d2
mov x9,#19456
add x9,sp,x9
str d2,[x9,x24,lsl #3]
add x24,x24,#1
cmp x24,x22
b.le .Lppt_alpha_cell
mov x23,#0
.Lppt_extrap_level:
ldr x9,[x19,#104]
ldr w9,[x9,x23,lsl #2]
cbz w9,.Lppt_extrap_next_level
mov x24,x21
.Lppt_extrap_cell:
madd x26,x23,x20,x24
ldr x9,[x19,#88]
ldr w9,[x9,x26,lsl #2]
cbz w9,.Lppt_extrap_next_cell
ldr x9,[x19,#72]
ldr d0,[x9,x26,lsl #3]
mov x10,#19
madd x10,x10,x20,x24
add x10,x10,#960
ldr x9,[x19,#128]
ldr d1,[x9,x10,lsl #3]
fsub d0,d0,d1
mov x9,#19456
add x9,sp,x9
ldr d1,[x9,x24,lsl #3]
fmul d0,d1,d0
movz x9,#0
movk x9,#0,lsl #16
movk x9,#0,lsl #32
movk x9,#16408,lsl #48
fmov d1,x9
fdiv d1,d0,d1
movz x9,#0
movk x9,#0,lsl #16
movk x9,#0,lsl #32
movk x9,#16352,lsl #48
fmov d2,x9
fadd d1,d2,d1
fmul d1,d1,d0
movz x9,#0
movk x9,#0,lsl #16
movk x9,#0,lsl #32
movk x9,#16368,lsl #48
fmov d2,x9
fadd d1,d2,d1
fmul d1,d1,d0
fadd d1,d2,d1
ldr x9,[x19,#144]
ldr d0,[x9,x24,lsl #3]
fmul d0,d0,d1
ldr x9,[x19,#176]
str d0,[x9,x26,lsl #3]
.Lppt_extrap_next_cell:
add x24,x24,#1
cmp x24,x22
b.le .Lppt_extrap_cell
.Lppt_extrap_next_level:
add x23,x23,#1
cmp x23,x27
b.lt .Lppt_extrap_level
b .Lppt_finished
.Lppt_no_extrap:
mov x23,#0
.Lppt_flat_level:
ldr x9,[x19,#104]
ldr w9,[x9,x23,lsl #2]
cbz w9,.Lppt_flat_next_level
mov x24,x21
.Lppt_flat_cell:
madd x26,x23,x20,x24
ldr x9,[x19,#88]
ldr w9,[x9,x26,lsl #2]
cbz w9,.Lppt_flat_next_cell
mov x10,#19
madd x10,x10,x20,x24
mov x9,#19648
add x9,sp,x9
ldr d0,[x9,x10,lsl #3]
ldr x9,[x19,#176]
str d0,[x9,x26,lsl #3]
.Lppt_flat_next_cell:
add x24,x24,#1
cmp x24,x22
b.le .Lppt_flat_cell
.Lppt_flat_next_level:
add x23,x23,#1
cmp x23,x27
b.lt .Lppt_flat_level
.Lppt_finished:
adrp x9,:got:__yomhook_MOD_lhook
ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
ldr w9,[x9]
cbz w9,.Lppt_hook_skip_1
adr x0,.Lppt_name
adr x1,.Lphase1
add x2,sp,#784
mov x3,#3
CALL __yomhook_MOD_dr_hook_default8
.Lppt_hook_skip_1:
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
add sp,sp,#24576
ret
.size md2asm_ppt_7358525,.-md2asm_ppt_7358525
.Lppt_reject:
brk #405
.section .rodata
.p2align 3
.Lphase0:
.word 0
.Lphase1:
.word 1
.Lppref:
.ascii "PPREF"
.Lppinit_name:
.ascii "PPINIT"
.Lppflev_name:
.ascii "PPFLEV"
.Lppsta_name:
.ascii "PPSTA"
.Lppintp_name:
.ascii "PPINTP"
.Lppt_name:
.ascii "PPT"
.section .note.GNU-stack,"",%progbits

// Keep the four helper names private while retaining their original call relocations.
.local md2asm_ppinit_7358525
.local md2asm_ppflev_7358525
.local md2asm_ppsta_7358525
.local md2asm_ppintp_7358525
