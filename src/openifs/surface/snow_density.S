/* Direct FP64 snow-density update from
 * formulations/openifs/surface/snow_density.md.
 * The full ordered update is in
 * skills/md2asm/references/openifs/surface/snow_density.md.
 *
 * ABI: 19 argument addresses in the original GNU Fortran order.
 * x0..x7 carry first, last, columns, layers, dt, mask, old density and mass.
 * The incoming stack carries temperature, old/new liquid, snowfall, u, v,
 * surface temperature, TSOIL, TCST, density and the untouched diagnostic.
 * A descriptor holds an array address, length and element stride.
 * Matrix cells follow column then layer order. Signed strides are supported.
 * Inputs are read-only. Output owners must be separate from every input.
 * The caller checks descriptor bounds, finite physical data and FPCR zero.
 * x18, x19..x29 and the low 64 bits of d8..d15 are preserved.
 * The 576-byte frame is aligned to 16 bytes. No fused operation is used.
 */
#ifndef SNOW_DENSITY_SYMBOL
#define SNOW_DENSITY_SYMBOL __srfsn_rsn_mod_MOD_srfsn_rsn
#endif

.text
.p2align 4
.global SNOW_DENSITY_SYMBOL
.type SNOW_DENSITY_SYMBOL,%function

/* x10 becomes the address of one vector element. */
.macro rsn_vector_address argument, unit=3
    ldr x9,[sp,#\argument]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x12,x11,eq
    mul x11,x19,x11
    add x10,x10,x11,lsl #\unit
.endm

/* x10 becomes the address of one column-by-layer cell. */
.macro rsn_matrix_address argument
    ldr x9,[sp,#\argument]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x12,x11,eq
    ldr x12,[x9,#64]
    mul x11,x19,x11
    madd x11,x20,x12,x11
    add x10,x10,x11,lsl #3
.endm

SNOW_DENSITY_SYMBOL:
    mov x16,sp
    sub sp,sp,#576
    stp x19,x20,[sp,#0]
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x25,x26,[sp,#48]
    stp x27,x28,[sp,#64]
    stp x29,x30,[sp,#80]
    stp d8,d9,[sp,#96]
    stp d10,d11,[sp,#112]
    stp d12,d13,[sp,#128]
    stp d14,d15,[sp,#144]
    stp x0,x1,[sp,#256]
    stp x2,x3,[sp,#272]
    stp x4,x5,[sp,#288]
    stp x6,x7,[sp,#304]
    ldp x9,x10,[x16,#0]
    stp x9,x10,[sp,#320]
    ldp x9,x10,[x16,#16]
    stp x9,x10,[sp,#336]
    ldp x9,x10,[x16,#32]
    stp x9,x10,[sp,#352]
    ldp x9,x10,[x16,#48]
    stp x9,x10,[sp,#368]
    ldp x9,x10,[x16,#64]
    stp x9,x10,[sp,#384]
    ldr x9,[x16,#80]
    str x9,[sp,#400]
    ldr w19,[x0]
    sub w19,w19,#1
    ldr w21,[x1]
    ldr w22,[x3]
    ldr d8,[x4]
    fmov d0,#1.0
    fdiv d9,d0,d8
    adrp x9,.Lrsn_epsilon
    ldr d10,[x9,:lo12:.Lrsn_epsilon]
    ldr x23,[sp,#376]
    ldr x24,[sp,#384]
    cmp w19,w21
    b.ge .Lrsn_return

.Lrsn_column:
    rsn_vector_address 296,2
    ldr w9,[x10]
    cbnz w9,.Lrsn_no_snow

    /* SN-RHO-01 gives the fresh-snow density. Keep the original POWER route. */
    rsn_vector_address 352
    ldr d0,[x10]
    fmul d0,d0,d0
    rsn_vector_address 360
    ldr d1,[x10]
    fmul d1,d1,d1
    fadd d0,d0,d1
    str d0,[sp,#232]
    fmov d1,#0.25
    bl md2asm_pow_original_rounding_candidate
    str d0,[sp,#240]

    /* The wind exponential has the same inputs in each layer. */
    ldr d0,[sp,#232]
    fsqrt d0,d0
    ldr d1,[x23,#1992]
    fneg d1,d1
    fmul d0,d1,d0
    bl exp
    fmax d0,d10,d0
    ldr d1,[x23,#1984]
    fmul d0,d1,d0
    fmov d1,#1.0
    fsub d0,d1,d0
    str d0,[sp,#192]

    rsn_vector_address 368
    ldr d0,[x10]
    ldr d1,[x24,#0]
    fsub d0,d0,d1
    ldr d1,[x23,#1816]
    fmul d0,d1,d0
    ldr d1,[x23,#1808]
    fadd d0,d1,d0
    ldr d1,[sp,#240]
    ldr d2,[x23,#1824]
    fmul d1,d2,d1
    fadd d0,d0,d1
    ldr d1,[x23,#1832]
    fmax d0,d0,d1
    str d0,[sp,#184]

    /* SN-RHO-02 mixes mass and volume in the top layer. */
    rsn_vector_address 344
    ldr d0,[x10]
    fmul d0,d8,d0
    str d0,[sp,#224]
    mov x20,#0
    rsn_matrix_address 312
    ldr d0,[x10]
    rsn_matrix_address 304
    ldr d1,[x10]
    fdiv d2,d0,d1
    ldr d3,[sp,#224]
    ldr d4,[sp,#184]
    fdiv d4,d3,d4
    fadd d4,d4,d2
    fmax d4,d10,d4
    fadd d0,d0,d3
    fdiv d0,d0,d4
    str d0,[sp,#200]
    fmov d11,xzr
    fmov d12,xzr

.Lrsn_layer:
    rsn_matrix_address 304
    ldr d14,[x10]
    rsn_matrix_address 312
    ldr d15,[x10]
    fmov d13,d14
    cbnz x20,.Lrsn_old_layer
    ldr d13,[sp,#200]
.Lrsn_old_layer:
    /* These layer quantities depend on the unchanged incoming state. */
    ldr d0,[x23,#1832]
    fsub d0,d14,d0
    ldr d1,[x23,#1976]
    fdiv d0,d0,d1
    fmov d1,xzr
    fmax d0,d1,d0
    fmov d1,#1.0
    fsub d0,d1,d0
    ldr d1,[x23,#1968]
    fmul d0,d1,d0
    ldr d1,[sp,#192]
    fadd d0,d1,d0
    str d0,[sp,#456]
    fmax d0,d10,d14
    fdiv d0,d15,d0
    str d0,[sp,#464]

    fcmp d15,d10
    b.ls .Lrsn_store

    /* Pressure from the layer and the snow above gives the first rate. */
    rsn_matrix_address 320
    ldr d0,[x10]
    ldr d1,[x24,#0]
    fsub d0,d1,d0
    ldr d1,[x23,#1848]
    fmul d0,d1,d0
    ldr d1,[x23,#1856]
    fmul d1,d1,d14
    fadd d0,d0,d1
    bl exp
    ldr d1,[x23,#1840]
    fmul d0,d1,d0
    fmov d1,#0.5
    fmul d1,d1,d15
    fadd d1,d11,d1
    ldr d2,[x24,#104]
    fmul d1,d1,d2
    fdiv d0,d1,d0
    str d0,[sp,#472]

    /* Changes in ice crystals give the second positive rate. */
    rsn_matrix_address 320
    ldr d0,[x10]
    ldr d1,[x24,#0]
    fsub d0,d1,d0
    ldr d1,[x23,#1872]
    fneg d1,d1
    fmul d0,d1,d0
    ldr d1,[x23,#1888]
    fsub d1,d14,d1
    fmov d2,xzr
    fmax d1,d2,d1
    ldr x9,[x23,#1896]
    ldr x10,[x23,#1904]
    add x11,x20,#1
    add x11,x11,x10
    ldr d2,[x9,x11,lsl #3]
    fmul d1,d2,d1
    fsub d0,d0,d1
    bl exp
    ldr d1,[x23,#1864]
    fmul d0,d1,d0
    str d0,[sp,#480]

    /* Retained liquid water gives the third rate. */
    rsn_matrix_address 336
    ldr d0,[x10]
    rsn_matrix_address 328
    ldr d1,[x10]
    fsub d0,d0,d1
    fmov d1,xzr
    fmax d0,d1,d0
    fmul d0,d9,d0
    fmax d1,d10,d15
    fdiv d0,d0,d1
    str d0,[sp,#488]

    /* Carry the wind integral in the original top-to-bottom order. */
    ldr d0,[sp,#456]
    fmov d1,xzr
    fmax d1,d1,d0
    str d1,[sp,#496]
    ldr d1,[x23,#2016]
    fsub d1,d1,d0
    ldr d0,[sp,#464]
    fmul d0,d0,d1
    fadd d12,d12,d0
    ldr d0,[x23,#2008]
    fneg d0,d0
    fmul d0,d0,d12
    bl exp
    fmax d0,d10,d0
    ldr d1,[sp,#496]
    fmul d0,d1,d0
    fmax d0,d10,d0
    adrp x9,.Lrsn_two_days
    ldr d1,[x9,:lo12:.Lrsn_two_days]
    fdiv d0,d1,d0
    ldr d1,[x23,#2024]
    fsub d1,d1,d14
    fdiv d0,d1,d0
    fmov d1,xzr
    fmax d0,d1,d0
    str d0,[sp,#504]

    /* SN-RHO-03 applies all four rates without changing rounding points. */
    ldr d0,[sp,#472]
    ldr d1,[sp,#480]
    fadd d0,d0,d1
    ldr d1,[sp,#488]
    fadd d0,d0,d1
    fmul d0,d13,d0
    fmul d0,d0,d8
    fadd d13,d13,d0
    ldr d0,[sp,#504]
    fmul d0,d0,d8
    fadd d13,d13,d0
    adrp x9,.Lrsn_maximum
    ldr d0,[x9,:lo12:.Lrsn_maximum]
    fmin d13,d0,d13
    ldr d0,[x23,#1832]
    fmax d13,d0,d13
    fadd d11,d11,d15

.Lrsn_store:
    /* The final original store uses ZRSTAR with its lower bound. */
    ldr d0,[x23,#1832]
    fmax d0,d0,d13
    rsn_matrix_address 392
    str d0,[x10]
    add w20,w20,#1
    cmp w20,w22
    b.lt .Lrsn_layer
    b .Lrsn_next_column

.Lrsn_no_snow:
    ldr d0,[x23,#352]
    mov x20,#0
.Lrsn_clear_layer:
    rsn_matrix_address 392
    str d0,[x10]
    add w20,w20,#1
    cmp w20,w22
    b.lt .Lrsn_clear_layer

.Lrsn_next_column:
    add w19,w19,#1
    cmp w19,w21
    b.lt .Lrsn_column

.Lrsn_return:
    ldp d14,d15,[sp,#144]
    ldp d12,d13,[sp,#128]
    ldp d10,d11,[sp,#112]
    ldp d8,d9,[sp,#96]
    ldp x29,x30,[sp,#80]
    ldp x27,x28,[sp,#64]
    ldp x25,x26,[sp,#48]
    ldp x23,x24,[sp,#32]
    ldp x21,x22,[sp,#16]
    ldp x19,x20,[sp,#0]
    add sp,sp,#576
    ret
.size SNOW_DENSITY_SYMBOL,.-SNOW_DENSITY_SYMBOL

.section .rodata
.p2align 3
.Lrsn_epsilon:
    .quad 0x3d06849b86a12b9c
.Lrsn_two_days:
    .double 172800.0
.Lrsn_maximum:
    .double 500.0
.section .note.GNU-stack,"",%progbits
