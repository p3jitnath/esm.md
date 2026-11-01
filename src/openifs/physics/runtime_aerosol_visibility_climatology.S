/* Direct AArch64 runtime RADACA with explicit owned constants.
 * Contract: skills/md2asm/references/openifs/physics/runtime_aerosol_visibility_climatology.md.
 * Preserve the original ordered FP64 core and each declared inactive output. */
.text
.p2align 4
.macro CALL target
 stp x18,x30,[sp,#-16]!
 bl \target
 ldp x18,x30,[sp],#16
.endm
.global md2asm_runtime_aerosol_visibility_climatology
.type md2asm_runtime_aerosol_visibility_climatology,%function
md2asm_runtime_aerosol_visibility_climatology:
sub sp,sp,#4096
sub sp,sp,#2048
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
add x16,x16,#2048
mov w9,#8
.Lsave_args:
sub w10,w9,#8
ldr x11,[x16,w10,uxtw #3]
str x11,[x19,w9,uxtw #3]
add w9,w9,#1
cmp w9,#24
b.lt .Lsave_args
mrs x9,fpcr
cbnz x9,.Lreject
ldr x0,[x19,#24]
movz x1,#4
mov x2,#3
mov x3,#3
bl .Lra_span
ldr x0,[x19,#32]
movz x1,#4
mov x2,#3
mov x3,#4
bl .Lra_span
ldr x0,[x19,#40]
movz x1,#4
mov x2,#3
mov x3,#5
bl .Lra_span
ldr x0,[x19,#48]
movz x1,#4
mov x2,#3
mov x3,#6
bl .Lra_span
ldr x8,[x19,#40]
ldr w25,[x8]
ldr x8,[x19,#48]
ldr w26,[x8]
sub w9,w25,#1
cmp w9,#127
b.hi .Lreject
sub w9,w26,#1
cmp w9,#136
b.hi .Lreject
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
b.ne .Lreject
cmp w10,w25
b.ge .Lreject
cmp w10,w9
b.lt .Lreject
ldr x0,[x19,#0]
movz x1,#4232
mov x2,#7
mov x3,#0
bl .Lra_span
ldr x0,[x19,#8]
movz x1,#2040
mov x2,#7
mov x3,#1
bl .Lra_span
ldr x0,[x19,#16]
movz x1,#44904
movk x1,#2,lsl #16
mov x2,#7
mov x3,#2
bl .Lra_span
ldr x0,[x19,#56]
add x1,x26,#1
mul x1,x1,x25
lsl x1,x1,#3
mov x2,#7
mov x3,#7
bl .Lra_span
ldr x0,[x19,#64]
lsl x1,x25,#3
mov x2,#7
mov x3,#8
bl .Lra_span
ldr x0,[x19,#72]
lsl x1,x25,#3
mov x2,#7
mov x3,#9
bl .Lra_span
ldr x0,[x19,#80]
lsl x1,x25,#3
mov x2,#7
mov x3,#10
bl .Lra_span
ldr x0,[x19,#88]
lsl x1,x25,#3
mov x2,#7
mov x3,#11
bl .Lra_span
ldr x0,[x19,#96]
add x1,x26,#1
mul x1,x1,x25
lsl x1,x1,#3
mov x2,#7
mov x3,#12
bl .Lra_span
ldr x0,[x19,#104]
mul x1,x25,x26
mov x9,#48
mul x1,x1,x9
mov x2,#7
mov x3,#13
bl .Lra_span
ldr x0,[x19,#112]
mul x1,x25,x26
mov x9,#96
mul x1,x1,x9
mov x2,#7
mov x3,#14
bl .Lra_span
ldr x0,[x19,#120]
mul x1,x25,x26
lsl x1,x1,#3
mov x2,#7
mov x3,#15
bl .Lra_span
ldr x0,[x19,#128]
lsl x1,x25,#3
mov x2,#7
mov x3,#16
bl .Lra_span
ldr x0,[x19,#136]
lsl x1,x25,#3
mov x2,#7
mov x3,#17
bl .Lra_span
ldr x0,[x19,#144]
lsl x1,x25,#3
mov x2,#7
mov x3,#18
bl .Lra_span
ldr x0,[x19,#152]
lsl x1,x25,#3
mov x2,#7
mov x3,#19
bl .Lra_span
ldr x0,[x19,#160]
lsl x1,x25,#3
mov x2,#7
mov x3,#20
bl .Lra_span
ldr x0,[x19,#168]
lsl x1,x25,#3
mov x2,#7
mov x3,#21
bl .Lra_span
ldr x0,[x19,#176]
lsl x1,x25,#3
mov x2,#7
mov x3,#22
bl .Lra_span
ldr x0,[x19,#184]
movz x1,#16
mov x2,#7
mov x3,#23
bl .Lra_span
mov x9,#27
str x9,[x29,#4048]
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
ldr x9,[x19,#184]
ldr x0,[x9]
mov x1,#520
mov x2,#7
mov x3,#24
bl .Lra_span
ldr w9,[x0,#512]
cmp w9,#1
b.ne .Lreject
ldr x9,[x0]
movz x10,#0x2d18
movk x10,#0x5444,lsl #16
movk x10,#0x21fb,lsl #32
movk x10,#0x4009,lsl #48
cmp x9,x10
b.ne .Lreject
ldr d0,[x0]
str d0,[x29,#544]
ldr x9,[x0,#112]
ubfx x10,x9,#52,#11
cmp x10,#2047
b.eq .Lreject
tbnz x9,#63,.Lreject
cbz x9,.Lreject
ldr d0,[x0,#112]
str d0,[x29,#552]
ldr x9,[x19,#184]
ldr x0,[x9,#8]
mov x1,#16
mov x2,#7
mov x3,#25
bl .Lra_span
ldr x9,[x0,#8]
cbnz x9,.Lreject
ldr x0,[x0]
mov x1,#4
mov x2,#3
mov x3,#26
bl .Lra_span
ldr w9,[x0]
cbnz w9,.Lreject
str wzr,[x29,#3992]
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
bl .Lra_disjoint_and_values
.Lhook0_done:
lsl x9,x25,#9
sub sp,sp,x9
mov x20,sp
mov w9,#66
str w9,[x29,#508]
ldr x8,[x19,#112]
mov w9,#0
mul w10,w25,w26
mov w9,#12
mul w10,w10,w9
mov w9,#0
.Lclear_mass_all:
str xzr,[x8,w9,uxtw #3]
add w9,w9,#1
cmp w9,w10
b.lt .Lclear_mass_all
adrp x17,.Lreals
add x17,x17,:lo12:.Lreals
ldr d0,[x17,#8]
mov w9,#45
scvtf d1,w9
fdiv d0,d0,d1
str d0,[x29,#3640]
mov w24,#0
.Ltegen_latgrid:
adrp x17,.Lreals
add x17,x17,:lo12:.Lreals
ldr d0,[x17,#0]
scvtf d1,w24
ldr d2,[x29,#3640]
fmul d1,d1,d2
fsub d0,d0,d1
ldr d1,[x29,#544]
fmul d0,d0,d1
adrp x17,.Lreals
add x17,x17,:lo12:.Lreals
ldr d1,[x17,#8]
fdiv d0,d0,d1
CALL md2asm_sin_original_rounding
adrp x9,.Lcounts
add x9,x9,:lo12:.Lcounts
ldr x10,[x9,#8]
add x10,x10,#1
str x10,[x9,#8]
add x9,x29,#576
str d0,[x9,w24,uxtw #3]
add w24,w24,#1
cmp w24,#46
b.lt .Ltegen_latgrid
ldr d0,[x29,#544]
fadd d0,d0,d0
mov w9,#72
scvtf d1,w9
fdiv d0,d0,d1
str d0,[x29,#3648]
mov w24,#0
.Ltegen_longrid:
scvtf d0,w24
ldr d1,[x29,#3648]
fmul d0,d0,d1
add x9,x29,#1088
str d0,[x9,w24,uxtw #3]
add w24,w24,#1
cmp w24,#72
b.lt .Ltegen_longrid
ldr w22,[x29,#480]
mov w23,w22
.Ltegen_columns:
add x21,x20,x23,lsl #9
ldr x8,[x19,#72]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#64]
ldr d1,[x8,w22,uxtw #3]
ldr x0,[x29,#3440]
add x1,x29,#576
add x2,x29,#1088
mov w3,#72
mov w4,#46
bl .Linterpolate
str d0,[x21,#0]
ldr x8,[x19,#72]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#64]
ldr d1,[x8,w22,uxtw #3]
ldr x0,[x29,#3448]
add x1,x29,#576
add x2,x29,#1088
mov w3,#72
mov w4,#46
bl .Linterpolate
str d0,[x21,#8]
ldr x8,[x19,#72]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#64]
ldr d1,[x8,w22,uxtw #3]
ldr x0,[x29,#3456]
add x1,x29,#576
add x2,x29,#1088
mov w3,#72
mov w4,#46
bl .Linterpolate
str d0,[x21,#16]
ldr x8,[x19,#72]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#64]
ldr d1,[x8,w22,uxtw #3]
ldr x0,[x29,#3464]
add x1,x29,#576
add x2,x29,#1088
mov w3,#72
mov w4,#46
bl .Linterpolate
str d0,[x21,#24]
ldr x8,[x19,#72]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#64]
ldr d1,[x8,w22,uxtw #3]
ldr x0,[x29,#3472]
add x1,x29,#576
add x2,x29,#1088
mov w3,#72
mov w4,#46
bl .Linterpolate
str d0,[x21,#32]
add w22,w22,#1
mov w23,w22
ldr w9,[x29,#484]
cmp w22,w9
b.le .Ltegen_columns
adrp x17,.Lreals
add x17,x17,:lo12:.Lreals
ldr d0,[x17,#8]
mov w9,#60
scvtf d1,w9
fdiv d0,d0,d1
str d0,[x29,#3640]
mov w24,#0
.Lmacc_latgrid:
adrp x17,.Lreals
add x17,x17,:lo12:.Lreals
ldr d0,[x17,#0]
scvtf d1,w24
ldr d2,[x29,#3640]
fmul d1,d1,d2
fsub d0,d0,d1
ldr d1,[x29,#544]
fmul d0,d0,d1
adrp x17,.Lreals
add x17,x17,:lo12:.Lreals
ldr d1,[x17,#8]
fdiv d0,d0,d1
CALL md2asm_sin_original_rounding
adrp x9,.Lcounts
add x9,x9,:lo12:.Lcounts
ldr x10,[x9,#8]
add x10,x10,#1
str x10,[x9,#8]
add x9,x29,#576
str d0,[x9,w24,uxtw #3]
add w24,w24,#1
cmp w24,#61
b.lt .Lmacc_latgrid
ldr d0,[x29,#544]
fadd d0,d0,d0
mov w9,#120
scvtf d1,w9
fdiv d0,d0,d1
str d0,[x29,#3648]
mov w24,#0
.Lmacc_longrid:
scvtf d0,w24
ldr d1,[x29,#3648]
fmul d0,d0,d1
add x9,x29,#1088
str d0,[x9,w24,uxtw #3]
add w24,w24,#1
cmp w24,#120
b.lt .Lmacc_longrid
ldr w22,[x29,#480]
mov w23,w22
.Lmacc_columns:
add x21,x20,x23,lsl #9
ldr x8,[x19,#72]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#64]
ldr d1,[x8,w22,uxtw #3]
ldr x0,[x29,#3480]
add x1,x29,#576
add x2,x29,#1088
mov w3,#120
mov w4,#61
bl .Linterpolate
str d0,[x21,#40]
ldr x8,[x19,#72]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#64]
ldr d1,[x8,w22,uxtw #3]
ldr x0,[x29,#3488]
add x1,x29,#576
add x2,x29,#1088
mov w3,#120
mov w4,#61
bl .Linterpolate
str d0,[x21,#48]
ldr x8,[x19,#72]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#64]
ldr d1,[x8,w22,uxtw #3]
ldr x0,[x29,#3496]
add x1,x29,#576
add x2,x29,#1088
mov w3,#120
mov w4,#61
bl .Linterpolate
str d0,[x21,#56]
ldr x8,[x19,#72]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#64]
ldr d1,[x8,w22,uxtw #3]
ldr x0,[x29,#3504]
add x1,x29,#576
add x2,x29,#1088
mov w3,#120
mov w4,#61
bl .Linterpolate
str d0,[x21,#64]
ldr x8,[x19,#72]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#64]
ldr d1,[x8,w22,uxtw #3]
ldr x0,[x29,#3512]
add x1,x29,#576
add x2,x29,#1088
mov w3,#120
mov w4,#61
bl .Linterpolate
str d0,[x21,#72]
ldr x8,[x19,#72]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#64]
ldr d1,[x8,w22,uxtw #3]
ldr x0,[x29,#3520]
add x1,x29,#576
add x2,x29,#1088
mov w3,#120
mov w4,#61
bl .Linterpolate
str d0,[x21,#80]
ldr x8,[x19,#72]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#64]
ldr d1,[x8,w22,uxtw #3]
ldr x0,[x29,#3528]
add x1,x29,#576
add x2,x29,#1088
mov w3,#120
mov w4,#61
bl .Linterpolate
str d0,[x21,#88]
ldr x8,[x19,#72]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#64]
ldr d1,[x8,w22,uxtw #3]
ldr x0,[x29,#3536]
add x1,x29,#576
add x2,x29,#1088
mov w3,#120
mov w4,#61
bl .Linterpolate
str d0,[x21,#96]
ldr x8,[x19,#72]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#64]
ldr d1,[x8,w22,uxtw #3]
ldr x0,[x29,#3544]
add x1,x29,#576
add x2,x29,#1088
mov w3,#120
mov w4,#61
bl .Linterpolate
str d0,[x21,#104]
ldr x8,[x19,#72]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#64]
ldr d1,[x8,w22,uxtw #3]
ldr x0,[x29,#3552]
add x1,x29,#576
add x2,x29,#1088
mov w3,#120
mov w4,#61
bl .Linterpolate
str d0,[x21,#112]
ldr x8,[x19,#72]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#64]
ldr d1,[x8,w22,uxtw #3]
ldr x0,[x29,#3560]
add x1,x29,#576
add x2,x29,#1088
mov w3,#120
mov w4,#61
bl .Linterpolate
str d0,[x21,#120]
add w22,w22,#1
mov w23,w22
ldr w9,[x29,#484]
cmp w22,w9
b.le .Lmacc_columns
ldr w22,[x29,#480]
mov w23,w22
.Lozone_columns:
add x21,x20,x23,lsl #9
mov w9,#6
str w9,[x29,#504]
ldr x8,[x19,#72]
add x0,x8,w22,uxtw #3
add x1,x29,#504
add x2,x29,#508
add x3,x29,#2064
CALL md2asm_radact_legtri
adrp x9,.Lcounts
add x9,x9,:lo12:.Lcounts
ldr x10,[x9,#0]
add x10,x10,#1
str x10,[x9,#0]
add x0,x29,#2064
ldr x8,[x19,#16]
add x1,x8,#512
add x2,x8,#680
add x3,x29,#2592
mov w4,#6
bl .Ltransform
add x0,x29,#2064
ldr x8,[x19,#16]
add x1,x8,#800
add x2,x8,#968
add x3,x29,#2680
mov w4,#6
bl .Ltransform
ldr x8,[x19,#80]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#88]
ldr d1,[x8,w22,uxtw #3]
add x0,x29,#2592
mov w1,#6
bl .Lfourier
str d0,[x21,#160]
ldr x8,[x19,#80]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#88]
ldr d1,[x8,w22,uxtw #3]
add x0,x29,#2680
mov w1,#6
bl .Lfourier
fsqrt d0,d0
fmul d1,d0,d0
fmul d0,d1,d0
str d0,[x21,#168]
add w22,w22,#1
mov w23,w22
ldr w9,[x29,#484]
cmp w22,w9
b.le .Lozone_columns
ldr w22,[x29,#480]
mov w23,w22
.Lharmonic_columns:
add x21,x20,x23,lsl #9
mov w9,#11
str w9,[x29,#504]
ldr x8,[x19,#72]
add x0,x8,w22,uxtw #3
add x1,x29,#504
add x2,x29,#508
add x3,x29,#2064
CALL md2asm_radact_legtri
adrp x9,.Lcounts
add x9,x9,:lo12:.Lcounts
ldr x10,[x9,#0]
add x10,x10,#1
str x10,[x9,#0]
add x0,x29,#2064
ldr x8,[x19,#0]
add x1,x8,#256
add x2,x8,#784
add x3,x29,#2768
mov w4,#11
bl .Ltransform
add x0,x29,#2064
ldr x8,[x19,#0]
add x1,x8,#1224
add x2,x8,#1752
add x3,x29,#2936
mov w4,#11
bl .Ltransform
add x0,x29,#2064
ldr x8,[x19,#0]
add x1,x8,#2192
add x2,x8,#2720
add x3,x29,#3104
mov w4,#11
bl .Ltransform
add x0,x29,#2064
ldr x8,[x19,#0]
add x1,x8,#3160
add x2,x8,#3688
add x3,x29,#3272
mov w4,#11
bl .Ltransform
ldr x8,[x19,#80]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#88]
ldr d1,[x8,w22,uxtw #3]
add x0,x29,#2768
mov w1,#11
bl .Lfourier
str d0,[x21,#128]
ldr x8,[x19,#80]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#88]
ldr d1,[x8,w22,uxtw #3]
add x0,x29,#2936
mov w1,#11
bl .Lfourier
str d0,[x21,#136]
ldr x8,[x19,#80]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#88]
ldr d1,[x8,w22,uxtw #3]
add x0,x29,#3104
mov w1,#11
bl .Lfourier
str d0,[x21,#144]
ldr x8,[x19,#80]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#88]
ldr d1,[x8,w22,uxtw #3]
add x0,x29,#3272
mov w1,#11
bl .Lfourier
str d0,[x21,#152]
add w22,w22,#1
mov w23,w22
ldr w9,[x29,#484]
cmp w22,w9
b.le .Lharmonic_columns
ldr w22,[x29,#480]
mov w23,w22
.Linitial_columns:
add x21,x20,x23,lsl #9
ldr x8,[x19,#56]
ldr d0,[x8,w22,uxtw #3]
str d0,[x21,#176]
fmul d1,d0,d0
fmul d1,d1,d0
fsqrt d1,d1
ldr d2,[x21,#160]
fmul d2,d2,d1
ldr d3,[x21,#168]
fadd d1,d1,d3
fdiv d0,d2,d1
str d0,[x21,#184]
fmov d0,#1.0
str d0,[x21,#192]
ldr d0,[x21,#24]
ldr x9,[x29,#3568]
ldr d1,[x9]
fmul d0,d0,d1
str d0,[x21,#200]
ldr d0,[x21,#0]
ldr x9,[x29,#3584]
ldr d1,[x9]
fmul d0,d0,d1
str d0,[x21,#216]
ldr d0,[x21,#16]
ldr x9,[x29,#3592]
ldr d1,[x9]
fmul d0,d0,d1
str d0,[x21,#224]
ldr d0,[x21,#32]
ldr x9,[x29,#3576]
ldr d1,[x9]
fmul d0,d0,d1
str d0,[x21,#232]
ldr d0,[x21,#8]
ldr d1,[x21,#32]
fadd d0,d0,d1
ldr x9,[x29,#3576]
ldr d1,[x9]
fmul d0,d0,d1
str d0,[x21,#208]
ldr d0,[x21,#24]
ldr x8,[x19,#144]
str d0,[x8,w22,uxtw #3]
ldr d0,[x21,#16]
ldr x8,[x19,#152]
str d0,[x8,w22,uxtw #3]
ldr d0,[x21,#8]
ldr x8,[x19,#160]
str d0,[x8,w22,uxtw #3]
ldr d0,[x21,#0]
ldr x8,[x19,#168]
str d0,[x8,w22,uxtw #3]
ldr d0,[x21,#32]
ldr x8,[x19,#176]
str d0,[x8,w22,uxtw #3]
ldr d0,[x21,#24]
ldr d1,[x21,#16]
fadd d0,d0,d1
ldr d1,[x21,#8]
fadd d0,d0,d1
ldr d1,[x21,#0]
fadd d0,d0,d1
ldr d1,[x21,#32]
fadd d0,d0,d1
ldr x8,[x19,#136]
str d0,[x8,w22,uxtw #3]
ldr d0,[x21,#40]
ldr x9,[x29,#3624]
ldr d1,[x9]
fmul d0,d0,d1
str d0,[x21,#240]
ldr d0,[x21,#48]
ldr x9,[x29,#3624]
ldr d1,[x9]
fmul d0,d0,d1
str d0,[x21,#248]
ldr d0,[x21,#56]
ldr x9,[x29,#3616]
ldr d1,[x9]
fmul d0,d0,d1
str d0,[x21,#256]
ldr d0,[x21,#64]
ldr x9,[x29,#3616]
ldr d1,[x9]
fmul d0,d0,d1
str d0,[x21,#264]
ldr d0,[x21,#72]
ldr x9,[x29,#3608]
ldr d1,[x9]
fmul d0,d0,d1
str d0,[x21,#272]
ldr d0,[x21,#80]
ldr x9,[x29,#3608]
ldr d1,[x9]
fmul d0,d0,d1
str d0,[x21,#280]
ldr d0,[x21,#88]
ldr x9,[x29,#3608]
ldr d1,[x9]
fmul d0,d0,d1
str d0,[x21,#288]
ldr d0,[x21,#96]
ldr x9,[x29,#3600]
ldr d1,[x9]
fmul d0,d0,d1
str d0,[x21,#296]
ldr d0,[x21,#104]
ldr x9,[x29,#3600]
ldr d1,[x9]
fmul d0,d0,d1
str d0,[x21,#304]
ldr d0,[x21,#112]
ldr x9,[x29,#3600]
ldr d1,[x9]
fmul d0,d0,d1
str d0,[x21,#312]
ldr d0,[x21,#120]
ldr x9,[x29,#3632]
ldr d1,[x9]
fmul d0,d0,d1
str d0,[x21,#320]
add w22,w22,#1
mov w23,w22
ldr w9,[x29,#484]
cmp w22,w9
b.le .Linitial_columns
mov w24,#0
.Llayers:
ldr w22,[x29,#480]
mov w23,w22
.Llayer_columns:
add x21,x20,x23,lsl #9
ldr x8,[x19,#96]
madd w11,w24,w28,w22
ldr d0,[x8,w11,uxtw #3]
add w12,w11,w28
ldr d1,[x8,w12,uxtw #3]
fdiv d0,d0,d1
str d0,[x29,#3736]
ldr x8,[x19,#56]
add w9,w24,#1
madd w9,w9,w25,w22
ldr d0,[x8,w9,uxtw #3]
str d0,[x29,#3680]
fmul d1,d0,d0
fmul d1,d1,d0
fsqrt d1,d1
str d1,[x29,#3688]
ldr d2,[x21,#176]
fadd d0,d0,d2
fmov d1,#0.5
fmul d0,d0,d1
adrp x17,.Lreals
add x17,x17,:lo12:.Lreals
ldr d1,[x17,#16]
fcmp d0,d1
b.lt .Lweight_one
ldr d0,[x29,#3736]
fmov d1,#1.0
fmin d0,d1,d0
ldr d1,[x29,#560]
CALL md2asm_pow_original_rounding_candidate
adrp x9,.Lcounts
add x9,x9,:lo12:.Lcounts
ldr x10,[x9,#16]
add x10,x10,#1
str x10,[x9,#16]
ldr d1,[x21,#192]
fmul d0,d1,d0
b .Lweight_ready
.Lweight_one:
fmov d0,#1.0
str d0,[x21,#192]
.Lweight_ready:
str d0,[x29,#3704]
ldr d1,[x21,#192]
fmul d1,d0,d1
fsqrt d1,d1
str d1,[x29,#3712]
fmov d2,#1.0
fsub d2,d2,d1
str d2,[x29,#3720]
ldr d0,[x29,#3680]
ldr d1,[x21,#176]
fsub d0,d0,d1
str d0,[x29,#3696]
ldr d0,[x21,#32]
ldr x9,[x29,#3576]
add w10,w24,#1
ldr d1,[x9,w10,uxtw #3]
fmul d0,d0,d1
str d0,[x29,#3824]
ldr d0,[x21,#24]
ldr x9,[x29,#3568]
add w10,w24,#1
ldr d1,[x9,w10,uxtw #3]
fmul d0,d0,d1
str d0,[x29,#3840]
ldr d0,[x21,#0]
ldr x9,[x29,#3584]
add w10,w24,#1
ldr d1,[x9,w10,uxtw #3]
fmul d0,d0,d1
str d0,[x29,#3848]
ldr d0,[x21,#16]
ldr x9,[x29,#3592]
add w10,w24,#1
ldr d1,[x9,w10,uxtw #3]
fmul d0,d0,d1
str d0,[x29,#3856]
ldr d0,[x21,#8]
ldr d1,[x21,#32]
fadd d0,d0,d1
ldr x9,[x29,#3576]
add w10,w24,#1
ldr d1,[x9,w10,uxtw #3]
fmul d0,d0,d1
str d0,[x29,#3832]
ldr x8,[x19,#0]
ldr d0,[x8,#4160]
ldr d1,[x29,#3696]
fmul d0,d0,d1
ldr d1,[x29,#3832]
fadd d0,d0,d1
ldr d1,[x21,#208]
fsub d0,d0,d1
ldr d1,[x29,#3720]
fmul d0,d1,d0
ldr x8,[x19,#104]
mov w9,#6
mul w9,w24,w9
add w9,w9,#0
madd w9,w9,w27,w23
str d0,[x8,w9,uxtw #3]
ldr d0,[x29,#3840]
ldr d1,[x21,#200]
fsub d0,d0,d1
ldr d1,[x29,#3720]
fmul d0,d1,d0
ldr x8,[x19,#104]
mov w9,#6
mul w9,w24,w9
add w9,w9,#1
madd w9,w9,w27,w23
str d0,[x8,w9,uxtw #3]
ldr d0,[x29,#3856]
ldr d1,[x21,#224]
fsub d0,d0,d1
ldr d1,[x29,#3720]
fmul d0,d1,d0
ldr x8,[x19,#104]
mov w9,#6
mul w9,w24,w9
add w9,w9,#2
madd w9,w9,w27,w23
str d0,[x8,w9,uxtw #3]
ldr d0,[x29,#3848]
ldr d1,[x21,#216]
fsub d0,d0,d1
ldr d1,[x29,#3720]
fmul d0,d1,d0
ldr x8,[x19,#104]
mov w9,#6
mul w9,w24,w9
add w9,w9,#3
madd w9,w9,w27,w23
str d0,[x8,w9,uxtw #3]
ldr d0,[x29,#3712]
ldr x8,[x19,#0]
ldr d1,[x8,#4168]
fmul d0,d0,d1
ldr d1,[x29,#3696]
fmul d0,d0,d1
ldr x8,[x19,#104]
mov w9,#6
mul w9,w24,w9
add w9,w9,#4
madd w9,w9,w27,w23
str d0,[x8,w9,uxtw #3]
ldr d0,[x29,#3712]
ldr x8,[x19,#0]
ldr d1,[x8,#4176]
fmul d0,d0,d1
ldr d1,[x29,#3696]
fmul d0,d0,d1
ldr x8,[x19,#104]
mov w9,#6
mul w9,w24,w9
add w9,w9,#5
madd w9,w9,w27,w23
str d0,[x8,w9,uxtw #3]
ldr d0,[x21,#160]
ldr d1,[x29,#3688]
fmul d0,d0,d1
ldr d2,[x21,#168]
fadd d1,d1,d2
fdiv d0,d0,d1
str d0,[x29,#3744]
ldr d1,[x21,#184]
fsub d0,d0,d1
ldr x8,[x19,#120]
madd w9,w24,w27,w23
str d0,[x8,w9,uxtw #3]
ldr d0,[x21,#96]
ldr x9,[x29,#3600]
add w10,w24,#1
ldr d1,[x9,w10,uxtw #3]
fmul d0,d0,d1
ldr d1,[x21,#296]
str d0,[x21,#296]
fsub d0,d0,d1
ldr d1,[x29,#3720]
fmul d0,d1,d0
ldr x8,[x19,#112]
mov w9,#0
madd w9,w9,w26,w24
madd w9,w9,w27,w23
str d0,[x8,w9,uxtw #3]
ldr d0,[x21,#104]
ldr x9,[x29,#3600]
add w10,w24,#1
ldr d1,[x9,w10,uxtw #3]
fmul d0,d0,d1
ldr d1,[x21,#304]
str d0,[x21,#304]
fsub d0,d0,d1
ldr d1,[x29,#3720]
fmul d0,d1,d0
ldr x8,[x19,#112]
mov w9,#1
madd w9,w9,w26,w24
madd w9,w9,w27,w23
str d0,[x8,w9,uxtw #3]
ldr d0,[x21,#112]
ldr x9,[x29,#3600]
add w10,w24,#1
ldr d1,[x9,w10,uxtw #3]
fmul d0,d0,d1
ldr d1,[x21,#312]
str d0,[x21,#312]
fsub d0,d0,d1
ldr d1,[x29,#3720]
fmul d0,d1,d0
ldr x8,[x19,#112]
mov w9,#2
madd w9,w9,w26,w24
madd w9,w9,w27,w23
str d0,[x8,w9,uxtw #3]
ldr d0,[x21,#72]
ldr x9,[x29,#3608]
add w10,w24,#1
ldr d1,[x9,w10,uxtw #3]
fmul d0,d0,d1
ldr d1,[x21,#272]
str d0,[x21,#272]
fsub d0,d0,d1
ldr d1,[x29,#3720]
fmul d0,d1,d0
ldr x8,[x19,#112]
mov w9,#3
madd w9,w9,w26,w24
madd w9,w9,w27,w23
str d0,[x8,w9,uxtw #3]
ldr d0,[x21,#80]
ldr x9,[x29,#3608]
add w10,w24,#1
ldr d1,[x9,w10,uxtw #3]
fmul d0,d0,d1
ldr d1,[x21,#280]
str d0,[x21,#280]
fsub d0,d0,d1
ldr d1,[x29,#3720]
fmul d0,d1,d0
ldr x8,[x19,#112]
mov w9,#4
madd w9,w9,w26,w24
madd w9,w9,w27,w23
str d0,[x8,w9,uxtw #3]
ldr d0,[x21,#88]
ldr x9,[x29,#3608]
add w10,w24,#1
ldr d1,[x9,w10,uxtw #3]
fmul d0,d0,d1
ldr d1,[x21,#288]
str d0,[x21,#288]
fsub d0,d0,d1
ldr d1,[x29,#3720]
fmul d0,d1,d0
ldr x8,[x19,#112]
mov w9,#5
madd w9,w9,w26,w24
madd w9,w9,w27,w23
str d0,[x8,w9,uxtw #3]
ldr d0,[x21,#56]
ldr x9,[x29,#3616]
add w10,w24,#1
ldr d1,[x9,w10,uxtw #3]
fmul d0,d0,d1
ldr d1,[x21,#256]
str d0,[x21,#256]
fsub d0,d0,d1
ldr d1,[x29,#3720]
fmul d0,d1,d0
ldr x8,[x19,#112]
mov w9,#6
madd w9,w9,w26,w24
madd w9,w9,w27,w23
str d0,[x8,w9,uxtw #3]
ldr d0,[x21,#64]
ldr x9,[x29,#3616]
add w10,w24,#1
ldr d1,[x9,w10,uxtw #3]
fmul d0,d0,d1
ldr d1,[x21,#264]
str d0,[x21,#264]
fsub d0,d0,d1
ldr d1,[x29,#3720]
fmul d0,d1,d0
ldr x8,[x19,#112]
mov w9,#7
madd w9,w9,w26,w24
madd w9,w9,w27,w23
str d0,[x8,w9,uxtw #3]
ldr d0,[x21,#40]
ldr x9,[x29,#3624]
add w10,w24,#1
ldr d1,[x9,w10,uxtw #3]
fmul d0,d0,d1
ldr d1,[x21,#240]
str d0,[x21,#240]
fsub d0,d0,d1
ldr d1,[x29,#3720]
fmul d0,d1,d0
ldr x8,[x19,#112]
mov w9,#8
madd w9,w9,w26,w24
madd w9,w9,w27,w23
str d0,[x8,w9,uxtw #3]
ldr d0,[x21,#48]
ldr x9,[x29,#3624]
add w10,w24,#1
ldr d1,[x9,w10,uxtw #3]
fmul d0,d0,d1
ldr d1,[x21,#248]
str d0,[x21,#248]
fsub d0,d0,d1
ldr d1,[x29,#3720]
fmul d0,d1,d0
ldr x8,[x19,#112]
mov w9,#9
madd w9,w9,w26,w24
madd w9,w9,w27,w23
str d0,[x8,w9,uxtw #3]
ldr d0,[x21,#120]
ldr x9,[x29,#3632]
add w10,w24,#1
ldr d1,[x9,w10,uxtw #3]
fmul d0,d0,d1
ldr d1,[x21,#320]
str d0,[x21,#320]
fsub d0,d0,d1
ldr d1,[x29,#3720]
fmul d0,d1,d0
ldr x8,[x19,#112]
mov w9,#10
madd w9,w9,w26,w24
madd w9,w9,w27,w23
str d0,[x8,w9,uxtw #3]
ldr x8,[x19,#112]
mov w9,#11
madd w9,w9,w26,w24
madd w9,w9,w27,w23
str xzr,[x8,w9,uxtw #3]
ldr d0,[x29,#3680]
str d0,[x21,#176]
ldr d0,[x29,#3744]
str d0,[x21,#184]
ldr d0,[x29,#3704]
str d0,[x21,#192]
ldr d0,[x29,#3840]
str d0,[x21,#200]
ldr d0,[x29,#3832]
str d0,[x21,#208]
ldr d0,[x29,#3848]
str d0,[x21,#216]
ldr d0,[x29,#3856]
str d0,[x21,#224]
ldr d0,[x29,#3824]
str d0,[x21,#232]
ldr x8,[x19,#104]
ldr d1,[x29,#568]
mov w10,#0
.Lfloors:
mov w9,#6
mul w9,w24,w9
add w9,w9,w10
madd w9,w9,w27,w23
ldr d0,[x8,w9,uxtw #3]
fmax d0,d0,d1
str d0,[x8,w9,uxtw #3]
add w10,w10,#1
cmp w10,#6
b.lt .Lfloors
add w22,w22,#1
mov w23,w22
ldr w9,[x29,#484]
cmp w22,w9
b.le .Llayer_columns
add w24,w24,#1
cmp w24,w26
b.lt .Llayers
ldr w22,[x29,#480]
mov w23,w22
.Lextinction_zero:
ldr x8,[x19,#128]
str xzr,[x8,w22,uxtw #3]
add w22,w22,#1
mov w23,w22
ldr w9,[x29,#484]
cmp w22,w9
b.le .Lextinction_zero
mov w24,#0
.Lextinction_species:
ldr w22,[x29,#480]
mov w23,w22
.Lextinction_columns:
ldr x8,[x19,#56]
mov w9,w26
madd w9,w9,w25,w22
ldr d0,[x8,w9,uxtw #3]
sub w9,w9,w25
ldr d1,[x8,w9,uxtw #3]
fsub d0,d0,d1
adrp x17,.Lreals
add x17,x17,:lo12:.Lreals
ldr d1,[x17,#32]
fmul d0,d1,d0
ldr d1,[x29,#552]
fdiv d0,d1,d0
ldr x8,[x19,#104]
sub w9,w26,#1
mov w10,#6
mul w9,w9,w10
add w9,w9,w24
madd w9,w9,w25,w22
ldr d1,[x8,w9,uxtw #3]
fmul d0,d0,d1
adrp x17,.Lreals
add x17,x17,:lo12:.Lreals
ldr d1,[x17,#40]
fmul d0,d0,d1
ldr x8,[x19,#128]
ldr d1,[x8,w22,uxtw #3]
fadd d0,d1,d0
str d0,[x8,w22,uxtw #3]
add w22,w22,#1
mov w23,w22
ldr w9,[x29,#484]
cmp w22,w9
b.le .Lextinction_columns
add w24,w24,#1
cmp w24,#6
b.lt .Lextinction_species
.Lhook1_done:
mov w0,#0
.Lra_restore:
mov sp,x29
ldr x18,[sp,#96]
ldp x19,x20,[sp,#16]
ldp x21,x22,[sp,#32]
ldp x23,x24,[sp,#48]
ldp x25,x26,[sp,#64]
ldp x27,x28,[sp,#80]
ldp x29,x30,[sp,#0]
add sp,sp,#4096
add sp,sp,#2048
ret
.Lreject:
mov w0,#2
b .Lra_restore
.size md2asm_runtime_aerosol_visibility_climatology,.-md2asm_runtime_aerosol_visibility_climatology
// Check every output against all other declared spans before any public write.
.Lra_disjoint_and_values:
add x20,x29,#4096
mov w21,#13
.Lra_output:
add x23,x20,x21,lsl #4
ldp x9,x10,[x23]
mov w22,#0
.Lra_other:
cmp w21,w22
b.eq .Lra_next_other
add x24,x20,x22,lsl #4
ldp x11,x12,[x24]
cmp x9,x12
b.hs .Lra_next_other
cmp x11,x10
b.lo .Lreject
.Lra_next_other:
add w22,w22,#1
cmp w22,#47
b.lo .Lra_other
add w21,w21,#1
cmp w21,#23
b.lo .Lra_output
// A caller-owned span must not overlap this entry's frame or private stack work.
lsl x9,x25,#9
sub x0,x29,x9
add x1,x29,#4096
add x1,x1,#2048
mov w22,#0
.Lra_private_span:
add x24,x20,x22,lsl #4
ldp x11,x12,[x24]
cmp x0,x12
b.hs .Lra_private_next
cmp x11,x1
b.lo .Lreject
.Lra_private_next:
add w22,w22,#1
cmp w22,#47
b.lo .Lra_private_span
// Validate the consumed exponent and floor using only non-NaN comparisons.
ldr x8,[x19]
ldr x9,[x8,#4184]
ubfx x10,x9,#52,#11
cmp x10,#2047
b.eq .Lreject
fmov d0,x9
fcmp d0,#0.0
b.lt .Lreject
adrp x17,.Lreals
add x17,x17,:lo12:.Lreals
ldr d1,[x17,#24]
fcmp d0,d1
b.gt .Lreject
ldr x8,[x19,#16]
mov x10,#35632
ldr x9,[x8,x10]
ubfx x10,x9,#52,#11
cmp x10,#2047
b.eq .Lreject
fmov d0,x9
fcmp d0,#0.0
b.lt .Lreject
mov w20,#0
ldr w21,[x29,#484]
.Lra_column_values:
mov w22,#8
.Lra_geo:
ldr x8,[x19,x22,lsl #3]
ldr x9,[x8,x20,lsl #3]
ubfx x10,x9,#52,#11
cmp x10,#2047
b.eq .Lreject
fmov d0,x9
cmp w22,#8
b.ne .Lra_unit_circle
fcmp d0,#0.0
b.lt .Lreject
movz x10,#0x2d18
movk x10,#0x5444,lsl #16
movk x10,#0x21fb,lsl #32
movk x10,#0x4019,lsl #48
fmov d1,x10
fcmp d0,d1
b.ge .Lreject
b .Lra_geo_next
.Lra_unit_circle:
fmov d1,#-1.0
fcmp d0,d1
b.lt .Lreject
fmov d1,#1.0
fcmp d0,d1
b.gt .Lreject
.Lra_geo_next:
add w22,w22,#1
cmp w22,#12
b.lo .Lra_geo
mov w22,#0
fmov d2,xzr
.Lra_vertical:
madd w23,w22,w25,w20
ldr x8,[x19,#56]
ldr x9,[x8,x23,lsl #3]
ubfx x10,x9,#52,#11
cmp x10,#2047
b.eq .Lreject
fmov d0,x9
cbnz w22,.Lra_pressure_increasing
fcmp d0,#0.0
b.lt .Lreject
b .Lra_pressure_done
.Lra_pressure_increasing:
fcmp d0,d2
b.le .Lreject
.Lra_pressure_done:
fmov d2,d0
ldr x8,[x19,#96]
ldr x9,[x8,x23,lsl #3]
ubfx x10,x9,#52,#11
cmp x10,#2047
b.eq .Lreject
fmov d0,x9
fcmp d0,#0.0
b.le .Lreject
add w22,w22,#1
cmp w22,w26
b.le .Lra_vertical
add w20,w20,#1
cmp w20,w21
b.le .Lra_column_values
ret
// Record a complete already-owned span without following its payload.
.Lra_span:
cbz x0,.Lreject
tst x0,x2
b.ne .Lreject
adds x9,x0,x1
b.cs .Lreject
add x10,x29,#4096
add x10,x10,x3,lsl #4
stp x0,x9,[x10]
ret
// Profile shape follows the live model layer count.
.Lprofile:
ldr x9,[x0]
ldr x10,[x0,#8]
cmn x10,#1
b.ne .Lreject
ldr x10,[x0,#16]
cmp x10,#8
b.ne .Lreject
ldrb w10,[x0,#28]
cmp w10,#1
b.ne .Lreject
ldrb w10,[x0,#29]
cmp w10,#3
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
add x11,x26,#1
cmp x10,x11
b.ne .Lreject
mov x0,x9
lsl x1,x11,#3
b .Lra_payload_span
.Lclimate:
ldr x9,[x0]
ldr x10,[x0,#8]
cmn x10,#121
b.ne .Lreject
ldr x10,[x0,#16]
cmp x10,#8
b.ne .Lreject
ldrb w10,[x0,#28]
cmp w10,#2
b.ne .Lreject
ldrb w10,[x0,#29]
cmp w10,#3
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
mov x0,x9
mov x1,#58560
.Lra_payload_span:
mov x2,#7
ldr x3,[x29,#4048]
stp x18,x30,[sp,#-16]!
bl .Lra_span
ldp x18,x30,[sp],#16
add x3,x3,#1
str x3,[x29,#4048]
ret
.Linterpolate:
mov w5,#0
sub w7,w4,#2
.Llatbracket:
ldr d4,[x1,w5,uxtw #3]
add w6,w5,#1
ldr d5,[x1,w6,uxtw #3]
fcmp d0,d4
b.gt .Llatnext
fcmp d0,d5
b.gt .Llatfound
cmp w5,w7
b.eq .Llatfound
.Llatnext:
add w5,w5,#1
cmp w5,w7
b.le .Llatbracket
b .Lreject
.Llatfound:
fsub d2,d0,d4
fsub d3,d5,d4
fdiv d2,d2,d3
sub w7,w3,#1
ldr d4,[x2,w7,uxtw #3]
fcmp d1,d4
b.ge .Llonseam
mov w6,#0
.Llonbracket:
ldr d4,[x2,w6,uxtw #3]
add w8,w6,#1
ldr d5,[x2,w8,uxtw #3]
fcmp d1,d4
b.lt .Llonnext
fcmp d1,d5
b.lt .Llonfound
.Llonnext:
add w6,w6,#1
cmp w6,w7
b.lt .Llonbracket
b .Lreject
.Llonseam:
mov w6,w7
mov w8,#0
ldr d5,[x29,#3648]
fadd d5,d4,d5
.Llonfound:
fsub d3,d1,d4
fsub d4,d5,d4
fdiv d3,d3,d4
madd w9,w5,w3,w6
ldr d4,[x0,w9,uxtw #3]
add w10,w9,w3
ldr d5,[x0,w10,uxtw #3]
fsub d5,d5,d4
fmul d5,d2,d5
fadd d4,d4,d5
madd w9,w5,w3,w8
ldr d5,[x0,w9,uxtw #3]
add w10,w9,w3
ldr d6,[x0,w10,uxtw #3]
fsub d6,d6,d5
fmul d6,d2,d6
fadd d5,d5,d6
fsub d5,d5,d4
fmul d5,d3,d5
fadd d0,d4,d5
ret
.Ltransform:
mov w5,#0
mov w6,#0
mov w7,#0
mov w8,#0
.Ltransorder:
sub w9,w4,w5
fmov d0,xzr
mov w10,#0
.Ltranscos:
add w11,w6,w10
ldr d1,[x0,w11,uxtw #3]
ldr d2,[x1,w11,uxtw #3]
fmul d1,d1,d2
fadd d0,d0,d1
add w10,w10,#1
cmp w10,w9
b.lt .Ltranscos
str d0,[x3,w8,uxtw #3]
add w8,w8,#1
add w6,w6,w9
cbz w5,.Ltransnext
fmov d0,xzr
mov w10,#0
.Ltranssin:
add w11,w7,w10
add w12,w11,w4
ldr d1,[x0,w12,uxtw #3]
ldr d2,[x2,w11,uxtw #3]
fmul d1,d1,d2
fadd d0,d0,d1
add w10,w10,#1
cmp w10,w9
b.lt .Ltranssin
str d0,[x3,w8,uxtw #3]
add w8,w8,#1
add w7,w7,w9
.Ltransnext:
add w5,w5,#1
cmp w5,w4
b.lt .Ltransorder
ret
.Lfourier:
fmov d2,d0
fmov d3,d1
ldr d4,[x0,#8]
fmul d4,d4,d2
ldr d5,[x0,#16]
fmul d5,d5,d3
fadd d4,d4,d5
mov w5,#2
.Lfourorder:
cmp w5,w1
b.ge .Lfourresult
fmul d5,d2,d0
fmul d6,d3,d1
fsub d16,d5,d6
fmul d5,d3,d0
fmul d6,d2,d1
fadd d17,d5,d6
fmov d2,d16
fmov d3,d17
lsl w6,w5,#1
sub w6,w6,#1
ldr d5,[x0,w6,uxtw #3]
fmul d5,d5,d2
fadd d4,d4,d5
add w6,w6,#1
ldr d5,[x0,w6,uxtw #3]
fmul d5,d5,d3
fadd d4,d4,d5
add w5,w5,#1
b .Lfourorder
.Lfourresult:
fmov d5,#2.0
fmul d4,d5,d4
ldr d5,[x0]
fadd d0,d5,d4
ret
 .global md2asm_runtime_aerosol_climatology_child_count_get
md2asm_runtime_aerosol_climatology_child_count_get:
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
.Lcounts: .zero 24
.section .note.GNU-stack,"",%progbits
