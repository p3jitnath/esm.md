/* Direct body from formulations/openifs/physics/cloud_decorrelation_length.md.
 * Contract skills/md2asm/references/openifs/physics/cloud_decorrelation_length.md.
 * Nine GNU Fortran addresses. Length vectors are in kilometres.
 */
#ifndef CLOUD_DECORR_SYMBOL
#define CLOUD_DECORR_SYMBOL cloud_overlap_decorr_len_
#endif
.text
.p2align 4
.global CLOUD_DECORR_SYMBOL
.type CLOUD_DECORR_SYMBOL,%function
CLOUD_DECORR_SYMBOL:
    sub sp,sp,#128
    stp x29,x30,[sp]
    mov x29,sp
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    ldr x26,[sp,#128]
    mov x27,x6
    mov x28,x7
    ldr w19,[x3]
    ldr w20,[x1]
    ldr w21,[x2]
    ldr w22,[x5]
    mrs x9,fpcr
    cbnz x9,.Ldecorr_bad
    cmp w19,#1
    b.lt .Ldecorr_bad
    cmp w19,#2048
    b.gt .Ldecorr_bad
    cmp w20,#1
    b.lt .Ldecorr_bad
    add w9,w19,#1
    cmp w20,w9
    b.gt .Ldecorr_bad
    cmp w21,#0
    b.lt .Ldecorr_bad
    cmp w21,w19
    b.gt .Ldecorr_bad
    sub w20,w20,#1
    adrp x23,.Ldecorr_constants
    add x23,x23,:lo12:.Ldecorr_constants
    cbz w22,.Ldecorr_constant
    adrp x9,:got:__yomcst_MOD_rpi
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rpi]
    ldr x10,[x9]
    ldr x11,[x23]
    cmp x10,x11
    b.ne .Ldecorr_bad
    ldr d0,[x9]
    ldr d7,[x23,#8]
    fdiv d7,d7,d0
    lsl x9,x19,#3
    add x9,x9,#15
    and x9,x9,#-16
    sub sp,sp,x9
    mov x25,sp
    mov x24,x20
    cmp x24,x21
    b.ge .Ldecorr_ratio_half
    /* All selected coordinates are checked before any output store. */
.Ldecorr_coordinate:
    ldr x10,[x4,x24,lsl #3]
    adrp x11,.Ldecorr_gaussian_table
    add x11,x11,:lo12:.Ldecorr_gaussian_table
    mov w12,#32
.Ldecorr_find:
    ldr x13,[x11]
    cmp x10,x13
    b.eq .Ldecorr_found
    add x11,x11,#24
    subs w12,w12,#1
    b.ne .Ldecorr_find
    b .Ldecorr_bad
.Ldecorr_found:
    cmp w22,#1
    b.ne .Ldecorr_select_cosine
    ldr d0,[x11,#8]
    b .Ldecorr_store_coordinate
.Ldecorr_select_cosine:
    ldr d0,[x11,#16]
.Ldecorr_store_coordinate:
    str d0,[x25,x24,lsl #3]
    add x24,x24,#1
    cmp x24,x21
    b.lt .Ldecorr_coordinate
    mov x24,x20
.Ldecorr_edge:
    ldr d0,[x25,x24,lsl #3]
    cmp w22,#1
    b.ne .Ldecorr_smooth
    fmul d0,d0,d7
    fabs d0,d0
    ldr d1,[x23,#32]
    fmul d0,d1,d0
    ldr d1,[x23,#24]
    fsub d0,d1,d0
    b .Ldecorr_store_edge
.Ldecorr_smooth:
    ldr d1,[x23,#48]
    fmul d1,d1,d0
    fmul d0,d1,d0
    ldr d1,[x23,#40]
    fadd d0,d1,d0
.Ldecorr_store_edge:
    str d0,[x27,x24,lsl #3]
    add x24,x24,#1
    cmp x24,x21
    b.lt .Ldecorr_edge
    cbz x28,.Ldecorr_ratio_half
    mov x24,x20
    ldr d1,[x23,#16]
.Ldecorr_water:
    ldr d0,[x27,x24,lsl #3]
    fmul d0,d0,d1
    str d0,[x28,x24,lsl #3]
    add x24,x24,#1
    cmp x24,x21
    b.lt .Ldecorr_water
.Ldecorr_ratio_half:
    cbz x26,.Ldecorr_done
    ldr d0,[x23,#16]
    str d0,[x26]
    b .Ldecorr_done
.Ldecorr_constant:
    ldr d0,[x0,#136]
    ldr d1,[x0,#144]
    dup v0.2d,v0.d[0]
    dup v1.2d,v1.d[0]
    mov x24,x20
.Ldecorr_constant_edge_pairs:
    sub x9,x21,x24
    cmp x9,#2
    b.lt .Ldecorr_constant_edge_tail
    add x10,x27,x24,lsl #3
    str q0,[x10]
    add x24,x24,#2
    b .Ldecorr_constant_edge_pairs
.Ldecorr_constant_edge_tail:
    cmp x24,x21
    b.ge .Ldecorr_constant_water
    str d0,[x27,x24,lsl #3]
.Ldecorr_constant_water:
    cbz x28,.Ldecorr_constant_ratio
    mov x24,x20
.Ldecorr_constant_water_pairs:
    sub x9,x21,x24
    cmp x9,#2
    b.lt .Ldecorr_constant_water_tail
    add x10,x28,x24,lsl #3
    str q1,[x10]
    add x24,x24,#2
    b .Ldecorr_constant_water_pairs
.Ldecorr_constant_water_tail:
    cmp x24,x21
    b.ge .Ldecorr_constant_ratio
    str d1,[x28,x24,lsl #3]
.Ldecorr_constant_ratio:
    cbz x26,.Ldecorr_done
    fdiv d2,d1,d0
    str d2,[x26]
.Ldecorr_done:
    mov sp,x29
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp x29,x30,[sp]
    add sp,sp,#128
    ret
.Ldecorr_bad:
    brk #0x4cd
.size CLOUD_DECORR_SYMBOL,.-CLOUD_DECORR_SYMBOL
.section .rodata
.p2align 4
.Ldecorr_constants:
    .quad 0x400921fb54442d18
    .double 180.0,0.5,2.899,0.02759,0.75,2.149
.p2align 4
.Ldecorr_gaussian_table:
    .quad 0x3fefe995e70409b6,0x3ff7f2e9650529f4,0x3fb2ecb28e1b54f8
    .quad 0x3fef8a212714bcdc,0x3ff66a4f3f0a78ff,0x3fc5a2a8d1292e09
    .quad 0x3feedf5518053baa,0x3ff4df6394c3a8dc,0x3fd0d702773295b3
    .quad 0x3fedeac0259f7f42,0x3ff353f1d9ef99b5,0x3fd6b69a82ff9e41
    .quad 0x3fecaea9b4574cb9,0x3ff1c84d4f66f7f5,0x3fdc60c137bd2841
    .quad 0x3feb2e04fd686a13,0x3ff03c903a9fd6d6,0x3fe0e3c06f55b060
    .quad 0x3fe96c69481c4bc5,0x3fed618af8d6485b,0x3fe36ee1b06a2a4e
    .quad 0x3fe76e0931d693ba,0x3fea49e4cc01ba6d,0x3fe5cba4e8c85f68
    .quad 0x3fe537a89c487f89,0x3fe73233c1c07c3e,0x3fe7f45e7108d59f
    .quad 0x3fe2ce9146962ca5,0x3fe41a7b5283a5a0,0x3fe9e3e17c5a9c0f
    .quad 0x3fe038862866b29e,0x3fe102bdb452ba1a,0x3feb958b579e13a9
    .quad 0x3fdaf76b57c6f8f1,0x3fdbd5f8c9b823e5,0x3fed054defc9ba72
    .quad 0x3fd53d55ce57bdf7,0x3fd5a670e661da05,0x3fee2fb9377aabfe
    .quad 0x3fcea0f7e19c0949,0x3fceedcaa7be5cb2,0x3fef120333e73813
    .quad 0x3fc27e0ea717f236,0x3fc28eaea3e5e152,0x3fefaa0e8ea0d481
    .quad 0x3fa8bbc8488cc499,0x3fa8be3f640a1669,0x3feff66f94ecbbbb
    .quad 0xbfa8bbc8488cc499,0xbfa8be3f640a1669,0x3feff66f94ecbbbb
    .quad 0xbfc27e0ea717f236,0xbfc28eaea3e5e152,0x3fefaa0e8ea0d481
    .quad 0xbfcea0f7e19c0949,0xbfceedcaa7be5cb2,0x3fef120333e73813
    .quad 0xbfd53d55ce57bdf7,0xbfd5a670e661da05,0x3fee2fb9377aabfe
    .quad 0xbfdaf76b57c6f8f1,0xbfdbd5f8c9b823e5,0x3fed054defc9ba72
    .quad 0xbfe038862866b29e,0xbfe102bdb452ba1a,0x3feb958b579e13a9
    .quad 0xbfe2ce9146962ca5,0xbfe41a7b5283a5a0,0x3fe9e3e17c5a9c0f
    .quad 0xbfe537a89c487f89,0xbfe73233c1c07c3e,0x3fe7f45e7108d59f
    .quad 0xbfe76e0931d693ba,0xbfea49e4cc01ba6d,0x3fe5cba4e8c85f68
    .quad 0xbfe96c69481c4bc5,0xbfed618af8d6485b,0x3fe36ee1b06a2a4e
    .quad 0xbfeb2e04fd686a13,0xbff03c903a9fd6d6,0x3fe0e3c06f55b060
    .quad 0xbfecaea9b4574cb9,0xbff1c84d4f66f7f5,0x3fdc60c137bd2841
    .quad 0xbfedeac0259f7f42,0xbff353f1d9ef99b5,0x3fd6b69a82ff9e41
    .quad 0xbfeedf5518053baa,0xbff4df6394c3a8dc,0x3fd0d702773295b3
    .quad 0xbfef8a212714bcdc,0xbff66a4f3f0a78ff,0x3fc5a2a8d1292e09
    .quad 0xbfefe995e70409b6,0xbff7f2e9650529f4,0x3fb2ecb28e1b54f8
.section .note.GNU-stack,"",%progbits
