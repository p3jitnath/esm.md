/* Complete longwave transport with scattering in cloudy layers.
 * Physics is formulations/openifs/physics/longwave_adding.md.
 * Ordered ABI is skills/md2asm/references/openifs/physics/fast_adding_ica_lw.md.
 * Thirteen pointers use x0..x7 and five caller-stack slots.
 * Complete FP64 fluxes are W/m^2, in Fortran interval order.
 * The 96-byte frame preserves x19..x30. x18 and d8..d15 stay untouched.
 * Private scratch is 48*(nlev+1) bytes, aligned to 16 bytes.
 * Two independent lanes and one scalar remainder preserve every rounding. */
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL __radiation_adding_ica_lw_MOD_fast_adding_ica_lw
#endif
.text
.p2align 2
.macro ALD reg,base,index,width
    add x15,\base,\index
.if \width == 2
    ldr q\reg,[x15]
.else
    ldr d\reg,[x15]
.endif
.endm
.macro AST reg,base,index,width
    add x15,\base,\index
.if \width == 2
    str q\reg,[x15]
.else
    str d\reg,[x15]
.endif
.endm
.macro AMUL dst,lhs,rhs,width
.if \width == 2
    fmul v\dst\().2d,v\lhs\().2d,v\rhs\().2d
.else
    fmul d\dst,d\lhs,d\rhs
.endif
.endm
.macro AADD dst,lhs,rhs,width
.if \width == 2
    fadd v\dst\().2d,v\lhs\().2d,v\rhs\().2d
.else
    fadd d\dst,d\lhs,d\rhs
.endif
.endm
.macro ASUB dst,lhs,rhs,width
.if \width == 2
    fsub v\dst\().2d,v\lhs\().2d,v\rhs\().2d
.else
    fsub d\dst,d\lhs,d\rhs
.endif
.endm
.macro ADIV dst,lhs,rhs,width
.if \width == 2
    fdiv v\dst\().2d,v\lhs\().2d,v\rhs\().2d
.else
    fdiv d\dst,d\lhs,d\rhs
.endif
.endm
.macro ACOPY dst,src,width
.if \width == 2
    mov v\dst\().16b,v\src\().16b
.else
    fmov d\dst,d\src
.endif
.endm

.macro LWFAST_GROUP width
    mov x9,#0
    mov x10,x5
.Lcopy\@:
    ALD 23,x24,x10,\width
    AST 23,x23,x10,\width
    cmp x9,x3
    b.hs .Lground\@
    add x9,x9,#1
    add x10,x10,x21
    b .Lcopy\@
.Lground\@:
    ALD 16,x1,x5,\width
    ALD 17,x0,x5,\width
    lsl x11,x20,#4
    AST 16,x6,x11,\width
    AST 17,x7,x11,\width
    mov x9,x20
    madd x10,x20,x21,x5
.Lupward\@:
    cmp x9,x3
    b.ls .Lcloudtop\@
    sub x9,x9,#1
    sub x10,x10,x21
    lsl x11,x9,#4
    ALD 4,x26,x10,\width
    ALD 6,x27,x10,\width
    ALD 7,x28,x10,\width
    AMUL 19,4,4,\width
    AMUL 19,19,16,\width
    AMUL 20,16,7,\width
    AADD 20,17,20,\width
    AMUL 20,4,20,\width
    ldr w14,[x2,x9,lsl #2]
    cbz w14,.Lcloud_up\@
    AADD 20,6,20,\width
    b .Lstore_up\@
.Lcloud_up\@:
    ALD 5,x25,x10,\width
    AMUL 18,16,5,\width
    ASUB 18,22,18,\width
    ADIV 18,22,18,\width
    AST 18,x8,x11,\width
    AMUL 19,19,18,\width
    AADD 19,5,19,\width
    AMUL 20,20,18,\width
    AADD 20,6,20,\width
.Lstore_up\@:
    AST 19,x6,x11,\width
    AST 20,x7,x11,\width
    ACOPY 16,19,\width
    ACOPY 17,20,\width
    b .Lupward\@
.Lcloudtop\@:
    ALD 23,x23,x10,\width
    AMUL 24,16,23,\width
    AADD 24,17,24,\width
    AST 24,x22,x10,\width
    mov x9,x3
.Labove\@:
    cbz x9,.Ldown_start\@
    sub x9,x9,#1
    sub x10,x10,x21
    ALD 4,x26,x10,\width
    ALD 6,x27,x10,\width
    AMUL 24,4,24,\width
    AADD 24,24,6,\width
    AST 24,x22,x10,\width
    b .Labove\@
.Ldown_start\@:
    mov x9,x3
    madd x10,x3,x21,x5
    ALD 23,x23,x10,\width
.Ldownward\@:
    cmp x9,x20
    b.hs .Lfinished\@
    lsl x11,x9,#4
    add x12,x11,#16
    ALD 16,x6,x12,\width
    ALD 17,x7,x12,\width
    ALD 4,x26,x10,\width
    ALD 7,x28,x10,\width
    AMUL 19,4,23,\width
    ldr w14,[x2,x9,lsl #2]
    cbz w14,.Lcloud_down\@
    AADD 19,19,7,\width
    b .Lstore_down\@
.Lcloud_down\@:
    ALD 5,x25,x10,\width
    ALD 18,x8,x11,\width
    AMUL 20,5,17,\width
    AADD 19,19,20,\width
    AADD 19,19,7,\width
    AMUL 19,19,18,\width
.Lstore_down\@:
    AMUL 24,16,19,\width
    AADD 24,24,17,\width
    add x10,x10,x21
    AST 19,x23,x10,\width
    AST 24,x22,x10,\width
    ACOPY 23,19,\width
    add x9,x9,#1
    b .Ldownward\@
.Lfinished\@:
.endm

.global ORIGINAL_SYMBOL
.type ORIGINAL_SYMBOL,%function
ORIGINAL_SYMBOL:
    stp x29,x30,[sp,#-96]!
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    mov x29,sp
    ldrsw x19,[x0]
    ldrsw x20,[x1]
    mov x25,x2
    mov x26,x3
    mov x27,x4
    mov x28,x5
    mov x0,x6
    mov x1,x7
    ldr x2,[sp,#96]
    ldr x15,[sp,#104]
    ldrsw x3,[x15]
    sub x3,x3,#1
    ldr x24,[sp,#112]
    ldp x22,x23,[sp,#120]
    cbz x19,.Lreturn
    lsl x21,x19,#3
    add x12,x20,#1
    lsl x12,x12,#4
    add x13,x12,x12,lsl #1
    sub sp,sp,x13
    mov x6,sp
    add x7,x6,x12
    add x8,x7,x12
    fmov d22,#1.0
    dup v22.2d,v22.d[0]
    mov x5,#0
    cmp x19,#2
    b.lo .Lscalar
.Lpair:
    LWFAST_GROUP 2
    add x5,x5,#16
    sub x17,x21,x5
    cmp x17,#16
    b.hs .Lpair
    cbz x17,.Lreturn
.Lscalar:
    LWFAST_GROUP 1
.Lreturn:
    mov sp,x29
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp x29,x30,[sp],#96
    ret
.size ORIGINAL_SYMBOL,.-ORIGINAL_SYMBOL
.section .note.GNU-stack,"",%progbits
