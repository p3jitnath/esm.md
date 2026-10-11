/* Physics formulations/openifs/surface/evaporation_efficiency.md.
 * Contract skills/md2asm/references/openifs/surface/evaporation_efficiency.md.
 * Complete 29-address GNU tile evaporation calculation.
 * Rank-one descriptors point to their first logical element.
 * Use only caller-saved FP registers and preserve the Arm integer ABI. */
#ifndef VEVAP_SYMBOL
#define VEVAP_SYMBOL __vevap_mod_MOD_vevap
#endif
.text
.p2align 4
.macro VALUE reg,argument
    ldr x9,[x22,#(8*\argument)]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mul x11,x23,x11
    ldr \reg,[x10,x11,lsl #3]
.endm
.macro STORE reg,argument
    ldr x9,[x22,#(8*\argument)]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mul x11,x23,x11
    str \reg,[x10,x11,lsl #3]
.endm
.macro BETA destination
    fdiv d25,d23,d24
    fmul d0,d18,d25
    fadd d0,d30,d0
    fdiv \destination,d30,d0
.endm
.macro DIAGNOSTIC group,resistance
    ldr x9,[x22,#224]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    ldr x12,[x9,#64]
    ldr x13,[x9,#88]
    mul x11,x23,x11
    add x11,x11,x13,lsl #1
    .if \group
    add x11,x11,x12
    .endif
    str \resistance,[x10,x11,lsl #3]
    add x11,x11,x13
    fdiv d0,d24,d18
    str d0,[x10,x11,lsl #3]
.endm
.macro HEAT beta,argument
    fmul d0,\beta,d17
    fsub d1,d30,\beta
    fmul d1,d1,d16
    fadd d0,d0,d1
    fmul d0,d29,d0
    fadd d0,d30,d0
    fmul d1,d19,d26
    fmul d0,d1,d0
    STORE d0,\argument
.endm
.global VEVAP_SYMBOL
.type VEVAP_SYMBOL,%function
VEVAP_SYMBOL:
    stp x29,x30,[sp,#-384]!
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    mov x29,sp
    add x22,sp,#96
    stp x0,x1,[x22]
    stp x2,x3,[x22,#16]
    stp x4,x5,[x22,#32]
    stp x6,x7,[x22,#48]
    add x9,sp,#384
    add x10,x22,#64
    mov x11,#21
.Levap_arguments:
    ldr x12,[x9],#8
    str x12,[x10],#8
    subs x11,x11,#1
    b.ne .Levap_arguments
    ldrsw x19,[x0]
    sub x19,x19,#1
    ldrsw x20,[x1]
    cmp x19,x20
    b.ge .Levap_return
    ldrsw x21,[x4]
    mov x23,x19
    ldr x9,[x22,#144]
    ldr d26,[x9,#80]
    ldr d27,[x9,#32]
    ldr d28,[x9,#48]
    adrp x9,:got:__yos_thf_MOD_rvtmp2
    ldr x9,[x9,:got_lo12:__yos_thf_MOD_rvtmp2]
    ldr d29,[x9]
    fmov d30,#1.0
.Levap_column:
    VALUE d16,7
    VALUE d17,11
    VALUE d18,12
    VALUE d19,9
    fmov d20,d30
    fmov d21,d30
    cmp x21,#7
    b.ne .Levap_tile_dispatch
    fmov d0,xzr
    STORE d0,27
.Levap_tile_dispatch:
    cmp x21,#3
    b.eq .Levap_interception
    cmp x21,#4
    b.eq .Levap_resistance
    cmp x21,#6
    b.eq .Levap_resistance
    cmp x21,#7
    b.eq .Levap_resistance
    cmp x21,#8
    b.eq .Levap_resistance
    cmp x21,#10
    b.ne .Levap_store
.Levap_resistance:
    fcmp d16,d17
    b.gt .Levap_store
    VALUE d0,8
    VALUE d1,6
    fmul d2,d27,d1
    fmul d3,d28,d16
    fadd d3,d30,d3
    fmul d2,d2,d3
    fdiv d24,d0,d2
    cmp x21,#4
    b.eq .Levap_low_vegetation
    cmp x21,#6
    b.eq .Levap_high_vegetation
    cmp x21,#7
    b.eq .Levap_canopy_snow
    VALUE d23,13
    BETA d20
    fmov d21,d20
    b .Levap_store
.Levap_interception:
    fsub d0,d16,d17
    fmul d0,d18,d0
    VALUE d1,5
    fneg d1,d1
    ldr x9,[x22,#24]
    ldr d2,[x9]
    fdiv d1,d1,d2
    fcmp d0,#0.0
    b.ge .Levap_store
    fcmp d1,#0.0
    b.ge .Levap_store
    fcmp d0,d1
    b.ge .Levap_store
    fdiv d0,d1,d0
    fminnm d20,d30,d0
    fmov d21,d20
    b .Levap_store
.Levap_low_vegetation:
    VALUE d23,14
    BETA d20
    VALUE d23,15
    BETA d21
    VALUE d0,14
    DIAGNOSTIC 0,d0
    b .Levap_store
.Levap_high_vegetation:
    VALUE d23,16
    BETA d20
    fmov d21,d20
    DIAGNOSTIC 1,d23
    b .Levap_store
.Levap_canopy_snow:
    VALUE d23,17
    VALUE d0,10
    ldr x9,[x22,#152]
    fcmp d19,d0
    b.gt .Levap_stable_canopy
    ldr d0,[x9,#696]
    b .Levap_canopy_resistance
.Levap_stable_canopy:
    ldr d0,[x9,#704]
.Levap_canopy_resistance:
    adr x9,.Levap_capacity
    ldr d1,[x9]
    fdiv d1,d1,d0
    fdiv d25,d23,d24
    fdiv d2,d1,d24
    fmul d3,d25,d18
    fadd d3,d30,d3
    fdiv d4,d25,d2
    fadd d3,d3,d4
    fdiv d20,d30,d3
    fmov d21,d20
    fcmp d23,d30
    b.le .Levap_store
    fmul d3,d2,d18
    fadd d3,d30,d3
    fdiv d4,d2,d25
    fadd d3,d3,d4
    fdiv d0,d30,d3
    STORE d0,27
.Levap_store:
    STORE d20,22
    STORE d20,23
    STORE d21,25
    STORE d21,26
    HEAT d20,21
    HEAT d21,24
    add x23,x23,#1
    cmp x23,x20
    b.lt .Levap_column
.Levap_return:
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp x29,x30,[sp],#384
    ret
.size VEVAP_SYMBOL,.-VEVAP_SYMBOL
.section .rodata
.p2align 3
.Levap_capacity:
    .double 1200.0
.section .note.GNU-stack,"",%progbits
