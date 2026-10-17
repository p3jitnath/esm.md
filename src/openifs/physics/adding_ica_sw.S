/* Add shortwave radiation reflected between atmospheric layers.
 * Physics is formulations/openifs/physics/shortwave_adding.md.
 * Ordered arithmetic and ABI are skills/md2asm/references/openifs/physics/adding_ica_sw.md.
 * Fourteen pointers arrive through x0..x7 and six caller-stack slots.
 * Outputs contain every half-level flux in W/m^2, in Fortran column order.
 * The 160-byte frame preserves x19..x30 and d8..d15. x18 stays untouched.
 * Private scratch is 96*(nlev+1) bytes, aligned to 16 bytes.
 * Two independent vector groups, a pair and a scalar retain all roundings. */
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL __radiation_adding_ica_sw_MOD_adding_ica_sw
#endif
.text
.p2align 2

/* Load or store one complete independent group within the owner bounds. */
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

/* Every group includes the complete direct, upward and downward passes. */
.macro ADDING_GROUP width
    ALD 1,x4,x5,\width       /* Solar cosine. */
    ALD 0,x1,x5,\width       /* Unscaled incoming beam. */
    AST 0,x24,x5,\width
    mov x9,#0
    mov x10,x5
.Ldirect\@:
    cmp x9,x20
    b.hs .Lground\@
    ALD 25,x0,x10,\width
    AMUL 0,0,25,\width
    add x10,x10,x21
    AST 0,x24,x10,\width
    add x9,x9,#1
    b .Ldirect\@

.Lground\@:
    ALD 16,x2,x5,\width      /* Ground diffuse albedo. */
    ALD 3,x3,x5,\width       /* Ground direct albedo. */
    AMUL 17,3,0,\width
    AMUL 17,17,1,\width      /* Ordered ground source. */
    lsl x11,x20,#4
    AST 16,x6,x11,\width
    AST 17,x7,x11,\width
    mov x9,x20

.Lupward\@:
    cbz x9,.Ltop\@
    sub x9,x9,#1
    sub x10,x10,x21
    lsl x11,x9,#4
    ALD 4,x25,x10,\width
    ALD 5,x26,x10,\width
    ALD 6,x27,x10,\width
    ALD 7,x28,x10,\width
    ALD 0,x24,x10,\width
    AMUL 18,16,4,\width
    ASUB 18,22,18,\width
    ADIV 18,22,18,\width
    AST 18,x8,x11,\width
    AMUL 19,5,5,\width
    AMUL 19,19,16,\width
    AMUL 19,19,18,\width
    AADD 19,4,19,\width
    AMUL 20,6,0,\width
    AMUL 21,16,7,\width
    AMUL 21,21,0,\width
    AADD 21,17,21,\width
    AMUL 21,5,21,\width
    AMUL 21,21,18,\width
    AADD 20,20,21,\width
    AST 19,x6,x11,\width
    AST 20,x7,x11,\width
    ACOPY 16,19,\width
    ACOPY 17,20,\width
    b .Lupward\@

.Ltop\@:
    movi v23.2d,#0
    AST 23,x23,x5,\width     /* Positive-zero diffuse top flux. */
    AST 17,x22,x5,\width
    mov x9,#0
    mov x10,x5
.Ldownward\@:
    cmp x9,x20
    b.hs .Llast_direct\@
    lsl x11,x9,#4
    ALD 18,x8,x11,\width
    add x11,x11,#16
    ALD 16,x6,x11,\width
    ALD 17,x7,x11,\width
    ALD 4,x25,x10,\width
    ALD 5,x26,x10,\width
    ALD 7,x28,x10,\width
    ALD 0,x24,x10,\width
    AMUL 19,5,23,\width
    AMUL 20,4,17,\width
    AADD 19,19,20,\width
    AMUL 20,7,0,\width
    AADD 19,19,20,\width
    AMUL 19,19,18,\width
    AMUL 24,16,19,\width
    AADD 24,24,17,\width
    AMUL 0,0,1,\width        /* Convert only after its scattering consumers. */
    AST 0,x24,x10,\width
    add x10,x10,x21
    AST 19,x23,x10,\width
    AST 24,x22,x10,\width
    ACOPY 23,19,\width
    add x9,x9,#1
    b .Ldownward\@
