/* Direct runtime GPPWC with explicit HYD64. Contract skills/md2asm/references/openifs/transport/pressure_weighted_column_integral.md. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_explicit_pressure_weighted_column_integral
.type md2asm_explicit_pressure_weighted_column_integral, %function
md2asm_explicit_pressure_weighted_column_integral:
    cbz x0,.Lcolumn_bad
    cbz x1,.Lcolumn_bad
    cbz x2,.Lcolumn_bad
    cbz x3,.Lcolumn_bad
    cbz x4,.Lcolumn_bad
    cbz x5,.Lcolumn_bad
    cbz x6,.Lcolumn_bad
    cbz x7,.Lcolumn_bad
    orr x12,x0,x1
    orr x12,x12,x2
    orr x12,x12,x3
    tst x12,#3
    b.ne .Lcolumn_bad
    orr x12,x4,x5
    orr x12,x12,x6
    orr x12,x12,x7
    tst x12,#7
    b.ne .Lcolumn_bad
    mrs x12,fpcr
    cbnz x12,.Lcolumn_bad
    ldrsw x8,[x0]
    ldrsw x9,[x1]
    ldrsw x10,[x2]
    ldrsw x11,[x3]
    sub x12,x8,#1
    cmp x12,#4095
    b.hi .Lcolumn_bad
    cmp x11,#4096
    b.hi .Lcolumn_bad
    cmp x9,#1
    b.lt .Lcolumn_bad
    add x12,x8,#1
    cmp x9,x12
    b.gt .Lcolumn_bad
    cmp x10,#0
    b.lt .Lcolumn_bad
    cmp x10,x8
    b.gt .Lcolumn_bad
    add x12,x11,#1
    mul x12,x12,x8
    lsl x12,x12,#3
    adds x13,x4,x12
    b.cs .Lcolumn_bad
    adds x14,x6,x12
    b.cs .Lcolumn_bad
    mul x12,x11,x8
    lsl x12,x12,#3
    adds x15,x5,x12
    b.cs .Lcolumn_bad
    cmp x4,x14
    b.hs .Lcolumn_pressure_clear
    cmp x6,x13
    b.lo .Lcolumn_bad
.Lcolumn_pressure_clear:
    cbz x12,.Lcolumn_humidity_clear
    cmp x4,x15
    b.hs .Lcolumn_humidity_clear
    cmp x5,x13
    b.lo .Lcolumn_bad
.Lcolumn_humidity_clear:
    ldr x7,[x7]
    cbz x7,.Lcolumn_bad
    tst x7,#7
    b.ne .Lcolumn_bad
    ldr d0,[x7,#112]
    fmov d1,#1.0
    fdiv d0,d1,d0
    dup v0.2d,v0.d[0]
    cmp x9,x10
    b.gt .Ldone
    lsl x8,x8,#3
    sub x9,x9,#1
    lsl x9,x9,#3
    lsl x10,x10,#3

    eor v1.16b, v1.16b, v1.16b
    mov x15, x9
.Ltop:
    sub x16, x10, x15
    cmp x16, #16
    b.lt .Ltop_tail
    str q1, [x4, x15]
    add x15, x15, #16
    b .Ltop
.Ltop_tail:
    cbz x16, .Ltop_done
    str d1, [x4, x15]
.Ltop_done:
    cbz x11, .Ldone
.Llayer:
    add x13, x4, x8         /* Next water boundary. */
    add x14, x6, x8         /* Next pressure boundary. */
    mov x15, x9
.Lcolumns:
    sub x16, x10, x15
    cmp x16, #16
    b.lt .Ltail
    ldr q1, [x5, x15]
    ldr q2, [x6, x15]
    ldr q3, [x14, x15]
    ldr q4, [x4, x15]
    fsub v3.2d, v3.2d, v2.2d
    fmul v1.2d, v1.2d, v3.2d
    fmul v1.2d, v1.2d, v0.2d
    fadd v1.2d, v4.2d, v1.2d
    str q1, [x13, x15]
    add x15, x15, #16
    b .Lcolumns
.Ltail:
    cbz x16, .Lnext_layer
    ldr d1, [x5, x15]
    ldr d2, [x6, x15]
    ldr d3, [x14, x15]
    ldr d4, [x4, x15]
    fsub d3, d3, d2
    fmul d1, d1, d3
    fmul d1, d1, d0
    fadd d1, d4, d1
    str d1, [x13, x15]
.Lnext_layer:
    mov x4, x13
    mov x6, x14
    add x5, x5, x8
    subs x11, x11, #1
    b.ne .Llayer
.Ldone:
    mov w0,#0
    ret
.Lcolumn_bad:
    mov w0,#2
    ret
.size md2asm_explicit_pressure_weighted_column_integral, .-md2asm_explicit_pressure_weighted_column_integral
.section .note.GNU-stack,"",%progbits
