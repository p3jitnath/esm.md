/* Contract: skills/md2asm/references/openifs/setup/operational_transform_setup.md.
 * x0 mapped ASCII text, x1 byte count, x2 selector 1 for the first NAMTRANS.
 * Accept an empty group or false assignments to LUSEFLT and LFFTW only.
 * Return 0 means supported, 2 means absent, unsupported or malformed.
 * No output, floating-point instruction, stack or child call is used.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_operational_transform_configuration_group
.type md2asm_operational_transform_configuration_group,%function
md2asm_operational_transform_configuration_group:
 cmp x2,#1
 b.ne .Ltransform_group_reject
 adr x6,.Ltransform_group_name1
 mov x12,#8
 cbz x0,.Ltransform_group_reject
 cbz x1,.Ltransform_group_reject
 adds x9,x0,x1
 b.cs .Ltransform_group_reject
 mov x2,#0
 mov x13,#0
.Ltransform_group_line:
 cmp x2,x1
 b.hs .Ltransform_group_reject
 cmp x13,#10
 b.hs .Ltransform_group_skip_line
 ldrb w3,[x0,x2]
 cmp w3,#32
 b.eq .Ltransform_group_leading
 cmp w3,#9
 b.eq .Ltransform_group_leading
 cmp w3,#10
 b.eq .Ltransform_group_leading
 cmp w3,#13
 b.eq .Ltransform_group_leading
 cmp w3,#38
 b.ne .Ltransform_group_skip_line
 add x4,x2,#1
 mov x5,#0
.Ltransform_group_match:
 cmp x4,x1
 b.hs .Ltransform_group_reject
 ldrb w7,[x0,x4]
 ldrb w8,[x6,x5]
 cmp w7,w8
 b.ne .Ltransform_group_skip_line
 add x4,x4,#1
 add x5,x5,#1
 cmp x5,x12
 b.lo .Ltransform_group_match
 cmp x4,x1
 b.hs .Ltransform_group_reject
 ldrb w3,[x0,x4]
 cmp w3,#32
 b.eq .Ltransform_group_found
 cmp w3,#9
 b.eq .Ltransform_group_found
 cmp w3,#10
 b.eq .Ltransform_group_found
 cmp w3,#13
 b.eq .Ltransform_group_found
 cmp w3,#47
 b.eq .Ltransform_group_found
 cmp w3,#33
 b.ne .Ltransform_group_skip_line
.Ltransform_group_found:
 mov x2,x4
.Ltransform_group_empty:
 cmp x2,x1
 b.hs .Ltransform_group_reject
 ldrb w3,[x0,x2]
 cmp w3,#47
 b.eq .Ltransform_group_accept
 cmp w3,#33
 b.eq .Ltransform_group_comment
 cmp w3,#32
 b.eq .Ltransform_group_empty_next
 cmp w3,#9
 b.eq .Ltransform_group_empty_next
 cmp w3,#10
 b.eq .Ltransform_group_empty_next
 cmp w3,#13
 b.eq .Ltransform_group_empty_next
 b .Lassignment_start
.Ltransform_group_empty_next:
 add x2,x2,#1
 b .Ltransform_group_empty
.Ltransform_group_comment:
 add x2,x2,#1
 cmp x2,x1
 b.hs .Ltransform_group_reject
 ldrb w3,[x0,x2]
 cmp w3,#10
 b.ne .Ltransform_group_comment
 b .Ltransform_group_empty_next
.Ltransform_group_leading:
 add x2,x2,#1
 add x13,x13,#1
 cmp w3,#10
 csel x13,xzr,x13,eq
 b .Ltransform_group_line
.Ltransform_group_skip_line:
 cmp x2,x1
 b.hs .Ltransform_group_reject
 ldrb w3,[x0,x2]
 add x2,x2,#1
 cmp w3,#10
 b.ne .Ltransform_group_skip_line
 mov x13,#0
 b .Ltransform_group_line
/* Match only the two source-defined false assignments. */
.Lassignment_start:
 adr x6,.Lmember_fast
 mov x12,#7
 mov x15,#0
