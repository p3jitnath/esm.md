/* Thermal spectrum from the unchanged RRTMG band table.
 * Physics is formulations/openifs/physics/tabulated_planck_emission.md.
 * Contract is skills/md2asm/references/openifs/physics/planck_functions.md.
 * Each entry implements every temperature, band and spectral output cell.
 * Tables are pre-existing read-only model inputs, not a numerical helper.
 * Saved x19..x30 and a 128-byte band buffer use one aligned 352-byte frame.
 * No external calls, fused arithmetic or approximate instructions. */
#ifndef ATMOS_SYMBOL
#define ATMOS_SYMBOL __radiation_ifs_rrtm_MOD_planck_function_atmos
#endif
#ifndef SURF_SYMBOL
#define SURF_SYMBOL __radiation_ifs_rrtm_MOD_planck_function_surf
#endif
.text
.p2align 2
.macro planck_save
    stp x29,x30,[sp,#-352]!
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
.endm
.global SURF_SYMBOL
.type SURF_SYMBOL,%function
SURF_SYMBOL:
    planck_save
    mov x19,x2
    mov x21,x4
    mov x22,x5
    ldrsw x0,[x0]
    ldrsw x1,[x1]
    sub x23,x1,x0
    add x23,x23,#1
    mov x25,#1
    ldr x20,[x3]
    ldr x1,[x3,#40]
    mov x2,#1
    cmp x1,#0
    csel x1,x1,x2,ne
    lsl x1,x1,#3
    str x1,[sp,#240]
    str xzr,[sp,#248]
    sub x0,x0,#1
    mul x0,x0,x1
    add x20,x20,x0
    str xzr,[sp,#336]
    b .Lplanck_setup
.size SURF_SYMBOL,.-SURF_SYMBOL
.p2align 2
.global ATMOS_SYMBOL
.type ATMOS_SYMBOL,%function
ATMOS_SYMBOL:
    planck_save
    mov x19,x3
    mov x21,x5
    mov x22,x6
    ldrsw x25,[x0]
    ldrsw x0,[x1]
    ldrsw x1,[x2]
    sub x23,x1,x0
    add x23,x23,#1
    ldr x20,[x4,#88]
    ldr x1,[x4,#128]
    ldr x2,[x4,#152]
    mov x3,#1
    cmp x1,#0
    csel x1,x1,x3,ne
    lsl x1,x1,#3
    lsl x2,x2,#3
    str x1,[sp,#240]
    str x2,[sp,#248]
    ldr x3,[x4,#168]
    sub x3,x3,x25
    sub x3,x3,#1
    mul x3,x3,x2
    sub x0,x0,#1
    mul x0,x0,x1
    add x20,x20,x3
    add x20,x20,x0
    add x25,x25,#1
    mov x0,#1
    str x0,[sp,#336]
    b .Lplanck_setup
.size ATMOS_SYMBOL,.-ATMOS_SYMBOL
.Lplanck_setup:
    add x0,x19,#4,lsl #12
    ldrsw x24,[x0,#3616]
    ldrsw x26,[x0,#3624]
    cmp x23,#0
    b.le .Lplanck_done
    cmp x24,#0
    b.le .Lplanck_done
    ldr w0,[x19,#624]
    cmp w0,#3
    b.eq .Lplanck_reordered
    mov x0,#10608
    ldr x0,[x19,x0]
    str x0,[sp,#280]
    str xzr,[sp,#288]
    b .Lplanck_tables
.Lplanck_reordered:
    mov x0,#10864
    ldr x0,[x19,x0]
    str x0,[sp,#280]
    mov x0,#10736
    ldr x0,[x19,x0]
    str x0,[sp,#288]
.Lplanck_tables:
    adrp x19,:got:__yoerrtwn_MOD_totplnk
    ldr x19,[x19,:got_lo12:__yoerrtwn_MOD_totplnk]
    adrp x0,:got:__yoerrtwn_MOD_delwave
    ldr x0,[x0,:got_lo12:__yoerrtwn_MOD_delwave]
    str x0,[sp,#304]
    mov x27,#0
.Lplanck_column:
    mov x28,#0
.Lplanck_point:
    ldr x0,[sp,#240]
    ldr x1,[sp,#248]
    mul x0,x27,x0
    mul x1,x28,x1
    add x0,x20,x0
    add x0,x0,x1
    ldr d0,[x0]
    adrp x0,.Lplanck_constants
    add x0,x0,:lo12:.Lplanck_constants
    ldr d1,[x0,#0]
    fcmp d0,d1
    b.ge .Lplanck_hot
    ldr d2,[x0,#8]
    fcmp d0,d2
    b.lt .Lplanck_cold
    ldr d2,[x0,#16]
    fsub d2,d0,d2
    fcvtzs w1,d2
    sub w1,w1,#1
    fcvtzs w2,d0
    scvtf d2,w2
    fsub d3,d0,d2
    b .Lplanck_band_setup
.Lplanck_hot:
    mov w1,#179
    fsub d3,d0,d1
    b .Lplanck_band_setup
.Lplanck_cold:
    mov w1,#0
    fmov d3,xzr
.Lplanck_band_setup:
    ldr d4,[x0,#24]
    ldr x3,[sp,#304]
    mov x4,#0
    add x5,sp,#96
    mov x6,#181
.Lplanck_band:
    mul x7,x4,x6
    add x7,x7,x1
    add x7,x19,x7,lsl #3
    ldp d0,d1,[x7]
    fsub d1,d1,d0
    fmul d1,d3,d1
    fadd d0,d0,d1
    ldr d2,[x3,x4,lsl #3]
    fmul d2,d4,d2
    fmul d0,d2,d0
    str d0,[x5,x4,lsl #3]
    add x4,x4,#1
    cmp x4,x26
    b.ne .Lplanck_band
    ldr x3,[sp,#280]
    ldr x4,[sp,#288]
    ldr x0,[sp,#336]
    mov x6,#0
    cbz x0,.Lplanck_fraction_ready
    mov x0,#1
    cmp x28,#1
    csel x0,x28,x0,ge
    sub x6,x25,#1
    sub x6,x6,x0
.Lplanck_fraction_ready:
    mov x0,#140
    mul x6,x6,x0
    mul x6,x6,x23
    add x6,x6,x27
    add x6,x21,x6,lsl #3
    mul x7,x27,x25
    add x7,x7,x28
    mul x7,x7,x24
    add x7,x22,x7,lsl #3
    mov x8,#0
.Lplanck_spectral:
    ldrsw x9,[x3,x8,lsl #2]
    sub x9,x9,#1
    ldr d0,[x5,x9,lsl #3]
    mov x10,x8
    cbz x4,.Lplanck_spectral_index_ready
    ldrsw x10,[x4,x8,lsl #2]
    sub x10,x10,#1
.Lplanck_spectral_index_ready:
    mul x10,x10,x23
    ldr d1,[x6,x10,lsl #3]
    fmul d0,d0,d1
    str d0,[x7,x8,lsl #3]
    add x8,x8,#1
    cmp x8,x24
    b.ne .Lplanck_spectral
    add x28,x28,#1
    cmp x28,x25
    b.ne .Lplanck_point
    add x27,x27,#1
    cmp x27,x23
    b.ne .Lplanck_column
.Lplanck_done:
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp x29,x30,[sp],#352
    ret
.section .rodata
.p2align 3
.Lplanck_constants:
    .double 339.0,160.0,159.0
    .quad 0x40deadfb4c5d390c
.section .note.GNU-stack,"",%progbits
