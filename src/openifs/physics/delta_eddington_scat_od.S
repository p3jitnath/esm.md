/* Complete elemental cloud optical transform.
 * x0, x1 and x2 address separate aligned mutable FP64 scalars.
 * Each operation rounds separately. Only caller-saved registers are used. */
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL __radiation_cloud_optics_MOD_delta_eddington_scat_od
#endif
.text
.p2align 2
.global ORIGINAL_SYMBOL
.type ORIGINAL_SYMBOL,%function
ORIGINAL_SYMBOL:
    ldr d0,[x0]              /* Old total depth. */
    ldr d1,[x1]              /* Old scattering depth. */
    ldr d2,[x2]              /* Old asymmetry. */
    fmov d3,#1.0
    fmul d4,d2,d2            /* Rounded forward fraction. */
    fmul d5,d1,d4
    fsub d0,d0,d5
    str d0,[x0]              /* Complete first mutation. */
    fsub d4,d3,d4
    fmul d1,d1,d4
    str d1,[x1]              /* Complete second mutation. */
    fadd d3,d3,d2
    fdiv d2,d2,d3
    str d2,[x2]              /* Complete third mutation. */
    ret
.size ORIGINAL_SYMBOL,.-ORIGINAL_SYMBOL
.section .note.GNU-stack,"",%progbits
