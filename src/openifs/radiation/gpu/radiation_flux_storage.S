/* GPU physical setup route. Original interface and ordered arithmetic are preserved.
 * Contract: skills/md2fort-gpu/references/openifs/setup/physical_setup.md
 * Original source: src/openifs/radiation/radiation_flux_storage.S
 */
// Original contract: skills/md2fort/references/openifs/radiation/radiation_control_setup.md
#include "../../support/gpu/preserved_scalar_calls.inc.S"
.text
.p2align 4
.global md2asm_initialize_selected_radiation_fluxes
.type md2asm_initialize_selected_radiation_fluxes,%function
md2asm_initialize_selected_radiation_fluxes:
    cbz x0,.Lflux_bad_leaf
    cbz x2,.Lflux_bad_leaf
    cbz x3,.Lflux_bad_leaf
    cbz x4,.Lflux_bad_leaf
    cbz x5,.Lflux_bad_leaf
    cmp x1,#2240
    b.lo .Lflux_bad_leaf
    orr x9,x0,x2
    orr x9,x9,x3
    orr x9,x9,x4
    orr x9,x9,x5
    tst x9,#7
    b.ne .Lflux_bad_leaf
    mrs x9,fpcr
    cbnz x9,.Lflux_bad_leaf
    sub sp,sp,#2688
    stp x29,x30,[sp]
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    str x18,[sp,#96]
    mov x29,sp
    mov x19,x0
    mov x20,x2
    mov x21,x3
    mov x22,x4
    mov x23,x5
    add x24,sp,#256
    add x9,sp,#160
    mov x10,#2240
    adds x10,x19,x10
    b.cs .Lflux_bad_frame
    stp x19,x10,[x9]
    adds x10,x20,#2040
    b.cs .Lflux_bad_frame
    stp x20,x10,[x9,#16]
    movz x10,#(229312 & 65535)
    movk x10,#(229312 >> 16),lsl #16
    adds x10,x21,x10
    b.cs .Lflux_bad_frame
    stp x21,x10,[x9,#32]
    adds x10,x22,#520
    b.cs .Lflux_bad_frame
    stp x22,x10,[x9,#48]
    adds x10,x23,#112
    b.cs .Lflux_bad_frame
    stp x23,x10,[x9,#64]
    mov x10,#0
.Lflux_span_outer:
    add x11,x9,x10,lsl #4
    ldp x12,x13,[x11]
    add x14,x10,#1
.Lflux_span_inner:
    cmp x14,#5
    b.hs .Lflux_span_next
    add x11,x9,x14,lsl #4
    ldp x15,x16,[x11]
    cmp x12,x16
    b.hs .Lflux_span_apart
    cmp x15,x13
    b.lo .Lflux_bad_frame
.Lflux_span_apart:
    add x14,x14,#1
    b .Lflux_span_inner
.Lflux_span_next:
    add x10,x10,#1
    cmp x10,#4
    b.lo .Lflux_span_outer
    adrp x9,.Lflux_upstream
    add x9,x9,:lo12:.Lflux_upstream
    mov x10,#0
.Lflux_upstream_check:
    ldr w11,[x23,x10,lsl #2]
    cmp x10,#4
    b.eq .Lflux_ozone
    ldr w12,[x9,x10,lsl #2]
    cmp w11,w12
    b.ne .Lflux_bad_frame
    b .Lflux_upstream_next
.Lflux_ozone:
    cmp w11,#1
    b.hi .Lflux_bad_frame
.Lflux_upstream_next:
    add x10,x10,#1
    cmp x10,#22
    b.lo .Lflux_upstream_check
    ldr x10,[x23,#88]
    adrp x9,.Lflux_timesteps
    add x9,x9,:lo12:.Lflux_timesteps
    mov x11,#0
.Lflux_timestep_check:
    ldr x12,[x9,x11,lsl #3]
    cmp x10,x12
    b.eq .Lflux_timestep_ok
    add x11,x11,#1
    cmp x11,#4
    b.lo .Lflux_timestep_check
    b .Lflux_bad_frame
.Lflux_timestep_ok:
    ldr x9,[x22,#56]
    adrp x10,.Lflux_hour
    ldr x10,[x10,:lo12:.Lflux_hour]
    cmp x9,x10
    b.ne .Lflux_bad_frame
    ldr w9,[x20,#12]
    cmn w9,#1
    b.ne .Lflux_bad_frame
    ldr w9,[x20,#16]
    cbnz w9,.Lflux_bad_frame
    ldr w9,[x20,#20]
    cmp w9,#15
    b.ne .Lflux_bad_frame
    ldr w9,[x20,#132]
    cmp w9,#12
    b.ne .Lflux_bad_frame
    ldr w9,[x20,#76]
    cmp w9,#1
    b.ne .Lflux_bad_frame
    ldr w9,[x20,#488]
    cmp w9,#1
    b.ne .Lflux_bad_frame
    ldr w9,[x21]
    cmn w9,#1
    b.ne .Lflux_bad_frame
    adrp x25,.Lflux_owner_plan
    add x25,x25,:lo12:.Lflux_owner_plan
    mov x26,#0
.Lflux_fresh:
    add x9,x25,x26,lsl #5
    ldr w9,[x9]
    ldr x10,[x19,x9]
    cbnz x10,.Lflux_bad_frame
    add x26,x26,#1
    cmp x26,#21
    b.lo .Lflux_fresh
    bl __errno_location
    str x0,[sp,#104]
    ldr w9,[x0]
    str w9,[sp,#112]
    ldr d0,[x23,#88]
    fmov d1,#1.0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,5,d0,destination,d0,real,x16,0,d1
    str d0,[sp,#240]
    ldr d1,[x22,#56]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d2,destination,d1,real,x16,0,d0
    str d2,[sp,#248]
    ldr w9,[x20,#12]
    neg w9,w9
 md2asm_gpu_preserved_scalar md2asm_gpu_startup_integer_cell_host,18,d3,destination,w9,general,w16,200,zero
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d3,destination,d3,real,x16,0,d2
    fmov d4,#0.5
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d3,destination,d3,real,x16,0,d4
 md2asm_gpu_preserved_scalar md2asm_gpu_physical_setup_numeric_cell_host,24,w9,destination,d3,real,x16,0,zero
    str w9,[sp,#128]
    ldr w10,[x20,#16]
    mul w10,w10,w9
    str w10,[sp,#132]
    ldr w10,[x20,#20]
    str w10,[sp,#136]
    ldr w10,[x21]
    neg w10,w10
 md2asm_gpu_preserved_scalar md2asm_gpu_startup_integer_cell_host,18,d3,destination,w10,general,w16,208,zero
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d3,destination,d3,real,x16,0,d2
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d3,destination,d3,real,x16,0,d4
 md2asm_gpu_preserved_scalar md2asm_gpu_physical_setup_numeric_cell_host,24,w10,destination,d3,real,x16,0,zero
    str w10,[sp,#156]
    adrp x9,.Lflux_point_zero_five
    ldr d4,[x9,:lo12:.Lflux_point_zero_five]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d3,destination,d2,real,x16,0,d4
 md2asm_gpu_preserved_scalar md2asm_gpu_physical_setup_numeric_cell_host,24,w10,destination,d3,real,x16,0,zero
    str w10,[sp,#148]
    ldr w11,[x20,#132]
 md2asm_gpu_preserved_scalar md2asm_gpu_startup_integer_cell_host,18,d3,destination,w11,general,w16,216,zero
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d3,destination,d3,real,x16,0,d2
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d3,destination,d3,real,x16,0,d4
 md2asm_gpu_preserved_scalar md2asm_gpu_physical_setup_numeric_cell_host,24,w11,destination,d3,real,x16,0,zero
    ldr d0,[x22,#56]
    ldr d1,[sp,#240]
    bl fmod
    adrp x9,.Lflux_point_one
    ldr d1,[x9,:lo12:.Lflux_point_one]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,4,none,comparison,d0,real,x16,0,d1
    b.gt .Lflux_bad_restore
    ldr w9,[sp,#128]
    ldr w10,[sp,#148]
    cmp w9,#1
    csel w11,w9,w10,eq
    str w11,[sp,#140]
    str w9,[sp,#144]
    add w11,w10,w10,lsl #1
    str w11,[sp,#152]
    mov x0,x24
    mov x1,x19
    mov x2,#2240
    bl memcpy
    mov x26,#0
.Lflux_allocate:
    add x27,x25,x26,lsl #5
    ldp w9,w1,[x27]
    add x0,x24,x9
    add x2,x27,#16
    mov w3,#1
    ldr w4,[x27,#8]
    bl md2asm_allocate_radiation_flux_array
    cbnz w0,.Lflux_allocation_failed
    add x26,x26,#1
    cmp x26,#21
    b.lo .Lflux_allocate
    mov x0,x19
    mov x1,x24
    mov x2,#2240
    bl memcpy
    ldr w9,[sp,#128]
    str w9,[x20,#12]
    ldr w9,[sp,#132]
    str w9,[x20,#16]
    ldr w9,[sp,#136]
    str w9,[x20,#20]
    ldr w9,[sp,#140]
    str w9,[x20,#36]
    ldr w9,[sp,#144]
    str w9,[x20,#32]
    ldr w9,[sp,#148]
    str w9,[x20,#40]
    ldr w9,[sp,#152]
    str w9,[x20,#44]
    ldr w9,[sp,#156]
    str w9,[x21]
    mov w28,#0
    b .Lflux_restore_return
.Lflux_allocation_failed:
    mov x0,x24
    mov x1,#2240
    bl md2asm_release_selected_radiation_fluxes
    mov w28,#1
    b .Lflux_return
.Lflux_bad_restore:
    mov w28,#2
.Lflux_restore_return:
    ldr x9,[sp,#104]
    ldr w10,[sp,#112]
    str w10,[x9]
    b .Lflux_return
.Lflux_bad_frame:
    mov w28,#2
.Lflux_return:
    mov w0,w28
    ldr x18,[sp,#96]
    ldp x27,x28,[sp,#80]
    ldp x25,x26,[sp,#64]
    ldp x23,x24,[sp,#48]
    ldp x21,x22,[sp,#32]
    ldp x19,x20,[sp,#16]
    ldp x29,x30,[sp]
    add sp,sp,#2688
    ret
.Lflux_bad_leaf:
    mov w0,#2
    ret
.size md2asm_initialize_selected_radiation_fluxes,.-md2asm_initialize_selected_radiation_fluxes
.p2align 4
.global md2asm_release_selected_radiation_fluxes
.type md2asm_release_selected_radiation_fluxes,%function
md2asm_release_selected_radiation_fluxes:
    cbz x0,.Lflux_bad_leaf
    cmp x1,#2240
    b.lo .Lflux_bad_leaf
    tst x0,#7
    b.ne .Lflux_bad_leaf
    adds x9,x0,#2240
    b.cs .Lflux_bad_leaf
    stp x19,x20,[sp,#-80]!
    stp x21,x22,[sp,#16]
    stp x23,x30,[sp,#32]
    str x18,[sp,#48]
    mov x19,x0
    bl __errno_location
    mov x20,x0
    ldr w21,[x0]
    adrp x22,.Lflux_owner_plan
    add x22,x22,:lo12:.Lflux_owner_plan
    mov x23,#0
.Lflux_release:
    add x9,x22,x23,lsl #5
    ldr w9,[x9]
    ldr x0,[x19,x9]
    cbz x0,.Lflux_release_next
    bl free
    add x9,x22,x23,lsl #5
    ldr w9,[x9]
    str xzr,[x19,x9]
.Lflux_release_next:
    add x23,x23,#1
    cmp x23,#21
    b.lo .Lflux_release
    str w21,[x20]
    mov w0,#0
    ldr x18,[sp,#48]
    ldp x23,x30,[sp,#32]
    ldp x21,x22,[sp,#16]
    ldp x19,x20,[sp],#80
    ret
.size md2asm_release_selected_radiation_fluxes,.-md2asm_release_selected_radiation_fluxes
.section .rodata
.p2align 3
.Lflux_hour:
 .double 3600.0
.Lflux_timesteps:
 .double 600.0,900.0,1800.0,3600.0
.Lflux_point_zero_five:
 .double 0.05
.Lflux_point_one:
 .double 0.1
.Lflux_upstream:
 .word 1,0,1,0,0,1,0,0,0,0,1,0,0,24,21,32,2048,2048,19,86,64,0
.section .rodata
.p2align 3
.Lflux_owner_plan:
    .word 0,3,0,0
    .word 24,20,86,1
    .word 112,3,0,0
    .word 24,20,86,1
    .word 224,3,0,0
    .word 24,20,86,1
    .word 336,3,0,0
    .word 24,20,86,1
    .word 560,4,1,0
    .word 24,19,6,86
    .word 696,2,0,0
    .word 24,86,1,1
    .word 984,2,0,0
    .word 24,86,1,1
    .word 872,3,0,0
    .word 24,1,86,1
    .word 784,2,0,0
    .word 24,86,1,1
    .word 1072,2,0,0
    .word 24,86,1,1
    .word 1160,2,0,0
    .word 24,86,1,1
    .word 1248,2,0,0
    .word 24,86,1,1
    .word 1336,2,0,0
    .word 24,86,1,1
    .word 1424,2,0,0
    .word 24,86,1,1
    .word 1512,2,0,0
    .word 24,86,1,1
    .word 1600,2,0,0
    .word 24,86,1,1
    .word 1688,2,0,0
    .word 24,86,1,1
    .word 1776,2,0,0
    .word 24,86,1,1
    .word 1864,2,0,0
    .word 24,86,1,1
    .word 1952,2,0,0
    .word 24,86,1,1
    .word 2128,3,0,0
    .word 24,20,86,1
.Lflux_owner_plan_end:
.section .note.GNU-stack,"",%progbits
