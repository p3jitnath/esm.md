/* UPDATE_FIELDS keeps field units and separately rounded source-minus-sink updates. */
/* Ninety-seven addresses follow AAPCS64. Null optional addresses disable reads. */
/* Source contract skills/md2asm/references/openifs/physics/update_fields.md. */
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL update_fields_
#endif
.text
.p2align 4
.global ORIGINAL_SYMBOL
.type ORIGINAL_SYMBOL,%function
ORIGINAL_SYMBOL:
    mov x8,sp
    sub sp,sp,#880
    stp x19,x20,[sp,#0]
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x25,x26,[sp,#48]
    stp x27,x28,[sp,#64]
    stp x29,x30,[sp,#80]
    stp x0,x1,[sp,#96]
    stp x2,x3,[sp,#112]
    stp x4,x5,[sp,#128]
    stp x6,x7,[sp,#144]
    add x9,sp,#160
    mov w10,#89
.Lsave_addresses:
    ldr x11,[x8],#8
    str x11,[x9],#8
    subs w10,w10,#1
    b.ne .Lsave_addresses
    ldr x0,[sp,#96]
    ldr d4,[x0,#8]
    dup v4.2d,v4.d[0]
    ldr x0,[sp,#104]
    ldr w24,[x0]
    ldr x0,[sp,#112]
    ldr w20,[x0]
    sub w20,w20,#1
    lsl x20,x20,#3
    ldr x0,[sp,#120]
    ldr w21,[x0]
    lsl x21,x21,#3
    ldr x0,[sp,#128]
    ldr w22,[x0]
    lsl x22,x22,#3
    ldr x0,[sp,#136]
    ldr w23,[x0]
    cbz x23,.Lfinish
    cmp x20,x21
    b.hs .Lfinish
    mov x19,#0
.Lfield:
    add x9,sp,#96
    add x9,x9,x19,lsl #3
    ldr x28,[x9,#672]
    cbz x28,.Lnext_field
    ldr x0,[x9,#360]
    cbz x0,.Lactive_field
    ldr w0,[x0]
    cbz w0,.Lnext_field
.Lactive_field:
    ldr x25,[x9,#48]
    ldr x26,[x9,#464]
    ldr x27,[x9,#568]
    ldr x15,[x9,#256]
    ldr x16,[x9,#152]
    mov x12,#0
    mov x10,x23
.Lrow:
    mov x13,x20
.Lpairs:
    add x17,x13,#16
    cmp x17,x21
    b.hi .Lscalar
    add x14,x12,x13
    cbz x25,.Lpair_incoming
    ldr q0,[x25,x14]
    b .Lpair_rate
.Lpair_incoming:
    ldr q0,[x28,x14]
.Lpair_rate:
    cmp w24,#1
    b.ne .Lpair_add
    ldr q1,[x26,x14]
    cbz x27,.Lpair_product
    ldr q2,[x27,x14]
    fsub v1.2d,v1.2d,v2.2d
.Lpair_product:
    fmul v1.2d,v1.2d,v4.2d
    fadd v0.2d,v0.2d,v1.2d
.Lpair_add:
    cbz x15,.Lpair_subtract
    ldr q1,[x15,x14]
    fadd v0.2d,v0.2d,v1.2d
.Lpair_subtract:
    cbz x16,.Lpair_store
    ldr q1,[x16,x14]
    fsub v0.2d,v0.2d,v1.2d
.Lpair_store:
    str q0,[x28,x14]
    mov x13,x17
    cmp x13,x21
    b.lo .Lpairs
    b .Lnext_row
.Lscalar:
    cmp x13,x21
    b.hs .Lnext_row
    add x14,x12,x13
    cbz x25,.Lscalar_incoming
    ldr d0,[x25,x14]
    b .Lscalar_rate
.Lscalar_incoming:
    ldr d0,[x28,x14]
.Lscalar_rate:
    cmp w24,#1
    b.ne .Lscalar_add
    ldr d1,[x26,x14]
    cbz x27,.Lscalar_product
    ldr d2,[x27,x14]
    fsub d1,d1,d2
.Lscalar_product:
    fmul d1,d1,d4
    fadd d0,d0,d1
.Lscalar_add:
    cbz x15,.Lscalar_subtract
    ldr d1,[x15,x14]
    fadd d0,d0,d1
.Lscalar_subtract:
    cbz x16,.Lscalar_store
    ldr d1,[x16,x14]
    fsub d0,d0,d1
.Lscalar_store:
    str d0,[x28,x14]
.Lnext_row:
    add x12,x12,x22
    subs x10,x10,#1
    b.ne .Lrow
.Lnext_field:
    add x19,x19,#1
    cmp x19,#13
    b.lo .Lfield
.Lfinish:
    ldp x19,x20,[sp,#0]
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x25,x26,[sp,#48]
    ldp x27,x28,[sp,#64]
    ldp x29,x30,[sp,#80]
    add sp,sp,#880
    ret
.size ORIGINAL_SYMBOL,.-ORIGINAL_SYMBOL
.section .note.GNU-stack,"",%progbits
