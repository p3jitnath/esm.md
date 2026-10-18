/* Contract skills/md2asm-gpu/references/openifs/physics/radiation_gas_forcing.md. */
/* Complete GNU lookup address interfaces. No host numerical work. */
.arch armv8-a
.text
.macro forcing_service name
bl \name
ldr x18,[sp,#96]
.endm
.p2align 4
.global md2asm_gpu_host_greenhouse_lookup
.type md2asm_gpu_host_greenhouse_lookup,%function
#ifndef MD2ASM_GPU_VERIFY_ONLY
.global __yomghgtimeseries_MOD_get_ghg_concentrations
.type __yomghgtimeseries_MOD_get_ghg_concentrations,%function
__yomghgtimeseries_MOD_get_ghg_concentrations:
.global md2asm_ghg_timeseries
.type md2asm_ghg_timeseries,%function
md2asm_ghg_timeseries:
.global md2asm_updrgas_ghg
.type md2asm_updrgas_ghg,%function
md2asm_updrgas_ghg:
#endif
md2asm_gpu_host_greenhouse_lookup:
mov x17,sp
sub sp,sp,#384
stp x29,x30,[sp]
mov x29,sp
stp x19,x20,[sp,#16]
stp x21,x22,[sp,#32]
stp x23,x24,[sp,#48]
stp x25,x26,[sp,#64]
stp x27,x28,[sp,#80]
str x18,[sp,#96]
str x0,[sp,#128]
str x1,[sp,#136]
str x2,[sp,#144]
str x3,[sp,#152]
str x4,[sp,#160]
str x5,[sp,#168]
str x6,[sp,#176]
str x7,[sp,#184]
ldr x8,[x17]
str x8,[sp,#192]
add x19,sp,#128
add x21,sp,#256
mrs x8,fpcr
mrs x9,fpsr
stp x8,x9,[sp,#104]
cbnz x8,.Lgreenhouse_fail
forcing_service __errno_location
mov x20,x0
ldr w8,[x20]
str w8,[sp,#120]
forcing_service omp_in_parallel
cbnz w0,.Lgreenhouse_fail
forcing_service md2asm_openifs_gpu_prepare
cbnz w0,.Lgreenhouse_fail
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
adrp x0,.Lgreenhouse_entry
add x0,x0,:lo12:.Lgreenhouse_entry
mov x1,x19
mov x2,x21
mov w3,#1
mov w4,#1
mov w5,#0
forcing_service md2asm_openifs_gpu_launch
cbnz w0,.Lgreenhouse_fail
ldr x18,[sp,#96]
ldp x19,x20,[sp,#16]
ldp x21,x22,[sp,#32]
ldp x23,x24,[sp,#48]
ldp x25,x26,[sp,#64]
ldp x27,x28,[sp,#80]
ldp x29,x30,[sp]
add sp,sp,#384
ret
.Lgreenhouse_fail:bl abort
brk #0
.size md2asm_gpu_host_greenhouse_lookup,.-md2asm_gpu_host_greenhouse_lookup
#ifndef MD2ASM_GPU_VERIFY_ONLY
.size __yomghgtimeseries_MOD_get_ghg_concentrations,.-__yomghgtimeseries_MOD_get_ghg_concentrations
.size md2asm_ghg_timeseries,.-md2asm_ghg_timeseries
.size md2asm_updrgas_ghg,.-md2asm_updrgas_ghg
#endif
.p2align 4
.global md2asm_gpu_host_solar_lookup
.type md2asm_gpu_host_solar_lookup,%function
#ifndef MD2ASM_GPU_VERIFY_ONLY
.global __yomsolarirradiance_MOD_get_solar_irradiance
.type __yomsolarirradiance_MOD_get_solar_irradiance,%function
__yomsolarirradiance_MOD_get_solar_irradiance:
.global md2asm_solar_irradiance
.type md2asm_solar_irradiance,%function
md2asm_solar_irradiance:
.global md2asm_updrgas_solar
.type md2asm_updrgas_solar,%function
md2asm_updrgas_solar:
#endif
md2asm_gpu_host_solar_lookup:
mov x17,sp
sub sp,sp,#384
stp x29,x30,[sp]
mov x29,sp
stp x19,x20,[sp,#16]
stp x21,x22,[sp,#32]
stp x23,x24,[sp,#48]
stp x25,x26,[sp,#64]
stp x27,x28,[sp,#80]
str x18,[sp,#96]
str x0,[sp,#128]
str x1,[sp,#136]
str x2,[sp,#144]
add x19,sp,#128
add x21,sp,#256
mrs x8,fpcr
mrs x9,fpsr
stp x8,x9,[sp,#104]
cbnz x8,.Lsolar_fail
forcing_service __errno_location
mov x20,x0
ldr w8,[x20]
str w8,[sp,#120]
forcing_service omp_in_parallel
cbnz w0,.Lsolar_fail
forcing_service md2asm_openifs_gpu_prepare
cbnz w0,.Lsolar_fail
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
adrp x0,.Lsolar_entry
add x0,x0,:lo12:.Lsolar_entry
mov x1,x19
mov x2,x21
mov w3,#1
mov w4,#1
mov w5,#0
forcing_service md2asm_openifs_gpu_launch
cbnz w0,.Lsolar_fail
ldr x18,[sp,#96]
ldp x19,x20,[sp,#16]
ldp x21,x22,[sp,#32]
ldp x23,x24,[sp,#48]
ldp x25,x26,[sp,#64]
ldp x27,x28,[sp,#80]
ldp x29,x30,[sp]
add sp,sp,#384
ret
.Lsolar_fail:bl abort
brk #0
.size md2asm_gpu_host_solar_lookup,.-md2asm_gpu_host_solar_lookup
#ifndef MD2ASM_GPU_VERIFY_ONLY
.size __yomsolarirradiance_MOD_get_solar_irradiance,.-__yomsolarirradiance_MOD_get_solar_irradiance
.size md2asm_solar_irradiance,.-md2asm_solar_irradiance
.size md2asm_updrgas_solar,.-md2asm_updrgas_solar
#endif
.section .rodata
.Lgreenhouse_entry:.asciz "md2asm_gpu_greenhouse_lookup"
.Lsolar_entry:.asciz "md2asm_gpu_solar_lookup"
.section .note.GNU-stack,"",%progbits
