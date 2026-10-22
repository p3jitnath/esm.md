/* Complete selected SUVERTFEB composition for 19 or 137 levels.
 * Contract: skills/md2asm/references/openifs/setup/selected_spline_operator_contract.md.
 * x0=control[6], x1=eta input[21 or 139], x2=eta output[rows],
 * x3=column-major output[rows, dimension], x4=workspace, x5=&byte capacity.
 * Workspace: 61,856 bytes for dimension 21; 1,954,048 bytes for dimension 139.
 * Return 0 means complete, 2 means preflight rejection, 3 means child failure.
 * Stack: 512 or 1,456 bytes, aligned to 16 bytes. Large matrices use the
 * qualified public library services; no original OpenIFS callable is used.
 */
.arch armv8-a
.text
.p2align 4
.global md2asm_selected_spline_operator
.type md2asm_selected_spline_operator,%function
md2asm_selected_spline_operator:
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
    mrs x9,fpcr
    cbnz x9,.Lreject
    ldr x9,[x5]
    mov x10,#61856
    cmp x9,x10
    b.lo .Lreject
    adrp x9,.Lcontrols
    add x9,x9,:lo12:.Lcontrols
    mov w10,#5
.Ltuple:
    mov x11,#0
.Ltuple_word:
    ldr w12,[x0,x11,lsl #2]
    ldr w13,[x9,x11,lsl #2]
    cmp w12,w13
    b.ne .Lnext_tuple
    add x11,x11,#1
    cmp x11,#6
    b.lt .Ltuple_word
    b .Leta_guard
.Lnext_tuple:
    add x9,x9,#24
    subs w10,w10,#1
    b.ne .Ltuple
    b .Llarge_entry
.Leta_guard:
    ldr x9,[x1]
    cbnz x9,.Lreject
    ldr x9,[x1,#160]
    mov x10,#0x3ff0000000000000
    cmp x9,x10
    b.ne .Lreject
    fmov d1,xzr
    mov x9,#1
.Leta_order:
    ldr x10,[x1,x9,lsl #3]
    ubfx x11,x10,#52,#11
    cmp x11,#2047
    b.eq .Lreject
    fmov d0,x10
    fcmp d0,d1
    b.le .Lreject
    fmov d1,d0
    add x9,x9,#1
    cmp x9,#21
    b.lt .Leta_order
    ldr w12,[x0,#4]
    mov x9,#0
    add x10,x1,#8
.Leta_subset:
    ldr x11,[x10,x9,lsl #3]
    ldr x13,[x2,x9,lsl #3]
    cmp x11,x13
    b.ne .Lreject
    add x9,x9,#1
    cmp w9,w12
    b.lt .Leta_subset
    stp x29,x30,[sp,#-512]!
    mov x29,sp
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    mov x19,x0
    mov x20,x1
    mov x21,x2
    mov x22,x3
    mov x23,x4
    ldr w25,[x19,#8]
    ldr w9,[x19,#12]
    add w24,w25,w9
    add w24,w24,#21
    str xzr,[sp,#128]
    mov x9,#0x3ff0000000000000
    str x9,[sp,#136]
    mov w9,#4
    str w9,[sp,#144]
    mov w9,#21
    str w9,[sp,#148]
    str w9,[sp,#152]
    str w24,[sp,#156]
    stp xzr,xzr,[sp,#160]
    mov x9,#0x3ff0000000000000
    str x9,[sp,#176]
    mov w9,#4
    str w9,[sp,#184]
    str xzr,[sp,#192]
    mov x9,#23648
    str x9,[sp,#272]
    str xzr,[sp,#464]
    str w25,[sp,#472]
    str wzr,[sp,#476]
    ldr w9,[x19,#12]
    str w9,[sp,#480]
    str wzr,[sp,#484]
    mov x26,#0
.Ltransforms:
    add x0,sp,#128
    add x1,sp,#144
    add x2,x23,x26,lsl #7
    bl md2asm_spline_sampling_transform
    cbnz w0,.Lfailure
    add x26,x26,#1
    cmp x26,#3
    b.lt .Ltransforms
    mov x26,#0
.Lknots:
    bl .Lrole_pointers
    add x0,sp,#144
    add x1,sp,#188
    add x2,sp,#148
    mov x3,x20
    mov x4,x11
    bl md2asm_vertical_spline_knots
    cbnz w0,.Lfailure
    add x26,x26,#1
    cmp x26,#3
    b.lt .Lknots
    mov x26,#0
.Lpieces:
    bl .Lrole_pointers
    add x0,sp,#184
    add x1,sp,#160
    add x2,sp,#128
    mov x3,x10
    mov x4,x11
    mov x5,x12
    mov x6,x13
    bl md2asm_spline_piece_coefficients
    cbnz w0,.Lfailure
    add x26,x26,#1
    cmp x26,#3
    b.lt .Lpieces
    mov x26,#0
.Lboundaries:
    bl .Lrole_pointers
    add x0,sp,#464
    add x1,sp,#464
    cbz x26,.Lboundary_call
    add x0,sp,#472
    add x1,sp,#480
.Lboundary_call:
    add x2,sp,#144
    add x3,sp,#188
    mov x4,x12
    bl md2asm_spline_value_boundaries
    cbnz w0,.Lfailure
    add x26,x26,#1
    cmp x26,#3
    b.lt .Lboundaries
    stp wzr,wzr,[sp,#200]
    str w24,[sp,#208]
    str w25,[sp,#212]
    str w24,[sp,#216]
    str w25,[sp,#220]
    add x9,x23,#128
    add x10,x23,#256
    stp x9,x10,[sp,#224]
    add x9,x23,#592
    add x10,x23,#800
    stp x9,x10,[sp,#240]
    add x9,x23,#3824
    mov x10,#6640
    add x10,x23,x10
    stp x9,x10,[sp,#256]
    mov x28,#9984
    bl .Lmatrix_call
    cbnz w0,.Lfailure
    ldr w9,[x19]
    str w9,[sp,#200]
    mov w9,#21
    str w9,[sp,#208]
    str wzr,[sp,#212]
    str x23,[sp,#224]
    add x9,x23,#384
    str x9,[sp,#240]
    add x9,x23,#1008
    str x9,[sp,#256]
    mov x28,#13512
    bl .Lmatrix_call
    cbnz w0,.Lfailure
    mov x9,#0
.Lclear_types:
    add x10,sp,#296
    str wzr,[x10,x9,lsl #2]
    add x10,sp,#380
    str wzr,[x10,x9,lsl #2]
    add x9,x9,#1
    cmp x9,#21
    b.lt .Lclear_types
    ldr w9,[x19,#16]
    str w9,[sp,#296]
    ldr w9,[x19,#20]
    str w9,[sp,#376]
    mov w9,#21
    str w9,[sp,#280]
    str w9,[sp,#284]
    str xzr,[sp,#288]
    add x0,sp,#280
    add x1,sp,#160
    mov x2,x20
    add x3,sp,#296
    add x4,x23,#384
    add x5,x23,#1008
    mov x6,#17040
    add x6,x23,x6
    bl md2asm_spline_evaluation_matrix
    cbnz w0,.Lfailure
    ldr w9,[x19,#4]
    str w9,[sp,#280]
    str w24,[sp,#284]
    str w25,[sp,#288]
    add x0,sp,#280
    add x1,sp,#160
    mov x2,x21
    add x3,sp,#380
    add x4,x23,#592
    add x5,x23,#3824
    mov x6,#20568
    add x6,x23,x6
    bl md2asm_spline_evaluation_matrix
    cbnz w0,.Lfailure
    mov w9,#1
    str w9,[sp,#184]
    add x0,sp,#184
    add x1,sp,#148
    mov x2,#9984
    add x2,x23,x2
    mov x3,#24096
    add x3,x23,x3
    bl md2asm_selected_spline_inverse
    cbnz w0,.Lfailure
    add x0,sp,#184
    add x1,sp,#148
    mov x2,#17040
    add x2,x23,x2
    mov x3,#27624
    add x3,x23,x3
    bl md2asm_selected_spline_inverse
    cbnz w0,.Lfailure
    add x0,sp,#148
    mov x1,#13512
    add x1,x23,x1
    mov x2,#27624
    add x2,x23,x2
    mov x3,#31152
    add x3,x23,x3
    bl md2asm_spline_matrix_product
    cbnz w0,.Lfailure
    add x0,sp,#148
    mov x1,#24096
    add x1,x23,x1
    mov x2,#31152
    add x2,x23,x2
    mov x3,#34680
    add x3,x23,x3
    bl md2asm_spline_matrix_product
    cbnz w0,.Lfailure
    add x0,x19,#4
    mov x1,#20568
    add x1,x23,x1
    mov x2,#34680
    add x2,x23,x2
    mov x3,x22
    bl md2asm_spline_matrix_product
    cbnz w0,.Lfailure
    mov w0,#0
    b .Lreturn
.Lfailure:
    mov w0,#3
.Lreturn:
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp x29,x30,[sp]
    add sp,sp,#512
    ret
.Lrole_pointers:
    mov w27,#21
    cmp x26,#0
    csel w27,w27,w24,eq
    str w27,[sp,#188]
    add x10,x23,x26,lsl #7
    mov x9,#208
    madd x11,x26,x9,x23
    add x11,x11,#384
    mov x9,#2816
    madd x12,x26,x9,x23
    add x12,x12,#1008
    mov x9,#176
    madd x13,x26,x9,x23
    mov x9,#9456
    add x13,x13,x9
    ret
.Lmatrix_call:
    add x0,sp,#200
    add x1,sp,#160
    add x2,sp,#224
    add x3,x23,x28
    mov x4,#38208
    add x4,x23,x4
    add x5,sp,#272
    b md2asm_spline_operator_matrix
.Lreject:
    mov w0,#2
    ret
.Llarge_entry:
    cbz x0,.Llarge_reject
    cbz x1,.Llarge_reject
    cbz x2,.Llarge_reject
    cbz x3,.Llarge_reject
    cbz x4,.Llarge_reject
    cbz x5,.Llarge_reject
    tst x0,#3
    b.ne .Llarge_reject
    orr x9,x1,x2
    orr x9,x9,x3
    orr x9,x9,x4
    orr x9,x9,x5
    tst x9,#7
    b.ne .Llarge_reject
    mrs x9,fpcr
    cbnz x9,.Llarge_reject
    ldr x9,[x5]
    movz x10,#53504
    movk x10,#29,lsl #16
    cmp x9,x10
    b.lo .Llarge_reject
    adrp x9,.Llarge_controls
    add x9,x9,:lo12:.Llarge_controls
    mov w10,#5
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
    b .Llarge_eta_guard
.Llarge_next_tuple:
    add x9,x9,#24
    subs w10,w10,#1
    b.ne .Llarge_tuple
    b .Llarge_reject
.Llarge_eta_guard:
    ldr x9,[x1]
    cbnz x9,.Llarge_reject
    ldr x9,[x1,#1104]
    mov x10,#0x3ff0000000000000
    cmp x9,x10
    b.ne .Llarge_reject
    fmov d1,xzr
    mov x9,#1
.Llarge_eta_order:
    ldr x10,[x1,x9,lsl #3]
    ubfx x11,x10,#52,#11
    cmp x11,#2047
    b.eq .Llarge_reject
    fmov d0,x10
    fcmp d0,d1
    b.le .Llarge_reject
    fmov d1,d0
    add x9,x9,#1
    cmp x9,#139
    b.lt .Llarge_eta_order
    ldr w12,[x0,#4]
    mov x9,#0
    add x10,x1,#8
.Llarge_eta_subset:
    ldr x11,[x10,x9,lsl #3]
    ldr x13,[x2,x9,lsl #3]
    cmp x11,x13
    b.ne .Llarge_reject
    add x9,x9,#1
    cmp w9,w12
    b.lt .Llarge_eta_subset
    sub sp,sp,#1456
    stp x29,x30,[sp]
    mov x29,sp
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    mov x19,x0
    mov x20,x1
    mov x21,x2
    mov x22,x3
    mov x23,x4
    ldr w25,[x19,#8]
    ldr w9,[x19,#12]
    add w24,w25,w9
    add w24,w24,#139
    str xzr,[sp,#128]
    mov x9,#0x3ff0000000000000
    str x9,[sp,#136]
    mov w9,#4
    str w9,[sp,#144]
    mov w9,#139
    str w9,[sp,#148]
    str w9,[sp,#152]
    str w24,[sp,#156]
    stp xzr,xzr,[sp,#160]
    mov x9,#0x3ff0000000000000
    str x9,[sp,#176]
    mov w9,#4
    str w9,[sp,#184]
    str xzr,[sp,#192]
    movz x9,#1184
    movk x9,#10,lsl #16
    str x9,[sp,#272]
    str xzr,[sp,#1408]
    str w25,[sp,#1416]
    str wzr,[sp,#1420]
    ldr w9,[x19,#12]
    str w9,[sp,#1424]
    str wzr,[sp,#1428]
    mov x26,#0
.Llarge_transforms:
    add x0,sp,#128
    add x1,sp,#144
    add x2,x23,x26,lsl #7
    bl md2asm_spline_sampling_transform
    cbnz w0,.Llarge_failure
    add x26,x26,#1
    cmp x26,#3
    b.lt .Llarge_transforms
    mov x26,#0
.Llarge_knots:
    bl .Llarge_role_pointers
    add x0,sp,#144
    add x1,sp,#188
    add x2,sp,#148
    mov x3,x20
    mov x4,x11
    bl md2asm_vertical_spline_knots
    cbnz w0,.Llarge_failure
    add x26,x26,#1
    cmp x26,#3
    b.lt .Llarge_knots
    mov x26,#0
.Llarge_pieces:
    bl .Llarge_role_pointers
    add x0,sp,#184
    add x1,sp,#160
    add x2,sp,#128
    mov x3,x10
    mov x4,x11
    mov x5,x12
    mov x6,x13
    bl md2asm_spline_piece_coefficients
    cbnz w0,.Llarge_failure
    add x26,x26,#1
    cmp x26,#3
    b.lt .Llarge_pieces
    mov x26,#0
.Llarge_boundaries:
    bl .Llarge_role_pointers
    add x0,sp,#1408
    add x1,sp,#1408
    cbz x26,.Llarge_boundary_call
    add x0,sp,#1416
    add x1,sp,#1424
.Llarge_boundary_call:
    add x2,sp,#144
    add x3,sp,#188
    mov x4,x12
    bl md2asm_spline_value_boundaries
    cbnz w0,.Llarge_failure
    add x26,x26,#1
    cmp x26,#3
    b.lt .Llarge_boundaries
    stp wzr,wzr,[sp,#200]
    str w24,[sp,#208]
    str w25,[sp,#212]
    str w24,[sp,#216]
    str w25,[sp,#220]
    add x9,x23,#128
    add x10,x23,#256
    stp x9,x10,[sp,#224]
    add x9,x23,#1536
    add x10,x23,#2688
    stp x9,x10,[sp,#240]
    movz x9,#21760
    movk x9,#0,lsl #16
    add x9,x23,x9
    mov x10,#39680
    add x10,x23,x10
    stp x9,x10,[sp,#256]
    mov x28,#60960
    bl .Llarge_matrix_call
    cbnz w0,.Llarge_failure
    ldr w9,[x19]
    str w9,[sp,#200]
    mov w9,#139
    str w9,[sp,#208]
    str wzr,[sp,#212]
    str x23,[sp,#224]
    add x9,x23,#384
    str x9,[sp,#240]
    add x9,x23,#3840
    str x9,[sp,#256]
    movz x28,#18920
    movk x28,#3,lsl #16
    bl .Llarge_matrix_call
    cbnz w0,.Llarge_failure
    mov x9,#0
.Llarge_clear_types:
    add x10,sp,#296
    str wzr,[x10,x9,lsl #2]
    add x10,sp,#852
    str wzr,[x10,x9,lsl #2]
    add x9,x9,#1
    cmp x9,#139
    b.lt .Llarge_clear_types
    ldr w9,[x19,#16]
    str w9,[sp,#296]
    ldr w9,[x19,#20]
    str w9,[sp,#848]
    mov w9,#139
    str w9,[sp,#280]
    str w9,[sp,#284]
    str xzr,[sp,#288]
    add x0,sp,#280
    add x1,sp,#160
    mov x2,x20
    add x3,sp,#296
    add x4,x23,#384
    add x5,x23,#3840
    movz x6,#42416
    movk x6,#5,lsl #16
    add x6,x23,x6
    bl md2asm_spline_evaluation_matrix
    cbnz w0,.Llarge_failure
    ldr w9,[x19,#4]
    str w9,[sp,#280]
    str w24,[sp,#284]
    str w25,[sp,#288]
    add x0,sp,#280
    add x1,sp,#160
    mov x2,x21
    add x3,sp,#852
    add x4,x23,#1536
    movz x5,#21760
    movk x5,#0,lsl #16
    add x5,x23,x5
    movz x6,#376
    movk x6,#8,lsl #16
    add x6,x23,x6
    bl md2asm_spline_evaluation_matrix
    cbnz w0,.Llarge_failure
    mov w9,#1
    str w9,[sp,#184]
    add x0,sp,#184
    add x1,sp,#148
    mov x2,#60960
    add x2,x23,x2
    movz x3,#23872
    movk x3,#10,lsl #16
    add x3,x23,x3
    bl md2asm_library_spline_matrix_inverse
    cbnz w0,.Llarge_failure
    add x0,sp,#184
    add x1,sp,#148
    movz x2,#42416
    movk x2,#5,lsl #16
    add x2,x23,x2
    movz x3,#47368
    movk x3,#12,lsl #16
    add x3,x23,x3
    bl md2asm_library_spline_matrix_inverse
    cbnz w0,.Llarge_failure
    add x0,sp,#148
    movz x1,#18920
    movk x1,#3,lsl #16
    add x1,x23,x1
    movz x2,#47368
    movk x2,#12,lsl #16
    add x2,x23,x2
    movz x3,#5328
    movk x3,#15,lsl #16
    add x3,x23,x3
    bl md2asm_library_spline_matrix_product
    cbnz w0,.Llarge_failure
    add x0,sp,#148
    movz x1,#23872
    movk x1,#10,lsl #16
    add x1,x23,x1
    movz x2,#5328
    movk x2,#15,lsl #16
    add x2,x23,x2
    movz x3,#28824
    movk x3,#17,lsl #16
    add x3,x23,x3
    bl md2asm_library_spline_matrix_product
    cbnz w0,.Llarge_failure
    add x0,x19,#4
    movz x1,#376
    movk x1,#8,lsl #16
    add x1,x23,x1
    movz x2,#28824
    movk x2,#17,lsl #16
    add x2,x23,x2
    mov x3,x22
    bl md2asm_library_spline_matrix_product
    cbnz w0,.Llarge_failure
    mov w0,#0
    b .Llarge_return
.Llarge_failure:
    mov w0,#3
.Llarge_return:
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp x29,x30,[sp]
    add sp,sp,#1456
    ret
.Llarge_role_pointers:
    mov w27,#139
    cmp x26,#0
    csel w27,w27,w24,eq
    str w27,[sp,#188]
    add x10,x23,x26,lsl #7
    mov x9,#1152
    madd x11,x26,x9,x23
    add x11,x11,#384
    mov x9,#17920
    madd x12,x26,x9,x23
    add x12,x12,#3840
    mov x9,#1120
    madd x13,x26,x9,x23
    mov x9,#57600
    add x13,x13,x9
    ret
.Llarge_matrix_call:
    add x0,sp,#200
    add x1,sp,#160
    add x2,sp,#224
    add x3,x23,x28
    movz x4,#52320
    movk x4,#19,lsl #16
    add x4,x23,x4
    add x5,sp,#272
    b md2asm_spline_operator_matrix
.Llarge_reject:
    mov w0,#2
    ret
.size md2asm_selected_spline_operator,.-md2asm_selected_spline_operator
.section .rodata
.p2align 2
.Lcontrols:
    .word -1,20,1,0,1,1
    .word 1,19,0,0,0,0
    .word 1,19,0,1,0,1
    .word 1,19,1,0,1,0
    .word 1,19,0,0,1,1

.Llarge_controls:
    .word -1,138,1,0,1,1
    .word 1,137,0,0,0,0
    .word 1,137,0,1,0,1
    .word 1,137,1,0,1,0
    .word 1,137,0,0,1,1
.section .note.GNU-stack,"",%progbits
