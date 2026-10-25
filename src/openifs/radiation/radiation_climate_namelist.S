/* Contract: skills/md2asm/references/openifs/radiation/runtime_radiation_flux_owners.md. */
#ifndef MD2ASM_RADSEL_ENTRY
#define MD2ASM_RADSEL_ENTRY md2asm_apply_selected_radiation_namelist
#endif
#ifndef MD2ASM_RADSEL_KEY_COUNT
#define MD2ASM_RADSEL_KEY_COUNT 13
#endif
/* Apply the first NAERAD group to a 1072-byte typed radiation selection record. Supported keys below.
 * x0 bounded text,x1 bytes1..262144,x2 record. Return 0/2, no writes on rejection.
 * Scalar integer tokens with optional sign and magnitude0..65535, boolean tokens as in Fortran. Frame 1168 bytes. */
.arch armv8.2-a
.text
.p2align 4
.global MD2ASM_RADSEL_ENTRY
.type MD2ASM_RADSEL_ENTRY,%function
MD2ASM_RADSEL_ENTRY:
 stp x29,x30,[sp,#-96]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 mov x29,sp
 sub sp,sp,#1072
 mov x19,x0
 mov x21,x2
 mov x22,sp
 cbz x0,.Lradsel_bad
 cbz x2,.Lradsel_bad
 cbz x1,.Lradsel_bad
 cmp x1,#64,lsl#12
 b.hi .Lradsel_bad
 tst x2,#7
 b.ne .Lradsel_bad
 adds x20,x0,x1
 b.cs .Lradsel_bad
 adds x9,x2,#1072
 b.cs .Lradsel_bad
 cmp x9,x0
 b.ls .Lradsel_disjoint
 cmp x2,x20
 b.lo .Lradsel_bad
.Lradsel_disjoint:
 mrs x9,fpcr
 cbnz x9,.Lradsel_bad
 mov x9,#0
.Lradsel_copy_in:
 add x12,x21,x9
 ldp x10,x11,[x12]
 add x12,x22,x9
 stp x10,x11,[x12]
 add x9,x9,#16
 cmp x9,#1072
 b.lo .Lradsel_copy_in
 /* The source group marker is the first nonblank token on its line. */
.Lradsel_start_line:
 mov w28,#0
.Lradsel_find_line:
 cmp x19,x20
 b.hs .Lradsel_bad
 ldrb w9,[x19],#1
 add w28,w28,#1
 cmp w9,#10
 b.eq .Lradsel_start_line
 cmp w9,#32
 b.eq .Lradsel_find_line
 cmp w9,#9
 b.eq .Lradsel_find_line
 cmp w9,#13
 b.eq .Lradsel_find_line
 cmp w9,#10
 b.eq .Lradsel_find_line
 cmp w9,#38
 b.ne .Lradsel_skip_line
 cmp w28,#10
 b.hi .Lradsel_skip_line
 add x9,x19,#6
 cmp x9,x20
 b.hs .Lradsel_bad
 adrp x10,.Lradsel_group
 add x10,x10,:lo12:.Lradsel_group
 mov w11,#0
.Lradsel_group_match:
 ldrb w12,[x19,x11]
 ldrb w13,[x10,x11]
 cmp w12,w13
 b.ne .Lradsel_skip_line
 add w11,w11,#1
 cmp w11,#6
 b.lo .Lradsel_group_match
 add x19,x19,#6
 ldrb w9,[x19]
 cmp w9,#32
 b.eq .Lradsel_key
 cmp w9,#9
 b.eq .Lradsel_key
 cmp w9,#13
 b.eq .Lradsel_key
 cmp w9,#10
 b.eq .Lradsel_key
 cmp w9,#47
 b.eq .Lradsel_key
 cmp w9,#44
 b.eq .Lradsel_key
.Lradsel_skip_line:
 cmp x19,x20
 b.hs .Lradsel_bad
 ldrb w9,[x19],#1
 cmp w9,#10
 b.ne .Lradsel_skip_line
 b .Lradsel_start_line
.Lradsel_key:
 mov x0,x19
 mov x1,x20
 bl .Lradsel_skip_blank
 mov x19,x0
 cmp x19,x20
 b.hs .Lradsel_bad
 ldrb w9,[x19]
 cmp w9,#44
 b.ne .Lradsel_key_start
 add x19,x19,#1
 b .Lradsel_key
.Lradsel_key_start:
 cmp w9,#47
 b.eq .Lradsel_finish
 mov x27,x19
.Lradsel_key_scan:
 cmp x19,x20
 b.hs .Lradsel_bad
 ldrb w9,[x19]
 sub w10,w9,#65
 cmp w10,#25
 b.ls .Lradsel_key_next
 sub w10,w9,#97
 cmp w10,#25
 b.ls .Lradsel_key_next
 sub w10,w9,#48
 cmp w10,#9
 b.ls .Lradsel_key_next
 cmp w9,#95
 b.eq .Lradsel_key_next
 cmp w9,#37
 b.ne .Lradsel_key_lookup_call
.Lradsel_key_next:
 add x19,x19,#1
 b .Lradsel_key_scan
.Lradsel_key_lookup_call:
 mov x0,x27
 sub x1,x19,x27
 bl .Lradsel_lookup
 tbnz w0,#31,.Lradsel_bad
 mov w25,w0
 mov w26,w1
 mov w24,w2
 mov x0,x19
 mov x1,x20
 bl .Lradsel_skip_blank
 mov x19,x0
 cmp x19,x20
 b.hs .Lradsel_bad
 ldrb w9,[x19],#1
 cmp w9,#61
 b.ne .Lradsel_bad
 mov x0,x19
 mov x1,x20
 bl .Lradsel_skip_blank
 mov x19,x0
 mov x27,x0
 cmp w26,#2
 b.ne .Lradsel_value_scan
 add x2,x22,x25
 mov w3,w24
 bl .Lradsel_string
 cbnz w1,.Lradsel_bad
 mov x19,x0
 b .Lradsel_key
.Lradsel_value_scan:
 cmp x19,x20
 b.hs .Lradsel_bad
 ldrb w9,[x19]
 cmp w9,#32
 b.eq .Lradsel_value_found
 cmp w9,#9
 b.eq .Lradsel_value_found
 cmp w9,#13
 b.eq .Lradsel_value_found
 cmp w9,#10
 b.eq .Lradsel_value_found
 cmp w9,#44
 b.eq .Lradsel_value_found
 cmp w9,#33
 b.eq .Lradsel_value_found
 cmp w9,#47
 b.eq .Lradsel_value_found
 add x19,x19,#1
 b .Lradsel_value_scan
.Lradsel_value_found:
 mov x0,x27
 sub x1,x19,x27
 cbnz w26,.Lradsel_integer_call
 bl .Lradsel_boolean
 b .Lradsel_value_result
.Lradsel_integer_call:
 bl .Lradsel_integer
.Lradsel_value_result:
 cbnz w1,.Lradsel_bad
 str w0,[x22,x25]
 b .Lradsel_key
.Lradsel_finish:
 mov x9,#0
.Lradsel_copy_out:
 add x12,x22,x9
 ldp x10,x11,[x12]
 add x12,x21,x9
 stp x10,x11,[x12]
 add x9,x9,#16
 cmp x9,#1072
 b.lo .Lradsel_copy_out
 mov w0,#0
 b .Lradsel_return
.Lradsel_bad:
 mov w0,#2
.Lradsel_return:
 add sp,sp,#1072
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp],#96
 ret
