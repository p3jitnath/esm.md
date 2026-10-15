/* Raw file services and exact original four-byte GRIB record framing.
 * Contract: skills/md2asm/references/openifs/output/grib_record_io.md. Source-owned padding is space0x20.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_open_grib_output
.type md2asm_open_grib_output,%function
md2asm_open_grib_output:
 cbz x0,.Lopen_invalid
 cbz x1,.Lopen_invalid
 cmp x1,#256
 b.hi .Lopen_invalid
 cmp x2,#1
 b.hi .Lopen_invalid
 mov x9,x1
.Lopen_trim:
 sub x9,x9,#1
 ldrb w10,[x0,x9]
 cmp w10,#32
 b.ne .Lopen_nonempty
 cbnz x9,.Lopen_trim
 b .Lopen_invalid
.Lopen_nonempty:
 add x9,x9,#1
 sub sp,sp,#272
 mov x10,#0
.Lopen_copy:
 ldrb w11,[x0,x10]
 cbz w11,.Lopen_embedded_zero
 strb w11,[sp,x10]
 add x10,x10,#1
 cmp x10,x9
 b.ne .Lopen_copy
 strb wzr,[sp,x9]
 mov x9,x2
 mov x0,#-100
 mov x1,sp
 mov x2,#1089
 cbz x9,.Lopen_call
 mov x2,#577
.Lopen_call:
 mov x3,#438
 mov x8,#56
 svc #0
 add sp,sp,#272
 ret
.Lopen_embedded_zero:
 add sp,sp,#272
.Lopen_invalid:
 mov x0,#-22
 ret
.size md2asm_open_grib_output,.-md2asm_open_grib_output
.p2align 4
.global md2asm_write_grib_record
.type md2asm_write_grib_record,%function
md2asm_write_grib_record:
 tbnz w0,#31,.Lwrite_invalid
 cbz x1,.Lwrite_invalid
 cmp x2,#16
 b.lo .Lwrite_invalid
 mov x9,#1048576
 cmp x2,x9
 b.hi .Lwrite_invalid
 ldr w9,[x1]
 movz w10,#0x5247
 movk w10,#0x4249,lsl#16
 cmp w9,w10
 b.ne .Lwrite_invalid
 ldrb w9,[x1,#7]
 cmp w9,#1
 b.eq .Lwrite_grib1
 cmp w9,#2
 b.ne .Lwrite_invalid
 ldr x9,[x1,#8]
 rev x9,x9
 b .Lwrite_length
.Lwrite_grib1:
 ldrb w9,[x1,#4]
 ldrb w10,[x1,#5]
 ldrb w11,[x1,#6]
 lsl x9,x9,#16
 orr x9,x9,x10,lsl#8
 orr x9,x9,x11
.Lwrite_length:
 cmp x9,x2
 b.ne .Lwrite_invalid
 add x9,x1,x2
 sub x9,x9,#4
 ldr w9,[x9]
 movz w10,#0x3737
 movk w10,#0x3737,lsl#16
 cmp w9,w10
 b.ne .Lwrite_invalid
 mov x11,x0
 mov x12,x1
 mov x13,x2
 neg x14,x2
 and x14,x14,#3
.Lwrite_message:
 mov x0,x11
 mov x1,x12
 mov x2,x13
 mov x8,#64
 svc #0
 cmp x0,#0
 b.lt .Lwrite_negative
 b.eq .Lwrite_zero
 add x12,x12,x0
 subs x13,x13,x0
 b.ne .Lwrite_message
 cbz x14,.Lwrite_success
 adrp x12,.Lrecord_spaces
 add x12,x12,:lo12:.Lrecord_spaces
 mov x13,x14
 mov x14,#0
 b .Lwrite_message
.Lwrite_negative:
 cmn x0,#4
 b.eq .Lwrite_message
 ret
.Lwrite_zero:
 mov x0,#-5
 ret
.Lwrite_success:
 mov x0,#0
 ret
.Lwrite_invalid:
 mov x0,#-22
 ret
.size md2asm_write_grib_record,.-md2asm_write_grib_record
.p2align 4
.global md2asm_close_grib_output
.type md2asm_close_grib_output,%function
md2asm_close_grib_output:
 mov x8,#57
 svc #0
 ret
.size md2asm_close_grib_output,.-md2asm_close_grib_output
.section .rodata
.Lrecord_spaces: .byte 32,32,32
.section .note.GNU-stack,"",%progbits
