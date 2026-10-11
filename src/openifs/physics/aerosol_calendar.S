// Physics input formulations/openifs/physics/monthly_aerosol_fields.md.
// Complete interface skills/md2asm/references/openifs/physics/updecaec.md.
// Source physics and verified interface are in the monthly aerosol contract.
// Nine Fortran address arguments. x0..x3 point to day, month, year and day increment.
// x4..x6 return the date. x7 returns twelve int32 month lengths. The ninth unit is negative.
// Forward Gregorian dates use exact int32 arithmetic. All outputs are disjoint.
// No stack, floating-point registers, x18 or callee-saved registers are changed.
#ifndef UPDCAL_SYMBOL
#define UPDCAL_SYMBOL md2asm_updcal
#endif
.text
.p2align 4
.macro FEBRUARY_LENGTH year,result,divisor,remainder
    mov \result, #28
    tst \year, #3
    b.ne 9f
    mov \divisor, #400
    udiv \remainder, \year, \divisor
    msub \remainder, \remainder, \divisor, \year
    cmp \remainder, #100
    b.eq 9f
    cmp \remainder, #200
    b.eq 9f
    cmp \remainder, #300
    b.eq 9f
    mov \result, #29
9:
.endm
.global UPDCAL_SYMBOL
.type UPDCAL_SYMBOL,%function
UPDCAL_SYMBOL:
    ldr w8, [x0]
    ldr w9, [x1]
    ldr w10, [x2]
    ldr w11, [x3]
    FEBRUARY_LENGTH w10,w14,w16,w15
    mov x12, #0
.Lcalendar_months:
    mov w13, #31
    cmp w12, #3
    b.eq .Lcalendar_thirty
    cmp w12, #5
    b.eq .Lcalendar_thirty
    cmp w12, #8
    b.eq .Lcalendar_thirty
    cmp w12, #10
    b.eq .Lcalendar_thirty
    cmp w12, #1
    csel w13, w14, w13, eq
    b .Lcalendar_store_month
.Lcalendar_thirty:
    mov w13, #30
.Lcalendar_store_month:
    str w13, [x7, x12, lsl #2]
    add x12, x12, #1
    cmp x12, #12
    b.lo .Lcalendar_months
    cbz w11, .Lcalendar_finish
.Lcalendar_day:
    add w8, w8, #1
    sub w12, w9, #1
    ldr w13, [x7, x12, lsl #2]
    cmp w8, w13
    b.le .Lcalendar_next
    mov w8, #1
    add w9, w9, #1
    cmp w9, #12
    b.le .Lcalendar_next
    mov w9, #1
    add w10, w10, #1
    FEBRUARY_LENGTH w10,w14,w16,w15
    str w14, [x7, #4]
.Lcalendar_next:
    subs w11, w11, #1
    b.ne .Lcalendar_day
.Lcalendar_finish:
    str w8, [x4]
    str w9, [x5]
    str w10, [x6]
    ret
.size UPDCAL_SYMBOL,.-UPDCAL_SYMBOL
.section .note.GNU-stack,"",%progbits