.size MD2ASM_RADSEL_ENTRY,.-MD2ASM_RADSEL_ENTRY
/* Local helpers use only caller-saved x0..x17. */
.Lradsel_skip_blank:
 cmp x0,x1
 b.hs .Lradsel_skip_return
 ldrb w9,[x0]
 cmp w9,#32
 b.eq .Lradsel_skip_next
 cmp w9,#9
 b.eq .Lradsel_skip_next
 cmp w9,#13
 b.eq .Lradsel_skip_next
 cmp w9,#10
 b.eq .Lradsel_skip_next
 cmp w9,#33
 b.ne .Lradsel_skip_return
.Lradsel_skip_comment:
 add x0,x0,#1
 cmp x0,x1
 b.hs .Lradsel_skip_return
 ldrb w9,[x0]
 cmp w9,#10
 b.ne .Lradsel_skip_comment
.Lradsel_skip_next:
 add x0,x0,#1
 b .Lradsel_skip_blank
.Lradsel_skip_return:
 ret
.Lradsel_lookup:
 adrp x9,.Lradsel_keys
 add x9,x9,:lo12:.Lradsel_keys
 mov w10,#MD2ASM_RADSEL_KEY_COUNT
.Lradsel_lookup_row:
 ldr w11,[x9,#32]
 cmp x1,x11
 b.ne .Lradsel_lookup_next
 mov x12,#0
.Lradsel_lookup_char:
 ldrb w13,[x0,x12]
 sub w14,w13,#65
 cmp w14,#25
 orr w15,w13,#32
 csel w13,w15,w13,ls
 ldrb w14,[x9,x12]
 cmp w13,w14
 b.ne .Lradsel_lookup_next
 add x12,x12,#1
 cmp x12,x1
 b.lo .Lradsel_lookup_char
 ldp w0,w1,[x9,#36]
 ldr w2,[x9,#44]
 ret
.Lradsel_lookup_next:
 add x9,x9,#48
 subs w10,w10,#1
 b.ne .Lradsel_lookup_row
 mov w0,#-1
 ret
.Lradsel_boolean:
 cbz x1,.Lradsel_token_bad
 ldrb w9,[x0]
 cmp w9,#46
 b.ne .Lradsel_bool_core
 cmp x1,#3
 b.lo .Lradsel_token_bad
 sub x10,x1,#1
 ldrb w9,[x0,x10]
 cmp w9,#46
 b.ne .Lradsel_token_bad
 add x0,x0,#1
 sub x1,x1,#2
.Lradsel_bool_core:
 ldrb w9,[x0]
 orr w9,w9,#32
 cmp w9,#116
 b.eq .Lradsel_true
 cmp w9,#102
 b.ne .Lradsel_token_bad
 mov w15,#0
 adrp x10,.Lradsel_false_text
 add x10,x10,:lo12:.Lradsel_false_text
 mov w11,#5
 b .Lradsel_bool_match
.Lradsel_true:
 mov w15,#1
 adrp x10,.Lradsel_true_text
 add x10,x10,:lo12:.Lradsel_true_text
 mov w11,#4
.Lradsel_bool_match:
 cmp x1,#1
 b.eq .Lradsel_bool_good
 cmp x1,x11
 b.ne .Lradsel_token_bad
 mov x12,#0
.Lradsel_bool_char:
 ldrb w13,[x0,x12]
 orr w13,w13,#32
 ldrb w14,[x10,x12]
 cmp w13,w14
 b.ne .Lradsel_token_bad
 add x12,x12,#1
 cmp x12,x1
 b.lo .Lradsel_bool_char
.Lradsel_bool_good:
 mov w0,w15
 mov w1,#0
 ret
.Lradsel_integer:
 cbz x1,.Lradsel_token_bad
 mov w15,#0
 ldrb w9,[x0]
 cmp w9,#45
 b.eq .Lradsel_integer_negative
 cmp w9,#43
 b.ne .Lradsel_integer_digits
 b .Lradsel_integer_sign
.Lradsel_integer_negative:
 mov w15,#1
.Lradsel_integer_sign:
 add x0,x0,#1
 sub x1,x1,#1
 cbz x1,.Lradsel_token_bad
.Lradsel_integer_digits:
 cmp x1,#5
 b.hi .Lradsel_token_bad
 mov w10,#0
 mov w11,#10
 mov x12,#0
.Lradsel_integer_loop:
 ldrb w9,[x0,x12]
 sub w9,w9,#48
 cmp w9,#9
 b.hi .Lradsel_token_bad
 madd w10,w10,w11,w9
 mov w13,#65535
 cmp w10,w13
 b.hi .Lradsel_token_bad
 add x12,x12,#1
 cmp x12,x1
 b.lo .Lradsel_integer_loop
 neg w11,w10
 cmp w15,#0
 csel w0,w11,w10,ne
 mov w1,#0
 ret
/* Quoted Fortran character value. x2 destination,x3 capacity256. */
.Lradsel_string:
 cmp x0,x1
 b.hs .Lradsel_string_bad
 ldrb w9,[x0],#1
 cmp w9,#39
 b.eq .Lradsel_string_start
 cmp w9,#34
 b.ne .Lradsel_string_bad
.Lradsel_string_start:
 mov x10,#0
 mov x11,#0x2020
 movk x11,#0x2020,lsl#16
 movk x11,#0x2020,lsl#32
 movk x11,#0x2020,lsl#48
.Lradsel_string_blank:
 str x11,[x2,x10]
 add x10,x10,#8
 cmp x10,x3
 b.lo .Lradsel_string_blank
 mov x10,#0
.Lradsel_string_char:
 cmp x0,x1
 b.hs .Lradsel_string_bad
 ldrb w11,[x0],#1
 cbz w11,.Lradsel_string_bad
 cmp w11,#10
 b.eq .Lradsel_string_bad
 cmp w11,#13
 b.eq .Lradsel_string_bad
 cmp w11,w9
 b.ne .Lradsel_string_store
 cmp x0,x1
 b.hs .Lradsel_string_bad
 ldrb w12,[x0]
 cmp w12,w9
 b.ne .Lradsel_string_end
 add x0,x0,#1
.Lradsel_string_store:
 cmp x10,x3
 b.hs .Lradsel_string_bad
 strb w11,[x2,x10]
 add x10,x10,#1
 b .Lradsel_string_char
.Lradsel_string_end:
 cmp w12,#32
 b.eq .Lradsel_string_good
 cmp w12,#9
 b.eq .Lradsel_string_good
 cmp w12,#13
 b.eq .Lradsel_string_good
 cmp w12,#10
 b.eq .Lradsel_string_good
 cmp w12,#44
 b.eq .Lradsel_string_good
 cmp w12,#47
 b.eq .Lradsel_string_good
 cmp w12,#33
 b.ne .Lradsel_string_bad
.Lradsel_string_good:
 mov w1,#0
 ret
.Lradsel_string_bad:
 mov w1,#1
 ret
.Lradsel_token_bad:
 mov w0,#0
 mov w1,#1
 ret
.section .rodata
.Lradsel_group: .ascii "NAERAD"
.Lradsel_true_text: .ascii "true"
.Lradsel_false_text: .ascii "false"
.p2align 4
.Lradsel_keys:
 .ascii "nrproma"
 .zero 25
 .word 7,24,1,0
 .ascii "laer3d"
 .zero 26
 .word 6,28,0,0
 .ascii "crtabledir"
 .zero 22
 .word 10,816,2,256
 .ascii "nhincsol"
 .zero 24
 .word 8,0,1,0
 .ascii "nghgrad"
 .zero 25
 .word 7,4,1,0
 .ascii "lhghg"
 .zero 27
 .word 5,8,0,0
 .ascii "nghgcmip"
 .zero 24
 .word 8,12,1,0
 .ascii "nrcp"
 .zero 28
 .word 4,16,1,0
 .ascii "nscen"
 .zero 27
 .word 5,20,1,0
 .ascii "lepo3ra"
 .zero 25
 .word 7,32,0,0
 .ascii "csolarirradiancefile"
 .zero 12
 .word 20,48,2,256
 .ascii "cghgclimfile"
 .zero 20
 .word 12,304,2,256
 .ascii "cghgtimeseriesfile"
 .zero 14
 .word 18,560,2,256
#ifdef MD2ASM_RAD_OWNER_KEYS
 .ascii "lapproxlwupdate"
 .zero 17
 .word 15,36,0,0
 .ascii "lecompgrid"
 .zero 22
 .word 10,40,0,0
 .ascii "lsrtm"
 .zero 27
 .word 5,44,0,0
#endif
.section .note.GNU-stack,"",%progbits
