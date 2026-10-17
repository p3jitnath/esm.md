/* Complete shortwave independent-column cloud transport.
 * Physics is formulations/openifs/physics/shortwave_cloud_transport.md.
 * Contract is skills/md2asm/references/openifs/physics/solver_mcica_sw.md.
 * Sixteen addresses, genuine GNU objects, spectral-fast private arrays.
 * The complete four-child closure is privately bound. Each operation rounds. */
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL __radiation_mcica_sw_MOD_solver_mcica_sw
#endif
#ifdef MD2ASM_SW_PRIVATE_RANGE
#include "shortwave_team_layout.inc.S"
#endif
.text
.p2align 2
#ifdef MD2ASM_SW_PRIVATE_RANGE
.global SW_PRIVATE_PARENT
.hidden SW_PRIVATE_PARENT
.type SW_PRIVATE_PARENT,%function
SW_PRIVATE_PARENT:
#else
.global md2asm_solver_mcica_sw
.global ORIGINAL_SYMBOL
.type md2asm_solver_mcica_sw,%function
ORIGINAL_SYMBOL:
md2asm_solver_mcica_sw:
#endif
    mov x17,sp
    sub sp,sp,#1536
    stp x19,x20,[sp,#64]
    stp x21,x22,[sp,#80]
    stp x23,x24,[sp,#96]
    stp x25,x26,[sp,#112]
    stp x27,x28,[sp,#128]
    stp x29,x30,[sp,#144]
    stp d8,d9,[sp,#160]
    stp d10,d11,[sp,#176]
    stp d12,d13,[sp,#192]
    stp d14,d15,[sp,#208]
    mov x29,sp
    str x18,[x29,#1000]
    stp x0,x1,[x29,#256]
    stp x2,x3,[x29,#272]
    stp x4,x5,[x29,#288]
    stp x6,x7,[x29,#304]
    ldp x8,x9,[x17,#0]
    stp x8,x9,[x29,#320]
    ldp x8,x9,[x17,#16]
    stp x8,x9,[x29,#336]
    ldp x8,x9,[x17,#32]
    stp x8,x9,[x29,#352]
    ldp x8,x9,[x17,#48]
    stp x8,x9,[x29,#368]
    ldr w21,[x0]
    ldr w19,[x1]
    ldr w20,[x2]
    cmp w20,w19
    b.lt .Lmcica_return
    sub w19,w19,#1
    mov x25,x3
    mov x8,#19996
    ldr w22,[x25,x8]
    mov x8,#20004
    ldr w23,[x25,x8]
#ifdef MD2ASM_SW_PRIVATE_RANGE
    ldr w8,[x25,#628]
    str w8,[x29,#SW_PARENT_PRIVATE_DELTA_FLAG]
#else
    ldr w28,[x25,#628]
#endif
    ldr x24,[x29,#376]
    str w22,[x29,#600]
    str w21,[x29,#604]
    ldr x8,[x24,#240]
    str w8,[x29,#608]
#ifdef MD2ASM_SW_PRIVATE_RANGE
    ldr x8,[x29,#SW_PARENT_SAVED_CONTEXT]
    ldr x0,[x8,#SW_WORK_SCRATCH]
#else
    mul x8,x22,x21
    mov x9,#14
    mul x8,x8,x9
    mov x9,#11
    madd x8,x22,x9,x8
    mov x9,#3
    madd x8,x21,x9,x8
    lsl x0,x8,#3
    bl malloc
    cbz x0,.Lmcica_reject
#endif
    mov x26,x0
    mov x8,x0
    str x8,[x29,#400]
    mul x9,x22,x21
    add x8,x8,x9,lsl #3
    str x8,[x29,#408]
    mul x9,x22,x21
    add x8,x8,x9,lsl #3
    str x8,[x29,#416]
    mul x9,x22,x21
    add x8,x8,x9,lsl #3
    str x8,[x29,#424]
    mul x9,x22,x21
    add x8,x8,x9,lsl #3
    str x8,[x29,#432]
    mul x9,x22,x21
    add x8,x8,x9,lsl #3
    str x8,[x29,#440]
    mul x9,x22,x21
    add x8,x8,x9,lsl #3
    str x8,[x29,#448]
    mul x9,x22,x21
    add x8,x8,x9,lsl #3
    str x8,[x29,#456]
    mul x9,x22,x21
    add x8,x8,x9,lsl #3
    str x8,[x29,#464]
    mul x9,x22,x21
    add x8,x8,x9,lsl #3
    str x8,[x29,#472]
    mul x9,x22,x21
    add x8,x8,x9,lsl #3
    str x8,[x29,#480]
    add x9,x21,#1
    mul x9,x22,x9
    add x8,x8,x9,lsl #3
    str x8,[x29,#488]
    add x9,x21,#1
    mul x9,x22,x9
    add x8,x8,x9,lsl #3
    str x8,[x29,#496]
    add x9,x21,#1
    mul x9,x22,x9
    add x8,x8,x9,lsl #3
    str x8,[x29,#504]
    mul x9,x22,x21
    add x8,x8,x9,lsl #3
    str x8,[x29,#512]
    mov x9,x22
    add x8,x8,x9,lsl #3
    str x8,[x29,#520]
    mov x9,x22
    add x8,x8,x9,lsl #3
    str x8,[x29,#528]
    mov x9,x22
    add x8,x8,x9,lsl #3
    str x8,[x29,#536]
    mov x9,x22
    add x8,x8,x9,lsl #3
    str x8,[x29,#544]
    mov x9,x22
    add x8,x8,x9,lsl #3
    str x8,[x29,#552]
    mov x9,x22
    add x8,x8,x9,lsl #3
    str x8,[x29,#560]
    mov x9,x22
    add x8,x8,x9,lsl #3
    str x8,[x29,#568]
    mov x9,x22
    add x8,x8,x9,lsl #3
    str x8,[x29,#576]
    mov x9,x21
    add x8,x8,x9,lsl #3
    str x8,[x29,#584]
    mov x9,x21
    add x8,x8,x9,lsl #3
    str x8,[x29,#592]
    mov x9,x21
    add x8,x8,x9,lsl #3
    add x0,x29,#640
    ldr x1,[x29,#528]
    mov x2,x22
    bl .Lmcica_descriptor
    add x0,x29,#704
    ldr x1,[x29,#536]
    mov x2,x22
    bl .Lmcica_descriptor
    add x0,x29,#768
    ldr x1,[x29,#544]
    mov x2,x22
    bl .Lmcica_descriptor
    add x0,x29,#832
    ldr x1,[x29,#552]
    mov x2,x22
    bl .Lmcica_descriptor
    add x0,x29,#896
    ldr x1,[x29,#560]
    mov x2,x22
    bl .Lmcica_descriptor
#ifdef MD2ASM_SW_PRIVATE_RANGE
    ldr x8,[x29,#SW_PARENT_SAVED_CONTEXT]
    ldr x19,[x8,#SW_WORK_BEGIN]
    ldr x20,[x8,#SW_WORK_END]
    cmp w19,w20
    b.ge .Lmcica_return
#endif
.Lmcica_column:
    ldr x8,[x29,#264]
    ldr w8,[x8]
    sub w8,w8,#1
    sub w27,w19,w8
    str w27,[x29,#632]
    ldr x8,[x29,#288]
    ldr x8,[x8]
    ldr d0,[x8,x19,lsl #3]
    str d0,[x29,#616]
    fcmp d0,#0.0
    b.le .Lmcica_night
    ldr x8,[x29,#568]
    mov x9,#0
.Lmcica_cos_repeat:
    str d0,[x8,x9,lsl #3]
    add x9,x9,#1
    cmp x9,x22
    b.lt .Lmcica_cos_repeat
    str wzr,[x29,#1008]
.Lmcica_clear_layer:
    ldr w8,[x29,#1008]
    madd x9,x27,x21,x8
    mul x9,x9,x22
    lsl x9,x9,#3
    ldr x10,[x29,#304]
    add x10,x10,x9
    ldr x11,[x29,#520]
    mov x12,#0
.Lmcica_clear_copy6:
    ldr d0,[x10,x12,lsl #3]
    str d0,[x11,x12,lsl #3]
    add x12,x12,#1
    cmp x12,x22
    b.lt .Lmcica_clear_copy6
    ldr x10,[x29,#312]
    add x10,x10,x9
    ldr x11,[x29,#528]
    mov x12,#0
.Lmcica_clear_copy7:
    ldr d0,[x10,x12,lsl #3]
    str d0,[x11,x12,lsl #3]
    add x12,x12,#1
    cmp x12,x22
    b.lt .Lmcica_clear_copy7
    ldr x10,[x29,#320]
    add x10,x10,x9
    ldr x11,[x29,#536]
    mov x12,#0
.Lmcica_clear_copy8:
    ldr d0,[x10,x12,lsl #3]
    str d0,[x11,x12,lsl #3]
    add x12,x12,#1
    cmp x12,x22
    b.lt .Lmcica_clear_copy8
#ifdef MD2ASM_SW_PRIVATE_RANGE
    ldr w8,[x29,#SW_PARENT_PRIVATE_DELTA_FLAG]
    cbz w8,.Lmcica_clear_scaled
#else
    cbz w28,.Lmcica_clear_scaled
#endif
    ldr x0,[x29,#520]
    ldr x1,[x29,#528]
    ldr x2,[x29,#536]
    mov w3,w22
    bl .Lmcica_delta
.Lmcica_clear_scaled:
    ldr w0,[x29,#1008]
    mov w1,#0
    bl .Lmcica_layer
    ldr w8,[x29,#1008]
    add w8,w8,#1
    str w8,[x29,#1008]
    cmp w8,w21
    b.lt .Lmcica_clear_layer
    mov w0,#0
    bl .Lmcica_add
    mov w0,#0
    bl .Lmcica_store
    ldr x8,[x29,#296]
    ldr x10,[x8,#352]
    ldr x11,[x8,#416]
    add x10,x10,x19,lsl #3
    ldr x12,[x29,#576]
    mov x13,#0
    sub x14,x21,#0
    cbz x14,.Lmcica_row_done22
.Lmcica_row22:
    ldr d0,[x10]
    str d0,[x12,x13,lsl #3]
    add x10,x10,x11,lsl #3
    add x13,x13,#1
    cmp x13,x14
    b.lt .Lmcica_row22
.Lmcica_row_done22:
    ldr x8,[x29,#296]
    ldr x10,[x8,#440]
    ldr x11,[x8,#504]
    add x10,x10,x19,lsl #3
    ldr x12,[x29,#592]
    mov x13,#0
    sub x14,x21,#0
    cbz x14,.Lmcica_row_done24
.Lmcica_row24:
    ldr d0,[x10]
    str d0,[x12,x13,lsl #3]
    add x10,x10,x11,lsl #3
    add x13,x13,#1
    cmp x13,x14
    b.lt .Lmcica_row24
.Lmcica_row_done24:
    ldr x8,[x29,#296]
    ldr x10,[x8,#704]
    ldr x11,[x8,#768]
    add x10,x10,x19,lsl #3
    ldr x12,[x29,#584]
    mov x13,#0
    sub x14,x21,#1
    cbz x14,.Lmcica_row_done23
.Lmcica_row23:
    ldr d0,[x10]
    str d0,[x12,x13,lsl #3]
    add x10,x10,x11,lsl #3
    add x13,x13,#1
    cmp x13,x14
    b.lt .Lmcica_row23
.Lmcica_row_done23:
    add x0,x29,#600
    add x1,x29,#604
    add x2,x25,#536
    ldr x3,[x29,#288]
    ldr x3,[x3,#552]
    add x3,x3,x19,lsl #2
    add x4,x25,#520
    ldr x5,[x29,#576]
    ldr x6,[x29,#584]
    add x7,x25,#552
    ldr x8,[x29,#592]
    str x8,[sp,#0]
    mov x8,#17840
    add x8,x25,x8
    str x8,[sp,#8]
    ldr x8,[x29,#504]
    str x8,[sp,#16]
    add x8,x29,#624
    str x8,[sp,#24]
    add x8,x25,#540
    str x8,[sp,#32]
#ifdef MD2ASM_SW_PRIVATE_RANGE
    bl SW_PRIVATE_GENERATOR
#else
    bl md2asm_cloud_generator
#endif
    ldr x8,[x24,#3208]
    ldr d0,[x29,#624]
    str d0,[x8,x19,lsl #3]
    ldr d1,[x25,#520]
    fcmp d0,d1
    b.lt .Lmcica_no_cloud
    str wzr,[x29,#1008]
.Lmcica_cloud_layer:
    ldr w8,[x29,#1008]
    ldr x9,[x29,#576]
    ldr d0,[x9,x8,lsl #3]
    ldr d1,[x25,#520]
    fcmp d0,d1
    b.lt .Lmcica_copy_clear_layer
    madd x9,x27,x21,x8
    mul x10,x9,x22
    lsl x10,x10,#3
    mul x11,x9,x23
    lsl x11,x11,#3
    mul x12,x8,x22
    lsl x12,x12,#3
    mov x13,#0
    mov x8,#10928
    ldr x14,[x25,x8]
.Lmcica_mix:
    ldr x0,[x29,#304]
    add x0,x0,x10
    ldr d0,[x0,x13,lsl #3]
    ldr x0,[x29,#312]
    add x0,x0,x10
    ldr d1,[x0,x13,lsl #3]
    ldr x0,[x29,#320]
    add x0,x0,x10
    ldr d2,[x0,x13,lsl #3]
    ldr w15,[x14,x13,lsl #2]
    sub w15,w15,#1
    ldr x0,[x29,#328]
    add x0,x0,x11
    ldr d3,[x0,x15,lsl #3]
    ldr x0,[x29,#336]
    add x0,x0,x11
    ldr d4,[x0,x15,lsl #3]
    ldr x0,[x29,#344]
    add x0,x0,x11
    ldr d5,[x0,x15,lsl #3]
    ldr x0,[x29,#504]
    add x0,x0,x12
    ldr d6,[x0,x13,lsl #3]
    fmul d3,d6,d3
    ldr x0,[x29,#512]
    str d3,[x0,x13,lsl #3]
    fadd d6,d0,d3
    ldr x0,[x29,#520]
    str d6,[x0,x13,lsl #3]
    fmov d7,xzr
    fcmp d6,#0.0
    b.le .Lmcica_zero_scattering
    fmul d7,d1,d0
    fmul d16,d4,d3
    fadd d7,d7,d16
    fdiv d7,d7,d6
.Lmcica_zero_scattering:
    ldr x0,[x29,#528]
    str d7,[x0,x13,lsl #3]
    fmul d16,d7,d6
    fmov d7,xzr
    fcmp d16,#0.0
    b.le .Lmcica_zero_direction
    fmul d7,d2,d1
    fmul d7,d7,d0
    fmul d17,d5,d4
    fmul d17,d17,d3
    fadd d7,d7,d17
    fdiv d7,d7,d16
.Lmcica_zero_direction:
    ldr x0,[x29,#536]
    str d7,[x0,x13,lsl #3]
    add x13,x13,#1
    cmp x13,x22
    b.lt .Lmcica_mix
#ifdef MD2ASM_SW_PRIVATE_RANGE
    ldr w8,[x29,#SW_PARENT_PRIVATE_DELTA_FLAG]
    cbz w8,.Lmcica_cloud_scaled
#else
    cbz w28,.Lmcica_cloud_scaled
#endif
    ldr x0,[x29,#520]
    ldr x1,[x29,#528]
    ldr x2,[x29,#536]
    mov w3,w22
    bl .Lmcica_delta
.Lmcica_cloud_scaled:
    ldr w0,[x29,#1008]
    mov w1,#5
    bl .Lmcica_layer
    b .Lmcica_cloud_next
.Lmcica_copy_clear_layer:
    mul x9,x8,x22
    lsl x9,x9,#3
    ldr x10,[x29,#400]
    ldr x11,[x29,#440]
    add x10,x10,x9
    add x11,x11,x9
    mov x12,#0
.Lmcica_copy_layer0:
    ldr d0,[x10,x12,lsl #3]
    str d0,[x11,x12,lsl #3]
    add x12,x12,#1
    cmp x12,x22
    b.lt .Lmcica_copy_layer0
    ldr x10,[x29,#408]
    ldr x11,[x29,#448]
    add x10,x10,x9
    add x11,x11,x9
    mov x12,#0
.Lmcica_copy_layer1:
    ldr d0,[x10,x12,lsl #3]
    str d0,[x11,x12,lsl #3]
    add x12,x12,#1
    cmp x12,x22
    b.lt .Lmcica_copy_layer1
    ldr x10,[x29,#416]
    ldr x11,[x29,#456]
    add x10,x10,x9
    add x11,x11,x9
    mov x12,#0
.Lmcica_copy_layer2:
    ldr d0,[x10,x12,lsl #3]
    str d0,[x11,x12,lsl #3]
    add x12,x12,#1
    cmp x12,x22
    b.lt .Lmcica_copy_layer2
    ldr x10,[x29,#424]
    ldr x11,[x29,#464]
    add x10,x10,x9
    add x11,x11,x9
    mov x12,#0
.Lmcica_copy_layer3:
    ldr d0,[x10,x12,lsl #3]
    str d0,[x11,x12,lsl #3]
    add x12,x12,#1
    cmp x12,x22
    b.lt .Lmcica_copy_layer3
    ldr x10,[x29,#432]
    ldr x11,[x29,#472]
    add x10,x10,x9
    add x11,x11,x9
    mov x12,#0
.Lmcica_copy_layer4:
    ldr d0,[x10,x12,lsl #3]
    str d0,[x11,x12,lsl #3]
    add x12,x12,#1
    cmp x12,x22
    b.lt .Lmcica_copy_layer4
.Lmcica_cloud_next:
    ldr w8,[x29,#1008]
    add w8,w8,#1
    str w8,[x29,#1008]
    cmp w8,w21
    b.lt .Lmcica_cloud_layer
    mov w0,#5
    bl .Lmcica_add
    mov w0,#1
    bl .Lmcica_store
    b .Lmcica_next
.Lmcica_no_cloud:
    bl .Lmcica_copy_flux
    b .Lmcica_next
.Lmcica_night:
    bl .Lmcica_zero_flux
.Lmcica_next:
    add w19,w19,#1
    cmp w19,w20
    b.lt .Lmcica_column
#ifndef MD2ASM_SW_PRIVATE_RANGE
    mov x0,x26
    bl free
#endif
.Lmcica_return:
    ldr x18,[x29,#1000]
    ldp d8,d9,[sp,#160]
    ldp d10,d11,[sp,#176]
    ldp d12,d13,[sp,#192]
    ldp d14,d15,[sp,#208]
    ldp x19,x20,[sp,#64]
    ldp x21,x22,[sp,#80]
    ldp x23,x24,[sp,#96]
    ldp x25,x26,[sp,#112]
    ldp x27,x28,[sp,#128]
    ldp x29,x30,[sp,#144]
    add sp,sp,#1536
    ret
.Lmcica_reject:
    brk #0
#ifdef MD2ASM_SW_PRIVATE_RANGE
.size SW_PRIVATE_PARENT,.-SW_PRIVATE_PARENT
#else
.size md2asm_solver_mcica_sw,.-md2asm_solver_mcica_sw
#endif
.Lmcica_descriptor:
    str x1,[x0]
    mov x3,#-1
    str x3,[x0,#8]
    mov x3,#8
    str x3,[x0,#16]
    ldr x4,.Lmcica_dtype
    str x4,[x0,#24]
    str x3,[x0,#32]
    mov x3,#1
    str x3,[x0,#40]
    str x3,[x0,#48]
    str x2,[x0,#56]
    ret
.Lmcica_delta:
    mov w8,#0
    fmov d7,#1.0
.Lmcica_delta_point:
    ldr d0,[x0,x8,lsl #3]
    ldr d1,[x1,x8,lsl #3]
    ldr d2,[x2,x8,lsl #3]
    fmul d3,d2,d2
    fmul d4,d1,d3
    fsub d4,d7,d4
    fmul d0,d0,d4
    fsub d3,d7,d3
    fmul d1,d1,d3
    fdiv d1,d1,d4
    fadd d3,d7,d2
    fdiv d2,d2,d3
    str d0,[x0,x8,lsl #3]
    str d1,[x1,x8,lsl #3]
    str d2,[x2,x8,lsl #3]
    add w8,w8,#1
    cmp w8,w3
    b.lt .Lmcica_delta_point
    ret
.Lmcica_layer:
    str x30,[x29,#1096]
    str w0,[x29,#1080]
    str w1,[x29,#1084]
    add x0,x29,#600
    add x1,x29,#616
    add x2,x29,#640
    add x3,x29,#704
    add x4,x29,#768
    add x5,x29,#832
    add x6,x29,#896
    bl md2asm_mcica_gamma
    add x0,x29,#600
    add x1,x29,#616
    ldr x2,[x29,#520]
    ldr x3,[x29,#528]
    ldr x4,[x29,#544]
    ldr x5,[x29,#552]
    ldr x6,[x29,#560]
    ldr w8,[x29,#1080]
    mul x8,x8,x22
    lsl x8,x8,#3
    ldr w9,[x29,#1084]
    add x10,x29,#400
    add x10,x10,x9,lsl #3
    ldr x7,[x10]
    add x7,x7,x8
    ldr x9,[x10,#8]
    add x9,x9,x8
    str x9,[sp,#0]
    ldr x9,[x10,#16]
    add x9,x9,x8
    str x9,[sp,#8]
    ldr x9,[x10,#24]
    add x9,x9,x8
    str x9,[sp,#16]
    ldr x9,[x10,#32]
    add x9,x9,x8
    str x9,[sp,#24]
#ifdef MD2ASM_SW_PRIVATE_RANGE
    bl SW_PRIVATE_REFLECT
#else
    bl md2asm_mcica_reflect
#endif
    ldr x30,[x29,#1096]
    ret
.Lmcica_add:
    str x30,[x29,#1104]
    str w0,[x29,#1084]
    add x0,x29,#600
    add x1,x29,#604
    mul x8,x27,x22
    lsl x8,x8,#3
    ldr x2,[x29,#368]
    add x2,x2,x8
    ldr x3,[x29,#360]
    add x3,x3,x8
    ldr x4,[x29,#352]
    add x4,x4,x8
    ldr x5,[x29,#568]
    ldr w9,[x29,#1084]
    add x10,x29,#400
    add x10,x10,x9,lsl #3
    ldr x6,[x10]
    ldr x7,[x10,#8]
    ldr x8,[x10,#16]
    str x8,[sp,#0]
    ldr x8,[x10,#24]
    str x8,[sp,#8]
    ldr x8,[x10,#32]
    str x8,[sp,#16]
    ldr x8,[x29,#480]
    str x8,[sp,#24]
    ldr x8,[x29,#488]
    str x8,[sp,#32]
    ldr x8,[x29,#496]
    str x8,[sp,#40]
    bl md2asm_adding_native_7240564
    ldr x30,[x29,#1104]
    ret
.Lmcica_store:
    str w0,[x29,#1108]
    mov x8,#0
.Lmcica_sum_boundary:
    mul x9,x8,x22
    lsl x9,x9,#3
    ldr x10,[x29,#480]
    add x10,x10,x9
    ldr x11,[x29,#488]
    add x11,x11,x9
    ldr x12,[x29,#496]
    add x12,x12,x9
    fmov d0,xzr
    fmov d1,xzr
    fmov d2,xzr
    mov x13,#0
.Lmcica_sum_sample:
    ldr d3,[x10,x13,lsl #3]
    fadd d0,d0,d3
    ldr d3,[x11,x13,lsl #3]
    fadd d1,d1,d3
    ldr d3,[x12,x13,lsl #3]
    fadd d2,d2,d3
    add x13,x13,#1
    cmp x13,x22
    b.lt .Lmcica_sum_sample
    fadd d1,d1,d2
    ldr w9,[x29,#1108]
    cbnz w9,.Lmcica_store_all
    ldr x10,[x24,#616]
    cbz x10,.Lmcica_store_clear_skip0
    ldr x11,[x24,#680]
    madd x12,x8,x11,x19
    str d0,[x10,x12,lsl #3]
.Lmcica_store_clear_skip0:
    ldr x10,[x24,#704]
    cbz x10,.Lmcica_store_clear_skip1
    ldr x11,[x24,#768]
    madd x12,x8,x11,x19
    str d1,[x10,x12,lsl #3]
.Lmcica_store_clear_skip1:
    ldr x10,[x24,#792]
    cbz x10,.Lmcica_store_clear_skip2
    ldr x11,[x24,#856]
    madd x12,x8,x11,x19
    str d2,[x10,x12,lsl #3]
.Lmcica_store_clear_skip2:
    b .Lmcica_store_boundary_next
.Lmcica_store_all:
    ldr x10,[x24,#176]
    cbz x10,.Lmcica_store_all_skip0
    ldr x11,[x24,#240]
    madd x12,x8,x11,x19
    ldr x13,[x24,#616]
    ldr d3,[x13,x12,lsl #3]
    ldr d4,[x29,#624]
    fmov d5,#1.0
    fsub d5,d5,d4
    fmul d0,d4,d0
    fmul d3,d5,d3
    fadd d0,d0,d3
    str d0,[x10,x12,lsl #3]
.Lmcica_store_all_skip0:
    ldr x10,[x24,#264]
    cbz x10,.Lmcica_store_all_skip1
    ldr x11,[x24,#328]
    madd x12,x8,x11,x19
    ldr x13,[x24,#704]
    ldr d3,[x13,x12,lsl #3]
    ldr d4,[x29,#624]
    fmov d5,#1.0
    fsub d5,d5,d4
    fmul d1,d4,d1
    fmul d3,d5,d3
    fadd d1,d1,d3
    str d1,[x10,x12,lsl #3]
.Lmcica_store_all_skip1:
    ldr x10,[x24,#352]
    cbz x10,.Lmcica_store_all_skip2
    ldr x11,[x24,#416]
    madd x12,x8,x11,x19
    ldr x13,[x24,#792]
    ldr d3,[x13,x12,lsl #3]
    ldr d4,[x29,#624]
    fmov d5,#1.0
    fsub d5,d5,d4
    fmul d2,d4,d2
    fmul d3,d5,d3
    fadd d2,d2,d3
    str d2,[x10,x12,lsl #3]
.Lmcica_store_all_skip2:
.Lmcica_store_boundary_next:
    add x8,x8,#1
    cmp x8,x21
    b.le .Lmcica_sum_boundary
    mul x8,x21,x22
    lsl x8,x8,#3
    ldr x10,[x29,#488]
    ldr x11,[x29,#496]
    add x10,x10,x8
    add x11,x11,x8
    mul x8,x19,x22
    lsl x8,x8,#3
    ldr w9,[x29,#1108]
    cbnz w9,.Lmcica_surface_all
    ldr x12,[x24,#2352]
    ldr x13,[x24,#2440]
    add x12,x12,x8
    add x13,x13,x8
    mov x9,#0
.Lmcica_surface_clear_sample:
    ldr d0,[x10,x9,lsl #3]
    ldr d1,[x11,x9,lsl #3]
    str d0,[x12,x9,lsl #3]
    str d1,[x13,x9,lsl #3]
    add x9,x9,#1
    cmp x9,x22
    b.lt .Lmcica_surface_clear_sample
    ret
.Lmcica_surface_all:
    ldr x12,[x24,#2176]
    ldr x13,[x24,#2264]
    add x12,x12,x8
    add x13,x13,x8
    ldr x14,[x24,#2352]
    ldr x15,[x24,#2440]
    add x14,x14,x8
    add x15,x15,x8
    ldr d4,[x29,#624]
    fmov d5,#1.0
    fsub d5,d5,d4
    mov x9,#0
.Lmcica_surface_all_sample:
    ldr d0,[x10,x9,lsl #3]
    ldr d1,[x11,x9,lsl #3]
    ldr d2,[x14,x9,lsl #3]
    ldr d3,[x15,x9,lsl #3]
    fmul d0,d4,d0
    fmul d1,d4,d1
    fmul d2,d5,d2
    fmul d3,d5,d3
    fadd d0,d0,d2
    fadd d1,d1,d3
    str d0,[x12,x9,lsl #3]
    str d1,[x13,x9,lsl #3]
    add x9,x9,#1
    cmp x9,x22
    b.lt .Lmcica_surface_all_sample
    ret
.Lmcica_copy_flux:
    ldr x8,[x24,#176]
    cbz x8,.Lmcica_copy_flux_skip0
    ldr x9,[x24,#616]
    ldr x10,[x24,#240]
    add x8,x8,x19,lsl #3
    add x9,x9,x19,lsl #3
    mov x11,#0
.Lmcica_copy_flux_0:
    ldr d0,[x9]
    str d0,[x8]
    add x8,x8,x10,lsl #3
    add x9,x9,x10,lsl #3
    add x11,x11,#1
    cmp x11,x21
    b.le .Lmcica_copy_flux_0
.Lmcica_copy_flux_skip0:
    ldr x8,[x24,#264]
    cbz x8,.Lmcica_copy_flux_skip1
    ldr x9,[x24,#704]
    ldr x10,[x24,#328]
    add x8,x8,x19,lsl #3
    add x9,x9,x19,lsl #3
    mov x11,#0
.Lmcica_copy_flux_1:
    ldr d0,[x9]
    str d0,[x8]
    add x8,x8,x10,lsl #3
    add x9,x9,x10,lsl #3
    add x11,x11,#1
    cmp x11,x21
    b.le .Lmcica_copy_flux_1
.Lmcica_copy_flux_skip1:
    ldr x8,[x24,#352]
    cbz x8,.Lmcica_copy_flux_skip2
    ldr x9,[x24,#792]
    ldr x10,[x24,#416]
    add x8,x8,x19,lsl #3
    add x9,x9,x19,lsl #3
    mov x11,#0
.Lmcica_copy_flux_2:
    ldr d0,[x9]
    str d0,[x8]
    add x8,x8,x10,lsl #3
    add x9,x9,x10,lsl #3
    add x11,x11,#1
    cmp x11,x21
    b.le .Lmcica_copy_flux_2
.Lmcica_copy_flux_skip2:
    ldr x8,[x24,#2176]
    ldr x9,[x24,#2352]
    mul x10,x19,x22
    add x8,x8,x10,lsl #3
    add x9,x9,x10,lsl #3
    mov x11,#0
.Lmcica_copy_surface0:
    ldr d0,[x9,x11,lsl #3]
    str d0,[x8,x11,lsl #3]
    add x11,x11,#1
    cmp x11,x22
    b.lt .Lmcica_copy_surface0
    ldr x8,[x24,#2264]
    ldr x9,[x24,#2440]
    mul x10,x19,x22
    add x8,x8,x10,lsl #3
    add x9,x9,x10,lsl #3
    mov x11,#0
.Lmcica_copy_surface1:
    ldr d0,[x9,x11,lsl #3]
    str d0,[x8,x11,lsl #3]
    add x11,x11,#1
    cmp x11,x22
    b.lt .Lmcica_copy_surface1
    ret
.Lmcica_zero_flux:
    ldr x8,[x24,#176]
    cbz x8,.Lmcica_zero_skip0
    ldr x9,[x24,#240]
    add x8,x8,x19,lsl #3
    mov x10,#0
.Lmcica_zero_profile0:
    str xzr,[x8]
    add x8,x8,x9,lsl #3
    add x10,x10,#1
    cmp x10,x21
    b.le .Lmcica_zero_profile0
.Lmcica_zero_skip0:
    ldr x8,[x24,#264]
    cbz x8,.Lmcica_zero_skip1
    ldr x9,[x24,#328]
    add x8,x8,x19,lsl #3
    mov x10,#0
.Lmcica_zero_profile1:
    str xzr,[x8]
    add x8,x8,x9,lsl #3
    add x10,x10,#1
    cmp x10,x21
    b.le .Lmcica_zero_profile1
.Lmcica_zero_skip1:
    ldr x8,[x24,#352]
    cbz x8,.Lmcica_zero_skip2
    ldr x9,[x24,#416]
    add x8,x8,x19,lsl #3
    mov x10,#0
.Lmcica_zero_profile2:
    str xzr,[x8]
    add x8,x8,x9,lsl #3
    add x10,x10,#1
    cmp x10,x21
    b.le .Lmcica_zero_profile2
.Lmcica_zero_skip2:
    ldr x8,[x24,#616]
    cbz x8,.Lmcica_zero_skip3
    ldr x9,[x24,#680]
    add x8,x8,x19,lsl #3
    mov x10,#0
.Lmcica_zero_profile3:
    str xzr,[x8]
    add x8,x8,x9,lsl #3
    add x10,x10,#1
    cmp x10,x21
    b.le .Lmcica_zero_profile3
.Lmcica_zero_skip3:
    ldr x8,[x24,#704]
    cbz x8,.Lmcica_zero_skip4
    ldr x9,[x24,#768]
    add x8,x8,x19,lsl #3
    mov x10,#0
.Lmcica_zero_profile4:
    str xzr,[x8]
    add x8,x8,x9,lsl #3
    add x10,x10,#1
    cmp x10,x21
    b.le .Lmcica_zero_profile4
.Lmcica_zero_skip4:
    ldr x8,[x24,#792]
    cbz x8,.Lmcica_zero_skip5
    ldr x9,[x24,#856]
    add x8,x8,x19,lsl #3
    mov x10,#0
.Lmcica_zero_profile5:
    str xzr,[x8]
    add x8,x8,x9,lsl #3
    add x10,x10,#1
    cmp x10,x21
    b.le .Lmcica_zero_profile5
.Lmcica_zero_skip5:
    ldr x8,[x24,#2176]
    mul x9,x19,x22
    add x8,x8,x9,lsl #3
    mov x10,#0
.Lmcica_zero_surface0:
    str xzr,[x8,x10,lsl #3]
    add x10,x10,#1
    cmp x10,x22
    b.lt .Lmcica_zero_surface0
    ldr x8,[x24,#2264]
    mul x9,x19,x22
    add x8,x8,x9,lsl #3
    mov x10,#0
.Lmcica_zero_surface1:
    str xzr,[x8,x10,lsl #3]
    add x10,x10,#1
    cmp x10,x22
    b.lt .Lmcica_zero_surface1
    ldr x8,[x24,#2352]
    mul x9,x19,x22
    add x8,x8,x9,lsl #3
    mov x10,#0
.Lmcica_zero_surface2:
    str xzr,[x8,x10,lsl #3]
    add x10,x10,#1
    cmp x10,x22
    b.lt .Lmcica_zero_surface2
    ldr x8,[x24,#2440]
    mul x9,x19,x22
    add x8,x8,x9,lsl #3
    mov x10,#0
.Lmcica_zero_surface3:
    str xzr,[x8,x10,lsl #3]
    add x10,x10,#1
    cmp x10,x22
    b.lt .Lmcica_zero_surface3
    ret
.p2align 3
.Lmcica_dtype:
    .quad 3302829850624
.section .note.GNU-stack,"",%progbits
