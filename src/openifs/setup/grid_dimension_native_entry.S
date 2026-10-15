/* Original SUDIM entry with direct scalar NAMDIM parsing.
 * Contract: skills/md2asm/references/openifs/setup/grid_dimension_setup.md.
 * x0 writable Geometry, x1 optional input KSUPERSEDE.
 * Live scalar setup words are explicit compatibility inputs.
 * No original callable, constructor, type descriptor or vtable is used.
 */
.arch armv8.2-a
.text
.p2align 4
.global sudim_
.type sudim_,%function
sudim_:
 sub sp,sp,#208
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x18,[sp,#64]
 mov x29,sp
 mov x19,x0
 mov x20,#0
 mov w21,#-1
 mrs x9,fpcr
 str x9,[sp,#80]
 mrs x9,fpsr
 str x9,[sp,#88]
 cbz x19,.Ldimension_native_fail
 tst x19,#7
 b.ne .Ldimension_native_fail
 mov x23,x1
 adrp x9,:got:__yomct0_MOD_lecmwf
 ldr x9,[x9,:got_lo12:__yomct0_MOD_lecmwf]
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Ldimension_native_fail
 adrp x9,:got:__yomct0_MOD_lelam
 ldr x9,[x9,:got_lo12:__yomct0_MOD_lelam]
 ldr w9,[x9]
 cmp w9,#0
 b.ne .Ldimension_native_fail
 adrp x9,:got:__yommp0_MOD_lopt_scalar
 ldr x9,[x9,:got_lo12:__yommp0_MOD_lopt_scalar]
 ldr w9,[x9]
 str w9,[sp,#104]
 adrp x9,:got:__yomvar_MOD_lrepro4dvar
 ldr x9,[x9,:got_lo12:__yomvar_MOD_lrepro4dvar]
 ldr w9,[x9]
 str w9,[sp,#108]
 adrp x9,:got:__yomct0_MOD_liolevg
 ldr x9,[x9,:got_lo12:__yomct0_MOD_liolevg]
 ldr w9,[x9]
 str w9,[sp,#116]
 adrp x9,:got:__yomct0_MOD_lr2d
 ldr x9,[x9,:got_lo12:__yomct0_MOD_lr2d]
 ldr w9,[x9]
 str w9,[sp,#120]
 adrp x9,:got:__yomct0_MOD_nconf
 ldr x9,[x9,:got_lo12:__yomct0_MOD_nconf]
 ldr w9,[x9]
 str w9,[sp,#124]
 adrp x9,:got:__yomarg_MOD_nusmax
 ldr x9,[x9,:got_lo12:__yomarg_MOD_nusmax]
 ldr w9,[x9]
 str w9,[sp,#128]
 adrp x9,:got:__yomarg_MOD_nudgl
 ldr x9,[x9,:got_lo12:__yomarg_MOD_nudgl]
 ldr w9,[x9]
 str w9,[sp,#132]
 adrp x9,:got:__yomarg_MOD_nudlon
 ldr x9,[x9,:got_lo12:__yomarg_MOD_nudlon]
 ldr w9,[x9]
 str w9,[sp,#136]
 adrp x9,:got:__yomarg_MOD_nucmax
 ldr x9,[x9,:got_lo12:__yomarg_MOD_nucmax]
 ldr w9,[x9]
 str w9,[sp,#140]
 adrp x9,:got:__yomarg_MOD_nuflev
 ldr x9,[x9,:got_lo12:__yomarg_MOD_nuflev]
 ldr w9,[x9]
 str w9,[sp,#144]
 cbnz x23,.Ldimension_native_explicit_supersede
 adrp x23,:got:__yomarg_MOD_nsupersede
 ldr x23,[x23,:got_lo12:__yomarg_MOD_nsupersede]
.Ldimension_native_explicit_supersede:
 tst x23,#3
 b.ne .Ldimension_native_fail
 ldr w9,[x23]
 cmp w9,#1
 cset w9,eq
 str w9,[sp,#112]
 bl __errno_location
 mov x24,x0
 movz x0,#1
 movk x0,#4,lsl#16
 bl malloc
 cbz x0,.Ldimension_native_fail
 mov x20,x0
 adr x0,.Ldimension_native_file
 mov w1,#0
 mov w2,#0
 bl open
 tbnz w0,#31,.Ldimension_native_fail
 mov w21,w0
 mov x22,#0
.Ldimension_native_read:
 mov w0,w21
 add x1,x20,x22
 movz x2,#1
 movk x2,#4,lsl#16
 sub x2,x2,x22
 bl read
 tbnz x0,#63,.Ldimension_native_read_error
 cbz x0,.Ldimension_native_read_done
 add x22,x22,x0
 movz x9,#1
 movk x9,#4,lsl#16
 cmp x22,x9
 b.hs .Ldimension_native_fail
 b .Ldimension_native_read
.Ldimension_native_read_error:
 ldr w9,[x24]
 cmp w9,#4
 b.eq .Ldimension_native_read
 b .Ldimension_native_fail
.Ldimension_native_read_done:
 mov w0,w21
 bl close
 cbnz w0,.Ldimension_native_fail
 mov w21,#-1
 mov x0,x20
 mov x1,x22
 add x2,sp,#152
 add x3,sp,#100
 bl md2asm_read_grid_dimension_group
 cbnz w0,.Ldimension_native_fail
 mov x0,x20
 bl free
 mov x20,#0
 /* Input services do not add flags to the source setup calculation. */
 /* Genuine successful source namelist reading returns errno zero. */
 str wzr,[x24]
 ldr x9,[sp,#80]
 msr fpcr,x9
 ldr x9,[sp,#88]
 msr fpsr,x9
 ldr x18,[sp,#72]
 mov x0,x19
 add x1,sp,#104
 add x2,sp,#152
 ldr w3,[sp,#100]
 bl md2asm_initialize_grid_dimensions
 cbnz w0,.Ldimension_native_fail
 adrp x9,.Ldimension_native_count
 add x9,x9,:lo12:.Ldimension_native_count
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x18,[sp,#64]
 ldp x29,x30,[sp]
 add sp,sp,#208
 ret
.Ldimension_native_fail:
 tbnz w21,#31,.Ldimension_native_free
 mov w0,w21
 bl close
.Ldimension_native_free:
 cbz x20,.Ldimension_native_exit
 mov x0,x20
 bl free
.Ldimension_native_exit:
 mov w0,#122
 bl _exit
 brk #0
.size sudim_,.-sudim_
.p2align 4
.global md2asm_grid_dimension_native_count_get
.type md2asm_grid_dimension_native_count_get,%function
md2asm_grid_dimension_native_count_get:
 adrp x9,.Ldimension_native_count
 ldr x0,[x9,:lo12:.Ldimension_native_count]
 ret
.size md2asm_grid_dimension_native_count_get,.-md2asm_grid_dimension_native_count_get
.Ldimension_native_file: .asciz "fort.4"
.bss
.p2align 3
.Ldimension_native_count: .zero 8
.section .note.GNU-stack,"",%progbits