.Llast_direct\@:
    ALD 0,x24,x10,\width
    AMUL 0,0,1,\width
    AST 0,x24,x10,\width
.endm


/* Two independent vector groups share loop control and address calculation.
 * Registers 0..14 and 16..30 hold the groups. v15 holds exact one.
 * Each cell retains every original multiplication, sum and division. */
.macro ALD4 lo,hi,base,index
    add x15,\base,\index
    ldp q\lo,q\hi,[x15]
.endm
.macro AST4 lo,hi,base,index
    add x15,\base,\index
    stp q\lo,q\hi,[x15]
.endm
.macro AMUL4 a,b,c,d,e,f
    fmul v\a\().2d,v\c\().2d,v\e\().2d
    fmul v\b\().2d,v\d\().2d,v\f\().2d
.endm
.macro AADD4 a,b,c,d,e,f
    fadd v\a\().2d,v\c\().2d,v\e\().2d
    fadd v\b\().2d,v\d\().2d,v\f\().2d
.endm
.macro ASUB4 a,b,c,d,e,f
    fsub v\a\().2d,v\c\().2d,v\e\().2d
    fsub v\b\().2d,v\d\().2d,v\f\().2d
.endm
.macro ADIV4 a,b,c,d,e,f
    fdiv v\a\().2d,v\c\().2d,v\e\().2d
    fdiv v\b\().2d,v\d\().2d,v\f\().2d
.endm

.macro ADDING_FOUR_GROUP
    ALD4 1,17,x4,x5
    ALD4 0,16,x1,x5
    AST4 0,16,x24,x5
    mov x9,x20
    mov x10,x5
    cbz x9,.Lfour_ground\@
.Lfour_direct\@:
    ALD4 2,18,x0,x10
    AMUL4 0,16,0,16,2,18
    add x10,x10,x21
    AST4 0,16,x24,x10
    subs x9,x9,#1
    b.ne .Lfour_direct\@
.Lfour_ground\@:
    ALD4 3,19,x2,x5
    ALD4 5,21,x3,x5
    AMUL4 4,20,5,21,0,16
    AMUL4 4,20,4,20,1,17
    add x6,x6,x20,lsl #5
    add x7,x7,x20,lsl #5
    add x8,x8,x20,lsl #5
    stp q3,q19,[x6]
    stp q4,q20,[x7]
    mov x9,x20
    cbz x9,.Lfour_top\@
