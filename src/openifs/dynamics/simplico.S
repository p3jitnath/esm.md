/* Complete real/complex pressure-wave and Coriolis solve.
 * The frozen Markdown contract defines each separately rounded operation.
 * Arrays are ordinary pointers. Five additional pointers enter on the stack.
 */
#ifndef SIMPLICO_ENTRY
#define SIMPLICO_ENTRY simplico_assembly_
#endif
.text
.p2align 4
.global SIMPLICO_ENTRY
.type SIMPLICO_ENTRY,%function
.macro observe
#ifdef SIMPLICO_OBSERVER
    str w9,[sp,#256]
    add x0,sp,#256
    ldp x1,x2,[sp,#176]
    ldp x3,x4,[sp,#192]
    mov x5,x29
    ldr x6,[sp,#160]
    ldr x7,[sp,#168]
    bl SIMPLICO_OBSERVER
#endif
.endm
.macro degree_views
    sub x11,x10,x19
    mul x11,x11,x22
    lsl x11,x11,#1
    ldr x12,[sp,#160]
    add x12,x12,x11
    add x13,x29,x11
    ldr x14,[sp,#168]
    add x14,x14,x11
.endm
SIMPLICO_ENTRY:
    sub sp,sp,#288
    stp x19,x20,[sp]
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x25,x26,[sp,#48]
    stp x27,x28,[sp,#64]
    stp x29,x30,[sp,#80]
    stp d8,d9,[sp,#96]
    stp d10,d11,[sp,#112]
    stp d12,d13,[sp,#128]
    stp d14,d15,[sp,#144]
    stp x0,x1,[sp,#176]
    stp x2,x3,[sp,#192]
    ldrsw x19,[x0]
    ldrsw x20,[x1]
    ldrsw x21,[x2]
    ldrsw x22,[x3]
    lsl x22,x22,#3
    mov x23,x4
    mov x24,x5
    mov x25,x6
    mov x26,x7
    ldp x27,x28,[sp,#288]
    ldr x9,[sp,#304]
    str x9,[sp,#224]
    ldr d8,[x9]
    ldp x29,x9,[sp,#312]
    str x9,[sp,#160]
    fmov d15,#1.0
    sub x0,x20,x19
    add x0,x0,#1
    mul x0,x0,x22
    lsl x0,x0,#1
    mov x9,#16
    cmp x0,#0
    csel x0,x0,x9,ne
    bl malloc
    cbz x0,.Lallocation_failed
    str x0,[sp,#168]
    cbnz x19,.Lclears_done
    /* Zero wave clears every imaginary row, including capacity padding. */
    mov x10,x19
.Lclear_degree:
    degree_views
    add x13,x13,x22
    add x12,x12,x22
    mov x15,#0
.Lclear_row:
    cmp x15,x22
    b.ge .Lclear_next
    str xzr,[x13,x15]
    str xzr,[x12,x15]
    add x15,x15,#8
    b .Lclear_row
.Lclear_next:
    add x10,x10,#1
    cmp x10,x20
    b.le .Lclear_degree
.Lclears_done:
    mov w9,#0
    observe
    str wzr,[sp,#240]
.Lparity:
    ldr w9,[sp,#240]
    add x10,x19,x9
.Lforward_degree:
    sub x17,x10,x19
    lsl x17,x17,#3
    ldr w9,[sp,#240]
    add x9,x19,x9
    cmp x10,x9
    cset w9,eq
    str w9,[sp,#264]
    cbnz x19,.Lcomplex_coefficients
    /* Real first degree and real continuation use distinct sum orders. */
    add x16,x25,x17
    ldr d20,[x16]
    ldr d21,[x16,#8]
    fmul d10,d20,d21
    ldr w9,[sp,#264]
    cbz w9,.Lreal_continuing_coefficients
    add x16,x26,x17
    ldr d21,[x16,#8]
    fmul d9,d20,d21
    fadd d9,d15,d9
    ldr w9,[sp,#240]
    cbz w9,.Lreal_coefficients_done
    add x16,x26,x17
    ldr d20,[x16]
    add x16,x25,x17
    ldr d21,[x16,#-8]
    fmul d20,d20,d21
    fadd d9,d9,d20
    b .Lreal_coefficients_done
.Lreal_continuing_coefficients:
    add x16,x26,x17
    ldr d20,[x16]
    ldr d22,[x16,#8]
    ldr d23,[x16,#-8]
    add x16,x25,x17
    ldr d21,[x16,#-8]
    ldr d24,[x16]
    fmul d9,d20,d21
    fadd d9,d15,d9
    fmul d22,d24,d22
    fadd d9,d9,d22
    fmul d12,d23,d20
.Lreal_coefficients_done:
    degree_views
    ldr d30,[x28,x10,lsl #3]
    mov x15,#0
.Lreal_forward_row:
    cmp x15,x21,lsl #3
    b.ge .Lforward_next
    ldr d0,[x27,x15]
    fmul d0,d8,d0
    fmul d0,d0,d30
    fsub d0,d9,d0
    ldr d6,[x13,x15]
    ldr w9,[sp,#264]
    cbnz w9,.Lreal_inverse
    sub x16,x14,x22,lsl #2
    ldr d1,[x16,x15]
    fmul d1,d12,d1
    fadd d0,d0,d1
    sub x16,x12,x22,lsl #2
    ldr d1,[x16,x15]
    fmul d1,d12,d1
    fadd d6,d1,d6
.Lreal_inverse:
    fmul d2,d0,d0
    fdiv d2,d15,d2
    fneg d4,d0
    fmul d4,d4,d2
    fmul d1,d4,d6
    str d1,[x12,x15]
    fmul d1,d4,d10
    str d1,[x14,x15]
    add x15,x15,#8
    b .Lreal_forward_row
.Lcomplex_coefficients:
    ldr w9,[sp,#264]
    cbz w9,.Lcomplex_continuing_coefficients
    add x16,x24,x17
    ldr d20,[x16,#8]
    add x16,x25,x17
    ldr d21,[x16]
    add x16,x26,x17
    ldr d22,[x16,#8]
    fmul d9,d20,d21
    fmul d9,d9,d22
    fadd d9,d15,d9
    add x16,x23,x17
    ldr d23,[x16]
    ldr d24,[x16,#8]
    fneg d14,d23
    fmul d23,d20,d24
    fmul d23,d23,d21
    fmul d23,d23,d22
    fadd d14,d14,d23
    ldr w9,[sp,#240]
    cbz w9,.Lcomplex_common_coefficients
    add x16,x24,x17
    ldr d20,[x16,#-8]
    add x16,x26,x17
    ldr d21,[x16]
    add x16,x25,x17
    ldr d22,[x16,#-8]
    fmul d23,d20,d21
    fmul d23,d23,d22
    fadd d9,d9,d23
    add x16,x23,x17
    ldr d24,[x16,#-8]
    fmul d23,d20,d24
    fmul d23,d23,d21
    fmul d23,d23,d22
    fadd d14,d14,d23
    b .Lcomplex_common_coefficients
.Lcomplex_continuing_coefficients:
    add x16,x24,x17
    ldr d20,[x16,#-8]
    add x16,x26,x17
    ldr d21,[x16]
    ldr d25,[x16,#-8]
    add x16,x25,x17
    ldr d22,[x16,#-8]
    fmul d9,d20,d21
    fmul d9,d9,d22
    fadd d9,d15,d9
    add x16,x23,x17
    ldr d23,[x16]
    ldr d24,[x16,#-8]
    fneg d14,d23
    fmul d23,d20,d24
    fmul d23,d23,d21
    fmul d23,d23,d22
    fadd d14,d14,d23
    fmul d12,d20,d25
    fmul d12,d12,d21
    fmul d13,d24,d12
    add x16,x24,x17
    ldr d20,[x16,#8]
    add x16,x25,x17
    ldr d21,[x16]
    add x16,x26,x17
    ldr d22,[x16,#8]
    fmul d23,d20,d21
    fmul d23,d23,d22
    fadd d9,d9,d23
    add x16,x23,x17
    ldr d24,[x16,#8]
    fmul d23,d20,d24
    fmul d23,d23,d21
    fmul d23,d23,d22
    fadd d14,d14,d23
.Lcomplex_common_coefficients:
    add x16,x24,x17
    ldr d20,[x16,#8]
    add x16,x25,x17
    ldr d21,[x16]
    ldr d22,[x16,#8]
    fmul d10,d20,d21
    fmul d10,d10,d22
    add x16,x23,x17
    ldr d20,[x16,#8]
    fmul d11,d20,d10
    degree_views
    ldr d30,[x28,x10,lsl #3]
    mov x15,#0
.Lcomplex_forward_row:
    cmp x15,x21,lsl #3
    b.ge .Lforward_next
    ldr d0,[x27,x15]
    fmul d0,d8,d0
    fmul d0,d0,d30
    fsub d0,d9,d0
    fmov d1,d14
    ldr d6,[x13,x15]
    add x16,x13,x22
    ldr d7,[x16,x15]
    ldr w9,[sp,#264]
    cbnz w9,.Lcomplex_inverse
    sub x16,x14,x22,lsl #2
    ldr d16,[x16,x15]
    add x16,x16,x22
    ldr d17,[x16,x15]
    fmul d18,d12,d16
    fadd d0,d0,d18
    fmul d18,d13,d17
    fsub d0,d0,d18
    fmul d18,d13,d16
    fadd d1,d1,d18
    fmul d18,d12,d17
    fadd d1,d1,d18
    sub x16,x12,x22,lsl #2
    ldr d16,[x16,x15]
    add x16,x16,x22
    ldr d17,[x16,x15]
    fmul d18,d12,d16
    fmul d19,d13,d17
    fsub d18,d18,d19
    fadd d6,d18,d6
    fmul d18,d13,d16
    fmul d19,d12,d17
    fadd d18,d18,d19
    fadd d7,d18,d7
.Lcomplex_inverse:
    fmul d2,d0,d0
    fmul d3,d1,d1
    fadd d2,d2,d3
    fdiv d2,d15,d2
    fneg d4,d0
    fmul d4,d4,d2
    fmul d5,d1,d2
    fmul d16,d4,d6
    fmul d17,d5,d7
    fsub d16,d16,d17
    str d16,[x12,x15]
    fmul d16,d5,d6
    fmul d17,d4,d7
    fadd d16,d16,d17
    add x16,x12,x22
    str d16,[x16,x15]
    fmul d16,d4,d10
    fmul d17,d5,d11
    fsub d16,d16,d17
    str d16,[x14,x15]
    fmul d16,d5,d10
    fmul d17,d4,d11
    fadd d16,d16,d17
    add x16,x14,x22
    str d16,[x16,x15]
    add x15,x15,#8
    b .Lcomplex_forward_row
.Lforward_next:
    add x10,x10,#2
    cmp x10,x20
    b.le .Lforward_degree
    ldr w9,[sp,#240]
    lsl w9,w9,#1
    add w9,w9,#1
    observe
    ldr w9,[sp,#240]
    sub x10,x20,x19
    add x10,x10,x9
    and x10,x10,#1
    sub x10,x20,x10
    degree_views
    mov x15,#0
.Lbackward_tail:
    cmp x15,x21,lsl #3
    b.ge .Lbackward_previous
    ldr d0,[x12,x15]
    fneg d0,d0
    str d0,[x12,x15]
    cbz x19,.Lbackward_tail_next
    add x16,x12,x22
    ldr d0,[x16,x15]
    fneg d0,d0
    str d0,[x16,x15]
.Lbackward_tail_next:
    add x15,x15,#8
    b .Lbackward_tail
.Lbackward_previous:
    sub x10,x10,#2
    ldr w9,[sp,#240]
    add x9,x19,x9
    cmp x10,x9
    b.lt .Lbackward_done
    degree_views
    add x16,x12,x22,lsl #2
    mov x15,#0
.Lbackward_row:
    cmp x15,x21,lsl #3
    b.ge .Lbackward_previous
    ldr d0,[x14,x15]
    ldr d2,[x16,x15]
    ldr d4,[x12,x15]
    cbnz x19,.Lcomplex_backward_row
    fmul d6,d0,d2
    fsub d6,d6,d4
    str d6,[x12,x15]
    b .Lbackward_row_next
.Lcomplex_backward_row:
    add x17,x14,x22
    ldr d1,[x17,x15]
    add x17,x16,x22
    ldr d3,[x17,x15]
    add x17,x12,x22
    ldr d5,[x17,x15]
    fmul d6,d0,d2
    fmul d7,d1,d3
    fsub d6,d6,d7
    fsub d6,d6,d4
    str d6,[x12,x15]
    fmul d6,d1,d2
    fmul d7,d0,d3
    fadd d6,d6,d7
    fsub d6,d6,d5
    str d6,[x17,x15]
.Lbackward_row_next:
    add x15,x15,#8
    b .Lbackward_row
.Lbackward_done:
    ldr w9,[sp,#240]
    lsl w9,w9,#1
    add w9,w9,#2
    observe
    ldr w9,[sp,#240]
    cbnz w9,.Lfinished
    cmp x19,x20
    b.eq .Lfinished
    mov w9,#1
    str w9,[sp,#240]
    b .Lparity
.Lfinished:
    ldr x0,[sp,#168]
    bl free
    ldp x19,x20,[sp]
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x25,x26,[sp,#48]
    ldp x27,x28,[sp,#64]
    ldp x29,x30,[sp,#80]
    ldp d8,d9,[sp,#96]
    ldp d10,d11,[sp,#112]
    ldp d12,d13,[sp,#128]
    ldp d14,d15,[sp,#144]
    add sp,sp,#288
    ret
.Lallocation_failed:
    bl abort
.size SIMPLICO_ENTRY,.-SIMPLICO_ENTRY
.purgem observe
.purgem degree_views
.section .note.GNU-stack,"",%progbits
