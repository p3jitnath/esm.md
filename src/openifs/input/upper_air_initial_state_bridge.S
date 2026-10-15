/* Native six-argument SUGRIDUG verification bridge.
 * Read-only direct metadata uses the frozen original GNU12 data layout.
 * The accepted direct loader owns all file reading and state placement.
 * Closing console-only startup norms are omitted, with no field mutation.
 */
.arch armv8.2-a
.text
.p2align 4
.global sugridug_
.type sugridug_,%function
sugridug_:
 sub sp,sp,#800
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 mrs x9,fpcr
 stp x18,x9,[sp,#96]
 mrs x9,fpsr
 str x9,[sp,#112]
 stp x0,x1,[sp,#144]
 stp x2,x3,[sp,#160]
 stp x4,x5,[sp,#176]
 adrp x28,md2asm_native_upper_air_counters
 add x28,x28,:lo12:md2asm_native_upper_air_counters
 ldr x9,[x28,#8]
 add x9,x9,#1
 str x9,[x28,#8]
 ldr x9,[sp,#104]
 str x9,[x28,#40]
 ldr x9,[sp,#112]
 str x9,[x28,#48]
 bl __errno_location
 str x0,[sp,#120]
 ldr w9,[x0]
 str w9,[sp,#128]
 sxtw x9,w9
 str x9,[x28,#64]
 add x19,sp,#144
 mov x20,#6
.Lpointer:
 ldr x9,[x19],#8
 cbz x9,.Lunsupported
 subs x20,x20,#1
 b.ne .Lpointer
 ldr x9,[sp,#184]
 tst x9,#3
 b.ne .Lunsupported
 ldr w9,[x9]
 cbnz w9,.Lunsupported
 ldr x0,[sp,#144]
 ldp x1,x2,[sp,#160]
 ldr x3,[sp,#176]
 add x4,sp,#256
 bl md2asm_upper_air_initial_context_direct_
 ldr x9,[sp,#256]
 cbnz x9,.Lcontext_failed
 adrp x9,:got:__yomoph0_MOD_cfnigg
 ldr x9,[x9,:got_lo12:__yomoph0_MOD_cfnigg]
 add x10,sp,#768
 mov x11,#0
.Lpath:
 ldrb w12,[x9,x11]
 cbz w12,.Lunsupported
 strb w12,[x10,x11]
 add x11,x11,#1
 cmp x11,#12
 b.ne .Lpath
 mov w12,#85
 strb w12,[x10,#12]
 mov w12,#65
 strb w12,[x10,#13]
 strb wzr,[x10,#14]
 ldr x9,[sp,#104]
 msr fpcr,x9
 ldr x9,[sp,#112]
 msr fpsr,x9
 ldr x9,[sp,#120]
 ldr w10,[sp,#128]
 str w10,[x9]
 ldr x18,[sp,#96]
 add x0,sp,#768
 ldp x1,x2,[sp,#304]
 bl md2asm_load_initial_upper_air_state
 cbnz w0,.Lloader_failed
 mrs x9,fpsr
 str x9,[x28,#56]
 ldr x9,[sp,#120]
 ldrsw x9,[x9]
 str x9,[x28,#72]
 ldr x9,[x28,#16]
 add x9,x9,#1
 str x9,[x28,#16]
 ldr x18,[sp,#96]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp]
 add sp,sp,#800
 ret
.Lunsupported:
 mov x0,#101
 b .Lfail
.Lcontext_failed:
 mov x0,#102
 b .Lfail
.Lloader_failed:
 add x0,x0,#1000
.Lfail:
 str x0,[x28,#32]
 ldr x9,[x28,#24]
 add x9,x9,#1
 str x9,[x28,#24]
 bl md2asm_native_upper_air_failure
 mov x0,#116
 mov x8,#94
 svc #0
 brk #0
.size sugridug_,.-sugridug_
.data
.p2align 3
.hidden md2asm_native_upper_air_counters
.global md2asm_native_upper_air_counters
.type md2asm_native_upper_air_counters,%object
md2asm_native_upper_air_counters:
 .quad 1,0,0,0,0,0,0,0,0,0
.size md2asm_native_upper_air_counters,80
.section .note.GNU-stack,"",%progbits
