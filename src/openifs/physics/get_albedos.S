/* Map surface reflection to every atmospheric spectral sample.
 * Physics is formulations/openifs/physics/surface_albedos.md.
 * Ordered ABI is skills/md2asm/references/openifs/physics/get_albedos.md.
 * Seven pointers use x0..x6. Fractions are dimensionless FP64.
 * Original GNU configuration and allocatable descriptors stay read-only.
 * The 160-byte frame preserves x19..x30. x18 and d8..d15 stay untouched.
 * Private scratch is 16*max(shortwave_bands,longwave_bands) bytes.
 * Two horizontal columns share each weighted band, followed by a scalar tail. */
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL __radiation_single_level_MOD_get_albedos
#endif
.text
.p2align 2
.macro CFGADDR dst,offset
    add \dst,x20,#(\offset >> 12),lsl #12
    add \dst,\dst,#(\offset & 4095)
.endm
.macro LOADVALUES reg,address,width
.if \width == 2
    ldr q\reg,[\address]
.else
    ldr d\reg,[\address]
.endif
.endm
.macro COMPLEMENT reg,width
.if \width == 2
    fsub v\reg\().2d,v31.2d,v\reg\().2d
.else
    fsub d\reg,d31,d\reg
.endif
.endm
.macro WEIGHTED_GROUP width
    ldr x7,[x24]
    ldr x8,[x24,#8]
    ldr x9,[x24,#64]
    ldr x10,[x24,#40]
    add x11,x21,x0
    madd x8,x11,x10,x8
    add x7,x7,x8,lsl #3
    cmp x4,#1
    b.ne .Lemit_start\@
    mov x12,#1
.Lband\@:
    movi v0.2d,#0
    ldr x10,[x26,#56]
    ldr x11,[x26,#48]
    sub x10,x10,x11
    add x10,x10,#1
    ldr x14,[x26]
    ldr x15,[x26,#8]
    ldr x16,[x26,#64]
    madd x15,x12,x16,x15
    add x15,x15,#1
    add x14,x14,x15,lsl #3
    lsl x16,x9,#3
    add x15,x7,x16
    mov x13,#0
.Linterval\@:
    ldr d1,[x14],#8
    fcmp d1,#0.0
    b.eq .Lnext_interval\@
    LOADVALUES 2,x15,\width
    cbz x5,.Lmultiply\@
    COMPLEMENT 2,\width
.Lmultiply\@:
.if \width == 2
    dup v1.2d,v1.d[0]
    fmul v2.2d,v1.2d,v2.2d
    fadd v0.2d,v0.2d,v2.2d
.else
    fmul d2,d1,d2
    fadd d0,d0,d2
.endif
.Lnext_interval\@:
    add x15,x15,x16
    add x13,x13,#1
    cmp x13,x10
    b.lo .Linterval\@
    sub x17,x12,#1
    add x17,sp,x17,lsl #4
.if \width == 2
    str q0,[x17]
.else
    str d0,[x17]
.endif
    add x12,x12,#1
    cmp x12,x28
    b.ls .Lband\@
.Lemit_start\@:
    mul x14,x0,x27
    add x14,x23,x14,lsl #3
    lsl x13,x27,#3
    mov x12,#0
.Lemit\@:
    add x15,x12,#1
    cbz x4,.Linput_value\@
    ldr x8,[x25]
    ldr x10,[x25,#8]
    ldr x11,[x25,#40]
    madd x10,x15,x11,x10
    ldrsw x15,[x8,x10,lsl #2]
    cmp x4,#1
    b.eq .Lband_value\@
    ldr x8,[x6]
    ldr x10,[x6,#8]
    ldr x11,[x6,#40]
    madd x10,x15,x11,x10
    ldrsw x15,[x8,x10,lsl #2]
.Linput_value\@:
    mul x15,x15,x9
    add x17,x7,x15,lsl #3
    LOADVALUES 0,x17,\width
    cbz x5,.Lstore_value\@
    COMPLEMENT 0,\width
    b .Lstore_value\@
.Lband_value\@:
    sub x15,x15,#1
    add x17,sp,x15,lsl #4
    LOADVALUES 0,x17,\width
.Lstore_value\@:
    str d0,[x14]
.if \width == 2
    add x17,x14,x13
    st1 {v0.d}[1],[x17]
.endif
    add x14,x14,#8
    add x12,x12,#1
    cmp x12,x27
    b.lo .Lemit\@
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
    mov x29,sp
    ldr x19,[x0]
    mov x20,x3
    ldrsw x21,[x1]
    ldrsw x22,[x2]
    sub x22,x22,x21
    add x22,x22,#1
    cmp x22,#0
    b.le .Lreturn
    str x4,[sp,#96]
    str x5,[sp,#104]
    str x6,[sp,#112]
    add x17,x20,#4,lsl #12
    ldrsw x9,[x17,#3620]
    ldrsw x10,[x17,#3624]
    cmp x9,x10
    csel x9,x9,x10,ge
    lsl x9,x9,#4
    sub sp,sp,x9
    fmov d31,#1.0
    dup v31.2d,v31.d[0]

    ldr x23,[x29,#104]
    add x24,x19,#128
    CFGADDR x25,10928
    CFGADDR x26,10432
    CFGADDR x6,10304
    add x17,x20,#4,lsl #12
    ldrsw x27,[x17,#3612]
    ldrsw x28,[x17,#3620]
    ldr w4,[x20,#7984]
    cbnz w4,.Lsw_full
    ldr w4,[x20,#708]
    cmp w4,#0
    mov x4,#1
    mov x9,#2
    csel x4,x4,x9,eq
    b .Lsw_mode_ready
.Lsw_full:
    mov x4,#0
.Lsw_mode_ready:
    mov x5,#0
    bl .Lmap_spectrum
    add x24,x19,#216
    ldr x9,[x24]
    cbz x9,.Ldirect_missing
    ldr x23,[x29,#96]
    bl .Lmap_spectrum
    b .Llongwave
.Ldirect_missing:
    cbz x4,.Llongwave
    mul x9,x22,x27
    lsl x9,x9,#3
    ldr x10,[x29,#104]
    ldr x11,[x29,#96]
.Lcopy_direct:
    cmp x9,#16
    b.lo .Lcopy_tail
    ldr q0,[x10],#16
    str q0,[x11],#16
    sub x9,x9,#16
    b .Lcopy_direct
.Lcopy_tail:
    cbz x9,.Llongwave
    ldr d0,[x10]
    str d0,[x11]
.Llongwave:
    ldr x23,[x29,#112]
    cbz x23,.Lreturn
    add x24,x19,#304
    CFGADDR x25,10864
    CFGADDR x26,10520
    CFGADDR x6,10368
    add x17,x20,#4,lsl #12
    ldrsw x27,[x17,#3616]
    ldrsw x28,[x17,#3624]
    ldr w4,[x20,#7988]
    cbnz w4,.Llw_full
    ldr w4,[x20,#712]
    cmp w4,#0
    mov x4,#1
    mov x9,#2
    csel x4,x4,x9,eq
    b .Llw_mode_ready
.Llw_full:
    mov x4,#0
.Llw_mode_ready:
    mov x5,#1
    bl .Lmap_spectrum
.Lreturn:
    mov sp,x29
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp x29,x30,[sp],#160
    ret

/* Map independent horizontal columns without changing the reduction order. */
.Lmap_spectrum:
    mov x0,#0
    cmp x22,#2
    b.lo .Lmap_scalar
.Lmap_pair:
    WEIGHTED_GROUP 2
    add x0,x0,#2
    sub x17,x22,x0
    cmp x17,#2
    b.hs .Lmap_pair
    cbz x17,.Lmap_finished
.Lmap_scalar:
    WEIGHTED_GROUP 1
.Lmap_finished:
    ret
.size ORIGINAL_SYMBOL,.-ORIGINAL_SYMBOL
.section .note.GNU-stack,"",%progbits
