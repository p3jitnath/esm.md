/* Consumed SUVFE_MATRIX knot intervals, direct owned-buffer utility.
 * Contract: skills/md2asm/references/openifs/setup/spline_knot_interval_contract.md. x0=counts[2],x1=input knots,
 * x2=weight knots, x3=&threshold, x4=records, x5=&record_count.
 * Records reserve 55 old slots or 287 slots for the exact new count pairs.
 * Records contain lower,upper,width FP64 and two int32 cumulative indices.
 * Return0 complete,2 rejected before mutation. No stack or external call.
 */
.arch armv8-a
.text
.p2align 4
.global md2asm_spline_knot_intervals
.type md2asm_spline_knot_intervals,%function
md2asm_spline_knot_intervals:
    cbz x0,.Lreject
    cbz x1,.Lreject
    cbz x2,.Lreject
    cbz x3,.Lreject
    cbz x4,.Lreject
    cbz x5,.Lreject
    orr x9,x0,x5
    tst x9,#3
    b.ne .Lreject
    orr x9,x1,x2
    orr x9,x9,x3
    orr x9,x9,x4
    tst x9,#7
    b.ne .Lreject
    ldp w6,w7,[x0]
    sub w9,w6,#25
    cmp w9,#3
    b.hi .Llarge_domain
    sub w9,w7,#25
    cmp w9,#3
    b.hi .Lreject
.Lcount_domain_done:
    mov x13,#0x3ff0000000000000
    mov x8,#0
    mov x14,#0
.Lvalidate_input:
    ldr x10,[x1,x8,lsl #3]
    cmp x10,x13
    b.hi .Lreject
    cmp x10,x14
    b.lo .Lreject
    mov x14,x10
    add x8,x8,#1
    cmp x8,x6
    b.lt .Lvalidate_input
    cmp x14,x13
    b.ne .Lreject
    ldr x10,[x1]
    cbnz x10,.Lreject
    mov x8,#0
    mov x14,#0
.Lvalidate_weight:
    ldr x10,[x2,x8,lsl #3]
    cmp x10,x13
    b.hi .Lreject
    cmp x10,x14
    b.lo .Lreject
    mov x14,x10
    add x8,x8,#1
    cmp x8,x7
    b.lt .Lvalidate_weight
    cmp x14,x13
    b.ne .Lreject
    ldr x10,[x2]
    cbnz x10,.Lreject
    ldr x10,[x3]
    tbnz x10,#63,.Lreject
    ubfx x11,x10,#52,#11
    cmp x11,#2047
    b.eq .Lreject
    fmov d7,x10
    mov x8,#0
    mov x9,#0
    mov x12,x4
    mov w13,#0
    mov x14,#0
.Lconsume_input:
    cmp x8,x6
    b.ge .Lconsume_weight
    ldr x10,[x1,x8,lsl #3]
    cmp x10,x14
    b.ne .Lconsume_weight
    add x8,x8,#1
    b .Lconsume_input
.Lconsume_weight:
    cmp x9,x7
    b.ge .Lnext_coordinate
    ldr x11,[x2,x9,lsl #3]
    cmp x11,x14
    b.ne .Lnext_coordinate
    add x9,x9,#1
    b .Lconsume_weight
.Lnext_coordinate:
    cmp x8,x6
    b.lt .Lload_input_next
    cmp x9,x7
    b.ge .Lsuccess
    ldr x15,[x2,x9,lsl #3]
    b .Linterval
.Lload_input_next:
    ldr x15,[x1,x8,lsl #3]
    cmp x9,x7
    b.ge .Linterval
    ldr x11,[x2,x9,lsl #3]
    cmp x15,x11
    csel x15,x15,x11,ls
.Linterval:
    fmov d0,x14
    fmov d1,x15
    fsub d2,d1,d0
    fabs d3,d2
    fcmp d3,d7
    b.le .Lskip
    stp d0,d1,[x12]
    str d2,[x12,#16]
    stp w8,w9,[x12,#24]
    add x12,x12,#32
    add w13,w13,#1
.Lskip:
    mov x14,x15
    b .Lconsume_input
.Lsuccess:
    str w13,[x5]
    mov w0,#0
    ret
.Lreject:
    mov w0,#2
    ret
.Llarge_domain:
    sub w9,w6,#143
    cmp w9,#1
    b.hi .Lreject
    sub w9,w7,#143
    cmp w9,#1
    b.hi .Lreject
    cmp w6,#144
    b.ne .Lcount_domain_done
    cmp w7,#144
    b.ne .Lreject
    b .Lcount_domain_done
.size md2asm_spline_knot_intervals,.-md2asm_spline_knot_intervals
.section .note.GNU-stack,"",%progbits
