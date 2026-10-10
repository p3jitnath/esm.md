/* Complete radiation_cloud_cover::cum_cloud_cover_exp_ran numerical body.
 * Physics: formulations/openifs/physics/cloud_overlap.md.
 * Contract: skills/md2asm/references/openifs/physics/cloud_overlap.md.
 * x0 points to level count, x1 fractions, x2 overlap, x3 cumulative
 * output, x4 pair output and x5 an optional Fortran logical or null.
 * All arrays are disjoint and aligned. n=1 reads no interface arrays.
 * Each FP64 arithmetic operation rounds separately. No frame or helper
 * is needed, and only caller-saved integer and FP64 registers are used. */
#ifndef CLOUD_COVER_SYMBOL
#define CLOUD_COVER_SYMBOL __radiation_cloud_cover_MOD_cum_cloud_cover_exp_ran
#endif
.text
.p2align 2
.global CLOUD_COVER_SYMBOL
.type CLOUD_COVER_SYMBOL,%function
CLOUD_COVER_SYMBOL:
    ldr w6,[x0]
    ldr d0,[x1]
    str d0,[x3],#8
    fmov d20,#1.0
    fsub d7,d20,d0             /* Initial clear probability. */
    sub w6,w6,#1
    cbz w6,.Lcloud_done
    mov w7,#0
    cbz x5,.Lcloud_flag_ready
    ldr w7,[x5]
.Lcloud_flag_ready:
    movz x9,#0xffec
    movk x9,#0xffff,lsl #16
    movk x9,#0xffff,lsl #32
    movk x9,#0x3fef,lsl #48
    fmov d21,x9               /* 1 - 10*epsilon(FP64). */
.Lcloud_level:
    ldr d1,[x1,#8]
    ldr d2,[x2],#8
    cbz w7,.Lcloud_alpha_ready
    fcmp d2,d20
    b.ge .Lcloud_alpha_one
    fsub d3,d0,d1
    fabs d3,d3
    fsub d4,d20,d2
    fmul d4,d4,d3
    fdiv d5,d20,d2
    fadd d5,d3,d5
    fsub d5,d5,d20
    fdiv d4,d4,d5
    fadd d2,d2,d4
    b .Lcloud_alpha_ready
.Lcloud_alpha_one:
    fmov d2,d20
.Lcloud_alpha_ready:
    fmaxnm d3,d0,d1
    fmul d3,d2,d3
    fsub d4,d20,d2
    fadd d5,d0,d1
    fmul d6,d0,d1
    fsub d5,d5,d6
    fmul d4,d4,d5
    fadd d3,d3,d4
    str d3,[x4],#8            /* P01, complete adjacent union. */
    fcmp d0,d21
    b.ge .Lcloud_fully_covered
    fsub d4,d20,d3
    fmul d7,d7,d4
    fsub d4,d20,d0
    fdiv d7,d7,d4
    b .Lcloud_store
.Lcloud_fully_covered:
    fmov d7,xzr
.Lcloud_store:
    fsub d4,d20,d7
    str d4,[x3],#8            /* P02, complete cumulative cover. */
    fmov d0,d1
    add x1,x1,#8
    subs w6,w6,#1
    b.ne .Lcloud_level
.Lcloud_done:
    ret
.size CLOUD_COVER_SYMBOL,.-CLOUD_COVER_SYMBOL
.section .note.GNU-stack,"",%progbits
