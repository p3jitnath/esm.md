/* Complete deterministic convective wind transport.
 * Physics formulations/openifs/physics/convective_wind_transport.md.
 * Contract skills/md2asm/references/openifs/physics/cududv.md.
 * Twenty-seven argument addresses. LSPP must be false.
 * Bind the complete accepted bidiagonal child inside this closure. */
#ifndef CUDUDV_SYMBOL
#define CUDUDV_SYMBOL cududv_
#endif
.text
.p2align 4
.macro LOAD_FP reg,slot,index=x26
    ldr x9,[x29,#\slot]
    ldr \reg,[x9,\index,lsl #3]
.endm
.macro STORE_FP reg,slot,index=x26
    ldr x9,[x29,#\slot]
    str \reg,[x9,\index,lsl #3]
.endm
.macro MASK_SKIP label
    ldr x9,[x29,#192]
    sub x10,x25,#1
    ldr w9,[x9,x10,lsl #2]
    cbz w9,\label
.endm
.macro FLUX mass,plume,environment,destination
    LOAD_FP d1,\environment,x11
    fmul d1,d16,d1
    LOAD_FP d2,\plume
    fsub d2,d2,d1
    LOAD_FP d0,\mass
    fmul d0,d0,d2
    STORE_FP d0,\destination
.endm
.macro CONTINUE_FLUX slot
    LOAD_FP d1,\slot,x11
    fmul d1,d1,d0
    STORE_FP d1,\slot
.endm
.macro DIVERGENCE up,down,destination
    LOAD_FP d1,\up,x11
    LOAD_FP d2,\up
    LOAD_FP d3,\down,x11
    LOAD_FP d4,\down
    fsub d1,d1,d2
    fadd d1,d1,d3
    fsub d1,d1,d4
    fmul d1,d0,d1
    STORE_FP d1,\destination
.endm
.macro BOTTOM_DIVERGENCE up,down,destination
    LOAD_FP d1,\up
    LOAD_FP d2,\down
    fadd d1,d1,d2
    fmul d1,d0,d1
    STORE_FP d1,\destination
.endm
.macro NEXT_CELL col_label,level_label,done_label
    add x25,x25,#1
    add x26,x26,#1
    cmp x25,x20
    b.le \col_label
    add x24,x24,#1
    cmp x24,x22
    b.ge \done_label
    b \level_label
.endm
.macro BEGIN_ROW
    mov x25,x19
    mul x26,x24,x21
    sub x9,x19,#1
    add x26,x26,x9
.endm
.global CUDUDV_SYMBOL
.type CUDUDV_SYMBOL,%function
CUDUDV_SYMBOL:
    mov x9,sp
    stp x29,x30,[sp,#-496]!
    mov x29,sp
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    stp x0,x1,[sp,#112]
    stp x2,x3,[sp,#128]
    stp x4,x5,[sp,#144]
    stp x6,x7,[sp,#160]
    add x10,x29,#176
    mov x11,#19
.Lmomentum_arguments:
    ldr x12,[x9],#8
    str x12,[x10],#8
    subs x11,x11,#1
    b.ne .Lmomentum_arguments
    ldr w9,[x1]
    cbnz w9,.Lmomentum_unsupported
    ldrsw x19,[x2]
    ldrsw x20,[x3]
    ldrsw x21,[x4]
    ldrsw x22,[x5]
    ldrsw x23,[x6]
    cmp x19,x20
    b.gt .Lmomentum_return
    cmp x23,x22
    b.gt .Lmomentum_return
    ldr d0,[x0,#72]
    str d0,[x29,#416]
    fmov d1,#1.0
    fsub d16,d1,d0
    str d16,[x29,#400]
    ldr d0,[x0,#96]
    str d0,[x29,#424]
    ldr d0,[x0,#104]
    str d0,[x29,#432]
    ldr d0,[x0,#112]
    str d0,[x29,#440]
    ldr x9,[x29,#200]
    ldr d18,[x9]
    str d18,[x29,#456]
    fdiv d0,d1,d18
    str d0,[x29,#408]
    adrp x9,:got:__yomcst_MOD_rg
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rg]
    ldr d19,[x9]
    str d19,[x29,#448]
    mul x27,x21,x22
    mov x9,#60
    mul x9,x27,x9
    add x9,x9,#31
    and x9,x9,#-16
    sub sp,sp,x9
    add x9,sp,#16
    add x10,x29,#336
    mov x11,#7
.Lmomentum_arena:
    str x9,[x10],#8
    add x9,x9,x27,lsl #3
    subs x11,x11,#1
    b.ne .Lmomentum_arena
    str x9,[x29,#392]
    mov x24,#0
.Lmomentum_dp_row:
    BEGIN_ROW
.Lmomentum_dp_cell:
    MASK_SKIP .Lmomentum_dp_next
    add x11,x26,x21
    LOAD_FP d0,208,x11
    LOAD_FP d1,208
    fsub d0,d0,d1
    fdiv d0,d19,d0
    STORE_FP d0,384
.Lmomentum_dp_next:
    NEXT_CELL .Lmomentum_dp_cell,.Lmomentum_dp_row,.Lmomentum_flux_start
.Lmomentum_flux_start:
    sub x24,x23,#1
.Lmomentum_flux_row:
    BEGIN_ROW
.Lmomentum_flux_cell:
    MASK_SKIP .Lmomentum_flux_next
    sub x11,x26,x21
    FLUX 240,272,224,336
    FLUX 240,288,232,344
    FLUX 248,280,224,352
    FLUX 248,296,232,360
.Lmomentum_flux_next:
    NEXT_CELL .Lmomentum_flux_cell,.Lmomentum_flux_row,.Lmomentum_extend_start
.Lmomentum_extend_start:
    ldr d0,[x29,#416]
    fcmp d0,#0.0
    b.ne .Lmomentum_divergence_start
    sub x24,x23,#1
.Lmomentum_extend_row:
    BEGIN_ROW
.Lmomentum_extend_cell:
    MASK_SKIP .Lmomentum_extend_next
    ldr x9,[x29,#176]
    sub x10,x25,#1
    ldrsw x11,[x9,x10,lsl #2]
    add x12,x24,#1
    cmp x12,x11
    b.le .Lmomentum_extend_next
    sub x11,x11,#1
    mul x11,x11,x21
    add x11,x11,x10
    mul x12,x22,x21
    add x12,x12,x10
    LOAD_FP d0,208,x12
    LOAD_FP d1,208
    LOAD_FP d2,208,x11
    fsub d1,d0,d1
    fsub d2,d0,d2
    fdiv d0,d1,d2
    ldr x9,[x29,#168]
    ldr w9,[x9,x10,lsl #2]
    cmp w9,#3
    b.ne .Lmomentum_extend_fraction
    fmul d0,d0,d0
.Lmomentum_extend_fraction:
    CONTINUE_FLUX 336
    CONTINUE_FLUX 344
    CONTINUE_FLUX 352
    CONTINUE_FLUX 360
.Lmomentum_extend_next:
    NEXT_CELL .Lmomentum_extend_cell,.Lmomentum_extend_row,.Lmomentum_divergence_start
.Lmomentum_divergence_start:
    sub x24,x23,#1
.Lmomentum_divergence_row:
    BEGIN_ROW
.Lmomentum_divergence_cell:
    MASK_SKIP .Lmomentum_divergence_next
    LOAD_FP d0,384
    add x11,x24,#1
    cmp x11,x22
    b.ge .Lmomentum_bottom
    add x11,x26,x21
    DIVERGENCE 336,352,368
    DIVERGENCE 344,360,376
    b .Lmomentum_divergence_next
.Lmomentum_bottom:
    fneg d0,d0
    BOTTOM_DIVERGENCE 336,352,368
    BOTTOM_DIVERGENCE 344,360,376
.Lmomentum_divergence_next:
    NEXT_CELL .Lmomentum_divergence_cell,.Lmomentum_divergence_row,.Lmomentum_select_solver
.Lmomentum_select_solver:
    ldr d0,[x29,#416]
    fcmp d0,#0.0
    b.ne .Lmomentum_matrix_initialize
    sub x24,x23,#1
.Lmomentum_explicit_row:
    BEGIN_ROW
.Lmomentum_explicit_cell:
    MASK_SKIP .Lmomentum_explicit_next
    LOAD_FP d0,312
    LOAD_FP d1,368
    fadd d0,d0,d1
    STORE_FP d0,312
    LOAD_FP d0,320
    LOAD_FP d1,376
    fadd d0,d0,d1
    STORE_FP d0,320
.Lmomentum_explicit_next:
    NEXT_CELL .Lmomentum_explicit_cell,.Lmomentum_explicit_row,.Lmomentum_return
.Lmomentum_matrix_initialize:
    mov x26,#0
    fmov d0,#1.0
.Lmomentum_initialize_cell:
    ldr x9,[x29,#336]
    str xzr,[x9,x26,lsl #3]
    STORE_FP d0,360
    ldr x9,[x29,#392]
    str wzr,[x9,x26,lsl #2]
    add x26,x26,#1
    cmp x26,x27
    b.lt .Lmomentum_initialize_cell
    sub x24,x23,#1
.Lmomentum_matrix_row:
    BEGIN_ROW
.Lmomentum_matrix_cell:
    MASK_SKIP .Lmomentum_matrix_next
    ldr x9,[x29,#184]
    sub x10,x25,#1
    ldrsw x11,[x9,x10,lsl #2]
    add x12,x24,#2
    cmp x12,x11
    b.lt .Lmomentum_matrix_next
    ldr x9,[x29,#392]
    mov w11,#1
    str w11,[x9,x26,lsl #2]
    ldr d0,[x29,#416]
    LOAD_FP d1,384
    fmul d0,d0,d1
    ldr d2,[x29,#456]
    fmul d0,d0,d2
    LOAD_FP d1,240
    LOAD_FP d2,248
    fadd d1,d1,d2
    fneg d2,d0
    fmul d1,d2,d1
    STORE_FP d1,336
    add x11,x24,#1
    cmp x11,x22
    b.ge .Lmomentum_advection
    add x11,x26,x21
    LOAD_FP d1,240,x11
    LOAD_FP d2,248,x11
    fadd d1,d1,d2
    fmul d1,d0,d1
    fmov d2,#1.0
    fadd d1,d2,d1
    STORE_FP d1,360
.Lmomentum_advection:
    LOAD_FP d0,264
    ldr d1,[x29,#440]
    fmul d0,d1,d0
    LOAD_FP d1,256
    fadd d0,d1,d0
    ldr d1,[x29,#448]
    fmul d0,d1,d0
    sub x11,x26,x21
    LOAD_FP d1,216
    LOAD_FP d2,216,x11
    fsub d1,d1,d2
    fdiv d0,d0,d1
    ldr d1,[x29,#456]
    fmul d0,d0,d1
    ldr x9,[x29,#168]
    ldr w9,[x9,x10,lsl #2]
    fmov d1,xzr
    cmp w9,#1
    b.ne .Lmomentum_advection_weight
    ldr d1,[x29,#432]
.Lmomentum_advection_weight:
    fmul d16,d0,d1
    LOAD_FP d0,224,x11
    LOAD_FP d1,224
    fsub d0,d0,d1
    fmul d6,d16,d0
    LOAD_FP d0,232,x11
    LOAD_FP d1,232
    fsub d0,d0,d1
    fmul d7,d16,d0
    LOAD_FP d0,368
    LOAD_FP d1,312
    ldr d2,[x29,#424]
    fmul d1,d1,d2
    fadd d0,d0,d1
    ldr d1,[x29,#456]
    fmul d0,d0,d1
    LOAD_FP d1,224
    fadd d0,d0,d1
    fsub d0,d0,d6
    STORE_FP d0,368
    LOAD_FP d0,376
    LOAD_FP d1,320
    ldr d2,[x29,#424]
    fmul d1,d1,d2
    fadd d0,d0,d1
    ldr d1,[x29,#456]
    fmul d0,d0,d1
    LOAD_FP d1,232
    fadd d0,d0,d1
    fsub d0,d0,d7
    STORE_FP d0,376
.Lmomentum_matrix_next:
    NEXT_CELL .Lmomentum_matrix_cell,.Lmomentum_matrix_row,.Lmomentum_solve_u
.Lmomentum_solve_u:
    ldp x0,x1,[x29,#128]
    ldp x2,x3,[x29,#144]
    ldr x4,[x29,#184]
    ldr x5,[x29,#392]
    ldr x6,[x29,#336]
    ldr x7,[x29,#360]
    ldr x9,[x29,#368]
    ldr x10,[x29,#344]
    stp x9,x10,[sp]
    bl md2asm_cududv_bidiag
    ldp x0,x1,[x29,#128]
    ldp x2,x3,[x29,#144]
    ldr x4,[x29,#184]
    ldr x5,[x29,#392]
    ldr x6,[x29,#336]
    ldr x7,[x29,#360]
    ldr x9,[x29,#376]
    ldr x10,[x29,#352]
    stp x9,x10,[sp]
    bl md2asm_cududv_bidiag
    ldr d0,[x29,#424]
    fmov d1,#1.0
    fsub d16,d1,d0
    ldr d17,[x29,#408]
    sub x24,x23,#1
.Lmomentum_implicit_row:
    BEGIN_ROW
.Lmomentum_implicit_cell:
    ldr x9,[x29,#392]
    ldr w9,[x9,x26,lsl #2]
    cbz w9,.Lmomentum_implicit_next
    LOAD_FP d0,312
    fmul d0,d0,d16
    LOAD_FP d1,344
    LOAD_FP d2,224
    fsub d1,d1,d2
    fmul d1,d1,d17
    fadd d0,d0,d1
    STORE_FP d0,312
    LOAD_FP d0,320
    fmul d0,d0,d16
    LOAD_FP d1,352
    LOAD_FP d2,232
    fsub d1,d1,d2
    fmul d1,d1,d17
    fadd d0,d0,d1
    STORE_FP d0,320
.Lmomentum_implicit_next:
    NEXT_CELL .Lmomentum_implicit_cell,.Lmomentum_implicit_row,.Lmomentum_return
.Lmomentum_return:
    mov sp,x29
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp x29,x30,[sp],#496
    ret
.Lmomentum_unsupported:
    bl abort
    brk #0
.size CUDUDV_SYMBOL,.-CUDUDV_SYMBOL
.section .note.GNU-stack,"",%progbits
