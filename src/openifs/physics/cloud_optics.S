/* Complete active SOCRATES/Fu cloud mixture in dimensionless optical units.
 * Physics formulations/openifs/physics/cloud_optical_mixture.md.
 * Contract skills/md2asm/references/openifs/physics/cloud_optics.md.
 * Twelve argument addresses, with four output addresses on the stack.
 * Bind complete direct children. No driver supplies a numerical stage. */
#ifndef CLOUD_OPTICS_SYMBOL
#define CLOUD_OPTICS_SYMBOL __radiation_cloud_optics_MOD_cloud_optics
#endif
.text
.p2align 4
.macro ZERO_TEMP slot,bands
    ldr x0,[x29,#\slot]
    mov x1,\bands
    bl .Lcloud_zero
.endm
.macro OPTICAL_CHILD symbol,count,coeff,water,radius,tau,sca,g
    add x0,x29,#\count
    mov x9,#\coeff
    add x1,x19,x9
    add x2,x29,#\water
    ldr x3,[x29,#\radius]
    ldr x4,[x29,#\tau]
    ldr x5,[x29,#\sca]
    ldr x6,[x29,#\g]
    bl \symbol
.endm
.macro DELTA_ARRAY tau,sca,g,bands
    ldr x0,[x29,#\tau]
    ldr x1,[x29,#\sca]
    ldr x2,[x29,#\g]
    mov x3,\bands
    bl .Lcloud_delta_array
.endm
.global CLOUD_OPTICS_SYMBOL
.type CLOUD_OPTICS_SYMBOL,%function
CLOUD_OPTICS_SYMBOL:
    stp x29,x30,[sp,#-496]!
    mov x29,sp
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    mov x19,x3
    mov x20,x4
    mov x21,x5
    ldrsw x22,[x0]
    ldrsw x23,[x1]
    ldrsw x24,[x2]
    stp x6,x7,[sp,#128]
    add x9,x29,#496
    ldp x10,x11,[x9]
    stp x10,x11,[sp,#144]
    ldp x10,x11,[x9,#16]
    stp x10,x11,[sp,#160]
    ldr w9,[x19,#696]
    cmp w9,#2
    b.ne .Lcloud_unsupported
    ldr w9,[x19,#700]
    cmp w9,#2
    b.ne .Lcloud_unsupported
    cmp x22,#0
    b.le .Lcloud_return
    cmp x23,x24
    b.gt .Lcloud_return
    mov x9,#20008
    ldrsw x27,[x19,x9]
    mov x9,#20004
    ldrsw x28,[x19,x9]
    str w27,[x29,#320]
    str w28,[x29,#324]
    add x9,x27,x28
    mov x10,#48
    mul x9,x9,x10
    add x9,x9,#15
    and x9,x9,#-16
    sub sp,sp,x9
    mov x9,sp
    add x10,x29,#192
    mov x11,#6
.Lcloud_lw_storage:
    str x9,[x10],#8
    add x9,x9,x27,lsl #3
    subs x11,x11,#1
    b.ne .Lcloud_lw_storage
    mov x11,#6
.Lcloud_sw_storage:
    str x9,[x10],#8
    add x9,x9,x28,lsl #3
    subs x11,x11,#1
    b.ne .Lcloud_sw_storage
    sub x9,x24,x23
    add x9,x9,#1
    mul x9,x9,x22
    mul x1,x9,x27
    str x1,[x29,#368]
    mul x1,x9,x28
    str x1,[x29,#376]
    ldr x0,[x29,#128]
    ldr x1,[x29,#368]
    bl .Lcloud_zero
    ldr w9,[x19,#608]
    cbz w9,.Lcloud_clear_sw
    ldr x0,[x29,#136]
    ldr x1,[x29,#368]
    bl .Lcloud_zero
    ldr x0,[x29,#144]
    ldr x1,[x29,#368]
    bl .Lcloud_zero
.Lcloud_clear_sw:
    ldr x0,[x29,#152]
    ldr x1,[x29,#376]
    bl .Lcloud_zero
    ldr x0,[x29,#160]
    ldr x1,[x29,#376]
    bl .Lcloud_zero
    ldr x0,[x29,#168]
    ldr x1,[x29,#376]
    bl .Lcloud_zero
    mov x25,#1
.Lcloud_layer:
    mov x26,x23
.Lcloud_column:
    add x0,x21,#352
    mov x1,x26
    mov x2,x25
    bl .Lcloud_cell_address
    ldr d0,[x0]
    fcmp d0,#0.0
    b.le .Lcloud_next_column
    mov x0,x20
    mov x1,x26
    mov x2,x25
    bl .Lcloud_cell_address
    ldr d1,[x0]
    mov x0,x20
    mov x1,x26
    add x2,x25,#1
    bl .Lcloud_cell_address
    ldr d2,[x0]
    fsub d2,d2,d1
    adr x9,.Lcloud_gravity
    ldr d1,[x9]
    mov x9,#20028
    ldr w9,[x19,x9]
    cbnz w9,.Lcloud_factor_ready
    fmul d1,d1,d0
.Lcloud_factor_ready:
    fdiv d0,d2,d1
    str d0,[x29,#304]
    mov x0,x21
    mov x1,x26
    mov x2,x25
    bl .Lcloud_cell_address
    ldr d1,[x0]
    ldr d0,[x29,#304]
    fmul d1,d0,d1
    str d1,[x29,#288]
    add x0,x21,#88
    mov x1,x26
    mov x2,x25
    bl .Lcloud_cell_address
    str x0,[x29,#344]
    ldr d1,[x0]
    ldr d0,[x29,#304]
    fmul d1,d0,d1
    str d1,[x29,#296]
    ldr d0,[x29,#288]
    fcmp d0,#0.0
    b.le .Lcloud_no_liquid
    add x0,x21,#176
    mov x1,x26
    mov x2,x25
    bl .Lcloud_cell_address
    str x0,[x29,#328]
    OPTICAL_CHILD md2asm_cloud_socrates,320,11128,288,328,192,200,208
    OPTICAL_CHILD md2asm_cloud_socrates,324,11216,288,328,240,248,256
    ldr w9,[x19,#628]
    cbnz w9,.Lcloud_ice
    DELTA_ARRAY 240,248,256,x28
    b .Lcloud_ice
.Lcloud_no_liquid:
    ZERO_TEMP 192,x27
    ZERO_TEMP 200,x27
    ZERO_TEMP 208,x27
    ZERO_TEMP 240,x28
    ZERO_TEMP 248,x28
    ZERO_TEMP 256,x28
.Lcloud_ice:
    ldr d0,[x29,#296]
    fcmp d0,#0.0
    b.le .Lcloud_no_ice
    add x0,x21,#264
    mov x1,x26
    mov x2,x25
    bl .Lcloud_cell_address
    str x0,[x29,#336]
    OPTICAL_CHILD md2asm_cloud_fu_lw,320,11304,296,336,216,224,232
    mov x9,#7964
    ldr w9,[x19,x9]
    cbz w9,.Lcloud_fu_sw
    ldr x0,[x29,#216]
    ldr x1,[x29,#224]
    mov x2,x27
    bl .Lcloud_scatter_compatibility
.Lcloud_fu_sw:
    OPTICAL_CHILD md2asm_cloud_fu_sw,324,11392,296,336,264,272,280
    ldr w9,[x19,#628]
    cbnz w9,.Lcloud_ice_lw_delta
    DELTA_ARRAY 264,272,280,x28
.Lcloud_ice_lw_delta:
    DELTA_ARRAY 216,224,232,x27
    b .Lcloud_combine
.Lcloud_no_ice:
    ZERO_TEMP 216,x27
    ZERO_TEMP 224,x27
    ZERO_TEMP 232,x27
    ZERO_TEMP 264,x28
    ZERO_TEMP 272,x28
    ZERO_TEMP 280,x28
.Lcloud_combine:
    sub x9,x26,x23
    sub x10,x25,#1
    madd x9,x9,x22,x10
    mul x10,x9,x27
    lsl x10,x10,#3
    mul x9,x9,x28
    lsl x9,x9,#3
    str x9,[x29,#360]
    add x0,x29,#192
    mov x1,x27
    ldr x2,[x29,#128]
    add x2,x2,x10
    ldr x3,[x29,#136]
    add x3,x3,x10
    ldr x4,[x29,#144]
    add x4,x4,x10
    ldr w5,[x19,#608]
    bl .Lcloud_mix
    ldr x9,[x29,#360]
    add x0,x29,#240
    mov x1,x28
    ldr x2,[x29,#152]
    add x2,x2,x9
    ldr x3,[x29,#160]
    add x3,x3,x9
    ldr x4,[x29,#168]
    add x4,x4,x9
    mov w5,#2
    bl .Lcloud_mix
.Lcloud_next_column:
    add x26,x26,#1
    cmp x26,x24
    b.le .Lcloud_column
    add x25,x25,#1
    cmp x25,x22
    b.le .Lcloud_layer
.Lcloud_return:
    mov sp,x29
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp x29,x30,[sp],#496
    ret
.Lcloud_unsupported:
    bl abort
.size CLOUD_OPTICS_SYMBOL,.-CLOUD_OPTICS_SYMBOL

/* Address one element of an owner descriptor without touching FP state. */
.Lcloud_cell_address:
    ldp x3,x4,[x0]
    ldr x5,[x0,#40]
    ldr x6,[x0,#64]
    madd x4,x1,x5,x4
    madd x4,x2,x6,x4
    add x0,x3,x4,lsl #3
    ret

/* x0 raw FP64 array and x1 count. */
.Lcloud_zero:
    cbz x1,.Lcloud_zero_return
.Lcloud_zero_cell:
    str xzr,[x0],#8
    subs x1,x1,#1
    b.ne .Lcloud_zero_cell
.Lcloud_zero_return:
    ret

/* x0 total depth, x1 scattering depth, x2 count. */
.Lcloud_scatter_compatibility:
    cbz x2,.Lcloud_compatibility_return
.Lcloud_compatibility_cell:
    ldr d0,[x0],#8
    ldr d1,[x1]
    fsub d0,d0,d1
    str d0,[x1],#8
    subs x2,x2,#1
    b.ne .Lcloud_compatibility_cell
.Lcloud_compatibility_return:
    ret

/* Apply the complete accepted scalar delta body to one array triple. */
.Lcloud_delta_array:
    stp x29,x30,[sp,#-48]!
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    mov x19,x0
    mov x20,x1
    mov x21,x2
    mov x22,x3
    cbz x22,.Lcloud_delta_return
.Lcloud_delta_cell:
    mov x0,x19
    mov x1,x20
    mov x2,x21
    bl md2asm_cloud_delta
    add x19,x19,#8
    add x20,x20,#8
    add x21,x21,#8
    subs x22,x22,#1
    b.ne .Lcloud_delta_cell
.Lcloud_delta_return:
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x29,x30,[sp],#48
    ret

/* x0 six private arrays, x1 count, x2/x3/x4 outputs.
 * Mode zero is absorption, one is longwave scattering, two is shortwave. */
.Lcloud_mix:
    ldp x6,x7,[x0]
    ldp x8,x9,[x0,#16]
    ldp x10,x11,[x0,#32]
    cbz x1,.Lcloud_mix_return
.Lcloud_mix_band:
    ldr d0,[x6],#8
    ldr d1,[x7],#8
    ldr d2,[x8],#8
    ldr d3,[x9],#8
    ldr d4,[x10],#8
    ldr d5,[x11],#8
    cbz w5,.Lcloud_mix_absorption
    fadd d0,d0,d3
    fadd d6,d1,d4
    fmul d2,d2,d1
    fmul d5,d5,d4
    fadd d2,d2,d5
    cmp w5,#1
    b.ne .Lcloud_mix_divide
    fcmp d6,#0.0
    b.gt .Lcloud_mix_divide
    fmov d2,xzr
    b .Lcloud_mix_albedo
.Lcloud_mix_divide:
    fdiv d2,d2,d6
.Lcloud_mix_albedo:
    fdiv d6,d6,d0
    str d6,[x3],#8
    str d2,[x4],#8
    b .Lcloud_mix_store
.Lcloud_mix_absorption:
    fsub d0,d0,d1
    fadd d0,d0,d3
    fsub d0,d0,d4
.Lcloud_mix_store:
    str d0,[x2],#8
    subs x1,x1,#1
    b.ne .Lcloud_mix_band
.Lcloud_mix_return:
    ret
.p2align 3
.Lcloud_gravity:
    .double 9.80665
.section .note.GNU-stack,"",%progbits
