// Exact nine-array SUALLO segment, separate from the later numerical setup.
// x0 TEAERD4232,x1 capacity,x2 TERAD2040,x3 capacity. Return0/1/2.
// Contract: skills/md2asm/references/openifs/radiation/aerosol_distribution_setup.md.
.macro ADMIT_AEROSOL_RECORDS
    cbz x0,.Lad_storage_bad_leaf
    cbz x2,.Lad_storage_bad_leaf
    orr x9,x0,x2
    tst x9,#7
    b.ne .Lad_storage_bad_leaf
    mov x9,#4232
    cmp x1,x9
    b.lo .Lad_storage_bad_leaf
    cmp x3,#2040
    b.lo .Lad_storage_bad_leaf
    adds x10,x0,x9
    b.cs .Lad_storage_bad_leaf
    adds x11,x2,#2040
    b.cs .Lad_storage_bad_leaf
    cmp x0,x11
    b.hs .Lad_storage_apart\@
    cmp x2,x10
    b.lo .Lad_storage_bad_leaf
.Lad_storage_apart\@:
.endm
.text
.p2align 4
.global md2asm_create_selected_aerosol_vertical_storage
.type md2asm_create_selected_aerosol_vertical_storage,%function
md2asm_create_selected_aerosol_vertical_storage:
    ADMIT_AEROSOL_RECORDS
    mrs x9,fpcr
    cbnz x9,.Lad_storage_bad_leaf
    sub sp,sp,#768
    stp x29,x30,[sp]
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    str x18,[sp,#96]
    mov x29,sp
    mov x19,x0
    mov x20,x2
    adrp x23,.Laerosol_distribution_owners
    add x23,x23,:lo12:.Laerosol_distribution_owners
    add x25,sp,#192
    mov x24,#0
// Check all public bases before making a private descriptor copy.
.Lad_storage_fresh:
    add x9,x23,x24,lsl #3
    ldp w10,w11,[x9]
    cmp w10,#0
    csel x12,x19,x20,eq
    ldr x13,[x12,x11]
    cbnz x13,.Lad_storage_bad_frame
    add x24,x24,#1
    cmp x24,#9
    b.lo .Lad_storage_fresh
    mov x24,#0
.Lad_storage_copy_private:
    add x9,x23,x24,lsl #3
    ldp w10,w11,[x9]
    cmp w10,#0
    csel x1,x19,x20,eq
    add x1,x1,x11
    add x0,x25,x24,lsl #6
    mov x2,#64
    bl memcpy
    add x24,x24,#1
    cmp x24,#9
    b.lo .Lad_storage_copy_private
    bl __errno_location
    mov x21,x0
    ldr w22,[x0]
    mov x24,#0
.Lad_storage_allocate:
    add x0,x25,x24,lsl #6
    mov w1,#1
    adrp x2,.Laerosol_distribution_shape
    add x2,x2,:lo12:.Laerosol_distribution_shape
    mov w3,#1
    mov w4,#0
    bl md2asm_allocate_radiation_flux_array
    cbnz w0,.Lad_storage_failed
    add x24,x24,#1
    cmp x24,#9
    b.lo .Lad_storage_allocate
    mov x24,#0
.Lad_storage_commit:
    add x9,x23,x24,lsl #3
    ldp w10,w11,[x9]
    cmp w10,#0
    csel x0,x19,x20,eq
    add x0,x0,x11
    add x1,x25,x24,lsl #6
    mov x2,#64
    bl memcpy
    add x24,x24,#1
    cmp x24,#9
    b.lo .Lad_storage_commit
    str w22,[x21]
    mov w26,#0
    b .Lad_storage_return
.Lad_storage_failed:
    ldr w27,[x21]
    mov x24,#0
.Lad_storage_cleanup:
    add x9,x25,x24,lsl #6
    ldr x0,[x9]
    cbz x0,.Lad_storage_cleanup_next
    bl free
.Lad_storage_cleanup_next:
    add x24,x24,#1
    cmp x24,#9
    b.lo .Lad_storage_cleanup
    str w27,[x21]
    mov w26,#1
    b .Lad_storage_return
.Lad_storage_bad_frame:
    mov w26,#2
.Lad_storage_return:
    mov w0,w26
    ldr x18,[sp,#96]
    ldp x27,x28,[sp,#80]
    ldp x25,x26,[sp,#64]
    ldp x23,x24,[sp,#48]
    ldp x21,x22,[sp,#32]
    ldp x19,x20,[sp,#16]
    ldp x29,x30,[sp]
    add sp,sp,#768
    ret
.Lad_storage_bad_leaf:
    mov w0,#2
    ret
.size md2asm_create_selected_aerosol_vertical_storage,.-md2asm_create_selected_aerosol_vertical_storage
.p2align 4
.global md2asm_release_selected_aerosol_vertical_storage
.type md2asm_release_selected_aerosol_vertical_storage,%function
md2asm_release_selected_aerosol_vertical_storage:
    ADMIT_AEROSOL_RECORDS
    stp x19,x20,[sp,#-96]!
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x25,x30,[sp,#48]
    str x18,[sp,#64]
    mov x19,x0
    mov x20,x2
    bl __errno_location
    mov x21,x0
    ldr w22,[x0]
    adrp x23,.Laerosol_distribution_owners
    add x23,x23,:lo12:.Laerosol_distribution_owners
    mov x24,#0
.Lad_release:
    add x9,x23,x24,lsl #3
    ldp w10,w11,[x9]
    cmp w10,#0
    csel x25,x19,x20,eq
    add x25,x25,x11
    ldr x0,[x25]
    cbz x0,.Lad_release_next
    bl free
    str xzr,[x25]
.Lad_release_next:
    add x24,x24,#1
    cmp x24,#9
    b.lo .Lad_release
    str w22,[x21]
    mov w0,#0
    ldr x18,[sp,#64]
    ldp x25,x30,[sp,#48]
    ldp x23,x24,[sp,#32]
    ldp x21,x22,[sp,#16]
    ldp x19,x20,[sp],#96
    ret
.size md2asm_release_selected_aerosol_vertical_storage,.-md2asm_release_selected_aerosol_vertical_storage
#include "aerosol_distribution_owners.inc.S"
.section .note.GNU-stack,"",%progbits
