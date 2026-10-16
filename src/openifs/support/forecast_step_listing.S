/* Owned selected forecast progress listing, revision 1.
 * Contract: skills/md2asm/references/openifs/support/forecast_step_listing.md.
 * Raw x0 open fd,x1 int32 step,x2 config[9]; return0/1write/2input.
 * The complete inputs are mapped; step aligns4 and is0..24.
 * Original ABI x0 step,x1 config,x2 hidden length9, void return.
 * Integer-only formatting;112-byte raw and16-byte native frames. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_write_forecast_step_listing
.type md2asm_write_forecast_step_listing,%function
md2asm_write_forecast_step_listing:
 tbnz w0,#31,.Llisting_invalid
 cbz x1,.Llisting_invalid
 cbz x2,.Llisting_invalid
 tst x1,#3
 b.ne .Llisting_invalid
 adds x9,x1,#4
 b.cs .Llisting_invalid
 adds x9,x2,#9
 b.cs .Llisting_invalid
 ldr w10,[x1]
 cmp w10,#24
 b.hi .Llisting_invalid
 stp x29,x30,[sp,#-112]!
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 mov x29,sp
 mov w19,w0
 mov x20,x2
 mov w21,w10
 adrp x9,.Llisting_template
 add x9,x9,:lo12:.Llisting_template
 ldp x10,x11,[x9]
 stp x10,x11,[sp,#64]
 ldp x10,x11,[x9,#16]
 stp x10,x11,[sp,#80]
 ldrb w10,[x9,#32]
 strb w10,[sp,#96]
 add x9,sp,#78
 mov w10,#10
.Llisting_digits:
 udiv w11,w21,w10
 msub w12,w11,w10,w21
 add w12,w12,#48
 strb w12,[x9,#-1]!
 mov w21,w11
 cbnz w21,.Llisting_digits
 ldr x10,[x20]
 add x9,sp,#87
 str x10,[x9]
 ldrb w10,[x20,#8]
 strb w10,[sp,#95]
 add x1,sp,#64
 mov x2,#33
.Llisting_write:
 mov w0,w19
 mov x8,#64
 svc #0
 cmn x0,#4
 b.eq .Llisting_write
 cmp x0,#0
 b.le .Llisting_failed
 add x1,x1,x0
 subs x2,x2,x0
 b.ne .Llisting_write
 mov w0,#0
 b .Llisting_return
.Llisting_failed:
 mov w0,#1
.Llisting_return:
 ldp x20,x21,[sp,#32]
 ldp x18,x19,[sp,#16]
 ldp x29,x30,[sp],#112
 ret
.Llisting_invalid:
 mov w0,#2
 ret
.size md2asm_write_forecast_step_listing,.-md2asm_write_forecast_step_listing
.p2align 4
.global md2asm_step_log_
.type md2asm_step_log_,%function
md2asm_step_log_:
 cmp x2,#9
 b.ne .Llisting_native_bad
 stp x29,x30,[sp,#-16]!
 mov x29,sp
 mov x2,x1
 mov x1,x0
 adrp x9,md2asm_owned_forecast_listing_descriptor
 ldr w0,[x9,:lo12:md2asm_owned_forecast_listing_descriptor]
 bl md2asm_write_forecast_step_listing
 cbnz w0,.Llisting_native_bad
 ldp x29,x30,[sp],#16
 ret
.Llisting_native_bad:
 mov w0,#126
 b _exit
.size md2asm_step_log_,.-md2asm_step_log_
.section .rodata
.p2align 3
.Llisting_template:
 .ascii " NSTEP ="
 .ascii "      "
 .ascii " STEPO   "
 .ascii "         "
 .byte 10
.data
.p2align 2
.global md2asm_owned_forecast_listing_descriptor
.type md2asm_owned_forecast_listing_descriptor,%object
md2asm_owned_forecast_listing_descriptor:
 .word 1
.size md2asm_owned_forecast_listing_descriptor,4
.section .note.GNU-stack,"",%progbits
