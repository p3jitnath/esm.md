// Complete FTDIR caller for the frozen coarse Fourier-analysis contract.
// Physics: formulations/openifs/dynamics/direct_fourier_analysis.md.
// Contract: skills/md2asm/references/openifs/dynamics/direct_fourier_analysis.md.
// Original interface: __ftdir_mod_MOD_ftdir(PREEL,KFIELDS,KGL).
// x0 points to the 88-byte GNU rank-two descriptor; x1 and x2 point to INTEGER4.
// Matrix words are FP64, field first, with 2144 columns and eight-byte alignment.
// The parent owns its source table views, complete direct FFT child and high-wave zeros.
// FFT992_ENTRY selects only the unchanged accepted assembly child.
// The frame has 224 bytes. Save x18 and all used saved registers; leave d8-d15 untouched.
// The numerical route preserves FPCR and errno and retains the child's source FPSR.
// Integer stores write positive FP64 zero without another floating-point operation.
#ifndef FFT992_ENTRY
#define FFT992_ENTRY md2asm_fft992
#endif
.arch armv8-a
.text
.p2align 4

// Read a source INTEGER4 component from its qualified complete allocated owner.
.macro int_cell output, object, offset, index, upper, kind=1
    ldr x10, [\object, #\offset]
    cbz x10, .Lftdir_bad_input
    tst x10, #3
    b.ne .Lftdir_bad_input
    ldr x11, [\object, #(\offset+16)]
    cmp x11, #4
    b.ne .Lftdir_bad_input
    ldrb w11, [\object, #(\offset+28)]
    cmp w11, #1
    b.ne .Lftdir_bad_input
    ldrb w11, [\object, #(\offset+29)]
    cmp w11, #\kind
    b.ne .Lftdir_bad_input
    ldr x11, [\object, #(\offset+32)]
    cmp x11, #4
    b.ne .Lftdir_bad_input
    ldr x11, [\object, #(\offset+40)]
    cmp x11, #1
    b.ne .Lftdir_bad_input
    ldr x11, [\object, #(\offset+48)]
    cmp x11, #1
    b.ne .Lftdir_bad_input
    ldr x11, [\object, #(\offset+56)]
    cmp x11, #\upper
    b.ne .Lftdir_bad_input
    cmp \index, #1
    b.lt .Lftdir_bad_input
    cmp \index, #\upper
    b.gt .Lftdir_bad_input
    ldr x11, [\object, #(\offset+8)]
    add x11, x11, \index
    ldr \output, [x10, x11, lsl #2]
.endm

// Return the first source table word at formal index (1,KGL).
.macro table_cell output, object, offset, index, first_extent, bytes, kind
    ldr x10, [\object, #\offset]
    cbz x10, .Lftdir_bad_input
    tst x10, #(\bytes-1)
    b.ne .Lftdir_bad_input
    ldr x11, [\object, #(\offset+16)]
    cmp x11, #\bytes
    b.ne .Lftdir_bad_input
    ldrb w11, [\object, #(\offset+28)]
    cmp w11, #2
    b.ne .Lftdir_bad_input
    ldrb w11, [\object, #(\offset+29)]
    cmp w11, #\kind
    b.ne .Lftdir_bad_input
    ldr x11, [\object, #(\offset+32)]
    cmp x11, #\bytes
    b.ne .Lftdir_bad_input
    ldr x11, [\object, #(\offset+40)]
    cmp x11, #1
    b.ne .Lftdir_bad_input
    ldr x11, [\object, #(\offset+48)]
    cmp x11, #1
    b.ne .Lftdir_bad_input
    ldr x11, [\object, #(\offset+56)]
    cmp x11, #\first_extent
    b.ne .Lftdir_bad_input
    ldr x12, [\object, #(\offset+64)]
    cmp x12, #\first_extent
    b.ne .Lftdir_bad_input
    ldr x11, [\object, #(\offset+72)]
    cmp x11, #1
    b.ne .Lftdir_bad_input
    ldr x11, [\object, #(\offset+80)]
    cmp x11, #32
    b.ne .Lftdir_bad_input
    ldr x11, [\object, #(\offset+8)]
    add x11, x11, #1
    madd x11, \index, x12, x11
    mov x12, #\bytes
    madd \output, x11, x12, x10
.endm

.global md2asm_ftdir
.type md2asm_ftdir, %function
md2asm_ftdir:
    sub sp, sp, #224
    stp x29, x30, [sp]
    stp x18, x19, [sp, #16]
    stp x20, x21, [sp, #32]
    stp x22, x23, [sp, #48]
    stp x24, x25, [sp, #64]
    stp x26, x27, [sp, #80]
    str x28, [sp, #96]
    mov x29, sp
    cbz x0, .Lftdir_bad_input
    cbz x1, .Lftdir_bad_input
    cbz x2, .Lftdir_bad_input
    tst x0, #7
    b.ne .Lftdir_bad_input
    orr x9, x1, x2
    tst x9, #3
    b.ne .Lftdir_bad_input
    mov x19, x0
    str x1, [sp, #112]
    str x2, [sp, #120]
    ldrsw x20, [x1]
    ldrsw x21, [x2]
    cmp x20, #1
    b.lt .Lftdir_bad_input
    cmp x20, #136
    b.gt .Lftdir_bad_input
    cmp x21, #1
    b.lt .Lftdir_bad_input
    cmp x21, #32
    b.gt .Lftdir_bad_input
    mrs x9, fpcr
    ldr x10, =0x03c80003
    tst x9, x10
    b.ne .Lftdir_bad_input
    ldr x9, [x19]
    cbz x9, .Lftdir_bad_input
    tst x9, #7
    b.ne .Lftdir_bad_input
    ldr x9, [x19, #16]
    cmp x9, #8
    b.ne .Lftdir_bad_input
    ldrb w9, [x19, #28]
    cmp w9, #2
    b.ne .Lftdir_bad_input
    ldrb w9, [x19, #29]
    cmp w9, #3
    b.ne .Lftdir_bad_input
    ldr x9, [x19, #32]
    cmp x9, #8
    b.ne .Lftdir_bad_input
    ldr x9, [x19, #40]
    cmp x9, #1
    b.ne .Lftdir_bad_input
    ldr x9, [x19, #48]
    cmp x9, #1
    b.ne .Lftdir_bad_input
    ldr x9, [x19, #56]
    cmp x9, x20
    b.ne .Lftdir_bad_input
    ldr x9, [x19, #64]
    cmp x9, x20
    b.ne .Lftdir_bad_input
    ldr x9, [x19, #72]
    cmp x9, #1
    b.ne .Lftdir_bad_input
    ldr x9, [x19, #80]
    cmp x9, #2144
    b.ne .Lftdir_bad_input

    adrp x16, :got:__tpm_distr_MOD_d
    ldr x16, [x16, :got_lo12:__tpm_distr_MOD_d]
    ldr x22, [x16]
    adrp x16, :got:__tpm_geometry_MOD_g
    ldr x16, [x16, :got_lo12:__tpm_geometry_MOD_g]
    ldr x23, [x16]
    adrp x16, :got:__tpm_fft_MOD_t
    ldr x16, [x16, :got_lo12:__tpm_fft_MOD_t]
    ldr x24, [x16]
    adrp x16, :got:__tpm_dim_MOD_r
    ldr x16, [x16, :got_lo12:__tpm_dim_MOD_r]
    ldr x25, [x16]
    cbz x22, .Lftdir_bad_input
    cbz x23, .Lftdir_bad_input
    cbz x24, .Lftdir_bad_input
    cbz x25, .Lftdir_bad_input
    adrp x16, :got:__tpm_distr_MOD_mysetw
    ldr x16, [x16, :got_lo12:__tpm_distr_MOD_mysetw]
    ldrsw x9, [x16]
    cmp x9, #1
    b.ne .Lftdir_bad_input

    // IGLG = D%NPTRLS(MYSETW) + KGL - 1.
    int_cell w26, x22, 1200, x9, 1
    cmp w26, #1
    b.ne .Lftdir_bad_input
    add w26, w26, w21
    sub w26, w26, #1
    sxtw x26, w26
    // IST = 2*(G%NMEN(IGLG)+1)+1.
    int_cell w9, x23, 64, x26, 32
    cmp w9, #21
    b.ne .Lftdir_bad_input
    add w9, w9, #1
    lsl w9, w9, #1
    add w9, w9, #1
    str w9, [sp, #140]
    // ILEN = G%NLOEN(IGLG)+R%NNOEXTZL+3-IST.
    int_cell w9, x23, 0, x26, 32
    cmp w9, #64
    b.ne .Lftdir_bad_input
    str w9, [sp, #160]
    ldr w10, [x25, #48]
    cbnz w10, .Lftdir_bad_input
    add w9, w9, w10
    str w9, [sp, #148]
    add w9, w9, #3
    ldr w10, [sp, #140]
    sub w9, w9, w10
    str w9, [sp, #136]
    // The selected coarse row has more than one position and uses FFT992.
    int_cell w9, x24, 184, x21, 32, 2
    cmp w9, #1
    b.ne .Lftdir_bad_input
    // IOFF = D%NSTAGTF(KGL)+1; retain the zero-based column start.
    int_cell w27, x22, 1000, x21, 32
    sub x9, x21, #1
    mov x10, #67
    mul x9, x9, x10
    cmp x27, x9
    b.ne .Lftdir_bad_input
    str w27, [sp, #144]
    table_cell x1, x24, 0, x21, 64, 8, 3
    table_cell x2, x24, 88, x21, 19, 4, 1
    ldr w9, [x2]
    cmp w9, #3
    b.ne .Lftdir_bad_input
    ldr w9, [x2, #4]
    cmp w9, #2
    b.ne .Lftdir_bad_input
    ldr w9, [x2, #8]
    cmp w9, #4
    b.ne .Lftdir_bad_input
    ldr w9, [x2, #12]
    cmp w9, #8
    b.ne .Lftdir_bad_input
    adrp x10, .Lftdir_canonical_trigs
    add x10, x10, :lo12:.Lftdir_canonical_trigs
    mov x11, #0
.Lftdir_table_check:
    ldr x12, [x1, x11, lsl #3]
    ldr x13, [x10, x11, lsl #3]
    cmp x12, x13
    b.ne .Lftdir_bad_input
    add x11, x11, #1
    cmp x11, #64
    b.lt .Lftdir_table_check

    // Complete direct child arguments, with original INC/LOT pointer alias.
    ldr x0, [x19]
    mul x9, x27, x20
    add x0, x0, x9, lsl #3
    ldr x3, [sp, #112]
    mov w9, #1
    str w9, [sp, #152]
    add x4, sp, #152
    add x5, sp, #148
    mov x6, x3
    mov w9, #-1
    str w9, [sp, #156]
    add x7, sp, #156
    // Prepare the exact high-wave owner before the unchanged child call.
    ldrsw x9, [sp, #140]
    sub x9, x9, #1
    mul x9, x9, x20
    add x28, x0, x9, lsl #3
    ldrsw x9, [sp, #136]
    mul x9, x9, x20
    str x9, [sp, #168]
    adrp x16, md2asm_ftdir_calls
    add x16, x16, :lo12:md2asm_ftdir_calls
    ldr x9, [x16]
    add x9, x9, #1
    str x9, [x16]
    bl FFT992_ENTRY

    // JJ=1..ILEN and JF=1..KFIELDS, with a complete scalar remainder.
    ldr x9, [sp, #168]
.Lftdir_zero_high_waves:
    cbz x9, .Lftdir_done
    str xzr, [x28], #8
    sub x9, x9, #1
    b .Lftdir_zero_high_waves
.Lftdir_done:
    ldp x29, x30, [sp]
    ldp x18, x19, [sp, #16]
    ldp x20, x21, [sp, #32]
    ldp x22, x23, [sp, #48]
    ldp x24, x25, [sp, #64]
    ldp x26, x27, [sp, #80]
    ldr x28, [sp, #96]
    add sp, sp, #224
    ret
.Lftdir_bad_input:
    brk #0xf7
.size md2asm_ftdir, .-md2asm_ftdir
.section .rodata
.p2align 3
.Lftdir_canonical_trigs:
    .quad 0x3ff0000000000000
    .quad 0x0000000000000000
    .quad 0x3fefd88da3d12526
    .quad 0x3fb917a6bc29b42c
    .quad 0x3fef6297cff75cb0
    .quad 0x3fc8f8b83c69a60a
    .quad 0x3fee9f4156c62dda
    .quad 0x3fd294062ed59f05
    .quad 0x3fed906bcf328d46
    .quad 0x3fd87de2a6aea963
    .quad 0x3fec38b2f180bdb1
    .quad 0x3fde2b5d3806f63b
    .quad 0x3fea9b66290ea1a3
    .quad 0x3fe1c73b39ae68c8
    .quad 0x3fe8bc806b151741
    .quad 0x3fe44cf325091dd6
    .quad 0x3fe6a09e667f3bcd
    .quad 0x3fe6a09e667f3bcc
    .quad 0x3fe44cf325091dd6
    .quad 0x3fe8bc806b151741
    .quad 0x3fe1c73b39ae68c9
    .quad 0x3fea9b66290ea1a3
    .quad 0x3fde2b5d3806f63e
    .quad 0x3fec38b2f180bdb0
    .quad 0x3fd87de2a6aea964
    .quad 0x3fed906bcf328d46
    .quad 0x3fd294062ed59f05
    .quad 0x3fee9f4156c62ddb
    .quad 0x3fc8f8b83c69a60d
    .quad 0x3fef6297cff75cb0
    .quad 0x3fb917a6bc29b438
    .quad 0x3fefd88da3d12525
    .quad 0x3c91a62633145c07
    .quad 0x3ff0000000000000
    .quad 0xbfb917a6bc29b42f
    .quad 0x3fefd88da3d12526
    .quad 0xbfc8f8b83c69a608
    .quad 0x3fef6297cff75cb0
    .quad 0xbfd294062ed59f02
    .quad 0x3fee9f4156c62ddb
    .quad 0xbfd87de2a6aea962
    .quad 0x3fed906bcf328d46
    .quad 0xbfde2b5d3806f63c
    .quad 0x3fec38b2f180bdb1
    .quad 0xbfe1c73b39ae68c6
    .quad 0x3fea9b66290ea1a5
    .quad 0xbfe44cf325091dd5
    .quad 0x3fe8bc806b151742
    .quad 0xbfe6a09e667f3bcc
    .quad 0x3fe6a09e667f3bcd
    .quad 0xbfe8bc806b151741
    .quad 0x3fe44cf325091dd6
    .quad 0xbfea9b66290ea1a4
    .quad 0x3fe1c73b39ae68c8
    .quad 0xbfec38b2f180bdb0
    .quad 0x3fde2b5d3806f63f
    .quad 0xbfed906bcf328d46
    .quad 0x3fd87de2a6aea965
    .quad 0xbfee9f4156c62dda
    .quad 0x3fd294062ed59f06
    .quad 0xbfef6297cff75cb0
    .quad 0x3fc8f8b83c69a617
    .quad 0xbfefd88da3d12525
    .quad 0x3fb917a6bc29b43c
.data
.p2align 3
.global md2asm_ftdir_calls
.type md2asm_ftdir_calls, %object
.size md2asm_ftdir_calls, 8
md2asm_ftdir_calls:
    .quad 0
.section .note.GNU-stack,"",%progbits
