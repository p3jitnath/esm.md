// Direct assembly. Numerical and storage contract: ../../../../skills/md2asm-gpu/references/openifs/physics/seasonal_ozone_coefficients.md
// Original two-address SUECOZO ABI. The GPU owns all 72 Fourier values.
.arch armv8-a
.text
.p2align 4
.macro seasonal_ozone_service name
bl \name
ldr x18,[sp,#96]
.endm
.global md2asm_gpu_host_seasonal_ozone
.type md2asm_gpu_host_seasonal_ozone,%function
#ifndef MD2ASM_GPU_VERIFY_ONLY
.global md2asm_yearly_ozone_cycle
.type md2asm_yearly_ozone_cycle,%function
md2asm_yearly_ozone_cycle:
#endif
md2asm_gpu_host_seasonal_ozone:
sub sp,sp,#256
stp x29,x30,[sp]
mov x29,sp
stp x19,x20,[sp,#16]
stp x21,x22,[sp,#32]
stp x23,x24,[sp,#48]
stp x25,x26,[sp,#64]
stp x27,x28,[sp,#80]
str x18,[sp,#96]
stp x0,x1,[sp,#128]
mrs x8,fpcr
mrs x9,fpsr
stp x8,x9,[sp,#104]
cbnz x8,.Lseasonal_ozone_failure
seasonal_ozone_service __errno_location
mov x20,x0
ldr w8,[x20]
str w8,[sp,#120]
seasonal_ozone_service omp_in_parallel
cbnz w0,.Lseasonal_ozone_failure
seasonal_ozone_service md2asm_openifs_gpu_prepare
cbnz w0,.Lseasonal_ozone_failure
add x21,sp,#160
stp xzr,xzr,[x21]
stp xzr,xzr,[x21,#16]
stp xzr,xzr,[x21,#32]
stp xzr,xzr,[x21,#48]
mov w8,#1
str w8,[x21,#4]
ldp x8,x9,[sp,#104]
msr fpcr,x8
msr fpsr,x9
ldr w8,[sp,#120]
str w8,[x20]
adrp x0,.Lseasonal_ozone_entry
add x0,x0,:lo12:.Lseasonal_ozone_entry
add x1,sp,#128
mov x2,x21
mov w3,#1
mov w4,#1
mov w5,#0
seasonal_ozone_service md2asm_openifs_gpu_launch
cbnz w0,.Lseasonal_ozone_failure
ldr x18,[sp,#96]
ldp x19,x20,[sp,#16]
ldp x21,x22,[sp,#32]
ldp x23,x24,[sp,#48]
ldp x25,x26,[sp,#64]
ldp x27,x28,[sp,#80]
ldp x29,x30,[sp]
add sp,sp,#256
ret
.Lseasonal_ozone_failure:
bl abort
brk #0
.size md2asm_gpu_host_seasonal_ozone,.-md2asm_gpu_host_seasonal_ozone
#ifndef MD2ASM_GPU_VERIFY_ONLY
.size md2asm_yearly_ozone_cycle,.-md2asm_yearly_ozone_cycle
#endif
.section .rodata
.Lseasonal_ozone_entry:.asciz "md2asm_gpu_seasonal_ozone"
.section .note.GNU-stack,"",%progbits
