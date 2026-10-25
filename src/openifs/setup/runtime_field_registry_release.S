// Retire the complete successful registry through its source-defined owners.
// Contract skills/md2asm/references/openifs/setup/runtime_field_registry_release.md.
// x0 mapped FIELDS529288 or null, x1 capacity. Return0 success or2 prewrite refusal.
// All private clones and field consumers must have finished before this call.
.arch armv8.2-a
.text
.p2align 4
.global md2asm_release_runtime_field_registry
.type md2asm_release_runtime_field_registry,%function
md2asm_release_runtime_field_registry:
    cbz x0,.Lregistry_release_empty
    tst x0,#7
    b.ne .Lregistry_release_reject
    movz x2,#5000
    movk x2,#8,lsl #16
    cmp x1,x2
    b.lo .Lregistry_release_reject
    adds x5,x0,x2
    b.cs .Lregistry_release_reject
    sub x2,x2,#16
    add x2,x0,x2
    ldp x3,x4,[x2]
    orr x8,x3,x4
    cbz x8,.Lregistry_release_empty
    cbz x3,.Lregistry_release_reject
    cbz x4,.Lregistry_release_reject
    tst x8,#7
    b.ne .Lregistry_release_reject
    movz x8,#7160
    movk x8,#1,lsl #16
    adds x6,x3,x8
    b.cs .Lregistry_release_reject
    movz x8,#29728
    movk x8,#2,lsl #16
    adds x7,x4,x8
    b.cs .Lregistry_release_reject
    cmp x3,x5
    b.hs .Lregistry_release_surface_range
    cmp x0,x6
    b.lo .Lregistry_release_reject
.Lregistry_release_surface_range:
    cmp x4,x5
    b.hs .Lregistry_release_root_ranges
    cmp x0,x7
    b.lo .Lregistry_release_reject
.Lregistry_release_root_ranges:
    cmp x3,x7
    b.hs .Lregistry_release_private_aliases
    cmp x4,x6
    b.lo .Lregistry_release_reject
.Lregistry_release_private_aliases:
    adrp x8,:got:md2asm_registry_variable_array_layout
    ldr x8,[x8,:got_lo12:md2asm_registry_variable_array_layout]
    mov w9,#18
