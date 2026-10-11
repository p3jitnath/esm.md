/* Complete soil-water recovery from formulation revision 1.0, WI-1 and WI-2.
 * Physics is formulations/openifs/surface/soil_water_increment.md.
 * Interface and ordered updates are in skills/md2asm/references/openifs/surface/soil_water_increment.md.
 * Thirteen addresses include signed-stride array descriptors and four complete returned owners.
 * All FP64 operations round separately, and a 128-byte aligned frame preserves x19 through x30 and d8 through d9. */
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL __srfwinc_mod_MOD_srfwinc
#endif
.text
.p2align 4
.global md2asm_soil_water_increment
.global ORIGINAL_SYMBOL
.type md2asm_soil_water_increment,%function
.type ORIGINAL_SYMBOL,%function
/* Address a rank-two FP64 element using zero-based dummy indices. */
.macro element2 descriptor
    ldr x9,[\descriptor]
    ldr x10,[\descriptor,#40]
    ldr x11,[\descriptor,#64]
    mul x10,x10,x28
    madd x10,x11,x27,x10
    add x9,x9,x10,lsl #3
.endm
/* Address one diagnostic field with its own signed third stride. */
.macro element3 field
    element2 x26
    ldr x12,[x26,#88]
    mov x13,#\field
    mul x12,x12,x13
    add x9,x9,x12,lsl #3
.endm
md2asm_soil_water_increment:
ORIGINAL_SYMBOL:
    sub sp,sp,#128
    stp x19,x20,[sp,#0]
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x25,x26,[sp,#48]
    stp x27,x28,[sp,#64]
    stp x29,x30,[sp,#80]
    stp d8,d9,[sp,#96]
    ldr w9,[x0]
    sub w9,w9,#1
    str w9,[sp,#112]
    ldr w10,[x1]
    str w10,[sp,#116]
    ldrsw x29,[x2]
    mov x19,x4
    mov x20,x5
    mov x21,x6
    mov x22,x7
    ldp x23,x24,[sp,#136]
    ldp x25,x26,[sp,#152]
    ldr x9,[sp,#128]
    ldr d1,[x9,#144]
    fmov d0,#1.0
    fdiv d8,d0,d1
    fsub d8,d8,d0
    adrp x9,:got:__yos_thf_MOD_rhoh2o
    ldr x9,[x9,:got_lo12:__yos_thf_MOD_rhoh2o]
    ldr d0,[x9]
    ldr d1,[x3]
    fdiv d9,d0,d1
    ldrsw x28,[sp,#112]
    ldrsw x10,[sp,#116]
    cmp x28,x10
    b.ge .Lsoil_return
    mov x27,#0
.Lsoil_layer:
    ldrsw x28,[sp,#112]
.Lsoil_cell:
    ldr x9,[x25]
    ldr x10,[x25,#40]
    mul x10,x10,x28
    ldr w9,[x9,x10,lsl #2]
    cbz w9,.Lsoil_sea
    element2 x19
    ldr d0,[x9]
    fmul d0,d8,d0
    element2 x20
    ldr d1,[x9]
    fsub d2,d1,d0
    element2 x23
    str d2,[x9]
    add x10,x27,#1
    cmp x10,x29
    b.ge .Lsoil_next_cell
    element2 x20
    ldr d1,[x9]
    ldr x10,[x20,#64]
    add x9,x9,x10,lsl #3
    ldr d2,[x9]
    fsub d2,d1,d2
    element2 x22
    ldr d0,[x9]
    fmul d0,d9,d0
    fmul d0,d0,d2
    element2 x21
    ldr d1,[x9]
    fadd d0,d1,d0
    str d0,[x9]
    b .Lsoil_next_cell
.Lsoil_sea:
    element2 x19
    ldr d0,[x9]
    element2 x23
    str d0,[x9]
    element2 x21
    str xzr,[x9]
.Lsoil_next_cell:
    add x28,x28,#1
    ldrsw x10,[sp,#116]
    cmp x28,x10
    b.lt .Lsoil_cell
    add x27,x27,#1
    cmp x27,x29
    b.lt .Lsoil_layer
    mov x27,#0
    ldrsw x28,[sp,#112]
.Lsoil_top_flux:
    element2 x21
    ldr d0,[x9]
    ldr x9,[x24]
    ldr x10,[x24,#40]
    mul x10,x10,x28
    str d0,[x9,x10,lsl #3]
    add x28,x28,#1
    ldrsw x10,[sp,#116]
    cmp x28,x10
    b.lt .Lsoil_top_flux
    ldp x9,x10,[x26,#48]
    cmp x10,x9
    b.lt .Lsoil_return
    ldp x9,x10,[x26,#72]
    cmp x10,x9
    b.lt .Lsoil_return
    ldp x9,x10,[x26,#96]
    cmp x10,x9
    b.lt .Lsoil_return
    mov x27,#0
.Lsoil_diagnostic_layer:
    ldrsw x28,[sp,#112]
.Lsoil_diagnostic_cell:
    element2 x21
    ldr d0,[x9]
    element3 7
    str d0,[x9]
    add x28,x28,#1
    ldrsw x10,[sp,#116]
    cmp x28,x10
    b.lt .Lsoil_diagnostic_cell
    add x27,x27,#1
    cmp x27,x29
    b.lt .Lsoil_diagnostic_layer
    sub x27,x29,#1
    ldrsw x28,[sp,#112]
.Lsoil_bottom_loss:
    element2 x21
    ldr d0,[x9]
    element3 5
    ldr d1,[x9]
    fsub d0,d1,d0
    str d0,[x9]
    add x28,x28,#1
    ldrsw x10,[sp,#116]
    cmp x28,x10
    b.lt .Lsoil_bottom_loss
.Lsoil_return:
    ldp x19,x20,[sp,#0]
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x25,x26,[sp,#48]
    ldp x27,x28,[sp,#64]
    ldp x29,x30,[sp,#80]
    ldp d8,d9,[sp,#96]
    add sp,sp,#128
    ret
.size md2asm_soil_water_increment,.-md2asm_soil_water_increment
.size ORIGINAL_SYMBOL,.-ORIGINAL_SYMBOL
.section .note.GNU-stack,"",%progbits
