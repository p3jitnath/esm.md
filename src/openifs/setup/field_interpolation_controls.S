/* Complete source SUDYN1.08 field-interpolation control block.
 * Contract skills/md2asm/references/openifs/setup/field_interpolation_controls.md.
 * x0 outer MODEL, x1 capacity, x2 read-only platform16(NCONF,LECMWF,...).
 * Integer leaf, no storage ownership or external call; return0 ready or2 invalid. */
.arch armv8.2-a
.text
.macro FIELD_ADDRESS dst,base,offset
 movz \dst,#(\offset & 65535)
 movk \dst,#(\offset >> 16),lsl#16
 add \dst,\base,\dst
.endm
.p2align 4
.global md2asm_initialize_field_interpolation_controls
.type md2asm_initialize_field_interpolation_controls,%function
md2asm_initialize_field_interpolation_controls:
 cbz x0,.Linvalid
 cbz x2,.Linvalid
 tst x0,#7
 b.ne .Linvalid
 tst x2,#3
 b.ne .Linvalid
 FIELD_ADDRESS x9,xzr,4275088
 cmp x1,x9
 b.lo .Linvalid
 adds x10,x0,x9
 b.cs .Linvalid
 adds x11,x2,#16
 b.cs .Linvalid
 cmp x10,x2
 b.ls .Ldisjoint
 cmp x11,x0
 b.hi .Linvalid
.Ldisjoint:
 ldp w9,w10,[x2]
 cmp w10,#1
 b.hi .Linvalid
 FIELD_ADDRESS x12,x0,1564160
 ldr w11,[x12]
 cmp w11,#1
 b.hi .Linvalid
 /* Build the selected configuration set before combining live LSLAG. */
 cmp w9,#1
 cset w13,eq
 cmp w9,#302
 cset w12,eq
 orr w13,w13,w12
 cmp w9,#904
 cset w12,eq
 orr w13,w13,w12
 cmp w9,#131
 cset w12,eq
 eor w10,w10,#1
 and w12,w12,w10
 orr w13,w13,w12
 and w13,w13,w11
 /* Source writes exactly these ten consecutive four-byte logical words. */
 FIELD_ADDRESS x9,x0,1568928
 stp wzr,w13,[x9]
 stp wzr,w13,[x9,#8]
 stp w13,wzr,[x9,#16]
 stp wzr,wzr,[x9,#24]
 stp wzr,wzr,[x9,#32]
 mov w0,#0
 ret
.Linvalid:
 mov w0,#2
 ret
.size md2asm_initialize_field_interpolation_controls,.-md2asm_initialize_field_interpolation_controls
.section .note.GNU-stack,"",%progbits
