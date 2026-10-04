// Read the Arm environment without changing it; both functions preserve
// all callee-saved registers and return an unsigned 64-bit value in x0.
.text
.p2align 4
.global sw_fpcr
.type sw_fpcr,%function
sw_fpcr:
    mrs x0, fpcr
    ret
.size sw_fpcr,.-sw_fpcr

.p2align 4
.global sw_vector_bytes
.type sw_vector_bytes,%function
sw_vector_bytes:
    cntb x0
    ret
.size sw_vector_bytes,.-sw_vector_bytes
.section .note.GNU-stack,"",%progbits
