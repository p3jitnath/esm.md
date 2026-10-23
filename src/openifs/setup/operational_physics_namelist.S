/* Contract: skills/md2asm/references/openifs/setup/operational_physics_controls.md. */
/* Apply the first NAEPHY group to a480-byte private record. Supported keys below.
 * x0 bounded text,x1 bytes1..262144,x2 record. Return0/2, no writes on rejection.
 * Scalar integer tokens0..2, boolean tokens as in Fortran. Frame576 bytes. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_apply_operational_physics_namelist
.type md2asm_apply_operational_physics_namelist,%function
md2asm_apply_operational_physics_namelist:
 stp x29,x30,[sp,#-96]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 mov x29,sp
 sub sp,sp,#480
 mov x19,x0
 mov x21,x2
 mov x22,sp
 cbz x0,.Loperational_naephy_bad
 cbz x2,.Loperational_naephy_bad
 cbz x1,.Loperational_naephy_bad
 cmp x1,#64,lsl#12
 b.hi .Loperational_naephy_bad
 tst x2,#7
 b.ne .Loperational_naephy_bad
 adds x20,x0,x1
 b.cs .Loperational_naephy_bad
 adds x9,x2,#480
 b.cs .Loperational_naephy_bad
 cmp x9,x0
 b.ls .Loperational_naephy_disjoint
 cmp x2,x20
 b.lo .Loperational_naephy_bad
.Loperational_naephy_disjoint:
 mrs x9,fpcr
 cbnz x9,.Loperational_naephy_bad
 mov x9,#0
.Loperational_naephy_copy_in:
 add x12,x21,x9
 ldp x10,x11,[x12]
 add x12,x22,x9
 stp x10,x11,[x12]
 add x9,x9,#16
 cmp x9,#480
 b.lo .Loperational_naephy_copy_in
 /* The source group marker is the first nonblank token on its line. */
.Loperational_naephy_start_line:
 mov w28,#0
.Loperational_naephy_find_line:
 cmp x19,x20
 b.hs .Loperational_naephy_bad
 ldrb w9,[x19],#1
 add w28,w28,#1
 cmp w9,#10
 b.eq .Loperational_naephy_start_line
 cmp w9,#32
 b.eq .Loperational_naephy_find_line
 cmp w9,#9
 b.eq .Loperational_naephy_find_line
 cmp w9,#13
 b.eq .Loperational_naephy_find_line
 cmp w9,#10
 b.eq .Loperational_naephy_find_line
 cmp w9,#38
 b.ne .Loperational_naephy_skip_line
 cmp w28,#10
 b.hi .Loperational_naephy_skip_line
 add x9,x19,#6
 cmp x9,x20
 b.hs .Loperational_naephy_bad
 adr x10,.Loperational_naephy_group
 mov w11,#0
.Loperational_naephy_group_match:
 ldrb w12,[x19,x11]
 ldrb w13,[x10,x11]
 cmp w12,w13
 b.ne .Loperational_naephy_skip_line
 add w11,w11,#1
 cmp w11,#6
 b.lo .Loperational_naephy_group_match
 add x19,x19,#6
 ldrb w9,[x19]
 cmp w9,#32
 b.eq .Loperational_naephy_key
 cmp w9,#9
 b.eq .Loperational_naephy_key
 cmp w9,#13
 b.eq .Loperational_naephy_key
 cmp w9,#10
 b.eq .Loperational_naephy_key
 cmp w9,#47
 b.eq .Loperational_naephy_key
 cmp w9,#44
 b.eq .Loperational_naephy_key
.Loperational_naephy_skip_line:
 cmp x19,x20
 b.hs .Loperational_naephy_bad
 ldrb w9,[x19],#1
 cmp w9,#10
 b.ne .Loperational_naephy_skip_line
 b .Loperational_naephy_start_line
.Loperational_naephy_key:
 mov x0,x19
 mov x1,x20
 bl .Loperational_naephy_skip_blank
 mov x19,x0
 cmp x19,x20
 b.hs .Loperational_naephy_bad
 ldrb w9,[x19]
 cmp w9,#44
 b.ne .Loperational_naephy_key_start
 add x19,x19,#1
 b .Loperational_naephy_key
