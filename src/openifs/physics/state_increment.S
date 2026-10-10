/* Add process increments to the enabled weather state fields.
 * Physics is formulations/openifs/physics/state_increments.md.
 * Ordered ABI is skills/md2asm/references/openifs/physics/state_increment.md.
 * Thirteen pointers use x0..x7 and five caller stack slots.
 * The 192-byte aligned frame preserves x19..x30 and stores optional pointers.
 * x18 and d8..d15 stay untouched. Each pair of columns uses one FP64 addition.
 * Original GNU descriptors and input increments stay read-only. */
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL state_increment_
#endif
.text
.p2align 2
.macro STATE_FIELD input_offset,descriptor_offset,mask_offset,component
    ldr x0,[sp,#(96+\input_offset)]
    cbz x0,.Lfield_done\@
.if \mask_offset >= 0
    ldr w1,[x20,#\mask_offset]
    cbz w1,.Lfield_done\@
.endif
    add x1,x20,#\descriptor_offset
    ldr x2,[x1]
    ldr x3,[x1,#8]
    ldr x4,[x1,#40]
    ldr x5,[x1,#64]
    ldr x6,[x1,#72]
    madd x3,x23,x4,x3
    madd x3,x6,x5,x3
.if \component > 0
    ldr x8,[x1,#88]
    mov x9,#\component
    madd x3,x9,x8,x3
.endif
    add x2,x2,x3,lsl #3
    sub x8,x23,#1
    add x0,x0,x8,lsl #3
    mov x12,x26
.Lrow\@:
    mov x9,x0
    mov x10,x2
    mov x11,x27
    cmp x11,#2
    b.lo .Ltail\@
.Lpair\@:
    ldr q0,[x10]
    ldr q1,[x9],#16
    fadd v0.2d,v0.2d,v1.2d
    str q0,[x10],#16
    sub x11,x11,#2
    cmp x11,#2
    b.hs .Lpair\@
.Ltail\@:
    cbz x11,.Lnext_row\@
    ldr d0,[x10]
    ldr d1,[x9]
    fadd d0,d0,d1
    str d0,[x10]
.Lnext_row\@:
    add x0,x0,x25,lsl #3
    add x2,x2,x5,lsl #3
    subs x12,x12,#1
    b.ne .Lrow\@
.Lfield_done\@:
.endm
.global ORIGINAL_SYMBOL
.type ORIGINAL_SYMBOL,%function
ORIGINAL_SYMBOL:
    sub sp,sp,#192
    stp x19,x20,[sp,#0]
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x25,x26,[sp,#48]
    stp x27,x28,[sp,#64]
    stp x29,x30,[sp,#80]
    mov x19,x0
    mov x20,x1
    ldrsw x23,[x19,#0]
    ldrsw x24,[x19,#4]
    subs x27,x24,x23
    b.lt .Lreturn
    add x27,x27,#1
    ldrsw x25,[x19,#12]
    ldrsw x26,[x19,#48]
    cmp x26,#0
    b.le .Lreturn
    stp x2,x3,[sp,#96]
    stp x4,x5,[sp,#112]
    stp x6,x7,[sp,#128]
    ldp x0,x1,[sp,#192]
    stp x0,x1,[sp,#144]
    ldp x0,x1,[sp,#208]
    stp x0,x1,[sp,#160]
    ldr x0,[sp,#224]
    str x0,[sp,#176]
    STATE_FIELD 0,32,-1,0
    STATE_FIELD 8,120,-1,0
    STATE_FIELD 16,208,-1,0
    STATE_FIELD 32,384,4,0
    STATE_FIELD 24,296,0,0
    STATE_FIELD 40,472,8,0
    STATE_FIELD 80,560,28,0
    STATE_FIELD 48,1000,12,1
    STATE_FIELD 56,1000,16,2
    STATE_FIELD 64,1000,20,3
    STATE_FIELD 72,1000,24,4
.Lreturn:
    ldp x19,x20,[sp,#0]
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x25,x26,[sp,#48]
    ldp x27,x28,[sp,#64]
    ldp x29,x30,[sp,#80]
    add sp,sp,#192
    ret
.size ORIGINAL_SYMBOL,.-ORIGINAL_SYMBOL
.section .note.GNU-stack,"",%progbits
