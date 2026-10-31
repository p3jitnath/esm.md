/* Release complete pages of private scratch after all consumers finish.
 * Private ABI: x0 is the child return word; x1 points to the 128-byte owner.
 * The caller checks the selected child, supported case and completed use.
 * Owner bytes 40 and 48 hold addresses; bytes 64 and 72 hold byte capacities.
 * Each range belongs to a separate allocation. Keep its first and last pages.
 * Preserve x0, x18, saved registers, errno, FPCR, FPSR and stack alignment.
 * Linux AArch64 system call 233 requests page release with advice value 4.
 * No floating-point arithmetic is used. The caller keeps exclusive ownership.
 */
.arch armv8.2-a+simd
.text
.p2align 4
.global md2asm_discard_completed_transport_private_pages
.type md2asm_discard_completed_transport_private_pages,%function
md2asm_discard_completed_transport_private_pages:
 stp x29,x30,[sp,#-128]!
 mov x29,sp
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 stp x22,x23,[sp,#48]
 stp x24,x25,[sp,#64]
 str x0,[sp,#80]
 mov x19,x1
 mrs x21,fpcr
 mrs x22,fpsr
 bl __errno_location
 mov x23,x0
 ldr w24,[x23]
 bl getpagesize
 sxtw x20,w0
 cmp x20,#0
 b.le .Ldiscard_restore
 sub x9,x20,#1
 tst x20,x9
 b.ne .Ldiscard_restore
 mov x25,#40
.Ldiscard_next:
 ldr x0,[x19,x25]
 add x9,x25,#24
 ldr x1,[x19,x9]
 cbz x0,.Ldiscard_advance
 cbz x1,.Ldiscard_advance
 adds x3,x0,x1
 b.cs .Ldiscard_advance
 sub x4,x20,#1
 bic x0,x0,x4
 adds x0,x0,x20
 b.cs .Ldiscard_advance
 sub x3,x3,#1
 bic x3,x3,x4
 cmp x3,x0
 b.ls .Ldiscard_advance
 sub x1,x3,x0
 mov w2,#4
 mov x8,#233
 svc #0
.Ldiscard_advance:
 add x25,x25,#8
 cmp x25,#56
 b.lo .Ldiscard_next
.Ldiscard_restore:
 str w24,[x23]
 msr fpcr,x21
 msr fpsr,x22
 ldr x0,[sp,#80]
 ldp x18,x19,[sp,#16]
 ldp x20,x21,[sp,#32]
 ldp x22,x23,[sp,#48]
 ldp x24,x25,[sp,#64]
 ldp x29,x30,[sp],#128
 ret
.size md2asm_discard_completed_transport_private_pages,.-md2asm_discard_completed_transport_private_pages
.section .note.GNU-stack,"",%progbits
