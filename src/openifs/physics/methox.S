// Complete local methane oxidation and photolysis humidity tendency.
// Source interface: METHOX(KIDIA,KFDIA,KLON,KLEV,PQ,PTENQ,PAP).
// Each array contains KLON*KLEV FP64 words, with the column changing first.
// The caller supplies the consumed physical bounds in the solver contract.
// LOG and EXP use the accepted primary route; COS has a private bounded route.
.text
.p2align 4
.global md2asm_methox
.type md2asm_methox,%function
.macro meth_global reg,name
    adrp x9,:got:\name
    ldr x9,[x9,:got_lo12:\name]
    ldr \reg,[x9]
.endm
md2asm_methox:
    mrs x9,fpcr
    cbnz x9,.Lmeth_bad
    ldr w9,[x0]
    ldr w10,[x1]
    ldr w11,[x2]
    ldr w12,[x3]
    cmp w9,#1
    b.lt .Lmeth_bad
    cmp w10,#0
    b.lt .Lmeth_bad
    cmp w11,#0
    b.lt .Lmeth_bad
    cmp w11,#4096
    b.gt .Lmeth_bad
    cmp w12,#0
    b.lt .Lmeth_bad
    cmp w12,#512
    b.gt .Lmeth_bad
    add w13,w11,#1
    cmp w9,w13
    b.gt .Lmeth_bad
    cmp w10,w11
    b.gt .Lmeth_bad
    cmp w9,w10
    b.gt .Lmeth_empty
    cbz w12,.Lmeth_empty
    stp x29,x30,[sp,#-192]!
    mov x29,sp
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    stp d8,d9,[sp,#96]
    stp d10,d11,[sp,#112]
    stp d12,d13,[sp,#128]
    stp d14,d15,[sp,#144]
    mov x19,x4
    mov x20,x5
    mov x21,x6
    uxtw x22,w11
    uxtw x23,w10
    sub w9,w9,#1
    uxtw x24,w9
    uxtw x25,w12
    mov x27,#0
.Lmeth_level:
    add x26,x27,x24
    add x28,x27,x23
.Lmeth_cell:
    ldr d8,[x21,x26,lsl #3]
    ldr d9,[x19,x26,lsl #3]
    fmov d10,xzr
// Oxidation relaxes dry air towards RQLIM.
    meth_global d0,__yoemeth_MOD_rpbotox
    fcmp d8,d0
    b.ge .Lmeth_photo
    meth_global d0,__yoemeth_MOD_rqlim
    fcmp d9,d0
    b.ge .Lmeth_photo
    meth_global d0,__yoemeth_MOD_rptopox
    fcmp d8,d0
    b.le .Lmeth_ox_constant
    fdiv d0,d8,d0
    bl log
    fmov d1,#4.0
    bl md2asm_pow_original_rounding_candidate
    fmov d11,d0
    meth_global d0,__yoemeth_MOD_rpbotox
    fdiv d0,d0,d8
    bl log
    fdiv d11,d11,d0
    meth_global d0,__yoemeth_MOD_ralpha1
    fmul d11,d0,d11
    fmov d0,#1.0
    fadd d11,d0,d11
    ldr d0,.Lmeth_hundred
    fmul d11,d0,d11
    b .Lmeth_ox_days
.Lmeth_ox_constant:
    ldr d11,.Lmeth_hundred
.Lmeth_ox_days:
    meth_global d0,__yomcst_MOD_rdayi
    fmul d11,d0,d11
    meth_global d0,__yoemeth_MOD_rqlim
    fsub d0,d0,d9
    fdiv d0,d0,d11
    fadd d10,d10,d0
// Photolysis removes water. Its pressure interpolation uses the whole COS route.
.Lmeth_photo:
    meth_global d0,__yoemeth_MOD_rpbotph
    fcmp d8,d0
    b.ge .Lmeth_store
    meth_global d1,__yoemeth_MOD_rptopph
    fcmp d8,d1
    b.le .Lmeth_photo_constant
    fdiv d0,d8,d0
    bl log
    meth_global d1,__yomcst_MOD_rpi
    fmul d0,d1,d0
    meth_global d1,__yoemeth_MOD_rlogpph
    fdiv d0,d0,d1
    bl md2asm_cos_original_rounding
    fmov d1,#1.0
    fadd d0,d1,d0
    meth_global d1,__yoemeth_MOD_ralpha3
    fmul d0,d1,d0
    meth_global d1,__yoemeth_MOD_ralpha2
    fsub d0,d1,d0
    bl exp
    ldr d1,.Lmeth_hundredth
    fsub d0,d0,d1
    fmov d1,#1.0
    fdiv d11,d1,d0
    b .Lmeth_photo_days
.Lmeth_photo_constant:
    fmov d11,#3.0
.Lmeth_photo_days:
    meth_global d0,__yomcst_MOD_rdayi
    fmul d11,d0,d11
    fdiv d0,d9,d11
    fsub d10,d10,d0
.Lmeth_store:
    str d10,[x20,x26,lsl #3]
    add x26,x26,#1
    cmp x26,x28
    b.lt .Lmeth_cell
    add x27,x27,x22
    subs x25,x25,#1
    b.ne .Lmeth_level
    ldp d8,d9,[sp,#96]
    ldp d10,d11,[sp,#112]
    ldp d12,d13,[sp,#128]
    ldp d14,d15,[sp,#144]
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp x29,x30,[sp],#192
.Lmeth_empty:
    ret
.Lmeth_bad:
    b abort
.size md2asm_methox,.-md2asm_methox
.section .rodata
.p2align 3
.Lmeth_hundred: .double 100.0
.Lmeth_hundredth: .double 0.01
.section .note.GNU-stack,"",%progbits
