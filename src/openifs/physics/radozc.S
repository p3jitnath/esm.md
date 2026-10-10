/* Place the ozone climatology on model pressure layers.
 * Physics formulations/openifs/physics/ozone_climatology.md.
 * Contract skills/md2asm/references/openifs/physics/radozc.md.
 * Eleven address arguments. Preserve complete inactive output bytes. */
#ifndef RADOZC_SYMBOL
#define RADOZC_SYMBOL radozc_
#endif
.text
.p2align 4
.global RADOZC_SYMBOL
.type RADOZC_SYMBOL,%function
RADOZC_SYMBOL:
    mov x9,sp
    sub sp,sp,#1120
    stp x29,x30,[sp]
    mov x29,sp
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    mov x19,x0
    ldrsw x20,[x1]
    ldrsw x21,[x2]
    ldrsw x22,[x3]
    ldrsw x23,[x4]
    ldrsw x24,[x5]
    ldrsw x25,[x6]
    ldrsw x26,[x7]
    ldr x27,[x9]
    ldr x11,[x9,#8]
    ldr x28,[x9,#16]
    cmp x23,#0
    b.le .Lozone_return
    cmp x20,x21
    b.gt .Lozone_return
    sub x0,x20,#1
    ldr d0,[x11,x0,lsl #3]
    adrp x0,:got:__yomdyncore_MOD_lape
    ldr x0,[x0,:got_lo12:__yomdyncore_MOD_lape]
    ldr w15,[x0]
    add x11,x19,#776
    mov x12,#0
    mov x13,#1
    mov x14,#35
    mov x16,#18
    cbz w15,.Lozone_latitude_search
    mov x14,#60
    mov x16,#63
    ldr d2,[x11]
    fcmp d0,d2
    b.gt .Lozone_north_endpoint
    mov x12,#1
    mov x13,#0
    b .Lozone_latitude_ready
.Lozone_north_endpoint:
    ldr d2,[x11,#504]
    fcmp d0,d2
    b.lt .Lozone_latitude_search
    mov x12,#64
    mov x13,#0
    b .Lozone_latitude_ready
.Lozone_latitude_search:
    sub x0,x16,#1
    ldr d2,[x11,x0,lsl #3]
    ldr d3,[x11,x16,lsl #3]
    fcmp d0,d3
    b.gt .Lozone_latitude_next
    fcmp d0,d2
    b.lt .Lozone_latitude_next
    mov x12,x16
.Lozone_latitude_next:
    subs x16,x16,#1
    b.ne .Lozone_latitude_search
    cbz x12,.Lozone_unsupported
    sub x0,x12,#1
    ldr d2,[x11,x0,lsl #3]
    ldr d3,[x11,x12,lsl #3]
    fsub d0,d0,d2
    fsub d3,d3,d2
    fdiv d1,d0,d3
    cbnz w15,.Lozone_latitude_ready
    cmp x12,#1
    b.eq .Lozone_outer_profile
    cmp x12,#18
    b.ne .Lozone_latitude_ready
.Lozone_outer_profile:
    mov x13,#0
.Lozone_latitude_ready:
    add x8,x29,#128
    add x9,x29,#624
    mov x10,#32520
    add x10,x19,x10
    add x0,x19,#1288
    sub x1,x12,#1
    add x0,x0,x1,lsl #3
    mov x16,#0
.Lozone_blend:
    ldr d2,[x0]
    cbz x13,.Lozone_blend_store
    ldr d3,[x0,#8]
    fsub d3,d3,d2
    fmul d3,d1,d3
    fadd d2,d2,d3
.Lozone_blend_store:
    str d2,[x8,x16,lsl #3]
    add x0,x0,#512
    add x16,x16,#1
    cmp x16,x14
    b.le .Lozone_blend
    fmov d6,#1.0
    mov x16,#0
.Lozone_slopes:
    add x0,x16,#1
    ldr d0,[x10,x16,lsl #3]
    ldr d1,[x10,x0,lsl #3]
    fsub d0,d0,d1
    fdiv d0,d6,d0
    ldr d2,[x8,x16,lsl #3]
    ldr d3,[x8,x0,lsl #3]
    fsub d2,d2,d3
    fmul d0,d0,d2
    str d0,[x9,x16,lsl #3]
    add x16,x16,#1
    cmp x16,x14
    b.lt .Lozone_slopes
    mov x17,x20
.Lozone_column:
    add x26,x26,#1
    mov x7,#0
.Lozone_face:
    mul x0,x7,x22
    sub x1,x17,#1
    add x0,x0,x1
    ldr d0,[x27,x0,lsl #3]
    ldr d1,[x10,x14,lsl #3]
    fcmp d0,d1
    b.ge .Lozone_final_profile
    mov x16,#0
.Lozone_pressure_interval:
    add x0,x16,#1
    ldr d1,[x10,x16,lsl #3]
    ldr d2,[x10,x0,lsl #3]
    fcmp d0,d1
    b.lt .Lozone_pressure_next
    fcmp d0,d2
    b.ge .Lozone_pressure_next
    ldr d1,[x8,x0,lsl #3]
    ldr d3,[x9,x16,lsl #3]
    fsub d2,d0,d2
    fmul d2,d2,d3
    fadd d1,d1,d2
    b .Lozone_face_ready
.Lozone_pressure_next:
    add x16,x16,#1
    cmp x16,x14
    b.lt .Lozone_pressure_interval
    b .Lozone_unsupported
.Lozone_final_profile:
    ldr d1,[x8,x14,lsl #3]
.Lozone_face_ready:
    cbz x7,.Lozone_remember_face
    fsub d2,d0,d4
    fadd d3,d1,d5
    fmul d2,d2,d3
    fmov d3,#0.5
    fmul d2,d2,d3
    sub x0,x7,#1
    mul x0,x0,x25
    sub x1,x26,#1
    add x0,x0,x1
    str d2,[x28,x0,lsl #3]
.Lozone_remember_face:
    fmov d4,d0
    fmov d5,d1
    add x7,x7,#1
    cmp x7,x23
    b.le .Lozone_face
    add x17,x17,x24
    cmp x17,x21
    b.le .Lozone_column
.Lozone_return:
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp x29,x30,[sp]
    add sp,sp,#1120
    ret
.Lozone_unsupported:
    bl abort
    brk #0
.size RADOZC_SYMBOL,.-RADOZC_SYMBOL
.section .note.GNU-stack,"",%progbits
