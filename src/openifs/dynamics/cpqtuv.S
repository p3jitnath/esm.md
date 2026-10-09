/* Complete CPQTUV physics update, emitted from its frozen md2asm contract.
 * GNU Fortran arguments are addresses; ten remaining arguments use the stack.
 * The five outputs are separate, with global NDIM and compact NDIM1 bounds.
 * Keep each multiply, add, subtraction and division separate in FP64. */
.text
.p2align 4
.global cpqtuv_
.type cpqtuv_,%function
/* Load one named compact-field base after its flag has authorised access. */
.macro compact_base object, target
    ldr \target,[sp,#\object]
    ldrsw x16,[\target,#188]
    sub x16,x16,#1
    madd \target,x16,x27,x26
.endm
/* Start and end byte offsets for the current level x1. */
.macro cell_bounds
    ldr x16,[sp,#152]
    madd x0,x1,x28,x16
    ldr x16,[sp,#160]
    madd x2,x1,x28,x16
.endm
/* Evaporate one small condensed component into vapour and cool temperature. */
.macro evaporate object, latent
    ldr x8,[sp,#\object]
    ldr w16,[x8,#92]
    cbz w16,.Levp_done\@
    compact_base \object,x9
    ldr d16,[x9,x0]
    fcmp d16,d1
    b.ge .Levp_done\@
    compact_base 96,x10
    ldr d17,[x10,x0]
    fadd d17,d17,d16
    str d17,[x10,x0]
    ldr d17,[x25,x0]
    fmul d18,\latent,d16
    fsub d17,d17,d18
    str d17,[x25,x0]
    str xzr,[x9,x0]
.Levp_done\@:
.endm
/* One component's new-minus-old change minus its dynamics contribution. */
.macro water_change object, first=0
    ldr x8,[sp,#\object]
    ldrsw x9,[x8,#188]
    sub x9,x9,#1
    mul x9,x9,x27
    add x10,x26,x9
    ldr d16,[x10,x0]
    ldrsw x10,[x8,#184]
    sub x10,x10,#1
    madd x10,x10,x27,x20
    ldr d17,[x10,x0]
    fsub d16,d16,d17
    add x10,x21,x9
    ldr d17,[x10,x0]
    fmul d17,d17,d0
    fsub d16,d16,d17
.if \first
    fmov d6,d16
.else
    fadd d6,d6,d16
.endif
.endm
/* Add the resulting water fields from left to right. */
.macro water_sum object, first=0
    compact_base \object,x8
    ldr d16,[x8,x0]
.if \first
    fmov d19,d16
.else
    fadd d19,d19,d16
.endif
.endm
cpqtuv_:
    stp x29,x30,[sp,#-240]!
    mov x29,sp
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    mov x19,x1
    ldrsw x28,[x2]
    ldrsw x8,[x5]
    str x8,[sp,#168]
    cmp x8,#0
    b.le .Lreturn
    ldrsw x9,[x3]
    ldrsw x10,[x4]
    cmp x10,x9
    b.lt .Lreturn
    lsl x28,x28,#3
    mul x27,x28,x8
    sub x9,x9,#1
    lsl x9,x9,#3
    lsl x10,x10,#3
    stp x9,x10,[sp,#152]
    ldr w8,[x7]
    str w8,[sp,#176]
    ldr d0,[x6]
    ldr d1,[x0,#120]
    ldr d2,[x0,#112]
    adrp x8,:got:__yoethf_MOD_ralvdcp
    ldr x8,[x8,:got_lo12:__yoethf_MOD_ralvdcp]
    ldr d3,[x8]
    adrp x8,:got:__yoethf_MOD_ralsdcp
    ldr x8,[x8,:got_lo12:__yoethf_MOD_ralsdcp]
    ldr d4,[x8]
    fmov d5,#1.0
    ldr x20,[sp,#264]
    ldr x21,[sp,#272]
    ldr x22,[sp,#280]
    ldr x23,[sp,#288]
    ldr x24,[sp,#296]
    ldr x25,[sp,#304]
    ldr x26,[sp,#312]
    ldr x8,[sp,#240]
    str x8,[sp,#192]
    ldr x8,[sp,#248]
    str x8,[sp,#200]
    ldr x8,[sp,#256]
    str x8,[sp,#208]
    /* Named descriptors are pointers into the caller's component objects. */
    mov x8,#0x3460
    movk x8,#0xc,lsl #16
    ldr x9,[x19,x8]
    str x9,[sp,#96]
    mov x8,#0x3470
    movk x8,#0xc,lsl #16
    ldr x9,[x19,x8]
    str x9,[sp,#104]
    mov x8,#0x3468
    movk x8,#0xc,lsl #16
    ldr x9,[x19,x8]
    str x9,[sp,#112]
    mov x8,#0x34b0
    movk x8,#0xc,lsl #16
    ldr x9,[x19,x8]
    str x9,[sp,#120]
    mov x8,#0x34a8
    movk x8,#0xc,lsl #16
    ldr x9,[x19,x8]
    str x9,[sp,#128]
    mov x8,#0x34f0
    movk x8,#0xc,lsl #16
    ldr x9,[x19,x8]
    str x9,[sp,#136]
    mov x8,#0x3950
    movk x8,#0xc,lsl #16
    ldr x9,[x19,x8]
    str x9,[sp,#144]
    /* Apply supplied wind and temperature rates. */
    ldr x3,[sp,#192]
    ldr x4,[sp,#200]
    ldr x5,[sp,#208]
    mov x1,#0
.Lwind_level:
    cell_bounds
.Lwind_cell:
    ldr d16,[x23,x0]
    fmul d16,d0,d16
    ldr d17,[x3,x0]
    fadd d16,d17,d16
    str d16,[x23,x0]
    ldr d16,[x24,x0]
    fmul d16,d0,d16
    ldr d17,[x4,x0]
    fadd d16,d17,d16
    str d16,[x24,x0]
    ldr d16,[x25,x0]
    fmul d16,d0,d16
    ldr d17,[x5,x0]
    fadd d16,d17,d16
    str d16,[x25,x0]
    add x0,x0,#8
    cmp x0,x2
    b.lt .Lwind_cell
    add x1,x1,#1
    ldr x16,[sp,#168]
    cmp x1,x16
    b.lt .Lwind_level
    /* Descriptor order controls repeated selections of a new tracer. */
    add x12,x19,#3848
    ldrsw x13,[x19]
    cbz x13,.Lcorrections
.Ltracer_descriptor:
    ldr w16,[x12,#92]
    cbz w16,.Ltracer_next
    ldrsw x14,[x12,#188]
    sub x14,x14,#1
    madd x14,x14,x27,x26
    ldrsw x15,[x12,#184]
    sub x15,x15,#1
    madd x15,x15,x27,x20
    mov x1,#0
.Ltracer_level:
    cell_bounds
.Ltracer_cell:
    ldr d16,[x14,x0]
    fmul d16,d0,d16
    ldr d17,[x15,x0]
    fadd d16,d17,d16
    str d16,[x14,x0]
    add x0,x0,#8
    cmp x0,x2
    b.lt .Ltracer_cell
    add x1,x1,#1
    ldr x16,[sp,#168]
    cmp x1,x16
    b.lt .Ltracer_level
.Ltracer_next:
    add x12,x12,#368
    subs x13,x13,#1
    b.ne .Ltracer_descriptor
.Lcorrections:
    mov x1,#0
.Lcorrection_level:
    cell_bounds
.Lcorrection_cell:
    evaporate 104,d3
    evaporate 112,d4
    evaporate 120,d3
    evaporate 128,d4
    ldr x3,[sp,#104]
    ldr w8,[x3,#92]
    cbz w8,.Lcloud_cap
    ldr x3,[sp,#112]
    ldr w8,[x3,#92]
    cbz w8,.Lcloud_cap
    ldr x3,[sp,#136]
    ldr w8,[x3,#92]
    cbz w8,.Lcloud_cap
    compact_base 104,x8
    compact_base 112,x9
    compact_base 136,x10
    ldr d16,[x8,x0]
    ldr d17,[x9,x0]
    ldr d18,[x10,x0]
    fadd d19,d16,d17
    fcmp d18,d2
    b.lt .Lclear_cloud
    fcmp d19,d1
    b.ge .Lcloud_cap
.Lclear_cloud:
    compact_base 96,x11
    ldr d20,[x11,x0]
    fadd d20,d20,d19
    str d20,[x11,x0]
    ldr d20,[x25,x0]
    fmul d21,d3,d16
    fsub d20,d20,d21
    fmul d21,d4,d17
    fsub d20,d20,d21
    str d20,[x25,x0]
    str xzr,[x8,x0]
    str xzr,[x9,x0]
    str xzr,[x10,x0]
.Lcloud_cap:
    ldr x3,[sp,#136]
    ldr w8,[x3,#92]
    cbz w8,.Lcorrection_next
    compact_base 136,x8
    ldr d16,[x8,x0]
    fcmp d16,d5
    b.le .Lcorrection_next
    str d5,[x8,x0]
.Lcorrection_next:
    add x0,x0,#8
    cmp x0,x2
    b.lt .Lcorrection_cell
    add x1,x1,#1
    ldr x16,[sp,#168]
    cmp x1,x16
    b.lt .Lcorrection_level
    /* Save the convection continuity rate in the full earlier buffer. */
    ldr x8,[sp,#144]
    ldr w9,[x8,#64]
    cbz w9,.Lreturn
    ldrsw x14,[x8,#168]
    sub x14,x14,#1
    madd x14,x14,x27,x20
    str x14,[sp,#184]
    mov x1,#0
.Lcontinuity_level:
    cell_bounds
.Lcontinuity_cell:
    ldr d16,[x22,x0]
    str d16,[x14,x0]
    add x0,x0,#8
    cmp x0,x2
    b.lt .Lcontinuity_cell
    add x1,x1,#1
    ldr x16,[sp,#168]
    cmp x1,x16
    b.lt .Lcontinuity_level
    ldr w8,[sp,#176]
    cbz w8,.Lreturn
    ldr x8,[sp,#96]
    ldr w9,[x8,#64]
    cbz w9,.Lreturn
    ldr x8,[sp,#104]
    ldr w9,[x8,#64]
    cbz w9,.Lreturn
    ldr x8,[sp,#112]
    ldr w9,[x8,#64]
    cbz w9,.Lreturn
    ldr x8,[sp,#120]
    ldr w9,[x8,#64]
    cbz w9,.Lreturn
    ldr x8,[sp,#128]
    ldr w9,[x8,#64]
    cbz w9,.Lreturn
    mov x1,#0
.Lmass_level:
    cell_bounds
.Lmass_cell:
    water_change 96,1
    water_change 104
    water_change 112
    water_change 120
    water_change 128
    fsub d7,d5,d6
    add x12,x19,#3848
    ldrsw x13,[x19]
    cbz x13,.Lmass_sum
.Lmass_descriptor:
    ldr w8,[x12,#92]
    cbz w8,.Lmass_next
    ldrsw x8,[x12,#188]
    sub x8,x8,#1
    madd x8,x8,x27,x26
    ldr d16,[x8,x0]
    fmul d16,d16,d7
    str d16,[x8,x0]
.Lmass_next:
    add x12,x12,#368
    subs x13,x13,#1
    b.ne .Lmass_descriptor
.Lmass_sum:
    water_sum 96,1
    water_sum 104
    water_sum 112
    water_sum 120
    water_sum 128
    fsub d7,d5,d19
    fdiv d6,d6,d7
    fdiv d6,d6,d0
    ldr x8,[sp,#184]
    ldr d16,[x8,x0]
    fadd d16,d16,d6
    str d16,[x8,x0]
    add x0,x0,#8
    cmp x0,x2
    b.lt .Lmass_cell
    add x1,x1,#1
    ldr x16,[sp,#168]
    cmp x1,x16
    b.lt .Lmass_level
.Lreturn:
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp x29,x30,[sp],#240
    ret
.size cpqtuv_,.-cpqtuv_
.section .note.GNU-stack,"",%progbits
