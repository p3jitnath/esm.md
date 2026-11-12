// Direct assembly. Numerical and storage contract: ../../../../skills/md2fort-gpu/references/openifs/radiation/ozone_pressure_layers.md
/* Original eleven-address ozone pressure layer storage boundary.
 * The 640-byte frame has saved state0..123, vector128..215,
 * context256..319 and live flag record320..335.
 * All numerical work executes in the complete GPU child.
 */
.arch armv8-a
.text
.p2align 4
.macro gas_call target
bl \target
ldr x18,[sp,#96]
.endm
.global md2asm_gpu_host_radozc
.type md2asm_gpu_host_radozc,%function
#ifndef MD2ASM_GPU_VERIFY_ONLY
.global md2asm_grid_ozone_layers
.type md2asm_grid_ozone_layers,%function
md2asm_grid_ozone_layers:
#endif
md2asm_gpu_host_radozc:
mov x17,sp
sub sp,sp,#640
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
ldr x8,[x17,#16]
str x8,[sp,#208]
add x19,sp,#128
add x20,sp,#256
mrs x8,fpcr
mrs x9,fpsr
stp x8,x9,[sp,#104]
cbnz x8,.Lgas_failure
gas_call __errno_location
mov x22,x0
ldr w8,[x22]
str w8,[sp,#120]
gas_call omp_in_parallel
cbnz w0,.Lgas_failure
gas_call md2asm_openifs_gpu_prepare
cbnz w0,.Lgas_failure
mov x26,#1024
mov x0,x26
gas_call malloc
cbz x0,.Lgas_failure
mov x21,x0
stp xzr,xzr,[x20]
stp xzr,xzr,[x20,#16]
stp xzr,xzr,[x20,#32]
stp xzr,xzr,[x20,#48]
mov w8,#1
str w8,[x20,#4]
str x21,[x20,#32]
str x26,[x20,#40]
add x8,sp,#320
str x8,[x20,#48]
mov x8,#16
str x8,[x20,#56]
adrp x8,:got:__yomdyncore_MOD_lape
ldr x8,[x8,:got_lo12:__yomdyncore_MOD_lape]
str x8,[sp,#320]
mov x8,#4
str x8,[sp,#328]
ldp x8,x9,[sp,#104]
msr fpcr,x8
msr fpsr,x9
ldr w8,[sp,#120]
str w8,[x22]
adrp x0,.Lgas_entry
add x0,x0,:lo12:.Lgas_entry
mov x1,x19
mov x2,x20
mov w3,#1
mov w4,#1
mov w5,#0
gas_call md2asm_openifs_gpu_launch
cbnz w0,.Lgas_failure
mrs x23,fpcr
mrs x24,fpsr
ldr w25,[x22]
mov x0,x21
gas_call free
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
add sp,sp,#640
ret
.Lgas_failure:bl abort
.size md2asm_gpu_host_radozc,.-md2asm_gpu_host_radozc
#ifndef MD2ASM_GPU_VERIFY_ONLY
.size md2asm_grid_ozone_layers,.-md2asm_grid_ozone_layers
#endif
.section .rodata
.Lgas_entry:.asciz "md2asm_gpu_radozc"
.section .note.GNU-stack,"",%progbits
