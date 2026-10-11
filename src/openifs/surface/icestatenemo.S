/* Complete sea-ice coupling copy from the frozen original contract.
 * Physics formulations/openifs/surface/coupled_sea_ice.md
 * Contract skills/md2asm/references/openifs/surface/icestatenemo.md
 * Nine ordinary addresses, all five optional original outputs.
 */
.text
.p2align 4
.global md2asm_icestatenemo
.type md2asm_icestatenemo,%function
md2asm_icestatenemo:
    stp x29,x30,[sp,#-384]!
    mov x29,sp
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    stp x0,x1,[sp,#96]
    stp x2,x3,[sp,#112]
    stp x4,x5,[sp,#128]
    stp x6,x7,[sp,#144]
    ldr x8,[sp,#384]
    str x8,[sp,#160]
    mrs x9,fpcr
    cbnz x9,.Lice_bad
    cbz x0,.Lice_bad
    tst x0,#7
    b.ne .Lice_bad
    cbz x1,.Lice_bad
    cbz x2,.Lice_bad
    cbz x3,.Lice_bad
    orr x9,x1,x2
    orr x9,x9,x3
    tst x9,#3
    b.ne .Lice_bad
    mov x22,x0
    mov x9,#6796
    ldr w9,[x22,x9]
    cbz w9,.Lice_return
    ldr w9,[x1]
    ldr w10,[x2]
    ldr w11,[x3]
    cmp w9,#1
    b.lt .Lice_bad
    cmp w10,#1
    b.lt .Lice_bad
    cmp w11,w10
    b.lt .Lice_return
    sub w19,w11,w10
    add w19,w19,#1
    cmp w19,#1
    b.lt .Lice_bad
    mov w12,#4096
    cmp w19,w12
    b.gt .Lice_bad
    sub w20,w9,#1
    adds w20,w20,w10
    b.vs .Lice_bad
    sub w21,w9,#1
    adds w21,w21,w11
    b.vs .Lice_bad
    mov x9,#7360
    add x28,x22,x9
    ldr x23,[x28]
    cbz x23,.Lice_bad
    tst x23,#7
    b.ne .Lice_bad
    ldr x9,[x28,#16]
    cmp x9,#352
    b.ne .Lice_bad
    ldrb w9,[x28,#28]
    cmp w9,#1
    b.ne .Lice_bad
    ldrb w9,[x28,#29]
    cmp w9,#5
    b.ne .Lice_bad
    ldr x9,[x28,#32]
    cmp x9,#352
    b.ne .Lice_bad
    ldr x24,[x28,#40]
    cmp x24,#1
    b.lt .Lice_bad
    mov x9,#352
    mul x24,x24,x9
    ldr x9,[x28,#48]
    ldr x10,[x28,#56]
    cmp x9,#1
    b.ne .Lice_bad
    cmp x10,#5
    b.lt .Lice_bad
    sub x10,x10,#1
    mul x10,x10,x24
    adds x10,x10,x23
    b.cs .Lice_bad
    adds x10,x10,#352
    b.cs .Lice_bad
    str x10,[sp,#344]
    add x25,sp,#176
    add x26,sp,#216
    add x27,sp,#256
    mov w18,#0
.Lice_prepare:
    add x9,sp,#128
    ldr x9,[x9,x18,lsl #3]
    str xzr,[x25,x18,lsl #3]
    cbz x9,.Lice_prepare_next
    tst x9,#7
    b.ne .Lice_bad
    adrp x10,.Lice_index_offsets
    add x10,x10,:lo12:.Lice_index_offsets
    ldr w10,[x10,x18,lsl #2]
    ldr w10,[x22,x10]
    cmp w10,#1
    b.lt .Lice_bad
    ldr x11,[x28,#56]
    cmp x10,x11
    b.gt .Lice_bad
    sub x10,x10,#1
    madd x11,x10,x24,x23
    add x11,x11,#240
    ldr x12,[x11]
    cbz x12,.Lice_bad
    tst x12,#7
    b.ne .Lice_bad
    ldr x10,[x11,#16]
    cmp x10,#8
    b.ne .Lice_bad
    ldrb w10,[x11,#28]
    cmp w10,#3
    b.ne .Lice_bad
    ldrb w10,[x11,#29]
    cmp w10,#3
    b.ne .Lice_bad
    ldr x10,[x11,#32]
    cmp x10,#8
    b.ne .Lice_bad
    ldr x10,[x11,#48]
    cmp x10,#1
    b.ne .Lice_bad
    ldr x10,[x11,#56]
    cmp x10,x21
    b.lt .Lice_bad
    ldr x13,[x11,#40]
    cmp x13,#1
    b.lt .Lice_bad
    lsl x13,x13,#3
    ldr x14,[x11,#72]
    cmp x14,#1
    b.ne .Lice_bad
    ldr x14,[x11,#80]
    cmp x14,#1
    b.ne .Lice_bad
    ldr x14,[x11,#96]
    cmp x14,#1
    b.ne .Lice_bad
    ldr x14,[x11,#104]
    cmp x14,#1
    b.ne .Lice_bad
    sub x10,x10,#1
    mul x10,x10,x13
    adds x10,x10,x12
    b.cs .Lice_bad
    adds x10,x10,#8
    b.cs .Lice_bad
    lsl x14,x18,#4
    add x14,x27,x14
    stp x12,x10,[x14]
    sub x10,x20,#1
    madd x12,x10,x13,x12
    str x12,[x25,x18,lsl #3]
    str x13,[x26,x18,lsl #3]
.Lice_prepare_next:
    add w18,w18,#1
    cmp w18,#5
    b.lo .Lice_prepare
    lsl x19,x19,#3
    mov w18,#0
.Lice_overlap_out:
    ldr x9,[x25,x18,lsl #3]
    cbz x9,.Lice_overlap_next
    add x9,sp,#128
    ldr x12,[x9,x18,lsl #3]
    adds x13,x12,x19
    b.cs .Lice_bad
    mov x14,x22
    mov x15,#7584
    add x15,x14,x15
    cmp x12,x15
    b.hs .Lice_overlap_fields
    cmp x14,x13
    b.lo .Lice_bad
.Lice_overlap_fields:
    ldr x15,[sp,#344]
    cmp x12,x15
    b.hs .Lice_overlap_int
    cmp x23,x13
    b.lo .Lice_bad
.Lice_overlap_int:
    mov w16,#1
.Lice_overlap_int_loop:
    add x9,sp,#96
    ldr x14,[x9,x16,lsl #3]
    add x15,x14,#4
    cmp x12,x15
    b.hs .Lice_overlap_int_next
    cmp x14,x13
    b.lo .Lice_bad
.Lice_overlap_int_next:
    add w16,w16,#1
    cmp w16,#4
    b.lo .Lice_overlap_int_loop
    mov w16,#0
.Lice_overlap_copy:
    ldr x9,[x25,x16,lsl #3]
    cbz x9,.Lice_overlap_copy_next
    lsl x9,x16,#4
    add x9,x27,x9
    ldp x14,x15,[x9]
    cmp x12,x15
    b.hs .Lice_overlap_other_output
    cmp x14,x13
    b.lo .Lice_bad
.Lice_overlap_other_output:
    cmp w18,w16
    b.eq .Lice_overlap_copy_next
    add x9,sp,#128
    ldr x14,[x9,x16,lsl #3]
    add x15,x14,x19
    cmp x12,x15
    b.hs .Lice_overlap_copy_next
    cmp x14,x13
    b.lo .Lice_bad
.Lice_overlap_copy_next:
    add w16,w16,#1
    cmp w16,#5
    b.lo .Lice_overlap_copy
.Lice_overlap_next:
    add w18,w18,#1
    cmp w18,#5
    b.lo .Lice_overlap_out
    lsr x19,x19,#3
    mov w18,#0
.Lice_field_copy:
    ldr x10,[x25,x18,lsl #3]
    cbz x10,.Lice_field_next
    ldr x11,[x26,x18,lsl #3]
    add x9,sp,#128
    ldr x12,[x9,x18,lsl #3]
    mov x13,x19
.Lice_cell_copy:
    ldr x14,[x10]
    str x14,[x12],#8
    add x10,x10,x11
    subs x13,x13,#1
    b.ne .Lice_cell_copy
.Lice_field_next:
    add w18,w18,#1
    cmp w18,#5
    b.lo .Lice_field_copy
.Lice_return:
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp x29,x30,[sp],#384
    ret
.Lice_bad:
    bl abort
    brk #0
.size md2asm_icestatenemo,.-md2asm_icestatenemo
.section .rodata
.p2align 3
.Lice_index_offsets:
    .word 7528,7532,7524,7432,7520
.section .note.GNU-stack,"",%progbits
