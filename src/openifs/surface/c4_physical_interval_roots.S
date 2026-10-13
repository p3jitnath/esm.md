// Gross C4 roots from plant_photosynthesis_contract.md, revision 2.
// x0 coefficients[4], x1 lower, x2 upper, x3 roots[3], x4 int32 count.
// All buffers are eight-byte aligned except the four-byte count.
// The 384-byte aligned frame owns four partition points and four values.
// Preserve x18, callee-saved registers, FPCR and every separate FP64 operation.
.text
.p2align 4
.global md2asm_c4_physical_interval_roots
.type md2asm_c4_physical_interval_roots,%function
md2asm_c4_physical_interval_roots:
    sub sp,sp,#384
    stp x19,x20,[sp]
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x29,x30,[sp,#48]
    stp d8,d9,[sp,#64]
    stp d10,d11,[sp,#80]
    stp d12,d13,[sp,#96]
    stp d14,d15,[sp,#112]
    str x18,[sp,#128]
    mov x29,sp
    mov x19,x0
    mov x20,x3
    mov x21,x4
    add x22,sp,#160
    add x23,sp,#192
    stp xzr,xzr,[x20]
    str xzr,[x20,#16]
    str wzr,[x21]
    ldr d0,[x1]
    ldr d1,[x2]
    str d0,[sp,#232]
    str d1,[sp,#240]
    fcmp d1,d0
    b.lt .Lc4_roots_return
    stp d0,d1,[x22]
    mov w24,#2
    ldr d0,[x19,#24]
    fmov d1,#3.0
    fmul d8,d1,d0
    ldr d0,[x19,#16]
    fmov d1,#2.0
    fmul d9,d1,d0
    ldr d10,[x19,#8]
    fcmp d8,#0.0
    b.ne .Lc4_roots_cubic_derivative
    fcmp d9,#0.0
    b.eq .Lc4_roots_sort_points
    fneg d0,d10
    fdiv d0,d0,d9
    bl .Lc4_roots_add_point
    b .Lc4_roots_sort_points
.Lc4_roots_cubic_derivative:
    fmul d0,d9,d9
    fmov d1,#4.0
    fmul d1,d1,d8
    fmul d1,d1,d10
    fsub d11,d0,d1
    fcmp d11,#0.0
    b.lt .Lc4_roots_sort_points
    fsqrt d11,d11
    fcmp d9,#0.0
    b.lt .Lc4_roots_negative_db
    fadd d0,d9,d11
    b .Lc4_roots_form_q
.Lc4_roots_negative_db:
    fsub d0,d9,d11
.Lc4_roots_form_q:
    fmov d1,#-0.5
    fmul d11,d1,d0
    fcmp d11,#0.0
    b.ne .Lc4_roots_two_turns
    fneg d0,d9
    fmov d1,#2.0
    fmul d1,d1,d8
    fdiv d0,d0,d1
    bl .Lc4_roots_add_point
    b .Lc4_roots_sort_points
.Lc4_roots_two_turns:
    fdiv d0,d11,d8
    bl .Lc4_roots_add_point
    fdiv d0,d10,d11
    bl .Lc4_roots_add_point
.Lc4_roots_sort_points:
    mov w9,#1
.Lc4_roots_point_outer:
    cmp w9,w24
    b.ge .Lc4_roots_evaluate_begin
    ldr d0,[x22,w9,uxtw #3]
    sub w10,w9,#1
.Lc4_roots_point_inner:
    cmp w10,#0
    b.lt .Lc4_roots_point_store
    ldr d1,[x22,w10,uxtw #3]
    fcmp d1,d0
    b.le .Lc4_roots_point_store
    add w11,w10,#1
    str d1,[x22,w11,uxtw #3]
    sub w10,w10,#1
    b .Lc4_roots_point_inner
.Lc4_roots_point_store:
    add w10,w10,#1
    str d0,[x22,w10,uxtw #3]
    add w9,w9,#1
    b .Lc4_roots_point_outer
.Lc4_roots_evaluate_begin:
    str wzr,[sp,#344]
.Lc4_roots_evaluate:
    ldr w9,[sp,#344]
    cmp w9,w24
    b.ge .Lc4_roots_intervals_begin
    ldr d0,[x22,w9,uxtw #3]
    str d0,[sp,#360]
    bl .Lc4_roots_poly
    ldr w9,[sp,#344]
    str d0,[x23,w9,uxtw #3]
    fcmp d0,#0.0
    b.ne .Lc4_roots_evaluate_next
    ldr d0,[sp,#360]
    bl .Lc4_roots_add_root
.Lc4_roots_evaluate_next:
    ldr w9,[sp,#344]
    add w9,w9,#1
    str w9,[sp,#344]
    b .Lc4_roots_evaluate
.Lc4_roots_intervals_begin:
    str wzr,[sp,#344]
.Lc4_roots_interval:
    ldr w9,[sp,#344]
    sub w10,w24,#1
    cmp w9,w10
    b.ge .Lc4_roots_sort_roots
    ldr d12,[x22,w9,uxtw #3]
    ldr d14,[x23,w9,uxtw #3]
    add w9,w9,#1
    ldr d13,[x22,w9,uxtw #3]
    ldr d15,[x23,w9,uxtw #3]
    fcmp d14,#0.0
    b.lt .Lc4_roots_start_negative
    b.le .Lc4_roots_next_interval
    fcmp d15,#0.0
    b.lt .Lc4_roots_bisect_begin
    b .Lc4_roots_next_interval
.Lc4_roots_start_negative:
    fcmp d15,#0.0
    b.le .Lc4_roots_next_interval
.Lc4_roots_bisect_begin:
    str wzr,[sp,#352]
.Lc4_roots_bisect:
    fmov d0,#0.5
    fmul d8,d0,d12
    fmul d1,d0,d13
    fadd d8,d8,d1
    fcmp d8,d12
    b.le .Lc4_roots_choose
    fcmp d8,d13
    b.ge .Lc4_roots_choose
    fmov d0,d8
    bl .Lc4_roots_poly
    fcmp d0,#0.0
    b.eq .Lc4_roots_exact_midpoint
    fcmp d14,#0.0
    b.lt .Lc4_roots_mid_negative_low
    fcmp d0,#0.0
    b.gt .Lc4_roots_replace_low
    b .Lc4_roots_replace_high
.Lc4_roots_mid_negative_low:
    fcmp d0,#0.0
    b.lt .Lc4_roots_replace_low
.Lc4_roots_replace_high:
    fmov d13,d8
    fmov d15,d0
    b .Lc4_roots_bisect_next
.Lc4_roots_replace_low:
    fmov d12,d8
    fmov d14,d0
.Lc4_roots_bisect_next:
    ldr w9,[sp,#352]
    add w9,w9,#1
    str w9,[sp,#352]
    cmp w9,#2200
    b.lt .Lc4_roots_bisect
    b .Lc4_roots_choose
.Lc4_roots_exact_midpoint:
    fmov d12,d8
    fmov d13,d8
    fmov d14,xzr
    fmov d15,xzr
.Lc4_roots_choose:
    fmov d0,d12
    fabs d1,d15
    fabs d2,d14
    fcmp d1,d2
    b.ge .Lc4_roots_chosen
    fmov d0,d13
.Lc4_roots_chosen:
    bl .Lc4_roots_add_root
.Lc4_roots_next_interval:
    ldr w9,[sp,#344]
    add w9,w9,#1
    str w9,[sp,#344]
    b .Lc4_roots_interval
.Lc4_roots_sort_roots:
    ldr w24,[x21]
    mov w9,#1
.Lc4_roots_root_outer:
    cmp w9,w24
    b.ge .Lc4_roots_return
    ldr d0,[x20,w9,uxtw #3]
    sub w10,w9,#1
.Lc4_roots_root_inner:
    cmp w10,#0
    b.lt .Lc4_roots_root_store
    ldr d1,[x20,w10,uxtw #3]
    fcmp d1,d0
    b.le .Lc4_roots_root_store
    add w11,w10,#1
    str d1,[x20,w11,uxtw #3]
    sub w10,w10,#1
    b .Lc4_roots_root_inner
.Lc4_roots_root_store:
    add w10,w10,#1
    str d0,[x20,w10,uxtw #3]
    add w9,w9,#1
    b .Lc4_roots_root_outer
.Lc4_roots_return:
    ldr x18,[sp,#128]
    ldp x19,x20,[sp]
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x29,x30,[sp,#48]
    ldp d8,d9,[sp,#64]
    ldp d10,d11,[sp,#80]
    ldp d12,d13,[sp,#96]
    ldp d14,d15,[sp,#112]
    add sp,sp,#384
    ret
.Lc4_roots_poly:
    ldr d1,[x19,#24]
    fmul d1,d1,d0
    ldr d2,[x19,#16]
    fadd d1,d1,d2
    fmul d1,d1,d0
    ldr d2,[x19,#8]
    fadd d1,d1,d2
    fmul d1,d1,d0
    ldr d2,[x19]
    fadd d0,d1,d2
    ret
.Lc4_roots_add_point:
    ldr d1,[sp,#232]
    fcmp d0,d1
    b.le .Lc4_roots_point_return
    ldr d1,[sp,#240]
    fcmp d0,d1
    b.ge .Lc4_roots_point_return
    mov w9,#0
.Lc4_roots_point_duplicate:
    cmp w9,w24
    b.ge .Lc4_roots_point_append
    ldr d1,[x22,w9,uxtw #3]
    fcmp d0,d1
    b.eq .Lc4_roots_point_return
    add w9,w9,#1
    b .Lc4_roots_point_duplicate
.Lc4_roots_point_append:
    str d0,[x22,w24,uxtw #3]
    add w24,w24,#1
.Lc4_roots_point_return:
    ret
.Lc4_roots_add_root:
    ldr w10,[x21]
    mov w9,#0
.Lc4_roots_root_duplicate:
    cmp w9,w10
    b.ge .Lc4_roots_root_append
    ldr d1,[x20,w9,uxtw #3]
    fcmp d0,d1
    b.eq .Lc4_roots_add_root_return
    add w9,w9,#1
    b .Lc4_roots_root_duplicate
.Lc4_roots_root_append:
    cmp w10,#3
    b.ge .Lc4_roots_overflow
    str d0,[x20,w10,uxtw #3]
    add w10,w10,#1
    str w10,[x21]
.Lc4_roots_add_root_return:
    ret
.Lc4_roots_overflow:
    bl abort
    brk #0
.size md2asm_c4_physical_interval_roots,.-md2asm_c4_physical_interval_roots
.section .note.GNU-stack,"",%progbits
