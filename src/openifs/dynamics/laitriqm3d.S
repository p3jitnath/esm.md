/* Complete bounded three-dimensional parcel interpolation.
 * Physics formulations/openifs/dynamics/bounded_three_dimensional_transport.md.
 * Contract skills/md2asm/references/openifs/dynamics/laitriqm3d.md.
 * Nineteen addresses and a complete P-by-H output owner.
 * x19 columns, x20 layers, x21 source plane, x22 layer, x23 column,
 * x24 matrix cell, x25 source, x26 output and x27/x28 selected bounds.
 * Preserve x18 and d8 through d15. No numerical child or driver stage.
 * Keep each signed row index in x12..x15 after its original first read. */
.text
.p2align 4
.macro PARG reg,index
    ldr x\reg,[sp,#(96+8*\index)]
.endm
.macro FIELD reg,arg,plane
    PARG 9,\arg
    mov x10,#\plane
    ldr x11,[sp,#272]
    madd x10,x10,x11,x24
    ldr \reg,[x9,x10,lsl #3]
.endm
.macro STENCIL reg,row,v,j,cache,first=0
.if \first
    PARG 9,14
    mov x10,#\row
    ldr x11,[sp,#272]
    madd x10,x10,x11,x24
    ldrsw x10,[x9,x10,lsl #2]
    mov \cache,x10
.else
    mov x10,\cache
.endif
    mov x11,#\v
    madd x10,x11,x21,x10
.if \j == 0
    sub x10,x10,#1
.elseif \j > 1
    add x10,x10,#(\j-1)
.endif
    ldr \reg,[x25,x10,lsl #3]
.endm
.global md2asm_laitriqm3d
.type md2asm_laitriqm3d,%function
md2asm_laitriqm3d:
    mov x16,sp
    sub sp,sp,#640
    stp x19,x20,[sp,#0]
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x25,x26,[sp,#48]
    stp x27,x28,[sp,#64]
    stp x29,x30,[sp,#80]
    mov x29,sp
    stp x0,x1,[sp,#96]
    stp x2,x3,[sp,#112]
    stp x4,x5,[sp,#128]
    stp x6,x7,[sp,#144]
    ldp x9,x10,[x16,#0]
    stp x9,x10,[sp,#160]
    ldp x9,x10,[x16,#16]
    stp x9,x10,[sp,#176]
    ldp x9,x10,[x16,#32]
    stp x9,x10,[sp,#192]
    ldp x9,x10,[x16,#48]
    stp x9,x10,[sp,#208]
    ldp x9,x10,[x16,#64]
    stp x9,x10,[sp,#224]
    ldr x9,[x16,#80]
    str x9,[sp,#240]
    str xzr,[sp,#264]
    ldr w19,[x3]
    ldr w20,[x6]
    ldr w21,[x2]
    ldr w27,[x4]
    sub w27,w27,#1
    ldr w28,[x5]
    sub w28,w28,#1
    uxtw x19,w19
    uxtw x20,w20
    uxtw x21,w21
    sxtw x27,w27
    sxtw x28,w28
    cbz x20,.Ltransport_return
    cmp x27,x28
    b.gt .Ltransport_return
    mul x9,x19,x20
    str x9,[sp,#272]
    PARG 9,17
    mov x25,x9
    PARG 9,18
    mov x26,x9
    PARG 9,9
    ldr w9,[x9]
    cmp w9,#2
    b.ne .Ltransport_mode_ready
    ldr w10,[x1]
    cbz w10,.Ltransport_mode_ready
    mov w9,#3
.Ltransport_mode_ready:
    str w9,[sp,#256]
    cmp w9,#3
    b.ne .Ltransport_start
    PARG 9,0
    ldr x9,[x9]
    str x9,[sp,#288]
    lsl x0,x19,#3
    bl malloc
    cbz x0,.Ltransport_allocation_failed
    str x0,[sp,#264]
    mov x9,#0
.Ltransport_clear_surplus:
    str xzr,[x0,x9,lsl #3]
    add x9,x9,#1
    cmp x9,x19
    b.lt .Ltransport_clear_surplus
.Ltransport_start:
    mov x22,#0
.Ltransport_layer:
    ldr w9,[sp,#256]
    cmp w9,#3
    b.ne .Ltransport_columns
    cbz x22,.Ltransport_first_ratio
    ldr x9,[sp,#288]
    add x10,x22,#1
    ldr d0,[x9,x10,lsl #3]
    sub x10,x10,#1
    ldr d1,[x9,x10,lsl #3]
    sub x10,x10,#1
    ldr d2,[x9,x10,lsl #3]
    fsub d0,d0,d1
    fsub d1,d1,d2
    fdiv d0,d0,d1
    b .Ltransport_ratio_ready
.Ltransport_first_ratio:
    fmov d0,#1.0
.Ltransport_ratio_ready:
    str d0,[sp,#296]
.Ltransport_columns:
    mov x23,x27
.Ltransport_cell:
    madd x24,x22,x19,x23
    STENCIL d0,1,0,1,x13,1
    STENCIL d1,1,0,2,x13,0
    FIELD d2,12,1
    fsub d1,d1,d0
    fmul d1,d2,d1
    fadd d0,d0,d1
    str d0,[sp,#320]
    STENCIL d0,2,0,1,x14,1
    STENCIL d1,2,0,2,x14,0
    FIELD d2,12,2
    fsub d1,d1,d0
    fmul d1,d2,d1
    fadd d0,d0,d1
    str d0,[sp,#328]
    STENCIL d0,0,1,1,x12,1
    STENCIL d1,0,1,2,x12,0
    FIELD d2,12,0
    fsub d1,d1,d0
    fmul d1,d2,d1
    fadd d0,d0,d1
    str d0,[sp,#336]
    STENCIL d6,1,1,0,x13,0
    fmov d0,d6
    STENCIL d1,1,1,1,x13,0
    str d1,[sp,#512]
    fsub d1,d1,d6
    FIELD d2,13,0
    fmul d1,d2,d1
    fadd d0,d0,d1
    STENCIL d1,1,1,2,x13,0
    str d1,[sp,#520]
    fsub d1,d1,d6
    FIELD d2,13,1
    fmul d1,d2,d1
    fadd d0,d0,d1
    STENCIL d1,1,1,3,x13,0
    fsub d1,d1,d6
    FIELD d2,13,2
    fmul d1,d2,d1
    fadd d0,d0,d1
    str d0,[sp,#344]
    STENCIL d6,2,1,0,x14,0
    fmov d0,d6
    STENCIL d1,2,1,1,x14,0
    str d1,[sp,#528]
    fsub d1,d1,d6
    FIELD d2,13,3
    fmul d1,d2,d1
    fadd d0,d0,d1
    STENCIL d1,2,1,2,x14,0
    str d1,[sp,#536]
    fsub d1,d1,d6
    FIELD d2,13,4
    fmul d1,d2,d1
    fadd d0,d0,d1
    STENCIL d1,2,1,3,x14,0
    fsub d1,d1,d6
    FIELD d2,13,5
    fmul d1,d2,d1
    fadd d0,d0,d1
    str d0,[sp,#352]
    STENCIL d0,3,1,1,x15,1
    STENCIL d1,3,1,2,x15,0
    FIELD d2,12,3
    fsub d1,d1,d0
    fmul d1,d2,d1
    fadd d0,d0,d1
    str d0,[sp,#360]
    STENCIL d0,0,2,1,x12,0
    STENCIL d1,0,2,2,x12,0
    FIELD d2,12,0
    fsub d1,d1,d0
    fmul d1,d2,d1
    fadd d0,d0,d1
    str d0,[sp,#368]
    STENCIL d6,1,2,0,x13,0
    fmov d0,d6
    STENCIL d1,1,2,1,x13,0
    str d1,[sp,#544]
    fsub d1,d1,d6
    FIELD d2,13,0
    fmul d1,d2,d1
    fadd d0,d0,d1
    STENCIL d1,1,2,2,x13,0
    str d1,[sp,#552]
    fsub d1,d1,d6
    FIELD d2,13,1
    fmul d1,d2,d1
    fadd d0,d0,d1
    STENCIL d1,1,2,3,x13,0
    fsub d1,d1,d6
    FIELD d2,13,2
    fmul d1,d2,d1
    fadd d0,d0,d1
    str d0,[sp,#376]
    STENCIL d6,2,2,0,x14,0
    fmov d0,d6
    STENCIL d1,2,2,1,x14,0
    str d1,[sp,#560]
    fsub d1,d1,d6
    FIELD d2,13,3
    fmul d1,d2,d1
    fadd d0,d0,d1
    STENCIL d1,2,2,2,x14,0
    str d1,[sp,#568]
    fsub d1,d1,d6
    FIELD d2,13,4
    fmul d1,d2,d1
    fadd d0,d0,d1
    STENCIL d1,2,2,3,x14,0
    fsub d1,d1,d6
    FIELD d2,13,5
    fmul d1,d2,d1
    fadd d0,d0,d1
    str d0,[sp,#384]
    STENCIL d0,3,2,1,x15,0
    STENCIL d1,3,2,2,x15,0
    FIELD d2,12,3
    fsub d1,d1,d0
    fmul d1,d2,d1
    fadd d0,d0,d1
    str d0,[sp,#392]
    STENCIL d0,1,3,1,x13,0
    STENCIL d1,1,3,2,x13,0
    FIELD d2,12,1
    fsub d1,d1,d0
    fmul d1,d2,d1
    fadd d0,d0,d1
    str d0,[sp,#400]
    STENCIL d0,2,3,1,x14,0
    STENCIL d1,2,3,2,x14,0
    FIELD d2,12,2
    fsub d1,d1,d0
    fmul d1,d2,d1
    fadd d0,d0,d1
    str d0,[sp,#408]
    ldr d0,[sp,#320]
    ldr d1,[sp,#328]
    FIELD d2,10,0
    fsub d1,d1,d0
    fmul d1,d2,d1
    fadd d0,d0,d1
    str d0,[sp,#432]
    ldr d6,[sp,#336]
    fmov d0,d6
    ldr d1,[sp,#344]
    fsub d1,d1,d6
    FIELD d2,11,0
    fmul d1,d2,d1
    fadd d0,d0,d1
    ldr d1,[sp,#352]
    fsub d1,d1,d6
    FIELD d2,11,1
    fmul d1,d2,d1
    fadd d0,d0,d1
    ldr d1,[sp,#360]
    fsub d1,d1,d6
    FIELD d2,11,2
    fmul d1,d2,d1
    fadd d0,d0,d1
    str d0,[sp,#440]
    ldr d6,[sp,#368]
    fmov d0,d6
    ldr d1,[sp,#376]
    fsub d1,d1,d6
    FIELD d2,11,0
    fmul d1,d2,d1
    fadd d0,d0,d1
    ldr d1,[sp,#384]
    fsub d1,d1,d6
    FIELD d2,11,1
    fmul d1,d2,d1
    fadd d0,d0,d1
    ldr d1,[sp,#392]
    fsub d1,d1,d6
    FIELD d2,11,2
    fmul d1,d2,d1
    fadd d0,d0,d1
    str d0,[sp,#448]
    ldr d0,[sp,#400]
    ldr d1,[sp,#408]
    FIELD d2,10,0
    fsub d1,d1,d0
    fmul d1,d2,d1
    fadd d0,d0,d1
    str d0,[sp,#456]
    ldr d6,[sp,#432]
    fmov d0,d6
    ldr d1,[sp,#440]
    fsub d1,d1,d6
    FIELD d2,15,0
    fmul d1,d2,d1
    fadd d0,d0,d1
    ldr d1,[sp,#448]
    fsub d1,d1,d6
    FIELD d2,15,1
    fmul d1,d2,d1
    fadd d0,d0,d1
    ldr d1,[sp,#456]
    fsub d1,d1,d6
    FIELD d2,15,2
    fmul d1,d2,d1
    fadd d0,d0,d1
    ldr w9,[sp,#256]
    cbz w9,.Ltransport_store
    ldr d16,[sp,#512]
    fmov d17,d16
    ldr d1,[sp,#520]
    fminnm d16,d16,d1
    fmaxnm d17,d17,d1
    ldr d1,[sp,#528]
    fminnm d16,d16,d1
    fmaxnm d17,d17,d1
    ldr d1,[sp,#536]
    fminnm d16,d16,d1
    fmaxnm d17,d17,d1
    ldr d1,[sp,#544]
    fminnm d16,d16,d1
    fmaxnm d17,d17,d1
    ldr d1,[sp,#552]
    fminnm d16,d16,d1
    fmaxnm d17,d17,d1
    ldr d1,[sp,#560]
    fminnm d16,d16,d1
    fmaxnm d17,d17,d1
    ldr d1,[sp,#568]
    fminnm d16,d16,d1
    fmaxnm d17,d17,d1
    cmp w9,#1
    b.eq .Ltransport_linear_limiter
    cmp w9,#3
    b.eq .Ltransport_vertical_limiter
    fminnm d0,d17,d0
    fmaxnm d0,d16,d0
    b .Ltransport_store
.Ltransport_linear_limiter:
    fcmp d0,d17
    b.gt .Ltransport_linear_fallback
    fcmp d0,d16
    b.ge .Ltransport_store
.Ltransport_linear_fallback:
    ldr d0,[sp,#512]
    ldr d1,[sp,#520]
    FIELD d2,12,1
    fsub d1,d1,d0
    fmul d1,d2,d1
    fadd d0,d0,d1
    str d0,[sp,#432]
    ldr d0,[sp,#528]
    ldr d1,[sp,#536]
    FIELD d2,12,2
    fsub d1,d1,d0
    fmul d1,d2,d1
    fadd d0,d0,d1
    str d0,[sp,#440]
    ldr d0,[sp,#544]
    ldr d1,[sp,#552]
    FIELD d2,12,1
    fsub d1,d1,d0
    fmul d1,d2,d1
    fadd d0,d0,d1
    str d0,[sp,#448]
    ldr d0,[sp,#560]
    ldr d1,[sp,#568]
    FIELD d2,12,2
    fsub d1,d1,d0
    fmul d1,d2,d1
    fadd d0,d0,d1
    str d0,[sp,#456]
    ldr d0,[sp,#432]
    ldr d1,[sp,#440]
    FIELD d2,10,0
    fsub d1,d1,d0
    fmul d1,d2,d1
    fadd d0,d0,d1
    str d0,[sp,#320]
    ldr d0,[sp,#448]
    ldr d1,[sp,#456]
    FIELD d2,10,0
    fsub d1,d1,d0
    fmul d1,d2,d1
    fadd d0,d0,d1
    str d0,[sp,#328]
    ldr d0,[sp,#320]
    ldr d1,[sp,#328]
    FIELD d2,16,0
    fsub d1,d1,d0
    fmul d1,d2,d1
    fadd d0,d0,d1
    b .Ltransport_store
.Ltransport_vertical_limiter:
    ldr x9,[sp,#264]
    ldr d1,[x9,x23,lsl #3]
    fadd d0,d0,d1
    fminnm d1,d17,d0
    fmaxnm d1,d16,d1
    fmaxnm d2,d0,d17
    fsub d2,d2,d17
    fminnm d3,d0,d16
    fsub d3,d3,d16
    fabs d4,d2
    fabs d5,d3
    fcmp d4,d5
    fcsel d2,d2,d3,ge
    ldr d7,[sp,#296]
    fmul d2,d2,d7
    str d2,[x9,x23,lsl #3]
    fmov d0,d1
.Ltransport_store:
    str d0,[x26,x24,lsl #3]
    add x23,x23,#1
    cmp x23,x28
    b.le .Ltransport_cell
    add x22,x22,#1
    cmp x22,x20
    b.lt .Ltransport_layer
.Ltransport_return:
    ldr x0,[sp,#264]
    cbz x0,.Ltransport_restore
    bl free
.Ltransport_restore:
    ldp x19,x20,[sp,#0]
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x25,x26,[sp,#48]
    ldp x27,x28,[sp,#64]
    ldp x29,x30,[sp,#80]
    add sp,sp,#640
    ret
.Ltransport_allocation_failed:
    bl abort
    brk #0
.size md2asm_laitriqm3d,.-md2asm_laitriqm3d
.section .note.GNU-stack,"",%progbits
