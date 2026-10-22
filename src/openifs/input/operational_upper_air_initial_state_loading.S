/*
 * Operational upper-air initial-state loading, revision 1.
 * Contract: skills/md2asm/references/openifs/input/operational_upper_air_initial_state_loading.md
 * x0 readable path, x1 complete in/out model buffer, x2 byte capacity.
 * Shape 17 by 137 by 9 by 388217, with 65099332296 bytes.
 * Decode all 959 fields before placement. Preserve the preimage on error.
 * Private values and metadata need 50632783320 bytes through C malloc/free.
 * No new physical arithmetic and no original OpenIFS production provider.
 * FPCR must be zero. Preserve FPCR, FPSR, errno, x18 and ABI saved state.
 * Frame 112 bytes, aligned to 16 bytes. Child contracts define field units.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_load_operational_upper_air_initial_state
.type md2asm_load_operational_upper_air_initial_state,%function
md2asm_load_operational_upper_air_initial_state:
    stp x29,x30,[sp,#-112]!
    mov x29,sp
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    str x18,[sp,#80]
    mrs x25,fpsr
    mrs x26,fpcr
    mov x19,x0
    mov x20,x1
    mov x21,x2
    mov x22,xzr
    mov x24,xzr
    mov w23,#1
    cbz x19,.Loperational_upper_restore
    cbz x20,.Loperational_upper_restore
    tst x20,#7
    b.ne .Loperational_upper_restore
    ldr x8,.Loperational_upper_output_bytes
    cmp x21,x8
    b.lo .Loperational_upper_restore
    adds x9,x20,x8
    b.cs .Loperational_upper_restore
    cbnz x26,.Loperational_upper_restore
    bl __errno_location
    mov x24,x0
    ldr w8,[x24]
    str w8,[sp,#88]
    ldr x0,.Loperational_upper_private_bytes
    ldr x18,[sp,#80]
    bl malloc
    mov x22,x0
    mov w23,#2
    cbz x22,.Loperational_upper_restore_errno
    mov x0,x19
    mov x1,x22
    ldr x2,.Loperational_upper_value_bytes
    add x3,x22,x2
    mov x4,#38360
    add x5,sp,#96
    ldr x18,[sp,#80]
    bl md2asm_read_operational_initial_upper_air_fields
    add w23,w0,#16
    cbnz w0,.Loperational_upper_cleanup
    mov x0,x22
    ldr x1,.Loperational_upper_value_bytes
    add x2,x22,x1
    mov x3,#38360
    mov x4,x20
    mov x5,x21
    ldr x18,[sp,#80]
    bl md2asm_place_operational_upper_air_fields
    add w23,w0,#32
    cbnz w0,.Loperational_upper_cleanup
    mov w23,#0
.Loperational_upper_cleanup:
    mov x0,x22
    ldr x18,[sp,#80]
    bl free
.Loperational_upper_restore_errno:
    ldr w8,[sp,#88]
    str w8,[x24]
.Loperational_upper_restore:
    msr fpcr,x26
    msr fpsr,x25
    ldr x18,[sp,#80]
    mov w0,w23
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x29,x30,[sp],#112
    ret
.size md2asm_load_operational_upper_air_initial_state,.-md2asm_load_operational_upper_air_initial_state
.p2align 3
.Loperational_upper_output_bytes:
    .xword 65099332296
.Loperational_upper_private_bytes:
    .xword 50632783320
.Loperational_upper_value_bytes:
    .xword 50632744960
.section .note.GNU-stack,"",%progbits
