// Direct complete aerosol mixture from P01-P03.
// Physics: formulations/openifs/physics/aerosol_optical_mixture.md.
// Contract: skills/md2asm/references/openifs/physics/add_aerosol_optics.md.
// The private context and loops own every numerical stage. Accepted native
// gas and delta children supply their complete verified operations.
// Public GNU arguments, object offsets, output bounds and scratch limits
// follow the contract. x19-x29 and the link register are preserved.
.text
.p2align 4
.macro aerosol_frame
    stp x29,x30,[sp,#-432]!
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    mov x29,sp
    add x19,sp,#96
.endm
.macro aerosol_load3
    ldr x13,[x9]
    ldr x14,[x9,#8]
    ldr x15,[x9,#40]
    madd x14,x10,x15,x14
    ldr x15,[x9,#64]
    madd x14,x11,x15,x14
    ldr x15,[x9,#88]
    madd x14,x12,x15,x14
    ldr d0,[x13,x14,lsl #3]
.endm

.macro aerosol_load2
    ldr x13,[x9]
    ldr x14,[x9,#8]
    ldr x15,[x9,#40]
    madd x14,x10,x15,x14
    ldr x15,[x9,#64]
    madd x14,x11,x15,x14
    ldr d0,[x13,x14,lsl #3]
.endm

.macro aerosol_load_i1
    ldr x13,[x9]
    ldr x14,[x9,#8]
    ldr x15,[x9,#40]
    madd x14,x10,x15,x14
    ldr w0,[x13,x14,lsl #2]
.endm

.macro aerosol_table_load
    ldr w10,[x19,#316]
    mov x11,x27
    ldr w13,[x19,#324]
    cmp w13,#2
    b.eq .Laerosol_inline_table2_\@
    mov x11,x26
    mov x12,x27
    aerosol_load3
    b .Laerosol_inline_table_done_\@
.Laerosol_inline_table2_\@:
    aerosol_load2
.Laerosol_inline_table_done_\@:
.endm

// Bind band one once. All descriptor offsets and strides remain signed.
// x9 is the descriptor, x26 the humidity bin, and x27 the species index.
.macro aerosol_bind_table2 pointer, step
    ldr \pointer,[x9]
    ldr x13,[x9,#8]
    ldr \step,[x9,#40]
    add x13,x13,\step
    ldr x14,[x9,#64]
    madd x13,x27,x14,x13
    add \pointer,\pointer,x13,lsl #3
    lsl \step,\step,#3
.endm

.macro aerosol_bind_table3 pointer, step
    ldr \pointer,[x9]
    ldr x13,[x9,#8]
    ldr \step,[x9,#40]
    add x13,x13,\step
    ldr x14,[x9,#64]
    madd x13,x26,x14,x13
    ldr x14,[x9,#88]
    madd x13,x27,x14,x13
    add \pointer,\pointer,x13,lsl #3
    lsl \step,\step,#3
.endm

.global md2asm_add_aerosol_optics
.type md2asm_add_aerosol_optics,%function
md2asm_add_aerosol_optics:
    aerosol_frame
    str x3,[x19]
    str x6,[x19,#8]
    str x4,[x19,#16]
    str x5,[x19,#24]
    ldr w9,[x0]
    str w9,[x19,#32]
    ldr w9,[x1]
    str w9,[x19,#36]
    ldr w9,[x2]
    str w9,[x19,#40]
    str x7,[x19,#48]
    ldp x9,x10,[sp,#432]
    stp x9,x10,[x19,#56]
    ldp x9,x10,[sp,#448]
    stp x9,x10,[x19,#72]
    ldr x9,[sp,#464]
    str x9,[x19,#88]
    ldr w9,[x6,#792]
    str w9,[x19,#288]
    b .Laerosol_begin
.size md2asm_add_aerosol_optics,.-md2asm_add_aerosol_optics

.global md2asm_add_aerosol_optics_direct
.type md2asm_add_aerosol_optics_direct,%function
md2asm_add_aerosol_optics_direct:
    aerosol_frame
    str x3,[x19]
    str x4,[x19,#8]
    ldr w9,[x0]
    str w9,[x19,#32]
    ldr w9,[x1]
    str w9,[x19,#36]
    ldr w9,[x2]
    str w9,[x19,#40]
    stp x5,x6,[x19,#48]
    str x7,[x19,#64]
    ldp x9,x10,[sp,#432]
    stp x9,x10,[x19,#72]
    ldr x9,[sp,#448]
    str x9,[x19,#88]
    mov w9,#1
    str w9,[x19,#288]
.Laerosol_begin:
    ldr w9,[x19,#32]
    cmp w9,#0
    b.le .Laerosol_return
    ldp w10,w11,[x19,#36]
    subs w10,w11,w10
    b.lt .Laerosol_return
    add w10,w10,#1
    str w10,[x19,#44]
    ldr x20,[x19]
    mov x9,#19968
    add x9,x20,x9
    ldp w10,w11,[x9,#28]
    str w10,[x19,#120]
    str w11,[x19,#124]
    ldp w10,w11,[x9,#36]
    stp w10,w11,[x19,#112]
    ldr w10,[x9,#52]
    str w10,[x19,#128]
    // Positive-zero output stages use their complete declared owner extent.
    ldr w9,[x19,#288]
    cbz w9,.Laerosol_zero_sw
    ldr w9,[x20,#6852]
    cbz w9,.Laerosol_zero_lw
.Laerosol_zero_sw:
    ldr x0,[x19,#88]
    ldr w1,[x19,#120]
    bl .Laerosol_zero
.Laerosol_zero_lw:
    ldr w9,[x19,#288]
    cbz w9,.Laerosol_zero_lw_flag
    ldr w9,[x20,#6848]
    cbz w9,.Laerosol_allocate
.Laerosol_zero_lw_flag:
    ldr w9,[x20,#612]
    cbz w9,.Laerosol_allocate
    ldr x0,[x19,#56]
    ldr w1,[x19,#128]
    bl .Laerosol_zero
    ldr x0,[x19,#64]
    ldr w1,[x19,#128]
    bl .Laerosol_zero
.Laerosol_allocate:
    ldp w9,w10,[x19,#112]
    add x9,x9,x10
    mov x10,#24
    mul x9,x9,x10
    str x9,[x19,#104]
    ldr w10,[x19,#288]
    cbnz w10,.Laerosol_malloc
    ldr w10,[x19,#32]
    ldr w11,[x19,#44]
    mul x10,x10,x11
    add x9,x9,x10,lsl #3
.Laerosol_malloc:
    mov x0,x9
    bl malloc
    str x0,[x19,#96]
    cbz x0,.Laerosol_allocation_failed
    ldr w9,[x19,#288]
    cbnz w9,.Laerosol_set_layers
    // Construct the complete water output descriptor and native gas class.
    ldr x9,[x19,#104]
    add x9,x0,x9
    str x9,[x19,#136]
    ldr w10,[x19,#44]
    neg x11,x10
    sub x11,x11,#1
    str x11,[x19,#144]
    mov x11,#8
    str x11,[x19,#152]
    mov w11,#0x0302
    str w11,[x19,#164]
    str wzr,[x19,#160]
    mov x11,#8
    str x11,[x19,#168]
    mov x11,#1
    stp x11,x11,[x19,#176]
    str x10,[x19,#192]
    stp x10,x11,[x19,#200]
    ldr w12,[x19,#32]
    str x12,[x19,#216]
    ldr x9,[x19,#24]
    stp x9,xzr,[x19,#224]
    mov w9,#1
    str w9,[x19,#256]
    str wzr,[x19,#260]
    add x0,x19,#224
    add x1,x19,#256
    add x2,x19,#260
    add x3,x19,#136
    mov x4,xzr
    add x5,x19,#36
    bl md2asm_get_gas
.Laerosol_set_layers:
    ldr x20,[x19,#8]
    ldr w9,[x19,#288]
    cbz w9,.Laerosol_mass_layers
    // Direct spectra can have distinct layer ranges and enable flags.
    str wzr,[x19,#292]
.Laerosol_direct_next_wave:
    ldr x20,[x19,#8]
    ldr w9,[x19,#292]
    ldr x10,[x19]
    mov x11,#6852
    sub x11,x11,x9,lsl #2
    ldr w10,[x10,x11]
    cbz w10,.Laerosol_direct_wave_done
    mov x10,#112
    mov x11,#336
    madd x10,x9,x11,x10
    add x10,x20,x10
    ldr w11,[x10,#72]
    ldr w12,[x10,#80]
    str w11,[x19,#264]
    str w12,[x19,#300]
    b .Laerosol_cell_column_init
.Laerosol_mass_layers:
    ldr w11,[x20,#72]
    ldr w12,[x20,#80]
    str w11,[x19,#264]
    str w12,[x19,#300]
.Laerosol_cell_column_init:
    ldr w9,[x19,#264]
    ldr w10,[x19,#300]
    cmp w9,w10
    b.gt .Laerosol_layers_done
    ldr w9,[x19,#36]
    str w9,[x19,#268]
.Laerosol_cell:
    ldr w9,[x19,#288]
    cbnz w9,.Laerosol_direct_cell
    bl .Laerosol_mass_prepare
    mov w0,#0
    bl .Laerosol_combine
    mov w0,#1
    bl .Laerosol_combine
    b .Laerosol_cell_done
.Laerosol_direct_cell:
    bl .Laerosol_direct_prepare
    ldr w0,[x19,#292]
    bl .Laerosol_combine
.Laerosol_cell_done:
    ldr w9,[x19,#268]
    add w9,w9,#1
    str w9,[x19,#268]
    ldr w10,[x19,#40]
    cmp w9,w10
    b.le .Laerosol_cell
    ldr w9,[x19,#264]
    add w9,w9,#1
    str w9,[x19,#264]
    b .Laerosol_cell_column_init
.Laerosol_layers_done:
    ldr w9,[x19,#288]
    cbz w9,.Laerosol_free
.Laerosol_direct_wave_done:
    ldr w9,[x19,#292]
    add w9,w9,#1
    str w9,[x19,#292]
    cmp w9,#2
    b.lt .Laerosol_direct_next_wave
.Laerosol_free:
    ldr x0,[x19,#96]
    bl free
.Laerosol_return:
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp x29,x30,[sp],#432
    ret
.Laerosol_allocation_failed:
    bl abort
.size md2asm_add_aerosol_optics_direct,.-md2asm_add_aerosol_optics_direct

// x0 owner, x1 radiation-point extent. No access for zero extent.
.Laerosol_zero:
    ldr w9,[x19,#32]
    ldr w10,[x19,#44]
    mul x9,x9,x10
    mul x9,x9,x1
    cbz x9,.Laerosol_zero_done
.Laerosol_zero_loop:
    str xzr,[x0],#8
    subs x9,x9,#1
    b.ne .Laerosol_zero_loop
.Laerosol_zero_done:
    ret

// Complete descriptor loads. x9 descriptor, x10..x12 absolute indices.
// Only x13..x16 and d0 are overwritten.
.global md2asm_aerosol_rh_index
.type md2asm_aerosol_rh_index,%function
md2asm_aerosol_rh_index:
    ldr x2,[x0]
    mov x3,#6144
    add x3,x2,x3
    ldr w4,[x3,#76]
    cbz w4,.Laerosol_rh_disabled
    ldr w4,[x3,#60]
    add x3,x2,#2128
    ldr x5,[x3]
    ldr x6,[x3,#8]
    ldr x7,[x3,#40]
    ldr d0,[x1]
    sxtw x8,w4
    madd x8,x8,x7,x6
    ldr d1,[x5,x8,lsl #3]
    fcmp d0,d1
    b.gt .Laerosol_rh_last
    mov w0,#1
.Laerosol_rh_search:
    add w8,w0,#1
    sxtw x8,w8
    madd x8,x8,x7,x6
    ldr d1,[x5,x8,lsl #3]
    fcmp d0,d1
    b.le .Laerosol_rh_done
    add w0,w0,#1
    b .Laerosol_rh_search
.Laerosol_rh_last:
    mov w0,w4
.Laerosol_rh_done:
    ret
.Laerosol_rh_disabled:
    mov w0,#0
    ret
.size md2asm_aerosol_rh_index,.-md2asm_aerosol_rh_index

.Laerosol_mass_prepare:
    stp x29,x30,[sp,#-16]!
    // Zero six independent band accumulators.
    ldr x9,[x19,#96]
    ldr x10,[x19,#104]
    cbz x10,.Laerosol_mass_zero_done
.Laerosol_mass_zero:
    str xzr,[x9],#8
    subs x10,x10,#8
    b.ne .Laerosol_mass_zero
.Laerosol_mass_zero_done:
    ldr x20,[x19]
    mov x28,#11608
    add x28,x20,x28
    stp x28,xzr,[x19,#240]
    ldr w9,[x19,#264]
    sub w9,w9,#1
    ldr w10,[x19,#44]
    mul x9,x9,x10
    ldr w11,[x19,#268]
    ldr w12,[x19,#36]
    sub w11,w11,w12
    add x9,x9,x11
    ldr x10,[x19,#136]
    ldr d1,[x10,x9,lsl #3]
    ldr x9,[x19,#16]
    add x9,x9,#176
    ldr w10,[x19,#268]
    ldr w11,[x19,#264]
    aerosol_load2
    fdiv d1,d1,d0
    str d1,[x19,#304]
    add x0,x19,#240
    add x1,x19,#304
    bl md2asm_aerosol_rh_index
    str w0,[x19,#276]
    ldr x9,[x19,#16]
    ldr w10,[x19,#268]
    ldr w11,[x19,#264]
    aerosol_load2
    fmov d1,d0
    add w11,w11,#1
    aerosol_load2
    fsub d0,d0,d1
    adrp x9,.Laerosol_gravity
    ldr d1,[x9,:lo12:.Laerosol_gravity]
    fdiv d0,d0,d1
    str d0,[x19,#280]
    mov w9,#1
    str w9,[x19,#272]
.Laerosol_type_loop:
    ldr w10,[x19,#272]
    ldr x9,[x19]
    ldr w11,[x9,#6912]
    cmp w10,w11
    b.gt .Laerosol_mass_done
    add x9,x28,#0
    aerosol_load_i1
    cmp w0,#2
    b.lt .Laerosol_type_next
    str w0,[x19,#324]
    add x9,x28,#64
    ldr w10,[x19,#272]
    aerosol_load_i1
    str w0,[x19,#320]
    ldr x9,[x19,#8]
    ldr w10,[x19,#268]
    ldr w11,[x19,#264]
    ldr w12,[x19,#272]
    aerosol_load3
    ldr d1,[x19,#280]
    fmul d0,d1,d0
    str d0,[x19,#304]
    mov w0,#0
    bl .Laerosol_accumulate_wave
    mov w0,#1
    bl .Laerosol_accumulate_wave
.Laerosol_type_next:
    ldr w9,[x19,#272]
    add w9,w9,#1
    str w9,[x19,#272]
    b .Laerosol_type_loop
.Laerosol_mass_done:
    ldp x29,x30,[sp],#16
    ret

.Laerosol_accumulate_wave:
    stp x29,x30,[sp,#-16]!
    mov w25,w0
    ldr x20,[x19,#96]
    ldr w23,[x19,#112]
    cbz w25,.Laerosol_accum_sw
    mov x9,#24
    madd x20,x23,x9,x20
    ldr w23,[x19,#116]
.Laerosol_accum_sw:
    add x21,x20,x23,lsl #3
    add x22,x21,x23,lsl #3
    ldr w9,[x19,#324]
    cmp w9,#2
    mov x24,#128
    mov x10,#656
    csel x24,x24,x10,eq
    mov x10,#264
    mov x11,#336
    csel x10,x10,x11,eq
    madd x24,x25,x10,x24
    ldr x28,[x19]
    mov x9,#11608
    add x28,x28,x9
    ldr w26,[x19,#276]
    ldr w27,[x19,#320]
    mov x9,#1
    str w9,[x19,#316]
    cmp w23,#1
    b.lt .Laerosol_accum_done
    add x9,x28,x24
    ldr w10,[x19,#324]
    cmp w10,#2
    b.eq .Laerosol_bind_hydrophobic
    aerosol_bind_table3 x0,x1
    add x9,x9,#112
    aerosol_bind_table3 x2,x3
    cbz w25,.Laerosol_bind_hydrophilic_direction
    ldr x10,[x19]
    ldr w10,[x10,#612]
    cbz w10,.Laerosol_bind_done
.Laerosol_bind_hydrophilic_direction:
    add x9,x9,#112
    aerosol_bind_table3 x4,x5
    b .Laerosol_bind_done
.Laerosol_bind_hydrophobic:
    aerosol_bind_table2 x0,x1
    add x9,x9,#88
    aerosol_bind_table2 x2,x3
    cbz w25,.Laerosol_bind_hydrophobic_direction
    ldr x10,[x19]
    ldr w10,[x10,#612]
    cbz w10,.Laerosol_bind_done
.Laerosol_bind_hydrophobic_direction:
    add x9,x9,#88
    aerosol_bind_table2 x4,x5
.Laerosol_bind_done:
.Laerosol_accum_band:
    ldr w10,[x19,#316]
    cmp w10,w23
    b.gt .Laerosol_accum_done
    ldr d0,[x0]
    add x0,x0,x1
    ldr d7,[x19,#304]
    fmul d1,d7,d0
    ldr d0,[x2]
    add x2,x2,x3
    fmov d2,d0
    cbz w25,.Laerosol_accum_scattering
    ldr x9,[x19]
    ldr w9,[x9,#612]
    cbnz w9,.Laerosol_accum_scattering
    fmov d3,#1.0
    fsub d3,d3,d2
    fmul d1,d1,d3
    ldr w9,[x19,#316]
    sub w9,w9,#1
    ldr d3,[x20,x9,lsl #3]
    fadd d3,d3,d1
    str d3,[x20,x9,lsl #3]
    b .Laerosol_accum_next
.Laerosol_accum_scattering:
    ldr d0,[x4]
    add x4,x4,x5
    fmul d4,d1,d2
    ldr w9,[x19,#316]
    sub w9,w9,#1
    ldr d3,[x20,x9,lsl #3]
    fadd d3,d3,d1
    str d3,[x20,x9,lsl #3]
    ldr d3,[x21,x9,lsl #3]
    fadd d3,d3,d4
    str d3,[x21,x9,lsl #3]
    fmul d4,d4,d0
    ldr d3,[x22,x9,lsl #3]
    fadd d3,d3,d4
    str d3,[x22,x9,lsl #3]
.Laerosol_accum_next:
    ldr w9,[x19,#316]
    add w9,w9,#1
    str w9,[x19,#316]
    b .Laerosol_accum_band
.Laerosol_accum_done:
    ldp x29,x30,[sp],#16
    ret
.Laerosol_direct_prepare:
    stp x29,x30,[sp,#-16]!
    ldr w25,[x19,#292]
    ldr x20,[x19,#96]
    ldr w23,[x19,#112]
    cbz w25,.Laerosol_direct_sw
    mov x9,#24
    madd x20,x23,x9,x20
    ldr w23,[x19,#116]
.Laerosol_direct_sw:
    add x21,x20,x23,lsl #3
    add x22,x21,x23,lsl #3
    mov x24,#112
    mov x9,#336
    madd x24,x25,x9,x24
    ldr x28,[x19,#8]
    mov x26,#1
.Laerosol_direct_band:
    cmp x26,x23
    b.gt .Laerosol_direct_done
    add x9,x28,x24
    mov x10,x26
    ldr w11,[x19,#264]
    ldr w12,[x19,#268]
    aerosol_load3
    fmov d1,d0
    add x9,x24,#112
    add x9,x28,x9
    aerosol_load3
    fmov d2,d0
    cbz w25,.Laerosol_direct_scattering
    ldr x9,[x19]
    ldr w9,[x9,#612]
    cbnz w9,.Laerosol_direct_scattering
    fmov d3,#1.0
    fsub d3,d3,d2
    fmul d1,d1,d3
    sub x9,x26,#1
    str d1,[x20,x9,lsl #3]
    str xzr,[x21,x9,lsl #3]
    str xzr,[x22,x9,lsl #3]
    b .Laerosol_direct_band_next
.Laerosol_direct_scattering:
    add x9,x24,#224
    add x9,x28,x9
    aerosol_load3
    fmul d2,d2,d1
    fmul d3,d0,d2
    sub x9,x26,#1
    str d1,[x20,x9,lsl #3]
    str d2,[x21,x9,lsl #3]
    str d3,[x22,x9,lsl #3]
.Laerosol_direct_band_next:
    add x26,x26,#1
    b .Laerosol_direct_band
.Laerosol_direct_done:
    ldp x29,x30,[sp],#16
    ret

.Laerosol_combine:
    stp x29,x30,[sp,#-16]!
    mov w25,w0
    ldr x28,[x19]
    ldr x20,[x19,#96]
    ldr w21,[x19,#112]
    ldr w22,[x19,#120]
    mov x27,#10928
    cbz w25,.Laerosol_combine_sw
    mov x9,#24
    madd x20,x21,x9,x20
    ldr w21,[x19,#116]
    ldr w22,[x19,#124]
    mov x27,#10864
    ldr w9,[x28,#612]
    cbz w9,.Laerosol_combine_no_delta
    b .Laerosol_delta_begin
.Laerosol_combine_sw:
    ldr w9,[x28,#628]
    cbnz w9,.Laerosol_combine_no_delta
.Laerosol_delta_begin:
    mov x26,#0
.Laerosol_delta_band:
    cmp x26,x21
    b.ge .Laerosol_combine_no_delta
    add x0,x20,x26,lsl #3
    add x1,x0,x21,lsl #3
    add x2,x1,x21,lsl #3
    bl md2asm_openifs_delta_eddington_extensive
    add x26,x26,#1
    b .Laerosol_delta_band
.Laerosol_combine_no_delta:
    cbnz w25,.Laerosol_combine_cell
    ldr d0,[x20]
    fcmp d0,#0.0
    b.le .Laerosol_combine_done
.Laerosol_combine_cell:
    ldr w9,[x19,#268]
    ldr w10,[x19,#36]
    sub w9,w9,w10
    ldr w10,[x19,#32]
    mul x9,x9,x10
    ldr w10,[x19,#264]
    sub w10,w10,#1
    add x9,x9,x10
    mul x23,x9,x22
    lsl x23,x23,#3
    mov x26,#0
.Laerosol_combine_point:
    cmp x26,x22
    b.ge .Laerosol_combine_done
    add x9,x28,x27
    add x10,x26,#1
    aerosol_load_i1
    sub w0,w0,#1
    sxtw x24,w0
    ldr d0,[x20,x24,lsl #3]
    add x9,x20,x21,lsl #3
    ldr d1,[x9,x24,lsl #3]
    add x9,x9,x21,lsl #3
    ldr d2,[x9,x24,lsl #3]
    cbnz w25,.Laerosol_combine_longwave
    ldr x9,[x19,#72]
    add x9,x9,x23
    ldr d3,[x9,x26,lsl #3]
    fadd d4,d3,d0
    ldr x10,[x19,#80]
    add x10,x10,x23
    ldr d5,[x10,x26,lsl #3]
    fmul d5,d5,d3
    fadd d5,d5,d1
    fdiv d6,d2,d5
    ldr x11,[x19,#88]
    add x11,x11,x23
    str d6,[x11,x26,lsl #3]
    fdiv d6,d5,d4
    str d6,[x10,x26,lsl #3]
    str d4,[x9,x26,lsl #3]
    b .Laerosol_combine_next
.Laerosol_combine_longwave:
    ldr x9,[x19,#48]
    add x9,x9,x23
    ldr w10,[x28,#612]
    cbz w10,.Laerosol_combine_absorption
    fcmp d0,#0.0
    b.le .Laerosol_combine_next
    fmov d4,xzr
    fcmp d1,#0.0
    b.le .Laerosol_combine_lw_zero_direction
    fdiv d4,d2,d1
.Laerosol_combine_lw_zero_direction:
    ldr x10,[x19,#64]
    add x10,x10,x23
    str d4,[x10,x26,lsl #3]
    ldr d3,[x9,x26,lsl #3]
    fadd d3,d3,d0
    fdiv d4,d1,d3
    ldr x10,[x19,#56]
    add x10,x10,x23
    str d4,[x10,x26,lsl #3]
    str d3,[x9,x26,lsl #3]
    b .Laerosol_combine_next
.Laerosol_combine_absorption:
    ldr d3,[x9,x26,lsl #3]
    fadd d3,d3,d0
    str d3,[x9,x26,lsl #3]
.Laerosol_combine_next:
    add x26,x26,#1
    b .Laerosol_combine_point
.Laerosol_combine_done:
    ldp x29,x30,[sp],#16
    ret

.section .rodata
.p2align 3
.Laerosol_gravity:
    .double 9.80665
.section .note.GNU-stack,"",%progbits
