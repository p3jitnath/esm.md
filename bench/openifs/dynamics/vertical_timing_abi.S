/* Timing ABI adapter only. The complete VERINT body performs all mathematics.
 * Convert DGEMM-shape addresses to P,start,end,N,M,matrix,input,output,type,chunk.
 * KTYPE=0 and KCHUNK=24. Preserve x29/LR and 16-byte stack alignment. */
#ifndef INTEGRAL_TIMING_ENTRY
#define INTEGRAL_TIMING_ENTRY matrix_integral_scalar_
#endif
.text
.p2align 4
.global INTEGRAL_TIMING_ENTRY
.type INTEGRAL_TIMING_ENTRY,%function
INTEGRAL_TIMING_ENTRY:
    ldr x9, [sp]
    ldr x10, [sp, #24]
    sub sp, sp, #64
    stp x29, x30, [sp, #48]
    mov x29, sp
    str wzr, [sp, #16]
    mov w11, #24
    str w11, [sp, #20]
    mov w11, #1
    str w11, [sp, #24]
    add x11, sp, #16
    add x12, sp, #20
    stp x11, x12, [sp]
    mov x0, x7
    add x1, sp, #24
    mov x11, x3
    mov x3, x4
    mov x4, x11
    mov x5, x9
    mov x7, x10
    bl verint_complete_assembly_
    ldp x29, x30, [sp, #48]
    add sp, sp, #64
    ret
.size INTEGRAL_TIMING_ENTRY,.-INTEGRAL_TIMING_ENTRY
.section .note.GNU-stack,"",%progbits
