/* Selected SUFPOFNAME + GET_CLINC route, no PTSTEP argument.
 * x0 source256, x1 output256; w2 int32 step, w3 signed digits, w4 NTIMEFMT.
 * No allocation, Fortran formatting service or floating-point arithmetic.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_make_output_name
.type md2asm_make_output_name,%function
md2asm_make_output_name:
 cmp w3,#0
 cset w8,gt
 cneg w6,w3,lt
 cbz w8,.Lname_plain_digits
 cmp w6,#6
 b.hi .Lname_reject
 cmp w4,#2
 b.hi .Lname_reject
 mov w9,#3
 madd w7,w4,w9,w6
 add w7,w7,#1
 b .Lname_trim
.Lname_plain_digits:
 cmp w6,#16
 b.hi .Lname_reject
 mov w7,w6
.Lname_trim:
 mov x5,#256
.Lname_trim_one:
 cbz x5,.Lname_trimmed
 sub x9,x5,#1
 ldrb w10,[x0,x9]
 cmp w10,#32
 b.ne .Lname_trimmed
 sub x5,x5,#1
 b .Lname_trim_one
.Lname_trimmed:
 add x17,x5,x7
 cmp x17,#256
 b.hi .Lname_reject
 mov x9,#0x2020
 movk x9,#0x2020,lsl #16
 movk x9,#0x2020,lsl #32
 movk x9,#0x2020,lsl #48
 mov x10,x1
 mov x11,#32
.Lname_pad_output:
 str x9,[x10],#8
 subs x11,x11,#1
 b.ne .Lname_pad_output
 mov x9,#0
.Lname_copy_prefix:
 cmp x9,x5
 b.hs .Lname_prefix_ready
 ldrb w10,[x0,x9]
 strb w10,[x1,x9]
 add x9,x9,#1
 b .Lname_copy_prefix
.Lname_prefix_ready:
 add x10,x1,x5
 cbz w8,.Lname_digits_start
 mov w9,#'+'
 strb w9,[x10],#1
.Lname_digits_start:
 mov w11,w2
 cmp w2,#0
 cset w15,lt
 cbz w8,.Lname_overflow_ready
 mov w9,#0x423f
 movk w9,#0xf,lsl #16
 cmp w2,w9
 cset w9,gt
 orr w15,w15,w9
.Lname_overflow_ready:
 mov w12,w6
 mov w16,#10
.Lname_decimal:
 cbz w12,.Lname_decimal_done
 sub w12,w12,#1
 cbnz w15,.Lname_star
 udiv w13,w11,w16
 msub w14,w13,w16,w11
 add w14,w14,#'0'
 mov w11,w13
 b .Lname_digit_store
.Lname_star:
 mov w14,#'*'
.Lname_digit_store:
 strb w14,[x10,x12]
 b .Lname_decimal
.Lname_decimal_done:
 cbz w8,.Lname_count
 add x10,x10,x6
 cbz w4,.Lname_count
 mov w9,#':'
 mov w11,#'0'
 strb w9,[x10]
 strb w11,[x10,#1]
 strb w11,[x10,#2]
 cmp w4,#2
 b.ne .Lname_count
 strb w9,[x10,#3]
 strb w11,[x10,#4]
 strb w11,[x10,#5]
.Lname_count:
 adrp x9,md2asm_output_header_counters
 add x9,x9,:lo12:md2asm_output_header_counters
 ldr x10,[x9,#8]
 add x10,x10,#1
 str x10,[x9,#8]
 ret
.size md2asm_make_output_name,.-md2asm_make_output_name
.global md2asm_output_header_count_get
.type md2asm_output_header_count_get,%function
md2asm_output_header_count_get:
 cmp x0,#2
 b.hs .Lname_zero_count
 adrp x9,md2asm_output_header_counters
 add x9,x9,:lo12:md2asm_output_header_counters
 ldr x0,[x9,x0,lsl #3]
 ret
.Lname_zero_count:
 mov x0,#0
 ret
.size md2asm_output_header_count_get,.-md2asm_output_header_count_get
.Lname_reject:
 mov x0,#116
 mov x8,#94
 svc #0
 brk #0
.bss
.p2align 3
.hidden md2asm_output_header_counters
.global md2asm_output_header_counters
md2asm_output_header_counters: .zero 16
.section .note.GNU-stack,"",%progbits