.Loperational_naephy_key_start:
 cmp w9,#47
 b.eq .Loperational_naephy_finish
 mov x27,x19
.Loperational_naephy_key_scan:
 cmp x19,x20
 b.hs .Loperational_naephy_bad
 ldrb w9,[x19]
 sub w10,w9,#65
 cmp w10,#25
 b.ls .Loperational_naephy_key_next
 sub w10,w9,#97
 cmp w10,#25
 b.ls .Loperational_naephy_key_next
 sub w10,w9,#48
 cmp w10,#9
 b.ls .Loperational_naephy_key_next
 cmp w9,#95
 b.eq .Loperational_naephy_key_next
 cmp w9,#37
 b.ne .Loperational_naephy_key_lookup_call
.Loperational_naephy_key_next:
 add x19,x19,#1
 b .Loperational_naephy_key_scan
.Loperational_naephy_key_lookup_call:
 mov x0,x27
 sub x1,x19,x27
 bl .Loperational_naephy_lookup
 tbnz w0,#31,.Loperational_naephy_bad
 mov w25,w0
 mov w26,w1
 mov x0,x19
 mov x1,x20
 bl .Loperational_naephy_skip_blank
 mov x19,x0
 cmp x19,x20
 b.hs .Loperational_naephy_bad
 ldrb w9,[x19],#1
 cmp w9,#61
 b.ne .Loperational_naephy_bad
 mov x0,x19
 mov x1,x20
 bl .Loperational_naephy_skip_blank
 mov x19,x0
 mov x27,x0
.Loperational_naephy_value_scan:
 cmp x19,x20
 b.hs .Loperational_naephy_bad
 ldrb w9,[x19]
 cmp w9,#32
 b.eq .Loperational_naephy_value_found
 cmp w9,#9
 b.eq .Loperational_naephy_value_found
 cmp w9,#13
 b.eq .Loperational_naephy_value_found
 cmp w9,#10
 b.eq .Loperational_naephy_value_found
 cmp w9,#44
 b.eq .Loperational_naephy_value_found
 cmp w9,#33
 b.eq .Loperational_naephy_value_found
 cmp w9,#47
 b.eq .Loperational_naephy_value_found
 add x19,x19,#1
 b .Loperational_naephy_value_scan
.Loperational_naephy_value_found:
 mov x0,x27
 sub x1,x19,x27
 cmp w26,#2
 b.eq .Loperational_naephy_character_call
 cbnz w26,.Loperational_naephy_integer_call
 bl .Loperational_naephy_boolean
 b .Loperational_naephy_value_result
.Loperational_naephy_character_call:
 bl .Loperational_naephy_character
 b .Loperational_naephy_value_result
.Loperational_naephy_integer_call:
 bl .Loperational_naephy_integer
.Loperational_naephy_value_result:
 cbnz w1,.Loperational_naephy_bad
 str w0,[x22,x25]
 b .Loperational_naephy_key
.Loperational_naephy_finish:
 mov x9,#0
.Loperational_naephy_copy_out:
 add x12,x22,x9
 ldp x10,x11,[x12]
 add x12,x21,x9
 stp x10,x11,[x12]
 add x9,x9,#16
 cmp x9,#480
 b.lo .Loperational_naephy_copy_out
 mov w0,#0
 b .Loperational_naephy_return
.Loperational_naephy_bad:
 mov w0,#2
.Loperational_naephy_return:
 add sp,sp,#480
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp],#96
 ret
.size md2asm_apply_operational_physics_namelist,.-md2asm_apply_operational_physics_namelist
/* Local helpers use only caller-saved x0..x17. */
.Loperational_naephy_skip_blank:
 cmp x0,x1
 b.hs .Loperational_naephy_skip_return
 ldrb w9,[x0]
 cmp w9,#32
 b.eq .Loperational_naephy_skip_next
 cmp w9,#9
 b.eq .Loperational_naephy_skip_next
 cmp w9,#13
 b.eq .Loperational_naephy_skip_next
 cmp w9,#10
 b.eq .Loperational_naephy_skip_next
 cmp w9,#33
 b.ne .Loperational_naephy_skip_return
