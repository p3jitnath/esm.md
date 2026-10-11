/* Complete monthly gas parent from formulation revision 1.0, MG-1 and MG-2.
 * Physics is formulations/openifs/physics/monthly_gas_climatology.md.
 * ABI and ordered calculations are in skills/md2asm/references/openifs/physics/upd_ghgclim.md.
 * Six addresses supply radiation objects, date, minutes and two unused integers.
 * The complete child writes only the selected gas owners, using signed array strides.
 * Every FP64 operation rounds separately, and the aligned 192-byte frame preserves x19 through x30. */
#ifndef MONTHLY_GAS_SYMBOL
#define MONTHLY_GAS_SYMBOL md2asm_upd_ghgclim
#endif
#ifndef MONTHLY_GAS_CHILD
#define MONTHLY_GAS_CHILD md2asm_climatology_layer
#endif
.text
.p2align 4
/* Visit one prescribed species in the exact original order. */
.macro gas single, threshold, vmr, amount, mean, fraction
    cmp w23,#\single
    b.eq .Lmonthly_gas_use\@
    cmp w23,#\threshold
    b.lt .Lmonthly_gas_skip\@
.Lmonthly_gas_use\@:
    ldr d0,[x20,#\fraction]
    ldr d1,[x21,#\mean]
    fdiv d0,d0,d1
    str d0,[sp,#112]
    add x0,sp,#96
    add x1,sp,#100
    add x2,sp,#104
    add x3,x22,#64
    add x4,sp,#112
    add x5,x21,#\vmr
    add x6,x22,#\amount
    bl MONTHLY_GAS_CHILD
.Lmonthly_gas_skip\@:
.endm
/* Fixed molar-mass species use a separately rounded mass ratio. */
.macro fixed_gas single, threshold, vmr, amount, mass, ozone
    cmp w23,#\single
    b.eq .Lmonthly_fixed_use\@
.if \ozone
    cmp w23,#17
    b.eq .Lmonthly_fixed_use\@
.endif
    cmp w23,#\threshold
    b.lt .Lmonthly_fixed_skip\@
.Lmonthly_fixed_use\@:
    adrp x9,:got:\mass
    ldr x9,[x9,:got_lo12:\mass]
    ldr d0,[x9]
    adrp x9,:got:__yomcst_MOD_rmd
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rmd]
    ldr d1,[x9]
    fdiv d0,d0,d1
    str d0,[sp,#112]
    add x0,sp,#96
    add x1,sp,#100
    add x2,sp,#104
    add x3,x22,#64
    add x4,sp,#112
    add x5,x21,#\vmr
    add x6,x22,#\amount
    bl MONTHLY_GAS_CHILD
.Lmonthly_fixed_skip\@:
.endm
.global MONTHLY_GAS_SYMBOL
.type MONTHLY_GAS_SYMBOL,%function
MONTHLY_GAS_SYMBOL:
    sub sp,sp,#192
    stp x19,x20,[sp,#0]
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x25,x26,[sp,#48]
    stp x27,x28,[sp,#64]
    stp x29,x30,[sp,#80]
    mov x19,x0
    mov x20,x1
    ldr w9,[x2]
    ldr w10,[x3]
    mov w11,#100
    udiv w12,w9,w11
    msub w13,w12,w11,w9
    sub w13,w13,#1
    udiv w14,w12,w11
    msub w12,w14,w11,w12
    scvtf d0,w13
    scvtf d1,w10
    adr x9,.Lmonthly_constants
    ldr d2,[x9,#0]
    cmp w12,#1
    b.eq .Lmonthly_january
    cmp w12,#2
    b.eq .Lmonthly_february
    sub w12,w12,#2
    adr x10,.Lmonthly_days
    ldr d3,[x10,w12,uxtw #3]
    fadd d0,d3,d0
    fmul d0,d0,d2
    fadd d0,d0,d1
    b .Lmonthly_modulo
.Lmonthly_january:
    fmul d0,d0,d2
    fadd d0,d0,d1
    b .Lmonthly_modulo
.Lmonthly_february:
    cmp w13,#28
    b.ne .Lmonthly_feb_day
    mov w13,#27
    scvtf d0,w13
.Lmonthly_feb_day:
    ldr d2,[x9,#8]
    fmul d0,d0,d2
    ldr d2,[x9,#16]
    fadd d0,d2,d0
    fadd d0,d0,d1
/* The integer divisor product is exact in this declared minute domain. */
.Lmonthly_modulo:
    ldr d2,[x9,#24]
    fdiv d3,d0,d2
    fcvtzs x10,d3
    scvtf d3,x10
    fmul d3,d3,d2
    fsub d0,d0,d3
    fcmp d0,#0.0
    b.ge .Lmonthly_choose
    fadd d0,d0,d2
.Lmonthly_choose:
    adr x10,.Lmonthly_midpoints
    ldr d1,[x10]
    fcmp d0,d1
    b.le .Lmonthly_early
    ldr d1,[x10,#88]
    fcmp d0,d1
    b.gt .Lmonthly_late
    mov w11,#0
.Lmonthly_search:
    ldr d1,[x10,w11,uxtw #3]
    add w12,w11,#1
    ldr d2,[x10,w12,uxtw #3]
    fcmp d0,d1
    b.le .Lmonthly_search_next
    fcmp d0,d2
    b.gt .Lmonthly_search_next
    fsub d3,d0,d2
    fsub d4,d1,d2
    fdiv d3,d3,d4
    add w11,w11,#1
    add w12,w12,#1
    b .Lmonthly_weights
.Lmonthly_search_next:
    add w11,w11,#1
    cmp w11,#11
    b.lt .Lmonthly_search
    bl abort
    brk #0
.Lmonthly_early:
    fsub d3,d1,d0
    b .Lmonthly_wrap
.Lmonthly_late:
    ldr d1,[x9,#32]
    fsub d3,d1,d0
.Lmonthly_wrap:
    ldr d1,[x9,#16]
    fdiv d3,d3,d1
    mov w11,#12
    mov w12,#1
.Lmonthly_weights:
    str w11,[sp,#96]
    str w12,[sp,#100]
    str d3,[sp,#104]
    adrp x9,:got:__yomclim_MOD_yghgclim
    ldr x9,[x9,:got_lo12:__yomclim_MOD_yghgclim]
    ldr x21,[x9]
    adrp x9,:got:__yoeradghg_MOD_yradghg
    ldr x9,[x9,:got_lo12:__yoeradghg_MOD_yradghg]
    ldr x22,[x9]
    ldr w23,[x19,#156]
    gas 1,10,128,216,1136,16
    gas 2,11,240,128,1144,24
    gas 3,12,352,304,1152,32
    fixed_gas 4,20,464,392,__yomcst_MOD_rmno2,0
    gas 5,15,576,480,1168,64
    gas 6,16,688,568,1176,72
    fixed_gas 7,21,800,832,__yomcst_MOD_rmo3,1
    gas 8,18,912,744,1184,80
    gas 9,19,1024,656,1192,56
    ldp x19,x20,[sp,#0]
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x25,x26,[sp,#48]
    ldp x27,x28,[sp,#64]
    ldp x29,x30,[sp,#80]
    add sp,sp,#192
    ret
.size MONTHLY_GAS_SYMBOL,.-MONTHLY_GAS_SYMBOL
.section .rodata
.p2align 3
.Lmonthly_constants:
    .double 1440.0,1452.8571,44640.0,525960.0,548280.0
.Lmonthly_days:
    .double 31.0,59.25,90.25,120.25,151.25,181.25,212.25,243.25,273.25,304.25,334.25,365.25
.Lmonthly_midpoints:
    .double 22320.0,64980.0,107640.0,151560.0,195480.0,239400.0,283320.0,327960.0,371880.0,415800.0,459720.0,503640.0
.section .note.GNU-stack,"",%progbits
