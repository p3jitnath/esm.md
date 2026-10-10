/* Complete CCD-1 and CCD-2 from formulations/openifs/physics/convective_cloud_diagnostics.md.
 * The numerical contract is skills/md2asm/references/openifs/physics/cuccdia.md.
 * Eighteen address arguments retain the original column-fast array interface.
 * A 96-byte aligned frame preserves x19..x30. x18 and d8..d15 are untouched.
 * Real arrays align to eight bytes, integer arrays to four. Active columns
 * and cloud levels stay inside B-by-H owners. No numerical helper is called.
 * Vapour and liquid use kg/kg, mass and rain flux use kg/(m2 s). */
.arch armv8-a
.text
.p2align 4
.global md2asm_cuccdia
.type md2asm_cuccdia,%function
md2asm_cuccdia:
    stp x19,x20,[sp,#-96]!
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x25,x26,[sp,#48]
    stp x27,x28,[sp,#64]
    stp x29,x30,[sp,#80]
    ldrsw x19,[x3]
    sub x19,x19,#1
    ldrsw x20,[x4]
    ldrsw x21,[x5]
    mov w9,#0
    ldr w17,[x2,#8]
    cbz w17,.Lccd_return
    ldr w17,[x1,#4]
    cbnz w17,.Lccd_ready
    ldr w10,[x0,#12]
    cmp w10,#1
    b.eq .Lccd_ready
    ldr w17,[x2,#36]
    cbz w17,.Lccd_return
    ldr w17,[x7]
    add w17,w17,#1
    sdiv w15,w17,w10
    msub w17,w15,w10,w17
    cbz w17,.Lccd_return
    sub w17,w10,#1
    mov w16,#1
    cmp w17,#1
    csel w17,w17,w16,ge
    scvtf d20,w17
    fmov d21,#1.0
    fdiv d20,d21,d20
    mov w9,#1
.Lccd_ready:
    cmp x19,x20
    b.ge .Lccd_return
    ldp x22,x23,[sp,#96]
    ldp x24,x25,[sp,#112]
    ldp x26,x27,[sp,#128]
    ldp x28,x29,[sp,#144]
    ldp x30,x8,[sp,#160]
    adrp x16,.Lccd_five_percent
    ldr d21,[x16,:lo12:.Lccd_five_percent]
.Lccd_column:
    ldr w17,[x24,x19,lsl #2]
    cbz w17,.Lccd_next
    ldr w13,[x22,x19,lsl #2]
    ldr w14,[x23,x19,lsl #2]
    cbz w9,.Lccd_replace_indices
    ldr w17,[x8,x19,lsl #2]
    cmp w17,w13
    csel w17,w17,w13,ge
    str w17,[x8,x19,lsl #2]
    ldr w17,[x30,x19,lsl #2]
    cmp w17,w14
    csel w17,w17,w14,le
    cmp w17,#1
    csel w17,w14,w17,eq
    str w17,[x30,x19,lsl #2]
    b .Lccd_flux
.Lccd_replace_indices:
    str w13,[x8,x19,lsl #2]
    str w14,[x30,x19,lsl #2]
.Lccd_flux:
    sub w15,w13,#1
    smaddl x15,w15,w21,x19
    sub w16,w14,#1
    smaddl x16,w16,w21,x19
    ldr d0,[x25,x15,lsl #3]
    ldr d1,[x26,x15,lsl #3]
    ldr d2,[x25,x16,lsl #3]
    ldr d4,[x27,x15,lsl #3]
    fmul d3,d0,d21
    fadd d0,d0,d1
    fsub d0,d0,d2
    fmaxnm d0,d0,d3
    fmul d0,d0,d4
    ldr d1,[x28,x19,lsl #3]
    fmaxnm d0,d0,d1
    cbz w9,.Lccd_store
    fmul d0,d0,d20
    ldr d1,[x29,x19,lsl #3]
    fadd d0,d1,d0
.Lccd_store:
    str d0,[x29,x19,lsl #3]
.Lccd_next:
    add x19,x19,#1
    cmp x19,x20
    b.lt .Lccd_column
.Lccd_return:
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x25,x26,[sp,#48]
    ldp x27,x28,[sp,#64]
    ldp x29,x30,[sp,#80]
    ldp x19,x20,[sp],#96
    ret
.size md2asm_cuccdia,.-md2asm_cuccdia
.section .rodata
.p2align 3
.Lccd_five_percent:
    .quad 0x3fa999999999999a
.section .note.GNU-stack,"",%progbits
