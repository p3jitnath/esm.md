/* GPU physical setup route. Original interface and ordered arithmetic are preserved.
 * Contract: skills/md2asm-gpu/references/openifs/setup/physical_setup.md
 * Original interfaces: PPFLEV, PPSTA, PPINTP and PPT.
 * Related contract: skills/md2asm-gpu/references/openifs/physics/pressure_coordinates.md
 */
#include "../../support/gpu/preserved_scalar_calls.inc.S"
.text
.p2align 4
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
 str x18,[sp,#696]
 bl __yomhook_MOD_dr_hook_default8
 ldr x18,[sp,#696]
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
 md2asm_gpu_preserved_scalar md2asm_gpu_output_numeric_cell_host,17,d0,destination,d0,real,x16,0,d1
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
 md2asm_gpu_preserved_scalar md2asm_gpu_output_numeric_cell_host,18,d0,destination,d0,real,x16,0,d1
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
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,4,none,comparison,d0,real,x16,0,d1
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
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,4,none,comparison,d0,real,x16,0,d1
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
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d0,destination,d0,real,x16,0,d1
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,4,none,comparison,d0,real,x16,0,zero
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
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,4,none,comparison,d0,real,x16,0,d1
cset w11,gt
ldr x9,[x19,#80]
str w11,[x9,x26,lsl #2]
orr w27,w27,w11
mov x10,#19
madd x10,x10,x20,x24
ldr x9,[x19,#56]
ldr d1,[x9,x10,lsl #3]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,4,none,comparison,d0,real,x16,0,d1
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
 str x18,[sp,#696]
 bl __yomhook_MOD_dr_hook_default8
 ldr x18,[sp,#696]
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
 str x18,[sp,#696]
 bl __yomhook_MOD_dr_hook_default8
 ldr x18,[sp,#696]
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
 str x18,[sp,#696]
 bl log
 ldr x18,[sp,#696]
add x9,sp,#1424
str d0,[x9,x23,lsl #3]
add x9,sp,#1184
ldr d1,[x9,x23,lsl #3]
movz x9,#0
movk x9,#0,lsl #16
movk x9,#0,lsl #32
movk x9,#16368,lsl #48
fmov d0,x9
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d0,destination,d0,real,x16,0,d1
add x9,sp,#1344
str d0,[x9,x23,lsl #3]
fmov d0,xzr
add x9,sp,#1264
ldr d1,[x9,x23,lsl #3]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,4,none,comparison,d1,real,x16,0,zero
b.eq .Lppsta_zero_gradient
movz x9,#0
movk x9,#0,lsl #16
movk x9,#0,lsl #32
movk x9,#16368,lsl #48
fmov d0,x9
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d0,destination,d0,real,x16,0,d1
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
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,4,none,comparison,d0,real,x16,0,d1
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
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d0,destination,d0,real,x16,0,d1
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
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,4,none,comparison,d1,real,x16,0,zero
b.eq .Lppsta_eval_isothermal
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,8,d1,destination,d1,real,x16,0,zero
ldr d2,[sp,#1592]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d1,destination,d1,real,x16,0,d2
ldr x9,[x19,#48]
ldr d0,[x9,x26,lsl #3]
add x9,sp,#1344
ldr d2,[x9,x25,lsl #3]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d0,real,x16,0,d2
 str x18,[sp,#696]
 bl pow
 ldr x18,[sp,#696]
movz x9,#0
movk x9,#0,lsl #16
movk x9,#0,lsl #32
movk x9,#16368,lsl #48
fmov d1,x9
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d0,destination,d0,real,x16,0,d1
add x9,sp,#1104
ldr d1,[x9,x25,lsl #3]
add x9,sp,#1504
ldr d2,[x9,x25,lsl #3]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d1,destination,d1,real,x16,0,d2
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d1,real,x16,0,d0
add x9,sp,#1024
ldr d2,[x9,x25,lsl #3]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d2,real,x16,0,d0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d2,destination,d0,real,x16,0,d2
add x9,sp,#1264
ldr d3,[x9,x25,lsl #3]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d2,destination,d3,real,x16,0,d2
add x9,sp,#1104
ldr d1,[x9,x25,lsl #3]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d1,destination,d1,real,x16,0,d2
b .Lppsta_eval_store
.Lppsta_eval_isothermal:
add x9,sp,#1104
ldr d1,[x9,x25,lsl #3]
ldr d2,[sp,#1592]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d2,destination,d1,real,x16,0,d2
ldr x9,[x19,#56]
ldr d3,[x9,x26,lsl #3]
add x9,sp,#1424
ldr d4,[x9,x25,lsl #3]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d3,destination,d3,real,x16,0,d4
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d2,destination,d2,real,x16,0,d3
add x9,sp,#1024
ldr d0,[x9,x25,lsl #3]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d0,destination,d0,real,x16,0,d2
.Lppsta_eval_store:
ldr x9,[x19,#64]
str d1,[x9,x26,lsl #3]
adrp x9,:got:__yomcst_MOD_rg
ldr x9,[x9,:got_lo12:__yomcst_MOD_rg]
ldr d2,[x9]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d0,real,x16,0,d2
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
 str x18,[sp,#696]
 bl __yomhook_MOD_dr_hook_default8
 ldr x18,[sp,#696]
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
 str x18,[sp,#696]
 bl __yomhook_MOD_dr_hook_default8
 ldr x18,[sp,#696]
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
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d1,destination,d0,real,x16,0,d1
ldr x10,[x19,#88]
ldr d2,[x10,x26,lsl #3]
madd x9,x25,x20,x24
add x9,x9,#480
ldr x10,[x19,#96]
ldr d3,[x10,x9,lsl #3]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d2,destination,d2,real,x16,0,d3
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d1,destination,d1,real,x16,0,d2
sub x9,x9,x20
ldr x10,[x19,#104]
ldr d2,[x10,x9,lsl #3]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d1,destination,d1,real,x16,0,d2
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d0,real,x16,0,d1
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
 str x18,[sp,#696]
 bl __yomhook_MOD_dr_hook_default8
 ldr x18,[sp,#696]
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
.global md2asm_ppt_old_7358525
.type md2asm_ppt_old_7358525,%function
md2asm_ppt_old_7358525:
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
ldr x9,[x19,#0]
ldrsw x20,[x9]
cmp x20,#24
b.ne .Lppt_old_reject
ldr x9,[x19,#8]
ldrsw x21,[x9]
cmp x21,#1
b.ne .Lppt_old_reject
sub x21,x21,#1
ldr x9,[x19,#16]
ldrsw x22,[x9]
cmp x22,#24
b.eq .Lppt_old_end_shape
cmp x22,#8
b.ne .Lppt_old_reject
.Lppt_old_end_shape:
sub x22,x22,#1
ldr x9,[x19,#24]
ldrsw x9,[x9]
cmp x9,#19
b.ne .Lppt_old_reject
ldr x9,[x19,#48]
ldrsw x9,[x9]
cmp x9,#4
b.ne .Lppt_old_reject
ldr x9,[x19,#32]
ldrsw x27,[x9]
cmp x27,#4
b.eq .Lppt_old_output_shape
cmp x27,#19
b.ne .Lppt_old_reject
.Lppt_old_output_shape:
ldr x9,[x19,#40]
ldrsw x9,[x9]
cmp x9,#1
b.ne .Lppt_old_reject
adrp x9,:got:__yomhook_MOD_lhook
ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
ldr w9,[x9]
cbz w9,.Lppt_old_hook_skip_0
adr x0,.Lppt_old_name
adr x1,.Lphase0
add x2,sp,#784
mov x3,#7
 str x18,[sp,#696]
 bl __yomhook_MOD_dr_hook_default8
 ldr x18,[sp,#696]
.Lppt_old_hook_skip_0:
mov x24,x21
.Lppt_old_top:
ldr x9,[x19,#152]
add x10,x24,x20
ldr d0,[x9,x10,lsl #3]
str d0,[x9,x24,lsl #3]
add x24,x24,#1
cmp x24,x22
b.le .Lppt_old_top
mov w9,#2
str w9,[sp,#816]
ldr x9,[x19,#0]
str x9,[sp,#1536]
ldr x9,[x19,#8]
str x9,[sp,#1544]
ldr x9,[x19,#16]
str x9,[sp,#1552]
ldr x9,[x19,#24]
str x9,[sp,#1560]
ldr x9,[x19,#32]
str x9,[sp,#1568]
ldr x9,[x19,#40]
str x9,[sp,#1576]
ldr x9,[x19,#48]
str x9,[sp,#1584]
ldr x9,[x19,#56]
str x9,[sp,#1592]
add x9,sp,#816
str x9,[sp]
ldr x9,[x19,#72]
str x9,[sp,#8]
ldr x9,[x19,#88]
str x9,[sp,#16]
ldr x9,[x19,#64]
str x9,[sp,#24]
ldr x9,[x19,#120]
str x9,[sp,#32]
ldr x9,[x19,#128]
str x9,[sp,#40]
ldr x9,[x19,#152]
str x9,[sp,#48]
ldr x9,[x19,#160]
str x9,[sp,#56]
ldr x0,[sp,#1536]
ldr x1,[sp,#1544]
ldr x2,[sp,#1552]
ldr x3,[sp,#1560]
ldr x4,[sp,#1568]
ldr x5,[sp,#1576]
ldr x6,[sp,#1584]
ldr x7,[sp,#1592]
 str x18,[sp,#696]
 bl md2asm_ppintp_7358525
 ldr x18,[sp,#696]
mov x23,#0
.Lppt_old_lowest_target:
ldr x9,[x19,#88]
ldr w9,[x9,x23,lsl #2]
cbz w9,.Lppt_old_lowest_target_next
mov x24,x21
.Lppt_old_lowest_cell:
madd x26,x23,x20,x24
ldr x9,[x19,#72]
ldr w9,[x9,x26,lsl #2]
cbz w9,.Lppt_old_lowest_cell_next
ldr x9,[x19,#80]
ldr w9,[x9,x26,lsl #2]
cbnz w9,.Lppt_old_lowest_cell_next
mov x10,#19
madd x10,x10,x20,x24
ldr x9,[x19,#120]
ldr d0,[x9,x10,lsl #3]
add x11,x10,#480
ldr d1,[x9,x11,lsl #3]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d1,destination,d0,real,x16,0,d1
ldr x9,[x19,#64]
ldr d2,[x9,x26,lsl #3]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d0,destination,d0,real,x16,0,d2
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d0,destination,d0,real,x16,0,d1
ldr x9,[x19,#136]
ldr d1,[x9,x24,lsl #3]
ldr x9,[x19,#152]
ldr d2,[x9,x10,lsl #3]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d2,destination,d2,real,x16,0,d1
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d0,real,x16,0,d2
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d1,real,x16,0,d0
ldr x9,[x19,#160]
str d0,[x9,x26,lsl #3]
.Lppt_old_lowest_cell_next:
add x24,x24,#1
cmp x24,x22
b.le .Lppt_old_lowest_cell
.Lppt_old_lowest_target_next:
add x23,x23,#1
cmp x23,x27
b.lt .Lppt_old_lowest_target
ldr x9,[x19,#104]
ldr w9,[x9]
cbz w9,.Lppt_old_done
adrp x9,:got:__yomcst_MOD_rg
ldr x9,[x9,:got_lo12:__yomcst_MOD_rg]
ldr d0,[x9]
movz x9,#0
movk x9,#0,lsl #16
movk x9,#16384,lsl #32
movk x9,#16543,lsl #48
fmov d1,x9
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d1,destination,d1,real,x16,0,d0
str d1,[sp,#1240]
movz x9,#0
movk x9,#0,lsl #16
movk x9,#34816,lsl #32
movk x9,#16547,lsl #48
fmov d2,x9
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d2,destination,d2,real,x16,0,d0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d2,destination,d2,real,x16,0,d1
movz x9,#0
movk x9,#0,lsl #16
movk x9,#0,lsl #32
movk x9,#16368,lsl #48
fmov d1,x9
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d1,destination,d1,real,x16,0,d2
str d1,[sp,#1256]
adrp x9,:got:__yomsta_MOD_rdtdz1
ldr x9,[x9,:got_lo12:__yomsta_MOD_rdtdz1]
ldr d1,[x9]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,8,d1,destination,d1,real,x16,0,zero
adrp x9,:got:__yomcst_MOD_rd
ldr x9,[x9,:got_lo12:__yomcst_MOD_rd]
ldr d2,[x9]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d1,destination,d1,real,x16,0,d2
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d1,destination,d1,real,x16,0,d0
str d1,[sp,#1272]
mov x24,x21
.Lppt_old_alpha:
ldr x9,[x19,#144]
ldr d0,[x9,x24,lsl #3]
movz x9,#0
movk x9,#0,lsl #16
movk x9,#40960,lsl #32
movk x9,#16498,lsl #48
fmov d1,x9
 md2asm_gpu_preserved_scalar md2asm_gpu_output_numeric_cell_host,18,d1,destination,d0,real,x16,0,d1
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d1,destination,d1,real,x16,0,d0
ldr x9,[x19,#112]
ldr d0,[x9,x24,lsl #3]
ldr d2,[sp,#1240]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d3,destination,d0,real,x16,0,d2
ldr d4,[sp,#1256]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d3,destination,d3,real,x16,0,d4
fmov d4,xzr
 md2asm_gpu_preserved_scalar md2asm_gpu_output_numeric_cell_host,17,d3,destination,d4,real,x16,0,d3
movz x9,#0
movk x9,#0,lsl #16
movk x9,#0,lsl #32
movk x9,#16368,lsl #48
fmov d5,x9
 md2asm_gpu_preserved_scalar md2asm_gpu_output_numeric_cell_host,18,d3,destination,d5,real,x16,0,d3
adrp x9,:got:__yomcst_MOD_rd
ldr x9,[x9,:got_lo12:__yomcst_MOD_rd]
ldr d5,[x9]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d3,destination,d5,real,x16,0,d3
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d1,destination,d3,real,x16,0,d1
 md2asm_gpu_preserved_scalar md2asm_gpu_output_numeric_cell_host,17,d0,destination,d0,real,x16,0,d2
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d1,destination,d1,real,x16,0,d0
ldr d0,[sp,#1272]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d0,real,x16,0,d1
 md2asm_gpu_preserved_scalar md2asm_gpu_output_numeric_cell_host,17,d0,destination,d4,real,x16,0,d0
add x9,sp,#1024
str d0,[x9,x24,lsl #3]
add x24,x24,#1
cmp x24,x22
b.le .Lppt_old_alpha
mov x23,#0
.Lppt_old_extrap_target:
ldr x9,[x19,#96]
ldr w9,[x9,x23,lsl #2]
cbz w9,.Lppt_old_extrap_target_next
mov x24,x21
.Lppt_old_extrap_cell:
madd x26,x23,x20,x24
ldr x9,[x19,#80]
ldr w9,[x9,x26,lsl #2]
cbz w9,.Lppt_old_extrap_cell_next
ldr x9,[x19,#64]
ldr d0,[x9,x26,lsl #3]
mov x10,#19
madd x10,x10,x20,x24
ldr x9,[x19,#120]
ldr d1,[x9,x10,lsl #3]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d0,destination,d0,real,x16,0,d1
 str x18,[sp,#696]
 bl log
 ldr x18,[sp,#696]
add x9,sp,#1024
ldr d1,[x9,x24,lsl #3]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d1,real,x16,0,d0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d1,destination,d0,real,x16,0,d0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d2,destination,d1,real,x16,0,d0
movz x9,#0
movk x9,#0,lsl #16
movk x9,#0,lsl #32
movk x9,#16368,lsl #48
fmov d3,x9
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d3,real,x16,0,d0
movz x9,#0
movk x9,#0,lsl #16
movk x9,#0,lsl #32
movk x9,#16352,lsl #48
fmov d3,x9
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d1,destination,d3,real,x16,0,d1
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d0,real,x16,0,d1
movz x9,#21845
movk x9,#21845,lsl #16
movk x9,#21845,lsl #32
movk x9,#16325,lsl #48
fmov d3,x9
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d2,destination,d3,real,x16,0,d2
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d0,real,x16,0,d2
ldr x9,[x19,#136]
ldr d1,[x9,x24,lsl #3]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d1,real,x16,0,d0
ldr x9,[x19,#160]
str d0,[x9,x26,lsl #3]
.Lppt_old_extrap_cell_next:
add x24,x24,#1
cmp x24,x22
b.le .Lppt_old_extrap_cell
.Lppt_old_extrap_target_next:
add x23,x23,#1
cmp x23,x27
b.lt .Lppt_old_extrap_target
.Lppt_old_done:
adrp x9,:got:__yomhook_MOD_lhook
ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
ldr w9,[x9]
cbz w9,.Lppt_old_hook_skip_1
adr x0,.Lppt_old_name
adr x1,.Lphase1
add x2,sp,#784
mov x3,#7
 str x18,[sp,#696]
 bl __yomhook_MOD_dr_hook_default8
 ldr x18,[sp,#696]
.Lppt_old_hook_skip_1:
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
.size md2asm_ppt_old_7358525,.-md2asm_ppt_old_7358525
.Lppt_old_reject:
brk #405
.global md2asm_ppt_original_route_7358525
.type md2asm_ppt_original_route_7358525,%function
md2asm_ppt_original_route_7358525:
mov x16,sp
sub sp,sp,#8192
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
b.ne .Lppt_original_route_reject
ldr x9,[x19,#8]
ldrsw x21,[x9]
cmp x21,#1
b.ne .Lppt_original_route_reject
sub x21,x21,#1
ldr x9,[x19,#16]
ldrsw x22,[x9]
cmp x22,#24
b.eq .Lppt_original_route_end_shape
cmp x22,#8
b.ne .Lppt_original_route_reject
.Lppt_original_route_end_shape:
sub x22,x22,#1
ldr x9,[x19,#24]
ldrsw x9,[x9]
cmp x9,#19
b.ne .Lppt_original_route_reject
ldr x9,[x19,#48]
ldrsw x9,[x9]
cmp x9,#4
b.ne .Lppt_original_route_reject
ldr x9,[x19,#32]
ldrsw x27,[x9]
cmp x27,#4
b.eq .Lppt_original_route_output_shape
cmp x27,#19
b.ne .Lppt_original_route_reject
.Lppt_original_route_output_shape:
ldr x9,[x19,#40]
ldrsw x9,[x9]
cmp x9,#1
b.ne .Lppt_original_route_reject
ldr x9,[x19,#192]
cbnz x9,.Lppt_original_route_reject
ldr x9,[x19,#200]
cbnz x9,.Lppt_original_route_reject
adrp x9,:got:__yomct0_MOD_loldpp
ldr x9,[x9,:got_lo12:__yomct0_MOD_loldpp]
ldr w9,[x9]
cmp w9,#1
b.ne .Lppt_original_route_reject
adrp x9,:got:__yomhook_MOD_lhook
ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
ldr w9,[x9]
cbz w9,.Lppt_original_route_hook_skip_0
adr x0,.Lppt_original_route_name
adr x1,.Lphase0
add x2,sp,#784
mov x3,#3
 str x18,[sp,#696]
 bl __yomhook_MOD_dr_hook_default8
 ldr x18,[sp,#696]
.Lppt_original_route_hook_skip_0:
mov x23,#1
.Lppt_original_route_copy_level:
mov x24,x21
.Lppt_original_route_copy_cell:
madd x26,x23,x20,x24
sub x10,x26,x20
ldr x9,[x19,#168]
ldr x11,[x9,x10,lsl #3]
add x9,sp,#4096
str x11,[x9,x26,lsl #3]
add x24,x24,#1
cmp x24,x22
b.le .Lppt_original_route_copy_cell
add x23,x23,#1
cmp x23,#19
b.le .Lppt_original_route_copy_level
ldr x9,[x19,#0]
str x9,[sp,#1536]
ldr x9,[x19,#8]
str x9,[sp,#1544]
ldr x9,[x19,#16]
str x9,[sp,#1552]
ldr x9,[x19,#24]
str x9,[sp,#1560]
ldr x9,[x19,#32]
str x9,[sp,#1568]
ldr x9,[x19,#40]
str x9,[sp,#1576]
ldr x9,[x19,#48]
str x9,[sp,#1584]
ldr x9,[x19,#56]
str x9,[sp,#1592]
ldr x9,[x19,#64]
str x9,[sp,#1600]
ldr x9,[x19,#80]
str x9,[sp,#1608]
ldr x9,[x19,#88]
str x9,[sp,#1616]
ldr x9,[x19,#96]
str x9,[sp,#1624]
ldr x9,[x19,#104]
str x9,[sp,#1632]
ldr x9,[x19,#112]
str x9,[sp,#1640]
ldr x9,[x19,#120]
str x9,[sp,#1648]
ldr x9,[x19,#128]
str x9,[sp,#1656]
ldr x9,[x19,#136]
str x9,[sp,#1664]
ldr x9,[x19,#144]
str x9,[sp,#1672]
ldr x9,[x19,#152]
str x9,[sp,#1680]
add x9,sp,#4096
str x9,[sp,#1688]
ldr x9,[x19,#176]
str x9,[sp,#1696]
ldr x9,[sp,#1600]
str x9,[sp,#0]
ldr x9,[sp,#1608]
str x9,[sp,#8]
ldr x9,[sp,#1616]
str x9,[sp,#16]
ldr x9,[sp,#1624]
str x9,[sp,#24]
ldr x9,[sp,#1632]
str x9,[sp,#32]
ldr x9,[sp,#1640]
str x9,[sp,#40]
ldr x9,[sp,#1648]
str x9,[sp,#48]
ldr x9,[sp,#1656]
str x9,[sp,#56]
ldr x9,[sp,#1664]
str x9,[sp,#64]
ldr x9,[sp,#1672]
str x9,[sp,#72]
ldr x9,[sp,#1680]
str x9,[sp,#80]
ldr x9,[sp,#1688]
str x9,[sp,#88]
ldr x9,[sp,#1696]
str x9,[sp,#96]
ldr x0,[sp,#1536]
ldr x1,[sp,#1544]
ldr x2,[sp,#1552]
ldr x3,[sp,#1560]
ldr x4,[sp,#1568]
ldr x5,[sp,#1576]
ldr x6,[sp,#1584]
ldr x7,[sp,#1592]
 str x18,[sp,#696]
 bl md2asm_ppt_old_7358525
 ldr x18,[sp,#696]
adrp x9,:got:__yomhook_MOD_lhook
ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
ldr w9,[x9]
cbz w9,.Lppt_original_route_hook_skip_1
adr x0,.Lppt_original_route_name
adr x1,.Lphase1
add x2,sp,#784
mov x3,#3
 str x18,[sp,#696]
 bl __yomhook_MOD_dr_hook_default8
 ldr x18,[sp,#696]
.Lppt_original_route_hook_skip_1:
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
add sp,sp,#8192
ret
.size md2asm_ppt_original_route_7358525,.-md2asm_ppt_original_route_7358525
.Lppt_original_route_reject:
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
.Lppt_old_name:
 .ascii "PPT_OLD"
.Lppt_original_route_name:
 .ascii "PPT"
.section .note.GNU-stack,"",%progbits
