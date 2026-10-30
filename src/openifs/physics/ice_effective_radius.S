/* Direct body from formulations/openifs/physics/ice_particle_radius.md.
 * Contract skills/md2asm/references/openifs/physics/ice_particle_radius.md.
 * Fourteen GNU Fortran addresses. Output radius is in micrometres.
 */
#ifndef ICE_RADIUS_SYMBOL
#define ICE_RADIUS_SYMBOL ice_effective_radius_
#endif
.text
.p2align 4
.global ICE_RADIUS_SYMBOL
.type ICE_RADIUS_SYMBOL,%function
ICE_RADIUS_SYMBOL:
    sub sp,sp,#448
    stp x29,x30,[sp]
    mov x29,sp
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    stp d8,d9,[sp,#96]
    stp d10,d11,[sp,#112]
    stp d12,d13,[sp,#128]
    stp d14,d15,[sp,#144]
    stp x0,x1,[sp,#160]
    stp x2,x3,[sp,#176]
    stp x4,x5,[sp,#192]
    stp x6,x7,[sp,#208]
    ldp x9,x10,[sp,#448]
    stp x9,x10,[sp,#224]
    ldp x9,x10,[sp,#464]
    stp x9,x10,[sp,#240]
    ldp x9,x10,[sp,#480]
    stp x9,x10,[sp,#256]
    mrs x9,fpcr
    cbnz x9,.Lice_bad
    ldr w20,[x2]
    ldr w21,[x3]
    ldr w19,[x4]
    ldr w22,[x5]
    cmp w19,#1
    b.lt .Lice_bad
    cmp w19,#2048
    b.gt .Lice_bad
    cmp w22,#1
    b.lt .Lice_bad
    cmp w22,#512
    b.gt .Lice_bad
    cmp w20,#1
    b.lt .Lice_bad
    add w9,w19,#1
    cmp w20,w9
    b.gt .Lice_bad
    cmp w21,#0
    b.lt .Lice_bad
    cmp w21,w19
    b.gt .Lice_bad
    mov x25,x0
    ldr w9,[x25,#116]
    cmp w9,#3
    b.hi .Lice_bad
    str w9,[x29,#272]
    cmp w20,w21
    b.gt .Lice_done
    sub w20,w20,#1
    adrp x26,.Lice_constants
    add x26,x26,:lo12:.Lice_constants
    ldr d8,[x25,#584]
    adrp x9,:got:__yomcst_MOD_rd
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rd]
    ldr d9,[x9]
    adrp x9,:got:__yomcst_MOD_rtt
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rtt]
    ldr d10,[x9]
    str wzr,[x29,#280]
    ldr x9,[x29,#168]
    ldr w10,[x9]
    cbz w10,.Lice_spp_done
    ldrsw x10,[x9,#568]
    cmp x10,#0
    b.le .Lice_spp_done
    ldr x11,[x9,#352]
    cbz x11,.Lice_bad
    ldr x12,[x9,#400]
    cmp x10,x12
    b.lt .Lice_bad
    ldr x12,[x9,#408]
    cmp x10,x12
    b.gt .Lice_bad
    ldr x12,[x9,#392]
    cmp x12,#1
    b.ne .Lice_bad
    ldr x12,[x9,#360]
    add x10,x10,x12
    mov x12,#184
    madd x28,x10,x12,x11
    ldr d0,[x28,#56]
    str d0,[x29,#320]
    ldr d0,[x28,#24]
    str d0,[x29,#328]
    ldr w10,[x29,#272]
    cmp w10,#3
    b.ne .Lice_spp_done
    ldrsw x10,[x28,#140]
    cmp x10,#1
    b.lt .Lice_bad
    ldrsw x11,[x9,#220]
    cmp x10,x11
    b.gt .Lice_bad
    sub x10,x10,#1
    mul x10,x10,x19
    ldr x11,[x29,#264]
    cbz x11,.Lice_bad
    add x11,x11,x10,lsl #3
    str x11,[x29,#336]
    mov w10,#1
    str w10,[x29,#280]
.Lice_spp_done:
    ldr w9,[x29,#272]
    cmp w9,#3
    b.ne .Lice_matrix
    /* Check the complete latitude domain before any output write. */
    lsl x9,x19,#3
    add x9,x9,#15
    and x9,x9,#-16
    sub sp,sp,x9
    mov x27,sp
    ldr w9,[x25,#164]
    str w9,[x29,#276]
    mov x24,x20
.Lice_minimum:
    ldr d0,[x25,#608]
    ldr w9,[x29,#276]
    cbz w9,.Lice_store_minimum
    /* D11 stores RMINICE while the two functions run. Both preserve it. */
    fmov d11,d0
    ldr x9,[x29,#248]
    ldr d0,[x9,x24,lsl #3]
    fmov x10,d0
    and x10,x10,#0x7fffffffffffffff
    mov x11,#0x3ff0000000000000
    cmp x10,x11
    b.hi .Lice_bad
    bl md2asm_asin_original_rounding
    bl md2asm_cos_original_rounding
    fmov d1,d0
    fmov d0,d11
    ldr d2,[x26,#8]
    fsub d0,d0,d2
    fmul d0,d0,d1
    fadd d0,d2,d0
.Lice_store_minimum:
    str d0,[x27,x24,lsl #3]
    add x24,x24,#1
    cmp x24,x21
    b.lt .Lice_minimum
.Lice_matrix:
    mov x23,#0
.Lice_level:
    mov x24,x20
.Lice_column:
    add x9,x23,x24
    ldr w10,[x29,#272]
    cbz w10,.Lice_fixed
    cmp w10,#3
    b.eq .Lice_ice_content
    ldr x10,[x29,#216]
    ldr d0,[x10,x9,lsl #3]
    fsub d0,d0,d10
    ldr d1,[x26,#48]
    fminnm d0,d0,d1
    ldr d2,[x26,#80]
    fmul d2,d0,d2
    ldr d3,[x26,#72]
    fadd d2,d3,d2
    fmul d2,d0,d2
    ldr d3,[x26,#64]
    fadd d2,d3,d2
    fmul d2,d0,d2
    ldr d3,[x26,#56]
    fadd d0,d3,d2
    ldr w10,[x29,#272]
    cmp w10,#1
    b.eq .Lice_temperature_one
    ldr d1,[x26,#32]
    ldr d2,[x26,#40]
    b .Lice_temperature_limit
.Lice_temperature_one:
    ldr d1,[x26]
    ldr d2,[x26,#24]
.Lice_temperature_limit:
    fmaxnm d0,d0,d1
    fminnm d0,d0,d2
    b .Lice_store
.Lice_fixed:
    ldr d0,[x26]
    b .Lice_store
.Lice_ice_content:
    ldr x10,[x29,#224]
    ldr d13,[x10,x9,lsl #3]
    ldr d0,[x26,#88]
    fcmp d13,d0
    b.le .Lice_clear
    b.vs .Lice_clear
    ldr x10,[x29,#232]
    ldr d12,[x10,x9,lsl #3]
    ldr x10,[x29,#240]
    ldr d0,[x10,x9,lsl #3]
    fadd d12,d12,d0
    fcmp d12,#0.0
    b.le .Lice_clear
    b.vs .Lice_clear
    ldr x10,[x29,#216]
    ldr d11,[x10,x9,lsl #3]
    ldr x10,[x29,#208]
    ldr d0,[x10,x9,lsl #3]
    ldr d1,[x26,#96]
    fmul d0,d1,d0
    fmul d1,d9,d11
    fdiv d0,d0,d1
    fmul d0,d0,d12
    fdiv d14,d0,d13
    fmov d0,d14
    ldr d1,[x26,#104]
    bl md2asm_pow_original_rounding_candidate
    ldr d1,[x26,#112]
    fmul d15,d1,d0
    fmov d0,d14
    ldr d1,[x26,#120]
    bl md2asm_pow_original_rounding_candidate
    ldr d1,[x26,#128]
    fmul d0,d1,d0
    ldr d1,[x26,#136]
    fsub d1,d11,d1
    fmul d0,d0,d1
    fadd d0,d15,d0
    fsub d1,d11,d10
    ldr d2,[x26,#152]
    fmul d1,d2,d1
    ldr d2,[x26,#144]
    fadd d1,d2,d1
    fmul d0,d1,d0
    ldr w10,[x29,#280]
    cbz w10,.Lice_diameter_limit
    str d0,[x29,#360]
    ldr x10,[x29,#336]
    ldr d0,[x10,x24,lsl #3]
    ldr d1,[x29,#328]
    fmul d0,d1,d0
    ldr d1,[x29,#320]
    fadd d0,d1,d0
    bl exp
    ldr d1,[x29,#360]
    fmul d0,d1,d0
.Lice_diameter_limit:
    ldr d1,[x27,x24,lsl #3]
    fmaxnm d0,d0,d1
    ldr d1,[x26,#160]
    fminnm d0,d0,d1
    fmul d0,d0,d8
    b .Lice_store_reindex
.Lice_clear:
    ldr d0,[x26,#16]
    fmul d0,d0,d8
.Lice_store_reindex:
    add x9,x23,x24
.Lice_store:
    ldr x10,[x29,#256]
    str d0,[x10,x9,lsl #3]
    add x24,x24,#1
    cmp x24,x21
    b.lt .Lice_column
    add x23,x23,x19
    mul x10,x19,x22
    cmp x23,x10
    b.lt .Lice_level
.Lice_done:
    mov sp,x29
    ldp d8,d9,[sp,#96]
    ldp d10,d11,[sp,#112]
    ldp d12,d13,[sp,#128]
    ldp d14,d15,[sp,#144]
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp x29,x30,[sp]
    add sp,sp,#448
    ret
.Lice_bad:
    brk #0x4ce
.size ICE_RADIUS_SYMBOL,.-ICE_RADIUS_SYMBOL
.section .rodata
.p2align 4
.Lice_constants:
    .double 40.0,20.0,80.0,130.0,30.0,60.0,-0.1,326.3
    .double 12.42,0.197,0.0012,0.001,1000.0,0.2214,45.8966,0.2535
    .double 0.7957,83.15,1.2351,0.0105,155.0,1.0
.section .note.GNU-stack,"",%progbits
