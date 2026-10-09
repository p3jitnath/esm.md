/* Retain the first nonempty mask level from the frozen complete prefix proof. */
/* Frozen tuning candidate, emitted 2026-10-09T21:52:46.319918+00:00. */
/* Complete lower-bidiagonal solve from the frozen CUBIDIAG contract.
 * All ten inputs are GNU Fortran addresses. Stack slots 0 and 8 are PR/PU.
 * Only caller-saved registers are used; no frame or numerical helper exists. */
.text
.p2align 4
.global cubidiag_
.type cubidiag_,%function
cubidiag_:
    ldrsw x0,[x0]                 // First selected column, initially one based.
    ldrsw x1,[x1]                 // Last selected column, exclusive after conversion.
    ldrsw x2,[x2]                 // Complete leading dimension.
    ldrsw x3,[x3]                 // Complete level capacity.
    ldp x8,x9,[sp]                // Forcing and returned solution.
    sub x0,x0,#1
    mul x10,x2,x3
    mov x11,x9                  // Private pointer within complete output.
    eor v20.16b,v20.16b,v20.16b
    cmp x10,#8
    b.lt .Lzero_tail
.Lzero_block:
    stp q20,q20,[x11],#32
    stp q20,q20,[x11],#32
    sub x10,x10,#8
    cmp x10,#8
    b.ge .Lzero_block
.Lzero_tail:
    cbz x10,.Lzero_complete
.Lzero_word:
    str xzr,[x11],#8
    subs x10,x10,#1
    b.ne .Lzero_word
.Lzero_complete:
    cmp x3,#2
    b.lt .Lreturn
    cmp x0,x1
    b.ge .Lreturn
    mov x10,#1                   // First solve level, retained through the mask proof.
    sub x17,x1,x0
    cmp x17,#8
    b.lt .Lhas_cloud
.Lmask_row:
    mul x15,x10,x2
    add x15,x15,x0
    add x16,x5,x15,lsl #2
    sub x17,x1,x0
    cmp x17,#8
    b.lt .Lmask_tail
.Lmask_eight:
    ldp q21,q22,[x16],#32
    orr v21.16b,v21.16b,v22.16b
    umaxv s21,v21.4s
    fmov w14,s21
    cbnz w14,.Lhas_cloud
    sub x17,x17,#8
    cmp x17,#8
    b.ge .Lmask_eight
.Lmask_tail:
    cbz x17,.Lnext_mask_row
.Lmask_word:
    ldr w14,[x16],#4
    cbnz w14,.Lhas_cloud
    subs x17,x17,#1
    b.ne .Lmask_word
.Lnext_mask_row:
    add x10,x10,#1
    cmp x10,x3
    b.lt .Lmask_row
    b .Lreturn
.Lhas_cloud:
    lsl x2,x2,#3                 // Complete row width in bytes.
    adrp x15,.Lregulariser
    ldr d0,[x15,:lo12:.Lregulariser]
    fmov d1,#1.0
.Llevel:
    mul x15,x10,x2               // Common byte offset for this complete level.
    add x17,x10,#2               // Compare the raw top without per-cell conversion.
    mov x11,x0
.Lcolumn:
    add x12,x15,x11,lsl #3
    lsr x13,x12,#1               // The logical mask uses four bytes per cell.
    ldr w14,[x5,x13]
    cbz w14,.Lnext_column
    ldrsw x13,[x4,x11,lsl #2]
    cmp x17,x13                 // level + 2 against the original one-based top.
    b.lt .Lnext_column
    ldr d2,[x7,x12]
    fadd d2,d2,d0                // Rounded diagonal including regulariser.
    fdiv d3,d1,d2                // Reciprocal is a separate rounding point.
    ldr d4,[x8,x12]
    b.eq .Lfirst_cloud_row
    ldr d5,[x6,x12]
    sub x13,x12,x2
    ldr d6,[x9,x13]
    fmul d5,d5,d6                // Lower diagonal times preceding solution.
    fsub d4,d4,d5                // Reduced forcing, rounded before scaling.
.Lfirst_cloud_row:
    fmul d4,d4,d3                // Preserve reciprocal then multiplication.
    str d4,[x9,x12]
.Lnext_column:
    add x11,x11,#1
    cmp x11,x1
    b.lt .Lcolumn
    add x10,x10,#1
    cmp x10,x3
    b.lt .Llevel
.Lreturn:
    ret
.size cubidiag_,.-cubidiag_
.section .rodata
.p2align 3
.Lregulariser:
    .quad 0x38aa95a5b7f87a0f
.section .note.GNU-stack,"",%progbits
