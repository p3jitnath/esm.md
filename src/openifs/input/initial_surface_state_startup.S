/* Selected ten-pointer SUGRIDF route, revision 1.
 * Metadata getters read live types, default constants and branch controls only.
 * Direct assembly owns all allocated-row defaults and complete surface loading.
 * Console norms and timing instrumentation are outside this forecast route.
 * A 352-byte aligned frame preserves x18 and the Arm saved-register obligations.
 */
.arch armv8.2-a
.text
.p2align 4
.global sugridf_
.type sugridf_,%function
sugridf_:
 sub sp,sp,#352
 stp x29,x30,[sp,#16]
 add x29,sp,#16
 stp x19,x20,[sp,#32]
 stp x21,x22,[sp,#48]
 stp x23,x24,[sp,#64]
 stp x25,x26,[sp,#80]
 stp x27,x28,[sp,#96]
 mrs x9,fpcr
 stp x18,x9,[sp,#112]
 mrs x9,fpsr
 str x9,[sp,#128]
 stp x0,x1,[sp,#160]
 stp x2,x3,[sp,#176]
 stp x4,x5,[sp,#192]
 stp x6,x7,[sp,#208]
 ldp x9,x10,[sp,#352]
 stp x9,x10,[sp,#224]
 adrp x28,md2asm_native_surface_startup_counters
 add x28,x28,:lo12:md2asm_native_surface_startup_counters
 ldr x9,[x28,#8]
 add x9,x9,#1
 str x9,[x28,#8]
 ldr x9,[sp,#120]
 str x9,[x28,#40]
 ldr x9,[sp,#128]
 str x9,[x28,#48]
 bl __errno_location
 str x0,[sp,#136]
 ldr w9,[x0]
 str w9,[sp,#144]
 sxtw x9,w9
 str x9,[x28,#64]
 add x19,sp,#160
 mov x20,#6
.Lrequire:
 ldr x9,[x19],#8
 cbz x9,.Lunsupported
 subs x20,x20,#1
 b.ne .Lrequire
 ldr x9,[sp,#184]
 ldr x10,[sp,#200]
 orr x11,x9,x10
 tst x11,#3
 b.ne .Lunsupported
 ldr w9,[x9]
 cbnz w9,.Lunsupported
 ldp x9,x10,[sp,#208]
 orr x9,x9,x10
 ldr x10,[sp,#224]
 orr x9,x9,x10
 cbnz x9,.Lunsupported
 ldp x0,x1,[sp,#160]
 ldr x2,[sp,#176]
 add x3,sp,#240
 bl md2asm_surface_startup_context_direct_
 ldr x9,[sp,#240]
 cbnz x9,.Lcontext_failed
 mov x0,#0x8640
 movk x0,#1,lsl#16
 bl malloc
 cbz x0,.Lallocation_failed
 mov x21,x0
 ldp x0,x1,[sp,#160]
 mov x2,x21
 add x3,x21,#1536
 mov x9,#0x8600
 movk x9,#1,lsl#16
 add x4,x21,x9
 bl md2asm_surface_default_metadata_direct_
 mov x9,#0x8600
 movk x9,#1,lsl#16
 add x22,x21,x9
 ldr x9,[x22]
 cbnz x9,.Ldefault_context_failed
 ldr x9,[sp,#120]
 msr fpcr,x9
 ldr x9,[sp,#128]
 msr fpsr,x9
 ldr x9,[sp,#136]
 ldr w10,[sp,#144]
 str w10,[x9]
 ldr x18,[sp,#112]
 mov x0,x21
 mov x1,#1536
 add x2,x21,#1536
 mov x3,#0x8000
 movk x3,#1,lsl#16
 ldr x4,[x22,#16]
 ldr x5,[x22,#8]
 bl md2asm_set_initial_surface_defaults
 cbnz w0,.Ldefault_failed
 ldp x0,x1,[sp,#160]
 ldp x2,x3,[sp,#248]
 ldr x4,[sp,#264]
 ldr x5,[sp,#184]
 ldr x6,[sp,#200]
 mov x7,#0
 str xzr,[sp]
 bl sugridg_
 mrs x9,fpsr
 str x9,[sp,#312]
 ldr x9,[sp,#136]
 ldr w10,[x9]
 str w10,[sp,#320]
 mov x0,x21
 bl free
 ldr x9,[sp,#120]
 msr fpcr,x9
 ldr x9,[sp,#312]
 msr fpsr,x9
 str x9,[x28,#56]
 ldr x9,[sp,#136]
 ldr w10,[sp,#320]
 str w10,[x9]
 sxtw x10,w10
 str x10,[x28,#72]
 ldr x9,[x28,#16]
 add x9,x9,#1
 str x9,[x28,#16]
 ldr x18,[sp,#112]
 ldp x19,x20,[sp,#32]
 ldp x21,x22,[sp,#48]
 ldp x23,x24,[sp,#64]
 ldp x25,x26,[sp,#80]
 ldp x27,x28,[sp,#96]
 ldp x29,x30,[sp,#16]
 add sp,sp,#352
 ret
.Lunsupported:
 mov x0,#101
 b .Lfail
.Lcontext_failed:
 mov x0,#102
 b .Lfail
.Lallocation_failed:
 mov x0,#103
 b .Lfail
.Ldefault_context_failed:
 mov x0,#104
 b .Lfail
.Ldefault_failed:
 mov x0,#105
.Lfail:
 str x0,[x28,#32]
 ldr x9,[x28,#24]
 add x9,x9,#1
 str x9,[x28,#24]
 bl md2asm_native_surface_startup_failure
 mov x0,#116
 mov x8,#94
 svc #0
 brk #0
.size sugridf_,.-sugridf_
.data
.p2align 3
.hidden md2asm_native_surface_startup_counters
.global md2asm_native_surface_startup_counters
.type md2asm_native_surface_startup_counters,%object
md2asm_native_surface_startup_counters:
 .quad 1,0,0,0,0,0,0,0,0,0
.size md2asm_native_surface_startup_counters,80
.section .note.GNU-stack,"",%progbits