.Lassignment_name_start:
 mov x4,x2
 mov x5,#0
.Lassignment_name:
 cmp x4,x1
 b.hs .Ltransform_group_reject
 ldrb w7,[x0,x4]
 bic w7,w7,#32
 ldrb w8,[x6,x5]
 cmp w7,w8
 b.ne .Lassignment_try_second
 add x4,x4,#1
 add x5,x5,#1
 cmp x5,x12
 b.lo .Lassignment_name
 mov x2,x4
 mov x14,#0
 b .Lassignment_space
.Lassignment_try_second:
 cbnz x15,.Ltransform_group_reject
 adr x6,.Lmember_fft
 mov x12,#5
 mov x15,#1
 b .Lassignment_name_start
.Lassignment_space:
 cmp x2,x1
 b.hs .Ltransform_group_reject
 ldrb w3,[x0,x2]
 cmp w3,#32
 b.eq .Lassignment_space_next
 cmp w3,#9
 b.eq .Lassignment_space_next
 cmp w3,#10
 b.eq .Lassignment_space_next
 cmp w3,#13
 b.eq .Lassignment_space_next
 cmp w3,#33
 b.eq .Lassignment_comment
 cbnz x14,.Lassignment_false
 cmp w3,#61
 b.ne .Ltransform_group_reject
 mov x14,#1
.Lassignment_space_next:
 add x2,x2,#1
 b .Lassignment_space
.Lassignment_comment:
 add x2,x2,#1
 cmp x2,x1
 b.hs .Ltransform_group_reject
 ldrb w3,[x0,x2]
 cmp w3,#10
 b.ne .Lassignment_comment
 b .Lassignment_space_next
.Lassignment_false:
 mov x15,#0
 cmp w3,#46
 b.ne .Lassignment_false_word
 mov x15,#1
 add x2,x2,#1
.Lassignment_false_word:
 adr x6,.Lfalse_word
 mov x4,x2
 mov x5,#0
.Lassignment_false_letter:
 cmp x4,x1
 b.hs .Ltransform_group_reject
 ldrb w7,[x0,x4]
 bic w7,w7,#32
 ldrb w8,[x6,x5]
 cmp w7,w8
 b.ne .Ltransform_group_reject
 add x4,x4,#1
 add x5,x5,#1
 cmp x5,#5
 b.lo .Lassignment_false_letter
 cbz x15,.Lassignment_value_end
 cmp x4,x1
 b.hs .Ltransform_group_reject
 ldrb w3,[x0,x4]
 cmp w3,#46
 b.ne .Ltransform_group_reject
 add x4,x4,#1
.Lassignment_value_end:
 cmp x4,x1
 b.hs .Ltransform_group_reject
 ldrb w3,[x0,x4]
 mov x2,x4
 cmp w3,#47
 b.eq .Ltransform_group_accept
 cmp w3,#33
 b.eq .Ltransform_group_comment
 cmp w3,#44
 b.eq .Ltransform_group_empty_next
 cmp w3,#32
 b.eq .Ltransform_group_empty_next
 cmp w3,#9
 b.eq .Ltransform_group_empty_next
 cmp w3,#10
 b.eq .Ltransform_group_empty_next
 cmp w3,#13
 b.eq .Ltransform_group_empty_next
 b .Ltransform_group_reject
.Ltransform_group_accept:
 mov w0,#0
 ret
.Ltransform_group_reject:
 mov w0,#2
 ret
.size md2asm_operational_transform_configuration_group,.-md2asm_operational_transform_configuration_group
.Ltransform_group_name1:
 .ascii "NAMTRANS"
.Lmember_fast:
 .ascii "LUSEFLT"
.Lmember_fft:
 .ascii "LFFTW"
.Lfalse_word:
 .ascii "FALSE"
.section .note.GNU-stack,"",%progbits
