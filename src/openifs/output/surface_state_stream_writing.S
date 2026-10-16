/* Complete owned surface stream, revision 1.
 * int md2asm_write_selected_surface_state(w0=fd,x1=TSURF18224,
 * x2=trajectory408,x3=descriptions46080). All owners must remain live.
 * Emits SS104OW1, three records, then104 address/size/payload records.
 * Return0 after all bytes,1 after invalid basic input or write failure.
 * Private Linux write service;112-byte aligned frame; no allocation.
 * Contract: skills/md2asm/references/openifs/output/surface_state_stream_writing.md. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_write_selected_surface_state
.type md2asm_write_selected_surface_state,%function
md2asm_write_selected_surface_state:
 tbnz w0,#31,.Lsw_invalid
 cbz x1,.Lsw_invalid
 cbz x2,.Lsw_invalid
 cbz x3,.Lsw_invalid
 orr x9,x1,x2
 orr x9,x9,x3
 tst x9,#7
 b.ne .Lsw_invalid
 sub sp,sp,#112
 stp x29,x30,[sp]
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 stp x22,x23,[sp,#48]
 stp x24,x25,[sp,#64]
 stp x26,x27,[sp,#80]
 str x28,[sp,#96]
 mov x29,sp
 mov w19,w0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 adrp x1,.Lsw_magic
 add x1,x1,:lo12:.Lsw_magic
 mov x2,#8
 bl .Lsw_write
 cbnz w0,.Lsw_return
 mov x1,x20
 mov x2,#18224
 bl .Lsw_write
 cbnz w0,.Lsw_return
 mov x1,x21
 mov x2,#408
 bl .Lsw_write
 cbnz w0,.Lsw_return
 mov x1,x22
 mov x2,#46080
 bl .Lsw_write
 cbnz w0,.Lsw_return
 adrp x23,.Lsw_metadata
 add x23,x23,:lo12:.Lsw_metadata
 mov w24,#34
.Lsw_group:
 ldr w9,[x23]
 ldr x25,[x20,w9,uxtw]
 mov x0,x25
 ldr w1,[x23,#4]
 bl .Lsw_owner
 cbnz w0,.Lsw_return
 ldr w9,[x23,#8]
 cmp w9,#3
 b.ne .Lsw_next_group
 ldr w26,[x23,#12]
 mov x27,x25
 cbz w26,.Lsw_next_group
.Lsw_layered:
 mov w28,#0
.Lsw_layer_owner:
 add x9,x27,#32
 add x9,x9,x28,lsl#6
 ldr x0,[x9]
 ldr x10,[x9,#16]
 ldr x11,[x9,#56]
 mul x1,x10,x11
 bl .Lsw_owner
 cbnz w0,.Lsw_return
 add w28,w28,#1
 cmp w28,#4
 b.ne .Lsw_layer_owner
 add x27,x27,#288
 subs w26,w26,#1
 b.ne .Lsw_layered
.Lsw_next_group:
 add x23,x23,#16
 subs w24,w24,#1
 b.ne .Lsw_group
 adrp x23,.Lsw_numerics
 add x23,x23,:lo12:.Lsw_numerics
 mov w24,#34
.Lsw_numeric:
 ldp w9,w1,[x23],#8
 ldr x0,[x20,w9,uxtw]
 bl .Lsw_owner
 cbnz w0,.Lsw_return
 subs w24,w24,#1
 b.ne .Lsw_numeric
 mov w0,#0
.Lsw_return:
 ldp x29,x30,[sp]
 ldp x18,x19,[sp,#16]
 ldp x20,x21,[sp,#32]
 ldp x22,x23,[sp,#48]
 ldp x24,x25,[sp,#64]
 ldp x26,x27,[sp,#80]
 ldr x28,[sp,#96]
 add sp,sp,#112
 ret
.Lsw_invalid:
 mov w0,#1
 ret
.size md2asm_write_selected_surface_state,.-md2asm_write_selected_surface_state
/* Header words retain the true owner address and logical byte extent. */
.Lsw_owner:
 sub sp,sp,#32
 str x30,[sp]
 stp x0,x1,[sp,#16]
 add x1,sp,#16
 mov x2,#16
 bl .Lsw_write
 cbnz w0,.Lsw_owner_done
 ldp x1,x2,[sp,#16]
 bl .Lsw_write
.Lsw_owner_done:
 ldr x30,[sp]
 add sp,sp,#32
 ret
/* x1 bytes, x2 extent; x19 holds the caller's descriptor. */
.Lsw_write:
 cbz x2,.Lsw_written
.Lsw_write_more:
 mov w0,w19
 mov w8,#64
 svc #0
 cmp x0,#0
 b.le .Lsw_write_failed
 add x1,x1,x0
 subs x2,x2,x0
 b.ne .Lsw_write_more
.Lsw_written:
 mov w0,#0
 ret
.Lsw_write_failed:
 mov w0,#1
 ret
.section .rodata
.p2align 3
.Lsw_magic:
 .ascii "SS104OW1"
.Lsw_metadata:
 .word 5968,199872,3,3
 .word 6272,199872,3,5
 .word 6568,44416,2,7
 .word 6848,44416,2,2
 .word 7136,44416,2,0
 .word 7432,199872,3,0
 .word 7696,199872,3,0
 .word 7936,44416,2,0
 .word 8176,44416,2,0
 .word 9792,44416,2,38
 .word 10048,44416,2,0
 .word 10368,44416,2,0
 .word 10648,44416,2,5
 .word 10936,44416,2,0
 .word 11224,44416,2,0
 .word 11512,44416,2,0
 .word 11776,44416,2,0
 .word 12040,44416,2,0
 .word 12424,199872,3,0
 .word 18152,44416,2,0
 .word 14704,44416,2,272
 .word 15072,199872,3,0
 .word 15312,44416,2,1
 .word 15624,44416,2,6
 .word 16040,44416,2,0
 .word 16568,0,3,0
 .word 8448,0,3,0
 .word 8720,0,3,0
 .word 16304,0,3,0
 .word 17824,288,3,1
 .word 16840,0,3,0
 .word 17080,0,2,0
 .word 17320,44416,2,0
 .word 17560,44416,2,0
.Lsw_numerics:
 .word 5744,396288
 .word 6032,825600
 .word 6336,231168
 .word 6632,66048
 .word 6912,0
 .word 7200,0
 .word 7496,0
 .word 7760,0
 .word 8000,0
 .word 8784,627456
 .word 9856,0
 .word 10112,0
 .word 10432,82560
 .word 10712,0
 .word 11040,0
 .word 11288,0
 .word 11576,0
 .word 11840,0
 .word 12104,0
 .word 12488,4491264
 .word 14856,0
 .word 15136,16512
 .word 15448,99072
 .word 15752,0
 .word 16104,0
 .word 16640,0
 .word 16904,0
 .word 17144,0
 .word 17384,0
 .word 17624,313728
 .word 16368,0
 .word 17888,0
 .word 8240,0
 .word 8512,0
.section .note.GNU-stack,"",%progbits
