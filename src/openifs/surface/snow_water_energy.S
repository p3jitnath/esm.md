/* Layered snow water and heat P01.
 * Physics formulations/openifs/surface/snow_water_energy.md.
 * Contract skills/md2asm/references/openifs/surface/snow_water_energy.md.
 * Thirty addresses and independent signed GNU descriptor strides.
 * x19 column, x20 end, x21 total layers, x22 owner records, x23 scratch.
 * x24 active layers, x25 layer, x26 soil, x27 constants, x28 vectors.
 * Preserve x18, x19..x29, d8..d15, aligned SP and FPCR. */
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL __srfsn_webal_mod_MOD_srfsn_webal
#endif
#ifndef TRISOLVER_SYMBOL
#define TRISOLVER_SYMBOL md2asm_snow_trisolver
#endif
.text
.p2align 4
.macro OWNER desc,field,rank,shift=3
    add x12,x22,#(\field*32)
    ldr x9,[x\desc]
    ldr x11,[x\desc,#40]
    cmp x11,#0
    mov x10,#1
    csel x11,x11,x10,ne
    lsl x11,x11,#\shift
    stp x9,x11,[x12]
    .if \rank >= 2
      ldr x11,[x\desc,#64]
      lsl x11,x11,#\shift
    .else
      mov x11,#0
    .endif
    str x11,[x12,#16]
    .if \rank == 3
      ldr x11,[x\desc,#88]
      lsl x11,x11,#3
    .else
      mov x11,#0
    .endif
    str x11,[x12,#24]
.endm
.macro ADDRESS field,rank,layer=25,component=0
    add x10,x22,#(\field*32)
    ldp x9,x11,[x10]
    madd x9,x19,x11,x9
    .if \rank >= 2
      ldr x11,[x10,#16]
      madd x9,x\layer,x11,x9
    .endif
    .if \rank == 3
      ldr x11,[x10,#24]
      mov x12,#\component
      madd x9,x12,x11,x9
    .endif
.endm
.macro LOAD reg,field,rank=1,layer=25,component=0
    ADDRESS \field,\rank,\layer,\component
    ldr d\reg,[x9]
.endm
.macro STORE reg,field,rank=1,layer=25,component=0
    ADDRESS \field,\rank,\layer,\component
    str d\reg,[x9]
.endm
.macro GET reg,vec,layer=25
    ldr x9,[x28,#(\vec*8)]
    ldr d\reg,[x9,x\layer,lsl #3]
.endm
.macro SET reg,vec,layer=25
    ldr x9,[x28,#(\vec*8)]
    str d\reg,[x9,x\layer,lsl #3]
.endm
.macro COPY_T
    mov x25,#0
.Lcopy_t\@:
    LOAD 0,5,2
    SET 0,9
    add x25,x25,#1
    cmp x25,x21
    b.lt .Lcopy_t\@
.endm
.macro GROUND
    sub x25,x24,#1
    GET 0,9
    LOAD 1,6
    fsub d0,d0,d1
    GET 1,4,24
    fmul d0,d1,d0
    str d0,[x29,#904]
.endm
.global md2asm_snow_water_energy
.type md2asm_snow_water_energy,%function
md2asm_snow_water_energy:
    mov x16,sp
    sub sp,sp,#1360
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
    ldr w21,[x3]
    add x22,x29,#160
    ldr x26,[x16,#88]
    ldr x17,[x16,#96]
    ldr d8,[x26,#312]
    ldr d0,[x26,#296]
    fdiv d8,d8,d0
    ldr d9,[x17]
    ldr d10,[x17,#64]
    ldr d11,[x4]
    adrp x27,.Lconstants
    add x27,x27,:lo12:.Lconstants
    ldr d0,[x27,#8]
    fdiv d12,d0,d11
    ldr x9,[x26,#1648]
    ldr x10,[x26,#1656]
    add x10,x10,#1
    ldr d13,[x9,x10,lsl #3]
    ldr d14,[x27,#56]
    ldr d15,[x27,#64]
    OWNER 5,0,1,2
    OWNER 6,1,1
    OWNER 7,2,2
    ldr x0,[x16,#0]
    OWNER 0,3,2
    ldr x0,[x16,#8]
    OWNER 0,4,2
    ldr x0,[x16,#16]
    OWNER 0,5,2
    ldr x0,[x16,#24]
    OWNER 0,6,1
    ldr x0,[x16,#32]
    OWNER 0,7,1
    ldr x0,[x16,#40]
    OWNER 0,8,2
    ldr x0,[x16,#48]
    OWNER 0,9,1
    ldr x0,[x16,#56]
    OWNER 0,10,1
    ldr x0,[x16,#64]
    OWNER 0,11,1
    ldr x0,[x16,#72]
    OWNER 0,12,1
    ldr x0,[x16,#80]
    OWNER 0,13,1
    ldr x0,[x16,#104]
    OWNER 0,14,2
    ldr x0,[x16,#112]
    OWNER 0,15,2
    ldr x0,[x16,#120]
    OWNER 0,16,2
    ldr x0,[x16,#128]
    OWNER 0,17,1
    ldr x0,[x16,#136]
    OWNER 0,18,1
    ldr x0,[x16,#144]
    OWNER 0,19,2
    ldr x0,[x16,#152]
    OWNER 0,20,2
    ldr x0,[x16,#160]
    OWNER 0,21,3
    ldr x0,[x16,#168]
    OWNER 0,22,3
    mov w9,#1
    ldr x0,[x16,#160]
    ldr x1,[x16,#168]
    ldr x10,[x0,#56]
    ldr x11,[x0,#48]
    cmp x10,x11
    cset w10,ge
    and w9,w9,w10
    ldr x10,[x1,#56]
    ldr x11,[x1,#48]
    cmp x10,x11
    cset w10,ge
    and w9,w9,w10
    ldr x10,[x0,#80]
    ldr x11,[x0,#72]
    cmp x10,x11
    cset w10,ge
    and w9,w9,w10
    ldr x10,[x1,#80]
    ldr x11,[x1,#72]
    cmp x10,x11
    cset w10,ge
    and w9,w9,w10
    ldr x10,[x0,#104]
    ldr x11,[x0,#96]
    cmp x10,x11
    cset w10,ge
    and w9,w9,w10
    ldr x10,[x1,#104]
    ldr x11,[x1,#96]
    cmp x10,x11
    cset w10,ge
    and w9,w9,w10
    str w9,[x29,#900]
    cmp x19,x20
    b.ge .Lreturn
    mov x9,#104
    mul x9,x21,x9
    add x9,x9,#31
    and x9,x9,#-16
    sub sp,sp,x9
    mov x23,sp
    add x28,x29,#928
    mov x9,x23
    lsl x10,x21,#3
    str x9,[x28,#0]
    add x9,x9,x10
    str x9,[x28,#8]
    add x9,x9,x10
    str x9,[x28,#16]
    add x9,x9,x10
    str x9,[x28,#24]
    add x9,x9,x10
    str x9,[x28,#32]
    add x9,x9,x10
    add x9,x9,#8
    str x9,[x28,#40]
    add x9,x9,x10
    str x9,[x28,#48]
    add x9,x9,x10
    str x9,[x28,#56]
    add x9,x9,x10
    str x9,[x28,#64]
    add x9,x9,x10
    str x9,[x28,#72]
    add x9,x9,x10
    str x9,[x28,#80]
    add x9,x9,x10
    str x9,[x28,#88]
    add x9,x9,x10
    str x9,[x28,#96]
    add x9,x9,x10
    add x9,x9,#8
    mov x12,#0
.Ldescriptor:
    add x0,x29,#1040
    add x0,x0,x12,lsl #6
    add x9,x12,#5
    ldr x9,[x28,x9,lsl #3]
    str x9,[x0]
    mov x9,#-1
    str x9,[x0,#8]
    mov x9,#8
    str x9,[x0,#16]
    str wzr,[x0,#24]
    mov w9,#0x301
    strh w9,[x0,#28]
    strh wzr,[x0,#30]
    mov x9,#8
    str x9,[x0,#32]
    mov x9,#1
    str x9,[x0,#40]
    str x9,[x0,#48]
    str x21,[x0,#56]
    add x12,x12,#1
    cmp x12,#5
    b.lt .Ldescriptor
.Lcolumn:
    ADDRESS 0,1
    ldr w9,[x9]
    cbnz w9,.Lbare
    mov x24,#0
    mov x25,#0
.Lactive:
    LOAD 0,2,2
    fcmp d0,d14
    add x9,x25,#1
    csel x24,x9,x24,gt
    add x25,x25,#1
    cmp x25,x21
    b.lt .Lactive
    str w24,[x29,#896]
    mov x25,#0
.Lmaterial:
    LOAD 0,2,2
    LOAD 1,3,2
    fsub d2,d0,d1
    SET 2,2
    LOAD 3,4,2
    fdiv d0,d0,d3
    ldr d4,[x26,#416]
    fmin d0,d4,d0
    SET 0,0
    fdiv d2,d2,d3
    fmin d2,d4,d2
    fmul d0,d8,d3
    fmul d0,d0,d2
    fmul d1,d15,d1
    fadd d0,d0,d1
    fmul d0,d0,d12
    SET 0,1
    LOAD 0,5,2
    ldr d1,[x26,#2104]
    fsub d0,d0,d1
    ldr d1,[x26,#2096]
    fdiv d0,d1,d0
    ldr d1,[x26,#2088]
    fsub d0,d1,d0
    ldr d1,[x27]
    fmax d0,d1,d0
    LOAD 1,13
    ldr d2,[x26,#2112]
    fdiv d1,d2,d1
    fmul d0,d1,d0
    ldr d1,[x27,#32]
    fmul d1,d1,d3
    fmul d1,d1,d3
    ldr d2,[x27,#40]
    fmul d2,d2,d3
    fsub d1,d1,d2
    ldr d2,[x27,#48]
    fadd d1,d1,d2
    fadd d0,d1,d0
    SET 0,3
    add x25,x25,#1
    cmp x25,x21
    b.lt .Lmaterial
    cmp x24,#1
    b.ne .Linterfaces
    mov x25,#0
    GET 0,1
    fmax d0,d14,d0
    SET 0,1
.Linterfaces:
    mov x25,#0
    LOAD 0,1
    GET 1,3
    fmul d0,d0,d1
    GET 1,0
    ldr d2,[x27,#24]
    fmul d1,d2,d1
    fmul d1,d1,d1
    fmax d1,d14,d1
    fdiv d0,d0,d1
    SET 0,4
    mov x25,#1
.Linternal:
    cmp x25,x24
    b.ge .Lbottom
    sub x17,x25,#1
    GET 0,0,17
    GET 1,3,17
    GET 2,0
    GET 3,3
    fmul d1,d0,d1
    fmul d3,d2,d3
    fadd d1,d1,d3
    LOAD 3,1
    ldr d4,[x27,#16]
    fmul d3,d3,d4
    fmul d1,d3,d1
    fadd d0,d0,d2
    fmul d0,d0,d0
    fmax d0,d14,d0
    fdiv d0,d1,d0
    SET 0,4
    add x25,x25,#1
    b .Linternal
.Lbottom:
    sub x25,x24,#1
    GET 0,0
    GET 1,3
    fmul d1,d0,d1
    LOAD 2,12
    fmul d2,d13,d2
    fadd d1,d1,d2
    LOAD 2,1
    fmul d1,d2,d1
    fadd d0,d0,d13
    fmul d0,d0,d0
    fmax d0,d14,d0
    fdiv d0,d1,d0
    SET 0,4,24
    cmp x24,#1
    b.eq .Lsingle
    mov x25,#0
.Lmatrix:
    ldr d0,[x27]
    cbz x25,.Lfirst_row
    GET 0,4
    fneg d0,d0
.Lfirst_row:
    SET 0,5
    GET 0,1
    cbz x25,.Ldiagonal_upper
    GET 1,4
    fadd d0,d0,d1
.Ldiagonal_upper:
    add x17,x25,#1
    GET 1,4,17
    fadd d0,d0,d1
    SET 0,6
    cmp x17,x24
    ldr d0,[x27]
    b.eq .Llast_upper
    fneg d0,d1
.Llast_upper:
    SET 0,7
    GET 0,1
    LOAD 1,5,2
    fmul d0,d0,d1
    cbz x25,.Lfirst_rhs
    cmp x17,x24
    b.ne .Lradiation_rhs
    LOAD 1,6
    GET 2,4,24
    fmul d1,d2,d1
    fadd d0,d0,d1
.Lradiation_rhs:
    LOAD 1,8,2
    fadd d0,d0,d1
    b .Lstore_rhs
.Lfirst_rhs:
    LOAD 1,7
    LOAD 2,8,2
    fsub d1,d1,d2
    fadd d0,d1,d0
.Lstore_rhs:
    SET 0,8
    add x25,x25,#1
    cmp x25,x24
    b.lt .Lmatrix
    COPY_T
    bl .Lsolve
    GROUND
    b .Ltop_melting
.Lsingle:
    COPY_T
    mov x25,#0
    GET 0,1
    mov x17,#1
    GET 1,4,17
    fadd d0,d0,d1
    SET 0,6
    LOAD 0,7
    LOAD 2,8,2
    fsub d0,d0,d2
    GET 2,1
    LOAD 3,5,2
    fmul d2,d2,d3
    fadd d0,d0,d2
    LOAD 2,6
    fmul d1,d1,d2
    fadd d0,d0,d1
    SET 0,8
    GET 1,6
    fdiv d0,d0,d1
    SET 0,9
    GROUND
.Ltop_melting:
    mov x25,#0
    GET 0,9
    fcmp d0,d9
    b.le .Lphase_setup
    cmp x24,#1
    b.eq .Lsingle_melting
    ldr d0,[x27,#8]
    SET 0,6
    ldr d0,[x27]
    SET 0,7
    SET 9,8
    COPY_T
    bl .Lsolve
    GROUND
    mov x25,#0
    GET 0,9
    mov x17,#1
    GET 1,9,17
    fsub d0,d0,d1
    GET 1,4,17
    fmul d0,d1,d0
    b .Lexplicit_top
.Lsingle_melting:
    LOAD 0,6
    fsub d0,d9,d0
    mov x17,#1
    GET 1,4,17
    fmul d0,d1,d0
    str d0,[x29,#904]
.Lexplicit_top:
    LOAD 1,7
    LOAD 2,8,2
    fsub d1,d1,d2
    GET 2,1
    LOAD 3,5,2
    fmul d3,d2,d3
    fadd d1,d1,d3
    fsub d0,d1,d0
    fmax d2,d14,d2
    fdiv d0,d0,d2
    SET 0,9
.Lphase_setup:
    mov x25,#0
    ldr d3,[x27]
.Lcopy_mass:
    GET 0,2
    SET 0,10
    LOAD 0,3,2
    SET 0,11
    SET 3,12
    STORE 3,19,2
    STORE 3,20,2
    add x25,x25,#1
    cmp x25,x21
    b.lt .Lcopy_mass
    SET 3,12
    mov x25,#0
    LOAD 0,9
    LOAD 1,11
    fadd d0,d0,d1
    fmul d0,d11,d0
    GET 1,2
    fadd d0,d1,d0
    SET 0,10
    LOAD 0,10
    fmul d0,d11,d0
    SET 0,12
    str d3,[x29,#912]
.Lphase:
    LOAD 0,3,2
    GET 1,12
    fadd d0,d0,d1
    SET 0,11
    GET 1,1
    GET 2,9
    fsub d3,d2,d9
    fmul d3,d1,d3
    fmul d4,d10,d12
    GET 5,10
    fmul d4,d4,d5
    fmin d4,d3,d4
    ldr d6,[x27]
    fmax d4,d6,d4
    STORE 4,19,2
    fneg d5,d10
    fmul d5,d5,d12
    fmul d5,d5,d0
    fmax d5,d3,d5
    fmin d5,d6,d5
    STORE 5,20,2
    fadd d4,d4,d5
    ldr d5,[x29,#912]
    fadd d5,d4,d5
    fmax d3,d14,d1
    fdiv d5,d5,d3
    fsub d2,d2,d5
    fcmp d2,d9
    b.le .Lno_residual
    fsub d5,d9,d2
    fmul d5,d1,d5
    str d5,[x29,#912]
    fmov d2,d9
    b .Lphase_temperature
.Lno_residual:
    str d6,[x29,#912]
.Lphase_temperature:
    SET 2,9
    fdiv d4,d4,d10
    fmul d4,d4,d11
    fadd d0,d0,d4
    SET 0,11
    GET 1,10
    fsub d1,d1,d4
    SET 1,10
    ldr d2,[x26,#1776]
    LOAD 3,4,2
    fsub d3,d2,d3
    fmax d3,d6,d3
    ldr d4,[x26,#1784]
    ldr d5,[x26,#1792]
    fsub d5,d5,d4
    fmul d3,d5,d3
    fdiv d3,d3,d2
    fadd d3,d4,d3
    fmul d3,d1,d3
    fsub d2,d0,d3
    fmax d2,d6,d2
    add x17,x25,#1
    SET 2,12,17
    fsub d0,d0,d2
    SET 0,11
    add x25,x25,#1
    cmp x25,x24
    b.lt .Lphase
    sub x17,x24,#1
    GET 0,9,17
.Linactive_temperature:
    cmp x25,x21
    b.ge .Lfinal
    SET 0,9
    add x25,x25,#1
    b .Linactive_temperature
.Lfinal:
    mov x25,#0
    ldr d3,[x27]
.Lreturn_layers:
    GET 0,9
    fmin d0,d9,d0
    STORE 0,16,2
    GET 0,11
    GET 1,10
    fadd d1,d0,d1
    fmax d1,d3,d1
    STORE 1,14,2
    fmax d0,d3,d0
    fmin d0,d1,d0
    STORE 0,15,2
    add x25,x25,#1
    cmp x25,x21
    b.lt .Lreturn_layers
    GET 0,12,24
    fmul d0,d0,d12
    STORE 0,18
    ldr d0,[x29,#904]
    ldr d1,[x29,#912]
    fsub d0,d0,d1
    LOAD 1,8,2,24
    fadd d0,d0,d1
    STORE 0,17
    ldr w9,[x29,#900]
    cbz w9,.Lnext
    mov x25,#0
.Ldiagnostics:
    GET 0,1
    fmul d0,d0,d11
    STORE 0,21,3,25,0
    LOAD 1,5,2
    STORE 1,21,3,25,1
    fmul d2,d0,d1
    STORE 2,21,3,25,2
    LOAD 2,2,2
    LOAD 3,4,2
    fdiv d3,d2,d3
    STORE 3,21,3,25,3
    mov x17,#0
    LOAD 3,17
    STORE 3,21,3,17,12
    LOAD 3,19,2
    LOAD 4,20,2
    fadd d3,d3,d4
    STORE 3,21,3,25,13
    LOAD 4,16,2
    fsub d4,d4,d1
    fmul d4,d0,d4
    STORE 4,21,3,25,14
    STORE 2,22,3,25,0
    LOAD 4,11
    STORE 4,22,3,25,3
    fdiv d3,d3,d10
    STORE 3,22,3,25,4
    add x25,x25,#1
    cmp x25,x21
    b.lt .Ldiagnostics
    b .Lnext
.Lbare:
    mov x25,#0
    LOAD 0,2,2
    LOAD 1,9
    LOAD 2,11
    fadd d1,d1,d2
    fmul d1,d11,d1
    fadd d0,d0,d1
    ldr d3,[x27]
    fmax d0,d3,d0
    STORE 0,14,2
.Lbare_layers:
    cbz x25,.Lbare_mass_done
    STORE 3,14,2
.Lbare_mass_done:
    STORE 9,16,2
    STORE 3,15,2
    STORE 3,19,2
    STORE 3,20,2
    ldr w9,[x29,#900]
    cbz w9,.Lbare_next
    STORE 3,21,3,25,0
    STORE 9,21,3,25,1
    STORE 3,21,3,25,2
    STORE 3,21,3,25,3
    STORE 3,21,3,25,12
    STORE 3,21,3,25,13
    STORE 3,21,3,25,14
    STORE 3,22,3,25,0
    STORE 3,22,3,25,3
    STORE 3,22,3,25,4
.Lbare_next:
    add x25,x25,#1
    cmp x25,x21
    b.lt .Lbare_layers
    STORE 3,17
    STORE 3,18
.Lnext:
    add x19,x19,#1
    cmp x19,x20
    b.lt .Lcolumn
.Lreturn:
    mov sp,x29
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
    add sp,sp,#1360
    ret
.Lsolve:
    add x0,x29,#896
    add x1,x29,#1040
    add x2,x29,#1104
    add x3,x29,#1168
    add x4,x29,#1232
    add x5,x29,#1296
    b TRISOLVER_SYMBOL
.size md2asm_snow_water_energy,.-md2asm_snow_water_energy
.global ORIGINAL_SYMBOL
.type ORIGINAL_SYMBOL,%function
ORIGINAL_SYMBOL:
    b md2asm_snow_water_energy
.size ORIGINAL_SYMBOL,.-ORIGINAL_SYMBOL
.section .rodata
.p2align 3
.Lconstants:
    .double 0.0,1.0,2.0,0.5,2.5e-6,1.23e-4,0.024,2.220446049250313e-15,4180.0
.section .note.GNU-stack,"",%progbits
