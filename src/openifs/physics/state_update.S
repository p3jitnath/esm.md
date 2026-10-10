/* Update weather fields from their initial state and a physics tendency.
 * Physics is formulations/openifs/physics/state_update.md.
 * Ordered ABI is skills/md2asm/references/openifs/physics/state_update.md.
 * Five pointers use x0..x4. Products and sums round separately in FP64.
 * The 96-byte frame preserves x19..x30. x18 and d8..d15 stay untouched.
 * Each independent pair of columns uses two lanes, followed by a scalar tail.
 * Original GNU metadata and tendencies stay read-only. No array scratch is used. */
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL state_update_
#endif
.text
.p2align 2
.macro ADDRESS dst,object,descriptor,component
    add x1,\object,#\descriptor
    ldr \dst,[x1]
    ldr x3,[x1,#8]
    ldr x5,[x1,#40]
    ldr x6,[x1,#64]
    madd x3,x24,x5,x3
    madd x3,x28,x6,x3
.if \component > 0
    ldr x8,[x1,#88]
    mov x9,#\component
    madd x3,x9,x8,x3
.endif
    add \dst,\dst,x3,lsl #3
.endm
.macro UPDATE_FIELD descriptor,mask,component
.if \mask >= 0
    ldr w1,[x23,#\mask]
    cbz w1,.Lfield_done\@
.endif
    ADDRESS x0,x21,\descriptor,\component
    ADDRESS x2,x22,\descriptor,\component
    ADDRESS x7,x23,\descriptor,\component
    mov x9,x27
    cmp x9,#2
    b.lo .Ltail\@
.Lpair\@:
    ldr q0,[x0],#16
    ldr q1,[x2],#16
    fmul v1.2d,v4.2d,v1.2d
    fadd v0.2d,v0.2d,v1.2d
    str q0,[x7],#16
    sub x9,x9,#2
    cmp x9,#2
    b.hs .Lpair\@
.Ltail\@:
    cbz x9,.Lfield_done\@
    ldr d0,[x0]
    ldr d1,[x2]
    fmul d1,d4,d1
    fadd d0,d0,d1
    str d0,[x7]
.Lfield_done\@:
.endm
.global ORIGINAL_SYMBOL
.type ORIGINAL_SYMBOL,%function
ORIGINAL_SYMBOL:
    sub sp,sp,#96
    stp x19,x20,[sp,#0]
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x25,x26,[sp,#48]
    stp x27,x28,[sp,#64]
    stp x29,x30,[sp,#80]
    mov x19,x0
    mov x20,x1
    mov x21,x2
    mov x22,x3
    mov x23,x4
    ldrsw x24,[x20,#0]
    ldrsw x25,[x20,#4]
    subs x27,x25,x24
    b.lt .Lreturn
    add x27,x27,#1
    ldrsw x26,[x20,#48]
    cmp x26,#0
    b.le .Lreturn
    ldr d4,[x19,#8]
    dup v4.2d,v4.d[0]
    mov x28,#1
.Llevel:
    UPDATE_FIELD 32,-1,0
    UPDATE_FIELD 120,-1,0
    UPDATE_FIELD 208,-1,0
    UPDATE_FIELD 384,4,0
    UPDATE_FIELD 296,0,0
    UPDATE_FIELD 472,8,0
    UPDATE_FIELD 1000,12,1
    UPDATE_FIELD 1000,16,2
    UPDATE_FIELD 1000,20,3
    UPDATE_FIELD 1000,24,4
    UPDATE_FIELD 560,28,0
    add x28,x28,#1
    cmp x28,x26
    b.le .Llevel
.Lreturn:
    ldp x19,x20,[sp,#0]
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x25,x26,[sp,#48]
    ldp x27,x28,[sp,#64]
    ldp x29,x30,[sp,#80]
    add sp,sp,#96
    ret
.size ORIGINAL_SYMBOL,.-ORIGINAL_SYMBOL
.section .note.GNU-stack,"",%progbits
