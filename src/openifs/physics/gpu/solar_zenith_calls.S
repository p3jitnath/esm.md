// Contract: skills/md2asm-gpu/references/openifs/physics/solar_zenith_geometry.md.
/* Complete COS_SZA original ten-address boundary. No model FP arithmetic.
 * Frame768: saved0..103,status104..123,vector128..207,ctx256..319,
 * record320..447. Scratch contains one FP64 value per allocated column.
 */
.arch armv8-a
.text
.p2align 4
.macro solar_call symbol
bl \symbol
ldr x18,[sp,#96]
.endm
.global md2asm_gpu_host_cos_sza
.type md2asm_gpu_host_cos_sza,%function
#ifndef MD2ASM_GPU_VERIFY_ONLY
.global md2asm_ec_solar_7358525
.global md2asm_cos_sza
.global cos_sza_
.type md2asm_ec_solar_7358525,%function
.type md2asm_cos_sza,%function
.type cos_sza_,%function
md2asm_ec_solar_7358525:
md2asm_cos_sza:
cos_sza_:
#endif
md2asm_gpu_host_cos_sza:
mov x17,sp
sub sp,sp,#768
stp x29,x30,[sp]
mov x29,sp
stp x19,x20,[sp,#16]
stp x21,x22,[sp,#32]
stp x23,x24,[sp,#48]
stp x25,x26,[sp,#64]
stp x27,x28,[sp,#80]
str x18,[sp,#96]
stp x0,x1,[sp,#128]
stp x2,x3,[sp,#144]
stp x4,x5,[sp,#160]
stp x6,x7,[sp,#176]
ldp x8,x9,[x17]
stp x8,x9,[sp,#192]
add x19,sp,#128
add x20,sp,#256
mrs x8,fpcr
mrs x9,fpsr
stp x8,x9,[sp,#104]
cbnz x8,.Lsolar_failure
solar_call __errno_location
mov x22,x0
ldr w8,[x22]
str w8,[sp,#120]
solar_call omp_in_parallel
cbnz w0,.Lsolar_failure
solar_call md2asm_openifs_gpu_prepare
cbnz w0,.Lsolar_failure
ldr x8,[x19,#40]
cbz x8,.Lsolar_failure
tst x8,#3
b.ne .Lsolar_failure
ldrsw x8,[x8]
cmp x8,#1
b.lt .Lsolar_failure
cmp x8,#4096
b.gt .Lsolar_failure
lsl x26,x8,#3
mov x0,x26
solar_call malloc
cbz x0,.Lsolar_failure
mov x21,x0
stp xzr,xzr,[x20]
stp xzr,xzr,[x20,#16]
stp xzr,xzr,[x20,#32]
stp xzr,xzr,[x20,#48]
mov w8,#1
str w8,[x20,#4]
stp x21,x26,[x20,#32]
add x8,sp,#320
str x8,[x20,#48]
mov x9,#128
str x9,[x20,#56]

mov x8,#2040
str x8,[sp,#320]
mov x8,#48
str x8,[sp,#328]
mov x8,#44904
movk x8,#2,lsl #16
str x8,[sp,#336]
mov x8,#4
str x8,[sp,#344]
mov x8,#4
str x8,[sp,#352]
mov x8,#4
str x8,[sp,#360]
str x26,[sp,#368]
str x26,[sp,#376]
mov x8,#4
str x8,[sp,#384]
str x26,[sp,#392]
adrp x8,:got:__yomcst_MOD_rpi
ldr x8,[x8,:got_lo12:__yomcst_MOD_rpi]
str x8,[sp,#400]
mov x9,#8
str x9,[sp,#408]
adrp x8,:got:__yomcst_MOD_rday
ldr x8,[x8,:got_lo12:__yomcst_MOD_rday]
str x8,[sp,#416]
mov x9,#8
str x9,[sp,#424]
stp xzr,xzr,[sp,#432]
ldp x8,x9,[sp,#104]
msr fpcr,x8
msr fpsr,x9
ldr w8,[sp,#120]
str w8,[x22]
adrp x0,.Lsolar_kernel
add x0,x0,:lo12:.Lsolar_kernel
mov x1,x19
mov x2,x20
mov w3,#1
mov w4,#1
mov w5,#0
solar_call md2asm_openifs_gpu_launch
cbnz w0,.Lsolar_failure
mrs x23,fpcr
mrs x24,fpsr
ldr w25,[x22]
mov x0,x21
solar_call free
msr fpcr,x23
msr fpsr,x24
str w25,[x22]
ldr x18,[sp,#96]
ldp x19,x20,[sp,#16]
ldp x21,x22,[sp,#32]
ldp x23,x24,[sp,#48]
ldp x25,x26,[sp,#64]
ldp x27,x28,[sp,#80]
ldp x29,x30,[sp]
add sp,sp,#768
ret
.Lsolar_failure:bl abort
.size md2asm_gpu_host_cos_sza,.-md2asm_gpu_host_cos_sza
#ifndef MD2ASM_GPU_VERIFY_ONLY
.size md2asm_ec_solar_7358525,.-md2asm_ec_solar_7358525
.size md2asm_cos_sza,.-md2asm_cos_sza
.size cos_sza_,.-cos_sza_
#endif
.section .rodata
.Lsolar_kernel:.asciz "md2asm_gpu_cos_sza"
.section .note.GNU-stack,"",%progbits
