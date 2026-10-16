/* Contract: skills/md2asm/references/openifs/radiation/forcing_caller_binding.md. */
.arch armv8.2-a
.text
/* Five-address UPDRGAS caller interface over the accepted owned service.
 * x0 TDYNA456, x1 TERAD2040, x2 TERDI176, x3 TRIP175976,
 * x4 optional solar FP64 address. The radiation context remains live.
 * The private table borrows real input records and climate owners.
 * No original OpenIFS type table or global pointer enters this call. */
.p2align 4
.global md2asm_updrgas
.type md2asm_updrgas,%function
md2asm_updrgas:
 sub sp,sp,#192
 stp x29,x30,[sp]
 stp x18,x19,[sp,#16]
 mov x29,sp
 mov x19,x2
 mov x9,#456
 stp x0,x9,[sp,#32]
 mov x9,#2040
 stp x1,x9,[sp,#48]
 movz x9,#(175976 & 65535)
 movk x9,#(175976 >> 16),lsl#16
 stp x3,x9,[sp,#64]
 adrp x10,:got:md2asm_owned_radiation_setup_context
 ldr x10,[x10,:got_lo12:md2asm_owned_radiation_setup_context]
 ldr x11,[x10,#48]
 mov x9,#520
 stp x11,x9,[sp,#80]
 mov x9,#4256
 ldr x11,[x10,x9]
 mov x9,#2792
 stp x11,x9,[sp,#96]
 add x11,sp,#144
 mov x9,#16
 stp x11,x9,[sp,#112]
 mov x9,#8
 cmp x4,#0
 csel x9,xzr,x9,eq
 stp x4,x9,[sp,#128]
 adrp x9,:got:__yomrip0_MOD_nindat
 ldr x9,[x9,:got_lo12:__yomrip0_MOD_nindat]
 ldr w9,[x9]
 str w9,[sp,#144]
 adrp x9,:got:__yomct2_MOD_nstar2
 ldr x9,[x9,:got_lo12:__yomct2_MOD_nstar2]
 ldr w9,[x9]
 str w9,[sp,#148]
 adrp x9,:got:__yomct0_MOD_lnf
 ldr x9,[x9,:got_lo12:__yomct0_MOD_lnf]
 ldr w9,[x9]
 str w9,[sp,#152]
 str wzr,[sp,#156]
 mov x0,x19
 mov x1,#176
 add x2,sp,#32
 bl md2asm_update_owned_radiation_forcing
 cbnz w0,.Lforcing_boundary_bad
 ldp x18,x19,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#192
 ret
.Lforcing_boundary_bad:
 bl abort
.size md2asm_updrgas,.-md2asm_updrgas
.section .note.GNU-stack,"",%progbits
