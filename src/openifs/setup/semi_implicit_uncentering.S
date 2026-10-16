/* Original SUDYN uncentering and derived semi-implicit time factors.
 * Contract skills/md2asm/references/openifs/dynamics/semi_implicit_uncentering.md.
 * x0 Geometry, x1 capacity, x2 MODEL, x3 capacity, x4 platform16.
 * The caller owns all input records and the borrowed vertical arrays. */
.arch armv8.2-a
.text
.macro MADDR dst,base,offset
 movz \dst,#(\offset & 65535)
 movk \dst,#(\offset >> 16),lsl#16
 add \dst,\base,\dst
.endm
.p2align 4
.global md2asm_initialize_semi_implicit_uncentering
.type md2asm_initialize_semi_implicit_uncentering,%function
md2asm_initialize_semi_implicit_uncentering:
 cbz x0,.Lbad
 cbz x2,.Lbad
 cbz x4,.Lbad
 orr x9,x0,x2
 tst x9,#7
 b.ne .Lbad
 tst x4,#3
 b.ne .Lbad
 mov x9,#17096
 cmp x1,x9
 b.lo .Lbad
 adds x10,x0,x9
 b.cs .Lbad
 MADDR x9,xzr,4275088
 cmp x3,x9
 b.lo .Lbad
 adds x11,x2,x9
 b.cs .Lbad
 cmp x10,x2
 b.ls .Ldisjoint
 cmp x11,x0
 b.hi .Lbad
.Ldisjoint:
 mrs x9,fpcr
 cbnz x9,.Lbad
 ldp w9,w10,[x4]
 cmp w9,#1
 b.ne .Lbad
 cmp w10,#1
 b.ne .Lbad
 ldp w9,w10,[x4,#8]
 cbnz w9,.Lbad
 cmp w10,#1
 b.ne .Lbad
 /* The admitted source route is hydrostatic and uses two time levels. */
 MADDR x9,x2,1564136
 ldr w10,[x9,#8]
 cbnz w10,.Lbad
 ldp w10,w11,[x9,#20]
 cmp w10,#1
 b.ne .Lbad
 cmp w11,#1
 b.ne .Lbad
 ldr x5,[x0,#3240]
 ldr x6,[x0,#3264]
 cbz x5,.Lbad
 cbz x6,.Lbad
 orr x9,x5,x6
 tst x9,#7
 b.ne .Lbad
 ldr w7,[x6,#52]
 cmp w7,#1
 b.hi .Lbad
 /* VAH is the existing one-dimensional half-level pressure owner. */
 ldr x8,[x5,#128]
 cbz x8,.Lbad
 tst x8,#7
 b.ne .Lbad
 ldr x9,[x5,#168]
 cmp x9,#1
 b.ne .Lbad
 ldr x9,[x5,#176]
 cmp x9,#1
 b.gt .Lbad
 ldr x10,[x5,#184]
 cmp x10,#1
 b.lt .Lbad
 mov x10,#1
 sub x10,x10,x9
 ldr d0,[x8,x10,lsl#3]
 /* Pressure and BETADT must be finite, and pressure must be nonnegative. */
 fmov x9,d0
 lsl x10,x9,#1
 cbz x10,.Lpressure_finite
 tbnz x9,#63,.Lbad
.Lpressure_finite:
 ubfx x10,x9,#52,#11
 cmp x10,#2047
 b.eq .Lbad
 MADDR x9,x2,1567072
 ldr d4,[x9]
 fmov x9,d4
 ubfx x10,x9,#52,#11
 cmp x10,#2047
 b.eq .Lbad
 /* SUDYN 639,653,680 and1333-1348, with the admitted original branches. */
 adr x9,.Lconstants
 ldr d2,[x9]
 fmov d1,#0.5
 fmul d0,d0,d1
 ldr d1,[x9,#8]
 fcmp d0,d1
 cset w10,lt
 orr w10,w10,w7
 fmov d3,xzr
 cmp w10,#0
 fcsel d2,d3,d2,ne
 /* SUDYN1882 and1890. Each multiply has its own rounding point. */
 fmov d0,#1.0
 fadd d1,d0,d3
 fmul d1,d1,d4
 fadd d0,d0,d2
 fmul d1,d1,d0
 fmov d0,#0.5
 fmul d0,d0,d1
 MADDR x9,x2,1568912
 str d3,[x9]
 str d2,[x9,#8]
 MADDR x9,x2,1567080
 str d1,[x9]
 str d0,[x9,#8]
 mov w0,#0
 ret
.Lbad:
 mov w0,#2
 ret
.size md2asm_initialize_semi_implicit_uncentering,.-md2asm_initialize_semi_implicit_uncentering
.p2align 3
.Lconstants:
 .double 0.05,100.0
.section .note.GNU-stack,"",%progbits
