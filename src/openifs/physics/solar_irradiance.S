// Source physics is formulations/openifs/physics/solar_irradiance.md.
// The numerical contract is skills/md2asm/references/openifs/physics/solar_irradiance.md.
// Three-address GNU Fortran ABI is SELF, year and output irradiance.
// SELF holds a class data pointer to the measured 136-byte table object.
// The supported date lies strictly between the first and final table dates.
#ifndef SOLAR_IRRADIANCE_SYMBOL
#define SOLAR_IRRADIANCE_SYMBOL __yomsolarirradiance_MOD_get_solar_irradiance
#endif
.text
.p2align 4
.global SOLAR_IRRADIANCE_SYMBOL
.type SOLAR_IRRADIANCE_SYMBOL,%function
SOLAR_IRRADIANCE_SYMBOL:
    ldr x9,[x0]
    ldr w3,[x9,#128]
    cmp w3,#2
    b.lt .Lsolar_reject
    ldr d0,[x1]
    ldr x10,[x9]
    ldr x11,[x9,#8]
    ldr x12,[x9,#40]
    add x11,x11,x12
    add x10,x10,x11,lsl #3
    lsl x12,x12,#3
    ldr x13,[x9,#64]
    ldr x14,[x9,#72]
    ldr x15,[x9,#104]
    add x14,x14,x15
    add x13,x13,x14,lsl #3
    lsl x15,x15,#3
    ldr d1,[x10]
    fcmp d0,d1
    b.vs .Lsolar_reject
    b.le .Lsolar_reject
    sub w4,w3,#1
    smaddl x16,w4,w12,x10
    ldr d2,[x16]
    fcmp d0,d2
    b.vs .Lsolar_reject
    b.ge .Lsolar_reject
    mov w4,#1
.Lsolar_scan:
    ldr d1,[x10]
    ldr d2,[x10,x12]
    fcmp d0,d1
    b.lt .Lsolar_next
    fcmp d0,d2
    b.lt .Lsolar_interpolate
.Lsolar_next:
    add w4,w4,#1
    cmp w4,w3
    b.ge .Lsolar_reject
    add x10,x10,x12
    add x13,x13,x15
    b .Lsolar_scan
.Lsolar_interpolate:
    fsub d3,d0,d1
    fsub d2,d2,d1
    fdiv d3,d3,d2
    ldr d4,[x13]
    ldr d5,[x13,x15]
    fsub d5,d5,d4
    fmul d5,d3,d5
    fadd d5,d4,d5
    str d5,[x2]
    ret
.Lsolar_reject:
    brk #0x531
.size SOLAR_IRRADIANCE_SYMBOL,.-SOLAR_IRRADIANCE_SYMBOL
.section .note.GNU-stack,"",%progbits
