/* GPU physical setup route. Original interface and ordered arithmetic are preserved.
 * Contract: skills/md2asm-gpu/references/openifs/setup/physical_setup.md
 * Original source: src/openifs/setup/ecmwf_physics_tail_fields.S
 */
// Original contract: skills/md2asm/references/openifs/setup/ecmwf_physics_tail.md
#include "../../support/gpu/preserved_scalar_calls.inc.S"
.text
.p2align 4
.global md2asm_wave_coupling_startup_fields
.type md2asm_wave_coupling_startup_fields,%function
md2asm_wave_coupling_startup_fields:
    adrp x9,.Ltail_wave_missing
    ldr x9,[x9,:lo12:.Ltail_wave_missing]
    str x9,[x1,#64]
    mov w9,#1
    stp w9,w9,[x1,#8]
    mov w9,#-99
    str w9,[x1,#32]
    ldr w2,[x0,#4]
    mov w3,#3600
    sdiv w4,w2,w3
    msub w5,w4,w3,w2
 md2asm_gpu_preserved_scalar md2asm_gpu_startup_integer_cell_host,18,d0,destination,w5,general,w16,168,zero
    adrp x9,.Ltail_sixty
    ldr d1,[x9,:lo12:.Ltail_sixty]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d0,destination,d0,real,x16,0,d1
 md2asm_gpu_preserved_scalar md2asm_gpu_physical_setup_numeric_cell_host,24,w6,destination,d0,real,x16,0,zero
    mov w10,#60
    msub w7,w6,w10,w5
    mov w9,#10000
    mul w8,w4,w9
    mov w9,#100
    madd w8,w6,w9,w8
    add w8,w8,w7
    ldr w9,[x0]
    add x14,x1,#111
    mov w10,#8
    mov w11,#10
.Ltail_date_digit:
    udiv w12,w9,w11
    msub w13,w12,w11,w9
    add w13,w13,#48
    strb w13,[x14],#-1
    mov w9,w12
    subs w10,w10,#1
    b.ne .Ltail_date_digit
    mov w9,w8
    add x14,x1,#117
    mov w10,#6
.Ltail_time_digit:
    udiv w12,w9,w11
    msub w13,w12,w11,w9
    add w13,w13,#48
    strb w13,[x14],#-1
    mov w9,w12
    subs w10,w10,#1
    b.ne .Ltail_time_digit
    ret
.size md2asm_wave_coupling_startup_fields,.-md2asm_wave_coupling_startup_fields
.p2align 4
.global md2asm_linearized_physics_parameter_fields
.type md2asm_linearized_physics_parameter_fields,%function
md2asm_linearized_physics_parameter_fields:
    stp wzr,wzr,[x1]
    str wzr,[x1,#8]
    str wzr,[x1,#24]
    ldp w9,w10,[x0,#8]
    orr w9,w9,w10
    str w9,[x1,#16]
    adrp x9,.Ltail_linear_literals
    add x9,x9,:lo12:.Ltail_linear_literals
    ldp d0,d1,[x0,#24]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d0,destination,d0,real,x16,0,d1
    ldr d2,[x9]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d0,destination,d0,real,x16,0,d2
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d1,real,x16,0,d0
    str d0,[x1,#32]
    add x10,x1,#40
    add x9,x9,#8
    mov x11,#10
.Ltail_linear_literal_copy:
    ldr x12,[x9],#8
    str x12,[x10],#8
    subs x11,x11,#1
    b.ne .Ltail_linear_literal_copy
    ldp w9,w10,[x0,#16]
    cmp w10,#1
    cset w10,eq
    and w9,w9,w10
    str w9,[x1,#20]
    ldr w9,[x2,#8]
    stp w9,w9,[x2,#32]
    str w9,[x2,#40]
    mov w9,#5
    str w9,[x3]
    ret
.size md2asm_linearized_physics_parameter_fields,.-md2asm_linearized_physics_parameter_fields
.p2align 4
.global md2asm_methane_oxidation_parameter_fields
.type md2asm_methane_oxidation_parameter_fields,%function
md2asm_methane_oxidation_parameter_fields:
    stp x19,x20,[sp,#-64]!
    stp x21,x30,[sp,#16]
    str x18,[sp,#32]
    mov x19,x0
    adrp x20,.Ltail_methane_literals
    add x20,x20,:lo12:.Ltail_methane_literals
    mov x9,#0
.Ltail_methane_literal_copy:
    ldr x10,[x20,x9,lsl #3]
    str x10,[x19,x9,lsl #3]
    add x9,x9,#1
    cmp x9,#7
    b.lo .Ltail_methane_literal_copy
    ldr d0,[x20,#56]
    ldr d1,[x19,#8]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d0,real,x16,0,d1
    fmov d1,#0.5
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d1,real,x16,0,d0
    str d0,[x19,#56]
    ldr d0,[x19,#48]
    ldr d1,[x19,#32]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d0,destination,d0,real,x16,0,d1
    bl log
    ldr x18,[sp,#32]
    str d0,[x19,#64]
    ldp x21,x30,[sp,#16]
    ldp x19,x20,[sp],#64
    ret
.size md2asm_methane_oxidation_parameter_fields,.-md2asm_methane_oxidation_parameter_fields
.section .rodata
.p2align 3
.Ltail_wave_missing:
 .double -999.0
.Ltail_sixty:
 .double 60.0
.Ltail_linear_literals:
    .double 1.4142135623730951,0.15,20.0,5.0,5.0,5.0,4000.0,0.2,0.0,0.0,30000.0
.section .rodata
.p2align 3
.Ltail_methane_literals:
 .xword 0x3fe161de809d4f32
 .xword 0xbff11ad7d41e07b1
 .xword 0x3ed42cb2bb7e9bbc
 .xword 0x40c3880000000000
 .xword 0x4034000000000000
 .xword 0x4049000000000000
 .xword 0x3fb999999999999a
 .xword 0x40126bb1bbb55516
.section .note.GNU-stack,"",%progbits
