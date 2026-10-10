/* Complete independent-column longwave surface sensitivities, physics P01/P02.
 * Physics is formulations/openifs/physics/longwave_surface_sensitivity.md.
 * Contract is skills/md2asm/references/openifs/physics/lw_derivatives_ica.md.
 * x0..x2 address INTEGER4 ng, nlev, icol; x3 transmission, x4 surface flux.
 * Calculate x5 is a rank-two output descriptor. Modify x5 is weight and
 * x6 is that descriptor. Byte 0 is the first cell, strides are at 40 and 64.
 * Disjoint aligned FP64 buffers, ng <= 4096, nlev >= 0 and a valid column.
 * Private spectral values occupy at most 32 KiB on the aligned stack.
 * All reductions retain their scalar order and each operation rounds.
 * Caller-saved registers only. Profiling stays in the paired local wrapper. */
#ifndef CALC_SYMBOL
#define CALC_SYMBOL __radiation_lw_derivatives_MOD_calc_lw_derivatives_ica
#endif
#ifndef MODIFY_SYMBOL
#define MODIFY_SYMBOL __radiation_lw_derivatives_MOD_modify_lw_derivatives_ica
#endif
.text
.p2align 2
.global CALC_SYMBOL
.type CALC_SYMBOL,%function
CALC_SYMBOL:
    mov x6,x5
    mov w7,#0
    b .Llw_sensitivity_common
.size CALC_SYMBOL,.-CALC_SYMBOL
.p2align 2
.global MODIFY_SYMBOL
.type MODIFY_SYMBOL,%function
MODIFY_SYMBOL:
    mov w7,#1
    b .Llw_sensitivity_common
.size MODIFY_SYMBOL,.-MODIFY_SYMBOL
.Llw_sensitivity_common:
    ldrsw x8,[x0]
    cmp x8,#0
    csel x8,x8,xzr,gt
    ldrsw x9,[x1]
    ldrsw x10,[x2]
    sub x10,x10,#1
    ldr x11,[x6,#40]
    mov x16,#1
    cmp x11,#0
    csel x11,x11,x16,ne
    ldr x12,[x6,#64]
    lsl x11,x11,#3
    lsl x12,x12,#3
    ldr x6,[x6]
    mul x10,x10,x11
    add x6,x6,x10
    mul x11,x9,x12
    add x11,x6,x11
    mov x0,sp
    lsl x14,x8,#3
    add x16,x14,#15
    and x16,x16,#0xfffffffffffffff0
    sub sp,sp,x16
    mov x13,sp
    fmov d4,xzr
    mov x15,#0
    cbz x8,.Llw_sensitivity_boundary
.Llw_sensitivity_total:
    ldr d0,[x4,x15]
    fadd d4,d4,d0
    add x15,x15,#8
    cmp x15,x14
    b.ne .Llw_sensitivity_total
    mov x15,#0
.Llw_sensitivity_normalise:
    ldr d0,[x4,x15]
    fdiv d0,d0,d4
    str d0,[x13,x15]
    add x15,x15,#8
    cmp x15,x14
    b.ne .Llw_sensitivity_normalise
.Llw_sensitivity_boundary:
    fmov d0,#1.0
    str d0,[x11]
    cbz x9,.Llw_sensitivity_done
    cbz w7,.Llw_sensitivity_layers_ready
    ldr d7,[x5]
    fsub d6,d0,d7
.Llw_sensitivity_layers_ready:
    sub x10,x9,#1
    mul x10,x10,x14
    add x10,x3,x10
.Llw_sensitivity_layer:
    fmov d2,xzr
    mov x15,#0
    cbz x8,.Llw_sensitivity_write
.Llw_sensitivity_point:
    ldr d0,[x13,x15]
    ldr d1,[x10,x15]
    fmul d0,d0,d1
    str d0,[x13,x15]
    fadd d2,d2,d0
    add x15,x15,#8
    cmp x15,x14
    b.ne .Llw_sensitivity_point
.Llw_sensitivity_write:
    sub x11,x11,x12
    cbz w7,.Llw_sensitivity_store
    ldr d0,[x11]
    fmul d0,d6,d0
    fmul d2,d7,d2
    fadd d2,d0,d2
.Llw_sensitivity_store:
    str d2,[x11]
    sub x10,x10,x14
    subs x9,x9,#1
    b.ne .Llw_sensitivity_layer
.Llw_sensitivity_done:
    mov sp,x0
    ret
.section .note.GNU-stack,"",%progbits
