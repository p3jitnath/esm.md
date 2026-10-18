/* Contract skills/md2asm-gpu/references/openifs/physics/radiation_gas_forcing.md. */
/* Original five-address parent and two-address FP64 date return.
 * Frame768 holds vector128,context192,live record256 and date output400.
 * Parent scratch1024 is heap-owned. The host has no numerical stage. */
.arch armv8-a
#ifndef MD2ASM_GPU_VERIFY_ONLY
#define MD2ASM_GPU_OWNED_INPUTS 1
#endif
.text
.macro parent_service name
bl \name
ldr x18,[sp,#96]
.endm
.p2align 4
.global md2asm_gpu_host_forcing_parent
.type md2asm_gpu_host_forcing_parent,%function
#ifndef MD2ASM_GPU_VERIFY_ONLY
.global updrgas_
.type updrgas_,%function
updrgas_:
.global md2asm_updrgas
.type md2asm_updrgas,%function
md2asm_updrgas:
#endif
md2asm_gpu_host_forcing_parent:
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
str x4,[sp,#160]
add x19,sp,#128
add x20,sp,#192
mrs x8,fpcr
mrs x9,fpsr
stp x8,x9,[sp,#104]
cbnz x8,.Lparent_fail
parent_service __errno_location
mov x22,x0
ldr w8,[x22]
str w8,[sp,#120]
parent_service omp_in_parallel
cbnz w0,.Lparent_fail
parent_service md2asm_openifs_gpu_prepare
cbnz w0,.Lparent_fail
stp xzr,xzr,[x20]
stp xzr,xzr,[x20,#16]
stp xzr,xzr,[x20,#32]
stp xzr,xzr,[x20,#48]
mov w8,#1
str w8,[x20,#4]
add x8,sp,#256
str x8,[x20,#48]
mov x8,#128
str x8,[x20,#56]
#ifdef MD2ASM_GPU_OWNED_INPUTS
adrp x8,:got:md2asm_owned_radiation_setup_context
ldr x8,[x8,:got_lo12:md2asm_owned_radiation_setup_context]
ldr x27,[x8,#48]
cbz x27,.Lparent_fail
ldr x28,[x8,#4256]
cbz x28,.Lparent_fail
#endif
#ifdef MD2ASM_GPU_OWNED_INPUTS
add x8,x27,#160
#else
adrp x8,:got:__yomcst_MOD_rmd
ldr x8,[x8,:got_lo12:__yomcst_MOD_rmd]
#endif
str x8,[sp,#256]
#ifdef MD2ASM_GPU_OWNED_INPUTS
add x8,x27,#248
#else
adrp x8,:got:__yomcst_MOD_rmco2
ldr x8,[x8,:got_lo12:__yomcst_MOD_rmco2]
#endif
str x8,[sp,#264]
#ifdef MD2ASM_GPU_OWNED_INPUTS
add x8,x27,#256
#else
adrp x8,:got:__yomcst_MOD_rmch4
ldr x8,[x8,:got_lo12:__yomcst_MOD_rmch4]
#endif
str x8,[sp,#272]
#ifdef MD2ASM_GPU_OWNED_INPUTS
add x8,x27,#264
#else
adrp x8,:got:__yomcst_MOD_rmn2o
ldr x8,[x8,:got_lo12:__yomcst_MOD_rmn2o]
#endif
str x8,[sp,#280]
#ifdef MD2ASM_GPU_OWNED_INPUTS
add x8,x27,#288
#else
adrp x8,:got:__yomcst_MOD_rmno2
ldr x8,[x8,:got_lo12:__yomcst_MOD_rmno2]
#endif
str x8,[sp,#288]
#ifdef MD2ASM_GPU_OWNED_INPUTS
add x8,x27,#312
#else
adrp x8,:got:__yomcst_MOD_rmcfc11
ldr x8,[x8,:got_lo12:__yomcst_MOD_rmcfc11]
#endif
str x8,[sp,#296]
#ifdef MD2ASM_GPU_OWNED_INPUTS
add x8,x27,#320
#else
adrp x8,:got:__yomcst_MOD_rmcfc12
ldr x8,[x8,:got_lo12:__yomcst_MOD_rmcfc12]
#endif
str x8,[sp,#304]
#ifdef MD2ASM_GPU_OWNED_INPUTS
add x8,x27,#328
#else
adrp x8,:got:__yomcst_MOD_rmhcfc22
ldr x8,[x8,:got_lo12:__yomcst_MOD_rmhcfc22]
#endif
str x8,[sp,#312]
#ifdef MD2ASM_GPU_OWNED_INPUTS
add x8,x27,#336
#else
adrp x8,:got:__yomcst_MOD_rmccl4
ldr x8,[x8,:got_lo12:__yomcst_MOD_rmccl4]
#endif
str x8,[sp,#320]
#ifdef MD2ASM_GPU_OWNED_INPUTS
add x8,x27,#144
#else
adrp x8,:got:__yomcst_MOD_ri0
ldr x8,[x8,:got_lo12:__yomcst_MOD_ri0]
#endif
str x8,[sp,#328]
#ifdef MD2ASM_GPU_OWNED_INPUTS
add x8,x27,#40
#else
adrp x8,:got:__yomcst_MOD_rday
ldr x8,[x8,:got_lo12:__yomcst_MOD_rday]
#endif
str x8,[sp,#336]
adrp x8,:got:__yomct0_MOD_lnf
ldr x8,[x8,:got_lo12:__yomct0_MOD_lnf]
str x8,[sp,#344]
adrp x8,:got:__yomct2_MOD_nstar2
ldr x8,[x8,:got_lo12:__yomct2_MOD_nstar2]
str x8,[sp,#352]
adrp x8,:got:__yomrip0_MOD_nindat
ldr x8,[x8,:got_lo12:__yomrip0_MOD_nindat]
str x8,[sp,#360]
#ifdef MD2ASM_GPU_OWNED_INPUTS
add x8,x28,#136
#else
adrp x8,:got:__yomghgtimeseries_MOD_yghgtimeseries
ldr x8,[x8,:got_lo12:__yomghgtimeseries_MOD_yghgtimeseries]
ldr x8,[x8]
#endif
str x8,[sp,#368]
#ifdef MD2ASM_GPU_OWNED_INPUTS
mov x8,x28
#else
adrp x8,:got:__yomsolarirradiance_MOD_ysolarirradiance
ldr x8,[x8,:got_lo12:__yomsolarirradiance_MOD_ysolarirradiance]
ldr x8,[x8]
#endif
str x8,[sp,#376]
mov x0,#1024
parent_service malloc
cbz x0,.Lparent_fail
mov x21,x0
str x21,[x20,#32]
mov x8,#1024
str x8,[x20,#40]
ldp x8,x9,[sp,#104]
msr fpcr,x8
msr fpsr,x9
ldr w8,[sp,#120]
str w8,[x22]
adrp x0,.Lparent_entry
add x0,x0,:lo12:.Lparent_entry
mov x1,x19
mov x2,x20
mov w3,#1
mov w4,#1
mov w5,#0
parent_service md2asm_openifs_gpu_launch
cbnz w0,.Lparent_fail
mrs x23,fpcr
mrs x24,fpsr
ldr w25,[x22]
mov x0,x21
parent_service free
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
.Lparent_fail:bl abort
brk #0
.size md2asm_gpu_host_forcing_parent,.-md2asm_gpu_host_forcing_parent
#ifndef MD2ASM_GPU_VERIFY_ONLY
.size updrgas_,.-updrgas_
.size md2asm_updrgas,.-md2asm_updrgas
#endif
.p2align 4
.global md2asm_gpu_host_forcing_year
.type md2asm_gpu_host_forcing_year,%function
#ifndef MD2ASM_GPU_VERIFY_ONLY
.global md2asm_updrgas_get_year
.type md2asm_updrgas_get_year,%function
md2asm_updrgas_get_year:
#endif
md2asm_gpu_host_forcing_year:
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
add x8,sp,#400
str x8,[sp,#144]
add x19,sp,#128
add x20,sp,#192
mrs x8,fpcr
mrs x9,fpsr
stp x8,x9,[sp,#104]
cbnz x8,.Lyear_fail
parent_service __errno_location
mov x22,x0
ldr w8,[x22]
str w8,[sp,#120]
parent_service omp_in_parallel
cbnz w0,.Lyear_fail
parent_service md2asm_openifs_gpu_prepare
cbnz w0,.Lyear_fail
stp xzr,xzr,[x20]
stp xzr,xzr,[x20,#16]
stp xzr,xzr,[x20,#32]
stp xzr,xzr,[x20,#48]
mov w8,#1
str w8,[x20,#4]
add x8,sp,#256
str x8,[x20,#48]
mov x8,#128
str x8,[x20,#56]
#ifdef MD2ASM_GPU_OWNED_INPUTS
adrp x8,:got:md2asm_owned_radiation_setup_context
ldr x8,[x8,:got_lo12:md2asm_owned_radiation_setup_context]
ldr x27,[x8,#48]
cbz x27,.Lyear_fail
#endif
#ifdef MD2ASM_GPU_OWNED_INPUTS
add x8,x27,#160
#else
adrp x8,:got:__yomcst_MOD_rmd
ldr x8,[x8,:got_lo12:__yomcst_MOD_rmd]
#endif
str x8,[sp,#256]
#ifdef MD2ASM_GPU_OWNED_INPUTS
add x8,x27,#248
#else
adrp x8,:got:__yomcst_MOD_rmco2
ldr x8,[x8,:got_lo12:__yomcst_MOD_rmco2]
#endif
str x8,[sp,#264]
#ifdef MD2ASM_GPU_OWNED_INPUTS
add x8,x27,#256
#else
adrp x8,:got:__yomcst_MOD_rmch4
ldr x8,[x8,:got_lo12:__yomcst_MOD_rmch4]
#endif
str x8,[sp,#272]
#ifdef MD2ASM_GPU_OWNED_INPUTS
add x8,x27,#264
#else
adrp x8,:got:__yomcst_MOD_rmn2o
ldr x8,[x8,:got_lo12:__yomcst_MOD_rmn2o]
#endif
str x8,[sp,#280]
#ifdef MD2ASM_GPU_OWNED_INPUTS
add x8,x27,#288
#else
adrp x8,:got:__yomcst_MOD_rmno2
ldr x8,[x8,:got_lo12:__yomcst_MOD_rmno2]
#endif
str x8,[sp,#288]
#ifdef MD2ASM_GPU_OWNED_INPUTS
add x8,x27,#312
#else
adrp x8,:got:__yomcst_MOD_rmcfc11
ldr x8,[x8,:got_lo12:__yomcst_MOD_rmcfc11]
#endif
str x8,[sp,#296]
#ifdef MD2ASM_GPU_OWNED_INPUTS
add x8,x27,#320
#else
adrp x8,:got:__yomcst_MOD_rmcfc12
ldr x8,[x8,:got_lo12:__yomcst_MOD_rmcfc12]
#endif
str x8,[sp,#304]
#ifdef MD2ASM_GPU_OWNED_INPUTS
add x8,x27,#328
#else
adrp x8,:got:__yomcst_MOD_rmhcfc22
ldr x8,[x8,:got_lo12:__yomcst_MOD_rmhcfc22]
#endif
str x8,[sp,#312]
#ifdef MD2ASM_GPU_OWNED_INPUTS
add x8,x27,#336
#else
adrp x8,:got:__yomcst_MOD_rmccl4
ldr x8,[x8,:got_lo12:__yomcst_MOD_rmccl4]
#endif
str x8,[sp,#320]
#ifdef MD2ASM_GPU_OWNED_INPUTS
add x8,x27,#144
#else
adrp x8,:got:__yomcst_MOD_ri0
ldr x8,[x8,:got_lo12:__yomcst_MOD_ri0]
#endif
str x8,[sp,#328]
#ifdef MD2ASM_GPU_OWNED_INPUTS
add x8,x27,#40
#else
adrp x8,:got:__yomcst_MOD_rday
ldr x8,[x8,:got_lo12:__yomcst_MOD_rday]
#endif
str x8,[sp,#336]
adrp x8,:got:__yomct0_MOD_lnf
ldr x8,[x8,:got_lo12:__yomct0_MOD_lnf]
str x8,[sp,#344]
adrp x8,:got:__yomct2_MOD_nstar2
ldr x8,[x8,:got_lo12:__yomct2_MOD_nstar2]
str x8,[sp,#352]
adrp x8,:got:__yomrip0_MOD_nindat
ldr x8,[x8,:got_lo12:__yomrip0_MOD_nindat]
str x8,[sp,#360]
#ifdef MD2ASM_GPU_OWNED_INPUTS
mov x8,#0
#else
adrp x8,:got:__yomghgtimeseries_MOD_yghgtimeseries
ldr x8,[x8,:got_lo12:__yomghgtimeseries_MOD_yghgtimeseries]
ldr x8,[x8]
#endif
str x8,[sp,#368]
#ifdef MD2ASM_GPU_OWNED_INPUTS
mov x8,#0
#else
adrp x8,:got:__yomsolarirradiance_MOD_ysolarirradiance
ldr x8,[x8,:got_lo12:__yomsolarirradiance_MOD_ysolarirradiance]
ldr x8,[x8]
#endif
str x8,[sp,#376]
ldp x8,x9,[sp,#104]
msr fpcr,x8
msr fpsr,x9
ldr w8,[sp,#120]
str w8,[x22]
adrp x0,.Lyear_entry
add x0,x0,:lo12:.Lyear_entry
mov x1,x19
mov x2,x20
mov w3,#1
mov w4,#1
mov w5,#0
parent_service md2asm_openifs_gpu_launch
cbnz w0,.Lyear_fail
ldr d0,[sp,#400]
ldr x18,[sp,#96]
ldp x19,x20,[sp,#16]
ldp x21,x22,[sp,#32]
ldp x23,x24,[sp,#48]
ldp x25,x26,[sp,#64]
ldp x27,x28,[sp,#80]
ldp x29,x30,[sp]
add sp,sp,#768
ret
.Lyear_fail:bl abort
brk #0
.size md2asm_gpu_host_forcing_year,.-md2asm_gpu_host_forcing_year
#ifndef MD2ASM_GPU_VERIFY_ONLY
.size md2asm_updrgas_get_year,.-md2asm_updrgas_get_year
#endif
.section .rodata
.Lparent_entry:.asciz "md2asm_gpu_forcing_parent"
.Lyear_entry:.asciz "md2asm_gpu_forcing_year"
.section .note.GNU-stack,"",%progbits
