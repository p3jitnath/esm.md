// Contract: skills/md2asm-gpu/references/openifs/radiation/private_legendre_basis.md.
/* Original RADACT four-address LEGTRI storage boundary; all numerical work is GPU-owned. */
.arch armv8-a
.text
.p2align 4
.macro legendre_call target
bl \target
ldr x18,[sp,#96]
.endm
.global md2asm_gpu_host_radact_legendre
.type md2asm_gpu_host_radact_legendre,%function
.global md2asm_radact_legtri
.global md2asm_radact_legtri_alias
.type md2asm_radact_legtri,%function
.type md2asm_radact_legtri_alias,%function
md2asm_gpu_host_radact_legendre:
md2asm_radact_legtri:
md2asm_radact_legtri_alias:
sub sp,sp,#512
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
add x19,sp,#128
add x20,sp,#192
mrs x8,fpcr
mrs x9,fpsr
stp x8,x9,[sp,#104]
cbnz x8,.Lradact_legendre_failure
legendre_call __errno_location
mov x22,x0
ldr w8,[x22]
str w8,[sp,#120]
legendre_call omp_in_parallel
cbnz w0,.Lradact_legendre_failure
legendre_call md2asm_openifs_gpu_prepare
cbnz w0,.Lradact_legendre_failure
stp xzr,xzr,[x20]
stp xzr,xzr,[x20,#16]
stp xzr,xzr,[x20,#32]
stp xzr,xzr,[x20,#48]
mov w8,#1
str w8,[x20,#4]
ldp x8,x9,[sp,#104]
msr fpcr,x8
msr fpsr,x9
ldr w8,[sp,#120]
str w8,[x22]
adrp x0,.Lradact_legendre_entry
add x0,x0,:lo12:.Lradact_legendre_entry
mov x1,x19
mov x2,x20
mov w3,#1
mov w4,#1
mov w5,#0
legendre_call md2asm_openifs_gpu_launch
cbnz w0,.Lradact_legendre_failure
ldr x18,[sp,#96]
ldp x19,x20,[sp,#16]
ldp x21,x22,[sp,#32]
ldp x23,x24,[sp,#48]
ldp x25,x26,[sp,#64]
ldp x27,x28,[sp,#80]
ldp x29,x30,[sp]
add sp,sp,#512
ret
.Lradact_legendre_failure:bl abort
.size md2asm_gpu_host_radact_legendre,.-md2asm_gpu_host_radact_legendre
.size md2asm_radact_legtri,.-md2asm_radact_legtri
.size md2asm_radact_legtri_alias,.-md2asm_radact_legtri_alias
.section .rodata
.Lradact_legendre_entry:.asciz "md2asm_gpu_radact_legendre"
.section .note.GNU-stack,"",%progbits
