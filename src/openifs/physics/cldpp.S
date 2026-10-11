/* Complete new-radiation diagnostics from formulations/openifs/physics/cloud_cover_diagnostics.md.
 * Contract skills/md2asm/references/openifs/physics/cldpp.md.
 * Twenty-six ordinary addresses, complete configured Gaussian latitude,
 * overlap code1 and three nonempty cloud classes. */
#ifndef CLDPP_SYMBOL
#define CLDPP_SYMBOL cldpp_
#endif
#ifndef CLDPP_DECORR
#define CLDPP_DECORR md2asm_cloud_overlap_decorr_len
#endif
#ifndef CLDPP_CUMULATIVE
#define CLDPP_CUMULATIVE md2asm_cldpp_cumulative
#endif
.text
.p2align 4
.macro ARG reg,number
    ldr \reg,[sp,#(128+8*\number)]
.endm
.macro FIELD reg,number,index=x26
    ARG x9,\number
    ldr \reg,[x9,\index,lsl #3]
.endm
.macro PUT reg,number,index=x26
    ARG x9,\number
    str \reg,[x9,\index,lsl #3]
.endm
.global CLDPP_SYMBOL
.type CLDPP_SYMBOL,%function
CLDPP_SYMBOL:
    sub sp,sp,#768
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    stp x29,x30,[sp,#96]
    stp d8,d9,[sp,#400]
    stp d10,d11,[sp,#416]
    stp d12,d13,[sp,#432]
    stp d14,d15,[sp,#448]
    mov x29,sp
    mov x27,xzr
    str x0,[sp,#128]
    str x1,[sp,#136]
    str x2,[sp,#144]
    str x3,[sp,#152]
    str x4,[sp,#160]
    str x5,[sp,#168]
    str x6,[sp,#176]
    str x7,[sp,#184]
    ldr x9,[sp,#768]
    str x9,[sp,#192]
    ldr x9,[sp,#776]
    str x9,[sp,#200]
    ldr x9,[sp,#784]
    str x9,[sp,#208]
    ldr x9,[sp,#792]
    str x9,[sp,#216]
    ldr x9,[sp,#800]
    str x9,[sp,#224]
    ldr x9,[sp,#808]
    str x9,[sp,#232]
    ldr x9,[sp,#816]
    str x9,[sp,#240]
    ldr x9,[sp,#824]
    str x9,[sp,#248]
    ldr x9,[sp,#832]
    str x9,[sp,#256]
    ldr x9,[sp,#840]
    str x9,[sp,#264]
    ldr x9,[sp,#848]
    str x9,[sp,#272]
    ldr x9,[sp,#856]
    str x9,[sp,#280]
    ldr x9,[sp,#864]
    str x9,[sp,#288]
    ldr x9,[sp,#872]
    str x9,[sp,#296]
    ldr x9,[sp,#880]
    str x9,[sp,#304]
    ldr x9,[sp,#888]
    str x9,[sp,#312]
    ldr x9,[sp,#896]
    str x9,[sp,#320]
    ldr x9,[sp,#904]
    str x9,[sp,#328]

    mrs x9,fpcr
    cbnz x9,.Lcldpp_bad
    ARG x9,7
    ldr w20,[x9]
    ARG x9,8
    ldr w21,[x9]
    ARG x9,5
    ldr w22,[x9]
    ARG x9,6
    ldr w23,[x9]
    sub x22,x22,#1
    cmp w20,#1
    b.lt .Lcldpp_bad
    cmp w20,#2048
    b.gt .Lcldpp_bad
    cmp w21,#3
    b.lt .Lcldpp_bad
    cmp w21,#512
    b.gt .Lcldpp_bad
    cmp w22,#0
    b.lt .Lcldpp_bad
    cmp w22,w20
    b.ge .Lcldpp_bad
    cmp w23,#0
    b.lt .Lcldpp_bad
    cmp w23,w20
    b.gt .Lcldpp_bad
    ARG x9,17
    ldr w19,[x9]
    cmp w19,#1
    b.hi .Lcldpp_bad
    ARG x9,2
    ldr d0,[x9,#88]
    str d0,[sp,#480]
    adrp x28,.Lcldpp_constants
    add x28,x28,:lo12:.Lcldpp_constants
    cbz w19,.Lcldpp_mask
    ARG x9,1
    ldr w10,[x9,#512]
    cbnz w10,.Lcldpp_bad
    ARG x9,0
    ldr w10,[x9,#536]
    cmp w10,#1
    b.ne .Lcldpp_bad
    ARG x9,3
    ldr d0,[x9,#152]
    str d0,[sp,#496]
    ldr d0,[x9,#160]
    str d0,[sp,#504]
    adrp x9,:got:__yomcst_MOD_rd
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rd]
    ldr d0,[x9]
    adrp x9,:got:__yomcst_MOD_rg
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rg]
    ldr d1,[x9]
    fdiv d0,d0,d1
    str d0,[sp,#512]
    mov x0,#1
    mov x9,#24
    mul x1,x20,x9
    add x1,x1,x21,lsl #5
    bl calloc
    cbz x0,.Lcldpp_bad
    mov x27,x0
    str x0,[sp,#520]
    add x0,x0,x20,lsl #3
    str x0,[sp,#528]
    add x0,x0,x20,lsl #3
    str x0,[sp,#536]
    add x0,x0,x20,lsl #3
    str x0,[sp,#544]
    add x0,x0,x21,lsl #3
    str x0,[sp,#552]
    add x0,x0,x21,lsl #3
    str x0,[sp,#560]
    add x0,x0,x21,lsl #3
    str x0,[sp,#568]
    /* Validate every coordinate and class extent before public stores. */
    mov x24,x22
.Lcldpp_preflight:
    cmp x24,x23
    b.ge .Lcldpp_preflight_done
    FIELD x10,15,x24
    adrp x11,.Lcldpp_latitudes
    add x11,x11,:lo12:.Lcldpp_latitudes
    mov w12,#32
.Lcldpp_find_latitude:
    ldr x13,[x11]
    cmp x10,x13
    b.eq .Lcldpp_latitude_found
    add x11,x11,#16
    subs w12,w12,#1
    b.ne .Lcldpp_find_latitude
    b .Lcldpp_bad
.Lcldpp_latitude_found:
    ldr x10,[x11,#8]
    ldr x9,[sp,#520]
    str x10,[x9,x24,lsl #3]
    madd x26,x21,x20,x24
    FIELD d10,9
    FIELD d0,9,x24
    fdiv d0,d0,d10
    ldr d1,[sp,#496]
    fcmp d0,d1
    b.ge .Lcldpp_bad
    b.vs .Lcldpp_bad
    mov x25,#1
.Lcldpp_find_middle:
    madd x26,x25,x20,x24
    FIELD d0,9
    fdiv d0,d0,d10
    sub x10,x21,#1
    cmp x25,x10
    b.ge .Lcldpp_middle_found
    fcmp d0,d1
    b.ge .Lcldpp_middle_found
    add x25,x25,#1
    b .Lcldpp_find_middle
.Lcldpp_middle_found:
    ldr d1,[sp,#504]
    fcmp d0,d1
    b.ge .Lcldpp_bad
    b.vs .Lcldpp_bad
    ldr x9,[sp,#536]
    add x9,x9,x24,lsl #3
    str w25,[x9]
    add x25,x25,#1
    cmp x25,x21
    b.ge .Lcldpp_bad
.Lcldpp_find_low:
    madd x26,x25,x20,x24
    FIELD d0,9
    fdiv d0,d0,d10
    sub x10,x21,#1
    cmp x25,x10
    b.ge .Lcldpp_low_found
    fcmp d0,d1
    b.ge .Lcldpp_low_found
    add x25,x25,#1
    b .Lcldpp_find_low
.Lcldpp_low_found:
    fcmp d0,d1
    b.lt .Lcldpp_bad
    b.vs .Lcldpp_bad
    ldr x9,[sp,#536]
    add x9,x9,x24,lsl #3
    str w25,[x9,#4]
    add x24,x24,#1
    b .Lcldpp_preflight
.Lcldpp_preflight_done:
    ARG x0,3
    ARG x1,5
    ARG x2,6
    ARG x3,7
    ldr x4,[sp,#520]
    ARG x5,1
    add x5,x5,#160
    ldr x6,[sp,#528]
    mov x7,xzr
    str xzr,[sp]
    bl CLDPP_DECORR
    mov x24,x22
.Lcldpp_column:
    cmp x24,x23
    b.ge .Lcldpp_mask
    mov x25,#0
.Lcldpp_pack:
    madd x26,x25,x20,x24
    FIELD d0,11
    fmov d1,xzr
    ldr d2,[x28]
    fmaxnm d0,d0,d1
    fminnm d0,d0,d2
    ldr x9,[sp,#544]
    str d0,[x9,x25,lsl #3]
    sub x10,x21,#1
    cmp x25,x10
    b.ge .Lcldpp_packed
    FIELD d0,10
    add x26,x26,x20
    FIELD d1,10
    fdiv d0,d1,d0
    bl log
    fmov d8,d0
    madd x26,x25,x20,x24
    FIELD d0,14
    add x26,x26,x20
    FIELD d1,14
    fadd d0,d0,d1
    ldr d2,[sp,#512]
    ldr d3,[x28,#8]
    fmul d2,d2,d3
    fmul d0,d2,d0
    fmul d0,d0,d8
    ldr d1,[x28,#16]
    fmul d0,d0,d1
    fneg d0,d0
    ldr x9,[sp,#528]
    ldr d1,[x9,x24,lsl #3]
    fdiv d0,d0,d1
    bl exp
    ldr x9,[sp,#552]
    str d0,[x9,x25,lsl #3]
.Lcldpp_packed:
    add x25,x25,#1
    cmp x25,x21
    b.lt .Lcldpp_pack
    mov w10,w21
    mov x11,#0
    str w10,[sp,#600]
    add x0,sp,#600
    ldr x1,[sp,#544]
    add x1,x1,x11,lsl #3
    ldr x2,[sp,#552]
    add x2,x2,x11,lsl #3
    ldr x3,[sp,#560]
    ldr x4,[sp,#568]
    mov x5,xzr
    bl CLDPP_CUMULATIVE
    ldr w10,[sp,#600]
    sub w10,w10,#1
    ldr x9,[sp,#560]
    ldr d0,[x9,x10,lsl #3]
    PUT d0,22,x24
    ldr x9,[sp,#536]
    add x9,x9,x24,lsl #3
    ldr w10,[x9]
    mov x11,#0
    str w10,[sp,#600]
    add x0,sp,#600
    ldr x1,[sp,#544]
    add x1,x1,x11,lsl #3
    ldr x2,[sp,#552]
    add x2,x2,x11,lsl #3
    ldr x3,[sp,#560]
    ldr x4,[sp,#568]
    mov x5,xzr
    bl CLDPP_CUMULATIVE
    ldr w10,[sp,#600]
    sub w10,w10,#1
    ldr x9,[sp,#560]
    ldr d0,[x9,x10,lsl #3]
    PUT d0,19,x24
    ldr x9,[sp,#536]
    add x9,x9,x24,lsl #3
    ldr w11,[x9]
    ldr w10,[x9,#4]
    sub w10,w10,w11
    str w10,[sp,#600]
    add x0,sp,#600
    ldr x1,[sp,#544]
    add x1,x1,x11,lsl #3
    ldr x2,[sp,#552]
    add x2,x2,x11,lsl #3
    ldr x3,[sp,#560]
    ldr x4,[sp,#568]
    mov x5,xzr
    bl CLDPP_CUMULATIVE
    ldr w10,[sp,#600]
    sub w10,w10,#1
    ldr x9,[sp,#560]
    ldr d0,[x9,x10,lsl #3]
    PUT d0,21,x24
    ldr x9,[sp,#536]
    add x9,x9,x24,lsl #3
    ldr w11,[x9,#4]
    sub w10,w21,w11
    str w10,[sp,#600]
    add x0,sp,#600
    ldr x1,[sp,#544]
    add x1,x1,x11,lsl #3
    ldr x2,[sp,#552]
    add x2,x2,x11,lsl #3
    ldr x3,[sp,#560]
    ldr x4,[sp,#568]
    mov x5,xzr
    bl CLDPP_CUMULATIVE
    ldr w10,[sp,#600]
    sub w10,w10,#1
    ldr x9,[sp,#560]
    ldr d0,[x9,x10,lsl #3]
    PUT d0,20,x24

    add x24,x24,#1
    b .Lcldpp_column
.Lcldpp_mask:
    cmp x22,x23
    b.ge .Lcldpp_done
    ldr d1,[sp,#480]
    ldr d2,[x28]
    fsub d2,d2,d1
    mov x25,#0
.Lcldpp_mask_level:
    mov x24,x22
.Lcldpp_mask_column:
    madd x26,x25,x20,x24
    FIELD d0,11
    fmaxnm d0,d0,d1
    fminnm d0,d0,d2
    PUT d0,23
    fcmp d0,d1
    b.le .Lcldpp_clear_water
    FIELD d0,12
    PUT d0,25
    FIELD d0,13
    PUT d0,24
    b .Lcldpp_mask_next
.Lcldpp_clear_water:
    fmov d0,xzr
    PUT d0,25
    PUT d0,24
.Lcldpp_mask_next:
    add x24,x24,#1
    cmp x24,x23
    b.lt .Lcldpp_mask_column
    add x25,x25,#1
    cmp x25,x21
    b.lt .Lcldpp_mask_level
.Lcldpp_done:
    cbz x27,.Lcldpp_restore
    mov x0,x27
    bl free
.Lcldpp_restore:
    ldp d8,d9,[sp,#400]
    ldp d10,d11,[sp,#416]
    ldp d12,d13,[sp,#432]
    ldp d14,d15,[sp,#448]
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp x29,x30,[sp,#96]
    add sp,sp,#768
    ret
.Lcldpp_bad:
    bl abort
.size CLDPP_SYMBOL,.-CLDPP_SYMBOL
.section .rodata
.p2align 4
.Lcldpp_constants:
    .double 1.0,0.5,0.001
.p2align 4
.Lcldpp_latitudes:
    .quad 0x3ff7f2e9650529f4,0x3fefe995e70409b6
    .quad 0x3ff66a4f3f0a78ff,0x3fef8a212714bcdc
    .quad 0x3ff4df6394c3a8dc,0x3feedf5518053baa
    .quad 0x3ff353f1d9ef99b5,0x3fedeac0259f7f42
    .quad 0x3ff1c84d4f66f7f5,0x3fecaea9b4574cb9
    .quad 0x3ff03c903a9fd6d6,0x3feb2e04fd686a13
    .quad 0x3fed618af8d6485b,0x3fe96c69481c4bc5
    .quad 0x3fea49e4cc01ba6d,0x3fe76e0931d693ba
    .quad 0x3fe73233c1c07c3e,0x3fe537a89c487f89
    .quad 0x3fe41a7b5283a5a0,0x3fe2ce9146962ca5
    .quad 0x3fe102bdb452ba1a,0x3fe038862866b29e
    .quad 0x3fdbd5f8c9b823e5,0x3fdaf76b57c6f8f1
    .quad 0x3fd5a670e661da05,0x3fd53d55ce57bdf7
    .quad 0x3fceedcaa7be5cb2,0x3fcea0f7e19c0949
    .quad 0x3fc28eaea3e5e152,0x3fc27e0ea717f236
    .quad 0x3fa8be3f640a1669,0x3fa8bbc8488cc499
    .quad 0xbfa8be3f640a1669,0xbfa8bbc8488cc499
    .quad 0xbfc28eaea3e5e152,0xbfc27e0ea717f236
    .quad 0xbfceedcaa7be5cb2,0xbfcea0f7e19c0949
    .quad 0xbfd5a670e661da05,0xbfd53d55ce57bdf7
    .quad 0xbfdbd5f8c9b823e5,0xbfdaf76b57c6f8f1
    .quad 0xbfe102bdb452ba1a,0xbfe038862866b29e
    .quad 0xbfe41a7b5283a5a0,0xbfe2ce9146962ca5
    .quad 0xbfe73233c1c07c3e,0xbfe537a89c487f89
    .quad 0xbfea49e4cc01ba6d,0xbfe76e0931d693ba
    .quad 0xbfed618af8d6485b,0xbfe96c69481c4bc5
    .quad 0xbff03c903a9fd6d6,0xbfeb2e04fd686a13
    .quad 0xbff1c84d4f66f7f5,0xbfecaea9b4574cb9
    .quad 0xbff353f1d9ef99b5,0xbfedeac0259f7f42
    .quad 0xbff4df6394c3a8dc,0xbfeedf5518053baa
    .quad 0xbff66a4f3f0a78ff,0xbfef8a212714bcdc
    .quad 0xbff7f2e9650529f4,0xbfefe995e70409b6
.section .note.GNU-stack,"",%progbits
