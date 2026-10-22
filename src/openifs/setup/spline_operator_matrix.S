/* Direct selected SUVFE_MATRIX. Contract: skills/md2asm/references/openifs/setup/spline_operator_matrix_contract.md.
 * x0=controls[kind,surface,basisIN,offsetIN,basisW,offsetW],
 * x1=scalars[threshold,lower_sample,upper_sample],
 * x2=owners[transformIN,transformW,knotsIN,knotsW,piecesIN,piecesW],
 * x3=output[21,21] for old shapes or [139,139] for seven exact new tuples.
 * x4=workspace (23,648 old bytes or 656,544 new bytes), x5=&capacity.
 * Return 0 means complete, 2 means preflight rejection, 3 means child failure.
 * The aligned 544-byte frame has an exact paired release on each entered exit.
 */
.arch armv8-a
.text
.p2align 4
.global md2asm_spline_operator_matrix
.type md2asm_spline_operator_matrix,%function
md2asm_spline_operator_matrix:
    cbz x0,.Lreject
    cbz x1,.Lreject
    cbz x2,.Lreject
    cbz x3,.Lreject
    cbz x4,.Lreject
    cbz x5,.Lreject
    tst x0,#3
    b.ne .Lreject
    orr x9,x1,x2
    orr x9,x9,x3
    orr x9,x9,x4
    orr x9,x9,x5
    tst x9,#7
    b.ne .Lreject
    ldr x9,[x5]
    mov x10,#23648
    cmp x9,x10
    b.lo .Lreject
    ldp w6,w7,[x0]
    add w9,w6,#1
    cmp w9,#2
    b.hi .Lreject
    cbnz w7,.Lreject
    ldp w6,w7,[x0,#8]
    sub w9,w6,#21
    cmp w9,#3
    b.hi .Llarge_domain
    cmp w7,w9
    b.hi .Lreject
    ldp w6,w7,[x0,#16]
    sub w9,w6,#21
    cmp w9,#3
    b.hi .Lreject
    cmp w7,w9
    b.hi .Lreject
    ldp x6,x7,[x1]
    cbnz x6,.Lreject
    cbnz x7,.Lreject
    ldr x6,[x1,#16]
    mov x7,#0x3ff0000000000000
    cmp x6,x7
    b.ne .Lreject
    mov x9,#0
.Lowners:
    ldr x10,[x2,x9,lsl #3]
    cbz x10,.Lreject
    tst x10,#7
    b.ne .Lreject
    add x9,x9,#1
    cmp x9,#6
    b.lt .Lowners
    sub sp,sp,#544
    stp x29,x30,[sp]
    mov x29,sp
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    stp d8,d9,[sp,#96]
    stp d10,d11,[sp,#112]
    stp d12,d13,[sp,#128]
    stp d14,d15,[sp,#144]
    mov x19,x0
    mov x20,x1
    mov x21,x2
    mov x22,x3
    mov x23,x4
    ldr w24,[x19,#8]
    ldr w25,[x19,#16]
    ldr w9,[x19]
    str w9,[sp,#176]
    mov w9,#4
    str w9,[sp,#180]
    mov w9,#21
    str w9,[sp,#184]
    mov w9,#5
    str w9,[sp,#240]
    ldr w9,[x19,#12]
    str w9,[sp,#192]
    ldr w9,[x19,#20]
    str w9,[sp,#196]
    str xzr,[sp,#344]
    add w9,w24,#4
    add w10,w25,#4
    str w9,[sp,#512]
    str w10,[sp,#516]
    add w28,w9,w10
    str w28,[sp,#204]
    add x0,sp,#512
    ldr x1,[x21,#16]
    ldr x2,[x21,#24]
    mov x3,x20
    mov x4,x23
    add x5,sp,#188
    bl md2asm_spline_knot_intervals
    cbnz w0,.Lpreflight_failure
    mov x9,#1760
    add x9,x23,x9
    str x9,[sp,#256]
    mov x9,#12512
    add x9,x23,x9
    str x9,[sp,#264]
    mov x9,#23264
    add x9,x23,x9
    str x9,[sp,#272]
    mov x9,#23456
    add x9,x23,x9
    str x9,[sp,#280]
    mov x9,#0
.Lclear_output:
    str xzr,[x22,x9,lsl #3]
    add x9,x9,#1
    cmp x9,#441
    b.lt .Lclear_output
    ldr w9,[sp,#176]
    cmp w9,#-1
    b.ne .Lmain_start
    ldr x0,[sp,#256]
    mul x1,x24,x28
    bl .Lclear_array
    mov x26,#1
    mov x27,#0
.Lprepass:
    ldr x0,[sp,#272]
    mov x1,x24
    bl .Lclear_array
    bl .Lcurrent_record
    cbz w0,.Lprepass_accumulate
    bl .Linput_bounds
    bl .Linput_range
    ldr w9,[sp,#216]
    str w9,[sp,#232]
.Lprepass_basis:
    ldr w9,[sp,#232]
    ldr w10,[sp,#220]
    cmp w9,w10
    b.gt .Lprepass_record_done
    ldr x0,[x21,#32]
    mov x1,x24
    ldr w2,[sp,#232]
    ldr x9,[sp,#248]
    ldr w3,[x9,#24]
    add x4,sp,#352
    bl .Lcopy_piece
    add x0,sp,#180
    add x1,sp,#352
    add x2,sp,#344
    add x3,sp,#240
    add x4,sp,#448
    bl md2asm_spline_polynomial_integral
    add x0,sp,#240
    add x1,sp,#448
    add x2,sp,#288
    bl md2asm_spline_polynomial_evaluate
    str d0,[sp,#488]
    add x0,sp,#240
    add x1,sp,#448
    add x2,sp,#296
    bl md2asm_spline_polynomial_evaluate
    ldr d1,[sp,#488]
    fsub d0,d0,d1
    ldr d1,[sp,#320]
    fmul d0,d0,d1
    ldr x9,[sp,#272]
    ldr w10,[sp,#232]
    sub w10,w10,#1
    str d0,[x9,x10,lsl #3]
    ldr w9,[sp,#232]
    add w9,w9,#1
    str w9,[sp,#232]
    b .Lprepass_basis
.Lprepass_record_done:
    add x27,x27,#1
.Lprepass_accumulate:
    ldr x0,[sp,#256]
    ldr x1,[sp,#272]
    mov x2,x24
    mov x3,x26
    bl .Lcumulative_step
    add x26,x26,#1
    cmp x26,x28
    b.lt .Lprepass
    ldr x0,[sp,#264]
    mul x1,x25,x28
    bl .Lclear_array
.Lmain_start:
    mov x26,#1
    mov x27,#0
.Lmain_interval:
    ldr w9,[sp,#176]
    cmp w9,#-1
    b.ne .Lmain_record
    ldr x0,[sp,#280]
    mov x1,x25
    bl .Lclear_array
.Lmain_record:
    bl .Lcurrent_record
    cbz w0,.Lmain_accumulate
    ldr x9,[sp,#248]
    ldr d0,[x9,#16]
    str d0,[sp,#336]
    bl .Lweight_bounds
    bl .Linput_bounds
    ldp d0,d1,[sp,#288]
    fsub d0,d1,d0
    ldp d1,d2,[sp,#304]
    fsub d1,d2,d1
    bl .Linput_range
    bl .Lweight_range
    ldr w9,[sp,#224]
    str w9,[sp,#236]
.Lweight_basis:
    ldr w9,[sp,#236]
    ldr w10,[sp,#228]
    cmp w9,w10
    b.gt .Lmain_record_done
    ldr x0,[x21,#40]
    mov x1,x25
    ldr w2,[sp,#236]
    ldr x9,[sp,#248]
    ldr w3,[x9,#28]
    add x4,sp,#352
    bl .Lcopy_piece
    ldr w9,[sp,#176]
    cmp w9,#-1
    b.ne .Llocal_weight
    add x0,sp,#180
    add x1,sp,#352
    add x2,sp,#344
    add x3,sp,#240
    add x4,sp,#448
    bl md2asm_spline_polynomial_integral
    add x0,sp,#240
    add x1,sp,#448
    add x2,sp,#304
    bl md2asm_spline_polynomial_evaluate
    str d0,[sp,#488]
    add x0,sp,#240
    add x1,sp,#448
    add x2,sp,#312
    bl md2asm_spline_polynomial_evaluate
    ldr d1,[sp,#488]
    fsub d0,d0,d1
    ldr d1,[sp,#328]
    fmul d0,d0,d1
    ldr x9,[sp,#280]
    ldr w10,[sp,#236]
    sub w10,w10,#1
    str d0,[x9,x10,lsl #3]
.Llocal_weight:
    add x0,sp,#180
    ldr x1,[x21,#8]
    add x2,sp,#304
    add x3,sp,#312
    add x4,sp,#352
    add x5,sp,#416
    add x6,x20,#8
    bl md2asm_spline_local_polynomial
    cbnz w0,.Lchild_failure
    ldr w9,[sp,#216]
    str w9,[sp,#232]
.Linput_basis:
    ldr w9,[sp,#232]
    ldr w10,[sp,#220]
    cmp w9,w10
    b.gt .Linput_basis_done
    ldr x0,[x21,#32]
    mov x1,x24
    ldr w2,[sp,#232]
    ldr x9,[sp,#248]
    ldr w3,[x9,#24]
    add x4,sp,#352
    bl .Lcopy_piece
    add x0,sp,#180
    ldr x1,[x21]
    add x2,sp,#288
    add x3,sp,#296
    add x4,sp,#352
    add x5,sp,#384
    add x6,x20,#8
    bl md2asm_spline_local_polynomial
    cbnz w0,.Lchild_failure
    add x0,sp,#176
    add x1,sp,#384
    add x2,sp,#416
    add x3,sp,#336
    add x4,x20,#8
    add x5,sp,#504
    bl md2asm_spline_interval_contribution
    cbnz w0,.Lchild_failure
    bl .Lmatrix_address
    ldr d0,[x0]
    ldr d1,[sp,#504]
    fadd d0,d0,d1
    str d0,[x0]
    ldr w9,[sp,#176]
    cmp w9,#-1
    b.ne .Lnext_input
    bl .Ladd_cumulative_product
.Lnext_input:
    ldr w9,[sp,#232]
    add w9,w9,#1
    str w9,[sp,#232]
    b .Linput_basis
.Linput_basis_done:
    ldr w9,[sp,#176]
    cmp w9,#-1
    b.ne .Lnext_weight
    ldr w9,[sp,#192]
    add w9,w9,#1
    str w9,[sp,#232]
.Learlier_input:
    ldr w9,[sp,#232]
    ldr w10,[sp,#216]
    cmp w9,w10
    b.ge .Lnext_weight
    bl .Ladd_cumulative_product
    ldr w9,[sp,#232]
    add w9,w9,#1
    str w9,[sp,#232]
    b .Learlier_input
.Lnext_weight:
    ldr w9,[sp,#236]
    add w9,w9,#1
    str w9,[sp,#236]
    b .Lweight_basis
.Lmain_record_done:
    add x27,x27,#1
.Lmain_accumulate:
    ldr w9,[sp,#176]
    cmp w9,#-1
    b.ne .Lnext_main_interval
    ldr x0,[sp,#264]
    ldr x1,[sp,#280]
    mov x2,x25
    mov x3,x26
    bl .Lcumulative_step
.Lnext_main_interval:
    add x26,x26,#1
    cmp x26,x28
    b.lt .Lmain_interval
    mov w0,#0
    b .Lfinish
.Lpreflight_failure:
    mov w0,#2
    b .Lfinish
.Lchild_failure:
    mov w0,#3
.Lfinish:
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp d8,d9,[sp,#96]
    ldp d10,d11,[sp,#112]
    ldp d12,d13,[sp,#128]
    ldp d14,d15,[sp,#144]
    ldp x29,x30,[sp]
    add sp,sp,#544
    ret
.Lreject:
    mov w0,#2
    ret

/* Private integer copies and exact source loop indices. */
.Lclear_array:
    mov x9,#0
.Lclear_next:
    str xzr,[x0,x9,lsl #3]
    add x9,x9,#1
    cmp x9,x1
    b.lt .Lclear_next
    ret
.Lcurrent_record:
    ldr w9,[sp,#188]
    cmp x27,x9
    b.ge .Lno_record
    add x10,x23,x27,lsl #5
    ldp w11,w12,[x10,#24]
    add w11,w11,w12
    cmp x26,x11
    b.ne .Lno_record
    str x10,[sp,#248]
    mov w0,#1
    ret
.Lno_record:
    mov w0,#0
    ret
.Lcopy_piece:
    sub x9,x2,#1
    sub x10,x3,x2
    madd x9,x10,x1,x9
    add x0,x0,x9,lsl #3
    lsl x10,x1,#5
    mov x11,#0
.Lcopy_coefficient:
    ldr x9,[x0]
    str x9,[x4,x11,lsl #3]
    add x0,x0,x10
    add x11,x11,#1
    cmp x11,#4
    b.lt .Lcopy_coefficient
    ret
.Linput_bounds:
    ldr x0,[x21,#16]
    ldr x2,[sp,#248]
    ldr w1,[x2,#24]
    add x3,sp,#288
    add x4,sp,#320
    b .Lcoordinates
.Lweight_bounds:
    ldr x0,[x21,#24]
    ldr x2,[sp,#248]
    ldr w1,[x2,#28]
    add x3,sp,#304
    add x4,sp,#328
.Lcoordinates:
    str x30,[sp,#528]
    str x3,[sp,#536]
    str x4,[sp,#520]
    sub x1,x1,#1
    add x9,x0,x1,lsl #3
    ldp d10,d11,[x9]
    ldp d12,d13,[x2]
    fmov d0,d10
    fmov d1,d11
    fmov d2,d12
    bl md2asm_vertical_interval_coordinate
    ldr x9,[sp,#536]
    str d0,[x9]
    fmov d0,d10
    fmov d1,d11
    fmov d2,d13
    bl md2asm_vertical_interval_coordinate
    ldr x9,[sp,#536]
    str d0,[x9,#8]
    fsub d0,d11,d10
    ldr x9,[sp,#520]
    str d0,[x9]
    ldr x30,[sp,#528]
    ret
.Linput_range:
    ldr x9,[sp,#248]
    ldr w9,[x9,#24]
    sub w10,w9,#3
    ldr w11,[sp,#192]
    add w11,w11,#1
    cmp w10,w11
    csel w10,w10,w11,gt
    str w10,[sp,#216]
    add w11,w11,#20
    cmp w9,w11
    csel w9,w9,w11,lt
    str w9,[sp,#220]
    ret
.Lweight_range:
    ldr x9,[sp,#248]
    ldr w9,[x9,#28]
    sub w10,w9,#3
    ldr w11,[sp,#196]
    add w11,w11,#1
    cmp w10,w11
    csel w10,w10,w11,gt
    str w10,[sp,#224]
    add w11,w11,#20
    cmp w9,w11
    csel w9,w9,w11,lt
    str w9,[sp,#228]
    ret
.Lcumulative_step:
    sub x9,x3,#1
    mul x9,x9,x2
    add x10,x0,x9,lsl #3
    add x9,x9,x2
    add x11,x0,x9,lsl #3
    mov x9,#0
.Lcumulative_word:
    ldr d0,[x10,x9,lsl #3]
    ldr d1,[x1,x9,lsl #3]
    fadd d0,d0,d1
    str d0,[x11,x9,lsl #3]
    add x9,x9,#1
    cmp x9,x2
    b.lt .Lcumulative_word
    ret
.Lmatrix_address:
    ldr w9,[sp,#232]
    ldr w10,[sp,#192]
    sub w9,w9,w10
    sub w9,w9,#1
    mov w10,#21
    mul w9,w9,w10
    ldr w10,[sp,#236]
    ldr w11,[sp,#196]
    sub w10,w10,w11
    sub w10,w10,#1
    add w9,w9,w10
    add x0,x22,x9,lsl #3
    ret
.Ladd_cumulative_product:
    str x30,[sp,#528]
    bl .Lmatrix_address
    ldr w9,[sp,#236]
    sub w9,w9,#1
    ldr x10,[sp,#280]
    ldr d1,[x10,x9,lsl #3]
    sub x9,x26,#1
    mul x9,x9,x24
    ldr w10,[sp,#232]
    add x9,x9,x10
    sub x9,x9,#1
    ldr x10,[sp,#256]
    ldr d2,[x10,x9,lsl #3]
    fmul d1,d1,d2
    ldr d0,[x0]
    fadd d0,d0,d1
    str d0,[x0]
    ldr x30,[sp,#528]
    ret
.Llarge_domain:
    adrp x9,.Llarge_controls
    add x9,x9,:lo12:.Llarge_controls
    mov w10,#7
.Llarge_tuple:
    mov x11,#0
.Llarge_tuple_word:
    ldr w12,[x0,x11,lsl #2]
    ldr w13,[x9,x11,lsl #2]
    cmp w12,w13
    b.ne .Llarge_next_tuple
    add x11,x11,#1
    cmp x11,#6
    b.lt .Llarge_tuple_word
    b .Llarge_capacity
.Llarge_next_tuple:
    add x9,x9,#24
    subs w10,w10,#1
    b.ne .Llarge_tuple
    b .Lreject
.Llarge_capacity:
    ldr x9,[x5]
    movz x10,#1184
    movk x10,#10,lsl #16
    cmp x9,x10
    b.lo .Lreject
    ldp x6,x7,[x1]
    cbnz x6,.Lreject
    cbnz x7,.Lreject
    ldr x6,[x1,#16]
    mov x7,#0x3ff0000000000000
    cmp x6,x7
    b.ne .Lreject
    mov x9,#0
.Llarge_owners:
    ldr x10,[x2,x9,lsl #3]
    cbz x10,.Lreject
    tst x10,#7
    b.ne .Lreject
    add x9,x9,#1
    cmp x9,#6
    b.lt .Llarge_owners
    sub sp,sp,#544
    stp x29,x30,[sp]
    mov x29,sp
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    stp d8,d9,[sp,#96]
    stp d10,d11,[sp,#112]
    stp d12,d13,[sp,#128]
    stp d14,d15,[sp,#144]
    mov x19,x0
    mov x20,x1
    mov x21,x2
    mov x22,x3
    mov x23,x4
    ldr w24,[x19,#8]
    ldr w25,[x19,#16]
    ldr w9,[x19]
    str w9,[sp,#176]
    mov w9,#4
    str w9,[sp,#180]
    mov w9,#139
    str w9,[sp,#184]
    mov w9,#5
    str w9,[sp,#240]
    ldr w9,[x19,#12]
    str w9,[sp,#192]
    ldr w9,[x19,#20]
    str w9,[sp,#196]
    str xzr,[sp,#344]
    add w9,w24,#4
    add w10,w25,#4
    str w9,[sp,#512]
    str w10,[sp,#516]
    add w28,w9,w10
    str w28,[sp,#204]
    add x0,sp,#512
    ldr x1,[x21,#16]
    ldr x2,[x21,#24]
    mov x3,x20
    mov x4,x23
    add x5,sp,#188
    bl md2asm_spline_knot_intervals
    cbnz w0,.Llarge_preflight_failure
    mov x9,#9184
    add x9,x23,x9
    str x9,[sp,#256]
    movz x9,#4064
    movk x9,#5,lsl #16
    add x9,x23,x9
    str x9,[sp,#264]
    movz x9,#64480
    movk x9,#9,lsl #16
    add x9,x23,x9
    str x9,[sp,#272]
    movz x9,#64
    movk x9,#10,lsl #16
    add x9,x23,x9
    str x9,[sp,#280]
    mov x10,#19321
    mov x9,#0
.Llarge_clear_output:
    str xzr,[x22,x9,lsl #3]
    add x9,x9,#1
    cmp x9,x10
    b.lt .Llarge_clear_output
    ldr w9,[sp,#176]
    cmp w9,#-1
    b.ne .Llarge_main_start
    ldr x0,[sp,#256]
    mul x1,x24,x28
    bl .Llarge_clear_array
    mov x26,#1
    mov x27,#0
.Llarge_prepass:
    ldr x0,[sp,#272]
    mov x1,x24
    bl .Llarge_clear_array
    bl .Llarge_current_record
    cbz w0,.Llarge_prepass_accumulate
    bl .Llarge_input_bounds
    bl .Llarge_input_range
    ldr w9,[sp,#216]
    str w9,[sp,#232]
.Llarge_prepass_basis:
    ldr w9,[sp,#232]
    ldr w10,[sp,#220]
    cmp w9,w10
    b.gt .Llarge_prepass_record_done
    ldr x0,[x21,#32]
    mov x1,x24
    ldr w2,[sp,#232]
    ldr x9,[sp,#248]
    ldr w3,[x9,#24]
    add x4,sp,#352
    bl .Llarge_copy_piece
    add x0,sp,#180
    add x1,sp,#352
    add x2,sp,#344
    add x3,sp,#240
    add x4,sp,#448
    bl md2asm_spline_polynomial_integral
    add x0,sp,#240
    add x1,sp,#448
    add x2,sp,#288
    bl md2asm_spline_polynomial_evaluate
    str d0,[sp,#488]
    add x0,sp,#240
    add x1,sp,#448
    add x2,sp,#296
    bl md2asm_spline_polynomial_evaluate
    ldr d1,[sp,#488]
    fsub d0,d0,d1
    ldr d1,[sp,#320]
    fmul d0,d0,d1
    ldr x9,[sp,#272]
    ldr w10,[sp,#232]
    sub w10,w10,#1
    str d0,[x9,x10,lsl #3]
    ldr w9,[sp,#232]
    add w9,w9,#1
    str w9,[sp,#232]
    b .Llarge_prepass_basis
.Llarge_prepass_record_done:
    add x27,x27,#1
.Llarge_prepass_accumulate:
    ldr x0,[sp,#256]
    ldr x1,[sp,#272]
    mov x2,x24
    mov x3,x26
    bl .Llarge_cumulative_step
    add x26,x26,#1
    cmp x26,x28
    b.lt .Llarge_prepass
    ldr x0,[sp,#264]
    mul x1,x25,x28
    bl .Llarge_clear_array
.Llarge_main_start:
    mov x26,#1
    mov x27,#0
.Llarge_main_interval:
    ldr w9,[sp,#176]
    cmp w9,#-1
    b.ne .Llarge_main_record
    ldr x0,[sp,#280]
    mov x1,x25
    bl .Llarge_clear_array
.Llarge_main_record:
    bl .Llarge_current_record
    cbz w0,.Llarge_main_accumulate
    ldr x9,[sp,#248]
    ldr d0,[x9,#16]
    str d0,[sp,#336]
    bl .Llarge_weight_bounds
    bl .Llarge_input_bounds
    ldp d0,d1,[sp,#288]
    fsub d0,d1,d0
    ldp d1,d2,[sp,#304]
    fsub d1,d2,d1
    bl .Llarge_input_range
    bl .Llarge_weight_range
    ldr w9,[sp,#224]
    str w9,[sp,#236]
.Llarge_weight_basis:
    ldr w9,[sp,#236]
    ldr w10,[sp,#228]
    cmp w9,w10
    b.gt .Llarge_main_record_done
    ldr x0,[x21,#40]
    mov x1,x25
    ldr w2,[sp,#236]
    ldr x9,[sp,#248]
    ldr w3,[x9,#28]
    add x4,sp,#352
    bl .Llarge_copy_piece
    ldr w9,[sp,#176]
    cmp w9,#-1
    b.ne .Llarge_local_weight
    add x0,sp,#180
    add x1,sp,#352
    add x2,sp,#344
    add x3,sp,#240
    add x4,sp,#448
    bl md2asm_spline_polynomial_integral
    add x0,sp,#240
    add x1,sp,#448
    add x2,sp,#304
    bl md2asm_spline_polynomial_evaluate
    str d0,[sp,#488]
    add x0,sp,#240
    add x1,sp,#448
    add x2,sp,#312
    bl md2asm_spline_polynomial_evaluate
    ldr d1,[sp,#488]
    fsub d0,d0,d1
    ldr d1,[sp,#328]
    fmul d0,d0,d1
    ldr x9,[sp,#280]
    ldr w10,[sp,#236]
    sub w10,w10,#1
    str d0,[x9,x10,lsl #3]
.Llarge_local_weight:
    add x0,sp,#180
    ldr x1,[x21,#8]
    add x2,sp,#304
    add x3,sp,#312
    add x4,sp,#352
    add x5,sp,#416
    add x6,x20,#8
    bl md2asm_spline_local_polynomial
    cbnz w0,.Llarge_child_failure
    ldr w9,[sp,#216]
    str w9,[sp,#232]
.Llarge_input_basis:
    ldr w9,[sp,#232]
    ldr w10,[sp,#220]
    cmp w9,w10
    b.gt .Llarge_input_basis_done
    ldr x0,[x21,#32]
    mov x1,x24
    ldr w2,[sp,#232]
    ldr x9,[sp,#248]
    ldr w3,[x9,#24]
    add x4,sp,#352
    bl .Llarge_copy_piece
    add x0,sp,#180
    ldr x1,[x21]
    add x2,sp,#288
    add x3,sp,#296
    add x4,sp,#352
    add x5,sp,#384
    add x6,x20,#8
    bl md2asm_spline_local_polynomial
    cbnz w0,.Llarge_child_failure
    add x0,sp,#176
    add x1,sp,#384
    add x2,sp,#416
    add x3,sp,#336
    add x4,x20,#8
    add x5,sp,#504
    bl md2asm_spline_interval_contribution
    cbnz w0,.Llarge_child_failure
    bl .Llarge_matrix_address
    ldr d0,[x0]
    ldr d1,[sp,#504]
    fadd d0,d0,d1
    str d0,[x0]
    ldr w9,[sp,#176]
    cmp w9,#-1
    b.ne .Llarge_next_input
    bl .Llarge_add_cumulative_product
.Llarge_next_input:
    ldr w9,[sp,#232]
    add w9,w9,#1
    str w9,[sp,#232]
    b .Llarge_input_basis
.Llarge_input_basis_done:
    ldr w9,[sp,#176]
    cmp w9,#-1
    b.ne .Llarge_next_weight
    ldr w9,[sp,#192]
    add w9,w9,#1
    str w9,[sp,#232]
.Llarge_earlier_input:
    ldr w9,[sp,#232]
    ldr w10,[sp,#216]
    cmp w9,w10
    b.ge .Llarge_next_weight
    bl .Llarge_add_cumulative_product
    ldr w9,[sp,#232]
    add w9,w9,#1
    str w9,[sp,#232]
    b .Llarge_earlier_input
.Llarge_next_weight:
    ldr w9,[sp,#236]
    add w9,w9,#1
    str w9,[sp,#236]
    b .Llarge_weight_basis
.Llarge_main_record_done:
    add x27,x27,#1
.Llarge_main_accumulate:
    ldr w9,[sp,#176]
    cmp w9,#-1
    b.ne .Llarge_next_main_interval
    ldr x0,[sp,#264]
    ldr x1,[sp,#280]
    mov x2,x25
    mov x3,x26
    bl .Llarge_cumulative_step
.Llarge_next_main_interval:
    add x26,x26,#1
    cmp x26,x28
    b.lt .Llarge_main_interval
    mov w0,#0
    b .Llarge_finish
.Llarge_preflight_failure:
    mov w0,#2
    b .Llarge_finish
.Llarge_child_failure:
    mov w0,#3
.Llarge_finish:
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp d8,d9,[sp,#96]
    ldp d10,d11,[sp,#112]
    ldp d12,d13,[sp,#128]
    ldp d14,d15,[sp,#144]
    ldp x29,x30,[sp]
    add sp,sp,#544
    ret
/* Private integer copies and exact source loop indices. */
.Llarge_clear_array:
    mov x9,#0
.Llarge_clear_next:
    str xzr,[x0,x9,lsl #3]
    add x9,x9,#1
    cmp x9,x1
    b.lt .Llarge_clear_next
    ret
.Llarge_current_record:
    ldr w9,[sp,#188]
    cmp x27,x9
    b.ge .Llarge_no_record
    add x10,x23,x27,lsl #5
    ldp w11,w12,[x10,#24]
    add w11,w11,w12
    cmp x26,x11
    b.ne .Llarge_no_record
    str x10,[sp,#248]
    mov w0,#1
    ret
.Llarge_no_record:
    mov w0,#0
    ret
.Llarge_copy_piece:
    sub x9,x2,#1
    sub x10,x3,x2
    madd x9,x10,x1,x9
    add x0,x0,x9,lsl #3
    lsl x10,x1,#5
    mov x11,#0
.Llarge_copy_coefficient:
    ldr x9,[x0]
    str x9,[x4,x11,lsl #3]
    add x0,x0,x10
    add x11,x11,#1
    cmp x11,#4
    b.lt .Llarge_copy_coefficient
    ret
.Llarge_input_bounds:
    ldr x0,[x21,#16]
    ldr x2,[sp,#248]
    ldr w1,[x2,#24]
    add x3,sp,#288
    add x4,sp,#320
    b .Llarge_coordinates
.Llarge_weight_bounds:
    ldr x0,[x21,#24]
    ldr x2,[sp,#248]
    ldr w1,[x2,#28]
    add x3,sp,#304
    add x4,sp,#328
.Llarge_coordinates:
    str x30,[sp,#528]
    str x3,[sp,#536]
    str x4,[sp,#520]
    sub x1,x1,#1
    add x9,x0,x1,lsl #3
    ldp d10,d11,[x9]
    ldp d12,d13,[x2]
    fmov d0,d10
    fmov d1,d11
    fmov d2,d12
    bl md2asm_vertical_interval_coordinate
    ldr x9,[sp,#536]
    str d0,[x9]
    fmov d0,d10
    fmov d1,d11
    fmov d2,d13
    bl md2asm_vertical_interval_coordinate
    ldr x9,[sp,#536]
    str d0,[x9,#8]
    fsub d0,d11,d10
    ldr x9,[sp,#520]
    str d0,[x9]
    ldr x30,[sp,#528]
    ret
.Llarge_input_range:
    ldr x9,[sp,#248]
    ldr w9,[x9,#24]
    sub w10,w9,#3
    ldr w11,[sp,#192]
    add w11,w11,#1
    cmp w10,w11
    csel w10,w10,w11,gt
    str w10,[sp,#216]
    add w11,w11,#138
    cmp w9,w11
    csel w9,w9,w11,lt
    str w9,[sp,#220]
    ret
.Llarge_weight_range:
    ldr x9,[sp,#248]
    ldr w9,[x9,#28]
    sub w10,w9,#3
    ldr w11,[sp,#196]
    add w11,w11,#1
    cmp w10,w11
    csel w10,w10,w11,gt
    str w10,[sp,#224]
    add w11,w11,#138
    cmp w9,w11
    csel w9,w9,w11,lt
    str w9,[sp,#228]
    ret
.Llarge_cumulative_step:
    sub x9,x3,#1
    mul x9,x9,x2
    add x10,x0,x9,lsl #3
    add x9,x9,x2
    add x11,x0,x9,lsl #3
    mov x9,#0
.Llarge_cumulative_word:
    ldr d0,[x10,x9,lsl #3]
    ldr d1,[x1,x9,lsl #3]
    fadd d0,d0,d1
    str d0,[x11,x9,lsl #3]
    add x9,x9,#1
    cmp x9,x2
    b.lt .Llarge_cumulative_word
    ret
.Llarge_matrix_address:
    ldr w9,[sp,#232]
    ldr w10,[sp,#192]
    sub w9,w9,w10
    sub w9,w9,#1
    mov w10,#139
    mul w9,w9,w10
    ldr w10,[sp,#236]
    ldr w11,[sp,#196]
    sub w10,w10,w11
    sub w10,w10,#1
    add w9,w9,w10
    add x0,x22,x9,lsl #3
    ret
.Llarge_add_cumulative_product:
    str x30,[sp,#528]
    bl .Llarge_matrix_address
    ldr w9,[sp,#236]
    sub w9,w9,#1
    ldr x10,[sp,#280]
    ldr d1,[x10,x9,lsl #3]
    sub x9,x26,#1
    mul x9,x9,x24
    ldr w10,[sp,#232]
    add x9,x9,x10
    sub x9,x9,#1
    ldr x10,[sp,#256]
    ldr d2,[x10,x9,lsl #3]
    fmul d1,d1,d2
    ldr d0,[x0]
    fadd d0,d0,d1
    str d0,[x0]
    ldr x30,[sp,#528]
    ret
.size md2asm_spline_operator_matrix,.-md2asm_spline_operator_matrix
.section .rodata
.p2align 2
.Llarge_controls:
    .word 0,0,139,0,139,0
    .word 0,0,140,0,140,0
    .word 0,0,140,1,140,1
    .word -1,0,139,0,140,1
    .word 1,0,139,0,139,0
    .word 1,0,139,0,140,0
    .word 1,0,139,0,140,1
.section .note.GNU-stack,"",%progbits
