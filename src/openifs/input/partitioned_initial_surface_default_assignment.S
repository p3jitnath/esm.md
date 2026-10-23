/* Qualified live-provider contract: skills/md2asm/references/openifs/input/partitioned_surface_state_startup.md. */
/* Integer copies for source SETDEFAULT surface assignments, revision 1.
 * Contract: skills/md2asm/references/openifs/input/initial_surface_default_assignment.md
 * No physical calculation or default choice is supplied by this leaf.
 * Six arguments: owner table, table bytes, assignments, bytes, count, owners.
 * Each table row has three raw 64-bit words. Selected shape is 24 by 86 blocks.
 * Reject every invalid span/index before mutation. Return 0 for success or 1 for invalid arguments.
 * 80-byte aligned frame. Preserve x18..x30, all vectors, FPCR/FPSR and errno.
 */
.arch armv8.2-a
.text
.p2align 4
.macro APART p,e,q,f
 cmp \p,\f
 b.hs .Lapart_\@
 cmp \q,\e
 b.lo .Lreject
.Lapart_\@:
.endm
.global md2asm_set_initial_surface_defaults
.type md2asm_set_initial_surface_defaults,%function
md2asm_set_initial_surface_defaults:
 cbz x4,.Lsuccess
 cbz x0,.Lbad
 cbz x2,.Lbad
 cbz x5,.Lbad
 cmp x4,#4096
 b.hi .Lbad
 cmp x5,#64
 b.hi .Lbad
 orr x8,x0,x2
 tst x8,#7
 b.ne .Lbad
 add x8,x4,x4,lsl#1
 lsl x8,x8,#3
 cmp x3,x8
 b.lo .Lbad
 adds x9,x2,x8
 b.cs .Lbad
 add x8,x5,x5,lsl#1
 lsl x8,x8,#3
 cmp x1,x8
 b.lo .Lbad
 adds x10,x0,x8
 b.cs .Lbad
 stp x19,x20,[sp,#-80]!
 stp x21,x22,[sp,#16]
 stp x23,x24,[sp,#32]
 stp x25,x26,[sp,#48]
 stp x27,x28,[sp,#64]
 mov x19,x0
 mov x20,x2
 mov x21,x4
 mov x22,x5
 mov x23,x10
 mov x24,x9
 mov x25,#0
.Lowner:
 add x8,x25,x25,lsl#1
 add x8,x19,x8,lsl#3
 ldp x26,x9,[x8]
 ldr x28,[x8,#16]
 cbz x26,.Lreject
 tst x26,#7
 b.ne .Lreject
 cbz x28,.Lreject
 cmp x28,#4096
 b.hi .Lreject
 mov x10,#16512
 mul x10,x28,x10
 cmp x9,x10
 b.lo .Lreject
 adds x27,x26,x10
 b.cs .Lreject
 APART x26,x27,x19,x23
 APART x26,x27,x20,x24
 mov x8,#0
.Lprevious:
 cmp x8,x25
 b.eq .Lowner_ok
 add x9,x8,x8,lsl#1
 add x9,x19,x9,lsl#3
 ldr x10,[x9]
 ldr x11,[x9,#16]
 mov x12,#16512
 madd x11,x11,x12,x10
 APART x26,x27,x10,x11
 add x8,x8,#1
 b .Lprevious
.Lowner_ok:
 add x25,x25,#1
 cmp x25,x22
 b.ne .Lowner
 mov x25,#0
.Lvalidate_assignment:
 add x8,x25,x25,lsl#1
 add x8,x20,x8,lsl#3
 ldp x9,x10,[x8]
 cmp x9,x22
 b.hs .Lreject
 add x11,x9,x9,lsl#1
 add x11,x19,x11,lsl#3
 ldr x12,[x11,#16]
 cmp x10,x12
 b.hs .Lreject
 add x25,x25,#1
 cmp x25,x21
 b.ne .Lvalidate_assignment
 mov x25,#0
.Lassignment:
 add x8,x25,x25,lsl#1
 add x8,x20,x8,lsl#3
 ldp x9,x10,[x8]
 ldr x11,[x8,#16]
 add x12,x9,x9,lsl#1
 add x12,x19,x12,lsl#3
 ldr x13,[x12]
 ldr x14,[x12,#16]
 mov x15,#192
 madd x13,x10,x15,x13
 mul x14,x14,x15
 sub x14,x14,#192
 mov x16,#86
.Lblock:
 mov x17,#24
.Lrow:
 str x11,[x13],#8
 subs x17,x17,#1
 b.ne .Lrow
 add x13,x13,x14
 subs x16,x16,#1
 b.ne .Lblock
 add x25,x25,#1
 cmp x25,x21
 b.ne .Lassignment
 mov w0,#0
 b .Lreturn
.Lreject:
 mov w0,#1
.Lreturn:
 ldp x21,x22,[sp,#16]
 ldp x23,x24,[sp,#32]
 ldp x25,x26,[sp,#48]
 ldp x27,x28,[sp,#64]
 ldp x19,x20,[sp],#80
 ret
.Lsuccess:
 mov w0,#0
 ret
.Lbad:
 mov w0,#1
 ret
.size md2asm_set_initial_surface_defaults,.-md2asm_set_initial_surface_defaults
.section .note.GNU-stack,"",%progbits

/* Complete operational SETDEFAULT storage stage.
 * Contract: skills/md2asm/references/openifs/input/operational_surface_defaults.md.
 * Seven arguments include the caller-owned reset word. Frame 96 bytes.
 * Validate every range and assignment before the reset or numerical stores.
 */
.text
.p2align 4
.macro ODPART p,e,q,f
 cmp \p,\f
 b.hs .Lods_apart_\@
 cmp \q,\e
 b.lo .Lods_reject
.Lods_apart_\@:
.endm
.global md2asm_set_partitioned_initial_surface_defaults
.type md2asm_set_partitioned_initial_surface_defaults,%function
md2asm_set_partitioned_initial_surface_defaults:
 cbz x6,.Lods_bad
 tst x6,#3
 b.ne .Lods_bad
 adds x7,x6,#4
 b.cs .Lods_bad
 cbz x4,.Lods_empty
 cbz x0,.Lods_bad
 cbz x2,.Lods_bad
 cbz x5,.Lods_bad
 cmp x4,#4096
 b.hi .Lods_bad
 cmp x5,#64
 b.hi .Lods_bad
 orr x8,x0,x2
 tst x8,#7
 b.ne .Lods_bad
 add x8,x4,x4,lsl#1
 lsl x8,x8,#3
 cmp x3,x8
 b.lo .Lods_bad
 adds x9,x2,x8
 b.cs .Lods_bad
 add x8,x5,x5,lsl#1
 lsl x8,x8,#3
 cmp x1,x8
 b.lo .Lods_bad
 adds x10,x0,x8
 b.cs .Lods_bad
 cmp x6,x10
 b.hs .Lods_effect_owner_table_ok
 cmp x0,x7
 b.lo .Lods_bad
.Lods_effect_owner_table_ok:
 cmp x6,x9
 b.hs .Lods_effect_assignment_table_ok
 cmp x2,x7
 b.lo .Lods_bad
.Lods_effect_assignment_table_ok:
 stp x19,x20,[sp,#-96]!
 stp x6,x7,[sp,#80]
 stp x21,x22,[sp,#16]
 stp x23,x24,[sp,#32]
 stp x25,x26,[sp,#48]
 stp x27,x28,[sp,#64]
 mov x19,x0
 mov x20,x2
 mov x21,x4
 mov x22,x5
 mov x23,x10
 mov x24,x9
 mov x25,#0
.Lods_owner:
 add x8,x25,x25,lsl#1
 add x8,x19,x8,lsl#3
 ldp x26,x9,[x8]
 ldr x28,[x8,#16]
 cbz x26,.Lods_reject
 tst x26,#7
 b.ne .Lods_reject
 cbz x28,.Lods_reject
 cmp x28,#4096
 b.hi .Lods_reject
 movz x10,#(13199480&65535)
 movk x10,#(13199480>>16),lsl#16
 mul x10,x28,x10
 cmp x9,x10
 b.lo .Lods_reject
 adds x27,x26,x10
 b.cs .Lods_reject
 ODPART x26,x27,x19,x23
 ODPART x26,x27,x20,x24
 ldp x9,x10,[sp,#80]
 ODPART x26,x27,x9,x10
 mov x8,#0
.Lods_previous:
 cmp x8,x25
 b.eq .Lods_owner_ok
 add x9,x8,x8,lsl#1
 add x9,x19,x9,lsl#3
 ldr x10,[x9]
 ldr x11,[x9,#16]
 movz x12,#(13199480&65535)
 movk x12,#(13199480>>16),lsl#16
 madd x11,x11,x12,x10
 ODPART x26,x27,x10,x11
 add x8,x8,#1
 b .Lods_previous
.Lods_owner_ok:
 add x25,x25,#1
 cmp x25,x22
 b.ne .Lods_owner
 mov x25,#0
.Lods_validate_assignment:
 add x8,x25,x25,lsl#1
 add x8,x20,x8,lsl#3
 ldp x9,x10,[x8]
 cmp x9,x22
 b.hs .Lods_reject
 add x11,x9,x9,lsl#1
 add x11,x19,x11,lsl#3
 ldr x12,[x11,#16]
 cmp x10,x12
 b.hs .Lods_reject
 add x25,x25,#1
 cmp x25,x21
 b.ne .Lods_validate_assignment
 ldr x6,[sp,#80]
 str wzr,[x6]
 mov x25,#0
.Lods_assignment:
 add x8,x25,x25,lsl#1
 add x8,x20,x8,lsl#3
 ldp x9,x10,[x8]
 ldr x11,[x8,#16]
 add x12,x9,x9,lsl#1
 add x12,x19,x12,lsl#3
 ldr x13,[x12]
 ldr x14,[x12,#16]
 mov x15,#136
 madd x13,x10,x15,x13
 mul x14,x14,x15
 sub x14,x14,#136
 movz x16,#(97055&65535)
 movk x16,#(97055>>16),lsl#16
.Lods_block:
 mov x17,#17
.Lods_row:
 str x11,[x13],#8
 subs x17,x17,#1
 b.ne .Lods_row
 add x13,x13,x14
 subs x16,x16,#1
 b.ne .Lods_block
 add x25,x25,#1
 cmp x25,x21
 b.ne .Lods_assignment
 mov w0,#0
 b .Lods_return
.Lods_reject:
 mov w0,#1
.Lods_return:
 ldp x21,x22,[sp,#16]
 ldp x23,x24,[sp,#32]
 ldp x25,x26,[sp,#48]
 ldp x27,x28,[sp,#64]
 ldp x19,x20,[sp],#96
 ret
.Lods_empty:
 str wzr,[x6]
 mov w0,#0
 ret
.Lods_bad:
 mov w0,#1
 ret
.size md2asm_set_partitioned_initial_surface_defaults,.-md2asm_set_partitioned_initial_surface_defaults
.section .note.GNU-stack,"",%progbits
