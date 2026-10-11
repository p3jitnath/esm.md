// Complete parcel lift and implicit vertical diffusion.
// All arguments are pointers; ordinary operations round separately.
.arch armv8-a
.text
.align 4
.global md2asm_custrat_7240564
.type md2asm_custrat_7240564,%function
md2asm_custrat_7240564:
sub sp,sp,#768
stp x19,x20,[sp,#64]
stp x21,x22,[sp,#80]
stp x23,x24,[sp,#96]
stp x25,x26,[sp,#112]
stp x27,x28,[sp,#128]
stp x29,x30,[sp,#144]
add x29,sp,#144
str x0,[sp,#160]
str x1,[sp,#168]
str x2,[sp,#176]
str x3,[sp,#184]
str x4,[sp,#192]
str x5,[sp,#200]
str x6,[sp,#208]
str x7,[sp,#216]
ldr x9,[sp,#768]
str x9,[sp,#224]
ldr x9,[sp,#776]
str x9,[sp,#232]
ldr x9,[sp,#784]
str x9,[sp,#240]
ldr x9,[sp,#792]
str x9,[sp,#248]
ldr x9,[sp,#800]
str x9,[sp,#256]
ldr x9,[sp,#808]
str x9,[sp,#264]
ldr x9,[sp,#816]
str x9,[sp,#272]
ldr x9,[sp,#824]
str x9,[sp,#280]
ldr x9,[sp,#832]
str x9,[sp,#288]
mrs x9,fpcr
cbnz x9,L_bad
ldr x9,[sp,#184]
ldrsw x21,[x9]
cmp x21,#1
b.lt L_bad
mov x10,#4096
cmp x21,x10
b.gt L_bad
ldr x9,[sp,#192]
ldrsw x22,[x9]
cmp x22,#4
b.lt L_bad
cmp x22,#137
b.gt L_bad
ldr x9,[sp,#168]
ldrsw x28,[x9]
sub x28,x28,#1
cmp x28,#0
b.lt L_bad
cmp x28,x21
b.gt L_bad
ldr x9,[sp,#176]
ldrsw x26,[x9]
cmp x26,#0
b.lt L_bad
cmp x26,x21
b.gt L_bad
lsl x27,x21,#3
lsr x19,x22,#1
sub x19,x19,#1
str w19,[sp,#552]
adrp x9,:got:__yomcst_MOD_rg
ldr x9,[x9,:got_lo12:__yomcst_MOD_rg]
ldr d0,[x9]
str d0,[sp,#376]
adrp x9,:got:__yomcst_MOD_rd
ldr x9,[x9,:got_lo12:__yomcst_MOD_rd]
ldr d0,[x9]
str d0,[sp,#384]
adrp x9,:got:__yomcst_MOD_rcpd
ldr x9,[x9,:got_lo12:__yomcst_MOD_rcpd]
ldr d0,[x9]
str d0,[sp,#392]
adrp x9,:got:__yomcst_MOD_retv
ldr x9,[x9,:got_lo12:__yomcst_MOD_retv]
ldr d0,[x9]
str d0,[sp,#400]
ldr x9,[sp,#216]
ldr d0,[x9]
str d0,[sp,#328]
adrp x9,C_0000000000000000
ldr d1,[x9,:lo12:C_0000000000000000]
fcmp d0,d1
b.le L_bad
adrp x9,C_3ff0000000000000
ldr d1,[x9,:lo12:C_3ff0000000000000]
fcmp d0,d1
b.hi L_bad
ldr x9,[sp,#208]
ldr d0,[x9]
str d0,[sp,#344]
adrp x9,C_0000000000000000
ldr d1,[x9,:lo12:C_0000000000000000]
fcmp d0,d1
b.le L_bad
adrp x9,C_40f5180000000000
ldr d1,[x9,:lo12:C_40f5180000000000]
fcmp d0,d1
b.hi L_bad
ldr d0,[sp,#376]
adrp x9,C_0000000000000000
ldr d1,[x9,:lo12:C_0000000000000000]
fcmp d0,d1
b.le L_bad
b.vs L_bad
ldr d0,[sp,#384]
adrp x9,C_0000000000000000
ldr d1,[x9,:lo12:C_0000000000000000]
fcmp d0,d1
b.le L_bad
b.vs L_bad
ldr d0,[sp,#392]
adrp x9,C_0000000000000000
ldr d1,[x9,:lo12:C_0000000000000000]
fcmp d0,d1
b.le L_bad
b.vs L_bad
adrp x9,C_3ff0000000000000
ldr d0,[x9,:lo12:C_3ff0000000000000]
ldr d1,[sp,#328]
fdiv d0,d0,d1
str d0,[sp,#336]
ldr d0,[sp,#328]
ldr d1,[sp,#344]
fmul d0,d0,d1
ldr d1,[sp,#376]
ldr d2,[sp,#376]
fmul d1,d1,d2
fmul d0,d0,d1
adrp x9,C_3fe0000000000000
ldr d1,[x9,:lo12:C_3fe0000000000000]
ldr d2,[sp,#384]
fmul d1,d1,d2
fdiv d0,d0,d1
str d0,[sp,#352]
adrp x9,C_3ff0000000000000
ldr d0,[x9,:lo12:C_3ff0000000000000]
ldr d1,[sp,#344]
fdiv d0,d0,d1
str d0,[sp,#360]
ldr d0,[sp,#344]
ldr d1,[sp,#392]
fmul d0,d0,d1
str d0,[sp,#368]
cmp x28,x26
b.ge L_return
ldr x9,[sp,#160]
ldr w10,[x9,#4]
cbnz w10,L_bad
mov x23,#0
L_level_1:
cmp x23,x22
b.ge L_level_1_done
mov x24,x28
L_col_2:
cmp x24,x26
b.ge L_col_2_done
madd x25,x23,x21,x24
lsl x25,x25,#3
ldr x9,[sp,#248]
ldr d0,[x9,x25]
adrp x9,C_4061800000000000
ldr d1,[x9,:lo12:C_4061800000000000]
fcmp d0,d1
b.lt L_bad
b.vs L_bad
adrp x9,C_4076800000000000
ldr d1,[x9,:lo12:C_4076800000000000]
fcmp d0,d1
b.gt L_bad
ldr x9,[sp,#240]
ldr d0,[x9,x25]
adrp x9,C_0000000000000000
ldr d1,[x9,:lo12:C_0000000000000000]
fcmp d0,d1
b.lt L_bad
b.vs L_bad
adrp x9,C_413e848000000000
ldr d1,[x9,:lo12:C_413e848000000000]
fcmp d0,d1
b.gt L_bad
ldrsw x9,[sp,#552]
cmp x23,x9
b.lt L_guard_lower_done
ldr x9,[sp,#256]
ldr d0,[x9,x25]
adrp x9,C_0000000000000000
ldr d1,[x9,:lo12:C_0000000000000000]
fcmp d0,d1
b.lt L_bad
b.vs L_bad
adrp x9,C_3fb999999999999a
ldr d1,[x9,:lo12:C_3fb999999999999a]
fcmp d0,d1
b.gt L_bad
ldr x9,[sp,#232]
ldr d0,[x9,x25]
ldr x9,[sp,#232]
add x10,x25,x27
ldr d1,[x9,x10]
fcmp d1,d0
b.le L_bad
b.vs L_bad
adrp x9,C_0000000000000000
ldr d2,[x9,:lo12:C_0000000000000000]
fcmp d0,d2
b.le L_bad
sub x9,x22,#1
cmp x23,x9
b.ge L_guard_lower_done
ldr x9,[sp,#240]
ldr d0,[x9,x25]
ldr x9,[sp,#240]
add x10,x25,x27
ldr d1,[x9,x10]
fcmp d0,d1
b.le L_bad
b.vs L_bad
ldr x9,[sp,#224]
ldr d0,[x9,x25]
adrp x9,C_0000000000000000
ldr d1,[x9,:lo12:C_0000000000000000]
fcmp d0,d1
b.le L_bad
b.vs L_bad
L_guard_lower_done:
add x24,x24,#1
b L_col_2
L_col_2_done:
add x23,x23,#1
b L_level_1
L_level_1_done:
mov x9,#8
mul x9,x9,x22
add x9,x9,#8
mul x0,x9,x27
bl malloc
cbz x0,L_bad
mov x20,x0
mul x19,x22,x27
str x0,[sp,#416]
add x0,x0,x19
str x0,[sp,#424]
add x0,x0,x19
str x0,[sp,#432]
add x0,x0,x19
str x0,[sp,#440]
add x0,x0,x19
str x0,[sp,#448]
add x0,x0,x19
str x0,[sp,#456]
add x0,x0,x19
str x0,[sp,#464]
add x0,x0,x19
str x0,[sp,#472]
add x0,x0,x19
str x0,[sp,#480]
add x0,x0,x27
str x0,[sp,#488]
add x0,x0,x27
str x0,[sp,#496]
add x0,x0,x27
str x0,[sp,#504]
add x0,x0,x27
str x0,[sp,#512]
add x0,x0,x27
str x0,[sp,#520]
add x0,x0,x27
str x0,[sp,#528]
add x0,x0,x27
str x0,[sp,#536]
add x0,x0,x27
mov x23,#0
L_level_3:
cmp x23,x22
b.ge L_level_3_done
mov x24,x28
L_col_4:
cmp x24,x26
b.ge L_col_4_done
madd x25,x23,x21,x24
lsl x25,x25,#3
ldr x9,[sp,#240]
ldr d0,[x9,x25]
ldr x9,[sp,#248]
ldr d1,[x9,x25]
ldr d2,[sp,#392]
fmul d1,d1,d2
fadd d0,d0,d1
ldr x9,[sp,#416]
str d0,[x9,x25]
adrp x9,C_0000000000000000
ldr d0,[x9,:lo12:C_0000000000000000]
ldr x9,[sp,#424]
str d0,[x9,x25]
mov w11,#0
ldr x9,[sp,#472]
lsr x10,x25,#1
str w11,[x9,x10]
add x24,x24,#1
b L_col_4
L_col_4_done:
add x23,x23,#1
b L_level_3
L_level_3_done:
sub x23,x22,#1
mov x24,x28
L_col_5:
cmp x24,x26
b.ge L_col_5_done
madd x25,x23,x21,x24
lsl x25,x25,#3
ldr x9,[sp,#248]
ldr d0,[x9,x25]
adrp x9,C_3fd0000000000000
ldr d1,[x9,:lo12:C_3fd0000000000000]
fadd d0,d0,d1
ldr x9,[sp,#432]
str d0,[x9,x25]
ldr x9,[sp,#256]
ldr d0,[x9,x25]
ldr x9,[sp,#440]
str d0,[x9,x25]
ldr x9,[sp,#200]
ldr w11,[x9,x24,lsl #2]
cmp w11,#0
cset w11,eq
ldr x9,[sp,#472]
lsr x10,x25,#1
str w11,[x9,x10]
mov w11,#0
ldr x9,[sp,#536]
str w11,[x9,x24,lsl #2]
mov w11,#1
ldr x9,[sp,#528]
str w11,[x9,x24,lsl #2]
add x24,x24,#1
b L_col_5
L_col_5_done:
sub x23,x22,#2
L_level_6:
ldrsw x9,[sp,#552]
cmp x23,x9
b.lt L_level_6_done
mov x24,x28
L_col_7:
cmp x24,x26
b.ge L_col_7_done
madd x25,x23,x21,x24
lsl x25,x25,#3
ldr x9,[sp,#224]
ldr d0,[x9,x25]
ldr x9,[sp,#232]
madd x10,x22,x21,x24
ldr d1,[x9,x10,lsl #3]
adrp x9,C_3feccccccccccccd
ldr d2,[x9,:lo12:C_3feccccccccccccd]
fmul d1,d1,d2
fcmp d0,d1
b.ge L_cut_ok
mov w11,#0
ldr x9,[sp,#528]
str w11,[x9,x24,lsl #2]
L_cut_ok:
add x24,x24,#1
b L_col_7
L_col_7_done:
mov x24,x28
L_col_8:
cmp x24,x26
b.ge L_col_8_done
madd x25,x23,x21,x24
lsl x25,x25,#3
ldr x9,[sp,#528]
ldr w11,[x9,x24,lsl #2]
cbz w11,L_lift_inactive
ldr x9,[sp,#432]
add x10,x25,x27
ldr d0,[x9,x10]
ldr d1,[sp,#392]
fmul d0,d0,d1
ldr x9,[sp,#240]
add x10,x25,x27
ldr d1,[x9,x10]
fadd d0,d0,d1
ldr x9,[sp,#240]
ldr d1,[x9,x25]
fsub d0,d0,d1
ldr d1,[sp,#392]
fdiv d0,d0,d1
ldr x9,[sp,#432]
str d0,[x9,x25]
ldr x9,[sp,#440]
add x10,x25,x27
ldr d0,[x9,x10]
ldr x9,[sp,#440]
str d0,[x9,x25]
ldr x9,[sp,#472]
lsr x10,x25,#1
add x10,x10,x21,lsl #2
ldr w11,[x9,x10]
cmp w11,#0
cset w11,gt
ldr x9,[sp,#520]
str w11,[x9,x24,lsl #2]
ldr x9,[sp,#224]
ldr d0,[x9,x25]
ldr x9,[sp,#224]
ldr d0,[x9,x25]
ldr x9,[sp,#512]
str d0,[x9,x24,lsl #3]
ldr x9,[sp,#440]
ldr d0,[x9,x25]
ldr x9,[sp,#504]
str d0,[x9,x24,lsl #3]
b L_lift_done
L_lift_inactive:
mov w11,#0
ldr x9,[sp,#520]
str w11,[x9,x24,lsl #2]
L_lift_done:
add x24,x24,#1
b L_col_8
L_col_8_done:
add w9,w23,#1
str w9,[sp,#320]
mov w9,#1
str w9,[sp,#324]
ldr x0,[sp,#160]
ldr x1,[sp,#168]
ldr x2,[sp,#176]
ldr x3,[sp,#184]
ldr x4,[sp,#192]
add x5,sp,#320
ldr x6,[sp,#512]
ldr x7,[sp,#432]
ldr x9,[sp,#440]
str x9,[sp]
ldr x9,[sp,#520]
str x9,[sp,#8]
add x9,sp,#324
str x9,[sp,#16]
str xzr,[sp,#24]
bl md2asm_cuadjtq
mov x24,x28
L_col_9:
cmp x24,x26
b.ge L_col_9_done
madd x25,x23,x21,x24
lsl x25,x25,#3
ldr x9,[sp,#528]
ldr w11,[x9,x24,lsl #2]
cbz w11,L_buoy_done
ldr x9,[sp,#440]
ldr d0,[x9,x25]
ldr x9,[sp,#504]
ldr d1,[x9,x24,lsl #3]
fcmp d0,d1
b.eq L_q_unchanged
mov w11,#2
ldr x9,[sp,#472]
lsr x10,x25,#1
str w11,[x9,x10]
L_q_unchanged:
ldr x9,[sp,#432]
ldr d0,[x9,x25]
adrp x9,C_3ff0000000000000
ldr d1,[x9,:lo12:C_3ff0000000000000]
ldr d2,[sp,#400]
ldr x9,[sp,#440]
ldr d3,[x9,x25]
fmul d2,d2,d3
fadd d1,d1,d2
fmul d0,d0,d1
ldr x9,[sp,#248]
ldr d1,[x9,x25]
adrp x9,C_3ff0000000000000
ldr d2,[x9,:lo12:C_3ff0000000000000]
ldr d3,[sp,#400]
ldr x9,[sp,#256]
ldr d4,[x9,x25]
fmul d3,d3,d4
fadd d2,d2,d3
fmul d1,d1,d2
fsub d0,d0,d1
adrp x9,C_0000000000000000
ldr d1,[x9,:lo12:C_0000000000000000]
fcmp d0,d1
b.ge L_buoy_nonnegative
mov w11,#0
ldr x9,[sp,#472]
lsr x10,x25,#1
str w11,[x9,x10]
b L_buoy_done
L_buoy_nonnegative:
b.le L_buoy_flag2
ldr x9,[sp,#472]
lsr x10,x25,#1
ldr w11,[x9,x10]
cbnz w11,L_buoy_flag2
ldr x9,[sp,#472]
lsr x10,x25,#1
add x10,x10,x21,lsl #2
ldr w11,[x9,x10]
cmp w11,#1
b.ne L_buoy_flag2
mov w11,#1
ldr x9,[sp,#472]
lsr x10,x25,#1
str w11,[x9,x10]
L_buoy_flag2:
ldr x9,[sp,#472]
lsr x10,x25,#1
ldr w11,[x9,x10]
cmp w11,#2
b.ne L_buoy_done
mov w11,#1
ldr x9,[sp,#536]
str w11,[x9,x24,lsl #2]
L_buoy_done:
add x24,x24,#1
b L_col_9
L_col_9_done:
sub x23,x23,#1
b L_level_6
L_level_6_done:
sub x23,x22,#1
mov x24,x28
L_col_10:
cmp x24,x26
b.ge L_col_10_done
madd x25,x23,x21,x24
lsl x25,x25,#3
mov w11,#1
ldr x9,[sp,#528]
str w11,[x9,x24,lsl #2]
add x24,x24,#1
b L_col_10
L_col_10_done:
sub x23,x22,#2
L_level_11:
ldrsw x9,[sp,#552]
cmp x23,x9
b.lt L_level_11_done
mov x24,x28
L_col_12:
cmp x24,x26
b.ge L_col_12_done
madd x25,x23,x21,x24
lsl x25,x25,#3
ldr x9,[sp,#224]
ldr d0,[x9,x25]
ldr x9,[sp,#232]
madd x10,x22,x21,x24
ldr d1,[x9,x10,lsl #3]
adrp x9,C_3feccccccccccccd
ldr d2,[x9,:lo12:C_3feccccccccccccd]
fmul d1,d1,d2
fcmp d0,d1
b.ge L_exchange_cutok
mov w11,#0
ldr x9,[sp,#528]
str w11,[x9,x24,lsl #2]
L_exchange_cutok:
add x24,x24,#1
b L_col_12
L_col_12_done:
mov x24,x28
L_col_13:
cmp x24,x26
b.ge L_col_13_done
madd x25,x23,x21,x24
lsl x25,x25,#3
ldr x9,[sp,#528]
ldr w11,[x9,x24,lsl #2]
cbz w11,L_coef_done
ldr x9,[sp,#472]
lsr x10,x25,#1
ldr w11,[x9,x10]
cmp w11,#2
b.ne L_coef_zero
adrp x9,C_4024000000000000
ldr d0,[x9,:lo12:C_4024000000000000]
ldr x9,[sp,#472]
sub x10,x22,#3
madd x10,x10,x21,x24
ldr w11,[x9,x10,lsl #2]
cbnz w11,L_coef_cloud
adrp x9,C_4004000000000000
ldr d0,[x9,:lo12:C_4004000000000000]
L_coef_cloud:
ldr x9,[sp,#424]
str d0,[x9,x25]
b L_coef_entrain
L_coef_zero:
adrp x9,C_0000000000000000
ldr d0,[x9,:lo12:C_0000000000000000]
ldr x9,[sp,#424]
str d0,[x9,x25]
L_coef_entrain:
ldr x9,[sp,#424]
add x10,x25,x27
ldr d0,[x9,x10]
adrp x9,C_0000000000000000
ldr d1,[x9,:lo12:C_0000000000000000]
fcmp d0,d1
b.le L_coef_done
ldr x9,[sp,#472]
lsr x10,x25,#1
ldr w11,[x9,x10]
cbnz w11,L_coef_done
ldr x9,[sp,#264]
ldr d0,[x9,x25]
adrp x9,C_0000000000000000
ldr d1,[x9,:lo12:C_0000000000000000]
fcmp d0,d1
b.le L_bad
b.vs L_bad
ldr x9,[sp,#264]
add x10,x25,x27
ldr d0,[x9,x10]
adrp x9,C_0000000000000000
ldr d1,[x9,:lo12:C_0000000000000000]
fcmp d0,d1
b.le L_bad
b.vs L_bad
ldr x9,[sp,#424]
add x10,x25,x27
ldr d0,[x9,x10]
adrp x9,C_4014000000000000
ldr d1,[x9,:lo12:C_4014000000000000]
fmul d0,d0,d1
ldr x9,[sp,#256]
add x10,x25,x27
ldr d1,[x9,x10]
ldr x9,[sp,#264]
add x10,x25,x27
ldr d2,[x9,x10]
fdiv d1,d1,d2
adrp x9,C_3fe999999999999a
ldr d2,[x9,:lo12:C_3fe999999999999a]
fsub d1,d1,d2
adrp x9,C_0000000000000000
ldr d2,[x9,:lo12:C_0000000000000000]
fmaxnm d1,d1,d2
fmul d0,d0,d1
ldr x9,[sp,#256]
add x10,x25,x27
ldr d1,[x9,x10]
ldr x9,[sp,#264]
add x10,x25,x27
ldr d2,[x9,x10]
fdiv d1,d1,d2
ldr x9,[sp,#256]
ldr d2,[x9,x25]
ldr x9,[sp,#264]
ldr d3,[x9,x25]
fdiv d2,d2,d3
fsub d1,d1,d2
adrp x9,C_0000000000000000
ldr d2,[x9,:lo12:C_0000000000000000]
fmaxnm d1,d1,d2
fmul d0,d0,d1
ldr x9,[sp,#424]
str d0,[x9,x25]
mov w11,#0
ldr x9,[sp,#528]
str w11,[x9,x24,lsl #2]
L_coef_done:
add x24,x24,#1
b L_col_13
L_col_13_done:
sub x23,x23,#1
b L_level_11
L_level_11_done:
ldrsw x23,[sp,#552]
L_level_14:
sub x9,x22,#1
cmp x23,x9
b.ge L_level_14_done
mov x24,x28
L_col_15:
cmp x24,x26
b.ge L_col_15_done
madd x25,x23,x21,x24
lsl x25,x25,#3
ldr x9,[sp,#424]
ldr d0,[x9,x25]
ldr d1,[sp,#352]
fmul d0,d0,d1
ldr x9,[sp,#232]
add x10,x25,x27
ldr d1,[x9,x10]
fmul d0,d0,d1
ldr x9,[sp,#240]
ldr d1,[x9,x25]
ldr x9,[sp,#240]
add x10,x25,x27
ldr d2,[x9,x10]
fsub d1,d1,d2
ldr x9,[sp,#248]
ldr d2,[x9,x25]
ldr x9,[sp,#248]
add x10,x25,x27
ldr d3,[x9,x10]
fadd d2,d2,d3
fmul d1,d1,d2
fdiv d0,d0,d1
ldr x9,[sp,#424]
str d0,[x9,x25]
add x24,x24,#1
b L_col_15
L_col_15_done:
add x23,x23,#1
b L_level_14
L_level_14_done:
sub x23,x22,#1
mov x24,x28
L_col_16:
cmp x24,x26
b.ge L_col_16_done
madd x25,x23,x21,x24
lsl x25,x25,#3
ldr d0,[sp,#336]
ldr x9,[sp,#416]
ldr d1,[x9,x25]
fmul d0,d0,d1
ldr x9,[sp,#480]
str d0,[x9,x24,lsl #3]
ldr d0,[sp,#336]
ldr x9,[sp,#256]
ldr d1,[x9,x25]
fmul d0,d0,d1
ldr x9,[sp,#488]
str d0,[x9,x24,lsl #3]
add x24,x24,#1
b L_col_16
L_col_16_done:
ldrsw x23,[sp,#552]
L_level_17:
cmp x23,x22
b.ge L_level_17_done
mov x24,x28
L_col_18:
cmp x24,x26
b.ge L_col_18_done
madd x25,x23,x21,x24
lsl x25,x25,#3
ldr d0,[sp,#336]
ldr x9,[sp,#416]
ldr d1,[x9,x25]
fmul d0,d0,d1
ldr x9,[sp,#448]
str d0,[x9,x25]
ldr d0,[sp,#336]
ldr x9,[sp,#256]
ldr d1,[x9,x25]
fmul d0,d0,d1
ldr x9,[sp,#456]
str d0,[x9,x25]
add x24,x24,#1
b L_col_18
L_col_18_done:
add x23,x23,#1
b L_level_17
L_level_17_done:
ldrsw x23,[sp,#552]
mov x24,x28
L_col_19:
cmp x24,x26
b.ge L_col_19_done
madd x25,x23,x21,x24
lsl x25,x25,#3
ldr x9,[sp,#424]
ldr d0,[x9,x25]
ldr x9,[sp,#496]
str d0,[x9,x24,lsl #3]
adrp x9,C_3ff0000000000000
ldr d0,[x9,:lo12:C_3ff0000000000000]
ldr x9,[sp,#232]
add x10,x25,x27
ldr d1,[x9,x10]
ldr x9,[sp,#232]
ldr d2,[x9,x25]
fsub d1,d1,d2
fdiv d0,d0,d1
str d0,[sp,#560]
ldr x9,[sp,#424]
ldr d0,[x9,x25]
ldr d1,[sp,#560]
fmul d0,d0,d1
adrp x9,C_3ff0000000000000
ldr d1,[x9,:lo12:C_3ff0000000000000]
str d0,[sp,#568]
adrp x9,C_3ff0000000000000
ldr d1,[x9,:lo12:C_3ff0000000000000]
fadd d2,d1,d0
fdiv d2,d1,d2
str d2,[sp,#576]
fmul d0,d2,d0
ldr x9,[sp,#464]
str d0,[x9,x25]
ldr x9,[sp,#456]
ldr d0,[x9,x25]
ldr d1,[sp,#576]
fmul d0,d1,d0
ldr x9,[sp,#456]
str d0,[x9,x25]
ldr x9,[sp,#448]
ldr d0,[x9,x25]
ldr d1,[sp,#576]
fmul d0,d1,d0
ldr x9,[sp,#448]
str d0,[x9,x25]
add x24,x24,#1
b L_col_19
L_col_19_done:
ldrsw x23,[sp,#552]
add x23,x23,#1
L_level_20:
cmp x23,x22
b.ge L_level_20_done
mov x24,x28
L_col_21:
cmp x24,x26
b.ge L_col_21_done
madd x25,x23,x21,x24
lsl x25,x25,#3
adrp x9,C_3ff0000000000000
ldr d0,[x9,:lo12:C_3ff0000000000000]
ldr x9,[sp,#232]
add x10,x25,x27
ldr d1,[x9,x10]
ldr x9,[sp,#232]
ldr d2,[x9,x25]
fsub d1,d1,d2
fdiv d0,d0,d1
str d0,[sp,#560]
ldr x9,[sp,#496]
ldr d1,[x9,x24,lsl #3]
fmul d1,d1,d0
str d1,[sp,#568]
ldr x9,[sp,#424]
ldr d0,[x9,x25]
ldr x9,[sp,#496]
str d0,[x9,x24,lsl #3]
adrp x9,C_3ff0000000000000
ldr d0,[x9,:lo12:C_3ff0000000000000]
ldr x9,[sp,#464]
sub x10,x25,x27
ldr d1,[x9,x10]
fsub d1,d0,d1
ldr d2,[sp,#568]
fmul d1,d2,d1
fadd d1,d0,d1
ldr x9,[sp,#424]
ldr d2,[x9,x25]
ldr d3,[sp,#560]
fmul d2,d2,d3
fadd d1,d1,d2
fdiv d0,d0,d1
str d0,[sp,#576]
fmul d0,d0,d2
ldr x9,[sp,#464]
str d0,[x9,x25]
ldr x9,[sp,#456]
sub x10,x25,x27
ldr d0,[x9,x10]
ldr d1,[sp,#568]
fmul d0,d1,d0
ldr x9,[sp,#456]
ldr d1,[x9,x25]
fadd d0,d1,d0
ldr d1,[sp,#576]
fmul d0,d1,d0
ldr x9,[sp,#456]
str d0,[x9,x25]
ldr x9,[sp,#448]
sub x10,x25,x27
ldr d0,[x9,x10]
ldr d1,[sp,#568]
fmul d0,d1,d0
ldr x9,[sp,#448]
ldr d1,[x9,x25]
fadd d0,d1,d0
ldr d1,[sp,#576]
fmul d0,d1,d0
ldr x9,[sp,#448]
str d0,[x9,x25]
add x24,x24,#1
b L_col_21
L_col_21_done:
add x23,x23,#1
b L_level_20
L_level_20_done:
sub x23,x22,#1
mov x24,x28
L_col_22:
cmp x24,x26
b.ge L_col_22_done
madd x25,x23,x21,x24
lsl x25,x25,#3
ldr x9,[sp,#464]
ldr d0,[x9,x25]
ldr x9,[sp,#488]
ldr d1,[x9,x24,lsl #3]
fmul d0,d0,d1
ldr x9,[sp,#456]
ldr d1,[x9,x25]
fadd d0,d1,d0
ldr x9,[sp,#456]
str d0,[x9,x25]
ldr x9,[sp,#464]
ldr d0,[x9,x25]
ldr x9,[sp,#480]
ldr d1,[x9,x24,lsl #3]
fmul d0,d0,d1
ldr x9,[sp,#448]
ldr d1,[x9,x25]
fadd d0,d1,d0
ldr x9,[sp,#448]
str d0,[x9,x25]
add x24,x24,#1
b L_col_22
L_col_22_done:
sub x23,x22,#2
L_level_23:
ldrsw x9,[sp,#552]
cmp x23,x9
b.lt L_level_23_done
mov x24,x28
L_col_24:
cmp x24,x26
b.ge L_col_24_done
madd x25,x23,x21,x24
lsl x25,x25,#3
ldr x9,[sp,#456]
ldr d0,[x9,x25]
ldr x9,[sp,#464]
ldr d1,[x9,x25]
ldr x9,[sp,#456]
add x10,x25,x27
ldr d2,[x9,x10]
fmul d1,d1,d2
fadd d0,d0,d1
ldr x9,[sp,#456]
str d0,[x9,x25]
ldr x9,[sp,#448]
ldr d0,[x9,x25]
ldr x9,[sp,#464]
ldr d1,[x9,x25]
ldr x9,[sp,#448]
add x10,x25,x27
ldr d2,[x9,x10]
fmul d1,d1,d2
fadd d0,d0,d1
ldr x9,[sp,#448]
str d0,[x9,x25]
add x24,x24,#1
b L_col_24
L_col_24_done:
sub x23,x23,#1
b L_level_23
L_level_23_done:
ldrsw x23,[sp,#552]
L_level_25:
cmp x23,x22
b.ge L_level_25_done
mov x24,x28
L_col_26:
cmp x24,x26
b.ge L_col_26_done
madd x25,x23,x21,x24
lsl x25,x25,#3
ldr x9,[sp,#288]
ldr d0,[x9,x25]
ldr x9,[sp,#456]
ldr d1,[x9,x25]
ldr d2,[sp,#336]
ldr x9,[sp,#256]
ldr d3,[x9,x25]
fmul d2,d2,d3
fsub d1,d1,d2
ldr d2,[sp,#360]
fmul d1,d1,d2
fadd d0,d0,d1
ldr x9,[sp,#288]
str d0,[x9,x25]
ldr x9,[sp,#280]
ldr d0,[x9,x25]
ldr x9,[sp,#448]
ldr d1,[x9,x25]
ldr d2,[sp,#336]
ldr x9,[sp,#416]
ldr d3,[x9,x25]
fmul d2,d2,d3
fsub d1,d1,d2
ldr d2,[sp,#368]
fdiv d1,d1,d2
fadd d0,d0,d1
ldr x9,[sp,#280]
str d0,[x9,x25]
ldr x9,[sp,#448]
ldr d0,[x9,x25]
ldr d1,[sp,#336]
ldr x9,[sp,#416]
ldr d2,[x9,x25]
fmul d1,d1,d2
fsub d0,d0,d1
ldr d1,[sp,#360]
fmul d0,d0,d1
ldr x9,[sp,#272]
str d0,[x9,x25]
add x24,x24,#1
b L_col_26
L_col_26_done:
add x23,x23,#1
b L_level_25
L_level_25_done:
mov x0,x20
bl free
L_return:
ldp x19,x20,[sp,#64]
ldp x21,x22,[sp,#80]
ldp x23,x24,[sp,#96]
ldp x25,x26,[sp,#112]
ldp x27,x28,[sp,#128]
ldp x29,x30,[sp,#144]
add sp,sp,#768
ret
L_bad:
bl abort
brk #0
.size md2asm_custrat_7240564,.-md2asm_custrat_7240564
.section .rodata
.align 3
C_0000000000000000: .quad 0x0000000000000000
C_3ff0000000000000: .quad 0x3ff0000000000000
C_40f5180000000000: .quad 0x40f5180000000000
C_3fe0000000000000: .quad 0x3fe0000000000000
C_4061800000000000: .quad 0x4061800000000000
C_4076800000000000: .quad 0x4076800000000000
C_413e848000000000: .quad 0x413e848000000000
C_3fb999999999999a: .quad 0x3fb999999999999a
C_3fd0000000000000: .quad 0x3fd0000000000000
C_3feccccccccccccd: .quad 0x3feccccccccccccd
C_4024000000000000: .quad 0x4024000000000000
C_4004000000000000: .quad 0x4004000000000000
C_4014000000000000: .quad 0x4014000000000000
C_3fe999999999999a: .quad 0x3fe999999999999a
.section .note.GNU-stack,"",%progbits
