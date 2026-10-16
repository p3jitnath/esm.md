// Complete selected SUWCOU, SUPHLI and SUMETHOX setup in source order.
// x0 live text,x1 bytes1..262144,x2 upstream40,x3 five record pairs80.
// Return0 success or2 atomic rejection; no heap. FPCR0 and mapped views.
// Contract: skills/md2asm/references/openifs/setup/ecmwf_physics_tail.md.
.text
.p2align 4
.global md2asm_initialize_selected_ecmwf_physics_tail
.type md2asm_initialize_selected_ecmwf_physics_tail,%function
md2asm_initialize_selected_ecmwf_physics_tail:
    cbz x0,.Ltail_bad_leaf
    cbz x1,.Ltail_bad_leaf
    cbz x2,.Ltail_bad_leaf
    cbz x3,.Ltail_bad_leaf
    cmp x1,#64,lsl #12
    b.hi .Ltail_bad_leaf
    orr x9,x2,x3
    tst x9,#7
    b.ne .Ltail_bad_leaf
    adds x9,x3,#80
    b.cs .Ltail_bad_leaf
    adds x9,x2,#40
    b.cs .Ltail_bad_leaf
    adds x9,x0,x1
    b.cs .Ltail_bad_leaf
    mrs x9,fpcr
    cbnz x9,.Ltail_bad_leaf
    sub sp,sp,#256
    stp x29,x30,[sp]
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    str x18,[sp,#64]
    mov x29,sp
    mov x19,x0
    mov x20,x1
    mov x21,x2
    mov x22,x3
    add x9,sp,#96
    add x10,x19,x20
    stp x19,x10,[x9],#16
    add x10,x21,#40
    stp x21,x10,[x9],#16
    add x10,x22,#80
    stp x22,x10,[x9],#16
    adrp x23,.Ltail_record_sizes
    add x23,x23,:lo12:.Ltail_record_sizes
    mov x24,#0
.Ltail_output_ranges:
    add x10,x22,x24,lsl #4
    ldp x11,x12,[x10]
    cbz x11,.Ltail_bad_frame
    tst x11,#7
    b.ne .Ltail_bad_frame
    ldr x13,[x23,x24,lsl #3]
    cmp x12,x13
    b.lo .Ltail_bad_frame
    adds x12,x11,x13
    b.cs .Ltail_bad_frame
    stp x11,x12,[x9],#16
    add x24,x24,#1
    cmp x24,#5
    b.lo .Ltail_output_ranges
    add x9,sp,#96
    mov x10,#0
.Ltail_span_outer:
    add x11,x9,x10,lsl #4
    ldp x12,x13,[x11]
    add x14,x10,#1
.Ltail_span_inner:
    cmp x14,#8
    b.hs .Ltail_span_next
    add x11,x9,x14,lsl #4
    ldp x15,x16,[x11]
    cmp x12,x16
    b.hs .Ltail_span_apart
    cmp x15,x13
    b.lo .Ltail_bad_frame
.Ltail_span_apart:
    add x14,x14,#1
    b .Ltail_span_inner
.Ltail_span_next:
    add x10,x10,#1
    cmp x10,#7
    b.lo .Ltail_span_outer
    ldr w9,[x21]
    adrp x10,.Ltail_date_bounds
    add x10,x10,:lo12:.Ltail_date_bounds
    ldp w10,w11,[x10]
    cmp w9,w10
    b.lo .Ltail_bad_frame
    cmp w9,w11
    b.hi .Ltail_bad_frame
    ldr w9,[x21,#4]
    mov w10,#20863
    movk w10,#1,lsl #16
    cmp w9,w10
    b.hi .Ltail_bad_frame
    mov x9,#8
.Ltail_logical_check:
    ldr w10,[x21,x9]
    cmp w10,#1
    b.hi .Ltail_bad_frame
    add x9,x9,#4
    cmp x9,#20
    b.lo .Ltail_logical_check
// Positive finite source thermal limits, in kelvin, with ice no warmer than water.
    ldp x9,x10,[x21,#24]
    cbz x9,.Ltail_bad_frame
    cbz x10,.Ltail_bad_frame
    adrp x11,.Ltail_max_temperature
    ldr x11,[x11,:lo12:.Ltail_max_temperature]
    cmp x9,x11
    b.hi .Ltail_bad_frame
    cmp x10,x9
    b.hi .Ltail_bad_frame
    ldr x9,[x22,#32]
    ldr w10,[x9,#8]
    cmp w10,#1
    b.hi .Ltail_bad_frame
    ldr w10,[x9,#28]
    cbnz w10,.Ltail_bad_frame
// Reuse the unchanged bounded first-source-marker empty-group parser.
    mov x0,x19
    mov x1,x20
    adrp x2,.Ltail_naep
    add x2,x2,:lo12:.Ltail_naep
    mov x3,#7
    bl md2asm_require_empty_physics_group
    cbnz w0,.Ltail_bad_frame
    mov x0,x19
    mov x1,x20
    adrp x2,.Ltail_meth
    add x2,x2,:lo12:.Ltail_meth
    mov x3,#9
    bl md2asm_require_empty_physics_group
    cbnz w0,.Ltail_bad_frame
    mov x0,x21
    ldr x1,[x22]
    bl md2asm_wave_coupling_startup_fields
    mov x0,x21
    ldr x1,[x22,#16]
    ldr x2,[x22,#32]
    ldr x3,[x22,#48]
    bl md2asm_linearized_physics_parameter_fields
    ldr x0,[x22,#64]
    bl md2asm_methane_oxidation_parameter_fields
    mov w0,#0
    b .Ltail_return
.Ltail_bad_frame:
    mov w0,#2
.Ltail_return:
    ldr x18,[sp,#64]
    ldp x23,x24,[sp,#48]
    ldp x21,x22,[sp,#32]
    ldp x19,x20,[sp,#16]
    ldp x29,x30,[sp]
    add sp,sp,#256
    ret
.Ltail_bad_leaf:
    mov w0,#2
    ret
.size md2asm_initialize_selected_ecmwf_physics_tail,.-md2asm_initialize_selected_ecmwf_physics_tail
.section .rodata
.p2align 3
.Ltail_record_sizes: .xword 1024,120,100,32,72
.Ltail_date_bounds: .word 10000000,99999999
.Ltail_max_temperature: .double 400.0
.Ltail_naep: .ascii "NAEPHLI"
.Ltail_meth: .ascii "NAMMETHOX"
.section .note.GNU-stack,"",%progbits
