/* Initialize the two scalar settings from SU_COUP_COM.
 * See skills/md2asm/references/openifs/setup/runtime_coupling_common_controls.md.
 * X0 is text, X1 its byte count, X2 the 336-byte record and X3 capacity.
 * Status W0 is zero on success or two on input refusal.
 * Only NVCOM at byte 0 and LOMLDTH at byte 264 can change. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_runtime_coupling_common_controls
.type md2asm_initialize_runtime_coupling_common_controls,%function
md2asm_initialize_runtime_coupling_common_controls:
 stp x29,x30,[sp,#-96]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 mov x29,sp
 cbz x0,.Lnamcom_bad
 cbz x1,.Lnamcom_bad
 cbz x2,.Lnamcom_bad
 cmp x1,#64,lsl#12
 b.hi .Lnamcom_bad
 cmp x3,#336
 b.lo .Lnamcom_bad
 tst x2,#7
 b.ne .Lnamcom_bad
 adds x20,x0,x1
 b.cs .Lnamcom_bad
 adds x9,x2,#336
 b.cs .Lnamcom_bad
 cmp x9,x0
 b.ls .Lnamcom_disjoint
 cmp x2,x20
 b.lo .Lnamcom_bad
.Lnamcom_disjoint:
 mov x19,x0
 mov x21,x2
 mov x22,x0
 mov w23,#2
 mov w24,#0
/* The selected header is the first nonblank token of a text line. */
.Lnamcom_find_line:
 cmp x22,x20
 b.hs .Lnamcom_bad
 ldrb w9,[x22]
 cmp w9,#32
 b.eq .Lnamcom_find_blank
 cmp w9,#9
 b.eq .Lnamcom_find_blank
 cmp w9,#13
 b.eq .Lnamcom_find_blank
 cmp w9,#10
 b.eq .Lnamcom_find_blank
 cmp w9,#38
 b.ne .Lnamcom_skip_line
 add x9,x22,#7
 cmp x9,x20
 b.hs .Lnamcom_bad
 add x0,x22,#1
 mov x1,#6
 adr x2,.Lnamcom_group_name
 bl .Lnamcom_match_name
 cbnz w0,.Lnamcom_skip_line
 ldrb w9,[x22,#7]
 cmp w9,#32
 b.eq .Lnamcom_header_found
 cmp w9,#9
 b.eq .Lnamcom_header_found
 cmp w9,#13
 b.eq .Lnamcom_header_found
 cmp w9,#10
 b.eq .Lnamcom_header_found
 cmp w9,#33
 b.eq .Lnamcom_header_found
 cmp w9,#47
 b.eq .Lnamcom_header_found
/* A longer identifier names another group. Other punctuation is refused. */
 bic w10,w9,#0x20
 sub w10,w10,#65
 cmp w10,#25
 b.ls .Lnamcom_skip_line
 sub w10,w9,#48
 cmp w10,#9
 b.ls .Lnamcom_skip_line
 cmp w9,#95
 b.eq .Lnamcom_skip_line
 b .Lnamcom_bad
.Lnamcom_find_blank:
 add x22,x22,#1
 b .Lnamcom_find_line
.Lnamcom_skip_line:
 cmp x22,x20
 b.hs .Lnamcom_bad
 ldrb w9,[x22],#1
 cmp w9,#10
 b.ne .Lnamcom_skip_line
 b .Lnamcom_find_line
.Lnamcom_header_found:
 add x22,x22,#7
.Lnamcom_key:
 mov x0,x22
 mov x1,x20
 bl .Lnamcom_skip_space
 mov x22,x0
 cmp x22,x20
 b.hs .Lnamcom_bad
 ldrb w9,[x22]
 cmp w9,#47
 b.eq .Lnamcom_success
 cmp w9,#44
 b.ne .Lnamcom_key_start
 add x22,x22,#1
 b .Lnamcom_key
.Lnamcom_key_start:
 mov x27,x22
.Lnamcom_key_scan:
 cmp x22,x20
 b.hs .Lnamcom_bad
 ldrb w9,[x22]
 bic w10,w9,#0x20
 sub w10,w10,#65
 cmp w10,#25
 b.ls .Lnamcom_key_next
 sub w10,w9,#48
 cmp w10,#9
 b.ls .Lnamcom_key_next
 cmp w9,#95
 b.ne .Lnamcom_key_found
.Lnamcom_key_next:
 add x22,x22,#1
 b .Lnamcom_key_scan
.Lnamcom_key_found:
 sub x28,x22,x27
 cmp x28,#5
 b.ne .Lnamcom_logical_key
 mov x0,x27
 mov x1,#5
 adr x2,.Lnamcom_NVCOM
 bl .Lnamcom_match_name
 cbnz w0,.Lnamcom_bad
 mov w25,#0
 b .Lnamcom_equal
.Lnamcom_logical_key:
 cmp x28,#7
 b.ne .Lnamcom_bad
 mov x0,x27
 mov x1,#7
 adr x2,.Lnamcom_LOMLDTH
 bl .Lnamcom_match_name
 cbnz w0,.Lnamcom_bad
 mov w25,#1
.Lnamcom_equal:
 mov x0,x22
 mov x1,x20
 bl .Lnamcom_skip_space
 mov x22,x0
 cmp x22,x20
 b.hs .Lnamcom_bad
 ldrb w9,[x22],#1
 cmp w9,#61
 b.ne .Lnamcom_bad
 mov x0,x22
 mov x1,x20
 bl .Lnamcom_skip_space
 mov x22,x0
 cmp x22,x20
 b.hs .Lnamcom_bad
 ldrb w9,[x22]
 cmp w9,#47
 b.eq .Lnamcom_success
 cmp w9,#44
 b.ne .Lnamcom_value_start
/* A null scalar leaves its latest private value unchanged. */
 add x22,x22,#1
 b .Lnamcom_key
.Lnamcom_value_start:
 mov x27,x22
.Lnamcom_value_scan:
 cmp x22,x20
 b.hs .Lnamcom_bad
 ldrb w9,[x22]
 cmp w9,#32
 b.eq .Lnamcom_value_found
 cmp w9,#9
 b.eq .Lnamcom_value_found
 cmp w9,#13
 b.eq .Lnamcom_value_found
 cmp w9,#10
 b.eq .Lnamcom_value_found
 cmp w9,#44
 b.eq .Lnamcom_value_found
 cmp w9,#33
 b.eq .Lnamcom_value_found
 cmp w9,#47
 b.eq .Lnamcom_value_found
 add x22,x22,#1
 b .Lnamcom_value_scan
.Lnamcom_value_found:
 cmp x22,x27
 b.eq .Lnamcom_bad
 mov x0,x27
 mov x1,x22
 cbnz w25,.Lnamcom_read_logical
 bl .Lnamcom_parse_integer
 cbnz w1,.Lnamcom_bad
 mov w23,w0
 b .Lnamcom_key
.Lnamcom_read_logical:
 sub x1,x1,x0
 bl .Lnamcom_parse_logical
 cbnz w1,.Lnamcom_bad
 mov w24,w0
 b .Lnamcom_key
.Lnamcom_success:
 str w23,[x21]
 str w24,[x21,#264]
 mov w0,#0
 b .Lnamcom_return
.Lnamcom_bad:
 mov w0,#2
.Lnamcom_return:
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp],#96
 ret
.size md2asm_initialize_runtime_coupling_common_controls,.-md2asm_initialize_runtime_coupling_common_controls
/* Compare a bounded ASCII name under case folding. */
.Lnamcom_match_name:
 mov x9,#0
.Lnamcom_match_loop:
 ldrb w10,[x0,x9]
 bic w10,w10,#0x20
 ldrb w11,[x2,x9]
 cmp w10,w11
 b.ne .Lnamcom_match_bad
 add x9,x9,#1
 cmp x9,x1
 b.lo .Lnamcom_match_loop
 mov w0,#0
 ret
.Lnamcom_match_bad:
 mov w0,#1
 ret
/* Return the first nonblank, noncomment byte, bounded by X1. */
.Lnamcom_skip_space:
 cmp x0,x1
 b.hs .Lnamcom_space_return
 ldrb w9,[x0]
 cmp w9,#32
 b.eq .Lnamcom_space_next
 cmp w9,#9
 b.eq .Lnamcom_space_next
 cmp w9,#13
 b.eq .Lnamcom_space_next
 cmp w9,#10
 b.eq .Lnamcom_space_next
 cmp w9,#33
 b.ne .Lnamcom_space_return
.Lnamcom_comment:
 add x0,x0,#1
 cmp x0,x1
 b.hs .Lnamcom_space_return
 ldrb w9,[x0]
 cmp w9,#10
 b.ne .Lnamcom_comment
.Lnamcom_space_next:
 add x0,x0,#1
 b .Lnamcom_skip_space
.Lnamcom_space_return:
 ret
/* Full signed 32-bit decimal. Check the limit before every accumulation. */
.Lnamcom_parse_integer:
 mov x9,x0
 mov x10,x1
 mov x11,#0
 mov w14,#0
 ldrb w16,[x9]
 cmp w16,#45
 b.ne .Lnamcom_integer_plus
 mov w14,#1
 add x9,x9,#1
 b .Lnamcom_integer_first
.Lnamcom_integer_plus:
 cmp w16,#43
 b.ne .Lnamcom_integer_first
 add x9,x9,#1
.Lnamcom_integer_first:
 cmp x9,x10
 b.hs .Lnamcom_integer_bad
 movz x12,#0xcccc
 movk x12,#0x0ccc,lsl#16
 add w13,w14,#7
 mov x15,#10
.Lnamcom_integer_digit:
 ldrb w16,[x9],#1
 sub w16,w16,#48
 cmp w16,#9
 b.hi .Lnamcom_integer_bad
 cmp x11,x12
 b.hi .Lnamcom_integer_bad
 b.ne .Lnamcom_integer_accumulate
 cmp w16,w13
 b.hi .Lnamcom_integer_bad
.Lnamcom_integer_accumulate:
 madd x11,x11,x15,x16
 cmp x9,x10
 b.lo .Lnamcom_integer_digit
 mov w0,w11
 cmp w14,#0
 cneg w0,w0,ne
 mov w1,#0
 ret
.Lnamcom_integer_bad:
 mov w1,#2
 ret
/* Ordinary single-letter/full-word logical, optionally enclosed by dots. */
.Lnamcom_parse_logical:
 mov x9,x0
 mov x10,x1
 ldrb w11,[x9]
 cmp w11,#46
 b.ne .Lnamcom_logical_kind
 cmp x10,#3
 b.lo .Lnamcom_logical_bad
 sub x12,x10,#1
 ldrb w11,[x9,x12]
 cmp w11,#46
 b.ne .Lnamcom_logical_bad
 add x9,x9,#1
 sub x10,x10,#2
.Lnamcom_logical_kind:
 ldrb w11,[x9]
 bic w11,w11,#0x20
 cmp w11,#84
 b.eq .Lnamcom_logical_true
 cmp w11,#70
 b.ne .Lnamcom_logical_bad
 mov w13,#0
 cmp x10,#1
 b.eq .Lnamcom_logical_ok
 cmp x10,#5
 b.ne .Lnamcom_logical_bad
 adr x12,.Lnamcom_FALSE
 b .Lnamcom_logical_compare_start
.Lnamcom_logical_true:
 mov w13,#1
 cmp x10,#1
 b.eq .Lnamcom_logical_ok
 cmp x10,#4
 b.ne .Lnamcom_logical_bad
 adr x12,.Lnamcom_TRUE
.Lnamcom_logical_compare_start:
 mov x14,#0
.Lnamcom_logical_compare:
 ldrb w11,[x9,x14]
 bic w11,w11,#0x20
 ldrb w15,[x12,x14]
 cmp w11,w15
 b.ne .Lnamcom_logical_bad
 add x14,x14,#1
 cmp x14,x10
 b.lo .Lnamcom_logical_compare
.Lnamcom_logical_ok:
 mov w0,w13
 mov w1,#0
 ret
.Lnamcom_logical_bad:
 mov w1,#2
 ret
.section .rodata
.Lnamcom_group_name: .ascii "NAMCOM"
.Lnamcom_NVCOM: .ascii "NVCOM"
.Lnamcom_LOMLDTH: .ascii "LOMLDTH"
.Lnamcom_TRUE: .ascii "TRUE"
.Lnamcom_FALSE: .ascii "FALSE"
.section .note.GNU-stack,"",%progbits
