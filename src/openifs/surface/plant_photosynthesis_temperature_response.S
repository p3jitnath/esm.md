// Private-symbol temperature responses for src/openifs/surface/plant_photosynthesis.S.
// See skills/md2asm/references/openifs/surface/plant_photosynthesis.md.
// The caller supplies readonly scalar addresses and an original TCST record.
// FP64 arithmetic keeps each source product, sum and division separate.
.text
.p2align 2
.macro RANGE reg, lo, hi
    adrp x9, \lo
    ldr d6, [x9, :lo12:\lo]
    fcmp \reg, d6
    b.lt .Ltemperature_reject
    b.vs .Ltemperature_reject
    adrp x9, \hi
    ldr d6, [x9, :lo12:\hi]
    fcmp \reg, d6
    b.gt .Ltemperature_reject
.endm
.global md2asm_photosynthesis_temperature_response
.type md2asm_photosynthesis_temperature_response,%function
md2asm_photosynthesis_temperature_response:
    mrs x9, fpcr
    cbnz x9, .Ltemperature_reject
    cbz x0, .Ltemperature_reject
    cbz x1, .Ltemperature_reject
    cbz x2, .Ltemperature_reject
    cbz x4, .Ltemperature_reject
    ldr d0, [x0]
    ldr d1, [x1]
    ldr d2, [x2]
    ldr d3, [x4, #24]
    RANGE d0, .LC150, .LC370
    RANGE d1, .LC280, .LC320
    RANGE d2, .LCnegative300000, .LC300000
    RANGE d3, .LCeight, .LCnine
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    str x18, [sp, #16]
    fsub d4, d0, d1
    fmul d4, d4, d2
    fmul d5, d1, d3
    fmul d5, d5, d0
    fdiv d0, d4, d5
    bl exp
    ldr x18, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
.size md2asm_photosynthesis_temperature_response,.-md2asm_photosynthesis_temperature_response

.global md2asm_photosynthesis_temperature_response_with_deactivation
.type md2asm_photosynthesis_temperature_response_with_deactivation,%function
md2asm_photosynthesis_temperature_response_with_deactivation:
    mrs x9, fpcr
    cbnz x9, .Ltemperature_reject
    cbz x0, .Ltemperature_reject
    cbz x1, .Ltemperature_reject
    cbz x2, .Ltemperature_reject
    cbz x3, .Ltemperature_reject
    cbz x4, .Ltemperature_reject
    cbz x6, .Ltemperature_reject
    ldr d0, [x0]
    ldr d1, [x1]
    ldr d2, [x2]
    ldr d3, [x3]
    ldr d4, [x4]
    ldr d5, [x6, #24]
    RANGE d0, .LC150, .LC370
    RANGE d1, .LC280, .LC320
    RANGE d2, .LCzero, .LC300000
    RANGE d3, .LCzero, .LC600000
    RANGE d4, .LCzero, .LC2000
    RANGE d5, .LCeight, .LCnine
    stp x29, x30, [sp, #-112]!
    mov x29, sp
    str x18, [sp, #16]
    stp d0, d1, [sp, #32]
    stp d2, d3, [sp, #48]
    stp d4, d5, [sp, #64]
    fsub d6, d0, d1
    fmul d6, d6, d2
    fmul d7, d1, d5
    fmul d7, d7, d0
    fdiv d0, d6, d7
    bl exp
    str d0, [sp, #80]
    ldr d1, [sp, #40]
    ldr d3, [sp, #56]
    ldp d4, d5, [sp, #64]
    fmul d0, d1, d4
    fsub d0, d0, d3
    fmul d1, d1, d5
    fdiv d0, d0, d1
    bl exp
    fmov d1, #1.0
    fadd d0, d1, d0
    ldr d1, [sp, #80]
    fmul d0, d1, d0
    str d0, [sp, #88]
    ldr d1, [sp, #32]
    ldr d3, [sp, #56]
    ldp d4, d5, [sp, #64]
    fmul d0, d1, d4
    fsub d0, d0, d3
    fmul d1, d5, d1
    fdiv d0, d0, d1
    bl exp
    fmov d1, #1.0
    fadd d0, d1, d0
    ldr d1, [sp, #88]
    fdiv d0, d1, d0
    ldr x18, [sp, #16]
    ldp x29, x30, [sp], #112
    ret
.size md2asm_photosynthesis_temperature_response_with_deactivation,.-md2asm_photosynthesis_temperature_response_with_deactivation
.Ltemperature_reject:
    b abort
.section .rodata
.p2align 3
.LCzero: .double 0.0
.LCeight: .double 8.0
.LCnine: .double 9.0
.LC150: .double 150.0
.LC370: .double 370.0
.LC280: .double 280.0
.LC320: .double 320.0
.LC1000: .double 1000.0
.LCnegative300000: .double -300000.0
.LC600000: .double 600000.0
.LC2000: .double 2000.0
.LC300000: .double 300000.0
.section .note.GNU-stack,"",%progbits
