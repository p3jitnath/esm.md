/* Selected GFL_FID_SETUP computation, with caller-owned output storage.
 * Contract: skills/md2asm/references/openifs/setup/field_membership.md
 * ABI x0 map, x1 count0..4200, x2 on, x3 active, x4 field_ids, x5 used.
 */
.text
.p2align 4
.global md2asm_initialize_field_membership
.type md2asm_initialize_field_membership,%function
md2asm_initialize_field_membership:
 cbz x0,.Lmember_reject
 cbz x2,.Lmember_reject
 cbz x3,.Lmember_reject
 cbz x4,.Lmember_reject
 cbz x5,.Lmember_reject
 orr x6,x0,x2
 orr x6,x6,x3
 orr x6,x6,x4
 orr x6,x6,x5
 tst x6,#3
 b.ne .Lmember_reject
 mov w6,#4200
 cmp x1,x6
 b.hi .Lmember_reject
 mov x6,#0
 cbz x1,.Lmember_empty
.Lmember_guard:
 ldr w7,[x2,x6,lsl #2]
 ldr w8,[x3,x6,lsl #2]
 cmp w7,#1
 b.hi .Lmember_reject
 cmp w8,#1
 b.hi .Lmember_reject
 add x6,x6,#1
 cmp x6,x1
 b.lo .Lmember_guard
 mov x6,#0
 mov w9,#0
.Lmember_loop:
 ldr w7,[x0,x6,lsl #2]
 ldr w8,[x2,x6,lsl #2]
 cbz w7,.Lmember_keep
 mov w8,#1
 str w8,[x2,x6,lsl #2]
 cmn w7,#1
 b.eq .Lmember_keep
 str w8,[x3,x6,lsl #2]
.Lmember_keep:
 cbz w8,.Lmember_next
 add w7,w6,#1
 str w7,[x4,x9,lsl #2]
 add w9,w9,#1
.Lmember_next:
 add x6,x6,#1
 cmp x6,x1
 b.lo .Lmember_loop
 str w9,[x5]
 mov w0,#0
 ret
.Lmember_empty:
 str wzr,[x5]
 mov w0,#0
 ret
.Lmember_reject:
 mov w0,#2
 ret
.size md2asm_initialize_field_membership,.-md2asm_initialize_field_membership
.section .note.GNU-stack,"",%progbits
