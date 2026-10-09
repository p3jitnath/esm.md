/* Seed all AAPCS64 preserved registers around the complete call. */
.text
.p2align 4
.global vertical_abi_call
.type vertical_abi_call,%function
vertical_abi_call:
    sub sp,sp,#192
    stp x19,x20,[sp]
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x25,x26,[sp,#48]
    stp x27,x28,[sp,#64]
    stp x29,x30,[sp,#80]
    stp d8,d9,[sp,#96]
    stp d10,d11,[sp,#112]
    stp d12,d13,[sp,#128]
    stp d14,d15,[sp,#144]
    stp x0,x1,[sp,#160]
    mov x19,#19
    mov x20,#20
    mov x21,#21
    mov x22,#22
    mov x23,#23
    mov x24,#24
    mov x25,#25
    mov x26,#26
    mov x27,#27
    mov x28,#28
    mov x29,#29
    mov x9,#8
    fmov d8,x9
    mov x9,#9
    fmov d9,x9
    mov x9,#10
    fmov d10,x9
    mov x9,#11
    fmov d11,x9
    mov x9,#12
    fmov d12,x9
    mov x9,#13
    fmov d13,x9
    mov x9,#14
    fmov d14,x9
    mov x9,#15
    fmov d15,x9
    ldr x16,[sp,#160]
    ldr x0,[sp,#168]
    blr x16
    mov x0,#0
.macro check_gpr reg,expected,bit
    cmp \reg,#\expected
    cset x9,ne
    orr x0,x0,x9,lsl #\bit
.endm
    check_gpr x19,19,0
    check_gpr x20,20,1
    check_gpr x21,21,2
    check_gpr x22,22,3
    check_gpr x23,23,4
    check_gpr x24,24,5
    check_gpr x25,25,6
    check_gpr x26,26,7
    check_gpr x27,27,8
    check_gpr x28,28,9
    check_gpr x29,29,10
.macro check_fpr reg,expected,bit
    fmov x9,\reg
    cmp x9,#\expected
    cset x9,ne
    orr x0,x0,x9,lsl #\bit
.endm
    check_fpr d8,8,11
    check_fpr d9,9,12
    check_fpr d10,10,13
    check_fpr d11,11,14
    check_fpr d12,12,15
    check_fpr d13,13,16
    check_fpr d14,14,17
    check_fpr d15,15,18
    mrs x9,fpcr
    cmp x9,#0
    cset x9,ne
    orr x0,x0,x9,lsl #19
    ldp x19,x20,[sp]
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x25,x26,[sp,#48]
    ldp x27,x28,[sp,#64]
    ldp x29,x30,[sp,#80]
    ldp d8,d9,[sp,#96]
    ldp d10,d11,[sp,#112]
    ldp d12,d13,[sp,#128]
    ldp d14,d15,[sp,#144]
    add sp,sp,#192
    ret
.purgem check_gpr
.purgem check_fpr
.size vertical_abi_call,.-vertical_abi_call
.section .note.GNU-stack,"",%progbits
