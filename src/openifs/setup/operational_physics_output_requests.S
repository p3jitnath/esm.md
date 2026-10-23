/* Qualified live-provider contract: skills/md2asm/references/openifs/setup/operational_model_configuration.md. */
/* Direct operational NAMFPC intake. Contract: skills/md2asm/references/openifs/setup/operational_model_configuration.md.
 * x0 text, x1 bytes1..262144, x2 output12152. Return0 or atomic refusal2.
 * Private stack12384 bytes. No external call or floating-point instruction. */
.text
.p2align 4
.global md2asm_parse_operational_physics_output_requests
.type md2asm_parse_operational_physics_output_requests,%function
md2asm_parse_operational_physics_output_requests:
    stp x29,x30,[sp,#-96]!
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    mov x29,sp
    sub sp,sp,#3,lsl #12
    mov x19,x0
    adds x20,x0,x1
    b.cs .Lbad
    mov x21,x2
    mov x22,sp
    cbz x0,.Lbad
    cbz x2,.Lbad
    cbz x1,.Lbad
    cmp x1,#64,lsl #12
    b.hi .Lbad
    mov x9,#12152
    adds x9,x2,x9
    b.cs .Lbad
    cmp x9,x19
    b.ls .Lno_overlap
    cmp x21,x20
    b.lo .Lbad
.Lno_overlap:
    // Defined source defaults, with unused header bytes set to zero.
    mov x9,#0
    mov x10,#12152
.Lzero:
    str xzr,[x22,x9]
    add x9,x9,#8
    cmp x9,x10
    b.lo .Lzero
    adr x10,.Ldefault_format
    ldr x10,[x10]
    str x10,[x22,#40]
    movz x10,#65024,lsl #32
    movk x10,#16550,lsl #48
    str x10,[x22,#64]
    mov w10,#-9999
    mov x9,#4480
    add x9,x22,x9
    mov w11,#137
.Lphy_default:
    str w10,[x9],#4
    subs w11,w11,#1
    b.ne .Lphy_default
    mov w10,#-9
    mov x9,#5028
    add x9,x22,x9
    mov w11,#137
.Lmodel_default:
    str w10,[x9],#4
    subs w11,w11,#1
    b.ne .Lmodel_default
    adr x12,.Lreal_defaults
    mov x9,#5576
    add x9,x22,x9
    mov w13,#6
.Llevel_family:
    ldr x10,[x12],#8
    mov w11,#137
.Llevel_default:
    str x10,[x9],#8
    subs w11,w11,#1
    b.ne .Llevel_default
    subs w13,w13,#1
    b.ne .Llevel_family
    mov x23,#0
    // POSNAME requires uppercase markers within ten source columns.
.Lfind_new_line:
    mov w15,#0
.Lfind_line:
    cmp x19,x20
    b.hs .Lbad
    ldrb w9,[x19],#1
    add w15,w15,#1
    cmp w9,#32
    b.eq .Lfind_line
    cmp w9,#9
    b.eq .Lfind_line
    cmp w9,#13
    b.eq .Lfind_line
    cmp w9,#10
    b.eq .Lfind_new_line
    cmp w9,#38
    b.ne .Lskip_line
    cmp w15,#10
    b.hi .Lskip_line
    add x9,x19,#6
    cmp x9,x20
    b.hs .Lbad
    adr x10,.Lgroup_name
    mov w11,#0
.Lgroup_match:
    ldrb w12,[x19,x11]
    ldrb w13,[x10,x11]
    cmp w12,w13
    b.ne .Lskip_line
    add w11,w11,#1
    cmp w11,#6
    b.lo .Lgroup_match
    add x19,x19,#6
    ldrb w9,[x19]
    cmp w9,#32
    b.eq .Lnew_key
    cmp w9,#9
    b.eq .Lnew_key
    cmp w9,#13
    b.eq .Lnew_key
    cmp w9,#10
    b.eq .Lnew_key
    cmp w9,#47
    b.eq .Lnew_key
.Lskip_line:
    cmp x19,x20
    b.hs .Lbad
    ldrb w9,[x19],#1
    cmp w9,#10
    b.ne .Lskip_line
    b .Lfind_new_line
.Lnew_key:
    mov x0,x19
    mov x1,x20
    bl .Lskip_space
    mov x19,x0
    cmp x19,x20
    b.hs .Lbad
    ldrb w9,[x19]
    cmp w9,#47
    b.eq .Lfinish
    mov x27,x19
.Lkey_end:
    cmp x19,x20
    b.hs .Lbad
    ldrb w9,[x19]
    orr w10,w9,#32
    sub w10,w10,#97
    cmp w10,#25
    b.ls .Lkey_next
    sub w10,w9,#48
    cmp w10,#9
    b.ls .Lkey_next
    cmp w9,#95
    b.ne .Lkey_lookup_call
.Lkey_next:
    add x19,x19,#1
    b .Lkey_end
.Lkey_lookup_call:
    mov x0,x27
    sub x1,x19,x27
    bl .Lkey_lookup
    tbnz w0,#31,.Lbad
    mov w24,w0
    mov x25,x1
    mov w26,w2
    mov w28,w3
    mov x9,#1
    lsl x9,x9,x24
    tst x23,x9
    b.ne .Lbad
    orr x23,x23,x9
    mov x0,x19
    mov x1,x20
    bl .Lskip_space
    mov x19,x0
    cmp x19,x20
    b.hs .Lbad
    ldrb w9,[x19]
    cmp w9,#40
    b.ne .Loperational_equals
    cmp w28,#1
    b.ls .Lbad
    add x19,x19,#1
    mov x0,x19
    mov x1,x20
    bl .Lskip_space
    mov x19,x0
    cmp x19,x20
    b.hs .Lbad
    ldrb w9,[x19],#1
    cmp w9,#58
    b.ne .Lbad
    mov x0,x19
    mov x1,x20
    bl .Lskip_space
    mov x19,x0
    cmp x19,x20
    b.hs .Lbad
    ldrb w9,[x19],#1
    cmp w9,#41
    b.ne .Lbad
    mov x0,x19
    mov x1,x20
    bl .Lskip_space
    mov x19,x0
    cmp x19,x20
    b.hs .Lbad
.Loperational_equals:
    ldrb w9,[x19],#1
    cmp w9,#61
    b.ne .Lbad
    mov x0,x19
    mov x1,x20
    bl .Lskip_space
    mov x19,x0
    cmp w26,#4
    b.eq .Lformat
    mov w27,#0
    cmp w26,#5
    b.eq .Loperational_false
.Lvalue:
    cmp w27,w28
    b.hs .Lbad
    mov x0,x19
    mov x1,x20
    mov w2,w26
    bl .Lnumber
    cbz w2,.Lbad
    mov x19,x0
    cmp w26,#0
    b.eq .Lcount
    cmp w26,#1
    b.eq .Lcode
    cmp w26,#2
    b.eq .Lmodel
    cmp w24,#29
    b.ne .Loperational_real_valid
    mov x9,#60000
    cmp x1,x9
    b.ne .Lbad
.Loperational_real_valid:
    // Encode an exact integral FP64 number with integer operations.
    mov x0,x1
    mov w1,w3
    bl .Linteger_to_bits
    add x9,x22,x25
    str x0,[x9,x27,lsl #3]
    b .Lnext_value
.Lcount:
    cmp x1,#137
    b.hi .Lbad
    cmp w24,#26
    b.ne .Lstore_int
    cbnz x1,.Lbad
    b .Lstore_int
.Lcode:
    mov x9,#0x7fffffff
    cmp x1,x9
    b.hi .Lbad
    b .Lstore_int
.Lmodel:
    cmp x1,#137
    b.ls .Lstore_int
    cmn x1,#99
    b.eq .Lstore_int
    cmn x1,#9
    b.ne .Lbad
.Lstore_int:
    add x9,x22,x25
    str w1,[x9,x27,lsl #2]
.Lnext_value:
    add w27,w27,#1
    mov x0,x19
    mov x1,x20
    bl .Lskip_space
    mov x19,x0
    cmp x19,x20
    b.hs .Lbad
    ldrb w9,[x19]
    cmp w9,#44
    b.ne .Lvalue_dispatch
    add x19,x19,#1
    mov x0,x19
    mov x1,x20
    bl .Lskip_space
    mov x19,x0
    cmp x19,x20
    b.hs .Lbad
    ldrb w9,[x19]
.Lvalue_dispatch:
    cmp w9,#47
    b.eq .Lfinish
    orr w10,w9,#32
    sub w10,w10,#97
    cmp w10,#25
    b.ls .Lnew_key
    b .Lvalue
.Loperational_false:
    mov w14,#0
    cmp x19,x20
    b.hs .Lbad
    ldrb w9,[x19]
    cmp w9,#46
    b.ne .Loperational_false_body
    mov w14,#1
    add x19,x19,#1
.Loperational_false_body:
    cmp x19,x20
    b.hs .Lbad
    ldrb w9,[x19],#1
    orr w9,w9,#32
    cmp w9,#102
    b.ne .Lbad
    cmp x19,x20
    b.hs .Loperational_false_close
    ldrb w9,[x19]
    orr w9,w9,#32
    cmp w9,#97
    b.ne .Loperational_false_close
    add x9,x19,#4
    cmp x9,x20
    b.hi .Lbad
    adr x10,.Loperational_false_tail
    mov x11,#0
.Loperational_false_compare:
    ldrb w12,[x19,x11]
    orr w12,w12,#32
    ldrb w13,[x10,x11]
    cmp w12,w13
    b.ne .Lbad
    add x11,x11,#1
    cmp x11,#4
    b.lo .Loperational_false_compare
    add x19,x19,#4
.Loperational_false_close:
    cbz w14,.Loperational_false_store
    cmp x19,x20
    b.hs .Lbad
    ldrb w9,[x19],#1
    cmp w9,#46
    b.ne .Lbad
.Loperational_false_store:
    add x9,x22,x25
    str wzr,[x9]
    b .Lnext_value
.Lformat:
    cmp x19,x20
    b.hs .Lbad
    ldrb w9,[x19],#1
    cmp w9,#39
    b.eq .Lformat_quote
    cmp w9,#34
    b.ne .Lbad
.Lformat_quote:
    mov w14,w9
    add x9,x19,#6
    cmp x9,x20
    b.hi .Lbad
    adr x10,.Lmodel_format
    mov w11,#0
.Lformat_compare:
    ldrb w12,[x19,x11]
    ldrb w13,[x10,x11]
    cmp w12,w13
    b.ne .Lbad
    add w11,w11,#1
    cmp w11,#5
    b.lo .Lformat_compare
    add x19,x19,#5
    ldrb w9,[x19],#1
    cmp w9,w14
    b.ne .Lbad
    ldr x9,[x10]
    str x9,[x22,#40]
    mov x0,x19
    mov x1,x20
    bl .Lskip_space
    mov x19,x0
    cmp x19,x20
    b.hs .Lbad
    ldrb w9,[x19]
    cmp w9,#44
    b.ne .Lnew_key
    add x19,x19,#1
    b .Lnew_key
.Lfinish:
    adr x9,.Lmodel_format
    ldr x9,[x9]
    ldr x10,[x22,#40]
    cmp x9,x10
    b.ne .Lbad
    // Every active code must have been supplied and must be in the table domain.
    mov w9,#0
    add x10,x22,#96
.Lcheck_counts:
    ldr w11,[x22,x9,lsl #2]
    mov w12,#0
.Lcheck_codes:
    cmp w12,w11
    b.hs .Lnext_codes
    ldr w13,[x10,x12,lsl #2]
    cbz w13,.Lbad
    cmp w13,#0
    b.lt .Lbad
    add w12,w12,#1
    b .Lcheck_codes
.Lnext_codes:
    add x10,x10,#548
    add w9,w9,#1
    cmp w9,#9
    b.lo .Lcheck_counts
    // Success commits one complete, deterministic internal record.
    mov x9,#0
    mov x10,#12152
.Lcommit:
    ldr x11,[x22,x9]
    str x11,[x21,x9]
    add x9,x9,#8
    cmp x9,x10
    b.lo .Lcommit
    mov w0,#0
    b .Lreturn
.Lbad:
    mov w0,#2
.Lreturn:
    mov sp,x29
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp x29,x30,[sp],#96
    ret
.size md2asm_parse_operational_physics_output_requests,.-md2asm_parse_operational_physics_output_requests

// Return the first byte after spaces, line endings and Fortran comments.
.Lskip_space:
    cmp x0,x1
    b.hs .Lskip_return
    ldrb w3,[x0]
    cmp w3,#32
    b.eq .Lskip_one
    cmp w3,#9
    b.eq .Lskip_one
    cmp w3,#10
    b.eq .Lskip_one
    cmp w3,#13
    b.eq .Lskip_one
    cmp w3,#33
    b.ne .Lskip_return
.Lcomment:
    add x0,x0,#1
    cmp x0,x1
    b.hs .Lskip_return
    ldrb w3,[x0]
    cmp w3,#10
    b.ne .Lcomment
.Lskip_one:
    add x0,x0,#1
    b .Lskip_space
.Lskip_return:
    ret

// x0=name, x1=length; return id, byte offset, kind and capacity.
.Lkey_lookup:
    adr x3,.Lkeys
    mov w4,#0
.Lkey_try:
    ldr w5,[x3,#8]
    cmp x1,x5
    b.ne .Lkey_miss
    ldr x6,[x3]
    add x6,x6,x3
    mov x7,#0
.Lkey_compare:
    ldrb w8,[x0,x7]
    orr w8,w8,#32
    ldrb w9,[x6,x7]
    cmp w8,w9
    b.ne .Lkey_miss
    add x7,x7,#1
    cmp x7,x1
    b.lo .Lkey_compare
    mov w0,w4
    ldr w1,[x3,#12]
    ldp w2,w3,[x3,#16]
    ret
.Lkey_miss:
    add x3,x3,#24
    add w4,w4,#1
    cmp w4,#30
    b.lo .Lkey_try
    mov w0,#-1
    ret

// Parse an integer, or an exactly integral real token for kind 3.
// Return new cursor x0, signed magnitude x1, success w2 and sign w3.
.Lnumber:
    mov w4,w2
    mov w3,#0
    mov x5,#0
    mov w6,#0
    cmp x0,x1
    b.hs .Lnumber_bad
    ldrb w7,[x0]
    cmp w7,#45
    b.ne .Lnumber_plus
    mov w3,#1
    add x0,x0,#1
    b .Lnumber_digits
.Lnumber_plus:
    cmp w7,#43
    b.ne .Lnumber_digits
    add x0,x0,#1
.Lnumber_digits:
    mov x12,#1
    lsl x12,x12,#53
.Ldigit_loop:
    cmp x0,x1
    b.hs .Ldigits_done
    ldrb w7,[x0]
    sub w8,w7,#48
    cmp w8,#9
    b.hi .Ldigits_done
    mov x9,#10
    mul x10,x5,x9
    udiv x11,x10,x9
    cmp x11,x5
    b.ne .Lnumber_bad
    add x5,x10,x8
    cmp x5,x12
    b.hi .Lnumber_bad
    add x0,x0,#1
    add w6,w6,#1
    b .Ldigit_loop
.Ldigits_done:
    cbz w6,.Lnumber_bad
    cmp w4,#3
    b.ne .Lnumber_finish
    cmp x0,x1
    b.hs .Lnumber_finish
    cmp w7,#46
    b.ne .Lexponent
    add x0,x0,#1
.Lfraction:
    cmp x0,x1
    b.hs .Lnumber_finish
    ldrb w7,[x0]
    sub w8,w7,#48
    cmp w8,#9
    b.hi .Lexponent
    cbnz w8,.Lnumber_bad
    add x0,x0,#1
    b .Lfraction
.Lexponent:
    orr w8,w7,#32
    cmp w8,#101
    b.eq .Lexponent_start
    cmp w8,#100
    b.ne .Lnumber_finish
.Lexponent_start:
    add x0,x0,#1
    cmp x0,x1
    b.hs .Lnumber_bad
    mov w13,#0
    ldrb w7,[x0]
    cmp w7,#45
    b.ne .Lexponent_plus
    mov w13,#1
    add x0,x0,#1
    b .Lexponent_digits
.Lexponent_plus:
    cmp w7,#43
    b.ne .Lexponent_digits
    add x0,x0,#1
.Lexponent_digits:
    mov w14,#0
    mov w6,#0
.Lexponent_loop:
    cmp x0,x1
    b.hs .Lexponent_done
    ldrb w7,[x0]
    sub w8,w7,#48
    cmp w8,#9
    b.hi .Lexponent_done
    mov w9,#10
    madd w14,w14,w9,w8
    cmp w14,#15
    b.hi .Lnumber_bad
    add x0,x0,#1
    add w6,w6,#1
    b .Lexponent_loop
.Lexponent_done:
    cbz w6,.Lnumber_bad
    cbz w14,.Lnumber_finish
    mov x9,#10
.Lexponent_apply:
    cbnz w13,.Lexponent_divide
    mul x5,x5,x9
    cmp x5,x12
    b.hi .Lnumber_bad
    b .Lexponent_next
.Lexponent_divide:
    udiv x10,x5,x9
    msub x11,x10,x9,x5
    cbnz x11,.Lnumber_bad
    mov x5,x10
.Lexponent_next:
    subs w14,w14,#1
    b.ne .Lexponent_apply
.Lnumber_finish:
    cmp x0,x1
    b.hs .Lnumber_ok
    ldrb w7,[x0]
    cmp w7,#32
    b.eq .Lnumber_ok
    cmp w7,#9
    b.eq .Lnumber_ok
    cmp w7,#10
    b.eq .Lnumber_ok
    cmp w7,#13
    b.eq .Lnumber_ok
    cmp w7,#44
    b.eq .Lnumber_ok
    cmp w7,#47
    b.eq .Lnumber_ok
    cmp w7,#33
    b.ne .Lnumber_bad
.Lnumber_ok:
    cmp w3,#0
    cneg x1,x5,ne
    mov w2,#1
    ret
.Lnumber_bad:
    mov w2,#0
    ret

// The bounded integer magnitude is at most 2^53, so the FP64 encoding is exact.
.Linteger_to_bits:
    cmp x0,#0
    cneg x2,x0,mi
    cbz x2,.Lbits_zero
    clz x3,x2
    mov x4,#63
    sub x4,x4,x3
    add x5,x4,#1023
    lsl x5,x5,#52
    mov x6,#52
    subs x6,x6,x4
    b.mi .Lbits_right
    lsl x2,x2,x6
    b .Lbits_fraction
.Lbits_right:
    neg x6,x6
    lsr x2,x2,x6
.Lbits_fraction:
    and x2,x2,#0xfffffffffffff
    orr x0,x5,x2
    b .Lbits_sign
.Lbits_zero:
    mov x0,#0
.Lbits_sign:
    orr x0,x0,x1,lsl #63
    ret

.section .rodata
.p2align 3
.Lgroup_name: .ascii "NAMFPC"
.p2align 3
.Ldefault_format: .ascii "GAUSS   "
.Lmodel_format: .ascii "MODEL   "
.Lreal_defaults:
    .quad 0xc022000000000000
    .quad 0xc022000000000000
    .quad 0xc022000000000000
    .quad 0x42029fe50e000000
    .quad 0xc0c3878000000000
    .quad 0xc022000000000000
.p2align 3
.Lkeys:
    .quad .Lkey_0-.
    .word 7,0,0,1
    .quad .Lkey_1-.
    .word 7,4,0,1
    .quad .Lkey_2-.
    .word 7,8,0,1
    .quad .Lkey_3-.
    .word 7,12,0,1
    .quad .Lkey_4-.
    .word 7,16,0,1
    .quad .Lkey_5-.
    .word 7,20,0,1
    .quad .Lkey_6-.
    .word 7,24,0,1
    .quad .Lkey_7-.
    .word 6,28,0,1
    .quad .Lkey_8-.
    .word 6,32,0,1
    .quad .Lkey_9-.
    .word 7,96,1,137
    .quad .Lkey_10-.
    .word 7,644,1,137
    .quad .Lkey_11-.
    .word 7,1192,1,137
    .quad .Lkey_12-.
    .word 7,1740,1,137
    .quad .Lkey_13-.
    .word 7,2288,1,137
    .quad .Lkey_14-.
    .word 7,2836,1,137
    .quad .Lkey_15-.
    .word 7,3384,1,137
    .quad .Lkey_16-.
    .word 6,3932,1,137
    .quad .Lkey_17-.
    .word 6,4480,1,137
    .quad .Lkey_18-.
    .word 6,5028,2,137
    .quad .Lkey_19-.
    .word 5,5576,3,137
    .quad .Lkey_20-.
    .word 5,6672,3,137
    .quad .Lkey_21-.
    .word 6,7768,3,137
    .quad .Lkey_22-.
    .word 6,8864,3,137
    .quad .Lkey_23-.
    .word 5,9960,3,137
    .quad .Lkey_24-.
    .word 5,11056,3,137
    .quad .Lkey_25-.
    .word 6,40,4,1
    .quad .Lkey_26-.
    .word 6,48,0,1
    .quad .Lkey_27-.
    .word 4,52,5,1
    .quad .Lkey_28-.
    .word 8,56,5,1
    .quad .Lkey_29-.
    .word 7,64,3,1
.Lkey_0: .ascii "nfp3dfs"
.Lkey_1: .ascii "nfp3dfp"
.Lkey_2: .ascii "nfp3dfh"
.Lkey_3: .ascii "nfp3dft"
.Lkey_4: .ascii "nfp3dfv"
.Lkey_5: .ascii "nfp3dfi"
.Lkey_6: .ascii "nfp3dff"
.Lkey_7: .ascii "nfp2df"
.Lkey_8: .ascii "nfpphy"
.Lkey_9: .ascii "mfp3dfs"
.Lkey_10: .ascii "mfp3dfp"
.Lkey_11: .ascii "mfp3dfh"
.Lkey_12: .ascii "mfp3dft"
.Lkey_13: .ascii "mfp3dfv"
.Lkey_14: .ascii "mfp3dfi"
.Lkey_15: .ascii "mfp3dff"
.Lkey_16: .ascii "mfp2df"
.Lkey_17: .ascii "mfpphy"
.Lkey_18: .ascii "nrfp3s"
.Lkey_19: .ascii "rfp3p"
.Lkey_20: .ascii "rfp3h"
.Lkey_21: .ascii "rfp3th"
.Lkey_22: .ascii "rfp3pv"
.Lkey_23: .ascii "rfp3i"
.Lkey_24: .ascii "rfp3f"
.Lkey_25: .ascii "cfpfmt"

.Lkey_26: .ascii "nfpcli"
.Lkey_27: .ascii "lfpq"
.Lkey_28: .ascii "ltracefp"
.Lkey_29: .ascii "rfpcorr"
.Loperational_false_tail: .ascii "alse"

.section .note.GNU-stack,"",%progbits
