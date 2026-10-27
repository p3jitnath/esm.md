// Physics formulations/openifs/radiation/aerosol_and_ozone_layer_amounts.md.
// Contract skills/md2asm/references/openifs/radiation/aerosol_and_ozone_preparation.md.
// The runtime entry retains Tegen and both MACC branches with live column and layer bounds.
// Every numerical calculation uses explicit FP64 arithmetic. No original Fortran numerical call.
// A 4096-byte frame holds scalar state. One bounded allocation holds live field arrays.
.text
.p2align 4
.global md2asm_runtime_radiation_aerosol_and_ozone_preparation
.type md2asm_runtime_radiation_aerosol_and_ozone_preparation,%function
md2asm_runtime_radiation_aerosol_and_ozone_preparation:
sub sp,sp,#4096
stp x29,x30,[sp,#0]
stp x19,x20,[sp,#16]
stp x21,x22,[sp,#32]
stp x23,x24,[sp,#48]
stp x25,x26,[sp,#64]
stp x27,x28,[sp,#80]
str x18,[sp,#96]
mov x29,sp
str xzr,[x29,#112]
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
cmp w9,#27
b.lt .Lsave_args
ldr x8,[x16,#152]
cbz x8,.Lreject
tst x8,#7
b.ne .Lreject
str x8,[x29,#128]
ldr x9,[x8]
mov x10,#0x4000000
cmp x9,x10
b.hi .Lreject
ldr x8,[x8,#8]
cbz x8,.Lreject
tst x8,#7
b.ne .Lreject
adds x9,x8,#520
b.cs .Lreject
str x8,[x29,#136]
mrs x9,fpcr
cbnz x9,.Lreject
mov w9,#0
.Lalign:
ldr x10,[x19,w9,uxtw #3]
cbz x10,.Lreject
cmp w9,#5
b.lt .Lalign_real
cmp w9,#13
b.gt .Lalign_real
tst x10,#3
b.ne .Lreject
b .Lalign_next
.Lalign_real:
tst x10,#7
b.ne .Lreject
.Lalign_next:
add w9,w9,#1
cmp w9,#26
b.lt .Lalign
ldr x8,[x19,#56]
ldr w25,[x8]
sub w9,w25,#1
cmp w9,#1023
b.hi .Lreject
ldr x8,[x19,#64]
ldr w26,[x8]
sub w9,w26,#1
cmp w9,#511
b.hi .Lreject
ldr x8,[x19,#80]
ldr w27,[x8]
cmp w27,w25
b.ne .Lreject
ldr x8,[x19,#88]
ldr w28,[x8]
cmp w28,w25
b.ne .Lreject
ldr x8,[x19,#40]
ldr w9,[x8]
str w9,[x29,#480]
ldr x8,[x19,#48]
ldr w9,[x8]
str w9,[x29,#484]
ldr x8,[x19,#72]
ldr w9,[x8]
str w9,[x29,#488]
ldr x8,[x19,#96]
ldr w9,[x8]
str w9,[x29,#492]
ldr x8,[x19,#104]
ldr w9,[x8]
str w9,[x29,#496]
ldr w9,[x29,#480]
cmp w9,#1
b.lt .Lreject
sub w9,w9,#1
str w9,[x29,#480]
ldr w10,[x29,#484]
cmp w10,w25
b.gt .Lreject
sub w10,w10,#1
str w10,[x29,#484]
cmp w10,w9
b.lt .Lreject
ldr w11,[x29,#488]
cmp w11,#1
b.ne .Lreject
sub w12,w10,w9
sdiv w12,w12,w11
add w12,w12,#1
ldr w13,[x29,#492]
cmp w13,w9
b.ne .Lreject
add w12,w12,w13
cmp w12,w27
b.gt .Lreject
ldr w9,[x29,#496]
cmp w9,#1
b.gt .Lreject
cmp w9,#0
b.lt .Lreject
ldr x8,[x19,#32]
ldr w9,[x8]
cbnz w9,.Lreject
ldr x8,[x19,#8]
ldr w9,[x8,#168]
cmp w9,#0
b.ne .Lreject
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
ldr w9,[x8,#448]
cmp w9,#0
b.ne .Lreject
ldr x8,[x19,#8]
ldr w9,[x8,#464]
cmp w9,#1
b.hi .Lreject
str w9,[x29,#192]
ldr x8,[x19,#8]
ldr w9,[x8,#484]
cmp w9,#0
b.ne .Lreject
ldr x9,[x29,#136]
ldr d0,[x9,#0]
str d0,[x29,#544]
fcmp d0,#0.0
b.le .Lreject
b.vs .Lreject
fmov x11,d0
lsr x11,x11,#52
and x11,x11,#0x7ff
cmp x11,#2047
b.eq .Lreject
ldr x9,[x29,#136]
ldr d0,[x9,#112]
str d0,[x29,#552]
fcmp d0,#0.0
b.le .Lreject
b.vs .Lreject
fmov x11,d0
lsr x11,x11,#52
and x11,x11,#0x7ff
cmp x11,#2047
b.eq .Lreject
ldr x8,[x19,#0]
ldr d0,[x8,#4184]
str d0,[x29,#560]
fcmp d0,#0.0
b.lt .Lreject
b.vs .Lreject
adrp x17,.Lreals
add x17,x17,:lo12:.Lreals
ldr d1,[x17,#24]
fcmp d0,d1
b.gt .Lreject
ldr x8,[x19,#24]
mov x9,#35632
add x8,x8,x9
ldr d0,[x8]
str d0,[x29,#568]
fcmp d0,#0.0
b.lt .Lreject
b.vs .Lreject
fmov x11,d0
lsr x11,x11,#52
and x11,x11,#0x7ff
cmp x11,#2047
b.eq .Lreject
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
ldr x9,[x19,#24]
mov x10,#35632
add x9,x9,x10
mov x10,#744
add x9,x9,x10
str x9,[x29,#3440]
ldr x9,[x19,#24]
mov x10,#35632
add x9,x9,x10
mov x10,#27240
add x9,x9,x10
str x9,[x29,#3448]
ldr x9,[x19,#24]
mov x10,#35632
add x9,x9,x10
mov x10,#53736
add x9,x9,x10
str x9,[x29,#3456]
ldr x9,[x19,#24]
mov x10,#35632
add x9,x9,x10
movz x10,#14696
movk x10,#1,lsl #16
add x9,x9,x10
str x9,[x29,#3464]
ldr x9,[x19,#24]
mov x10,#35632
add x9,x9,x10
movz x10,#41192
movk x10,#1,lsl #16
add x9,x9,x10
str x9,[x29,#3472]
ldr w9,[x29,#192]
cbnz w9,.Ltrue_climate_bind
ldr x0,[x19,#24]
movz x9,#38168
movk x9,#2,lsl #16
add x0,x0,x9
add x0,x0,#1224
bl .Lclimate
str x0,[x29,#3480]
ldr x0,[x19,#24]
movz x9,#38168
movk x9,#2,lsl #16
add x0,x0,x9
add x0,x0,#1312
bl .Lclimate
str x0,[x29,#3488]
ldr x0,[x19,#24]
movz x9,#38168
movk x9,#2,lsl #16
add x0,x0,x9
add x0,x0,#1624
bl .Lclimate
str x0,[x29,#3496]
ldr x0,[x19,#24]
movz x9,#38168
movk x9,#2,lsl #16
add x0,x0,x9
add x0,x0,#1712
bl .Lclimate
str x0,[x29,#3504]
ldr x0,[x19,#24]
movz x9,#38168
movk x9,#2,lsl #16
add x0,x0,x9
add x0,x0,#2136
bl .Lclimate
str x0,[x29,#3512]
ldr x0,[x19,#24]
movz x9,#38168
movk x9,#2,lsl #16
add x0,x0,x9
add x0,x0,#2224
bl .Lclimate
str x0,[x29,#3520]
ldr x0,[x19,#24]
movz x9,#38168
movk x9,#2,lsl #16
add x0,x0,x9
add x0,x0,#2312
bl .Lclimate
str x0,[x29,#3528]
ldr x0,[x19,#24]
movz x9,#38168
movk x9,#2,lsl #16
add x0,x0,x9
add x0,x0,#2736
bl .Lclimate
str x0,[x29,#3536]
ldr x0,[x19,#24]
movz x9,#38168
movk x9,#2,lsl #16
add x0,x0,x9
add x0,x0,#2824
bl .Lclimate
str x0,[x29,#3544]
ldr x0,[x19,#24]
movz x9,#38168
movk x9,#2,lsl #16
add x0,x0,x9
add x0,x0,#2912
bl .Lclimate
str x0,[x29,#3552]
ldr x0,[x19,#24]
movz x9,#38168
movk x9,#2,lsl #16
add x0,x0,x9
add x0,x0,#3112
bl .Lclimate
str x0,[x29,#3560]
b .Lclimate_bound
.Ltrue_climate_bind:
ldr x0,[x19,#24]
movz x9,#38168
movk x9,#2,lsl #16
add x0,x0,x9
mov x9,#4968
add x0,x0,x9
bl .Lclimate3
str x0,[x29,#3920]
ldr x0,[x19,#24]
movz x9,#38168
movk x9,#2,lsl #16
add x0,x0,x9
mov x9,#5080
add x0,x0,x9
bl .Lclimate3
str x0,[x29,#3928]
ldr x0,[x19,#24]
movz x9,#38168
movk x9,#2,lsl #16
add x0,x0,x9
mov x9,#5192
add x0,x0,x9
bl .Lclimate3
str x0,[x29,#3936]
ldr x0,[x19,#24]
movz x9,#38168
movk x9,#2,lsl #16
add x0,x0,x9
mov x9,#5304
add x0,x0,x9
bl .Lclimate3
str x0,[x29,#3944]
ldr x0,[x19,#24]
movz x9,#38168
movk x9,#2,lsl #16
add x0,x0,x9
mov x9,#5416
add x0,x0,x9
bl .Lclimate3
str x0,[x29,#3952]
ldr x0,[x19,#24]
movz x9,#38168
movk x9,#2,lsl #16
add x0,x0,x9
mov x9,#5528
add x0,x0,x9
bl .Lclimate3
str x0,[x29,#3960]
ldr x0,[x19,#24]
movz x9,#38168
movk x9,#2,lsl #16
add x0,x0,x9
mov x9,#5640
add x0,x0,x9
bl .Lclimate3
str x0,[x29,#3968]
ldr x0,[x19,#24]
movz x9,#38168
movk x9,#2,lsl #16
add x0,x0,x9
mov x9,#5752
add x0,x0,x9
bl .Lclimate3
str x0,[x29,#3976]
ldr x0,[x19,#24]
movz x9,#38168
movk x9,#2,lsl #16
add x0,x0,x9
mov x9,#5864
add x0,x0,x9
bl .Lclimate3
str x0,[x29,#3984]
ldr x0,[x19,#24]
movz x9,#38168
movk x9,#2,lsl #16
add x0,x0,x9
mov x9,#5976
add x0,x0,x9
bl .Lclimate3
str x0,[x29,#3992]
ldr x0,[x19,#24]
movz x9,#38168
movk x9,#2,lsl #16
add x0,x0,x9
mov x9,#6088
add x0,x0,x9
bl .Lclimate3
str x0,[x29,#4000]
ldr x0,[x19,#24]
movz x9,#38168
movk x9,#2,lsl #16
add x0,x0,x9
mov x9,#6200
add x0,x0,x9
bl .Lclimate3
str x0,[x29,#4008]
ldr x0,[x19,#24]
movz x9,#38168
movk x9,#2,lsl #16
add x0,x0,x9
mov x9,#6312
add x0,x0,x9
bl .Lclimate3
str x0,[x29,#4016]
.Lclimate_bound:
ldr w22,[x29,#480]
ldr w23,[x29,#492]
.Linput_columns:
ldr x8,[x19,#128]
ldr d0,[x8,w22,uxtw #3]
fabs d1,d0
fmov d2,#1.0
fcmp d1,d2
b.gt .Lreject
b.vs .Lreject
ldr w9,[x29,#480]
ldr d1,[x8,w9,uxtw #3]
fcmp d0,d1
b.ne .Lreject
ldr x8,[x19,#120]
ldr d0,[x8,w22,uxtw #3]
fcmp d0,#0.0
b.lt .Lreject
b.vs .Lreject
ldr d1,[x29,#544]
fadd d1,d1,d1
fcmp d0,d1
b.ge .Lreject
ldr x8,[x19,#136]
ldr d0,[x8,w22,uxtw #3]
fabs d0,d0
fmov d1,#1.0
fcmp d0,d1
b.gt .Lreject
b.vs .Lreject
ldr x8,[x19,#144]
ldr d0,[x8,w22,uxtw #3]
fabs d0,d0
fmov d1,#1.0
fcmp d0,d1
b.gt .Lreject
b.vs .Lreject
ldr x8,[x19,#112]
ldr d1,[x8,w22,uxtw #3]
fcmp d1,#0.0
b.lt .Lreject
b.vs .Lreject
fmov x11,d1
lsr x11,x11,#52
and x11,x11,#0x7ff
cmp x11,#2047
b.eq .Lreject
mov w24,#1
.Linput_pressure:
madd w9,w24,w25,w22
ldr d0,[x8,w9,uxtw #3]
fcmp d0,d1
b.le .Lreject
b.vs .Lreject
fmov x11,d0
lsr x11,x11,#52
and x11,x11,#0x7ff
cmp x11,#2047
b.eq .Lreject
fmov d1,d0
add w24,w24,#1
cmp w24,w26
b.le .Linput_pressure
ldr w9,[x29,#496]
cmp w9,#0
csel w10,w22,w23,eq
mov w24,#0
ldr x8,[x19,#152]
.Linput_temperature:
madd w9,w24,w28,w10
ldr d0,[x8,w9,uxtw #3]
fcmp d0,#0.0
b.le .Lreject
b.vs .Lreject
fmov x11,d0
lsr x11,x11,#52
and x11,x11,#0x7ff
cmp x11,#2047
b.eq .Lreject
add w24,w24,#1
cmp w24,w26
b.le .Linput_temperature
ldr x8,[x19,#160]
mov w24,#0
.Linput_humidity_20:
madd w9,w24,w28,w10
ldr d0,[x8,w9,uxtw #3]
fmov x11,d0
lsr x11,x11,#52
and x11,x11,#0x7ff
cmp x11,#2047
b.eq .Lreject
add w24,w24,#1
cmp w24,w26
b.lt .Linput_humidity_20
ldr x8,[x19,#168]
mov w24,#0
.Linput_humidity_21:
madd w9,w24,w28,w10
ldr d0,[x8,w9,uxtw #3]
fmov x11,d0
lsr x11,x11,#52
and x11,x11,#0x7ff
cmp x11,#2047
b.eq .Lreject
fcmp d0,#0.0
b.le .Lreject
add w24,w24,#1
cmp w24,w26
b.lt .Linput_humidity_21
ldr w9,[x29,#488]
add w22,w22,w9
add w23,w23,#1
ldr w9,[x29,#484]
cmp w22,w9
b.le .Linput_columns
mov w9,#96
madd w9,w26,w9,wzr
add w9,w9,#12288
add w9,w9,#32
umull x0,w9,w25
str x0,[x29,#120]
ldr x8,[x29,#128]
ldr x9,[x8]
cmp x0,x9
b.hi .Lreject
bl malloc
cbz x0,.Lallocation_failed
mov x20,x0
str x0,[x29,#112]
add x8,x20,x25,lsl #9
str x8,[x29,#144]
add w9,w26,#1
umull x9,w9,w25
add x8,x8,x9,lsl #3
str x8,[x29,#152]
mov w9,#793
umull x9,w9,w25
add x8,x8,x9,lsl #3
str x8,[x29,#160]
mov w9,#671
umull x9,w9,w25
add x8,x8,x9,lsl #3
str x8,[x29,#168]
mov w9,#6
str w9,[x29,#504]
mov w9,#66
str w9,[x29,#508]
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
bl md2asm_sin_original_rounding
adrp x9,.Lcounts
add x9,x9,:lo12:.Lcounts
add x9,x9,#8
.Latomic_count_0:
ldxr x10,[x9]
add x10,x10,#1
stxr w11,x10,[x9]
cbnz w11,.Latomic_count_0
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
ldr w23,[x29,#492]
.Ltegen_columns:
add x21,x20,x23,lsl #9
ldr x8,[x19,#128]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#120]
ldr d1,[x8,w22,uxtw #3]
ldr x0,[x29,#3440]
add x1,x29,#576
add x2,x29,#1088
mov w3,#72
mov w4,#46
bl .Linterpolate
str d0,[x21,#0]
ldr x8,[x19,#128]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#120]
ldr d1,[x8,w22,uxtw #3]
ldr x0,[x29,#3448]
add x1,x29,#576
add x2,x29,#1088
mov w3,#72
mov w4,#46
bl .Linterpolate
str d0,[x21,#8]
ldr x8,[x19,#128]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#120]
ldr d1,[x8,w22,uxtw #3]
ldr x0,[x29,#3456]
add x1,x29,#576
add x2,x29,#1088
mov w3,#72
mov w4,#46
bl .Linterpolate
str d0,[x21,#16]
ldr x8,[x19,#128]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#120]
ldr d1,[x8,w22,uxtw #3]
ldr x0,[x29,#3464]
add x1,x29,#576
add x2,x29,#1088
mov w3,#72
mov w4,#46
bl .Linterpolate
str d0,[x21,#24]
ldr x8,[x19,#128]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#120]
ldr d1,[x8,w22,uxtw #3]
ldr x0,[x29,#3472]
add x1,x29,#576
add x2,x29,#1088
mov w3,#72
mov w4,#46
bl .Linterpolate
str d0,[x21,#32]
ldr w9,[x29,#488]
add w22,w22,w9
add w23,w23,#1
ldr w9,[x29,#484]
cmp w22,w9
b.le .Ltegen_columns
ldr w22,[x29,#480]
ldr w23,[x29,#492]
.Lclear_mass:
ldr x8,[x19,#192]
mov w24,#0
.Lclear_mass_layers:
madd w9,w24,w27,w23
str xzr,[x8,w9,uxtw #3]
add w24,w24,#1
mov w9,#12
mul w9,w9,w26
cmp w24,w9
b.lt .Lclear_mass_layers
ldr w9,[x29,#488]
add w22,w22,w9
add w23,w23,#1
ldr w9,[x29,#484]
cmp w22,w9
b.le .Lclear_mass
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
bl md2asm_sin_original_rounding
adrp x9,.Lcounts
add x9,x9,:lo12:.Lcounts
add x9,x9,#8
.Latomic_count_1:
ldxr x10,[x9]
add x10,x10,#1
stxr w11,x10,[x9]
cbnz w11,.Latomic_count_1
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
ldr w9,[x29,#192]
cbnz w9,.Ltrue_macc_columns_begin
ldr w22,[x29,#480]
ldr w23,[x29,#492]
.Lmacc_columns:
add x21,x20,x23,lsl #9
ldr x8,[x19,#128]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#120]
ldr d1,[x8,w22,uxtw #3]
ldr x0,[x29,#3480]
add x1,x29,#576
add x2,x29,#1088
mov w3,#120
mov w4,#61
bl .Linterpolate
str d0,[x21,#40]
ldr x8,[x19,#128]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#120]
ldr d1,[x8,w22,uxtw #3]
ldr x0,[x29,#3488]
add x1,x29,#576
add x2,x29,#1088
mov w3,#120
mov w4,#61
bl .Linterpolate
str d0,[x21,#48]
ldr x8,[x19,#128]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#120]
ldr d1,[x8,w22,uxtw #3]
ldr x0,[x29,#3496]
add x1,x29,#576
add x2,x29,#1088
mov w3,#120
mov w4,#61
bl .Linterpolate
str d0,[x21,#56]
ldr x8,[x19,#128]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#120]
ldr d1,[x8,w22,uxtw #3]
ldr x0,[x29,#3504]
add x1,x29,#576
add x2,x29,#1088
mov w3,#120
mov w4,#61
bl .Linterpolate
str d0,[x21,#64]
ldr x8,[x19,#128]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#120]
ldr d1,[x8,w22,uxtw #3]
ldr x0,[x29,#3512]
add x1,x29,#576
add x2,x29,#1088
mov w3,#120
mov w4,#61
bl .Linterpolate
str d0,[x21,#72]
ldr x8,[x19,#128]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#120]
ldr d1,[x8,w22,uxtw #3]
ldr x0,[x29,#3520]
add x1,x29,#576
add x2,x29,#1088
mov w3,#120
mov w4,#61
bl .Linterpolate
str d0,[x21,#80]
ldr x8,[x19,#128]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#120]
ldr d1,[x8,w22,uxtw #3]
ldr x0,[x29,#3528]
add x1,x29,#576
add x2,x29,#1088
mov w3,#120
mov w4,#61
bl .Linterpolate
str d0,[x21,#88]
ldr x8,[x19,#128]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#120]
ldr d1,[x8,w22,uxtw #3]
ldr x0,[x29,#3536]
add x1,x29,#576
add x2,x29,#1088
mov w3,#120
mov w4,#61
bl .Linterpolate
str d0,[x21,#96]
ldr x8,[x19,#128]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#120]
ldr d1,[x8,w22,uxtw #3]
ldr x0,[x29,#3544]
add x1,x29,#576
add x2,x29,#1088
mov w3,#120
mov w4,#61
bl .Linterpolate
str d0,[x21,#104]
ldr x8,[x19,#128]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#120]
ldr d1,[x8,w22,uxtw #3]
ldr x0,[x29,#3552]
add x1,x29,#576
add x2,x29,#1088
mov w3,#120
mov w4,#61
bl .Linterpolate
str d0,[x21,#112]
ldr x8,[x19,#128]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#120]
ldr d1,[x8,w22,uxtw #3]
ldr x0,[x29,#3560]
add x1,x29,#576
add x2,x29,#1088
mov w3,#120
mov w4,#61
bl .Linterpolate
str d0,[x21,#120]
ldr w9,[x29,#488]
add w22,w22,w9
add w23,w23,#1
ldr w9,[x29,#484]
cmp w22,w9
b.le .Lmacc_columns
b .Lmacc_done
.Ltrue_macc_columns_begin:
ldr w22,[x29,#480]
ldr w23,[x29,#492]
.Ltrue_macc_columns:
mov w24,#1
.Ltrue_macc_layers:
ldr x8,[x19,#128]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#120]
ldr d1,[x8,w22,uxtw #3]
ldr x0,[x29,#4008]
sub w9,w24,#1
mov w10,#7320
mul w9,w9,w10
add x0,x0,x9,lsl #3
add x1,x29,#576
add x2,x29,#1088
mov w3,#120
mov w4,#61
bl .Linterpolate
mov w9,#671
add w9,w9,w24
madd w9,w9,w27,w23
ldr x8,[x29,#152]
str d0,[x8,w9,uxtw #3]
ldr x8,[x19,#128]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#120]
ldr d1,[x8,w22,uxtw #3]
ldr x0,[x29,#4016]
sub w9,w24,#1
mov w10,#7320
mul w9,w9,w10
add x0,x0,x9,lsl #3
add x1,x29,#576
add x2,x29,#1088
mov w3,#120
mov w4,#61
bl .Linterpolate
mov w9,#732
add w9,w9,w24
madd w9,w9,w27,w23
ldr x8,[x29,#152]
str d0,[x8,w9,uxtw #3]
ldr x8,[x19,#128]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#120]
ldr d1,[x8,w22,uxtw #3]
ldr x0,[x29,#3920]
sub w9,w24,#1
mov w10,#7320
mul w9,w9,w10
add x0,x0,x9,lsl #3
add x1,x29,#576
add x2,x29,#1088
mov w3,#120
mov w4,#61
bl .Linterpolate
mov w9,#0
add w9,w9,w24
madd w9,w9,w27,w23
ldr x8,[x29,#152]
str d0,[x8,w9,uxtw #3]
ldr x8,[x19,#128]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#120]
ldr d1,[x8,w22,uxtw #3]
ldr x0,[x29,#3928]
sub w9,w24,#1
mov w10,#7320
mul w9,w9,w10
add x0,x0,x9,lsl #3
add x1,x29,#576
add x2,x29,#1088
mov w3,#120
mov w4,#61
bl .Linterpolate
mov w9,#61
add w9,w9,w24
madd w9,w9,w27,w23
ldr x8,[x29,#152]
str d0,[x8,w9,uxtw #3]
ldr x8,[x19,#128]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#120]
ldr d1,[x8,w22,uxtw #3]
ldr x0,[x29,#3936]
sub w9,w24,#1
mov w10,#7320
mul w9,w9,w10
add x0,x0,x9,lsl #3
add x1,x29,#576
add x2,x29,#1088
mov w3,#120
mov w4,#61
bl .Linterpolate
mov w9,#122
add w9,w9,w24
madd w9,w9,w27,w23
ldr x8,[x29,#152]
str d0,[x8,w9,uxtw #3]
ldr x8,[x19,#128]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#120]
ldr d1,[x8,w22,uxtw #3]
ldr x0,[x29,#3944]
sub w9,w24,#1
mov w10,#7320
mul w9,w9,w10
add x0,x0,x9,lsl #3
add x1,x29,#576
add x2,x29,#1088
mov w3,#120
mov w4,#61
bl .Linterpolate
mov w9,#183
add w9,w9,w24
madd w9,w9,w27,w23
ldr x8,[x29,#152]
str d0,[x8,w9,uxtw #3]
ldr x8,[x19,#128]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#120]
ldr d1,[x8,w22,uxtw #3]
ldr x0,[x29,#3952]
sub w9,w24,#1
mov w10,#7320
mul w9,w9,w10
add x0,x0,x9,lsl #3
add x1,x29,#576
add x2,x29,#1088
mov w3,#120
mov w4,#61
bl .Linterpolate
mov w9,#244
add w9,w9,w24
madd w9,w9,w27,w23
ldr x8,[x29,#152]
str d0,[x8,w9,uxtw #3]
ldr x8,[x19,#128]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#120]
ldr d1,[x8,w22,uxtw #3]
ldr x0,[x29,#3960]
sub w9,w24,#1
mov w10,#7320
mul w9,w9,w10
add x0,x0,x9,lsl #3
add x1,x29,#576
add x2,x29,#1088
mov w3,#120
mov w4,#61
bl .Linterpolate
mov w9,#305
add w9,w9,w24
madd w9,w9,w27,w23
ldr x8,[x29,#152]
str d0,[x8,w9,uxtw #3]
ldr x8,[x19,#128]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#120]
ldr d1,[x8,w22,uxtw #3]
ldr x0,[x29,#3968]
sub w9,w24,#1
mov w10,#7320
mul w9,w9,w10
add x0,x0,x9,lsl #3
add x1,x29,#576
add x2,x29,#1088
mov w3,#120
mov w4,#61
bl .Linterpolate
mov w9,#366
add w9,w9,w24
madd w9,w9,w27,w23
ldr x8,[x29,#152]
str d0,[x8,w9,uxtw #3]
ldr x8,[x19,#128]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#120]
ldr d1,[x8,w22,uxtw #3]
ldr x0,[x29,#3976]
sub w9,w24,#1
mov w10,#7320
mul w9,w9,w10
add x0,x0,x9,lsl #3
add x1,x29,#576
add x2,x29,#1088
mov w3,#120
mov w4,#61
bl .Linterpolate
mov w9,#427
add w9,w9,w24
madd w9,w9,w27,w23
ldr x8,[x29,#152]
str d0,[x8,w9,uxtw #3]
ldr x8,[x19,#128]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#120]
ldr d1,[x8,w22,uxtw #3]
ldr x0,[x29,#3984]
sub w9,w24,#1
mov w10,#7320
mul w9,w9,w10
add x0,x0,x9,lsl #3
add x1,x29,#576
add x2,x29,#1088
mov w3,#120
mov w4,#61
bl .Linterpolate
mov w9,#488
add w9,w9,w24
madd w9,w9,w27,w23
ldr x8,[x29,#152]
str d0,[x8,w9,uxtw #3]
ldr x8,[x19,#128]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#120]
ldr d1,[x8,w22,uxtw #3]
ldr x0,[x29,#3992]
sub w9,w24,#1
mov w10,#7320
mul w9,w9,w10
add x0,x0,x9,lsl #3
add x1,x29,#576
add x2,x29,#1088
mov w3,#120
mov w4,#61
bl .Linterpolate
mov w9,#549
add w9,w9,w24
madd w9,w9,w27,w23
ldr x8,[x29,#152]
str d0,[x8,w9,uxtw #3]
ldr x8,[x19,#128]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#120]
ldr d1,[x8,w22,uxtw #3]
ldr x0,[x29,#4000]
sub w9,w24,#1
mov w10,#7320
mul w9,w9,w10
add x0,x0,x9,lsl #3
add x1,x29,#576
add x2,x29,#1088
mov w3,#120
mov w4,#61
bl .Linterpolate
mov w9,#610
add w9,w9,w24
madd w9,w9,w27,w23
ldr x8,[x29,#152]
str d0,[x8,w9,uxtw #3]
add w24,w24,#1
cmp w24,#60
b.le .Ltrue_macc_layers
add w22,w22,#1
add w23,w23,#1
ldr w9,[x29,#484]
cmp w22,w9
b.le .Ltrue_macc_columns
.Lmacc_done:
ldr x8,[x19,#128]
ldr w9,[x29,#480]
add x0,x8,w9,uxtw #3
add x1,x29,#504
add x2,x29,#508
add x3,x29,#2064
bl md2asm_runtime_radiation_aerosol_and_ozone_preparation_legtri
adrp x9,.Lcounts
add x9,x9,:lo12:.Lcounts
add x9,x9,#0
.Latomic_count_2:
ldxr x10,[x9]
add x10,x10,#1
stxr w11,x10,[x9]
cbnz w11,.Latomic_count_2
add x0,x29,#2064
ldr x8,[x19,#24]
add x1,x8,#512
add x2,x8,#680
add x3,x29,#2592
mov w4,#6
bl .Ltransform
add x0,x29,#2064
ldr x8,[x19,#24]
add x1,x8,#800
add x2,x8,#968
add x3,x29,#2680
mov w4,#6
bl .Ltransform
ldr w22,[x29,#480]
ldr w23,[x29,#492]
.Lozone_columns:
add x21,x20,x23,lsl #9
ldr x8,[x19,#136]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#144]
ldr d1,[x8,w22,uxtw #3]
add x0,x29,#2592
mov w1,#6
bl .Lfourier
str d0,[x21,#160]
ldr x8,[x19,#136]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#144]
ldr d1,[x8,w22,uxtw #3]
add x0,x29,#2680
mov w1,#6
bl .Lfourier
fsqrt d0,d0
fmul d1,d0,d0
fmul d0,d1,d0
str d0,[x21,#168]
ldr w9,[x29,#488]
add w22,w22,w9
add w23,w23,#1
ldr w9,[x29,#484]
cmp w22,w9
b.le .Lozone_columns
mov w9,#11
str w9,[x29,#504]
ldr x8,[x19,#128]
ldr w9,[x29,#480]
add x0,x8,w9,uxtw #3
add x1,x29,#504
add x2,x29,#508
add x3,x29,#2064
bl md2asm_runtime_radiation_aerosol_and_ozone_preparation_legtri
adrp x9,.Lcounts
add x9,x9,:lo12:.Lcounts
add x9,x9,#0
.Latomic_count_3:
ldxr x10,[x9]
add x10,x10,#1
stxr w11,x10,[x9]
cbnz w11,.Latomic_count_3
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
ldr w22,[x29,#480]
ldr w23,[x29,#492]
.Lharmonic_columns:
add x21,x20,x23,lsl #9
ldr x8,[x19,#136]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#144]
ldr d1,[x8,w22,uxtw #3]
add x0,x29,#2768
mov w1,#11
bl .Lfourier
str d0,[x21,#128]
ldr x8,[x19,#136]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#144]
ldr d1,[x8,w22,uxtw #3]
add x0,x29,#2936
mov w1,#11
bl .Lfourier
str d0,[x21,#136]
ldr x8,[x19,#136]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#144]
ldr d1,[x8,w22,uxtw #3]
add x0,x29,#3104
mov w1,#11
bl .Lfourier
str d0,[x21,#144]
ldr x8,[x19,#136]
ldr d0,[x8,w22,uxtw #3]
ldr x8,[x19,#144]
ldr d1,[x8,w22,uxtw #3]
add x0,x29,#3272
mov w1,#11
bl .Lfourier
str d0,[x21,#152]
ldr w9,[x29,#488]
add w22,w22,w9
add w23,w23,#1
ldr w9,[x29,#484]
cmp w22,w9
b.le .Lharmonic_columns
ldr w22,[x29,#480]
ldr w23,[x29,#492]
.Linitial_columns:
add x21,x20,x23,lsl #9
ldr x8,[x19,#112]
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
ldr x9,[x29,#3576]
ldr d1,[x9]
fmul d0,d0,d1
ldr d1,[x21,#232]
fadd d0,d0,d1
str d0,[x21,#208]
ldr w9,[x29,#192]
cbnz w9,.Linitial_macc_done
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
.Linitial_macc_done:
ldr w9,[x29,#488]
add w22,w22,w9
add w23,w23,#1
ldr w9,[x29,#484]
cmp w22,w9
b.le .Linitial_columns
mov w24,#0
.Llayers:
ldr w22,[x29,#480]
ldr w23,[x29,#492]
.Llayer_columns:
add x21,x20,x23,lsl #9
ldr w9,[x29,#496]
cmp w9,#0
csel w10,w22,w23,eq
madd w11,w24,w28,w10
ldr x8,[x19,#152]
ldr d0,[x8,w11,uxtw #3]
add w12,w11,w28
ldr d1,[x8,w12,uxtw #3]
fdiv d0,d0,d1
str d0,[x29,#3736]
ldr x8,[x19,#160]
ldr d0,[x8,w11,uxtw #3]
ldr x8,[x19,#168]
ldr d1,[x8,w11,uxtw #3]
fdiv d0,d0,d1
str d0,[x29,#3728]
ldr x8,[x19,#112]
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
bl md2asm_pow_original_rounding_candidate
adrp x9,.Lcounts
add x9,x9,:lo12:.Lcounts
add x9,x9,#16
.Latomic_count_4:
ldxr x10,[x9]
add x10,x10,#1
stxr w11,x10,[x9]
cbnz w11,.Latomic_count_4
ldr d1,[x21,#192]
fmul d0,d1,d0
b .Lweight_ready
.Lweight_one:
fmov d0,#1.0
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
ldr d0,[x21,#8]
ldr x9,[x29,#3576]
add w10,w24,#1
ldr d1,[x9,w10,uxtw #3]
fmul d0,d0,d1
ldr d1,[x29,#3824]
fadd d0,d0,d1
str d0,[x29,#3832]
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
ldr x8,[x19,#0]
ldr d0,[x8,#4160]
ldr d1,[x29,#3696]
fmul d0,d0,d1
ldr d1,[x29,#3832]
fadd d1,d0,d1
ldr d2,[x21,#208]
fsub d1,d1,d2
ldr d2,[x29,#3720]
fmul d1,d2,d1
fmul d0,d2,d0
ldr x8,[x19,#184]
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
ldr x8,[x19,#184]
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
ldr x8,[x19,#184]
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
ldr x8,[x19,#184]
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
ldr x8,[x19,#184]
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
ldr x8,[x19,#184]
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
ldr x8,[x19,#200]
madd w9,w24,w27,w23
str d0,[x8,w9,uxtw #3]
ldr w9,[x29,#192]
cbnz w9,.Llayer_macc_done
ldr d0,[x29,#3696]
ldr d1,[x29,#552]
fdiv d0,d0,d1
str d0,[x29,#3752]
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
ldr d1,[x29,#3752]
fdiv d0,d0,d1
ldr x8,[x19,#192]
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
ldr d1,[x29,#3752]
fdiv d0,d0,d1
ldr x8,[x19,#192]
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
ldr d1,[x29,#3752]
fdiv d0,d0,d1
ldr x8,[x19,#192]
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
ldr d1,[x29,#3752]
fdiv d0,d0,d1
ldr x8,[x19,#192]
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
ldr d1,[x29,#3752]
fdiv d0,d0,d1
ldr x8,[x19,#192]
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
ldr d1,[x29,#3752]
fdiv d0,d0,d1
ldr x8,[x19,#192]
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
ldr d1,[x29,#3752]
fdiv d0,d0,d1
ldr x8,[x19,#192]
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
ldr d1,[x29,#3752]
fdiv d0,d0,d1
ldr x8,[x19,#192]
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
ldr d1,[x29,#3752]
fdiv d0,d0,d1
ldr x8,[x19,#192]
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
ldr d1,[x29,#3752]
fdiv d0,d0,d1
ldr x8,[x19,#192]
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
ldr d1,[x29,#3752]
fdiv d0,d0,d1
ldr x8,[x19,#192]
mov w9,#10
madd w9,w9,w26,w24
madd w9,w9,w27,w23
str d0,[x8,w9,uxtw #3]
ldr x8,[x19,#192]
mov w9,#11
madd w9,w9,w26,w24
madd w9,w9,w27,w23
str xzr,[x8,w9,uxtw #3]
.Llayer_macc_done:
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
ldr x8,[x19,#184]
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
ldr w9,[x29,#488]
add w22,w22,w9
add w23,w23,#1
ldr w9,[x29,#484]
cmp w22,w9
b.le .Llayer_columns
add w24,w24,#1
cmp w24,w26
b.lt .Llayers
ldr w22,[x29,#480]
.Lzero_columns:
mov w24,#0
.Lzero_species:
mov w9,#61
mul w9,w24,w9
madd w9,w9,w27,w22
ldr x8,[x29,#160]
str xzr,[x8,w9,uxtw #3]
add w9,w26,#1
mul w9,w24,w9
madd w9,w9,w27,w22
ldr x8,[x29,#168]
str xzr,[x8,w9,uxtw #3]
add w24,w24,#1
cmp w24,#11
b.lt .Lzero_species
mov w9,#671
madd w9,w9,w27,w22
ldr x8,[x29,#152]
str xzr,[x8,w9,uxtw #3]
add w22,w22,#1
ldr w9,[x29,#484]
cmp w22,w9
b.le .Lzero_columns
ldr x8,[x19,#112]
ldr x9,[x29,#144]
mov w10,#0
add w12,w26,#1
mul w12,w12,w25
.Lpressure_copy:
ldr x11,[x8,w10,uxtw #3]
str x11,[x9,w10,uxtw #3]
add w10,w10,#1
cmp w10,w12
b.lt .Lpressure_copy
ldr w9,[x29,#192]
cbz w9,.Lsuccess
mov w24,#1
.Lcumulative_layers:
mov w23,#0
.Lcumulative_species:
mov w9,#61
madd w9,w23,w9,w24
mul w9,w9,w27
ldr w22,[x29,#480]
.Lcumulative_columns:
add w10,w9,w22
sub w11,w10,w27
ldr x8,[x29,#160]
ldr d0,[x8,w11,uxtw #3]
ldr x8,[x29,#152]
ldr d1,[x8,w10,uxtw #3]
fadd d0,d0,d1
ldr x8,[x29,#160]
str d0,[x8,w10,uxtw #3]
add w22,w22,#1
ldr w11,[x29,#484]
cmp w22,w11
b.le .Lcumulative_columns
add w23,w23,#1
cmp w23,#11
b.lt .Lcumulative_species
add w24,w24,#1
cmp w24,#60
b.le .Lcumulative_layers
mov w24,#1
.Lvertical_layers:
ldr w22,[x29,#480]
.Lvertical_columns:
madd w9,w24,w25,w22
ldr x8,[x29,#144]
ldr d0,[x8,w9,uxtw #3]
mov w9,#0
mov w10,#59
mov w13,#671
madd w13,w13,w27,w22
ldr x8,[x29,#152]
.Lvertical_search:
madd w11,w9,w27,w13
ldr d1,[x8,w11,uxtw #3]
add w12,w11,w27
ldr d2,[x8,w12,uxtw #3]
fcmp d0,d1
b.lt .Lvertical_next
fcmp d0,d2
b.lt .Lvertical_found
.Lvertical_next:
add w9,w9,#1
cmp w9,#60
b.lt .Lvertical_search
mov w9,w10
.Lvertical_found:
madd w11,w9,w27,w13
ldr d1,[x8,w11,uxtw #3]
add w12,w11,w27
ldr d2,[x8,w12,uxtw #3]
fsub d0,d0,d1
fsub d2,d2,d1
fdiv d0,d0,d2
mov w23,#0
.Lvertical_species:
mov w11,#61
madd w11,w23,w11,w9
madd w11,w11,w27,w22
ldr x8,[x29,#160]
ldr d1,[x8,w11,uxtw #3]
add w12,w11,w27
ldr d2,[x8,w12,uxtw #3]
fsub d2,d2,d1
fmul d2,d0,d2
fadd d2,d1,d2
add w11,w26,#1
madd w11,w23,w11,w24
madd w11,w11,w27,w22
ldr x8,[x29,#168]
str d2,[x8,w11,uxtw #3]
add w23,w23,#1
cmp w23,#11
b.lt .Lvertical_species
add w22,w22,#1
ldr w9,[x29,#484]
cmp w22,w9
b.le .Lvertical_columns
add w24,w24,#1
cmp w24,w26
b.le .Lvertical_layers
mov w24,#1
.Lmass_layers:
ldr w22,[x29,#480]
.Lmass_columns:
madd w9,w24,w25,w22
ldr x8,[x29,#144]
ldr d0,[x8,w9,uxtw #3]
sub w10,w9,w25
ldr d1,[x8,w10,uxtw #3]
fsub d0,d0,d1
ldr d1,[x29,#552]
fdiv d0,d0,d1
mov w9,#7
add w10,w26,#1
madd w9,w9,w10,w24
madd w9,w9,w27,w22
ldr x8,[x29,#168]
ldr d1,[x8,w9,uxtw #3]
sub w10,w9,w27
ldr d2,[x8,w10,uxtw #3]
fsub d1,d1,d2
fdiv d1,d1,d0
mov w9,#0
madd w9,w9,w26,w24
sub w9,w9,#1
madd w9,w9,w27,w22
ldr x8,[x19,#192]
str d1,[x8,w9,uxtw #3]
mov w9,#8
add w10,w26,#1
madd w9,w9,w10,w24
madd w9,w9,w27,w22
ldr x8,[x29,#168]
ldr d1,[x8,w9,uxtw #3]
sub w10,w9,w27
ldr d2,[x8,w10,uxtw #3]
fsub d1,d1,d2
fdiv d1,d1,d0
mov w9,#1
madd w9,w9,w26,w24
sub w9,w9,#1
madd w9,w9,w27,w22
ldr x8,[x19,#192]
str d1,[x8,w9,uxtw #3]
mov w9,#9
add w10,w26,#1
madd w9,w9,w10,w24
madd w9,w9,w27,w22
ldr x8,[x29,#168]
ldr d1,[x8,w9,uxtw #3]
sub w10,w9,w27
ldr d2,[x8,w10,uxtw #3]
fsub d1,d1,d2
fdiv d1,d1,d0
mov w9,#2
madd w9,w9,w26,w24
sub w9,w9,#1
madd w9,w9,w27,w22
ldr x8,[x19,#192]
str d1,[x8,w9,uxtw #3]
mov w9,#4
add w10,w26,#1
madd w9,w9,w10,w24
madd w9,w9,w27,w22
ldr x8,[x29,#168]
ldr d1,[x8,w9,uxtw #3]
sub w10,w9,w27
ldr d2,[x8,w10,uxtw #3]
fsub d1,d1,d2
fdiv d1,d1,d0
mov w9,#3
madd w9,w9,w26,w24
sub w9,w9,#1
madd w9,w9,w27,w22
ldr x8,[x19,#192]
str d1,[x8,w9,uxtw #3]
mov w9,#5
add w10,w26,#1
madd w9,w9,w10,w24
madd w9,w9,w27,w22
ldr x8,[x29,#168]
ldr d1,[x8,w9,uxtw #3]
sub w10,w9,w27
ldr d2,[x8,w10,uxtw #3]
fsub d1,d1,d2
fdiv d1,d1,d0
mov w9,#4
madd w9,w9,w26,w24
sub w9,w9,#1
madd w9,w9,w27,w22
ldr x8,[x19,#192]
str d1,[x8,w9,uxtw #3]
mov w9,#6
add w10,w26,#1
madd w9,w9,w10,w24
madd w9,w9,w27,w22
ldr x8,[x29,#168]
ldr d1,[x8,w9,uxtw #3]
sub w10,w9,w27
ldr d2,[x8,w10,uxtw #3]
fsub d1,d1,d2
fdiv d1,d1,d0
mov w9,#5
madd w9,w9,w26,w24
sub w9,w9,#1
madd w9,w9,w27,w22
ldr x8,[x19,#192]
str d1,[x8,w9,uxtw #3]
mov w9,#2
add w10,w26,#1
madd w9,w9,w10,w24
madd w9,w9,w27,w22
ldr x8,[x29,#168]
ldr d1,[x8,w9,uxtw #3]
sub w10,w9,w27
ldr d2,[x8,w10,uxtw #3]
fsub d1,d1,d2
fdiv d1,d1,d0
mov w9,#6
madd w9,w9,w26,w24
sub w9,w9,#1
madd w9,w9,w27,w22
ldr x8,[x19,#192]
str d1,[x8,w9,uxtw #3]
mov w9,#3
add w10,w26,#1
madd w9,w9,w10,w24
madd w9,w9,w27,w22
ldr x8,[x29,#168]
ldr d1,[x8,w9,uxtw #3]
sub w10,w9,w27
ldr d2,[x8,w10,uxtw #3]
fsub d1,d1,d2
fdiv d1,d1,d0
mov w9,#7
madd w9,w9,w26,w24
sub w9,w9,#1
madd w9,w9,w27,w22
ldr x8,[x19,#192]
str d1,[x8,w9,uxtw #3]
mov w9,#0
add w10,w26,#1
madd w9,w9,w10,w24
madd w9,w9,w27,w22
ldr x8,[x29,#168]
ldr d1,[x8,w9,uxtw #3]
sub w10,w9,w27
ldr d2,[x8,w10,uxtw #3]
fsub d1,d1,d2
fdiv d1,d1,d0
mov w9,#8
madd w9,w9,w26,w24
sub w9,w9,#1
madd w9,w9,w27,w22
ldr x8,[x19,#192]
str d1,[x8,w9,uxtw #3]
mov w9,#1
add w10,w26,#1
madd w9,w9,w10,w24
madd w9,w9,w27,w22
ldr x8,[x29,#168]
ldr d1,[x8,w9,uxtw #3]
sub w10,w9,w27
ldr d2,[x8,w10,uxtw #3]
fsub d1,d1,d2
fdiv d1,d1,d0
mov w9,#9
madd w9,w9,w26,w24
sub w9,w9,#1
madd w9,w9,w27,w22
ldr x8,[x19,#192]
str d1,[x8,w9,uxtw #3]
mov w9,#10
add w10,w26,#1
madd w9,w9,w10,w24
madd w9,w9,w27,w22
ldr x8,[x29,#168]
ldr d1,[x8,w9,uxtw #3]
sub w10,w9,w27
ldr d2,[x8,w10,uxtw #3]
fsub d1,d1,d2
fdiv d1,d1,d0
mov w9,#10
madd w9,w9,w26,w24
sub w9,w9,#1
madd w9,w9,w27,w22
ldr x8,[x19,#192]
str d1,[x8,w9,uxtw #3]
mov w9,#11
madd w9,w9,w26,w24
sub w9,w9,#1
madd w9,w9,w27,w22
ldr x8,[x19,#192]
str xzr,[x8,w9,uxtw #3]
add w22,w22,#1
ldr w9,[x29,#484]
cmp w22,w9
b.le .Lmass_columns
add w24,w24,#1
cmp w24,w26
b.le .Lmass_layers
.Lsuccess:
mov w9,#0
str w9,[x29,#196]
b .Lexit
.Lallocation_failed:
mov w9,#1
str w9,[x29,#196]
b .Lexit
.Lreject:
mov w9,#2
str w9,[x29,#196]
.Lexit:
ldr x0,[x29,#112]
cbz x0,.Lrestored
bl free
.Lrestored:
ldr w0,[x29,#196]
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
.size md2asm_runtime_radiation_aerosol_and_ozone_preparation,.-md2asm_runtime_radiation_aerosol_and_ozone_preparation
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
add w11,w26,#1
cmp x10,x11
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
.Lclimate3:
ldr x9,[x0]
cbz x9,.Lreject
tst x9,#7
b.ne .Lreject
ldrb w10,[x0,#28]
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
ldr x10,[x0,#88]
mov x11,#7320
cmp x10,x11
b.ne .Lreject
ldr x10,[x0,#96]
cmp x10,#1
b.ne .Lreject
ldr x10,[x0,#104]
cmp x10,#60
b.ne .Lreject
ldr x10,[x0,#8]
mov x11,#7441
add x10,x10,x11
add x0,x9,x10,lsl #3
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
.global md2asm_runtime_radiation_aerosol_and_ozone_preparation_private_child_count_get
.type md2asm_runtime_radiation_aerosol_and_ozone_preparation_private_child_count_get,%function
md2asm_runtime_radiation_aerosol_and_ozone_preparation_private_child_count_get:
cmp w0,#3
b.hs .Lcountzero
adrp x9,.Lcounts
add x9,x9,:lo12:.Lcounts
ldr x0,[x9,w0,uxtw #3]
ret
.Lcountzero:
mov x0,#0
ret
.size md2asm_runtime_radiation_aerosol_and_ozone_preparation_private_child_count_get,.-md2asm_runtime_radiation_aerosol_and_ozone_preparation_private_child_count_get
.section .rodata
.p2align 3
.Lreals:
.double 90.0,180.0,999.0,64.0
.data
.p2align 3
.Lcounts:
.zero 24
#define ORIGINAL_SYMBOL md2asm_runtime_radiation_aerosol_and_ozone_preparation_legtri
#define md2asm_legtri md2asm_runtime_radiation_aerosol_and_ozone_preparation_legtri_alias
#include "../dynamics/legtri.S"
