/* Complete droplet rational fits from the frozen optical contract.
 * Seven GNU argument addresses, rank2 coefficient descriptor, three full stages.
 * Use caller-saved registers only; no frame or numerical helper is present. */
.text
.p2align 4
.global __radiation_liquid_optics_socrates_MOD_calc_liq_optics_socrates
.type __radiation_liquid_optics_socrates_MOD_calc_liq_optics_socrates,%function
__radiation_liquid_optics_socrates_MOD_calc_liq_optics_socrates:
    ldrsw x0,[x0]
    cmp x0,#0
    b.le .Lreturn
    ldr x7,[x1]                   // First logical coefficient, independent of lower bounds.
    ldr x8,[x1,#40]
    ldr x9,[x1,#64]
    ldr x10,[x1,#32]
    mul x8,x8,x10                // Row stride in bytes, possibly negative.
    mul x9,x9,x10                // Coefficient-column stride in bytes.
    ldr d1,[x2]                  // Liquid water path, kilograms per square metre.
    ldr d0,[x3]                  // Droplet radius in metres.
    fmov d2,#1.0
    mov x10,x7
    mov x11,x0
    mov x13,x4
.Loptical_depth:
    add x12,x10,x9,lsl #1        // C3, followed by C2 and C1.
    ldr d3,[x12]
    fmul d3,d0,d3
    sub x12,x12,x9
    ldr d5,[x12]
    fadd d3,d5,d3
    fmul d3,d0,d3
    sub x12,x12,x9
    ldr d5,[x12]
    fadd d3,d5,d3
    fmul d3,d1,d3                // Water multiplication precedes direct division.
    add x12,x10,x9,lsl #2
    add x12,x12,x9               // C6, followed by C5 and C4.
    ldr d4,[x12]
    fmul d4,d0,d4
    sub x12,x12,x9
    ldr d5,[x12]
    fadd d4,d5,d4
    fmul d4,d0,d4
    sub x12,x12,x9
    ldr d5,[x12]
    fadd d4,d5,d4
    fmul d4,d0,d4
    fadd d4,d2,d4
    fdiv d3,d3,d4
    str d3,[x13]
    add x13,x13,#8
    add x10,x10,x8
    subs x11,x11,#1
    b.ne .Loptical_depth
    mov x10,x7
    mov x11,x0
    mov x13,x5
    mov x14,x4
.Lscattering_depth:
    add x12,x10,x9,lsl #3        // C9, followed by C8 and C7.
    ldr d3,[x12]
    fmul d3,d0,d3
    sub x12,x12,x9
    ldr d5,[x12]
    fadd d3,d5,d3
    fmul d3,d0,d3
    sub x12,x12,x9
    ldr d5,[x12]
    fadd d3,d5,d3
    add x12,x10,x9,lsl #3
    add x12,x12,x9,lsl #1        // C11, followed by C10.
    ldr d4,[x12]
    fmul d4,d0,d4
    sub x12,x12,x9
    ldr d5,[x12]
    fadd d4,d5,d4
    fmul d4,d0,d4
    fadd d4,d2,d4
    fdiv d3,d3,d4
    fsub d3,d2,d3                // One minus absorption fraction.
    ldr d6,[x14]
    fmul d3,d6,d3                // Use the stored optical-depth stage.
    str d3,[x13]
    add x14,x14,#8
    add x13,x13,#8
    add x10,x10,x8
    subs x11,x11,#1
    b.ne .Lscattering_depth
    mov x10,x7
    mov x11,x0
    mov x13,x6
.Lasymmetry:
    add x12,x10,x9,lsl #3
    add x12,x12,x9,lsl #2
    add x12,x12,x9               // C14, followed by C13 and C12.
    ldr d3,[x12]
    fmul d3,d0,d3
    sub x12,x12,x9
    ldr d5,[x12]
    fadd d3,d5,d3
    fmul d3,d0,d3
    sub x12,x12,x9
    ldr d5,[x12]
    fadd d3,d5,d3
    add x12,x10,x9,lsl #4
    sub x12,x12,x9               // C16, followed by C15.
    ldr d4,[x12]
    fmul d4,d0,d4
    sub x12,x12,x9
    ldr d5,[x12]
    fadd d4,d5,d4
    fmul d4,d0,d4
    fadd d4,d2,d4
    fdiv d3,d3,d4
    str d3,[x13]
    add x13,x13,#8
    add x10,x10,x8
    subs x11,x11,#1
    b.ne .Lasymmetry
.Lreturn:
    ret
.size __radiation_liquid_optics_socrates_MOD_calc_liq_optics_socrates,.-__radiation_liquid_optics_socrates_MOD_calc_liq_optics_socrates
.section .note.GNU-stack,"",%progbits