.Lfour_upward\@:
    sub x10,x10,x21
    ALD4 5,21,x25,x10
    ALD4 6,22,x26,x10
    ALD4 7,23,x27,x10
    ALD4 8,24,x28,x10
    ALD4 0,16,x24,x10
    AMUL4 9,25,3,19,5,21
    ASUB4 9,25,15,15,9,25
    ADIV4 9,25,15,15,9,25
    AMUL4 10,26,6,22,6,22
    AMUL4 10,26,10,26,3,19
    AMUL4 11,27,7,23,0,16
    AMUL4 12,28,3,19,8,24
    AMUL4 12,28,12,28,0,16
    AADD4 12,28,4,20,12,28
    AMUL4 12,28,6,22,12,28
    AMUL4 3,19,10,26,9,25
    AADD4 3,19,5,21,3,19
    AMUL4 12,28,12,28,9,25
    AADD4 4,20,11,27,12,28
    stp q9,q25,[x8,#-32]!
    stp q3,q19,[x6,#-32]!
    stp q4,q20,[x7,#-32]!
    subs x9,x9,#1
    b.ne .Lfour_upward\@
.Lfour_top\@:
    movi v14.2d,#0
    movi v30.2d,#0
    AST4 14,30,x23,x5
    AST4 4,20,x22,x5
    mov x9,x20
    mov x10,x5
    cbz x9,.Lfour_last_direct\@
.Lfour_downward\@:
    ldp q9,q25,[x8],#32
    ldp q3,q19,[x6,#32]!
    ldp q4,q20,[x7,#32]!
    ALD4 5,21,x25,x10
    ALD4 6,22,x26,x10
    ALD4 8,24,x28,x10
    ALD4 0,16,x24,x10
    AMUL4 10,26,6,22,14,30
    AMUL4 11,27,5,21,4,20
    AADD4 10,26,10,26,11,27
    AMUL4 11,27,8,24,0,16
    AADD4 10,26,10,26,11,27
    AMUL4 14,30,10,26,9,25
    AMUL4 13,29,3,19,14,30
    AADD4 13,29,13,29,4,20
    AMUL4 0,16,0,16,1,17
    AST4 0,16,x24,x10
    add x10,x10,x21
    AST4 14,30,x23,x10
    AST4 13,29,x22,x10
    subs x9,x9,#1
    b.ne .Lfour_downward\@
.Lfour_last_direct\@:
    ALD4 0,16,x24,x10
    AMUL4 0,16,0,16,1,17
    AST4 0,16,x24,x10
    // The old pair and scalar remainder keep the original scratch bases.
    sub x6,x6,x20,lsl #5
    sub x7,x7,x20,lsl #5
    sub x8,x8,x20,lsl #5
.endm

.global ORIGINAL_SYMBOL
.type ORIGINAL_SYMBOL,%function
ORIGINAL_SYMBOL:
    stp x29,x30,[sp,#-160]!
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    stp d8,d9,[sp,#96]
    stp d10,d11,[sp,#112]
    stp d12,d13,[sp,#128]
    stp d14,d15,[sp,#144]
    mov x29,sp
    ldrsw x19,[x0]
    ldrsw x20,[x1]
    mov x1,x2
    mov x2,x3
    mov x3,x4
    mov x4,x5
    mov x25,x6
    mov x26,x7
    ldp x27,x28,[sp,#160]
    ldp x0,x22,[sp,#176]
    ldp x23,x24,[sp,#192]
    cbz x19,.Lreturn
    lsl x21,x19,#3           /* Complete plane pitch, in bytes. */
    add x12,x20,#1
    lsl x12,x12,#5
    add x13,x12,x12,lsl #1
    sub sp,sp,x13
    mov x6,sp
    add x7,x6,x12
    add x8,x7,x12
    fmov d15,#1.0
    dup v15.2d,v15.d[0]
    mov x5,#0
    cmp x19,#4
    b.lo .Lpair_dispatch
.Lfour:
    ADDING_FOUR_GROUP
    add x5,x5,#32
    sub x17,x21,x5
    cmp x17,#32
    b.hs .Lfour
    cbz x17,.Lreturn
.Lpair_dispatch:
    fmov d22,#1.0
    dup v22.2d,v22.d[0]
    sub x17,x21,x5
    cmp x17,#16
    b.lo .Lscalar
.Lpair:
    ADDING_GROUP 2
    add x5,x5,#16
    sub x17,x21,x5
    cmp x17,#16
    b.hs .Lpair
    cbz x17,.Lreturn
.Lscalar:
    ADDING_GROUP 1
.Lreturn:
    mov sp,x29
    ldp d8,d9,[sp,#96]
    ldp d10,d11,[sp,#112]
    ldp d12,d13,[sp,#128]
    ldp d14,d15,[sp,#144]
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp x29,x30,[sp],#160
    ret
.size ORIGINAL_SYMBOL,.-ORIGINAL_SYMBOL
.section .note.GNU-stack,"",%progbits
