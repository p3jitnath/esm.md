/* Complete selected owned SUVERT composition.
 * Contract: skills/md2asm/references/openifs/setup/owned_vertical_system_contract.md. x0=owned Geometry17096,
 * x1=scalars[reference_pressure_Pa,pi],x2=bound output addresses[2].
 * Existing27 owners remain context-owned; only new RDERB needs extra release.
 * Return0 complete,1 allocation,2 metadata,3 numerical. Own192B aligned frame.
 */
.arch armv8-a
.text
.p2align 4
.global md2asm_initialize_owned_vertical_system
.type md2asm_initialize_owned_vertical_system,%function
md2asm_initialize_owned_vertical_system:
    cbz x0,.Lreject
    cbz x1,.Lreject
    cbz x2,.Lreject
    orr x9,x0,x1
    orr x9,x9,x2
    tst x9,#7
    b.ne .Lreject
    mrs x9,fpcr
    cbnz x9,.Lreject
    ldr x9,[x0,#1264]
    cbnz x9,.Lreject
    stp x29,x30,[sp,#-192]!
    mov x29,sp
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    mov x19,x0
    mov x20,x1
    mov x21,x2
    adrp x22,.Lmatrix_descriptors
    add x22,x22,:lo12:.Lmatrix_descriptors
    mov x23,#0
    add x24,sp,#96
.Lmatrix_guard_loop:
    ldp w9,w1,[x22]
    add x0,x19,w9,uxtw
    ldr x9,[x0]
    str x9,[x24,x23,lsl #3]
    bl .Lmatrix_descriptor_guard
    cbnz w0,.Lmetadata_failure
    add x22,x22,#8
    add x23,x23,#1
    cmp x23,#5
    b.lt .Lmatrix_guard_loop
    adrp x22,.Ladjustment_descriptors
    add x22,x22,:lo12:.Ladjustment_descriptors
    mov x23,#0
    add x24,sp,#136
.Ladjustment_guard_loop:
    ldr w9,[x22,x23,lsl #2]
    add x0,x19,w9,uxtw
    ldr x9,[x0]
    str x9,[x24,x23,lsl #3]
    bl .Lprofile_descriptor_guard
    cbnz w0,.Lmetadata_failure
    add x23,x23,#1
    cmp x23,#5
    b.lt .Ladjustment_guard_loop
    mov x0,x19
    mov x1,x20
    mov x2,x21
    bl md2asm_initialize_vertical_eta_coordinates
    cbnz w0,.Lreturn
    ldr x0,[x19,#720]
    add x1,sp,#96
    add x2,x19,#1264
    bl md2asm_initialize_vertical_spline_owners
    cbnz w0,.Lreturn
    ldr x0,[x19,#144]
    ldr x1,[x19,#80]
    ldr x2,[x19,#784]
    ldr x3,[x19,#1088]
    mov x4,x20
    add x5,sp,#136
    bl md2asm_adjust_vertical_hybrid_coordinates
    cbz w0,.Lreturn
    str w0,[sp,#184]
    add x0,x19,#1264
    bl md2asm_release_vertical_spline_copy
    ldr w0,[sp,#184]
    b .Lreturn
.Lmetadata_failure:
    mov w0,#2
.Lreturn:
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp x29,x30,[sp],#192
    ret
.Lmatrix_descriptor_guard:
    ldr x9,[x0]
    cbz x9,.Lguard_reject
    tst x9,#7
    b.ne .Lguard_reject
    ldr x9,[x0,#8]
    add x10,x1,#1
    neg x10,x10
    cmp x9,x10
    b.ne .Lguard_reject
    ldr x9,[x0,#16]
    cmp x9,#8
    b.ne .Lguard_reject
    ldr x9,[x0,#24]
    mov x10,#0x30200000000
    cmp x9,x10
    b.ne .Lguard_reject
    ldr x9,[x0,#32]
    cmp x9,#8
    b.ne .Lguard_reject
    ldp x9,x10,[x0,#40]
    cmp x9,#1
    b.ne .Lguard_reject
    cmp x10,#1
    b.ne .Lguard_reject
    ldr x9,[x0,#56]
    cmp x9,x1
    b.ne .Lguard_reject
    ldr x9,[x0,#64]
    cmp x9,x1
    b.ne .Lguard_reject
    ldp x9,x10,[x0,#72]
    cmp x9,#1
    b.ne .Lguard_reject
    cmp x10,#21
    b.ne .Lguard_reject
    mov w0,#0
    ret
.Lprofile_descriptor_guard:
    ldr x9,[x0]
    cbz x9,.Lguard_reject
    tst x9,#7
    b.ne .Lguard_reject
    ldr x9,[x0,#8]
    cmn x9,#1
    b.ne .Lguard_reject
    ldr x9,[x0,#16]
    cmp x9,#8
    b.ne .Lguard_reject
    ldr x9,[x0,#24]
    mov x10,#0x30100000000
    cmp x9,x10
    b.ne .Lguard_reject
    ldr x9,[x0,#32]
    cmp x9,#8
    b.ne .Lguard_reject
    ldp x9,x10,[x0,#40]
    cmp x9,#1
    b.ne .Lguard_reject
    cmp x10,#1
    b.ne .Lguard_reject
    ldr x9,[x0,#56]
    cmp x9,#19
    b.ne .Lguard_reject
    mov w0,#0
    ret
.Lguard_reject:
    mov w0,#2
    ret
.Lreject:
    mov w0,#2
    ret
.size md2asm_initialize_owned_vertical_system,.-md2asm_initialize_owned_vertical_system
.p2align 4
.global md2asm_release_owned_vertical_system
.type md2asm_release_owned_vertical_system,%function
md2asm_release_owned_vertical_system:
    cbz x0,.Lrelease_reject
    tst x0,#7
    b.ne .Lrelease_reject
    add x0,x0,#1264
    b md2asm_release_vertical_spline_copy
.Lrelease_reject:
    mov w0,#2
    ret
.size md2asm_release_owned_vertical_system,.-md2asm_release_owned_vertical_system
.section .rodata
.p2align 2
.Lmatrix_descriptors:
    .word 1088,20,1352,19,1440,19,1528,19,1616,19
.Ladjustment_descriptors:
    .word 464,400,336,272,208
.section .note.GNU-stack,"",%progbits
