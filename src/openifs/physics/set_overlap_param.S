/* Direct AArch64 cloud overlap from pressure and temperature.
 * Physics formulations/openifs/physics/cloud_overlap_length.md.
 * Contract skills/md2asm/references/openifs/physics/set_overlap_param.md.
 * x0 class wrapper, x1 thermodynamics object, x2 length in metres.
 * x3 and x4 are optional INTEGER4 column bounds, with null for absent.
 * Preserve saved registers, FPCR and all unrelated object bytes. */
#ifndef OVERLAP_SYMBOL
#define OVERLAP_SYMBOL __radiation_cloud_MOD_set_overlap_param
#endif
#ifndef OVERLAP_APPROX_SYMBOL
#define OVERLAP_APPROX_SYMBOL __radiation_cloud_MOD_set_overlap_param_approx
#endif
.text
.p2align 4
.global OVERLAP_SYMBOL
.type OVERLAP_SYMBOL,%function
OVERLAP_SYMBOL:
    mov w5,#0
    b .Loverlap_body
.size OVERLAP_SYMBOL,.-OVERLAP_SYMBOL
.global OVERLAP_APPROX_SYMBOL
.type OVERLAP_APPROX_SYMBOL,%function
OVERLAP_APPROX_SYMBOL:
    mov w5,#1
.Loverlap_body:
    stp x29,x30,[sp,#-192]!
    mov x29,sp
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    ldr x19,[x0]
    mov x20,x1
    add x21,x19,#704
    mov w28,w5
    ldp x9,x10,[x20,#48]
    sub x24,x10,x9
    add x24,x24,#1
    ldp x9,x10,[x20,#72]
    sub x25,x10,x9
    mov x22,#1
    cbz x3,.Loverlap_default_first
    ldrsw x22,[x3]
.Loverlap_default_first:
    mov x23,x24
    cbz x4,.Loverlap_default_last
    ldrsw x23,[x4]
.Loverlap_default_last:
    ldr d1,[x2]
    adr x9,.Loverlap_R_over_g
    ldr d0,[x9]
    cbz w28,.Loverlap_full_factor
    adr x9,.Loverlap_scale_height
    ldr d0,[x9]
.Loverlap_full_factor:
    fdiv d0,d0,d1
    fneg d0,d0
    str d0,[sp,#96]
    adr x9,.Loverlap_half_R_over_g
    ldr d0,[x9]
    fdiv d0,d0,d1
    fneg d0,d0
    str d0,[sp,#104]
    ldr x9,[x21]
    cbnz x9,.Loverlap_allocated
    sub x10,x25,#1
    mul x0,x24,x10
    lsl x0,x0,#3
    bl malloc
    cbz x0,.Loverlap_allocation_failed
    str x0,[x21]
    mov x9,#-1
    sub x9,x9,x24
    str x9,[x21,#8]
    mov x9,#8
    str x9,[x21,#16]
    str x9,[x21,#32]
    mov x9,#0x302
    lsl x9,x9,#32
    str x9,[x21,#24]
    mov x9,#1
    stp x9,x9,[x21,#40]
    str x24,[x21,#56]
    stp x24,x9,[x21,#64]
    sub x10,x25,#1
    str x10,[x21,#80]
.Loverlap_allocated:
    ldp x9,x10,[x20]
    ldr x11,[x20,#40]
    ldr x12,[x20,#64]
    madd x10,x22,x11,x10
    add x10,x10,x12
    add x9,x9,x10,lsl #3
    ldr d0,[x9]
    ldr d1,[x9,x12,lsl #3]
    fcmp d1,d0
    cset x9,gt
    str x9,[sp,#112]
    mov x26,#1
.Loverlap_layer:
    cmp x22,x23
    b.gt .Loverlap_next_layer
    ldr x9,[sp,#112]
    cbnz w28,.Loverlap_approx_layer
    cbz x9,.Loverlap_descending_layer
    cmp x26,#1
    b.ne .Loverlap_ascending_middle
    mov x10,#3
    mov x11,#2
    ldr d0,[sp,#96]
    b .Loverlap_set_rows
.Loverlap_ascending_middle:
    add x10,x26,#2
    mov x11,x26
    ldr d0,[sp,#104]
    b .Loverlap_set_rows
.Loverlap_descending_layer:
    sub x10,x25,#1
    cmp x26,x10
    b.ne .Loverlap_descending_middle
    sub x10,x25,#1
    mov x11,x25
    ldr d0,[sp,#96]
    b .Loverlap_set_rows
.Loverlap_descending_middle:
    mov x10,x26
    add x11,x26,#2
    ldr d0,[sp,#104]
    b .Loverlap_set_rows
.Loverlap_approx_layer:
    add x11,x26,#1
    mov x10,x26
    cbz x9,.Loverlap_approx_rows
    add x10,x26,#2
.Loverlap_approx_rows:
    ldr d0,[sp,#96]
.Loverlap_set_rows:
    str d0,[sp,#120]
    stp x10,x11,[sp,#128]
    mov x27,x22
.Loverlap_column:
    ldp x9,x10,[x20]
    ldr x11,[x20,#40]
    ldr x12,[x20,#64]
    madd x10,x27,x11,x10
    ldp x13,x14,[sp,#128]
    madd x13,x13,x12,x10
    madd x14,x14,x12,x10
    ldr d0,[x9,x13,lsl #3]
    ldr d1,[x9,x14,lsl #3]
    fdiv d0,d0,d1
    ldr d2,[sp,#120]
    cbnz w28,.Loverlap_coefficient_ready
    add x9,x20,#88
    ldp x10,x11,[x9]
    ldr x12,[x9,#40]
    ldr x13,[x9,#64]
    madd x11,x27,x12,x11
    add x14,x26,#1
    madd x11,x14,x13,x11
    ldr d1,[x10,x11,lsl #3]
    fmul d2,d2,d1
.Loverlap_coefficient_ready:
    str d2,[sp,#144]
    bl log
    ldr d1,[sp,#144]
    fmul d0,d1,d0
    bl exp
    ldp x9,x10,[x21]
    ldr x11,[x21,#40]
    ldr x12,[x21,#64]
    madd x10,x27,x11,x10
    madd x10,x26,x12,x10
    str d0,[x9,x10,lsl #3]
    add x27,x27,#1
    cmp x27,x23
    b.le .Loverlap_column
.Loverlap_next_layer:
    add x26,x26,#1
    cmp x26,x25
    b.lt .Loverlap_layer
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp x29,x30,[sp],#192
    ret
.Loverlap_allocation_failed:
    bl abort
.size OVERLAP_APPROX_SYMBOL,.-OVERLAP_APPROX_SYMBOL
.p2align 3
.Loverlap_scale_height:
    .quad 0x40bf400000000000
.Loverlap_R_over_g:
    .quad 0x403d4592b265ab8d
.Loverlap_half_R_over_g:
    .quad 0x402d4592b265ab8d
.section .note.GNU-stack,"",%progbits