.Loperational_naephy_skip_comment:
 add x0,x0,#1
 cmp x0,x1
 b.hs .Loperational_naephy_skip_return
 ldrb w9,[x0]
 cmp w9,#10
 b.ne .Loperational_naephy_skip_comment
.Loperational_naephy_skip_next:
 add x0,x0,#1
 b .Loperational_naephy_skip_blank
.Loperational_naephy_skip_return:
 ret
.Loperational_naephy_lookup:
 adr x9,.Loperational_naephy_keys
 mov w10,#42
.Loperational_naephy_lookup_row:
 ldr w11,[x9,#16]
 cmp x1,x11
 b.ne .Loperational_naephy_lookup_next
 mov x12,#0
.Loperational_naephy_lookup_char:
 ldrb w13,[x0,x12]
 sub w14,w13,#65
 cmp w14,#25
 orr w15,w13,#32
 csel w13,w15,w13,ls
 ldrb w14,[x9,x12]
 cmp w13,w14
 b.ne .Loperational_naephy_lookup_next
 add x12,x12,#1
 cmp x12,x1
 b.lo .Loperational_naephy_lookup_char
 ldp w0,w1,[x9,#20]
 ret
.Loperational_naephy_lookup_next:
 add x9,x9,#32
 subs w10,w10,#1
 b.ne .Loperational_naephy_lookup_row
 mov w0,#-1
 ret
.Loperational_naephy_boolean:
 cbz x1,.Loperational_naephy_token_bad
 ldrb w9,[x0]
 cmp w9,#46
 b.ne .Loperational_naephy_bool_core
 cmp x1,#3
 b.lo .Loperational_naephy_token_bad
 sub x10,x1,#1
 ldrb w9,[x0,x10]
 cmp w9,#46
 b.ne .Loperational_naephy_token_bad
 add x0,x0,#1
 sub x1,x1,#2
.Loperational_naephy_bool_core:
 ldrb w9,[x0]
 orr w9,w9,#32
 cmp w9,#116
 b.eq .Loperational_naephy_true
 cmp w9,#102
 b.ne .Loperational_naephy_token_bad
 mov w15,#0
 adr x10,.Loperational_naephy_false_text
 mov w11,#5
 b .Loperational_naephy_bool_match
.Loperational_naephy_true:
 mov w15,#1
 adr x10,.Loperational_naephy_true_text
 mov w11,#4
.Loperational_naephy_bool_match:
 cmp x1,#1
 b.eq .Loperational_naephy_bool_good
 cmp x1,x11
 b.ne .Loperational_naephy_token_bad
 mov x12,#0
.Loperational_naephy_bool_char:
 ldrb w13,[x0,x12]
 orr w13,w13,#32
 ldrb w14,[x10,x12]
 cmp w13,w14
 b.ne .Loperational_naephy_token_bad
 add x12,x12,#1
 cmp x12,x1
 b.lo .Loperational_naephy_bool_char
.Loperational_naephy_bool_good:
 mov w0,w15
 mov w1,#0
 ret
.Loperational_naephy_integer:
 cmp x1,#1
 b.eq .Loperational_naephy_integer_positive
 cmp x1,#2
 b.ne .Loperational_naephy_token_bad
 ldrb w9,[x0],#1
 cmp w9,#43
 b.eq .Loperational_naephy_integer_positive
 b .Loperational_naephy_token_bad
.Loperational_naephy_integer_positive:
 mov w10,#1
.Loperational_naephy_integer_digit:
 ldrb w9,[x0]
 sub w9,w9,#48
 cmp w9,#2
 b.hi .Loperational_naephy_token_bad
 mul w0,w9,w10
 mov w1,#0
 ret
.Loperational_naephy_character:
 cmp x1,#6
 b.ne .Loperational_naephy_token_bad
 ldrb w9,[x0]
 cmp w9,#39
 b.eq .Loperational_naephy_character_quote
 cmp w9,#34
 b.ne .Loperational_naephy_token_bad
.Loperational_naephy_character_quote:
 ldrb w10,[x0,#5]
 cmp w10,w9
 b.ne .Loperational_naephy_token_bad
 ldr w10,[x0,#1]
 movz w11,#0x3148
 movk w11,#0x302e,lsl#16
 cmp w10,w11
 b.ne .Loperational_naephy_token_bad
 mov w0,w10
 mov w1,#0
 ret
.Loperational_naephy_token_bad:
 mov w0,#0
 mov w1,#1
 ret
.section .rodata
.Loperational_naephy_group: .ascii "NAEPHY"
.Loperational_naephy_true_text: .ascii "true"
.Loperational_naephy_false_text: .ascii "false"
.p2align 4
.Loperational_naephy_keys:
 .ascii "lephys"
 .zero 10
 .word 6,0,0,0
 .ascii "levdif"
 .zero 10
 .word 6,56,0,0
 .ascii "lesurf"
 .zero 10
 .word 6,52,0,0
 .ascii "lecond"
 .zero 10
 .word 6,4,0,0
 .ascii "lecumf"
 .zero 10
 .word 6,8,0,0
 .ascii "lepcld"
 .zero 10
 .word 6,68,0,0
 .ascii "leevap"
 .zero 10
 .word 6,16,0,0
 .ascii "levgen"
 .zero 10
 .word 6,188,0,0
 .ascii "lessro"
 .zero 10
 .word 6,192,0,0
 .ascii "lecurr"
 .zero 10
 .word 6,124,0,0
 .ascii "leocwa"
 .zero 10
 .word 6,172,0,0
 .ascii "legwdg"
 .zero 10
 .word 6,20,0,0
 .ascii "legwwms"
 .zero 9
 .word 7,24,0,0
 .ascii "leozoc"
 .zero 10
 .word 6,28,0,0
 .ascii "leqngt"
 .zero 10
 .word 6,32,0,0
 .ascii "leradi"
 .zero 10
 .word 6,36,0,0
 .ascii "lerads"
 .zero 10
 .word 6,44,0,0
 .ascii "lesice"
 .zero 10
 .word 6,48,0,0
 .ascii "leo3ch"
 .zero 10
 .word 6,72,0,0
 .ascii "lo3ch_hlo"
 .zero 7
 .word 9,88,0,0
 .ascii "co3chem"
 .zero 9
 .word 7,92,2,0
 .ascii "ledcld"
 .zero 10
 .word 6,12,0,0
 .ascii "lductdia"
 .zero 8
 .word 8,248,0,0
 .ascii "ldiagturb_ec"
 .zero 4
 .word 12,252,0,0
 .ascii "lelight"
 .zero 9
 .word 7,296,0,0
 .ascii "lwcou"
 .zero 11
 .word 5,448,0,0
 .ascii "lwcou2w"
 .zero 9
 .word 7,452,0,0
 .ascii "lwcouhmf"
 .zero 8
 .word 8,464,0,0
 .ascii "lwcournw"
 .zero 8
 .word 8,460,0,0
 .ascii "nstpw"
 .zero 11
 .word 5,476,1,0
 .ascii "lslphy"
 .zero 10
 .word 6,260,0,0
 .ascii "lesnml"
 .zero 10
 .word 6,340,0,0
 .ascii "nsnmlws"
 .zero 9
 .word 7,348,1,0
 .ascii "lefarquhar"
 .zero 6
 .word 10,280,0,0
 .ascii "leoptsurf"
 .zero 7
 .word 9,284,0,0
 .ascii "leairco2coup"
 .zero 4
 .word 12,292,0,0
 .ascii "lec4map"
 .zero 9
 .word 7,288,0,0
 .ascii "leags"
 .zero 11
 .word 5,276,0,0
 .ascii "nalbedoscheme"
 .zero 3
 .word 13,376,1,0
 .ascii "lelaiv"
 .zero 10
 .word 6,268,0,0
 .ascii "lwcur"
 .zero 11
 .word 5,456,0,0
 .ascii "lwstokes"
 .zero 8
 .word 8,468,0,0
.section .note.GNU-stack,"",%progbits
