/* Lake radiation transmission and layer means P01.
 * Physics formulations/openifs/surface/lake_radiation.md.
 * Contract skills/md2asm/references/openifs/surface/lake_radiation.md.
 * Sixteen addresses and independent signed GNU rank-one strides.
 * x19 column, x20 end, x21 water bands, x22 ice bands, x23 lake.
 * x24 owner records, x25 band, x26 band count, x27 pool, x28 flags.
 * Preserve x18, x19..x29, d8..d15, aligned SP and FPCR. */
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL __flakerad_mod_MOD_flakerad
#endif
.text
.p2align 4
.macro OWNER desc,field,shift=3
    ldr x9,[x\desc]
    ldr x10,[x\desc,#40]
    cmp x10,#0
    mov x11,#1
    csel x10,x10,x11,ne
    lsl x10,x10,#\shift
    stp x9,x10,[x24,#(\field*16)]
.endm
.macro ADDRESS field
    ldp x9,x10,[x24,#(\field*16)]
    madd x9,x19,x10,x9
.endm
.macro LOAD reg,field
    ADDRESS \field
    ldr d\reg,[x9]
.endm
.macro STORE reg,field
    ADDRESS \field
    str d\reg,[x9]
.endm
.global md2asm_lake_radiation
.type md2asm_lake_radiation,%function
md2asm_lake_radiation:
    mov x16,sp
    sub sp,sp,#416
    stp x19,x20,[sp,#0]
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x25,x26,[sp,#48]
    stp x27,x28,[sp,#64]
    stp x29,x30,[sp,#80]
    stp d8,d9,[sp,#96]
    stp d10,d11,[sp,#112]
    stp d12,d13,[sp,#128]
    stp d14,d15,[sp,#144]
    mov x29,sp
    ldr w19,[x0]
    sub x19,x19,#1
    ldr w20,[x1]
    mov x21,x4
    mov x22,x5
    mov x23,x6
    add x24,sp,#160
    OWNER 2,0,2
    OWNER 3,1
    OWNER 7,2
    ldr x0,[x16,#0]
    OWNER 0,3
    ldr x0,[x16,#8]
    OWNER 0,4
    ldr x0,[x16,#16]
    OWNER 0,5
    ldr x0,[x16,#24]
    OWNER 0,6
    ldr x0,[x16,#32]
    OWNER 0,7
    ldr x0,[x16,#40]
    OWNER 0,8
    ldr x0,[x16,#48]
    OWNER 0,9
    ldr x0,[x16,#56]
    OWNER 0,10
    adrp x27,.Lconstants
    add x27,x27,:lo12:.Lconstants
    cmp x19,x20
    b.ge .Lreturn
.Lcolumn:
    ADDRESS 0
    ldr w9,[x9]
    cbz w9,.Lnext
    LOAD 8,1
    ldr d0,[x27,#16]
    fmax d8,d0,d8
    ldr d0,[x27,#24]
    fmin d8,d0,d8
    LOAD 9,4
    LOAD 10,2
    STORE 10,5
    LOAD 0,3
    str d0,[sp,#336]
    ldr d1,[x23,#192]
    fcmp d0,d1
    b.lt .Lno_ice
    ldr d11,[x27]
    mov x25,#0
    ldr w26,[x22]
.Lice_band:
    add x9,x22,#56
    ldr d0,[x9,x25,lsl #3]
    fneg d0,d0
    ldr d1,[sp,#336]
    fmul d0,d0,d1
    bl exp
    add x9,x22,#8
    ldr d1,[x9,x25,lsl #3]
    fmul d0,d1,d0
    fadd d11,d11,d0
    add x25,x25,#1
    cmp x25,x26
    b.lt .Lice_band
    fmul d11,d10,d11
    b .Lwater_setup
.Lno_ice:
    fmov d11,d10
.Lwater_setup:
    STORE 11,7
    ldr d0,[x23,#200]
    fcmp d9,d0
    cset w28,ge
    fsub d0,d8,d0
    fcmp d9,d0
    cset w9,le
    orr w28,w28,w9,lsl #1
    ldr d12,[x27]
    fmov d13,d12
    fmov d14,d12
    fmov d15,d12
    mov x25,#0
    ldr w26,[x21]
.Lwater_band:
    cbz w28,.Ldepth_exponential
    add x9,x21,#56
    ldr d0,[x9,x25,lsl #3]
    fneg d0,d0
    fmul d0,d0,d9
    bl exp
    str d0,[sp,#344]
.Ldepth_exponential:
    add x9,x21,#56
    ldr d0,[x9,x25,lsl #3]
    fneg d0,d0
    fmul d0,d0,d8
    bl exp
    str d0,[sp,#352]
    add x9,x21,#8
    ldr d1,[x9,x25,lsl #3]
    fmul d2,d1,d0
    fadd d13,d13,d2
    cbz w28,.Lwater_next
    add x9,x21,#56
    ldr d2,[x9,x25,lsl #3]
    fdiv d2,d1,d2
    ldr d0,[sp,#344]
    tbz w28,#0,.Ldeep_mean
    fmul d3,d1,d0
    fadd d12,d12,d3
    ldr d3,[x27,#8]
    fsub d3,d3,d0
    fmul d3,d2,d3
    fadd d14,d14,d3
.Ldeep_mean:
    tbz w28,#1,.Lwater_next
    ldr d3,[sp,#352]
    fsub d3,d0,d3
    fmul d3,d2,d3
    fadd d15,d15,d3
.Lwater_next:
    add x25,x25,#1
    cmp x25,x26
    b.lt .Lwater_band
    fmul d0,d11,d13
    STORE 0,6
    tbz w28,#0,.Lthin_mixed
    fmul d12,d11,d12
    fmul d14,d11,d14
    fdiv d14,d14,d9
    b .Lmixed_outputs
.Lthin_mixed:
    fmov d12,d11
    fmov d14,d12
.Lmixed_outputs:
    STORE 12,8
    STORE 14,9
    tbz w28,#1,.Lno_deep
    fmul d15,d11,d15
    fsub d0,d8,d9
    fdiv d15,d15,d0
    b .Ldeep_output
.Lno_deep:
    fmov d15,d12
.Ldeep_output:
    STORE 15,10
.Lnext:
    add x19,x19,#1
    cmp x19,x20
    b.lt .Lcolumn
.Lreturn:
    ldp x19,x20,[sp,#0]
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x25,x26,[sp,#48]
    ldp x27,x28,[sp,#64]
    ldp x29,x30,[sp,#80]
    ldp d8,d9,[sp,#96]
    ldp d10,d11,[sp,#112]
    ldp d12,d13,[sp,#128]
    ldp d14,d15,[sp,#144]
    add sp,sp,#416
    ret
.size md2asm_lake_radiation,.-md2asm_lake_radiation
.global ORIGINAL_SYMBOL
.type ORIGINAL_SYMBOL,%function
ORIGINAL_SYMBOL:
    b md2asm_lake_radiation
.size ORIGINAL_SYMBOL,.-ORIGINAL_SYMBOL
.section .rodata
.p2align 3
.Lconstants:
    .double 0.0,1.0,2.0,50.0
.section .note.GNU-stack,"",%progbits
