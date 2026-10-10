// Direct aerosol forward-scattering adjustment.
// Physics: formulations/openifs/physics/aerosol_forward_scattering.md, P01-P02.
// Contract: skills/md2asm/references/openifs/physics/delta_eddington_extensive.md.
// x0, x1 and x2 point to disjoint eight-byte FP64 mutable scalars.
// Values are dimensionless. Each arithmetic instruction rounds separately.
// Only caller-saved d0-d6 are used. There is no frame or helper call.
.text
.p2align 4
.global md2asm_openifs_delta_eddington_extensive
.type md2asm_openifs_delta_eddington_extensive, %function
md2asm_openifs_delta_eddington_extensive:
    ldr d0, [x0]
    ldr d1, [x1]
    ldr d2, [x2]
    fcmp d1, #0.0
    b.le .Lextensive_no_scattering
    fdiv d3, d2, d1
    b .Lextensive_fraction
.Lextensive_no_scattering:
    fmov d3, xzr
.Lextensive_fraction:
    fmov d6, #1.0
    fmul d4, d3, d3
    fmul d5, d1, d4
    fsub d0, d0, d5
    str d0, [x0]
    fsub d4, d6, d4
    fmul d1, d1, d4
    str d1, [x1]
    fmul d2, d1, d3
    fadd d6, d6, d3
    fdiv d2, d2, d6
    str d2, [x2]
    ret
.size md2asm_openifs_delta_eddington_extensive, .-md2asm_openifs_delta_eddington_extensive
.section .note.GNU-stack,"",%progbits
