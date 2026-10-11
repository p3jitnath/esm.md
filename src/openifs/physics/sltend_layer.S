/* Complete direct SLTEND_LAYER record interface.
 * Physics formulations/openifs/physics/physics_increment.md
 * Physics formulations/openifs/physics/cloud_supersaturation.md
 * Contract skills/md2asm/references/openifs/physics/sltend_layer.md
 * Thirteen original addresses and the read-only SLTEND scalar context.
 * Only the complete direct SLTEND child performs numerical stages.
 */
.text
.p2align 4
.macro SLL_INPUT reg,index
    ldr \reg,[x19,#(416+8*\index)]
.endm
.macro SLL_ARG reg,index
.if \index < 8
    str \reg,[x19,#(352+8*\index)]
.else
    str \reg,[x19,#(8*(\index-8))]
.endif
.endm
.macro SLL_VIEW input,offset,child,rank,third=0,interface=0,empty_extra=0
    SLL_INPUT x0,\input
    ldr x9,=\offset
    add x0,x0,x9
    mov x1,#\rank
.if \third == -1
    mov x2,x24
.elseif \third == -2
    mov x2,x26
.else
    mov x2,#\third
.endif
    mov x4,x22
.if \interface
    add x4,x4,#1
.endif
    mov x5,#\empty_extra
    bl .Lsll_descriptor
    SLL_ARG x0,\child
.endm
.global md2asm_sltend_layer
.type md2asm_sltend_layer,%function
md2asm_sltend_layer:
    mrs x9,fpcr
    cbnz x9,.Lsll_bad
    mov x17,sp
    sub sp,sp,#768
    add x16,sp,#544
    stp x19,x20,[x16,#0]
    stp x21,x22,[x16,#16]
    stp x23,x24,[x16,#32]
    stp x25,x26,[x16,#48]
    stp x27,x28,[x16,#64]
    stp x29,x30,[x16,#80]
    stp d8,d9,[x16,#96]
    stp d10,d11,[x16,#112]
    stp d12,d13,[x16,#128]
    stp d14,d15,[x16,#144]
    str x18,[sp,#704]
    stp x0,x1,[sp,#416]
    stp x2,x3,[sp,#432]
    stp x4,x5,[sp,#448]
    stp x6,x7,[sp,#464]
    ldr x9,[x17,#0]
    str x9,[sp,#480]
    ldr x9,[x17,#8]
    str x9,[sp,#488]
    ldr x9,[x17,#16]
    str x9,[sp,#496]
    ldr x9,[x17,#24]
    str x9,[sp,#504]
    ldr x9,[x17,#32]
    str x9,[sp,#512]
    ldr x9,[x17,#40]
    str x9,[sp,#520]
    mov x19,sp
    mov x29,sp
    add x9,x19,#416
    mov x10,#14
.Lsll_objects:
    ldr x11,[x9],#8
    cbz x11,.Lsll_bad
    tst x11,#7
    b.ne .Lsll_bad
    subs x10,x10,#1
    b.ne .Lsll_objects
    SLL_INPUT x20,0
    SLL_INPUT x9,1
    ldr w10,[x9]
    cmp w10,#1
    b.ne .Lsll_bad
    ldrsw x23,[x9,#4]
    ldrsw x21,[x9,#12]
    ldrsw x22,[x9,#48]
    ldrsw x26,[x9,#36]
    cmp x21,#4096
    b.hi .Lsll_bad
    cmp x22,#512
    b.hi .Lsll_bad
    cmp x23,x21
    b.hi .Lsll_bad
    cmp x26,#128
    b.hi .Lsll_bad
    ldrsw x24,[x20,#264]
    cmp x24,#64
    b.hi .Lsll_bad
    ldr x10,=1577520
    add x10,x20,x10
    ldrsw x25,[x10]
    cmp x25,#3
    b.lt .Lsll_bad
    cmp x25,#64
    b.gt .Lsll_bad
    SLL_ARG x20,0
    SLL_ARG x9,1
    add x11,x9,#4
    SLL_ARG x11,2
    add x11,x9,#12
    SLL_ARG x11,3
    add x11,x9,#48
    SLL_ARG x11,4
    SLL_ARG x10,5
    add x11,x9,#36
    SLL_ARG x11,49
    SLL_INPUT x11,9
    SLL_ARG x11,46
    SLL_INPUT x11,10
    SLL_ARG x11,47
    SLL_INPUT x11,13
    SLL_ARG x11,50
    SLL_VIEW 3,208,6,2
    SLL_VIEW 3,384,7,2
    SLL_VIEW 3,472,8,2
    SLL_VIEW 3,1000,9,3,5
    SLL_VIEW 2,712,10,2
    SLL_VIEW 2,624,11,2,0,1
    SLL_VIEW 4,32,12,2
    SLL_VIEW 4,120,13,2
    SLL_VIEW 4,208,14,2
    SLL_VIEW 4,384,15,2
    SLL_VIEW 4,296,16,2
    SLL_VIEW 4,472,17,2
    SLL_VIEW 4,1000,18,3,5
    SLL_VIEW 7,32,19,2
    SLL_VIEW 7,120,20,2
    SLL_VIEW 7,208,21,2
    SLL_VIEW 7,384,22,2
    SLL_VIEW 7,296,23,2
    SLL_VIEW 7,472,24,2
    SLL_VIEW 7,1000,25,3,5
    SLL_VIEW 12,32,26,2
    SLL_VIEW 12,120,27,2
    SLL_VIEW 12,208,28,2
    SLL_VIEW 12,384,29,2
    SLL_VIEW 12,296,30,2
    SLL_VIEW 12,472,31,2
    SLL_VIEW 12,1000,32,3,5
    SLL_VIEW 8,0,33,2
    SLL_VIEW 8,88,34,2
    SLL_VIEW 8,176,35,2
    SLL_VIEW 8,264,36,3,-1
    SLL_VIEW 5,32,37,2
    SLL_VIEW 5,120,38,2
    SLL_VIEW 5,208,39,2
    SLL_VIEW 5,384,40,2
    SLL_VIEW 5,472,41,2
    SLL_VIEW 6,208,42,2
    SLL_VIEW 6,384,43,2
    SLL_VIEW 6,472,44,2
    SLL_VIEW 6,1000,45,3,5
    SLL_VIEW 11,9816,48,3,-2,0,1
    ldp x0,x1,[x19,#352]
    ldp x2,x3,[x19,#368]
    ldp x4,x5,[x19,#384]
    ldp x6,x7,[x19,#400]
    bl md2asm_sltend
    add x16,x19,#544
    ldp x19,x20,[x16,#0]
    ldp x21,x22,[x16,#16]
    ldp x23,x24,[x16,#32]
    ldp x25,x26,[x16,#48]
    ldp x27,x28,[x16,#64]
    ldp x29,x30,[x16,#80]
    ldp d8,d9,[x16,#96]
    ldp d10,d11,[x16,#112]
    ldp d12,d13,[x16,#128]
    ldp d14,d15,[x16,#144]
    ldr x18,[sp,#704]
    add sp,sp,#768
    ret
.size md2asm_sltend_layer,.-md2asm_sltend_layer

/* Read the measured contiguous real descriptor. x4 is its second extent. */
.type .Lsll_descriptor,%function
.Lsll_descriptor:
    ldr x9,[x0,#16]
    cmp x9,#8
    b.ne .Lsll_bad
    ldr x9,[x0,#32]
    cmp x9,#8
    b.ne .Lsll_bad
    ldrb w9,[x0,#28]
    cmp x9,x1
    b.ne .Lsll_bad
    ldrb w9,[x0,#29]
    cmp w9,#3
    b.ne .Lsll_bad
    ldr x9,[x0,#40]
    cmp x9,#1
    b.ne .Lsll_bad
    ldp x10,x11,[x0,#48]
    subs x12,x11,x10
    b.vs .Lsll_bad
    adds x12,x12,#1
    b.vs .Lsll_bad
    cmp x12,x21
    b.ne .Lsll_bad
    ldr x9,[x0,#64]
    cmp x9,x21
    b.ne .Lsll_bad
    ldp x10,x11,[x0,#72]
    subs x12,x11,x10
    b.vs .Lsll_bad
    adds x12,x12,#1
    b.vs .Lsll_bad
    cbz x5,.Lsll_strict_second
    cbnz x2,.Lsll_strict_second
    cmp x12,x4
    b.eq .Lsll_empty_second
    cmp x12,#1
    b.ne .Lsll_bad
.Lsll_empty_second:
    mov x4,x12
    b .Lsll_second_ready
.Lsll_strict_second:
    cmp x12,x4
    b.ne .Lsll_bad
.Lsll_second_ready:
    cmp x1,#2
    b.eq .Lsll_pointer
    ldr x9,[x0,#88]
    mul x10,x21,x4
    cmp x9,x10
    b.ne .Lsll_bad
    ldp x10,x11,[x0,#96]
    subs x12,x11,x10
    b.vs .Lsll_bad
    adds x12,x12,#1
    b.vs .Lsll_bad
    cmp x12,x2
    b.ne .Lsll_bad
.Lsll_pointer:
    ldr x0,[x0]
    mul x10,x21,x4
    cmp x1,#3
    b.ne .Lsll_extent
    mul x10,x10,x2
.Lsll_extent:
    cbz x10,.Lsll_desc_return
    cbz x0,.Lsll_bad
    tst x0,#7
    b.ne .Lsll_bad
    lsl x10,x10,#3
    adds x10,x0,x10
    b.cs .Lsll_bad
.Lsll_desc_return:
    cbz x5,.Lsll_desc_return_value
    cbnz x2,.Lsll_desc_return_value
    adrp x0,.Lsll_empty_extra_word
    add x0,x0,:lo12:.Lsll_empty_extra_word
.Lsll_desc_return_value:
    ret
.size .Lsll_descriptor,.-.Lsll_descriptor
.Lsll_bad:
    brk #0x2af
    b .Lsll_bad
.ltorg
.section .rodata
.p2align 3
.Lsll_empty_extra_word:
    .quad 0
.section .note.GNU-stack,"",%progbits
