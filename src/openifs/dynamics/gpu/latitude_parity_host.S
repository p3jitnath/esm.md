#include "../../support/gpu/preserved_weather_calls.inc.S"
.text
.p2align 4
.global md2asm_ltdir_parity_child_7358525
.type md2asm_ltdir_parity_child_7358525,%function
md2asm_ltdir_parity_child_7358525:
    sub sp,sp,#160
    stp x19,x20,[sp,#0]
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x25,x26,[sp,#48]
    stp x27,x28,[sp,#64]
    stp x29,x30,[sp,#80]
    ldrsw x19,[x0]
    lsl x19,x19,#1
    ldrsw x9,[x1]
    ldrsw x23,[x2]
    adrp x10,:got:__tpm_dim_MOD_r
    ldr x10,[x10,:got_lo12:__tpm_dim_MOD_r]
    ldr x10,[x10]
    ldrsw x22,[x10,#20]
    ldrsw x21,[x10,#28]
    adrp x11,:got:__tpm_geometry_MOD_g
    ldr x11,[x11,:got_lo12:__tpm_geometry_MOD_g]
    ldr x11,[x11]
    ldr x13,[x11,#128]
    ldr x14,[x11,#176]
    ldr x15,[x11,#168]
    sub x9,x9,x14
    mul x9,x9,x15
    ldrsw x16,[x13,x9,lsl #2]
    sub x20,x21,x16
    add x20,x20,#1
    mov x17,#1
    cmp x20,x17
    csel x20,x20,x17,ge
    cmp x20,x21
    b.gt .Lprfi_done
    cbz x19,.Lprfi_done
    adrp x24,:got:__tpm_distr_MOD_d
    ldr x24,[x24,:got_lo12:__tpm_distr_MOD_d]
    ldr x24,[x24]
    adrp x12,:got:__tpm_trans_MOD_foubuf
    ldr x12,[x12,:got_lo12:__tpm_trans_MOD_foubuf]
    ldr x25,[x12]
    ldr x13,[x12,#48]
    ldr x26,[x12,#40]
    lsl x26,x26,#3
    mul x14,x13,x26
    sub x25,x25,x14
    ldr x27,[x3]
    ldr x29,[x3,#40]
    lsl x29,x29,#3
    ldr x9,[x3,#64]
    lsl x9,x9,#3
    str x9,[sp,#96]
    ldr x28,[x4]
    ldr x30,[x4,#40]
    lsl x30,x30,#3
    ldr x9,[x4,#64]
    lsl x9,x9,#3
    str x9,[sp,#104]
.macro PRFI_ROW result,latitude
    ldr x9,[x24,#1136]
    ldr x10,[x24,#1184]
    ldr x11,[x24,#1176]
    sub x12,\latitude,x10
    mul x12,x12,x11
    ldrsw x12,[x9,x12,lsl #2]
    ldr x9,[x24,#1328]
    ldr x10,[x24,#1376]
    ldr x11,[x24,#1368]
    sub x12,x12,x10
    mul x12,x12,x11
    ldrsw x13,[x9,x12,lsl #2]
    ldr x9,[x24,#1480]
    ldr x10,[x24,#1528]
    ldr x11,[x24,#1520]
    sub x14,x23,x10
    mul x14,x14,x11
    ldr x10,[x24,#1552]
    ldr x11,[x24,#1544]
    sub x12,\latitude,x10
    madd x14,x12,x11,x14
    ldrsw x14,[x9,x14,lsl #2]
    add x13,x13,x14
    mul x13,x13,x19
    add x13,x13,#1
    madd \result,x13,x26,x25
.endm
.Lprfi_row:
    PRFI_ROW x0,x20
    add x2,x22,#1
    sub x2,x2,x20
    PRFI_ROW x1,x2
    sub x10,x20,#1
    ldr x9,[sp,#96]
    madd x3,x9,x10,x27
    ldr x9,[sp,#104]
    madd x4,x9,x10,x28
    mov x5,x19
    cmp x26,#8
    b.ne .Lprfi_scalar
    cmp x29,#8
    b.ne .Lprfi_scalar
    cmp x30,#8
    b.ne .Lprfi_scalar
.Lprfi_pair:
    cmp x5,#2
    b.lt .Lprfi_scalar
    ldr q0,[x0],#16
    ldr q1,[x1],#16
 md2asm_gpu_full_vector_pair md2asm_gpu_soil_water_cell_host,0,q2,q0,q1 // fadd v2.2d,v0.2d,v1.2d
 md2asm_gpu_full_vector_pair md2asm_gpu_soil_water_cell_host,1,q3,q0,q1 // fsub v3.2d,v0.2d,v1.2d
    str q2,[x4],#16
    str q3,[x3],#16
    sub x5,x5,#2
    cbnz x5,.Lprfi_pair
    b .Lprfi_next
.Lprfi_scalar:
    cbz x5,.Lprfi_next
    ldr d0,[x0]
    ldr d1,[x1]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,0,d2,d0,d1 // fadd d2,d0,d1
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,1,d3,d0,d1 // fsub d3,d0,d1
    str d2,[x4]
    str d3,[x3]
    add x0,x0,x26
    add x1,x1,x26
    add x3,x3,x29
    add x4,x4,x30
    sub x5,x5,#1
    b .Lprfi_scalar
.Lprfi_next:
    add x20,x20,#1
    cmp x20,x21
    b.le .Lprfi_row
.Lprfi_done:
    ldp x19,x20,[sp,#0]
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x25,x26,[sp,#48]
    ldp x27,x28,[sp,#64]
    ldp x29,x30,[sp,#80]
    add sp,sp,#160
    ret
.size md2asm_ltdir_parity_child_7358525,.-md2asm_ltdir_parity_child_7358525
.section .note.GNU-stack,"",%progbits
