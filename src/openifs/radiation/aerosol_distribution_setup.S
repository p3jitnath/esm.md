// Complete selected SUAERL/SUAERH/SUAERV/SU_AERV numerical composition.
// x0 live half-level eta160,x1 three address/capacity pairs48.
// Return0 or2 before mutation; nine source-order owners already exist.
// Contract: skills/md2asm/references/openifs/radiation/aerosol_distribution_setup.md.
.text
.p2align 4
.global md2asm_initialize_selected_aerosol_distribution
.type md2asm_initialize_selected_aerosol_distribution,%function
md2asm_initialize_selected_aerosol_distribution:
    cbz x0,.Lad_bad_leaf
    cbz x1,.Lad_bad_leaf
    orr x9,x0,x1
    tst x9,#7
    b.ne .Lad_bad_leaf
    adds x9,x0,#160
    b.cs .Lad_bad_leaf
    adds x9,x1,#48
    b.cs .Lad_bad_leaf
    mrs x9,fpcr
    cbnz x9,.Lad_bad_leaf
    sub sp,sp,#384
    stp x29,x30,[sp]
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    str x18,[sp,#96]
    mov x29,sp
    mov x19,x0
    mov x20,x1
    add x9,sp,#128
    add x10,x19,#160
    stp x19,x10,[x9],#16
    add x10,x20,#48
    stp x20,x10,[x9],#16
    adrp x10,.Lad_record_sizes
    add x10,x10,:lo12:.Lad_record_sizes
    mov x11,#0
.Lad_record_range:
    add x12,x20,x11,lsl #4
    ldp x13,x14,[x12]
    cbz x13,.Lad_bad_frame
    tst x13,#7
    b.ne .Lad_bad_frame
    ldr x15,[x10,x11,lsl #3]
    cmp x14,x15
    b.lo .Lad_bad_frame
    adds x14,x13,x15
    b.cs .Lad_bad_frame
    stp x13,x14,[x9],#16
    add x11,x11,#1
    cmp x11,#3
    b.lo .Lad_record_range
    ldr x21,[x20]
    ldr x22,[x20,#16]
    ldr x23,[x20,#32]
    adrp x24,.Laerosol_distribution_owners
    add x24,x24,:lo12:.Laerosol_distribution_owners
    mov x25,#0
// Exact typed descriptors admit only the owned twenty-element source views.
.Lad_owner_range:
    add x10,x24,x25,lsl #3
    ldp w11,w12,[x10]
    cmp w11,#0
    csel x13,x22,x23,eq
    add x13,x13,x12
    ldr x14,[x13]
    cbz x14,.Lad_bad_frame
    tst x14,#7
    b.ne .Lad_bad_frame
    adds x15,x14,#160
    b.cs .Lad_bad_frame
    stp x14,x15,[x9],#16
    adrp x14,.Lad_descriptor_signature
    add x14,x14,:lo12:.Lad_descriptor_signature
    mov x15,#0
.Lad_descriptor_word:
    add x16,x13,#8
    ldr x16,[x16,x15,lsl #3]
    ldr x17,[x14,x15,lsl #3]
    cmp x16,x17
    b.ne .Lad_bad_frame
    add x15,x15,#1
    cmp x15,#7
    b.lo .Lad_descriptor_word
    add x25,x25,#1
    cmp x25,#9
    b.lo .Lad_owner_range
// Every explicit and owner span is pairwise disjoint.
    add x9,sp,#128
    mov x10,#0
.Lad_span_outer:
    add x11,x9,x10,lsl #4
    ldp x12,x13,[x11]
    add x14,x10,#1
.Lad_span_inner:
    cmp x14,#14
    b.hs .Lad_span_next
    add x11,x9,x14,lsl #4
    ldp x15,x16,[x11]
    cmp x12,x16
    b.hs .Lad_span_apart
    cmp x15,x13
    b.lo .Lad_bad_frame
.Lad_span_apart:
    add x14,x14,#1
    b .Lad_span_inner
.Lad_span_next:
    add x10,x10,#1
    cmp x10,#13
    b.lo .Lad_span_outer
// Integer representations validate finite coordinates without changing FP status.
    adrp x9,.Lad_one
    ldr x9,[x9,:lo12:.Lad_one]
    ldr x10,[x19]
    lsl x11,x10,#1
    cbnz x11,.Lad_nonzero_first
    mov x10,#0
.Lad_nonzero_first:
    cmp x10,x9
    b.hi .Lad_bad_frame
    mov x11,#1
.Lad_eta_next:
    ldr x12,[x19,x11,lsl #3]
    cmp x12,x10
    b.ls .Lad_bad_frame
    cmp x12,x9
    b.hi .Lad_bad_frame
    mov x10,x12
    add x11,x11,#1
    cmp x11,#20
    b.lo .Lad_eta_next
    cmp x10,x9
    b.ne .Lad_bad_frame
    adrp x9,.Lad_positive_infinity
    ldr x9,[x9,:lo12:.Lad_positive_infinity]
    add x10,x23,#656
    mov x11,#0
.Lad_height_check:
    ldr x12,[x10,x11,lsl #3]
    cbz x12,.Lad_bad_frame
    cmp x12,x9
    b.hs .Lad_bad_frame
    add x11,x11,#1
    cmp x11,#5
    b.lo .Lad_height_check
    mov x11,#5
.Lad_background_check:
    ldr x12,[x10,x11,lsl #3]
    lsl x13,x12,#1
    cbz x13,.Lad_background_ok
    cmp x12,x9
    b.hs .Lad_bad_frame
.Lad_background_ok:
    add x11,x11,#1
    cmp x11,#7
    b.lo .Lad_background_check
    mov x0,x21
    bl md2asm_aerosol_longwave_absorption_fields
    mov x0,x22
    bl md2asm_aerosol_horizontal_distribution_fields
    mov x0,x19
    mov x1,x22
    mov x2,x23
    bl md2asm_legacy_aerosol_vertical_profiles
    mov x0,x19
    mov x1,x23
    bl md2asm_macc_aerosol_vertical_profiles
    mov w0,#0
    b .Lad_return
.Lad_bad_frame:
    mov w0,#2
.Lad_return:
    ldr x18,[sp,#96]
    ldp x27,x28,[sp,#80]
    ldp x25,x26,[sp,#64]
    ldp x23,x24,[sp,#48]
    ldp x21,x22,[sp,#32]
    ldp x19,x20,[sp,#16]
    ldp x29,x30,[sp]
    add sp,sp,#384
    ret
.Lad_bad_leaf:
    mov w0,#2
    ret
.size md2asm_initialize_selected_aerosol_distribution,.-md2asm_initialize_selected_aerosol_distribution
.section .rodata
.p2align 3
.Lad_record_sizes: .xword 10744,4232,2040
.Lad_descriptor_signature: .xword -1,8,0x0000030100000000,8,1,1,20
.Lad_one: .double 1.0
.Lad_positive_infinity: .xword 0x7ff0000000000000
#include "aerosol_distribution_owners.inc.S"
.section .note.GNU-stack,"",%progbits
