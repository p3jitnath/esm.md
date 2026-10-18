// Contract: skills/md2asm-gpu/references/openifs/physics/model_time_and_forcing.md.
/* Complete UPDTIM original9 storage transaction. skills/md2asm-gpu/references/openifs/physics/model_time_and_forcing.md revision1.
 * MODEL and every original pointed owner retain complete source bytes.
 */
.arch armv8-a
.text
.p2align 4
.macro time_host_call name
bl \name
ldr x18,[sp,#96]
.endm
.global md2asm_gpu_host_model_time
.type md2asm_gpu_host_model_time,%function
#ifndef MD2ASM_GPU_VERIFY_ONLY
.global md2asm_model_time_and_forcing
.type md2asm_model_time_and_forcing,%function
.global updtim_
.type updtim_,%function
md2asm_model_time_and_forcing:
updtim_:
#endif
md2asm_gpu_host_model_time:
mov x17,sp
sub sp,sp,#8,lsl #12
stp x29,x30,[sp]
mov x29,sp
stp x19,x20,[sp,#16]
stp x21,x22,[sp,#32]
stp x23,x24,[sp,#48]
stp x25,x26,[sp,#64]
stp x27,x28,[sp,#80]
str x18,[sp,#96]
stp x0,x1,[sp,#256]
stp x2,x3,[sp,#272]
stp x4,x5,[sp,#288]
stp x6,x7,[sp,#304]
ldr x8,[x17]
str x8,[sp,#320]
add x19,sp,#256
add x20,sp,#384
mrs x8,fpcr
mrs x9,fpsr
stp x8,x9,[sp,#104]
cbnz x8,.Ltime_host_fail
time_host_call __errno_location
mov x22,x0
ldr w8,[x22]
str w8,[sp,#120]
time_host_call omp_in_parallel
cbnz w0,.Ltime_host_fail
time_host_call md2asm_openifs_gpu_prepare
cbnz w0,.Ltime_host_fail
ldr x8,[x19,#0]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#17096
adds x9,x8,x9
b.cs .Ltime_host_fail
ldr x8,[x19,#8]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#18224
adds x9,x8,x9
b.cs .Ltime_host_fail
ldr x8,[x19,#16]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#15248
movk x9,#65,lsl #16
adds x9,x8,x9
b.cs .Ltime_host_fail
ldr x8,[x19,#24]
cbz x8,.Ltime_host_fail
tst x8,#3
b.ne .Ltime_host_fail
movz x9,#4
adds x9,x8,x9
b.cs .Ltime_host_fail
ldr x8,[x19,#32]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#8
adds x9,x8,x9
b.cs .Ltime_host_fail
ldr x8,[x19,#40]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#8
adds x9,x8,x9
b.cs .Ltime_host_fail
ldr x8,[x19,#48]
cbz x8,.Ltime_host_fail
tst x8,#3
b.ne .Ltime_host_fail
movz x9,#4
adds x9,x8,x9
b.cs .Ltime_host_fail
ldr x8,[x19,#56]
cbz x8,.Ltime_host_optional_ready
cbz x8,.Ltime_host_fail
tst x8,#3
b.ne .Ltime_host_fail
movz x9,#4
adds x9,x8,x9
b.cs .Ltime_host_fail
.Ltime_host_optional_ready:
ldr x8,[x19,#64]
cbnz x8,.Ltime_host_fail
add x26,sp,#1,lsl #12
// arg0
ldr x8,[x19,#0]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#17096
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#17096
stp x8,x9,[x26,#0]
// arg1
ldr x8,[x19,#8]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#18224
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#18224
stp x8,x9,[x26,#32]
// arg2
ldr x8,[x19,#16]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#15248
movk x9,#65,lsl #16
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#15248
movk x9,#65,lsl #16
stp x8,x9,[x26,#64]
// greenhouse-climate-object
adrp x8,:got:__yomclim_MOD_yghgclim
ldr x8,[x8,:got_lo12:__yomclim_MOD_yghgclim]
ldr x8,[x8]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#1208
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#1208
stp x8,x9,[x26,#128]
// greenhouse-radiation-object
adrp x8,:got:__yoeradghg_MOD_yradghg
ldr x8,[x8,:got_lo12:__yoeradghg_MOD_yradghg]
ldr x8,[x8]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#928
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#928
stp x8,x9,[x26,#160]
// forcing-gas-object
#ifdef MD2ASM_GPU_VERIFY_ONLY
adrp x8,:got:__yomghgtimeseries_MOD_yghgtimeseries
ldr x8,[x8,:got_lo12:__yomghgtimeseries_MOD_yghgtimeseries]
ldr x8,[x8]
#else
adrp x8,:got:md2asm_owned_radiation_setup_context
ldr x8,[x8,:got_lo12:md2asm_owned_radiation_setup_context]
ldr x8,[x8,#4256]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#656
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#136
add x8,x8,x9
#endif
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#520
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#520
str x8,[x26,#1888]
str x9,[x26,#1896]
// forcing-solar-object
#ifdef MD2ASM_GPU_VERIFY_ONLY
adrp x8,:got:__yomsolarirradiance_MOD_ysolarirradiance
ldr x8,[x8,:got_lo12:__yomsolarirradiance_MOD_ysolarirradiance]
ldr x8,[x8]
#else
adrp x8,:got:md2asm_owned_radiation_setup_context
ldr x8,[x8,:got_lo12:md2asm_owned_radiation_setup_context]
ldr x8,[x8,#4256]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#136
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#0
add x8,x8,x9
#endif
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#136
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#136
str x8,[x26,#2176]
str x9,[x26,#2184]
// integer-dynamics-object
adrp x8,:got:__intdyn_mod_MOD_yytxyb
ldr x8,[x8,:got_lo12:__intdyn_mod_MOD_yytxyb]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#32
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#32
str x8,[x26,#2272]
str x9,[x26,#2280]
// ozone-monthly
ldr x8,[x26,#64]
movz x9,#48920
movk x9,#20,lsl #16
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#62016
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#62016
stp x8,x9,[x26,#96]
// greenhouse-pressure
ldr x8,[x26,#160]
movz x9,#64
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#736
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#736
stp x8,x9,[x26,#192]
// greenhouse-monthly-0
ldr x8,[x26,#128]
movz x9,#128
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#34816
movk x9,#8,lsl #16
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#34816
movk x9,#8,lsl #16
stp x8,x9,[x26,#224]
// greenhouse-output-0
ldr x8,[x26,#160]
movz x9,#216
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#46592
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#46592
stp x8,x9,[x26,#256]
// greenhouse-monthly-1
ldr x8,[x26,#128]
movz x9,#240
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#34816
movk x9,#8,lsl #16
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#34816
movk x9,#8,lsl #16
stp x8,x9,[x26,#288]
// greenhouse-output-1
ldr x8,[x26,#160]
movz x9,#128
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#46592
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#46592
stp x8,x9,[x26,#320]
// greenhouse-monthly-2
ldr x8,[x26,#128]
movz x9,#352
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#34816
movk x9,#8,lsl #16
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#34816
movk x9,#8,lsl #16
stp x8,x9,[x26,#352]
// greenhouse-output-2
ldr x8,[x26,#160]
movz x9,#304
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#46592
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#46592
stp x8,x9,[x26,#384]
// greenhouse-monthly-3
ldr x8,[x26,#128]
movz x9,#464
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#34816
movk x9,#8,lsl #16
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#34816
movk x9,#8,lsl #16
stp x8,x9,[x26,#416]
// greenhouse-output-3
ldr x8,[x26,#160]
movz x9,#392
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#46592
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#46592
stp x8,x9,[x26,#448]
// greenhouse-monthly-4
ldr x8,[x26,#128]
movz x9,#576
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#34816
movk x9,#8,lsl #16
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#34816
movk x9,#8,lsl #16
stp x8,x9,[x26,#480]
// greenhouse-output-4
ldr x8,[x26,#160]
movz x9,#480
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#46592
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#46592
str x8,[x26,#512]
str x9,[x26,#520]
// greenhouse-monthly-5
ldr x8,[x26,#128]
movz x9,#688
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#34816
movk x9,#8,lsl #16
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#34816
movk x9,#8,lsl #16
str x8,[x26,#544]
str x9,[x26,#552]
// greenhouse-output-5
ldr x8,[x26,#160]
movz x9,#568
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#46592
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#46592
str x8,[x26,#576]
str x9,[x26,#584]
// greenhouse-monthly-6
ldr x8,[x26,#128]
movz x9,#800
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#34816
movk x9,#8,lsl #16
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#34816
movk x9,#8,lsl #16
str x8,[x26,#608]
str x9,[x26,#616]
// greenhouse-output-6
ldr x8,[x26,#160]
movz x9,#832
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#46592
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#46592
str x8,[x26,#640]
str x9,[x26,#648]
// greenhouse-monthly-7
ldr x8,[x26,#128]
movz x9,#912
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#34816
movk x9,#8,lsl #16
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#34816
movk x9,#8,lsl #16
str x8,[x26,#672]
str x9,[x26,#680]
// greenhouse-output-7
ldr x8,[x26,#160]
movz x9,#744
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#46592
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#46592
str x8,[x26,#704]
str x9,[x26,#712]
// greenhouse-monthly-8
ldr x8,[x26,#128]
movz x9,#1024
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#34816
movk x9,#8,lsl #16
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#34816
movk x9,#8,lsl #16
str x8,[x26,#736]
str x9,[x26,#744]
// greenhouse-output-8
ldr x8,[x26,#160]
movz x9,#656
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#46592
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#46592
str x8,[x26,#768]
str x9,[x26,#776]
// aerosol-profile-0
ldr x8,[x26,#64]
movz x9,#37344
movk x9,#24,lsl #16
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#160
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#160
str x8,[x26,#800]
str x9,[x26,#808]
// aerosol-profile-1
ldr x8,[x26,#64]
movz x9,#37408
movk x9,#24,lsl #16
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#160
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#160
str x8,[x26,#832]
str x9,[x26,#840]
// aerosol-profile-2
ldr x8,[x26,#64]
movz x9,#37472
movk x9,#24,lsl #16
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#160
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#160
str x8,[x26,#864]
str x9,[x26,#872]
// aerosol-profile-3
ldr x8,[x26,#64]
movz x9,#37536
movk x9,#24,lsl #16
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#160
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#160
str x8,[x26,#896]
str x9,[x26,#904]
// aerosol-profile-4
ldr x8,[x26,#64]
movz x9,#37600
movk x9,#24,lsl #16
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#160
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#160
str x8,[x26,#928]
str x9,[x26,#936]
// tegen-monthly-0
ldr x8,[x26,#64]
movz x9,#18712
movk x9,#21,lsl #16
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#55808
movk x9,#4,lsl #16
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#55808
movk x9,#4,lsl #16
str x8,[x26,#960]
str x9,[x26,#968]
// tegen-monthly-1
ldr x8,[x26,#64]
movz x9,#18824
movk x9,#21,lsl #16
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#55808
movk x9,#4,lsl #16
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#55808
movk x9,#4,lsl #16
str x8,[x26,#992]
str x9,[x26,#1000]
// tegen-monthly-2
ldr x8,[x26,#64]
movz x9,#18936
movk x9,#21,lsl #16
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#55808
movk x9,#4,lsl #16
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#55808
movk x9,#4,lsl #16
str x8,[x26,#1024]
str x9,[x26,#1032]
// tegen-monthly-3
ldr x8,[x26,#64]
movz x9,#19048
movk x9,#21,lsl #16
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#55808
movk x9,#4,lsl #16
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#55808
movk x9,#4,lsl #16
str x8,[x26,#1056]
str x9,[x26,#1064]
// tegen-monthly-4
ldr x8,[x26,#64]
movz x9,#19160
movk x9,#21,lsl #16
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#55808
movk x9,#4,lsl #16
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#55808
movk x9,#4,lsl #16
str x8,[x26,#1088]
str x9,[x26,#1096]
// volcanic-monthly
ldr x8,[x26,#64]
movz x9,#19272
movk x9,#21,lsl #16
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#54016
movk x9,#8,lsl #16
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#54016
movk x9,#8,lsl #16
str x8,[x26,#1120]
str x9,[x26,#1128]
// volcanic-latitude
ldr x8,[x26,#64]
movz x9,#19384
movk x9,#21,lsl #16
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#192
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#192
str x8,[x26,#1152]
str x9,[x26,#1160]
// macc-monthly-0
ldr x8,[x26,#64]
movz x9,#22240
movk x9,#23,lsl #16
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#47360
movk x9,#10,lsl #16
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#47360
movk x9,#10,lsl #16
str x8,[x26,#1184]
str x9,[x26,#1192]
// macc-output-0
ldr x8,[x26,#64]
movz x9,#22464
movk x9,#23,lsl #16
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#58560
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#58560
str x8,[x26,#1216]
str x9,[x26,#1224]
// macc-monthly-1
ldr x8,[x26,#64]
movz x9,#22352
movk x9,#23,lsl #16
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#47360
movk x9,#10,lsl #16
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#47360
movk x9,#10,lsl #16
str x8,[x26,#1248]
str x9,[x26,#1256]
// macc-output-1
ldr x8,[x26,#64]
movz x9,#22552
movk x9,#23,lsl #16
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#58560
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#58560
str x8,[x26,#1280]
str x9,[x26,#1288]
// macc-monthly-2
ldr x8,[x26,#64]
movz x9,#22640
movk x9,#23,lsl #16
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#47360
movk x9,#10,lsl #16
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#47360
movk x9,#10,lsl #16
str x8,[x26,#1312]
str x9,[x26,#1320]
// macc-output-2
ldr x8,[x26,#64]
movz x9,#22864
movk x9,#23,lsl #16
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#58560
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#58560
str x8,[x26,#1344]
str x9,[x26,#1352]
// macc-monthly-3
ldr x8,[x26,#64]
movz x9,#22752
movk x9,#23,lsl #16
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#47360
movk x9,#10,lsl #16
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#47360
movk x9,#10,lsl #16
str x8,[x26,#1376]
str x9,[x26,#1384]
// macc-output-3
ldr x8,[x26,#64]
movz x9,#22952
movk x9,#23,lsl #16
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#58560
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#58560
str x8,[x26,#1408]
str x9,[x26,#1416]
// macc-monthly-4
ldr x8,[x26,#64]
movz x9,#23040
movk x9,#23,lsl #16
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#47360
movk x9,#10,lsl #16
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#47360
movk x9,#10,lsl #16
str x8,[x26,#1440]
str x9,[x26,#1448]
// macc-output-4
ldr x8,[x26,#64]
movz x9,#23376
movk x9,#23,lsl #16
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#58560
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#58560
str x8,[x26,#1472]
str x9,[x26,#1480]
// macc-monthly-5
ldr x8,[x26,#64]
movz x9,#23152
movk x9,#23,lsl #16
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#47360
movk x9,#10,lsl #16
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#47360
movk x9,#10,lsl #16
str x8,[x26,#1504]
str x9,[x26,#1512]
// macc-output-5
ldr x8,[x26,#64]
movz x9,#23464
movk x9,#23,lsl #16
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#58560
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#58560
str x8,[x26,#1536]
str x9,[x26,#1544]
// macc-monthly-6
ldr x8,[x26,#64]
movz x9,#23264
movk x9,#23,lsl #16
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#47360
movk x9,#10,lsl #16
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#47360
movk x9,#10,lsl #16
str x8,[x26,#1568]
str x9,[x26,#1576]
// macc-output-6
ldr x8,[x26,#64]
movz x9,#23552
movk x9,#23,lsl #16
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#58560
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#58560
str x8,[x26,#1600]
str x9,[x26,#1608]
// macc-monthly-7
ldr x8,[x26,#64]
movz x9,#23640
movk x9,#23,lsl #16
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#47360
movk x9,#10,lsl #16
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#47360
movk x9,#10,lsl #16
str x8,[x26,#1632]
str x9,[x26,#1640]
// macc-output-7
ldr x8,[x26,#64]
movz x9,#23976
movk x9,#23,lsl #16
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#58560
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#58560
str x8,[x26,#1664]
str x9,[x26,#1672]
// macc-monthly-8
ldr x8,[x26,#64]
movz x9,#23752
movk x9,#23,lsl #16
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#47360
movk x9,#10,lsl #16
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#47360
movk x9,#10,lsl #16
str x8,[x26,#1696]
str x9,[x26,#1704]
// macc-output-8
ldr x8,[x26,#64]
movz x9,#24064
movk x9,#23,lsl #16
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#58560
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#58560
str x8,[x26,#1728]
str x9,[x26,#1736]
// macc-monthly-9
ldr x8,[x26,#64]
movz x9,#23864
movk x9,#23,lsl #16
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#47360
movk x9,#10,lsl #16
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#47360
movk x9,#10,lsl #16
str x8,[x26,#1760]
str x9,[x26,#1768]
// macc-output-9
ldr x8,[x26,#64]
movz x9,#24152
movk x9,#23,lsl #16
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#58560
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#58560
str x8,[x26,#1792]
str x9,[x26,#1800]
// macc-monthly-10
ldr x8,[x26,#64]
movz x9,#24240
movk x9,#23,lsl #16
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#47360
movk x9,#10,lsl #16
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#47360
movk x9,#10,lsl #16
str x8,[x26,#1824]
str x9,[x26,#1832]
// macc-output-10
ldr x8,[x26,#64]
movz x9,#24352
movk x9,#23,lsl #16
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#58560
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#58560
str x8,[x26,#1856]
str x9,[x26,#1864]
// forcing-gas-table-0
ldr x8,[x26,#1888]
movz x9,#0
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#20008
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#20008
str x8,[x26,#1920]
str x9,[x26,#1928]
// forcing-gas-table-1
ldr x8,[x26,#1888]
movz x9,#64
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#20008
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#20008
str x8,[x26,#1952]
str x9,[x26,#1960]
// forcing-gas-table-2
ldr x8,[x26,#1888]
movz x9,#128
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#20008
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#20008
str x8,[x26,#1984]
str x9,[x26,#1992]
// forcing-gas-table-3
ldr x8,[x26,#1888]
movz x9,#192
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#20008
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#20008
str x8,[x26,#2016]
str x9,[x26,#2024]
// forcing-gas-table-4
ldr x8,[x26,#1888]
movz x9,#256
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#20008
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#20008
str x8,[x26,#2048]
str x9,[x26,#2056]
// forcing-gas-table-5
ldr x8,[x26,#1888]
movz x9,#320
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#20008
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#20008
str x8,[x26,#2080]
str x9,[x26,#2088]
// forcing-gas-table-6
ldr x8,[x26,#1888]
movz x9,#384
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#20008
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#20008
str x8,[x26,#2112]
str x9,[x26,#2120]
// forcing-gas-table-7
ldr x8,[x26,#1888]
movz x9,#448
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#20008
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#20008
str x8,[x26,#2144]
str x9,[x26,#2152]
// forcing-solar-table-0
ldr x8,[x26,#2176]
movz x9,#0
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#3600
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#3600
str x8,[x26,#2208]
str x9,[x26,#2216]
// forcing-solar-table-1
ldr x8,[x26,#2176]
movz x9,#64
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#3600
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#3600
str x8,[x26,#2240]
str x9,[x26,#2248]
// pressure-boundary-object
ldr x8,[x26,#0]
movz x9,#3240
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#512
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#512
str x8,[x26,#2304]
str x9,[x26,#2312]
// pressure-settings-object
ldr x8,[x26,#0]
movz x9,#3264
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#216
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#216
str x8,[x26,#2336]
str x9,[x26,#2344]
// pressure-coefficient-0
ldr x8,[x26,#2304]
movz x9,#64
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#160
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#160
str x8,[x26,#2368]
str x9,[x26,#2376]
// pressure-coefficient-1
ldr x8,[x26,#2304]
movz x9,#128
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#160
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#160
str x8,[x26,#2400]
str x9,[x26,#2408]
// pressure-coefficient-2
ldr x8,[x26,#2304]
movz x9,#448
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#152
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#152
str x8,[x26,#2432]
str x9,[x26,#2440]
// pressure-coefficient-3
ldr x8,[x26,#2304]
movz x9,#256
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#152
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#152
str x8,[x26,#2464]
str x9,[x26,#2472]
// pressure-coefficient-4
ldr x8,[x26,#2304]
movz x9,#320
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#152
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#152
str x8,[x26,#2496]
str x9,[x26,#2504]
// pressure-coefficient-5
ldr x8,[x26,#2304]
movz x9,#384
ldr x8,[x8,x9]
cbz x8,.Ltime_host_fail
tst x8,#7
b.ne .Ltime_host_fail
movz x9,#152
adds x9,x8,x9
b.cs .Ltime_host_fail
movz x9,#152
str x8,[x26,#2528]
str x9,[x26,#2536]
ldr x10,[x26,#64]
movz x11,#48928
movk x11,#20,lsl #16
ldr x12,[x10,x11]
movz x11,#64870
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#48936
movk x11,#20,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#48944
movk x11,#20,lsl #16
ldr x12,[x10,x11]
movz x11,#0
movk x11,#771,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#48952
movk x11,#20,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#48960
movk x11,#20,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#48968
movk x11,#20,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#48976
movk x11,#20,lsl #16
ldr x12,[x10,x11]
movz x11,#19
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#48984
movk x11,#20,lsl #16
ldr x12,[x10,x11]
movz x11,#19
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#48992
movk x11,#20,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#49000
movk x11,#20,lsl #16
ldr x12,[x10,x11]
movz x11,#34
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#49008
movk x11,#20,lsl #16
ldr x12,[x10,x11]
movz x11,#646
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#49016
movk x11,#20,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#49024
movk x11,#20,lsl #16
ldr x12,[x10,x11]
movz x11,#12
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#160]
movz x11,#72
ldr x12,[x10,x11]
movz x11,#0
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#80
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#88
ldr x12,[x10,x11]
movz x11,#0
movk x11,#769,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#96
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#104
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#112
ldr x12,[x10,x11]
movz x11,#0
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#120
ldr x12,[x10,x11]
movz x11,#91
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#128]
movz x11,#136
ldr x12,[x10,x11]
movz x11,#59647
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#144
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#152
ldr x12,[x10,x11]
movz x11,#0
movk x11,#771,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#160
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#168
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#176
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#184
ldr x12,[x10,x11]
movz x11,#64
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#192
ldr x12,[x10,x11]
movz x11,#64
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#200
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#208
ldr x12,[x10,x11]
movz x11,#91
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#216
ldr x12,[x10,x11]
movz x11,#5824
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#224
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#232
ldr x12,[x10,x11]
movz x11,#12
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#160]
movz x11,#224
ldr x12,[x10,x11]
movz x11,#65471
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#232
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#240
ldr x12,[x10,x11]
movz x11,#0
movk x11,#770,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#248
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#256
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#264
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#272
ldr x12,[x10,x11]
movz x11,#64
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#280
ldr x12,[x10,x11]
movz x11,#64
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#288
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#296
ldr x12,[x10,x11]
movz x11,#91
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#128]
movz x11,#248
ldr x12,[x10,x11]
movz x11,#59647
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#256
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#264
ldr x12,[x10,x11]
movz x11,#0
movk x11,#771,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#272
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#280
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#288
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#296
ldr x12,[x10,x11]
movz x11,#64
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#304
ldr x12,[x10,x11]
movz x11,#64
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#312
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#320
ldr x12,[x10,x11]
movz x11,#91
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#328
ldr x12,[x10,x11]
movz x11,#5824
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#336
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#344
ldr x12,[x10,x11]
movz x11,#12
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#160]
movz x11,#136
ldr x12,[x10,x11]
movz x11,#65471
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#144
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#152
ldr x12,[x10,x11]
movz x11,#0
movk x11,#770,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#160
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#168
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#176
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#184
ldr x12,[x10,x11]
movz x11,#64
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#192
ldr x12,[x10,x11]
movz x11,#64
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#200
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#208
ldr x12,[x10,x11]
movz x11,#91
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#128]
movz x11,#360
ldr x12,[x10,x11]
movz x11,#59647
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#368
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#376
ldr x12,[x10,x11]
movz x11,#0
movk x11,#771,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#384
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#392
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#400
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#408
ldr x12,[x10,x11]
movz x11,#64
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#416
ldr x12,[x10,x11]
movz x11,#64
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#424
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#432
ldr x12,[x10,x11]
movz x11,#91
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#440
ldr x12,[x10,x11]
movz x11,#5824
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#448
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#456
ldr x12,[x10,x11]
movz x11,#12
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#160]
movz x11,#312
ldr x12,[x10,x11]
movz x11,#65471
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#320
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#328
ldr x12,[x10,x11]
movz x11,#0
movk x11,#770,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#336
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#344
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#352
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#360
ldr x12,[x10,x11]
movz x11,#64
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#368
ldr x12,[x10,x11]
movz x11,#64
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#376
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#384
ldr x12,[x10,x11]
movz x11,#91
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#128]
movz x11,#472
ldr x12,[x10,x11]
movz x11,#59647
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#480
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#488
ldr x12,[x10,x11]
movz x11,#0
movk x11,#771,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#496
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#504
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#512
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#520
ldr x12,[x10,x11]
movz x11,#64
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#528
ldr x12,[x10,x11]
movz x11,#64
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#536
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#544
ldr x12,[x10,x11]
movz x11,#91
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#552
ldr x12,[x10,x11]
movz x11,#5824
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#560
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#568
ldr x12,[x10,x11]
movz x11,#12
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#160]
movz x11,#400
ldr x12,[x10,x11]
movz x11,#65471
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#408
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#416
ldr x12,[x10,x11]
movz x11,#0
movk x11,#770,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#424
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#432
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#440
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#448
ldr x12,[x10,x11]
movz x11,#64
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#456
ldr x12,[x10,x11]
movz x11,#64
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#464
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#472
ldr x12,[x10,x11]
movz x11,#91
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#128]
movz x11,#584
ldr x12,[x10,x11]
movz x11,#59647
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#592
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#600
ldr x12,[x10,x11]
movz x11,#0
movk x11,#771,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#608
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#616
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#624
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#632
ldr x12,[x10,x11]
movz x11,#64
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#640
ldr x12,[x10,x11]
movz x11,#64
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#648
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#656
ldr x12,[x10,x11]
movz x11,#91
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#664
ldr x12,[x10,x11]
movz x11,#5824
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#672
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#680
ldr x12,[x10,x11]
movz x11,#12
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#160]
movz x11,#488
ldr x12,[x10,x11]
movz x11,#65471
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#496
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#504
ldr x12,[x10,x11]
movz x11,#0
movk x11,#770,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#512
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#520
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#528
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#536
ldr x12,[x10,x11]
movz x11,#64
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#544
ldr x12,[x10,x11]
movz x11,#64
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#552
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#560
ldr x12,[x10,x11]
movz x11,#91
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#128]
movz x11,#696
ldr x12,[x10,x11]
movz x11,#59647
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#704
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#712
ldr x12,[x10,x11]
movz x11,#0
movk x11,#771,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#720
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#728
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#736
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#744
ldr x12,[x10,x11]
movz x11,#64
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#752
ldr x12,[x10,x11]
movz x11,#64
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#760
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#768
ldr x12,[x10,x11]
movz x11,#91
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#776
ldr x12,[x10,x11]
movz x11,#5824
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#784
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#792
ldr x12,[x10,x11]
movz x11,#12
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#160]
movz x11,#576
ldr x12,[x10,x11]
movz x11,#65471
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#584
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#592
ldr x12,[x10,x11]
movz x11,#0
movk x11,#770,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#600
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#608
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#616
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#624
ldr x12,[x10,x11]
movz x11,#64
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#632
ldr x12,[x10,x11]
movz x11,#64
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#640
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#648
ldr x12,[x10,x11]
movz x11,#91
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#128]
movz x11,#808
ldr x12,[x10,x11]
movz x11,#59647
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#816
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#824
ldr x12,[x10,x11]
movz x11,#0
movk x11,#771,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#832
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#840
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#848
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#856
ldr x12,[x10,x11]
movz x11,#64
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#864
ldr x12,[x10,x11]
movz x11,#64
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#872
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#880
ldr x12,[x10,x11]
movz x11,#91
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#888
ldr x12,[x10,x11]
movz x11,#5824
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#896
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#904
ldr x12,[x10,x11]
movz x11,#12
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#160]
movz x11,#840
ldr x12,[x10,x11]
movz x11,#65471
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#848
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#856
ldr x12,[x10,x11]
movz x11,#0
movk x11,#770,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#864
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#872
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#880
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#888
ldr x12,[x10,x11]
movz x11,#64
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#896
ldr x12,[x10,x11]
movz x11,#64
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#904
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#912
ldr x12,[x10,x11]
movz x11,#91
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#128]
movz x11,#920
ldr x12,[x10,x11]
movz x11,#59647
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#928
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#936
ldr x12,[x10,x11]
movz x11,#0
movk x11,#771,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#944
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#952
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#960
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#968
ldr x12,[x10,x11]
movz x11,#64
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#976
ldr x12,[x10,x11]
movz x11,#64
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#984
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#992
ldr x12,[x10,x11]
movz x11,#91
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#1000
ldr x12,[x10,x11]
movz x11,#5824
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#1008
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#1016
ldr x12,[x10,x11]
movz x11,#12
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#160]
movz x11,#752
ldr x12,[x10,x11]
movz x11,#65471
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#760
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#768
ldr x12,[x10,x11]
movz x11,#0
movk x11,#770,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#776
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#784
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#792
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#800
ldr x12,[x10,x11]
movz x11,#64
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#808
ldr x12,[x10,x11]
movz x11,#64
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#816
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#824
ldr x12,[x10,x11]
movz x11,#91
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#128]
movz x11,#1032
ldr x12,[x10,x11]
movz x11,#59647
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#1040
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#1048
ldr x12,[x10,x11]
movz x11,#0
movk x11,#771,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#1056
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#1064
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#1072
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#1080
ldr x12,[x10,x11]
movz x11,#64
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#1088
ldr x12,[x10,x11]
movz x11,#64
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#1096
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#1104
ldr x12,[x10,x11]
movz x11,#91
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#1112
ldr x12,[x10,x11]
movz x11,#5824
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#1120
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#1128
ldr x12,[x10,x11]
movz x11,#12
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#160]
movz x11,#664
ldr x12,[x10,x11]
movz x11,#65471
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#672
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#680
ldr x12,[x10,x11]
movz x11,#0
movk x11,#770,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#688
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#696
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#704
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#712
ldr x12,[x10,x11]
movz x11,#64
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#720
ldr x12,[x10,x11]
movz x11,#64
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#728
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#736
ldr x12,[x10,x11]
movz x11,#91
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#64]
movz x11,#37352
movk x11,#24,lsl #16
ldr x12,[x10,x11]
movz x11,#65535
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#37360
movk x11,#24,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#37368
movk x11,#24,lsl #16
ldr x12,[x10,x11]
movz x11,#0
movk x11,#769,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#37376
movk x11,#24,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#37384
movk x11,#24,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#37392
movk x11,#24,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#37400
movk x11,#24,lsl #16
ldr x12,[x10,x11]
movz x11,#20
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#64]
movz x11,#37416
movk x11,#24,lsl #16
ldr x12,[x10,x11]
movz x11,#65535
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#37424
movk x11,#24,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#37432
movk x11,#24,lsl #16
ldr x12,[x10,x11]
movz x11,#0
movk x11,#769,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#37440
movk x11,#24,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#37448
movk x11,#24,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#37456
movk x11,#24,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#37464
movk x11,#24,lsl #16
ldr x12,[x10,x11]
movz x11,#20
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#64]
movz x11,#37480
movk x11,#24,lsl #16
ldr x12,[x10,x11]
movz x11,#65535
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#37488
movk x11,#24,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#37496
movk x11,#24,lsl #16
ldr x12,[x10,x11]
movz x11,#0
movk x11,#769,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#37504
movk x11,#24,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#37512
movk x11,#24,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#37520
movk x11,#24,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#37528
movk x11,#24,lsl #16
ldr x12,[x10,x11]
movz x11,#20
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#64]
movz x11,#37544
movk x11,#24,lsl #16
ldr x12,[x10,x11]
movz x11,#65535
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#37552
movk x11,#24,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#37560
movk x11,#24,lsl #16
ldr x12,[x10,x11]
movz x11,#0
movk x11,#769,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#37568
movk x11,#24,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#37576
movk x11,#24,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#37584
movk x11,#24,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#37592
movk x11,#24,lsl #16
ldr x12,[x10,x11]
movz x11,#20
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#64]
movz x11,#37608
movk x11,#24,lsl #16
ldr x12,[x10,x11]
movz x11,#65535
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#37616
movk x11,#24,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#37624
movk x11,#24,lsl #16
ldr x12,[x10,x11]
movz x11,#0
movk x11,#769,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#37632
movk x11,#24,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#37640
movk x11,#24,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#37648
movk x11,#24,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#37656
movk x11,#24,lsl #16
ldr x12,[x10,x11]
movz x11,#20
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#64]
movz x11,#18720
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#62151
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#18728
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#18736
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#0
movk x11,#771,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#18744
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#18752
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#18760
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#18768
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#72
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#18776
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#72
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#18784
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#18792
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#46
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#18800
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#3312
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#18808
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#18816
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#12
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#64]
movz x11,#18832
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#62151
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#18840
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#18848
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#0
movk x11,#771,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#18856
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#18864
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#18872
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#18880
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#72
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#18888
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#72
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#18896
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#18904
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#46
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#18912
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#3312
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#18920
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#18928
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#12
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#64]
movz x11,#18944
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#62151
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#18952
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#18960
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#0
movk x11,#771,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#18968
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#18976
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#18984
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#18992
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#72
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#19000
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#72
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#19008
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#19016
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#46
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#19024
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#3312
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#19032
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#19040
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#12
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#64]
movz x11,#19056
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#62151
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#19064
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#19072
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#0
movk x11,#771,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#19080
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#19088
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#19096
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#19104
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#72
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#19112
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#72
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#19120
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#19128
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#46
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#19136
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#3312
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#19144
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#19152
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#12
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#64]
movz x11,#19168
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#62151
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#19176
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#19184
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#0
movk x11,#771,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#19192
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#19200
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#19208
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#19216
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#72
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#19224
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#72
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#19232
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#19240
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#46
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#19248
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#3312
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#19256
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#19264
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#12
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#64]
movz x11,#19280
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#15111
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#19288
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#19296
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#0
movk x11,#771,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#19304
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#19312
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#19320
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#19328
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#24
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#19336
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#24
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#19344
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#1850
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#19352
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#2100
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#19360
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#6024
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#19368
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#19376
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#12
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#64]
movz x11,#19392
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#65535
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#19400
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#19408
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#0
movk x11,#769,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#19416
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#19424
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#19432
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#19440
movk x11,#21,lsl #16
ldr x12,[x10,x11]
movz x11,#24
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#64]
movz x11,#22248
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#58095
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22256
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22264
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#0
movk x11,#771,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22272
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22280
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22288
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22296
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#120
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22304
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#120
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22312
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22320
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#61
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22328
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#7320
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22336
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22344
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#12
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#64]
movz x11,#22472
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#65415
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22480
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22488
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#0
movk x11,#770,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22496
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22504
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22512
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22520
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#120
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22528
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#120
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22536
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22544
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#61
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#64]
movz x11,#22360
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#58095
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22368
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22376
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#0
movk x11,#771,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22384
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22392
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22400
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22408
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#120
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22416
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#120
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22424
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22432
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#61
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22440
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#7320
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22448
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22456
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#12
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#64]
movz x11,#22560
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#65415
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22568
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22576
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#0
movk x11,#770,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22584
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22592
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22600
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22608
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#120
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22616
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#120
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22624
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22632
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#61
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#64]
movz x11,#22648
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#58095
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22656
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22664
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#0
movk x11,#771,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22672
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22680
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22688
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22696
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#120
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22704
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#120
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22712
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22720
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#61
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22728
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#7320
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22736
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22744
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#12
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#64]
movz x11,#22872
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#65415
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22880
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22888
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#0
movk x11,#770,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22896
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22904
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22912
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22920
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#120
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22928
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#120
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22936
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22944
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#61
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#64]
movz x11,#22760
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#58095
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22768
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22776
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#0
movk x11,#771,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22784
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22792
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22800
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22808
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#120
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22816
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#120
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22824
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22832
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#61
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22840
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#7320
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22848
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22856
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#12
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#64]
movz x11,#22960
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#65415
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22968
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22976
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#0
movk x11,#770,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22984
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#22992
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23000
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23008
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#120
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23016
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#120
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23024
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23032
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#61
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#64]
movz x11,#23048
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#58095
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23056
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23064
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#0
movk x11,#771,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23072
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23080
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23088
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23096
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#120
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23104
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#120
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23112
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23120
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#61
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23128
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#7320
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23136
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23144
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#12
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#64]
movz x11,#23384
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#65415
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23392
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23400
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#0
movk x11,#770,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23408
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23416
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23424
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23432
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#120
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23440
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#120
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23448
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23456
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#61
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#64]
movz x11,#23160
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#58095
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23168
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23176
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#0
movk x11,#771,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23184
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23192
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23200
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23208
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#120
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23216
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#120
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23224
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23232
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#61
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23240
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#7320
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23248
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23256
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#12
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#64]
movz x11,#23472
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#65415
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23480
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23488
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#0
movk x11,#770,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23496
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23504
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23512
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23520
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#120
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23528
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#120
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23536
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23544
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#61
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#64]
movz x11,#23272
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#58095
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23280
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23288
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#0
movk x11,#771,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23296
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23304
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23312
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23320
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#120
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23328
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#120
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23336
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23344
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#61
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23352
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#7320
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23360
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23368
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#12
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#64]
movz x11,#23560
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#65415
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23568
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23576
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#0
movk x11,#770,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23584
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23592
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23600
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23608
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#120
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23616
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#120
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23624
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23632
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#61
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#64]
movz x11,#23648
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#58095
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23656
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23664
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#0
movk x11,#771,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23672
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23680
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23688
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23696
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#120
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23704
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#120
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23712
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23720
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#61
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23728
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#7320
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23736
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23744
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#12
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#64]
movz x11,#23984
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#65415
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23992
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#24000
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#0
movk x11,#770,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#24008
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#24016
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#24024
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#24032
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#120
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#24040
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#120
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#24048
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#24056
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#61
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#64]
movz x11,#23760
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#58095
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23768
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23776
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#0
movk x11,#771,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23784
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23792
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23800
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23808
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#120
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23816
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#120
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23824
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23832
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#61
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23840
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#7320
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23848
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23856
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#12
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#64]
movz x11,#24072
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#65415
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#24080
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#24088
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#0
movk x11,#770,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#24096
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#24104
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#24112
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#24120
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#120
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#24128
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#120
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#24136
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#24144
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#61
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#64]
movz x11,#23872
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#58095
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23880
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23888
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#0
movk x11,#771,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23896
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23904
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23912
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23920
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#120
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23928
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#120
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23936
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23944
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#61
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23952
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#7320
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23960
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#23968
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#12
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#64]
movz x11,#24160
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#65415
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#24168
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#24176
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#0
movk x11,#770,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#24184
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#24192
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#24200
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#24208
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#120
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#24216
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#120
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#24224
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#24232
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#61
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#64]
movz x11,#24248
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#58095
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#24256
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#24264
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#0
movk x11,#771,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#24272
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#24280
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#24288
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#24296
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#120
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#24304
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#120
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#24312
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#24320
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#61
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#24328
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#7320
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#24336
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#24344
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#12
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#64]
movz x11,#24360
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#65415
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#24368
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#24376
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#0
movk x11,#770,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#24384
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#24392
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#24400
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#24408
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#120
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#24416
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#120
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#24424
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#24432
movk x11,#23,lsl #16
ldr x12,[x10,x11]
movz x11,#61
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#1888]
movz x11,#8
ldr x12,[x10,x11]
movz x11,#65535
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#24
ldr x12,[x10,x11]
movz x11,#0
movk x11,#769,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#32
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#40
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#48
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#56
ldr x12,[x10,x11]
movz x11,#2501
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#1888]
movz x11,#72
ldr x12,[x10,x11]
movz x11,#65535
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#80
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#88
ldr x12,[x10,x11]
movz x11,#0
movk x11,#769,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#96
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#104
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#112
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#120
ldr x12,[x10,x11]
movz x11,#2501
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#1888]
movz x11,#136
ldr x12,[x10,x11]
movz x11,#65535
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#144
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#152
ldr x12,[x10,x11]
movz x11,#0
movk x11,#769,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#160
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#168
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#176
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#184
ldr x12,[x10,x11]
movz x11,#2501
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#1888]
movz x11,#200
ldr x12,[x10,x11]
movz x11,#65535
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#208
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#216
ldr x12,[x10,x11]
movz x11,#0
movk x11,#769,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#224
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#232
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#240
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#248
ldr x12,[x10,x11]
movz x11,#2501
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#1888]
movz x11,#264
ldr x12,[x10,x11]
movz x11,#65535
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#272
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#280
ldr x12,[x10,x11]
movz x11,#0
movk x11,#769,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#288
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#296
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#304
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#312
ldr x12,[x10,x11]
movz x11,#2501
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#1888]
movz x11,#328
ldr x12,[x10,x11]
movz x11,#65535
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#336
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#344
ldr x12,[x10,x11]
movz x11,#0
movk x11,#769,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#352
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#360
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#368
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#376
ldr x12,[x10,x11]
movz x11,#2501
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#1888]
movz x11,#392
ldr x12,[x10,x11]
movz x11,#65535
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#400
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#408
ldr x12,[x10,x11]
movz x11,#0
movk x11,#769,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#416
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#424
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#432
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#440
ldr x12,[x10,x11]
movz x11,#2501
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#1888]
movz x11,#456
ldr x12,[x10,x11]
movz x11,#65535
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#464
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#472
ldr x12,[x10,x11]
movz x11,#0
movk x11,#769,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#480
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#488
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#496
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#504
ldr x12,[x10,x11]
movz x11,#2501
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#2176]
movz x11,#8
ldr x12,[x10,x11]
movz x11,#65535
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#16
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#24
ldr x12,[x10,x11]
movz x11,#0
movk x11,#769,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#32
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#40
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#48
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#56
ldr x12,[x10,x11]
movz x11,#450
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#2176]
movz x11,#72
ldr x12,[x10,x11]
movz x11,#65535
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#80
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#88
ldr x12,[x10,x11]
movz x11,#0
movk x11,#769,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#96
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#104
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#112
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#120
ldr x12,[x10,x11]
movz x11,#450
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#2304]
movz x11,#72
ldr x12,[x10,x11]
movz x11,#0
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#80
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#88
ldr x12,[x10,x11]
movz x11,#0
movk x11,#769,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#96
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#104
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#112
ldr x12,[x10,x11]
movz x11,#0
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#120
ldr x12,[x10,x11]
movz x11,#19
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#2304]
movz x11,#136
ldr x12,[x10,x11]
movz x11,#0
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#144
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#152
ldr x12,[x10,x11]
movz x11,#0
movk x11,#769,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#160
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#168
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#176
ldr x12,[x10,x11]
movz x11,#0
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#184
ldr x12,[x10,x11]
movz x11,#19
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#2304]
movz x11,#456
ldr x12,[x10,x11]
movz x11,#65535
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#464
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#472
ldr x12,[x10,x11]
movz x11,#0
movk x11,#769,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#480
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#488
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#496
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#504
ldr x12,[x10,x11]
movz x11,#19
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#2304]
movz x11,#264
ldr x12,[x10,x11]
movz x11,#65535
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#272
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#280
ldr x12,[x10,x11]
movz x11,#0
movk x11,#769,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#288
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#296
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#304
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#312
ldr x12,[x10,x11]
movz x11,#19
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#2304]
movz x11,#328
ldr x12,[x10,x11]
movz x11,#65535
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#336
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#344
ldr x12,[x10,x11]
movz x11,#0
movk x11,#769,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#352
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#360
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#368
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#376
ldr x12,[x10,x11]
movz x11,#19
cmp x12,x11
b.ne .Ltime_host_fail
ldr x10,[x26,#2304]
movz x11,#392
ldr x12,[x10,x11]
movz x11,#65535
movk x11,#65535,lsl #16
movk x11,#65535,lsl #32
movk x11,#65535,lsl #48
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#400
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#408
ldr x12,[x10,x11]
movz x11,#0
movk x11,#769,lsl #32
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#416
ldr x12,[x10,x11]
movz x11,#8
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#424
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#432
ldr x12,[x10,x11]
movz x11,#1
cmp x12,x11
b.ne .Ltime_host_fail
movz x11,#440
ldr x12,[x10,x11]
movz x11,#19
cmp x12,x11
b.ne .Ltime_host_fail
mov x23,#0
.Ltime_host_original_outer:
cmp x23,#80
b.hs .Ltime_host_original_done
add x8,x26,x23,lsl #5
ldp x10,x11,[x8]
add x12,x10,x11
add x24,x23,#1
.Ltime_host_original_inner:
cmp x24,#80
b.hs .Ltime_host_original_next
add x8,x26,x24,lsl #5
ldp x13,x14,[x8]
add x15,x13,x14
cmp x10,x15
b.hs .Ltime_host_original_pair_ok
cmp x13,x12
b.lo .Ltime_host_fail
.Ltime_host_original_pair_ok:
add x24,x24,#1
b .Ltime_host_original_inner
.Ltime_host_original_next:
add x23,x23,#1
b .Ltime_host_original_outer
.Ltime_host_original_done:
movz x0,#28240
movk x0,#361,lsl #16
time_host_call malloc
cbz x0,.Ltime_host_fail
mov x25,x0
add x8,sp,#2,lsl #12
add x9,sp,#5,lsl #12
.Ltime_host_zero_metadata:
stp xzr,xzr,[x8],#16
cmp x8,x9
b.lo .Ltime_host_zero_metadata
mov x27,#0
add x21,sp,#4,lsl #12
add x21,x21,#1024
movz x8,#0
add x8,x25,x8
movz x9,#0
stp x8,x9,[x26,#16]
mov x0,x8
movz x1,#17096
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#16]
ldr x1,[x26,#0]
movz x2,#17096
time_host_call memcpy
movz x8,#17104
add x8,x25,x8
movz x9,#0
stp x8,x9,[x26,#48]
mov x0,x8
movz x1,#18224
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#48]
ldr x1,[x26,#32]
movz x2,#18224
time_host_call memcpy
movz x8,#35328
add x8,x25,x8
movz x9,#1
stp x8,x9,[x26,#80]
mov x0,x8
movz x1,#15248
movk x1,#65,lsl #16
mov x2,#1
bl .Ltime_host_append_row
ldr x0,[x26,#80]
ldr x1,[x26,#64]
movz x2,#15248
movk x2,#65,lsl #16
time_host_call memcpy
movz x8,#50576
movk x8,#65,lsl #16
add x8,x25,x8
movz x9,#0
stp x8,x9,[x26,#112]
mov x0,x8
movz x1,#62016
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#112]
ldr x1,[x26,#96]
movz x2,#62016
time_host_call memcpy
movz x8,#47056
movk x8,#66,lsl #16
add x8,x25,x8
movz x9,#0
stp x8,x9,[x26,#144]
mov x0,x8
movz x1,#1208
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#144]
ldr x1,[x26,#128]
movz x2,#1208
time_host_call memcpy
movz x8,#48272
movk x8,#66,lsl #16
add x8,x25,x8
movz x9,#1
stp x8,x9,[x26,#176]
mov x0,x8
movz x1,#928
mov x2,#1
bl .Ltime_host_append_row
ldr x0,[x26,#176]
ldr x1,[x26,#160]
movz x2,#928
time_host_call memcpy
movz x8,#49200
movk x8,#66,lsl #16
add x8,x25,x8
movz x9,#0
stp x8,x9,[x26,#208]
mov x0,x8
movz x1,#736
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#208]
ldr x1,[x26,#192]
movz x2,#736
time_host_call memcpy
movz x8,#49936
movk x8,#66,lsl #16
add x8,x25,x8
movz x9,#0
stp x8,x9,[x26,#240]
mov x0,x8
movz x1,#34816
movk x1,#8,lsl #16
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#240]
ldr x1,[x26,#224]
movz x2,#34816
movk x2,#8,lsl #16
time_host_call memcpy
movz x8,#19216
movk x8,#75,lsl #16
add x8,x25,x8
movz x9,#1
stp x8,x9,[x26,#272]
mov x0,x8
movz x1,#46592
mov x2,#1
bl .Ltime_host_append_row
ldr x0,[x26,#272]
ldr x1,[x26,#256]
movz x2,#46592
time_host_call memcpy
movz x8,#272
movk x8,#76,lsl #16
add x8,x25,x8
movz x9,#0
stp x8,x9,[x26,#304]
mov x0,x8
movz x1,#34816
movk x1,#8,lsl #16
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#304]
ldr x1,[x26,#288]
movz x2,#34816
movk x2,#8,lsl #16
time_host_call memcpy
movz x8,#35088
movk x8,#84,lsl #16
add x8,x25,x8
movz x9,#1
stp x8,x9,[x26,#336]
mov x0,x8
movz x1,#46592
mov x2,#1
bl .Ltime_host_append_row
ldr x0,[x26,#336]
ldr x1,[x26,#320]
movz x2,#46592
time_host_call memcpy
movz x8,#16144
movk x8,#85,lsl #16
add x8,x25,x8
movz x9,#0
stp x8,x9,[x26,#368]
mov x0,x8
movz x1,#34816
movk x1,#8,lsl #16
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#368]
ldr x1,[x26,#352]
movz x2,#34816
movk x2,#8,lsl #16
time_host_call memcpy
movz x8,#50960
movk x8,#93,lsl #16
add x8,x25,x8
movz x9,#1
stp x8,x9,[x26,#400]
mov x0,x8
movz x1,#46592
mov x2,#1
bl .Ltime_host_append_row
ldr x0,[x26,#400]
ldr x1,[x26,#384]
movz x2,#46592
time_host_call memcpy
movz x8,#32016
movk x8,#94,lsl #16
add x8,x25,x8
movz x9,#0
stp x8,x9,[x26,#432]
mov x0,x8
movz x1,#34816
movk x1,#8,lsl #16
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#432]
ldr x1,[x26,#416]
movz x2,#34816
movk x2,#8,lsl #16
time_host_call memcpy
movz x8,#1296
movk x8,#103,lsl #16
add x8,x25,x8
movz x9,#1
stp x8,x9,[x26,#464]
mov x0,x8
movz x1,#46592
mov x2,#1
bl .Ltime_host_append_row
ldr x0,[x26,#464]
ldr x1,[x26,#448]
movz x2,#46592
time_host_call memcpy
movz x8,#47888
movk x8,#103,lsl #16
add x8,x25,x8
movz x9,#0
stp x8,x9,[x26,#496]
mov x0,x8
movz x1,#34816
movk x1,#8,lsl #16
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#496]
ldr x1,[x26,#480]
movz x2,#34816
movk x2,#8,lsl #16
time_host_call memcpy
movz x8,#17168
movk x8,#112,lsl #16
add x8,x25,x8
movz x9,#1
str x8,[x26,#528]
str x9,[x26,#536]
mov x0,x8
movz x1,#46592
mov x2,#1
bl .Ltime_host_append_row
ldr x0,[x26,#528]
ldr x1,[x26,#512]
movz x2,#46592
time_host_call memcpy
movz x8,#63760
movk x8,#112,lsl #16
add x8,x25,x8
movz x9,#0
str x8,[x26,#560]
str x9,[x26,#568]
mov x0,x8
movz x1,#34816
movk x1,#8,lsl #16
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#560]
ldr x1,[x26,#544]
movz x2,#34816
movk x2,#8,lsl #16
time_host_call memcpy
movz x8,#33040
movk x8,#121,lsl #16
add x8,x25,x8
movz x9,#1
str x8,[x26,#592]
str x9,[x26,#600]
mov x0,x8
movz x1,#46592
mov x2,#1
bl .Ltime_host_append_row
ldr x0,[x26,#592]
ldr x1,[x26,#576]
movz x2,#46592
time_host_call memcpy
movz x8,#14096
movk x8,#122,lsl #16
add x8,x25,x8
movz x9,#0
str x8,[x26,#624]
str x9,[x26,#632]
mov x0,x8
movz x1,#34816
movk x1,#8,lsl #16
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#624]
ldr x1,[x26,#608]
movz x2,#34816
movk x2,#8,lsl #16
time_host_call memcpy
movz x8,#48912
movk x8,#130,lsl #16
add x8,x25,x8
movz x9,#1
str x8,[x26,#656]
str x9,[x26,#664]
mov x0,x8
movz x1,#46592
mov x2,#1
bl .Ltime_host_append_row
ldr x0,[x26,#656]
ldr x1,[x26,#640]
movz x2,#46592
time_host_call memcpy
movz x8,#29968
movk x8,#131,lsl #16
add x8,x25,x8
movz x9,#0
str x8,[x26,#688]
str x9,[x26,#696]
mov x0,x8
movz x1,#34816
movk x1,#8,lsl #16
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#688]
ldr x1,[x26,#672]
movz x2,#34816
movk x2,#8,lsl #16
time_host_call memcpy
movz x8,#64784
movk x8,#139,lsl #16
add x8,x25,x8
movz x9,#1
str x8,[x26,#720]
str x9,[x26,#728]
mov x0,x8
movz x1,#46592
mov x2,#1
bl .Ltime_host_append_row
ldr x0,[x26,#720]
ldr x1,[x26,#704]
movz x2,#46592
time_host_call memcpy
movz x8,#45840
movk x8,#140,lsl #16
add x8,x25,x8
movz x9,#0
str x8,[x26,#752]
str x9,[x26,#760]
mov x0,x8
movz x1,#34816
movk x1,#8,lsl #16
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#752]
ldr x1,[x26,#736]
movz x2,#34816
movk x2,#8,lsl #16
time_host_call memcpy
movz x8,#15120
movk x8,#149,lsl #16
add x8,x25,x8
movz x9,#1
str x8,[x26,#784]
str x9,[x26,#792]
mov x0,x8
movz x1,#46592
mov x2,#1
bl .Ltime_host_append_row
ldr x0,[x26,#784]
ldr x1,[x26,#768]
movz x2,#46592
time_host_call memcpy
movz x8,#61712
movk x8,#149,lsl #16
add x8,x25,x8
movz x9,#1
str x8,[x26,#816]
str x9,[x26,#824]
mov x0,x8
movz x1,#160
mov x2,#1
bl .Ltime_host_append_row
ldr x0,[x26,#816]
ldr x1,[x26,#800]
movz x2,#160
time_host_call memcpy
movz x8,#61872
movk x8,#149,lsl #16
add x8,x25,x8
movz x9,#1
str x8,[x26,#848]
str x9,[x26,#856]
mov x0,x8
movz x1,#160
mov x2,#1
bl .Ltime_host_append_row
ldr x0,[x26,#848]
ldr x1,[x26,#832]
movz x2,#160
time_host_call memcpy
movz x8,#62032
movk x8,#149,lsl #16
add x8,x25,x8
movz x9,#1
str x8,[x26,#880]
str x9,[x26,#888]
mov x0,x8
movz x1,#160
mov x2,#1
bl .Ltime_host_append_row
ldr x0,[x26,#880]
ldr x1,[x26,#864]
movz x2,#160
time_host_call memcpy
movz x8,#62192
movk x8,#149,lsl #16
add x8,x25,x8
movz x9,#1
str x8,[x26,#912]
str x9,[x26,#920]
mov x0,x8
movz x1,#160
mov x2,#1
bl .Ltime_host_append_row
ldr x0,[x26,#912]
ldr x1,[x26,#896]
movz x2,#160
time_host_call memcpy
movz x8,#62352
movk x8,#149,lsl #16
add x8,x25,x8
movz x9,#1
str x8,[x26,#944]
str x9,[x26,#952]
mov x0,x8
movz x1,#160
mov x2,#1
bl .Ltime_host_append_row
ldr x0,[x26,#944]
ldr x1,[x26,#928]
movz x2,#160
time_host_call memcpy
movz x8,#62512
movk x8,#149,lsl #16
add x8,x25,x8
movz x9,#0
str x8,[x26,#976]
str x9,[x26,#984]
mov x0,x8
movz x1,#55808
movk x1,#4,lsl #16
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#976]
ldr x1,[x26,#960]
movz x2,#55808
movk x2,#4,lsl #16
time_host_call memcpy
movz x8,#52784
movk x8,#154,lsl #16
add x8,x25,x8
movz x9,#0
str x8,[x26,#1008]
str x9,[x26,#1016]
mov x0,x8
movz x1,#55808
movk x1,#4,lsl #16
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#1008]
ldr x1,[x26,#992]
movz x2,#55808
movk x2,#4,lsl #16
time_host_call memcpy
movz x8,#43056
movk x8,#159,lsl #16
add x8,x25,x8
movz x9,#0
str x8,[x26,#1040]
str x9,[x26,#1048]
mov x0,x8
movz x1,#55808
movk x1,#4,lsl #16
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#1040]
ldr x1,[x26,#1024]
movz x2,#55808
movk x2,#4,lsl #16
time_host_call memcpy
movz x8,#33328
movk x8,#164,lsl #16
add x8,x25,x8
movz x9,#0
str x8,[x26,#1072]
str x9,[x26,#1080]
mov x0,x8
movz x1,#55808
movk x1,#4,lsl #16
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#1072]
ldr x1,[x26,#1056]
movz x2,#55808
movk x2,#4,lsl #16
time_host_call memcpy
movz x8,#23600
movk x8,#169,lsl #16
add x8,x25,x8
movz x9,#0
str x8,[x26,#1104]
str x9,[x26,#1112]
mov x0,x8
movz x1,#55808
movk x1,#4,lsl #16
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#1104]
ldr x1,[x26,#1088]
movz x2,#55808
movk x2,#4,lsl #16
time_host_call memcpy
movz x8,#13872
movk x8,#174,lsl #16
add x8,x25,x8
movz x9,#0
str x8,[x26,#1136]
str x9,[x26,#1144]
mov x0,x8
movz x1,#54016
movk x1,#8,lsl #16
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#1136]
ldr x1,[x26,#1120]
movz x2,#54016
movk x2,#8,lsl #16
time_host_call memcpy
movz x8,#2352
movk x8,#183,lsl #16
add x8,x25,x8
movz x9,#0
str x8,[x26,#1168]
str x9,[x26,#1176]
mov x0,x8
movz x1,#192
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#1168]
ldr x1,[x26,#1152]
movz x2,#192
time_host_call memcpy
movz x8,#2544
movk x8,#183,lsl #16
add x8,x25,x8
movz x9,#0
str x8,[x26,#1200]
str x9,[x26,#1208]
mov x0,x8
movz x1,#47360
movk x1,#10,lsl #16
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#1200]
ldr x1,[x26,#1184]
movz x2,#47360
movk x2,#10,lsl #16
time_host_call memcpy
movz x8,#49904
movk x8,#193,lsl #16
add x8,x25,x8
movz x9,#1
str x8,[x26,#1232]
str x9,[x26,#1240]
mov x0,x8
movz x1,#58560
mov x2,#1
bl .Ltime_host_append_row
ldr x0,[x26,#1232]
ldr x1,[x26,#1216]
movz x2,#58560
time_host_call memcpy
movz x8,#42928
movk x8,#194,lsl #16
add x8,x25,x8
movz x9,#0
str x8,[x26,#1264]
str x9,[x26,#1272]
mov x0,x8
movz x1,#47360
movk x1,#10,lsl #16
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#1264]
ldr x1,[x26,#1248]
movz x2,#47360
movk x2,#10,lsl #16
time_host_call memcpy
movz x8,#24752
movk x8,#205,lsl #16
add x8,x25,x8
movz x9,#1
str x8,[x26,#1296]
str x9,[x26,#1304]
mov x0,x8
movz x1,#58560
mov x2,#1
bl .Ltime_host_append_row
ldr x0,[x26,#1296]
ldr x1,[x26,#1280]
movz x2,#58560
time_host_call memcpy
movz x8,#17776
movk x8,#206,lsl #16
add x8,x25,x8
movz x9,#0
str x8,[x26,#1328]
str x9,[x26,#1336]
mov x0,x8
movz x1,#47360
movk x1,#10,lsl #16
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#1328]
ldr x1,[x26,#1312]
movz x2,#47360
movk x2,#10,lsl #16
time_host_call memcpy
movz x8,#65136
movk x8,#216,lsl #16
add x8,x25,x8
movz x9,#1
str x8,[x26,#1360]
str x9,[x26,#1368]
mov x0,x8
movz x1,#58560
mov x2,#1
bl .Ltime_host_append_row
ldr x0,[x26,#1360]
ldr x1,[x26,#1344]
movz x2,#58560
time_host_call memcpy
movz x8,#58160
movk x8,#217,lsl #16
add x8,x25,x8
movz x9,#0
str x8,[x26,#1392]
str x9,[x26,#1400]
mov x0,x8
movz x1,#47360
movk x1,#10,lsl #16
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#1392]
ldr x1,[x26,#1376]
movz x2,#47360
movk x2,#10,lsl #16
time_host_call memcpy
movz x8,#39984
movk x8,#228,lsl #16
add x8,x25,x8
movz x9,#1
str x8,[x26,#1424]
str x9,[x26,#1432]
mov x0,x8
movz x1,#58560
mov x2,#1
bl .Ltime_host_append_row
ldr x0,[x26,#1424]
ldr x1,[x26,#1408]
movz x2,#58560
time_host_call memcpy
movz x8,#33008
movk x8,#229,lsl #16
add x8,x25,x8
movz x9,#0
str x8,[x26,#1456]
str x9,[x26,#1464]
mov x0,x8
movz x1,#47360
movk x1,#10,lsl #16
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#1456]
ldr x1,[x26,#1440]
movz x2,#47360
movk x2,#10,lsl #16
time_host_call memcpy
movz x8,#14832
movk x8,#240,lsl #16
add x8,x25,x8
movz x9,#1
str x8,[x26,#1488]
str x9,[x26,#1496]
mov x0,x8
movz x1,#58560
mov x2,#1
bl .Ltime_host_append_row
ldr x0,[x26,#1488]
ldr x1,[x26,#1472]
movz x2,#58560
time_host_call memcpy
movz x8,#7856
movk x8,#241,lsl #16
add x8,x25,x8
movz x9,#0
str x8,[x26,#1520]
str x9,[x26,#1528]
mov x0,x8
movz x1,#47360
movk x1,#10,lsl #16
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#1520]
ldr x1,[x26,#1504]
movz x2,#47360
movk x2,#10,lsl #16
time_host_call memcpy
movz x8,#55216
movk x8,#251,lsl #16
add x8,x25,x8
movz x9,#1
str x8,[x26,#1552]
str x9,[x26,#1560]
mov x0,x8
movz x1,#58560
mov x2,#1
bl .Ltime_host_append_row
ldr x0,[x26,#1552]
ldr x1,[x26,#1536]
movz x2,#58560
time_host_call memcpy
movz x8,#48240
movk x8,#252,lsl #16
add x8,x25,x8
movz x9,#0
str x8,[x26,#1584]
str x9,[x26,#1592]
mov x0,x8
movz x1,#47360
movk x1,#10,lsl #16
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#1584]
ldr x1,[x26,#1568]
movz x2,#47360
movk x2,#10,lsl #16
time_host_call memcpy
movz x8,#30064
movk x8,#263,lsl #16
add x8,x25,x8
movz x9,#1
str x8,[x26,#1616]
str x9,[x26,#1624]
mov x0,x8
movz x1,#58560
mov x2,#1
bl .Ltime_host_append_row
ldr x0,[x26,#1616]
ldr x1,[x26,#1600]
movz x2,#58560
time_host_call memcpy
movz x8,#23088
movk x8,#264,lsl #16
add x8,x25,x8
movz x9,#0
str x8,[x26,#1648]
str x9,[x26,#1656]
mov x0,x8
movz x1,#47360
movk x1,#10,lsl #16
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#1648]
ldr x1,[x26,#1632]
movz x2,#47360
movk x2,#10,lsl #16
time_host_call memcpy
movz x8,#4912
movk x8,#275,lsl #16
add x8,x25,x8
movz x9,#1
str x8,[x26,#1680]
str x9,[x26,#1688]
mov x0,x8
movz x1,#58560
mov x2,#1
bl .Ltime_host_append_row
ldr x0,[x26,#1680]
ldr x1,[x26,#1664]
movz x2,#58560
time_host_call memcpy
movz x8,#63472
movk x8,#275,lsl #16
add x8,x25,x8
movz x9,#0
str x8,[x26,#1712]
str x9,[x26,#1720]
mov x0,x8
movz x1,#47360
movk x1,#10,lsl #16
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#1712]
ldr x1,[x26,#1696]
movz x2,#47360
movk x2,#10,lsl #16
time_host_call memcpy
movz x8,#45296
movk x8,#286,lsl #16
add x8,x25,x8
movz x9,#1
str x8,[x26,#1744]
str x9,[x26,#1752]
mov x0,x8
movz x1,#58560
mov x2,#1
bl .Ltime_host_append_row
ldr x0,[x26,#1744]
ldr x1,[x26,#1728]
movz x2,#58560
time_host_call memcpy
movz x8,#38320
movk x8,#287,lsl #16
add x8,x25,x8
movz x9,#0
str x8,[x26,#1776]
str x9,[x26,#1784]
mov x0,x8
movz x1,#47360
movk x1,#10,lsl #16
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#1776]
ldr x1,[x26,#1760]
movz x2,#47360
movk x2,#10,lsl #16
time_host_call memcpy
movz x8,#20144
movk x8,#298,lsl #16
add x8,x25,x8
movz x9,#1
str x8,[x26,#1808]
str x9,[x26,#1816]
mov x0,x8
movz x1,#58560
mov x2,#1
bl .Ltime_host_append_row
ldr x0,[x26,#1808]
ldr x1,[x26,#1792]
movz x2,#58560
time_host_call memcpy
movz x8,#13168
movk x8,#299,lsl #16
add x8,x25,x8
movz x9,#0
str x8,[x26,#1840]
str x9,[x26,#1848]
mov x0,x8
movz x1,#47360
movk x1,#10,lsl #16
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#1840]
ldr x1,[x26,#1824]
movz x2,#47360
movk x2,#10,lsl #16
time_host_call memcpy
movz x8,#60528
movk x8,#309,lsl #16
add x8,x25,x8
movz x9,#1
str x8,[x26,#1872]
str x9,[x26,#1880]
mov x0,x8
movz x1,#58560
mov x2,#1
bl .Ltime_host_append_row
ldr x0,[x26,#1872]
ldr x1,[x26,#1856]
movz x2,#58560
time_host_call memcpy
movz x8,#53552
movk x8,#310,lsl #16
add x8,x25,x8
movz x9,#0
str x8,[x26,#1904]
str x9,[x26,#1912]
mov x0,x8
movz x1,#520
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#1904]
ldr x1,[x26,#1888]
movz x2,#520
time_host_call memcpy
movz x8,#54080
movk x8,#310,lsl #16
add x8,x25,x8
movz x9,#0
str x8,[x26,#1936]
str x9,[x26,#1944]
mov x0,x8
movz x1,#20008
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#1936]
ldr x1,[x26,#1920]
movz x2,#20008
time_host_call memcpy
movz x8,#8560
movk x8,#311,lsl #16
add x8,x25,x8
movz x9,#0
str x8,[x26,#1968]
str x9,[x26,#1976]
mov x0,x8
movz x1,#20008
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#1968]
ldr x1,[x26,#1952]
movz x2,#20008
time_host_call memcpy
movz x8,#28576
movk x8,#311,lsl #16
add x8,x25,x8
movz x9,#0
str x8,[x26,#2000]
str x9,[x26,#2008]
mov x0,x8
movz x1,#20008
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#2000]
ldr x1,[x26,#1984]
movz x2,#20008
time_host_call memcpy
movz x8,#48592
movk x8,#311,lsl #16
add x8,x25,x8
movz x9,#0
str x8,[x26,#2032]
str x9,[x26,#2040]
mov x0,x8
movz x1,#20008
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#2032]
ldr x1,[x26,#2016]
movz x2,#20008
time_host_call memcpy
movz x8,#3072
movk x8,#312,lsl #16
add x8,x25,x8
movz x9,#0
str x8,[x26,#2064]
str x9,[x26,#2072]
mov x0,x8
movz x1,#20008
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#2064]
ldr x1,[x26,#2048]
movz x2,#20008
time_host_call memcpy
movz x8,#23088
movk x8,#312,lsl #16
add x8,x25,x8
movz x9,#0
str x8,[x26,#2096]
str x9,[x26,#2104]
mov x0,x8
movz x1,#20008
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#2096]
ldr x1,[x26,#2080]
movz x2,#20008
time_host_call memcpy
movz x8,#43104
movk x8,#312,lsl #16
add x8,x25,x8
movz x9,#0
str x8,[x26,#2128]
str x9,[x26,#2136]
mov x0,x8
movz x1,#20008
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#2128]
ldr x1,[x26,#2112]
movz x2,#20008
time_host_call memcpy
movz x8,#63120
movk x8,#312,lsl #16
add x8,x25,x8
movz x9,#0
str x8,[x26,#2160]
str x9,[x26,#2168]
mov x0,x8
movz x1,#20008
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#2160]
ldr x1,[x26,#2144]
movz x2,#20008
time_host_call memcpy
movz x8,#17600
movk x8,#313,lsl #16
add x8,x25,x8
movz x9,#0
str x8,[x26,#2192]
str x9,[x26,#2200]
mov x0,x8
movz x1,#136
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#2192]
ldr x1,[x26,#2176]
movz x2,#136
time_host_call memcpy
movz x8,#17744
movk x8,#313,lsl #16
add x8,x25,x8
movz x9,#0
str x8,[x26,#2224]
str x9,[x26,#2232]
mov x0,x8
movz x1,#3600
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#2224]
ldr x1,[x26,#2208]
movz x2,#3600
time_host_call memcpy
movz x8,#21344
movk x8,#313,lsl #16
add x8,x25,x8
movz x9,#0
str x8,[x26,#2256]
str x9,[x26,#2264]
mov x0,x8
movz x1,#3600
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#2256]
ldr x1,[x26,#2240]
movz x2,#3600
time_host_call memcpy
movz x8,#24944
movk x8,#313,lsl #16
add x8,x25,x8
movz x9,#0
str x8,[x26,#2288]
str x9,[x26,#2296]
mov x0,x8
movz x1,#32
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#2288]
ldr x1,[x26,#2272]
movz x2,#32
time_host_call memcpy
movz x8,#24976
movk x8,#313,lsl #16
add x8,x25,x8
movz x9,#0
str x8,[x26,#2320]
str x9,[x26,#2328]
mov x0,x8
movz x1,#512
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#2320]
ldr x1,[x26,#2304]
movz x2,#512
time_host_call memcpy
movz x8,#25488
movk x8,#313,lsl #16
add x8,x25,x8
movz x9,#0
str x8,[x26,#2352]
str x9,[x26,#2360]
mov x0,x8
movz x1,#216
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#2352]
ldr x1,[x26,#2336]
movz x2,#216
time_host_call memcpy
movz x8,#25712
movk x8,#313,lsl #16
add x8,x25,x8
movz x9,#0
str x8,[x26,#2384]
str x9,[x26,#2392]
mov x0,x8
movz x1,#160
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#2384]
ldr x1,[x26,#2368]
movz x2,#160
time_host_call memcpy
movz x8,#25872
movk x8,#313,lsl #16
add x8,x25,x8
movz x9,#0
str x8,[x26,#2416]
str x9,[x26,#2424]
mov x0,x8
movz x1,#160
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#2416]
ldr x1,[x26,#2400]
movz x2,#160
time_host_call memcpy
movz x8,#26032
movk x8,#313,lsl #16
add x8,x25,x8
movz x9,#0
str x8,[x26,#2448]
str x9,[x26,#2456]
mov x0,x8
movz x1,#152
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#2448]
ldr x1,[x26,#2432]
movz x2,#152
time_host_call memcpy
movz x8,#26192
movk x8,#313,lsl #16
add x8,x25,x8
movz x9,#0
str x8,[x26,#2480]
str x9,[x26,#2488]
mov x0,x8
movz x1,#152
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#2480]
ldr x1,[x26,#2464]
movz x2,#152
time_host_call memcpy
movz x8,#26352
movk x8,#313,lsl #16
add x8,x25,x8
movz x9,#0
str x8,[x26,#2512]
str x9,[x26,#2520]
mov x0,x8
movz x1,#152
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#2512]
ldr x1,[x26,#2496]
movz x2,#152
time_host_call memcpy
movz x8,#26512
movk x8,#313,lsl #16
add x8,x25,x8
movz x9,#0
str x8,[x26,#2544]
str x9,[x26,#2552]
mov x0,x8
movz x1,#152
mov x2,#0
bl .Ltime_host_append_row
ldr x0,[x26,#2544]
ldr x1,[x26,#2528]
movz x2,#152
time_host_call memcpy
ldr x8,[x19,#0]
str x8,[x20,#0]
ldr x8,[x19,#8]
str x8,[x20,#8]
ldr x8,[x19,#16]
str x8,[x20,#16]
ldr x8,[x19,#24]
str x8,[x20,#24]
ldr x8,[x19,#32]
str x8,[x20,#32]
ldr x8,[x19,#40]
str x8,[x20,#40]
ldr x8,[x19,#48]
str x8,[x20,#48]
ldr x8,[x19,#56]
str x8,[x20,#56]
ldr x8,[x19,#64]
str x8,[x20,#64]
ldr x8,[x26,#16]
str x8,[x20,#0]
ldr x8,[x26,#48]
str x8,[x20,#8]
ldr x8,[x26,#80]
str x8,[x20,#16]
ldr x8,[x26,#16]
ldr x9,[x26,#2320]
movz x10,#0
add x9,x9,x10
movz x10,#3240
str x9,[x8,x10]
ldr x8,[x26,#16]
ldr x9,[x26,#2352]
movz x10,#0
add x9,x9,x10
movz x10,#3264
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#112]
movz x10,#0
add x9,x9,x10
movz x10,#48920
movk x10,#20,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#816]
movz x10,#0
add x9,x9,x10
movz x10,#37344
movk x10,#24,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#848]
movz x10,#0
add x9,x9,x10
movz x10,#37408
movk x10,#24,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#880]
movz x10,#0
add x9,x9,x10
movz x10,#37472
movk x10,#24,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#912]
movz x10,#0
add x9,x9,x10
movz x10,#37536
movk x10,#24,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#944]
movz x10,#0
add x9,x9,x10
movz x10,#37600
movk x10,#24,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#976]
movz x10,#0
add x9,x9,x10
movz x10,#18712
movk x10,#21,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1008]
movz x10,#0
add x9,x9,x10
movz x10,#18824
movk x10,#21,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1040]
movz x10,#0
add x9,x9,x10
movz x10,#18936
movk x10,#21,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1072]
movz x10,#0
add x9,x9,x10
movz x10,#19048
movk x10,#21,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1104]
movz x10,#0
add x9,x9,x10
movz x10,#19160
movk x10,#21,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1136]
movz x10,#0
add x9,x9,x10
movz x10,#19272
movk x10,#21,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1168]
movz x10,#0
add x9,x9,x10
movz x10,#19384
movk x10,#21,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1200]
movz x10,#0
add x9,x9,x10
movz x10,#22240
movk x10,#23,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1264]
movz x10,#0
add x9,x9,x10
movz x10,#22352
movk x10,#23,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1328]
movz x10,#0
add x9,x9,x10
movz x10,#22640
movk x10,#23,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1392]
movz x10,#0
add x9,x9,x10
movz x10,#22752
movk x10,#23,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1456]
movz x10,#0
add x9,x9,x10
movz x10,#23040
movk x10,#23,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1520]
movz x10,#0
add x9,x9,x10
movz x10,#23152
movk x10,#23,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1584]
movz x10,#0
add x9,x9,x10
movz x10,#23264
movk x10,#23,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1648]
movz x10,#0
add x9,x9,x10
movz x10,#23640
movk x10,#23,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1712]
movz x10,#0
add x9,x9,x10
movz x10,#23752
movk x10,#23,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1776]
movz x10,#0
add x9,x9,x10
movz x10,#23864
movk x10,#23,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1840]
movz x10,#0
add x9,x9,x10
movz x10,#24240
movk x10,#23,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1232]
movz x10,#0
add x9,x9,x10
movz x10,#22464
movk x10,#23,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1296]
movz x10,#0
add x9,x9,x10
movz x10,#22552
movk x10,#23,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1360]
movz x10,#0
add x9,x9,x10
movz x10,#22864
movk x10,#23,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1424]
movz x10,#0
add x9,x9,x10
movz x10,#22952
movk x10,#23,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1488]
movz x10,#0
add x9,x9,x10
movz x10,#23376
movk x10,#23,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1552]
movz x10,#0
add x9,x9,x10
movz x10,#23464
movk x10,#23,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1616]
movz x10,#0
add x9,x9,x10
movz x10,#23552
movk x10,#23,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1680]
movz x10,#0
add x9,x9,x10
movz x10,#23976
movk x10,#23,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1744]
movz x10,#0
add x9,x9,x10
movz x10,#24064
movk x10,#23,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1808]
movz x10,#0
add x9,x9,x10
movz x10,#24152
movk x10,#23,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1872]
movz x10,#0
add x9,x9,x10
movz x10,#24352
movk x10,#23,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#144]
ldr x9,[x26,#240]
movz x10,#0
add x9,x9,x10
movz x10,#128
str x9,[x8,x10]
ldr x8,[x26,#144]
ldr x9,[x26,#304]
movz x10,#0
add x9,x9,x10
movz x10,#240
str x9,[x8,x10]
ldr x8,[x26,#144]
ldr x9,[x26,#368]
movz x10,#0
add x9,x9,x10
movz x10,#352
str x9,[x8,x10]
ldr x8,[x26,#144]
ldr x9,[x26,#432]
movz x10,#0
add x9,x9,x10
movz x10,#464
str x9,[x8,x10]
ldr x8,[x26,#144]
ldr x9,[x26,#496]
movz x10,#0
add x9,x9,x10
movz x10,#576
str x9,[x8,x10]
ldr x8,[x26,#144]
ldr x9,[x26,#560]
movz x10,#0
add x9,x9,x10
movz x10,#688
str x9,[x8,x10]
ldr x8,[x26,#144]
ldr x9,[x26,#624]
movz x10,#0
add x9,x9,x10
movz x10,#800
str x9,[x8,x10]
ldr x8,[x26,#144]
ldr x9,[x26,#688]
movz x10,#0
add x9,x9,x10
movz x10,#912
str x9,[x8,x10]
ldr x8,[x26,#144]
ldr x9,[x26,#752]
movz x10,#0
add x9,x9,x10
movz x10,#1024
str x9,[x8,x10]
ldr x8,[x26,#176]
ldr x9,[x26,#208]
movz x10,#0
add x9,x9,x10
movz x10,#64
str x9,[x8,x10]
ldr x8,[x26,#176]
ldr x9,[x26,#272]
movz x10,#0
add x9,x9,x10
movz x10,#216
str x9,[x8,x10]
ldr x8,[x26,#176]
ldr x9,[x26,#336]
movz x10,#0
add x9,x9,x10
movz x10,#128
str x9,[x8,x10]
ldr x8,[x26,#176]
ldr x9,[x26,#400]
movz x10,#0
add x9,x9,x10
movz x10,#304
str x9,[x8,x10]
ldr x8,[x26,#176]
ldr x9,[x26,#464]
movz x10,#0
add x9,x9,x10
movz x10,#392
str x9,[x8,x10]
ldr x8,[x26,#176]
ldr x9,[x26,#528]
movz x10,#0
add x9,x9,x10
movz x10,#480
str x9,[x8,x10]
ldr x8,[x26,#176]
ldr x9,[x26,#592]
movz x10,#0
add x9,x9,x10
movz x10,#568
str x9,[x8,x10]
ldr x8,[x26,#176]
ldr x9,[x26,#656]
movz x10,#0
add x9,x9,x10
movz x10,#832
str x9,[x8,x10]
ldr x8,[x26,#176]
ldr x9,[x26,#720]
movz x10,#0
add x9,x9,x10
movz x10,#744
str x9,[x8,x10]
ldr x8,[x26,#176]
ldr x9,[x26,#784]
movz x10,#0
add x9,x9,x10
movz x10,#656
str x9,[x8,x10]
ldr x8,[x26,#2320]
ldr x9,[x26,#2384]
movz x10,#0
add x9,x9,x10
movz x10,#64
str x9,[x8,x10]
ldr x8,[x26,#2320]
ldr x9,[x26,#2416]
movz x10,#0
add x9,x9,x10
movz x10,#128
str x9,[x8,x10]
ldr x8,[x26,#2320]
ldr x9,[x26,#2448]
movz x10,#0
add x9,x9,x10
movz x10,#448
str x9,[x8,x10]
ldr x8,[x26,#2320]
ldr x9,[x26,#2480]
movz x10,#0
add x9,x9,x10
movz x10,#256
str x9,[x8,x10]
ldr x8,[x26,#2320]
ldr x9,[x26,#2512]
movz x10,#0
add x9,x9,x10
movz x10,#320
str x9,[x8,x10]
ldr x8,[x26,#2320]
ldr x9,[x26,#2544]
movz x10,#0
add x9,x9,x10
movz x10,#384
str x9,[x8,x10]
ldr x8,[x26,#1904]
ldr x9,[x26,#1936]
movz x10,#0
add x9,x9,x10
movz x10,#0
str x9,[x8,x10]
ldr x8,[x26,#1904]
ldr x9,[x26,#1968]
movz x10,#0
add x9,x9,x10
movz x10,#64
str x9,[x8,x10]
ldr x8,[x26,#1904]
ldr x9,[x26,#2000]
movz x10,#0
add x9,x9,x10
movz x10,#128
str x9,[x8,x10]
ldr x8,[x26,#1904]
ldr x9,[x26,#2032]
movz x10,#0
add x9,x9,x10
movz x10,#192
str x9,[x8,x10]
ldr x8,[x26,#1904]
ldr x9,[x26,#2064]
movz x10,#0
add x9,x9,x10
movz x10,#256
str x9,[x8,x10]
ldr x8,[x26,#1904]
ldr x9,[x26,#2096]
movz x10,#0
add x9,x9,x10
movz x10,#320
str x9,[x8,x10]
ldr x8,[x26,#1904]
ldr x9,[x26,#2128]
movz x10,#0
add x9,x9,x10
movz x10,#384
str x9,[x8,x10]
ldr x8,[x26,#1904]
ldr x9,[x26,#2160]
movz x10,#0
add x9,x9,x10
movz x10,#448
str x9,[x8,x10]
ldr x8,[x26,#2192]
ldr x9,[x26,#2224]
movz x10,#0
add x9,x9,x10
movz x10,#0
str x9,[x8,x10]
ldr x8,[x26,#2192]
ldr x9,[x26,#2256]
movz x10,#0
add x9,x9,x10
movz x10,#64
str x9,[x8,x10]
ldr x8,[x20,#24]
cbz x8,.Ltime_host_scalar_skip_3
mov x0,x8
movz x1,#4
mov x2,#0
bl .Ltime_host_append_row
.Ltime_host_scalar_skip_3:
ldr x8,[x20,#32]
cbz x8,.Ltime_host_scalar_skip_4
mov x0,x8
movz x1,#8
mov x2,#0
bl .Ltime_host_append_row
.Ltime_host_scalar_skip_4:
ldr x8,[x20,#40]
cbz x8,.Ltime_host_scalar_skip_5
mov x0,x8
movz x1,#8
mov x2,#0
bl .Ltime_host_append_row
.Ltime_host_scalar_skip_5:
ldr x8,[x20,#48]
cbz x8,.Ltime_host_scalar_skip_6
mov x0,x8
movz x1,#4
mov x2,#0
bl .Ltime_host_append_row
.Ltime_host_scalar_skip_6:
ldr x8,[x20,#56]
cbz x8,.Ltime_host_scalar_skip_7
mov x0,x8
movz x1,#4
mov x2,#0
bl .Ltime_host_append_row
.Ltime_host_scalar_skip_7:
add x28,sp,#4,lsl #12
add x28,x28,#256
adrp x8,:got:__yomcst_MOD_rday
ldr x8,[x8,:got_lo12:__yomcst_MOD_rday]
str x8,[x28,#0]
mov x0,x8
movz x1,#8
mov x2,#0
bl .Ltime_host_append_row
adrp x8,:got:__yomcst_MOD_rpi
ldr x8,[x8,:got_lo12:__yomcst_MOD_rpi]
str x8,[x28,#8]
mov x0,x8
movz x1,#8
mov x2,#0
bl .Ltime_host_append_row
adrp x8,:got:__yomcst_MOD_ra
ldr x8,[x8,:got_lo12:__yomcst_MOD_ra]
str x8,[x28,#16]
mov x0,x8
movz x1,#8
mov x2,#0
bl .Ltime_host_append_row
adrp x8,:got:__yomcst_MOD_rea
ldr x8,[x8,:got_lo12:__yomcst_MOD_rea]
str x8,[x28,#24]
mov x0,x8
movz x1,#8
mov x2,#0
bl .Ltime_host_append_row
adrp x8,:got:__yomrip0_MOD_rtimst
ldr x8,[x8,:got_lo12:__yomrip0_MOD_rtimst]
str x8,[x28,#32]
mov x0,x8
movz x1,#8
mov x2,#0
bl .Ltime_host_append_row
adrp x8,:got:__yomrip0_MOD_nsssss
ldr x8,[x8,:got_lo12:__yomrip0_MOD_nsssss]
str x8,[x28,#40]
mov x0,x8
movz x1,#4
mov x2,#0
bl .Ltime_host_append_row
adrp x8,:got:__yomrip0_MOD_nindat
ldr x8,[x8,:got_lo12:__yomrip0_MOD_nindat]
str x8,[x28,#48]
mov x0,x8
movz x1,#4
mov x2,#0
bl .Ltime_host_append_row
adrp x8,:got:__yomhook_MOD_lhook
ldr x8,[x8,:got_lo12:__yomhook_MOD_lhook]
str x8,[x28,#112]
mov x0,x8
movz x1,#4
mov x2,#0
bl .Ltime_host_append_row
adrp x8,:got:__yomdyncore_MOD_lape
ldr x8,[x8,:got_lo12:__yomdyncore_MOD_lape]
str x8,[x28,#120]
mov x0,x8
movz x1,#4
mov x2,#0
bl .Ltime_host_append_row
adrp x8,:got:__yomrip0_MOD_lastrf
ldr x8,[x8,:got_lo12:__yomrip0_MOD_lastrf]
str x8,[x28,#128]
mov x0,x8
movz x1,#4
mov x2,#0
bl .Ltime_host_append_row
adrp x8,:got:__yomnud_MOD_lnudg
ldr x8,[x8,:got_lo12:__yomnud_MOD_lnudg]
str x8,[x28,#136]
mov x0,x8
movz x1,#4
mov x2,#0
bl .Ltime_host_append_row
adrp x8,:got:__yomrlx_MOD_lrlxg
ldr x8,[x8,:got_lo12:__yomrlx_MOD_lrlxg]
str x8,[x28,#144]
mov x0,x8
movz x1,#4
mov x2,#0
bl .Ltime_host_append_row
adrp x8,:got:__yommp0_MOD_lscmec
ldr x8,[x8,:got_lo12:__yommp0_MOD_lscmec]
str x8,[x28,#152]
mov x0,x8
movz x1,#4
mov x2,#0
bl .Ltime_host_append_row
mov x28,sp
add x28,x28,#512
ldr x8,[x20,#16]
movz x9,#56808
movk x9,#23,lsl #16
add x8,x8,x9
str x8,[x28,#0]
ldr x8,[x20,#16]
movz x9,#35864
movk x9,#24,lsl #16
add x8,x8,x9
str x8,[x28,#8]
ldr x8,[x20,#16]
movz x9,#21392
movk x9,#28,lsl #16
add x8,x8,x9
str x8,[x28,#16]
ldr x8,[x20,#16]
movz x9,#48608
movk x9,#20,lsl #16
add x8,x8,x9
str x8,[x28,#24]
ldr x8,[x20,#64]
str x8,[x28,#32]
add x0,sp,#4,lsl #12
ldr x1,[x26,#1904]
ldr x2,[x26,#2192]
time_host_call md2asm_gpu_fill_time_forcing_record
cbnz x0,.Ltime_host_fail
mov x28,sp
add x28,x28,#576
ldr x8,[x20,#16]
movz x9,#35864
movk x9,#24,lsl #16
add x8,x8,x9
str x8,[x28,#0]
ldr x8,[x20,#16]
movz x9,#21392
movk x9,#28,lsl #16
add x8,x8,x9
str x8,[x28,#8]
adrp x8,:got:__yomrip0_MOD_nindat
ldr x8,[x8,:got_lo12:__yomrip0_MOD_nindat]
str x8,[x28,#16]
movz x8,#26992
movk x8,#313,lsl #16
add x8,x25,x8
str x8,[x28,#24]
ldr x8,[x20,#24]
str x8,[x28,#32]
movz x8,#26996
movk x8,#313,lsl #16
add x8,x25,x8
str x8,[x28,#40]
mov x0,sp
add x0,x0,#576
add x1,sp,#2,lsl #12
ldr x2,[x26,#144]
ldr x3,[x26,#176]
time_host_call md2asm_gpu_fill_monthly_gas_record
cbnz x0,.Ltime_host_fail
movz x8,#0
movk x8,#16,lsl #16
cmp x1,x8
b.hi .Ltime_host_fail
mov x28,sp
add x28,x28,#640
ldr x8,[x20,#0]
str x8,[x28,#0]
ldr x8,[x20,#16]
movz x9,#35864
movk x9,#24,lsl #16
add x8,x8,x9
str x8,[x28,#8]
ldr x8,[x20,#16]
movz x9,#48608
movk x9,#20,lsl #16
add x8,x8,x9
str x8,[x28,#16]
adrp x8,:got:__yomrip0_MOD_nindat
ldr x8,[x8,:got_lo12:__yomrip0_MOD_nindat]
str x8,[x28,#24]
movz x8,#26992
movk x8,#313,lsl #16
add x8,x25,x8
str x8,[x28,#32]
mov x0,sp
add x0,x0,#640
add x1,sp,#3,lsl #12
time_host_call md2asm_gpu_fill_monthly_aerosol_record
cbnz x0,.Ltime_host_fail
movz x8,#0
movk x8,#32,lsl #16
cmp x1,x8
b.hi .Ltime_host_fail
add x28,sp,#4,lsl #12
add x28,x28,#128
adrp x8,:got:__yomcst_MOD_rpi
ldr x8,[x8,:got_lo12:__yomcst_MOD_rpi]
mov x9,#8
stp x8,x9,[x28]
ldr x8,[x26,#112]
movz x9,#62016
stp x8,x9,[x28,#16]
add x8,sp,#4,lsl #12
add x8,x8,#512
add x9,sp,#4,lsl #12
str x9,[x8,#48]
mov x9,#128
str x9,[x8,#56]
mov w9,#1
str w9,[x8,#4]
movz x9,#27184
movk x9,#313,lsl #16
add x9,x25,x9
str x9,[x8,#32]
movz x9,#1024
str x9,[x8,#40]
add x8,sp,#4,lsl #12
add x8,x8,#512
mov x0,x8
movz x1,#64
mov x2,#1
bl .Ltime_host_append_row
add x8,sp,#4,lsl #12
mov x0,x8
movz x1,#128
mov x2,#0
bl .Ltime_host_append_row
movz x8,#27184
movk x8,#313,lsl #16
add x8,x25,x8
mov x0,x8
movz x1,#1024
mov x2,#1
bl .Ltime_host_append_row
add x28,sp,#4,lsl #12
add x28,x28,#256
add x8,sp,#4,lsl #12
add x8,x8,#512
str x8,[x28,#56]
add x8,sp,#4,lsl #12
add x8,x8,#576
add x9,sp,#2,lsl #12
str x9,[x8,#48]
mov x9,#384
str x9,[x8,#56]
mov w9,#1
str w9,[x8,#4]
movz x9,#28208
movk x9,#313,lsl #16
add x9,x25,x9
str x9,[x8,#32]
movz x9,#0
movk x9,#16,lsl #16
str x9,[x8,#40]
add x8,sp,#4,lsl #12
add x8,x8,#576
mov x0,x8
movz x1,#64
mov x2,#1
bl .Ltime_host_append_row
add x8,sp,#2,lsl #12
mov x0,x8
movz x1,#384
mov x2,#0
bl .Ltime_host_append_row
movz x8,#28208
movk x8,#313,lsl #16
add x8,x25,x8
mov x0,x8
movz x1,#0
movk x1,#16,lsl #16
mov x2,#1
bl .Ltime_host_append_row
add x28,sp,#4,lsl #12
add x28,x28,#256
add x8,sp,#4,lsl #12
add x8,x8,#576
str x8,[x28,#64]
add x8,sp,#4,lsl #12
add x8,x8,#640
add x9,sp,#3,lsl #12
str x9,[x8,#48]
mov x9,#4096
str x9,[x8,#56]
mov w9,#1
str w9,[x8,#4]
movz x9,#28208
movk x9,#329,lsl #16
add x9,x25,x9
str x9,[x8,#32]
movz x9,#0
movk x9,#32,lsl #16
str x9,[x8,#40]
add x8,sp,#4,lsl #12
add x8,x8,#640
mov x0,x8
movz x1,#64
mov x2,#1
bl .Ltime_host_append_row
add x8,sp,#3,lsl #12
mov x0,x8
movz x1,#4096
mov x2,#0
bl .Ltime_host_append_row
movz x8,#28208
movk x8,#329,lsl #16
add x8,x25,x8
mov x0,x8
movz x1,#0
movk x1,#32,lsl #16
mov x2,#1
bl .Ltime_host_append_row
add x28,sp,#4,lsl #12
add x28,x28,#256
add x8,sp,#4,lsl #12
add x8,x8,#640
str x8,[x28,#72]
add x8,sp,#4,lsl #12
add x8,x8,#704
add x9,sp,#4,lsl #12
add x9,x9,#128
str x9,[x8,#48]
mov x9,#32
str x9,[x8,#56]
mov w9,#1
str w9,[x8,#4]
add x8,sp,#4,lsl #12
add x8,x8,#704
mov x0,x8
movz x1,#64
mov x2,#1
bl .Ltime_host_append_row
add x8,sp,#4,lsl #12
add x8,x8,#128
mov x0,x8
movz x1,#32
mov x2,#0
bl .Ltime_host_append_row
add x28,sp,#4,lsl #12
add x28,x28,#256
add x8,sp,#4,lsl #12
add x8,x8,#704
str x8,[x28,#80]
adrp x8,:got:md2asm_exponential_native_calls_storage
ldr x8,[x8,:got_lo12:md2asm_exponential_native_calls_storage]
movz x9,#28208
movk x9,#361,lsl #16
add x9,x25,x9
str xzr,[x9]
cbz x8,.Ltime_host_counter_absent_0
ldr x10,[x8]
str x10,[x9]
mov x8,x9
mov x0,x8
movz x1,#8
mov x2,#1
bl .Ltime_host_append_row
.Ltime_host_counter_absent_0:
add x28,sp,#3,lsl #12
ldr x8,[x28,#56]
cbz x8,.Ltime_host_counter_record_ready_0
movz x8,#28208
movk x8,#361,lsl #16
add x8,x25,x8
str x8,[x28,#56]
.Ltime_host_counter_record_ready_0:
adrp x8,:got:md2asm_product_sum_fast_calls
ldr x8,[x8,:got_lo12:md2asm_product_sum_fast_calls]
movz x9,#28216
movk x9,#361,lsl #16
add x9,x25,x9
str xzr,[x9]
cbz x8,.Ltime_host_counter_absent_1
ldr x10,[x8]
str x10,[x9]
mov x8,x9
mov x0,x8
movz x1,#8
mov x2,#1
bl .Ltime_host_append_row
.Ltime_host_counter_absent_1:
add x28,sp,#3,lsl #12
ldr x8,[x28,#72]
cbz x8,.Ltime_host_counter_record_ready_1
movz x8,#28216
movk x8,#361,lsl #16
add x8,x25,x8
str x8,[x28,#72]
.Ltime_host_counter_record_ready_1:
adrp x8,:got:md2asm_product_sum_wide_calls
ldr x8,[x8,:got_lo12:md2asm_product_sum_wide_calls]
movz x9,#28224
movk x9,#361,lsl #16
add x9,x25,x9
str xzr,[x9]
cbz x8,.Ltime_host_counter_absent_2
ldr x10,[x8]
str x10,[x9]
mov x8,x9
mov x0,x8
movz x1,#8
mov x2,#1
bl .Ltime_host_append_row
.Ltime_host_counter_absent_2:
add x28,sp,#3,lsl #12
ldr x8,[x28,#88]
cbz x8,.Ltime_host_counter_record_ready_2
movz x8,#28224
movk x8,#361,lsl #16
add x8,x25,x8
str x8,[x28,#88]
.Ltime_host_counter_record_ready_2:
add x28,sp,#4,lsl #12
add x28,x28,#256
add x8,sp,#4,lsl #12
add x8,x8,#1024
str x8,[x28,#88]
str w27,[x28,#96]
mov x8,#3072
str x8,[x28,#104]
mov x0,x21
movz x1,#3072
mov x2,#0
bl .Ltime_host_append_row
add x8,sp,#4,lsl #12
add x8,x8,#256
mov x0,x8
movz x1,#256
mov x2,#0
bl .Ltime_host_append_row
add x8,sp,#4,lsl #12
add x8,x8,#768
mov x0,x8
movz x1,#64
mov x2,#1
bl .Ltime_host_append_row
mov x0,x20
movz x1,#72
mov x2,#0
bl .Ltime_host_append_row
movz x8,#26672
movk x8,#313,lsl #16
add x8,x25,x8
mov x0,x8
movz x1,#512
mov x2,#1
bl .Ltime_host_append_row
add x28,sp,#4,lsl #12
add x28,x28,#256
str w27,[x28,#96]
add x23,sp,#4,lsl #12
add x23,x23,#768
mov w8,#1
str w8,[x23,#4]
movz x8,#26672
movk x8,#313,lsl #16
add x8,x25,x8
str x8,[x23,#32]
mov x8,#512
str x8,[x23,#40]
add x8,sp,#4,lsl #12
add x8,x8,#256
str x8,[x23,#48]
mov x8,#256
str x8,[x23,#56]
ldp x8,x9,[sp,#104]
msr fpcr,x8
msr fpsr,x9
ldr w8,[sp,#120]
str w8,[x22]
adrp x0,.Ltime_host_entry
add x0,x0,:lo12:.Ltime_host_entry
mov x1,x20
mov x2,x23
mov w3,#1
mov w4,#1
mov w5,#0
time_host_call md2asm_openifs_gpu_launch
cbnz w0,.Ltime_host_fail
mrs x23,fpcr
mrs x24,fpsr
ldr w28,[x22]
ldr x8,[x26,#16]
ldr x9,[x26,#2304]
movz x10,#0
add x9,x9,x10
movz x10,#3240
str x9,[x8,x10]
ldr x8,[x26,#16]
ldr x9,[x26,#2336]
movz x10,#0
add x9,x9,x10
movz x10,#3264
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#96]
movz x10,#0
add x9,x9,x10
movz x10,#48920
movk x10,#20,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#800]
movz x10,#0
add x9,x9,x10
movz x10,#37344
movk x10,#24,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#832]
movz x10,#0
add x9,x9,x10
movz x10,#37408
movk x10,#24,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#864]
movz x10,#0
add x9,x9,x10
movz x10,#37472
movk x10,#24,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#896]
movz x10,#0
add x9,x9,x10
movz x10,#37536
movk x10,#24,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#928]
movz x10,#0
add x9,x9,x10
movz x10,#37600
movk x10,#24,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#960]
movz x10,#0
add x9,x9,x10
movz x10,#18712
movk x10,#21,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#992]
movz x10,#0
add x9,x9,x10
movz x10,#18824
movk x10,#21,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1024]
movz x10,#0
add x9,x9,x10
movz x10,#18936
movk x10,#21,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1056]
movz x10,#0
add x9,x9,x10
movz x10,#19048
movk x10,#21,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1088]
movz x10,#0
add x9,x9,x10
movz x10,#19160
movk x10,#21,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1120]
movz x10,#0
add x9,x9,x10
movz x10,#19272
movk x10,#21,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1152]
movz x10,#0
add x9,x9,x10
movz x10,#19384
movk x10,#21,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1184]
movz x10,#0
add x9,x9,x10
movz x10,#22240
movk x10,#23,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1248]
movz x10,#0
add x9,x9,x10
movz x10,#22352
movk x10,#23,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1312]
movz x10,#0
add x9,x9,x10
movz x10,#22640
movk x10,#23,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1376]
movz x10,#0
add x9,x9,x10
movz x10,#22752
movk x10,#23,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1440]
movz x10,#0
add x9,x9,x10
movz x10,#23040
movk x10,#23,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1504]
movz x10,#0
add x9,x9,x10
movz x10,#23152
movk x10,#23,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1568]
movz x10,#0
add x9,x9,x10
movz x10,#23264
movk x10,#23,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1632]
movz x10,#0
add x9,x9,x10
movz x10,#23640
movk x10,#23,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1696]
movz x10,#0
add x9,x9,x10
movz x10,#23752
movk x10,#23,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1760]
movz x10,#0
add x9,x9,x10
movz x10,#23864
movk x10,#23,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1824]
movz x10,#0
add x9,x9,x10
movz x10,#24240
movk x10,#23,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1216]
movz x10,#0
add x9,x9,x10
movz x10,#22464
movk x10,#23,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1280]
movz x10,#0
add x9,x9,x10
movz x10,#22552
movk x10,#23,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1344]
movz x10,#0
add x9,x9,x10
movz x10,#22864
movk x10,#23,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1408]
movz x10,#0
add x9,x9,x10
movz x10,#22952
movk x10,#23,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1472]
movz x10,#0
add x9,x9,x10
movz x10,#23376
movk x10,#23,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1536]
movz x10,#0
add x9,x9,x10
movz x10,#23464
movk x10,#23,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1600]
movz x10,#0
add x9,x9,x10
movz x10,#23552
movk x10,#23,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1664]
movz x10,#0
add x9,x9,x10
movz x10,#23976
movk x10,#23,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1728]
movz x10,#0
add x9,x9,x10
movz x10,#24064
movk x10,#23,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1792]
movz x10,#0
add x9,x9,x10
movz x10,#24152
movk x10,#23,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#80]
ldr x9,[x26,#1856]
movz x10,#0
add x9,x9,x10
movz x10,#24352
movk x10,#23,lsl #16
str x9,[x8,x10]
ldr x8,[x26,#144]
ldr x9,[x26,#224]
movz x10,#0
add x9,x9,x10
movz x10,#128
str x9,[x8,x10]
ldr x8,[x26,#144]
ldr x9,[x26,#288]
movz x10,#0
add x9,x9,x10
movz x10,#240
str x9,[x8,x10]
ldr x8,[x26,#144]
ldr x9,[x26,#352]
movz x10,#0
add x9,x9,x10
movz x10,#352
str x9,[x8,x10]
ldr x8,[x26,#144]
ldr x9,[x26,#416]
movz x10,#0
add x9,x9,x10
movz x10,#464
str x9,[x8,x10]
ldr x8,[x26,#144]
ldr x9,[x26,#480]
movz x10,#0
add x9,x9,x10
movz x10,#576
str x9,[x8,x10]
ldr x8,[x26,#144]
ldr x9,[x26,#544]
movz x10,#0
add x9,x9,x10
movz x10,#688
str x9,[x8,x10]
ldr x8,[x26,#144]
ldr x9,[x26,#608]
movz x10,#0
add x9,x9,x10
movz x10,#800
str x9,[x8,x10]
ldr x8,[x26,#144]
ldr x9,[x26,#672]
movz x10,#0
add x9,x9,x10
movz x10,#912
str x9,[x8,x10]
ldr x8,[x26,#144]
ldr x9,[x26,#736]
movz x10,#0
add x9,x9,x10
movz x10,#1024
str x9,[x8,x10]
ldr x8,[x26,#176]
ldr x9,[x26,#192]
movz x10,#0
add x9,x9,x10
movz x10,#64
str x9,[x8,x10]
ldr x8,[x26,#176]
ldr x9,[x26,#256]
movz x10,#0
add x9,x9,x10
movz x10,#216
str x9,[x8,x10]
ldr x8,[x26,#176]
ldr x9,[x26,#320]
movz x10,#0
add x9,x9,x10
movz x10,#128
str x9,[x8,x10]
ldr x8,[x26,#176]
ldr x9,[x26,#384]
movz x10,#0
add x9,x9,x10
movz x10,#304
str x9,[x8,x10]
ldr x8,[x26,#176]
ldr x9,[x26,#448]
movz x10,#0
add x9,x9,x10
movz x10,#392
str x9,[x8,x10]
ldr x8,[x26,#176]
ldr x9,[x26,#512]
movz x10,#0
add x9,x9,x10
movz x10,#480
str x9,[x8,x10]
ldr x8,[x26,#176]
ldr x9,[x26,#576]
movz x10,#0
add x9,x9,x10
movz x10,#568
str x9,[x8,x10]
ldr x8,[x26,#176]
ldr x9,[x26,#640]
movz x10,#0
add x9,x9,x10
movz x10,#832
str x9,[x8,x10]
ldr x8,[x26,#176]
ldr x9,[x26,#704]
movz x10,#0
add x9,x9,x10
movz x10,#744
str x9,[x8,x10]
ldr x8,[x26,#176]
ldr x9,[x26,#768]
movz x10,#0
add x9,x9,x10
movz x10,#656
str x9,[x8,x10]
ldr x8,[x26,#2320]
ldr x9,[x26,#2368]
movz x10,#0
add x9,x9,x10
movz x10,#64
str x9,[x8,x10]
ldr x8,[x26,#2320]
ldr x9,[x26,#2400]
movz x10,#0
add x9,x9,x10
movz x10,#128
str x9,[x8,x10]
ldr x8,[x26,#2320]
ldr x9,[x26,#2432]
movz x10,#0
add x9,x9,x10
movz x10,#448
str x9,[x8,x10]
ldr x8,[x26,#2320]
ldr x9,[x26,#2464]
movz x10,#0
add x9,x9,x10
movz x10,#256
str x9,[x8,x10]
ldr x8,[x26,#2320]
ldr x9,[x26,#2496]
movz x10,#0
add x9,x9,x10
movz x10,#320
str x9,[x8,x10]
ldr x8,[x26,#2320]
ldr x9,[x26,#2528]
movz x10,#0
add x9,x9,x10
movz x10,#384
str x9,[x8,x10]
ldr x8,[x26,#1904]
ldr x9,[x26,#1920]
movz x10,#0
add x9,x9,x10
movz x10,#0
str x9,[x8,x10]
ldr x8,[x26,#1904]
ldr x9,[x26,#1952]
movz x10,#0
add x9,x9,x10
movz x10,#64
str x9,[x8,x10]
ldr x8,[x26,#1904]
ldr x9,[x26,#1984]
movz x10,#0
add x9,x9,x10
movz x10,#128
str x9,[x8,x10]
ldr x8,[x26,#1904]
ldr x9,[x26,#2016]
movz x10,#0
add x9,x9,x10
movz x10,#192
str x9,[x8,x10]
ldr x8,[x26,#1904]
ldr x9,[x26,#2048]
movz x10,#0
add x9,x9,x10
movz x10,#256
str x9,[x8,x10]
ldr x8,[x26,#1904]
ldr x9,[x26,#2080]
movz x10,#0
add x9,x9,x10
movz x10,#320
str x9,[x8,x10]
ldr x8,[x26,#1904]
ldr x9,[x26,#2112]
movz x10,#0
add x9,x9,x10
movz x10,#384
str x9,[x8,x10]
ldr x8,[x26,#1904]
ldr x9,[x26,#2144]
movz x10,#0
add x9,x9,x10
movz x10,#448
str x9,[x8,x10]
ldr x8,[x26,#2192]
ldr x9,[x26,#2208]
movz x10,#0
add x9,x9,x10
movz x10,#0
str x9,[x8,x10]
ldr x8,[x26,#2192]
ldr x9,[x26,#2240]
movz x10,#0
add x9,x9,x10
movz x10,#64
str x9,[x8,x10]
ldr x0,[x26,#64]
ldr x1,[x26,#80]
movz x2,#15248
movk x2,#65,lsl #16
time_host_call memcpy
ldr x0,[x26,#160]
ldr x1,[x26,#176]
movz x2,#928
time_host_call memcpy
ldr x0,[x26,#256]
ldr x1,[x26,#272]
movz x2,#46592
time_host_call memcpy
ldr x0,[x26,#320]
ldr x1,[x26,#336]
movz x2,#46592
time_host_call memcpy
ldr x0,[x26,#384]
ldr x1,[x26,#400]
movz x2,#46592
time_host_call memcpy
ldr x0,[x26,#448]
ldr x1,[x26,#464]
movz x2,#46592
time_host_call memcpy
ldr x0,[x26,#512]
ldr x1,[x26,#528]
movz x2,#46592
time_host_call memcpy
ldr x0,[x26,#576]
ldr x1,[x26,#592]
movz x2,#46592
time_host_call memcpy
ldr x0,[x26,#640]
ldr x1,[x26,#656]
movz x2,#46592
time_host_call memcpy
ldr x0,[x26,#704]
ldr x1,[x26,#720]
movz x2,#46592
time_host_call memcpy
ldr x0,[x26,#768]
ldr x1,[x26,#784]
movz x2,#46592
time_host_call memcpy
ldr x0,[x26,#800]
ldr x1,[x26,#816]
movz x2,#160
time_host_call memcpy
ldr x0,[x26,#832]
ldr x1,[x26,#848]
movz x2,#160
time_host_call memcpy
ldr x0,[x26,#864]
ldr x1,[x26,#880]
movz x2,#160
time_host_call memcpy
ldr x0,[x26,#896]
ldr x1,[x26,#912]
movz x2,#160
time_host_call memcpy
ldr x0,[x26,#928]
ldr x1,[x26,#944]
movz x2,#160
time_host_call memcpy
ldr x0,[x26,#1216]
ldr x1,[x26,#1232]
movz x2,#58560
time_host_call memcpy
ldr x0,[x26,#1280]
ldr x1,[x26,#1296]
movz x2,#58560
time_host_call memcpy
ldr x0,[x26,#1344]
ldr x1,[x26,#1360]
movz x2,#58560
time_host_call memcpy
ldr x0,[x26,#1408]
ldr x1,[x26,#1424]
movz x2,#58560
time_host_call memcpy
ldr x0,[x26,#1472]
ldr x1,[x26,#1488]
movz x2,#58560
time_host_call memcpy
ldr x0,[x26,#1536]
ldr x1,[x26,#1552]
movz x2,#58560
time_host_call memcpy
ldr x0,[x26,#1600]
ldr x1,[x26,#1616]
movz x2,#58560
time_host_call memcpy
ldr x0,[x26,#1664]
ldr x1,[x26,#1680]
movz x2,#58560
time_host_call memcpy
ldr x0,[x26,#1728]
ldr x1,[x26,#1744]
movz x2,#58560
time_host_call memcpy
ldr x0,[x26,#1792]
ldr x1,[x26,#1808]
movz x2,#58560
time_host_call memcpy
ldr x0,[x26,#1856]
ldr x1,[x26,#1872]
movz x2,#58560
time_host_call memcpy
adrp x8,:got:md2asm_exponential_native_calls_storage
ldr x8,[x8,:got_lo12:md2asm_exponential_native_calls_storage]
cbz x8,.Ltime_host_counter_commit_done_0
movz x9,#28208
movk x9,#361,lsl #16
add x9,x25,x9
ldr x9,[x9]
str x9,[x8]
.Ltime_host_counter_commit_done_0:
adrp x8,:got:md2asm_product_sum_fast_calls
ldr x8,[x8,:got_lo12:md2asm_product_sum_fast_calls]
cbz x8,.Ltime_host_counter_commit_done_1
movz x9,#28216
movk x9,#361,lsl #16
add x9,x25,x9
ldr x9,[x9]
str x9,[x8]
.Ltime_host_counter_commit_done_1:
adrp x8,:got:md2asm_product_sum_wide_calls
ldr x8,[x8,:got_lo12:md2asm_product_sum_wide_calls]
cbz x8,.Ltime_host_counter_commit_done_2
movz x9,#28224
movk x9,#361,lsl #16
add x9,x25,x9
ldr x9,[x9]
str x9,[x8]
.Ltime_host_counter_commit_done_2:
mov x0,x25
time_host_call free
msr fpcr,x23
msr fpsr,x24
str w28,[x22]
ldr x18,[sp,#96]
ldp x19,x20,[sp,#16]
ldp x21,x22,[sp,#32]
ldp x23,x24,[sp,#48]
ldp x25,x26,[sp,#64]
ldp x27,x28,[sp,#80]
ldp x29,x30,[sp]
add sp,sp,#8,lsl #12
ret
.Ltime_host_fail:
bl abort
brk #0
.size md2asm_gpu_host_model_time,.-md2asm_gpu_host_model_time
#ifndef MD2ASM_GPU_VERIFY_ONLY
.size md2asm_model_time_and_forcing,.-md2asm_model_time_and_forcing
.size updtim_,.-updtim_
#endif
/* x0base,x1bytes,x2writable. x21rows,x27count remain owned by this caller. */
.type .Ltime_host_append_row,%function
.Ltime_host_append_row:
cmp x27,#128
b.hs .Ltime_host_fail
mov x16,#24
madd x16,x27,x16,x21
stp x0,x1,[x16]
str x2,[x16,#16]
add x27,x27,#1
ret
.size .Ltime_host_append_row,.-.Ltime_host_append_row
.weak md2asm_exponential_native_calls_storage
.weak md2asm_product_sum_fast_calls
.weak md2asm_product_sum_wide_calls
.section .rodata
.Ltime_host_entry:.asciz "md2asm_gpu_model_time_and_forcing"
.section .note.GNU-stack,"",%progbits
