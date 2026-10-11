// VDFFBLEND follows BLW-1 and BLW-2 in the frozen md2asm contract.
// GNU Fortran address ABI: x0-x7 hold arguments 0-7; stack slots hold 8-10.
// Complete arrays are eight-byte aligned, contiguous and bounded by KLON/KLEV.
// Only PFBLEND mutates. Owners are disjoint and inactive columns remain intact.
// Caller-saved registers hold the complete update; x18, saved registers and SP remain intact.
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL vdffblend_
#endif
.text
.p2align 4
.global ORIGINAL_SYMBOL
.type ORIGINAL_SYMBOL,%function
ORIGINAL_SYMBOL:
    ldr w9,[x0]
    ldr w10,[x1]
    ldr w11,[x2]
    ldr w12,[x3]
    cmp w11,#1
    b.lt .Lreject
    cmp w11,#4096
    b.gt .Lreject
    cmp w12,#1
    b.lt .Lreject
    cmp w12,#1024
    b.gt .Lreject
    cmp w9,#1
    b.lt .Lreject
    add w16,w11,#1
    cmp w9,w16
    b.gt .Lreject
    cmp w10,#0
    b.lt .Lreject
    cmp w10,w11
    b.gt .Lreject
    mrs x16,fpcr
    cbnz x16,.Lreject
    cmp w9,w10
    b.gt .Lreturn
    ldr x13,[sp,#0]
    ldr x14,[sp,#8]
    ldr x15,[sp,#16]
    orr x16,x4,x5
    orr x16,x16,x6
    orr x16,x16,x7
    orr x16,x16,x13
    orr x16,x16,x14
    orr x16,x16,x15
    tst x16,#7
    b.ne .Lreject
    cbz x4,.Lreject
    cbz x5,.Lreject
    cbz x6,.Lreject
    cbz x7,.Lreject
    cbz x13,.Lreject
    cbz x14,.Lreject
    cbz x15,.Lreject
    adrp x16,:got:__yomcst_MOD_rg
    ldr x16,[x16,:got_lo12:__yomcst_MOD_rg]
    ldr d16,[x16]
    fcmp d16,#0.0
    b.le .Lreject
    b.vs .Lreject
    ldr d28,.Lgravity_limit
    fcmp d16,d28
    b.gt .Lreject
    ldr d29,.Lheight_limit
    ldr d30,.Lgeopotential_limit
    ldr d31,.Lwind_limit
// Check every consumed selected profile before the first returned write.
    sub w0,w9,#1
.Lpreflight_column:
    ldr d21,[x7,x0,lsl #3]
    ldr d22,[x13,x0,lsl #3]
    fabs d20,d21
    fcmp d20,d31
    b.gt .Lreject
    b.vs .Lreject
    fabs d20,d22
    fcmp d20,d31
    b.gt .Lreject
    b.vs .Lreject
    ldr d0,[x14,x0,lsl #3]
    fcmp d0,#0.0
    b.lt .Lreject
    b.vs .Lreject
    fcmp d0,d29
    b.gt .Lreject
    fmul d0,d0,d16
    ldr d1,[x6,x0,lsl #3]
    fcmp d0,d1
    b.ge .Lreject
    b.vs .Lreject
    mov x1,x0
    mov w17,#0
.Lpreflight_level:
    ldr d1,[x6,x1,lsl #3]
    fabs d20,d1
    fcmp d20,d30
    b.gt .Lreject
    b.vs .Lreject
    cbz w17,.Lfirst_level
    fcmp d17,d1
    b.le .Lreject
.Lfirst_level:
    fmov d17,d1
    ldr d18,[x4,x1,lsl #3]
    ldr d19,[x5,x1,lsl #3]
    fabs d20,d18
    fcmp d20,d31
    b.gt .Lreject
    b.vs .Lreject
    fabs d20,d19
    fcmp d20,d31
    b.gt .Lreject
    b.vs .Lreject
    add x1,x1,x11
    add w17,w17,#1
    cmp w17,w12
    b.lt .Lpreflight_level
    add x0,x0,#1
    cmp x0,x10
    b.lt .Lpreflight_column
// Independent columns retain both original stages and their rounded operations.
    sub w0,w9,#1
    sub w16,w12,#1
    umull x3,w16,w11
.Lcolumn:
    add x1,x3,x0
    ldr d0,[x14,x0,lsl #3]
    fmul d0,d0,d16
    ldr d1,[x6,x1,lsl #3]
    fmov d2,d0
    ldr d21,[x7,x0,lsl #3]
    ldr d22,[x13,x0,lsl #3]
    fcmp d0,d1
    b.ge .Lscan_begin
// Original first-stage norm below the lowest level.
    ldr d17,[x4,x1,lsl #3]
    ldr d19,[x5,x1,lsl #3]
    fsub d17,d17,d21
    fsub d19,d19,d22
    fmul d17,d17,d17
    fmul d19,d19,d19
    fadd d17,d17,d19
    fsqrt d17,d17
    str d17,[x15,x0,lsl #3]
    fmov d2,d1
.Lscan_begin:
    mov w17,w12
.Lscan:
    cmp w17,#2
    b.lt .Lnext_column
    sub x16,x1,x11
    ldr d3,[x6,x1,lsl #3]
    ldr d4,[x6,x16,lsl #3]
    fcmp d2,d4
    b.ge .Lnext_level
    fcmp d2,d3
    b.lt .Lnext_level
// Ordered BLW-1 component numerators, without contraction or reassociation.
    fsub d5,d2,d3
    fsub d6,d4,d2
    fsub d7,d4,d3
    ldr d17,[x4,x16,lsl #3]
    ldr d18,[x4,x1,lsl #3]
    fmul d17,d17,d5
    fmul d18,d18,d6
    fadd d17,d17,d18
    fdiv d17,d17,d7
    ldr d19,[x5,x16,lsl #3]
    ldr d20,[x5,x1,lsl #3]
    fmul d19,d19,d5
    fmul d20,d20,d6
    fadd d19,d19,d20
    fdiv d19,d19,d7
// Ordered BLW-2 relative-speed norm.
    fsub d17,d17,d21
    fsub d19,d19,d22
    fmul d17,d17,d17
    fmul d19,d19,d19
    fadd d17,d17,d19
    fsqrt d17,d17
    str d17,[x15,x0,lsl #3]
    b .Lnext_column
.Lnext_level:
    mov x1,x16
    sub w17,w17,#1
    b .Lscan
.Lnext_column:
    add x0,x0,#1
    cmp x0,x10
    b.lt .Lcolumn
.Lreturn:
    ret
.Lreject:
    mov w0,#116
    b _exit
.size ORIGINAL_SYMBOL,.-ORIGINAL_SYMBOL
.section .rodata
.p2align 3
.Lgravity_limit: .double 100.0
.Lheight_limit: .double 1.0e10
.Lgeopotential_limit: .double 1.0e12
.Lwind_limit: .double 1.0e6
.section .note.GNU-stack,"",%progbits
