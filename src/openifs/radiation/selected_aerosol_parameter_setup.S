// Complete selected SU_AERW with active SU_AERP and SU_AEROP parameter children.
// Contract: skills/md2asm/references/openifs/radiation/selected_aerosol_setup.md.
// x0 controls24, x1 eight address/capacity pairs128. Return0/1/2.
// Complete mapped, aligned and disjoint records; FPCR0; fresh descriptor base.
.text
.p2align 4
.global md2asm_initialize_selected_aerosol_parameters
.type md2asm_initialize_selected_aerosol_parameters,%function
md2asm_initialize_selected_aerosol_parameters:
    cbz x0,.Laer_bad_leaf
    cbz x1,.Laer_bad_leaf
    orr x9,x0,x1
    tst x9,#7
    b.ne .Laer_bad_leaf
    adds x9,x1,#128
    b.cs .Laer_bad_leaf
    adds x9,x0,#24
    b.cs .Laer_bad_leaf
    mrs x9,fpcr
    cbnz x9,.Laer_bad_leaf
    sub sp,sp,#320
    stp x29,x30,[sp]
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    str x18,[sp,#64]
    mov x29,sp
    mov x19,x0
    mov x20,x1
    add x9,sp,#128
    add x10,x19,#24
    stp x19,x10,[x9],#16
    add x10,x20,#128
    stp x20,x10,[x9],#16
    adrp x21,.Laer_sizes
    add x21,x21,:lo12:.Laer_sizes
    mov x22,#0
.Laer_ranges:
    add x10,x20,x22,lsl #4
    ldp x11,x12,[x10]
    cbz x11,.Laer_bad_frame
    tst x11,#7
    b.ne .Laer_bad_frame
    ldr x13,[x21,x22,lsl #3]
    cmp x12,x13
    b.lo .Laer_bad_frame
    adds x12,x11,x13
    b.cs .Laer_bad_frame
    stp x11,x12,[x9],#16
    add x22,x22,#1
    cmp x22,#8
    b.lo .Laer_ranges
    add x9,sp,#128
    mov x10,#0
.Laer_overlap_outer:
    add x11,x9,x10,lsl #4
    ldp x12,x13,[x11]
    add x14,x10,#1
.Laer_overlap_inner:
    cmp x14,#10
    b.hs .Laer_overlap_next
    add x11,x9,x14,lsl #4
    ldp x15,x16,[x11]
    cmp x12,x16
    b.hs .Laer_disjoint
    cmp x15,x13
    b.lo .Laer_bad_frame
.Laer_disjoint:
    add x14,x14,#1
    b .Laer_overlap_inner
.Laer_overlap_next:
    add x10,x10,#1
    cmp x10,#9
    b.lo .Laer_overlap_outer
    ldp w9,w10,[x19]
    orr w9,w9,w10
    cbnz w9,.Laer_bad_frame
    ldp w9,w10,[x19,#8]
    cmp w9,#1
    b.ne .Laer_bad_frame
    cbnz w10,.Laer_bad_frame
    ldr w9,[x19,#20]
    mov w10,#20863
    movk w10,#1,lsl #16
    cmp w9,w10
    b.hi .Laer_bad_frame
    ldr x21,[x20]
    ldr x9,[x21,#328]
    cbnz x9,.Laer_bad_frame
    bl __errno_location
    mov x22,x0
    ldr w23,[x0]
// Zero elements still own one allocator token, as in GNU ALLOCATE.
    mov x0,#1
    bl malloc
    cbz x0,.Laer_allocation_failed
    str x0,[x21,#328]
    mov x9,#-1
    str x9,[x21,#336]
    mov x9,#152
    str x9,[x21,#344]
    movz x10,#0x501,lsl #32
    str x10,[x21,#352]
    str x9,[x21,#360]
    mov x9,#1
    stp x9,x9,[x21,#368]
    str xzr,[x21,#384]
    str w23,[x22]
    mov x0,x19
    mov x1,x20
    bl md2asm_selected_aerosol_parameter_fields
    mov w0,#0
    b .Laer_return
.Laer_allocation_failed:
    mov w0,#1
    b .Laer_return
.Laer_bad_frame:
    mov w0,#2
.Laer_return:
    ldr x18,[sp,#64]
    ldp x23,x24,[sp,#48]
    ldp x21,x22,[sp,#32]
    ldp x19,x20,[sp,#16]
    ldp x29,x30,[sp]
    add sp,sp,#320
    ret
.Laer_bad_leaf:
    mov w0,#2
    ret
.size md2asm_initialize_selected_aerosol_parameters,.-md2asm_initialize_selected_aerosol_parameters
.p2align 4
.global md2asm_release_selected_aerosol_parameters
.type md2asm_release_selected_aerosol_parameters,%function
md2asm_release_selected_aerosol_parameters:
    cbz x0,.Laer_bad_leaf
    tst x0,#7
    b.ne .Laer_bad_leaf
    cmp x1,#392
    b.lo .Laer_bad_leaf
    adds x9,x0,#392
    b.cs .Laer_bad_leaf
    stp x19,x20,[sp,#-64]!
    stp x21,x30,[sp,#16]
    str x18,[sp,#32]
    mov x19,x0
    bl __errno_location
    mov x20,x0
    ldr w21,[x0]
    ldr x0,[x19,#328]
    cbz x0,.Laer_release_done
    bl free
    str xzr,[x19,#328]
.Laer_release_done:
    str w21,[x20]
    mov w0,#0
    ldr x18,[sp,#32]
    ldp x21,x30,[sp,#16]
    ldp x19,x20,[sp],#64
    ret
.size md2asm_release_selected_aerosol_parameters,.-md2asm_release_selected_aerosol_parameters
.section .rodata
.p2align 3
.Laer_sizes: .xword 392,440,760,880,344,14856,44,176080
.section .note.GNU-stack,"",%progbits
