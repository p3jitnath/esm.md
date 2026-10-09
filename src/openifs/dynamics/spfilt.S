/* Complete SPFILT revision 1.0, derived from its frozen filter equations.
 * x0 geometry, x1 first column, x2 last column, x3 vorticity descriptor,
 * x4 divergence descriptor. Only selected vorticity cells can change.
 * Geometry and rank-two buffer bounds are defined in spfilt.md.
 * Preserve x19-x29, d8-d15, x18 and FPCR; stack alignment is 16 bytes.
 * exp is the frozen external scalar dependency, not a driver stage. */
#ifndef SPFILT_ENTRY
#define SPFILT_ENTRY spfilt_
#endif
.text
.p2align 4
.global SPFILT_ENTRY
.type SPFILT_ENTRY,%function
SPFILT_ENTRY:
    mrs x9,fpcr
    cbnz x9,.Lspfilt_bad_fpcr
    sub sp,sp,#96
    stp x19,x20,[sp]
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x25,x26,[sp,#48]
    stp x27,x28,[sp,#64]
    stp x29,x30,[sp,#80]
    ldr w23,[x0,#5172]
    ldr w28,[x0,#5228]
    ldr w26,[x1]
    ldr w27,[x2]
    lsl w9,w23,#1
    scvtf d0,w9
    fmov d1,#3.0
    fdiv d0,d0,d1
    fcvtas w24,d0
    sub w24,w24,#1
    scvtf d0,w23
    ldr d1,.Lspfilt_083
    fmul d0,d0,d1
    fcvtas w25,d0
    sub w25,w25,w24
    cmp w26,w27
    b.gt .Lspfilt_return
    ldr x19,[x3]
    ldr x20,[x3,#40]
    ldr x21,[x3,#64]
    lsl x20,x20,#3
    lsl x21,x21,#3
    sub w9,w26,#1
    sxtw x9,w9
    mul x9,x9,x21
    add x19,x19,x9
    add x9,x0,#3848
    ldr x22,[x9]
    ldr x10,[x9,#48]
    sxtw x11,w26
    sub x10,x11,x10
    add x22,x22,x10,lsl #2
.Lspfilt_column:
    ldr w9,[x22]
    add w9,w9,w25
    cmp w9,w24
    b.le .Lspfilt_unfiltered
    sub w10,w9,w23
    sub w11,w9,w24
    scvtf d0,w10
    scvtf d1,w11
    fmul d0,d0,d0
    fmul d1,d1,d1
    fmov d2,#-0.5
    fmul d0,d0,d2
    fdiv d0,d0,d1
    bl exp
    ldr d1,.Lspfilt_32
    fmul d0,d0,d1
    b .Lspfilt_factor
.Lspfilt_unfiltered:
    fmov d0,xzr
.Lspfilt_factor:
    fmul d0,d0,d0
    fmov d1,#1.0
    fadd d0,d1,d0
    fdiv d0,d1,d0
    mov w9,w28
    mov x10,x19
    cbz w9,.Lspfilt_next
    cmp x20,#8
    b.ne .Lspfilt_strided
    dup v0.2d,v0.d[0]
    cmp w9,#2
    b.lt .Lspfilt_tail
.Lspfilt_pair:
    ldr q1,[x10]
    fmul v1.2d,v1.2d,v0.2d
    str q1,[x10],#16
    sub w9,w9,#2
    cmp w9,#2
    b.ge .Lspfilt_pair
.Lspfilt_tail:
    cbz w9,.Lspfilt_next
    ldr d1,[x10]
    fmul d1,d1,d0
    str d1,[x10]
    b .Lspfilt_next
.Lspfilt_strided:
    ldr d1,[x10]
    fmul d1,d1,d0
    str d1,[x10]
    add x10,x10,x20
    subs w9,w9,#1
    b.ne .Lspfilt_strided
.Lspfilt_next:
    cmp w26,w27
    b.eq .Lspfilt_return
    add w26,w26,#1
    add x19,x19,x21
    add x22,x22,#4
    b .Lspfilt_column
.Lspfilt_return:
    ldp x19,x20,[sp]
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x25,x26,[sp,#48]
    ldp x27,x28,[sp,#64]
    ldp x29,x30,[sp,#80]
    add sp,sp,#96
    ret
.Lspfilt_bad_fpcr:
    brk #0x5f1
.size SPFILT_ENTRY,.-SPFILT_ENTRY
.p2align 3
.Lspfilt_083:
    .quad 0x3fea8f5c28f5c28f
.Lspfilt_32:
    .quad 0x4040000000000000
.section .note.GNU-stack,"",%progbits