.Lregistry_release_private_alias:
    ldp w10,w11,[x8],#8
    add x12,x3,w10,uxtw
    add x13,x3,w11,uxtw
    ldr x12,[x12]
    ldr x13,[x13]
    cmp x12,x13
    b.ne .Lregistry_release_reject
    subs w9,w9,#1
    b.ne .Lregistry_release_private_alias
    stp x29,x30,[sp,#-160]!
    mov x29,sp
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    str x18,[sp,#96]
    mrs x9,fpcr
    mrs x10,fpsr
    stp x9,x10,[sp,#104]
    mov x19,x0
    mov x20,x3
    mov x21,x4
    bl __errno_location
    str x0,[sp,#120]
    ldr w9,[x0]
    str w9,[sp,#128]
    // Surface VARIABLE records and their allocated FIELD children.
    adrp x22,:got:md2asm_registry_surface_variable_layout
    ldr x22,[x22,:got_lo12:md2asm_registry_surface_variable_layout]
    mov w23,#284
.Lregistry_release_surface_variables:
    ldr w9,[x22]
    ldp w10,w11,[x22,#8]
    add x0,x21,w9,uxtw
    cbnz w11,.Lregistry_release_surface_array
    mov w1,w10
    bl .Lregistry_release_variable
    b .Lregistry_release_surface_variable_next
.Lregistry_release_surface_array:
    mov w1,w11
    mov w2,w10
    bl .Lregistry_release_array
.Lregistry_release_surface_variable_next:
    add x22,x22,#48
    subs w23,w23,#1
    b.ne .Lregistry_release_surface_variables
    // Embedded group FIELD records have payload ownership only.
    adrp x22,:got:md2asm_registry_surface_group_layout
    ldr x22,[x22,:got_lo12:md2asm_registry_surface_group_layout]
    mov w23,#19
.Lregistry_release_surface_groups:
    ldp w9,w1,[x22,#8]
    add x0,x21,w9,uxtw
    mov w2,#0
    bl .Lregistry_release_field
    add x22,x22,#32
    subs w23,w23,#1
    b.ne .Lregistry_release_surface_groups
    movz x9,#4992
    movk x9,#8,lsl #16
    add x9,x19,x9
    str xzr,[x9]
    mov x0,x21
    bl free
    // The source view table has61 scalar rows and18 private-array rows.
    adrp x22,:got:md2asm_registry_variable_view_layout
    ldr x22,[x22,:got_lo12:md2asm_registry_variable_view_layout]
    mov w23,#79
.Lregistry_release_variables:
    ldp w9,w1,[x22]
    ldr w10,[x22,#8]
    add x0,x20,w9,uxtw
    cbz w10,.Lregistry_release_scalar
    str xzr,[x0]
    sub x0,x0,#64
    mov w1,#1
    mov w2,#3
    bl .Lregistry_release_array
    b .Lregistry_release_variable_next
.Lregistry_release_scalar:
    bl .Lregistry_release_variable
.Lregistry_release_variable_next:
    add x22,x22,#12
    subs w23,w23,#1
    b.ne .Lregistry_release_variables
    // Geometry and radiation supply the remaining44 scalar records.
    adrp x22,:got:md2asm_registry_geometry_variable_layout
    ldr x22,[x22,:got_lo12:md2asm_registry_geometry_variable_layout]
    mov w23,#21
.Lregistry_release_geometry_variables:
    ldr w9,[x22]
    ldr w1,[x22,#8]
    add x0,x20,w9,uxtw
    bl .Lregistry_release_variable
    add x22,x22,#32
    subs w23,w23,#1
    b.ne .Lregistry_release_geometry_variables
    adrp x22,:got:md2asm_registry_radiation_variable_layout
    ldr x22,[x22,:got_lo12:md2asm_registry_radiation_variable_layout]
    mov w23,#23
.Lregistry_release_radiation_variables:
    ldr w9,[x22]
    ldr w1,[x22,#8]
    add x0,x20,w9,uxtw
    bl .Lregistry_release_variable
    add x22,x22,#32
    subs w23,w23,#1
    b.ne .Lregistry_release_radiation_variables
    movz x9,#4984
    movk x9,#8,lsl #16
    add x9,x19,x9
    str xzr,[x9]
    mov x0,x20
    bl free
    ldr x9,[sp,#120]
    ldr w10,[sp,#128]
    str w10,[x9]
    ldp x9,x10,[sp,#104]
    msr fpcr,x9
    msr fpsr,x10
    ldr x18,[sp,#96]
    ldp x27,x28,[sp,#80]
    ldp x25,x26,[sp,#64]
    ldp x23,x24,[sp,#48]
    ldp x21,x22,[sp,#32]
    ldp x19,x20,[sp,#16]
    ldp x29,x30,[sp],#160
.Lregistry_release_empty:
    mov w0,#0
    ret
.Lregistry_release_reject:
    mov w0,#2
    ret
.size md2asm_release_runtime_field_registry,.-md2asm_release_runtime_field_registry

// Release one complete VARIABLE's six unique FIELD metadata children.
// x0 variable, w1 field rank. All borrowed numerical values remain opaque.
.Lregistry_release_variable:
    stp x29,x30,[sp,#-64]!
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    mov x29,sp
    mov x19,x0
    mov w20,w1
    mov x9,#168
    madd x21,x20,x9,x19
    add x21,x21,#176
    mov w22,#6
.Lregistry_release_variable_child:
    ldr x0,[x21]
    str xzr,[x21],#8
    mov w1,w20
    mov w2,#1
    bl .Lregistry_release_field
    subs w22,w22,#1
    b.ne .Lregistry_release_variable_child
    ldp x21,x22,[sp,#32]
    ldp x19,x20,[sp,#16]
    ldp x29,x30,[sp],#64
    ret

// x0 descriptor, w1 metadata rank1or2, w2 VARIABLE field rank2through4.
.Lregistry_release_array:
    stp x29,x30,[sp,#-80]!
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    mov x29,sp
    mov x19,x0
    mov w24,w2
    ldr x21,[x19]
    cbz x21,.Lregistry_release_array_return
    ldp x9,x10,[x19,#48]
    sub x20,x10,x9
    add x20,x20,#1
    cmp x20,#0
    csel x20,x20,xzr,ge
    cmp w1,#2
    b.ne .Lregistry_release_array_shape
    ldp x9,x10,[x19,#72]
    sub x10,x10,x9
    add x10,x10,#1
    cmp x10,#0
    csel x10,x10,xzr,ge
    mul x20,x20,x10
.Lregistry_release_array_shape:
    mov x9,#168
    mul x22,x24,x9
    add x22,x22,#224
    mov x23,x21
.Lregistry_release_array_element:
    cbz x20,.Lregistry_release_array_owner
    mov x0,x23
    mov w1,w24
    bl .Lregistry_release_variable
    add x23,x23,x22
    sub x20,x20,#1
    b .Lregistry_release_array_element
.Lregistry_release_array_owner:
    str xzr,[x19]
    mov x0,x21
    bl free
.Lregistry_release_array_return:
    ldp x23,x24,[sp,#48]
    ldp x21,x22,[sp,#32]
    ldp x19,x20,[sp,#16]
    ldp x29,x30,[sp],#80
    ret

// x0 FIELD, w1 rank, w2 nonzero to release the FIELD metadata allocation.
.Lregistry_release_field:
    cbz x0,.Lregistry_release_field_empty
    stp x29,x30,[sp,#-64]!
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    str x23,[sp,#48]
    mov x29,sp
    mov x19,x0
    mov w20,w1
    mov w23,w2
    mov x9,#72
    madd x9,x20,x9,x19
    ldr w10,[x9,#108]
    cbz w10,.Lregistry_release_field_metadata
    mov x9,#24
    madd x9,x20,x9,x19
    ldr x21,[x9,#16]
    mov x10,#48
    madd x10,x20,x10,x19
    ldr x22,[x10,#56]
    str xzr,[x19]
    str xzr,[x9,#16]
    str xzr,[x10,#56]
    cbz x22,.Lregistry_release_field_PTR
    mov x0,x22
    bl free
.Lregistry_release_field_PTR:
    cbz x21,.Lregistry_release_field_metadata
    cmp x21,x22
    b.eq .Lregistry_release_field_metadata
    mov x0,x21
    bl free
.Lregistry_release_field_metadata:
    cbz w23,.Lregistry_release_field_return
    mov x0,x19
    bl free
.Lregistry_release_field_return:
    ldr x23,[sp,#48]
    ldp x21,x22,[sp,#32]
    ldp x19,x20,[sp,#16]
    ldp x29,x30,[sp],#64
.Lregistry_release_field_empty:
    ret
.section .note.GNU-stack,"",%progbits
