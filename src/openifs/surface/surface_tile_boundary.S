/* Physics input formulations/openifs/surface/surface_tile_fractions.md.
 * Complete order and 45-address ABI are in the surfbc_ctl md2asm contract.
 * TF1 partitions surface area and TF2 supplies wet canopy cover.
 * Selected rows are independent. Every snow and tile sum stays ordered.
 * The 464-byte aligned frame preserves x19..x30 and leaves x18/v8..v15 alone.
 */
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL __surfbc_ctl_mod_MOD_surfbc_ctl
#endif
.text
.p2align 4
.global ORIGINAL_SYMBOL
.global md2asm_surface_tile_boundary
.type ORIGINAL_SYMBOL,%function
.type md2asm_surface_tile_boundary,%function
ORIGINAL_SYMBOL:
md2asm_surface_tile_boundary:
    mrs x9,fpcr
    cbnz x9,.Lquick_return
    mov x9,sp
    sub sp,sp,#464
    stp x19,x20,[sp,#360]
    stp x21,x22,[sp,#376]
    stp x23,x24,[sp,#392]
    stp x25,x26,[sp,#408]
    stp x27,x28,[sp,#424]
    stp x29,x30,[sp,#440]
    stp x0,x1,[sp,#0]
    stp x2,x3,[sp,#16]
    stp x4,x5,[sp,#32]
    stp x6,x7,[sp,#48]
    ldr x10,[x9,#0]
    str x10,[sp,#64]
    ldr x10,[x9,#8]
    str x10,[sp,#72]
    ldr x10,[x9,#16]
    str x10,[sp,#80]
    ldr x10,[x9,#24]
    str x10,[sp,#88]
    ldr x10,[x9,#32]
    str x10,[sp,#96]
    ldr x10,[x9,#40]
    str x10,[sp,#104]
    ldr x10,[x9,#48]
    str x10,[sp,#112]
    ldr x10,[x9,#56]
    str x10,[sp,#120]
    ldr x10,[x9,#64]
    str x10,[sp,#128]
    ldr x10,[x9,#72]
    str x10,[sp,#136]
    ldr x10,[x9,#80]
    str x10,[sp,#144]
    ldr x10,[x9,#88]
    str x10,[sp,#152]
    ldr x10,[x9,#96]
    str x10,[sp,#160]
    ldr x10,[x9,#104]
    str x10,[sp,#168]
    ldr x10,[x9,#112]
    str x10,[sp,#176]
    ldr x10,[x9,#120]
    str x10,[sp,#184]
    ldr x10,[x9,#128]
    str x10,[sp,#192]
    ldr x10,[x9,#136]
    str x10,[sp,#200]
    ldr x10,[x9,#144]
    str x10,[sp,#208]
    ldr x10,[x9,#152]
    str x10,[sp,#216]
    ldr x10,[x9,#160]
    str x10,[sp,#224]
    ldr x10,[x9,#168]
    str x10,[sp,#232]
    ldr x10,[x9,#176]
    str x10,[sp,#240]
    ldr x10,[x9,#184]
    str x10,[sp,#248]
    ldr x10,[x9,#192]
    str x10,[sp,#256]
    ldr x10,[x9,#200]
    str x10,[sp,#264]
    ldr x10,[x9,#208]
    str x10,[sp,#272]
    ldr x10,[x9,#216]
    str x10,[sp,#280]
    ldr x10,[x9,#224]
    str x10,[sp,#288]
    ldr x10,[x9,#232]
    str x10,[sp,#296]
    ldr x10,[x9,#240]
    str x10,[sp,#304]
    ldr x10,[x9,#248]
    str x10,[sp,#312]
    ldr x10,[x9,#256]
    str x10,[sp,#320]
    ldr x10,[x9,#264]
    str x10,[sp,#328]
    ldr x10,[x9,#272]
    str x10,[sp,#336]
    ldr x10,[x9,#280]
    str x10,[sp,#344]
    ldr x10,[x9,#288]
    str x10,[sp,#352]
    ldrsw x19,[x0]
    ldrsw x20,[x1]
    cmp x19,x20
    b.gt .Lreturn
    ldrsw x21,[x3]
    sub x19,x19,#1
    sub x20,x20,#1
    ldp x23,x24,[sp,#328]
    ldp x25,x26,[sp,#344]
    ldr x9,[sp,#176]
    ldp x10,x11,[x9,#72]
    sub x22,x11,x10
    add x22,x22,#1
    fmov d16,#1.0
    fmov d17,xzr
.Lrow:
    ldr x9,[sp,#40]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    ldr d0,[x10,x11,lsl #3]
    fcvtas w14,d0
    ldr x9,[sp,#240]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    str w14,[x10,x11,lsl #2]
    ldr x9,[sp,#48]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    ldr d0,[x10,x11,lsl #3]
    fcvtas w14,d0
    ldr x9,[sp,#248]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    str w14,[x10,x11,lsl #2]
    ldr x9,[sp,#56]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    ldr d0,[x10,x11,lsl #3]
    fcvtas w14,d0
    ldr x9,[sp,#256]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    str w14,[x10,x11,lsl #2]
    ldr x9,[sp,#64]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    ldr d0,[x10,x11,lsl #3]
    fcvtas w14,d0
    ldr x9,[sp,#264]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    str w14,[x10,x11,lsl #2]
    ldr w14,[x24,#752]
    cbz w14,.Llai_table
    ldr d0,[x24,#744]
    fcmp d0,d17
    b.le .Llai_climate
    ldr x9,[sp,#120]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    ldr d21,[x10,x11,lsl #3]
    ldr x9,[sp,#128]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    ldr d22,[x10,x11,lsl #3]
    b .Llai_ready
.Llai_climate:
    ldr x9,[sp,#104]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    ldr d21,[x10,x11,lsl #3]
    ldr x9,[sp,#112]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    ldr d22,[x10,x11,lsl #3]
    b .Llai_ready
.Llai_table:
    ldr x9,[sp,#240]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    ldr w14,[x10,x11,lsl #2]
    add x9,x24,#72
    ldr x10,[x9]
    ldr x11,[x9,#40]
    ldr x12,[x9,#48]
    sxtw x14,w14
    sub x14,x14,x12
    mul x14,x14,x11
    ldr d21,[x10,x14,lsl #3]
    ldr x9,[sp,#256]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    ldr w14,[x10,x11,lsl #2]
    add x9,x24,#72
    ldr x10,[x9]
    ldr x11,[x9,#40]
    ldr x12,[x9,#48]
    sxtw x14,w14
    sub x14,x14,x12
    mul x14,x14,x11
    ldr d22,[x10,x14,lsl #3]
.Llai_ready:
    ldr x9,[sp,#296]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    str d21,[x10,x11,lsl #3]
    ldr x9,[sp,#304]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    str d22,[x10,x11,lsl #3]
    ldr x9,[sp,#240]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    ldr w14,[x10,x11,lsl #2]
    add x9,x24,#8
    ldr x10,[x9]
    ldr x11,[x9,#40]
    ldr x12,[x9,#48]
    sxtw x14,w14
    sub x14,x14,x12
    mul x14,x14,x11
    ldr d18,[x10,x14,lsl #3]
    ldr x9,[sp,#80]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    ldr d0,[x10,x11,lsl #3]
    fmul d18,d0,d18
    ldr x9,[sp,#272]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    str d18,[x10,x11,lsl #3]
    ldr x9,[sp,#256]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    ldr w14,[x10,x11,lsl #2]
    add x9,x24,#8
    ldr x10,[x9]
    ldr x11,[x9,#40]
    ldr x12,[x9,#48]
    sxtw x14,w14
    sub x14,x14,x12
    mul x14,x14,x11
    ldr d19,[x10,x14,lsl #3]
    ldr x9,[sp,#88]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    ldr d0,[x10,x11,lsl #3]
    fmul d19,d0,d19
    ldr x9,[sp,#280]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    str d19,[x10,x11,lsl #3]
    ldr x9,[sp,#96]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    ldr d20,[x10,x11,lsl #3]
    fcmp d20,d17
    b.lt .Lurban_zero
    fcmp d20,d16
    b.le .Lurban_ready
.Lurban_zero:
    fmov d20,d17
.Lurban_ready:
    ldr x9,[sp,#288]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    str d20,[x10,x11,lsl #3]
    ldr x9,[sp,#136]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    ldr d0,[x10,x11,lsl #3]
    fmov d1,#0.5
    fcmp d0,d1
    cset w14,gt
    ldr x9,[sp,#200]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    str w14,[x10,x11,lsl #2]
    ldr w14,[x25,#848]
    cbz w14,.Llake_flag_zero
    ldr x9,[sp,#200]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    ldr w14,[x10,x11,lsl #2]
    cbnz w14,.Llake_flag_one
    ldr x9,[sp,#152]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    ldr d0,[x10,x11,lsl #3]
    fmov d1,#0.5
    fcmp d0,d1
    cset w14,gt
    b .Llake_flag_ready
.Llake_flag_zero:
    mov w14,#0
    b .Llake_flag_ready
.Llake_flag_one:
    mov w14,#1
.Llake_flag_ready:
    ldr x9,[sp,#216]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    str w14,[x10,x11,lsl #2]
    ldr x9,[sp,#200]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    ldr w14,[x10,x11,lsl #2]
    cbnz w14,.Lsea_flag_zero
    ldr x9,[sp,#216]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    ldr w14,[x10,x11,lsl #2]
    cbnz w14,.Lsea_flag_zero
    ldr x9,[sp,#144]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    ldr d0,[x10,x11,lsl #3]
    ldr d1,[x23,#288]
    fcmp d0,d1
    cset w14,gt
    b .Lsea_flag_ready
.Lsea_flag_zero:
    mov w14,#0
.Lsea_flag_ready:
    ldr x9,[sp,#208]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    str w14,[x10,x11,lsl #2]
    ldr x9,[sp,#168]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    ldr d0,[x10,x11,lsl #3]
    fcmp d0,d17
    cset w14,gt
    ldr x9,[sp,#224]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    str w14,[x10,x11,lsl #2]
    ldr w14,[x26,#24]
    cbz w14,.Locean_ready
    ldr x9,[sp,#200]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    ldr w14,[x10,x11,lsl #2]
    mov w28,w14
    ldr x9,[sp,#216]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    ldr w14,[x10,x11,lsl #2]
    orr w14,w14,w28
    cmp w14,#0
    cset w14,eq
.Locean_ready:
    ldr x9,[sp,#232]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    str w14,[x10,x11,lsl #2]
    fmov d23,d17
    mov x27,#0
    ldr w28,[x23,#448]
.Lsnow_sum:
    cmp x27,x22
    b.ge .Lsnow_sum_done
    ldr x9,[sp,#176]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    ldr x13,[x9,#64]
    mul x15,x27,x13
    add x11,x11,x15
    ldr d0,[x10,x11,lsl #3]
    cbz w28,.Lsnow_mass_add
    ldr x9,[sp,#192]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    ldr x13,[x9,#64]
    mul x15,x27,x13
    add x11,x11,x15
    ldr d1,[x10,x11,lsl #3]
    fdiv d0,d0,d1
.Lsnow_mass_add:
    fadd d23,d23,d0
    add x27,x27,#1
    b .Lsnow_sum
.Lsnow_sum_done:
    cbz w28,.Lsnow_scale
    mov x9,#0x4059000000000000
    fmov d0,x9
    fmul d23,d0,d23
.Lsnow_scale:
    ldr d0,[x23,#184]
    fmul d23,d23,d0
    fminnm d23,d16,d23
    fmaxnm d23,d17,d23
    fsub d0,d16,d18
    fsub d0,d0,d19
    fmul d1,d18,d21
    fadd d0,d0,d1
    fmul d1,d19,d22
    fadd d0,d0,d1
    ldr d1,[x23,#192]
    fmul d0,d1,d0
    ldr x9,[sp,#312]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    str d0,[x10,x11,lsl #3]
    ldr x9,[sp,#184]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    ldr d1,[x10,x11,lsl #3]
    fdiv d24,d1,d0
    fminnm d24,d16,d24
    fmaxnm d24,d17,d24
    ldr x9,[sp,#160]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    ldr d0,[x10,x11,lsl #3]
    ldr d1,[x25,#192]
    fcmp d0,d1
    b.le .Lice_zero
    fmov d1,#10.0
    fmul d26,d0,d1
    fminnm d26,d16,d26
    fmaxnm d26,d17,d26
    b .Lice_ready
.Lice_zero:
    fmov d26,d17
.Lice_ready:
    mov x27,#0
.Lzero_tiles:
    cmp x27,x21
    b.ge .Lpartition
    ldr x9,[sp,#320]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    mov x12,x27
    ldr x13,[x9,#64]
    mul x15,x12,x13
    add x11,x11,x15
    str d17,[x10,x11,lsl #3]
    add x27,x27,#1
    b .Lzero_tiles
.Lpartition:
    ldr w14,[x25,#848]
    cbz w14,.Lno_lake
    ldr x9,[sp,#200]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    ldr w14,[x10,x11,lsl #2]
    mov w28,w14
    ldr x9,[sp,#216]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    ldr w14,[x10,x11,lsl #2]
    orr w14,w14,w28
    cbnz w14,.Llake_land
    ldr x9,[sp,#208]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    ldr w14,[x10,x11,lsl #2]
    cbz w14,.Lwater_all
    ldr x9,[sp,#144]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    ldr d0,[x10,x11,lsl #3]
    ldr d1,[x23,#288]
    fmaxnm d0,d1,d0
    fminnm d0,d0,d16
    ldr x9,[sp,#320]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    mov x12,#1
    ldr x13,[x9,#64]
    mul x15,x12,x13
    add x11,x11,x15
    str d0,[x10,x11,lsl #3]
    fsub d1,d16,d0
    ldr x9,[sp,#320]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    mov x12,#0
    ldr x13,[x9,#64]
    mul x15,x12,x13
    add x11,x11,x15
    str d1,[x10,x11,lsl #3]
    b .Lscreen
.Lwater_all:
    ldr x9,[sp,#320]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    mov x12,#0
    ldr x13,[x9,#64]
    mul x15,x12,x13
    add x11,x11,x15
    str d16,[x10,x11,lsl #3]
    b .Lscreen
.Llake_land:
    ldr x9,[sp,#216]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    ldr w14,[x10,x11,lsl #2]
    cbz w14,.Llake_fraction_zero
    ldr x9,[sp,#200]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    ldr w14,[x10,x11,lsl #2]
    cbnz w14,.Llake_fraction_field
    fmov d25,d16
    b .Llake_fraction_ready
.Llake_fraction_field:
    ldr x9,[sp,#152]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    ldr d25,[x10,x11,lsl #3]
    b .Llake_fraction_ready
.Llake_fraction_zero:
    fmov d25,d17
.Llake_fraction_ready:
    cmp x21,#9
    b.le .Lurban_cap_ready
    fadd d0,d25,d20
    fcmp d0,d16
    b.le .Lurban_cap_ready
    fsub d20,d16,d25
    ldr x9,[sp,#288]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    str d20,[x10,x11,lsl #3]
.Lurban_cap_ready:
    fsub d0,d16,d25
    fmul d27,d18,d0
    fmul d28,d19,d0
    fsub d29,d16,d27
    fsub d29,d29,d28
    fsub d29,d29,d25
    fsub d0,d16,d23
    fmul d1,d24,d0
    fadd d2,d27,d28
    fadd d2,d2,d29
    fmul d2,d1,d2
    ldr x9,[sp,#320]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    mov x12,#2
    ldr x13,[x9,#64]
    mul x15,x12,x13
    add x11,x11,x15
    str d2,[x10,x11,lsl #3]
    fsub d0,d16,d23
    fsub d1,d16,d24
    fmul d2,d27,d0
    fmul d2,d2,d1
    ldr x9,[sp,#320]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    mov x12,#3
    ldr x13,[x9,#64]
    mul x15,x12,x13
    add x11,x11,x15
    str d2,[x10,x11,lsl #3]
    fadd d0,d29,d27
    fmul d2,d23,d0
    ldr x9,[sp,#320]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    mov x12,#4
    ldr x13,[x9,#64]
    mul x15,x12,x13
    add x11,x11,x15
    str d2,[x10,x11,lsl #3]
    fsub d0,d16,d23
    fsub d1,d16,d24
    fmul d2,d28,d0
    fmul d2,d2,d1
    ldr x9,[sp,#320]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    mov x12,#5
    ldr x13,[x9,#64]
    mul x15,x12,x13
    add x11,x11,x15
    str d2,[x10,x11,lsl #3]
    fmul d2,d23,d28
    ldr x9,[sp,#320]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    mov x12,#6
    ldr x13,[x9,#64]
    mul x15,x12,x13
    add x11,x11,x15
    str d2,[x10,x11,lsl #3]
    fsub d0,d16,d23
    fsub d1,d16,d24
    fmul d2,d29,d0
    fmul d2,d2,d1
    ldr x9,[sp,#320]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    mov x12,#7
    ldr x13,[x9,#64]
    mul x15,x12,x13
    add x11,x11,x15
    str d2,[x10,x11,lsl #3]
    ldr x9,[sp,#216]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    ldr w14,[x10,x11,lsl #2]
    cbz w14,.Llake_all
    ldr x9,[sp,#160]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    ldr d0,[x10,x11,lsl #3]
    ldr d1,[x25,#192]
    fcmp d0,d1
    b.le .Llake_all
    fmul d0,d25,d26
    ldr x9,[sp,#320]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    mov x12,#8
    ldr x13,[x9,#64]
    mul x15,x12,x13
    add x11,x11,x15
    str d0,[x10,x11,lsl #3]
    fsub d1,d16,d26
    fmul d1,d25,d1
    ldr x9,[sp,#320]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    mov x12,#0
    ldr x13,[x9,#64]
    mul x15,x12,x13
    add x11,x11,x15
    str d1,[x10,x11,lsl #3]
    b .Llake_urban
.Llake_all:
    ldr x9,[sp,#320]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    mov x12,#8
    ldr x13,[x9,#64]
    mul x15,x12,x13
    add x11,x11,x15
    str d25,[x10,x11,lsl #3]
.Llake_urban:
    cmp x21,#9
    b.le .Lscreen
    fsub d0,d16,d25
    fsub d0,d0,d20
    fmul d27,d18,d0
    fmul d28,d19,d0
    fsub d29,d16,d27
    fsub d29,d29,d28
    fsub d29,d29,d25
    fsub d29,d29,d20
    fsub d0,d16,d23
    fmul d1,d24,d0
    fadd d2,d27,d28
    fadd d2,d2,d29
    fadd d2,d2,d20
    fmul d2,d1,d2
    ldr x9,[sp,#320]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    mov x12,#2
    ldr x13,[x9,#64]
    mul x15,x12,x13
    add x11,x11,x15
    str d2,[x10,x11,lsl #3]
    fsub d0,d16,d23
    fsub d1,d16,d24
    fmul d2,d27,d0
    fmul d2,d2,d1
    ldr x9,[sp,#320]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    mov x12,#3
    ldr x13,[x9,#64]
    mul x15,x12,x13
    add x11,x11,x15
    str d2,[x10,x11,lsl #3]
    fadd d0,d29,d27
    fmul d2,d23,d0
    ldr x9,[sp,#320]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    mov x12,#4
    ldr x13,[x9,#64]
    mul x15,x12,x13
    add x11,x11,x15
    str d2,[x10,x11,lsl #3]
    fsub d0,d16,d23
    fsub d1,d16,d24
    fmul d2,d28,d0
    fmul d2,d2,d1
    ldr x9,[sp,#320]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    mov x12,#5
    ldr x13,[x9,#64]
    mul x15,x12,x13
    add x11,x11,x15
    str d2,[x10,x11,lsl #3]
    fadd d0,d28,d20
    fmul d2,d23,d0
    ldr x9,[sp,#320]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    mov x12,#6
    ldr x13,[x9,#64]
    mul x15,x12,x13
    add x11,x11,x15
    str d2,[x10,x11,lsl #3]
    fsub d0,d16,d23
    fsub d1,d16,d24
    fmul d2,d29,d0
    fmul d2,d2,d1
    ldr x9,[sp,#320]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    mov x12,#7
    ldr x13,[x9,#64]
    mul x15,x12,x13
    add x11,x11,x15
    str d2,[x10,x11,lsl #3]
    fsub d0,d16,d23
    fsub d1,d16,d24
    fmul d2,d20,d0
    fmul d2,d2,d1
    ldr x9,[sp,#320]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    mov x12,#9
    ldr x13,[x9,#64]
    mul x15,x12,x13
    add x11,x11,x15
    str d2,[x10,x11,lsl #3]
    b .Lscreen
.Lno_lake:
    ldr x9,[sp,#200]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    ldr w14,[x10,x11,lsl #2]
    cbnz w14,.Ldry_land
    ldr x9,[sp,#208]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    ldr w14,[x10,x11,lsl #2]
    cbz w14,.Lwater_all
    ldr x9,[sp,#144]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    ldr d0,[x10,x11,lsl #3]
    ldr d1,[x23,#288]
    fmaxnm d0,d1,d0
    ldr x9,[sp,#320]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    mov x12,#1
    ldr x13,[x9,#64]
    mul x15,x12,x13
    add x11,x11,x15
    str d0,[x10,x11,lsl #3]
    fsub d1,d16,d0
    ldr x9,[sp,#320]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    mov x12,#0
    ldr x13,[x9,#64]
    mul x15,x12,x13
    add x11,x11,x15
    str d1,[x10,x11,lsl #3]
    b .Lscreen
.Ldry_land:
    fsub d0,d16,d19
    fmul d2,d23,d0
    ldr x9,[sp,#320]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    mov x12,#4
    ldr x13,[x9,#64]
    mul x15,x12,x13
    add x11,x11,x15
    str d2,[x10,x11,lsl #3]
    fmul d2,d23,d19
    ldr x9,[sp,#320]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    mov x12,#6
    ldr x13,[x9,#64]
    mul x15,x12,x13
    add x11,x11,x15
    str d2,[x10,x11,lsl #3]
    fsub d0,d16,d23
    fmul d2,d0,d24
    ldr x9,[sp,#320]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    mov x12,#2
    ldr x13,[x9,#64]
    mul x15,x12,x13
    add x11,x11,x15
    str d2,[x10,x11,lsl #3]
    fsub d0,d16,d23
    fsub d1,d16,d24
    fmul d2,d18,d0
    fmul d2,d2,d1
    ldr x9,[sp,#320]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    mov x12,#3
    ldr x13,[x9,#64]
    mul x15,x12,x13
    add x11,x11,x15
    str d2,[x10,x11,lsl #3]
    fsub d0,d16,d23
    fsub d1,d16,d24
    fmul d2,d19,d0
    fmul d2,d2,d1
    ldr x9,[sp,#320]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    mov x12,#5
    ldr x13,[x9,#64]
    mul x15,x12,x13
    add x11,x11,x15
    str d2,[x10,x11,lsl #3]
    fsub d29,d16,d18
    fsub d29,d29,d19
    fsub d0,d16,d23
    fsub d1,d16,d24
    fmul d2,d29,d0
    fmul d2,d2,d1
    ldr x9,[sp,#320]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    mov x12,#7
    ldr x13,[x9,#64]
    mul x15,x12,x13
    add x11,x11,x15
    str d2,[x10,x11,lsl #3]
    cmp x21,#9
    b.le .Lscreen
    fsub d0,d16,d20
    fmul d27,d18,d0
    fmul d28,d19,d0
    fadd d1,d28,d20
    fsub d0,d16,d1
    fmul d2,d23,d0
    ldr x9,[sp,#320]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    mov x12,#4
    ldr x13,[x9,#64]
    mul x15,x12,x13
    add x11,x11,x15
    str d2,[x10,x11,lsl #3]
    fmul d2,d23,d1
    ldr x9,[sp,#320]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    mov x12,#6
    ldr x13,[x9,#64]
    mul x15,x12,x13
    add x11,x11,x15
    str d2,[x10,x11,lsl #3]
    fsub d0,d16,d23
    fsub d1,d16,d24
    fmul d2,d27,d0
    fmul d2,d2,d1
    ldr x9,[sp,#320]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    mov x12,#3
    ldr x13,[x9,#64]
    mul x15,x12,x13
    add x11,x11,x15
    str d2,[x10,x11,lsl #3]
    fsub d0,d16,d23
    fsub d1,d16,d24
    fmul d2,d28,d0
    fmul d2,d2,d1
    ldr x9,[sp,#320]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    mov x12,#5
    ldr x13,[x9,#64]
    mul x15,x12,x13
    add x11,x11,x15
    str d2,[x10,x11,lsl #3]
    fsub d29,d16,d27
    fsub d29,d29,d28
    fsub d29,d29,d20
    fsub d0,d16,d23
    fsub d1,d16,d24
    fmul d2,d29,d0
    fmul d2,d2,d1
    ldr x9,[sp,#320]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    mov x12,#7
    ldr x13,[x9,#64]
    mul x15,x12,x13
    add x11,x11,x15
    str d2,[x10,x11,lsl #3]
    fsub d0,d16,d23
    fsub d1,d16,d24
    fmul d2,d20,d0
    fmul d2,d2,d1
    ldr x9,[sp,#320]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    mov x12,#9
    ldr x13,[x9,#64]
    mul x15,x12,x13
    add x11,x11,x15
    str d2,[x10,x11,lsl #3]
.Lscreen:
    ldr d31,[x23,#432]
    fcmp d31,d17
    b.le .Larea_check
    fmov d0,d17
    mov x27,#0
.Lscreen_sum:
    cmp x27,x21
    b.ge .Lnormalise_start
    ldr x9,[sp,#320]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    mov x12,x27
    ldr x13,[x9,#64]
    mul x15,x12,x13
    add x11,x11,x15
    ldr d1,[x10,x11,lsl #3]
    fcmp d1,d31
    b.ge .Lretain
    fmov d1,d17
    ldr x9,[sp,#320]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    mov x12,x27
    ldr x13,[x9,#64]
    mul x15,x12,x13
    add x11,x11,x15
    str d1,[x10,x11,lsl #3]
.Lretain:
    fadd d0,d0,d1
    add x27,x27,#1
    b .Lscreen_sum
.Lnormalise_start:
    mov x27,#0
.Lnormalise:
    cmp x27,x21
    b.ge .Larea_check
    ldr x9,[sp,#320]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    mov x12,x27
    ldr x13,[x9,#64]
    mul x15,x12,x13
    add x11,x11,x15
    ldr d1,[x10,x11,lsl #3]
    fdiv d1,d1,d0
    ldr x9,[sp,#320]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    mov x12,x27
    ldr x13,[x9,#64]
    mul x15,x12,x13
    add x11,x11,x15
    str d1,[x10,x11,lsl #3]
    add x27,x27,#1
    b .Lnormalise
.Larea_check:
    fsub d0,d16,d18
    fsub d0,d0,d19
    fcmp d0,d17
    b.lt .Lbad_physics
    fmov d0,d17
    mov x27,#0
.Larea_sum:
    cmp x27,x21
    b.ge .Larea_bound
    ldr x9,[sp,#320]
    ldr x10,[x9]
    ldr x11,[x9,#40]
    mov x12,#1
    cmp x11,#0
    csel x11,x11,x12,ne
    mul x11,x19,x11
    mov x12,x27
    ldr x13,[x9,#64]
    mul x15,x12,x13
    add x11,x11,x15
    ldr d1,[x10,x11,lsl #3]
    fcmp d1,d17
    b.lt .Lbad_physics
    fadd d0,d0,d1
    add x27,x27,#1
    b .Larea_sum
.Larea_bound:
    adr x9,.Larea_limit
    ldr d1,[x9]
    fcmp d0,d1
    b.gt .Lbad_physics
    add x19,x19,#1
    cmp x19,x20
    b.le .Lrow
.Lreturn:
    ldp x19,x20,[sp,#360]
    ldp x21,x22,[sp,#376]
    ldp x23,x24,[sp,#392]
    ldp x25,x26,[sp,#408]
    ldp x27,x28,[sp,#424]
    ldp x29,x30,[sp,#440]
    add sp,sp,#464
.Lquick_return:
    ret
.Lbad_physics:
    bl abort
    brk #0
.size md2asm_surface_tile_boundary,.-md2asm_surface_tile_boundary
.size ORIGINAL_SYMBOL,.-ORIGINAL_SYMBOL
.p2align 3
.Larea_limit:
    .quad 0x3ff028f5c28f5c29
.section .note.GNU-stack,"",%progbits
