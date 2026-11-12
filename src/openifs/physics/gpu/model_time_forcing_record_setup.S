// Contract: skills/md2fort-gpu/references/openifs/physics/model_time_and_forcing.md.
/* Storage-only time-forcing record fill for a complete GPU time parent.
 * x0 addresses a zeroed 128-byte record. x1 and x2 address private gas and
 * solar objects. Return x0 is zero on success and one on invalid pointers.
 * Original owned constants and scalar controls remain live. No FP operation,
 * library service or GPU launch occurs here. The 64-byte frame preserves
 * x19-x21,x27-x30; x18 and every vector register remain untouched. */
.arch armv8-a
#ifndef MD2ASM_GPU_VERIFY_ONLY
#define MD2ASM_GPU_OWNED_INPUTS 1
#endif
.text
.p2align 4
.global md2asm_gpu_fill_time_forcing_record
.type md2asm_gpu_fill_time_forcing_record,%function
md2asm_gpu_fill_time_forcing_record:
sub sp,sp,#64
stp x19,x20,[sp]
stp x21,x27,[sp,#16]
stp x28,x29,[sp,#32]
str x30,[sp,#48]
mov x19,x0
mov x20,x1
mov x21,x2
cbz x19,.Lfill_fail
cbz x20,.Lfill_fail
cbz x21,.Lfill_fail
orr x8,x19,x20
orr x8,x8,x21
tst x8,#7
b.ne .Lfill_fail
#ifdef MD2ASM_GPU_OWNED_INPUTS
adrp x8,:got:md2asm_owned_radiation_setup_context
ldr x8,[x8,:got_lo12:md2asm_owned_radiation_setup_context]
ldr x27,[x8,#48]
cbz x27,.Lfill_fail
#endif
#ifdef MD2ASM_GPU_OWNED_INPUTS
add x8,x27,#160
#else
adrp x8,:got:__yomcst_MOD_rmd
ldr x8,[x8,:got_lo12:__yomcst_MOD_rmd]
#endif
str x8,[x19,#0]
#ifdef MD2ASM_GPU_OWNED_INPUTS
add x8,x27,#248
#else
adrp x8,:got:__yomcst_MOD_rmco2
ldr x8,[x8,:got_lo12:__yomcst_MOD_rmco2]
#endif
str x8,[x19,#8]
#ifdef MD2ASM_GPU_OWNED_INPUTS
add x8,x27,#256
#else
adrp x8,:got:__yomcst_MOD_rmch4
ldr x8,[x8,:got_lo12:__yomcst_MOD_rmch4]
#endif
str x8,[x19,#16]
#ifdef MD2ASM_GPU_OWNED_INPUTS
add x8,x27,#264
#else
adrp x8,:got:__yomcst_MOD_rmn2o
ldr x8,[x8,:got_lo12:__yomcst_MOD_rmn2o]
#endif
str x8,[x19,#24]
#ifdef MD2ASM_GPU_OWNED_INPUTS
add x8,x27,#288
#else
adrp x8,:got:__yomcst_MOD_rmno2
ldr x8,[x8,:got_lo12:__yomcst_MOD_rmno2]
#endif
str x8,[x19,#32]
#ifdef MD2ASM_GPU_OWNED_INPUTS
add x8,x27,#312
#else
adrp x8,:got:__yomcst_MOD_rmcfc11
ldr x8,[x8,:got_lo12:__yomcst_MOD_rmcfc11]
#endif
str x8,[x19,#40]
#ifdef MD2ASM_GPU_OWNED_INPUTS
add x8,x27,#320
#else
adrp x8,:got:__yomcst_MOD_rmcfc12
ldr x8,[x8,:got_lo12:__yomcst_MOD_rmcfc12]
#endif
str x8,[x19,#48]
#ifdef MD2ASM_GPU_OWNED_INPUTS
add x8,x27,#328
#else
adrp x8,:got:__yomcst_MOD_rmhcfc22
ldr x8,[x8,:got_lo12:__yomcst_MOD_rmhcfc22]
#endif
str x8,[x19,#56]
#ifdef MD2ASM_GPU_OWNED_INPUTS
add x8,x27,#336
#else
adrp x8,:got:__yomcst_MOD_rmccl4
ldr x8,[x8,:got_lo12:__yomcst_MOD_rmccl4]
#endif
str x8,[x19,#64]
#ifdef MD2ASM_GPU_OWNED_INPUTS
add x8,x27,#144
#else
adrp x8,:got:__yomcst_MOD_ri0
ldr x8,[x8,:got_lo12:__yomcst_MOD_ri0]
#endif
str x8,[x19,#72]
#ifdef MD2ASM_GPU_OWNED_INPUTS
add x8,x27,#40
#else
adrp x8,:got:__yomcst_MOD_rday
ldr x8,[x8,:got_lo12:__yomcst_MOD_rday]
#endif
str x8,[x19,#80]
adrp x8,:got:__yomct0_MOD_lnf
ldr x8,[x8,:got_lo12:__yomct0_MOD_lnf]
str x8,[x19,#88]
adrp x8,:got:__yomct2_MOD_nstar2
ldr x8,[x8,:got_lo12:__yomct2_MOD_nstar2]
str x8,[x19,#96]
adrp x8,:got:__yomrip0_MOD_nindat
ldr x8,[x8,:got_lo12:__yomrip0_MOD_nindat]
str x8,[x19,#104]
mov x8,x20
str x8,[x19,#112]
mov x8,x21
str x8,[x19,#120]
mov x0,#0
b .Lfill_return
.Lfill_fail:mov x0,#1
.Lfill_return:
ldp x19,x20,[sp]
ldp x21,x27,[sp,#16]
ldp x28,x29,[sp,#32]
ldr x30,[sp,#48]
add sp,sp,#64
ret
.size md2asm_gpu_fill_time_forcing_record,.-md2asm_gpu_fill_time_forcing_record
.section .note.GNU-stack,"",%progbits
