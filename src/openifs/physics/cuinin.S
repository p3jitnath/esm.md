// Physics input formulations/openifs/physics/convective_initial_state.md.
// Contract skills/md2asm/references/openifs/physics/cuinin.md.
#ifndef CUININ_SYMBOL
#define CUININ_SYMBOL cuinin_
#endif
.text
.p2align 4
.global CUININ_SYMBOL
.type CUININ_SYMBOL,%function
CUININ_SYMBOL:
    ldr w9,[x0,#4]
    cbnz w9,.Ldomain
    stp x29,x30,[sp,#-384]!
    mov x29,sp
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    str x0,[sp,#112]
    str x1,[sp,#120]
    str x2,[sp,#128]
    str x3,[sp,#136]
    str x4,[sp,#144]
    str x5,[sp,#152]
    str x6,[sp,#160]
    str x7,[sp,#168]
    ldr x9,[x29,#384]
    str x9,[sp,#176]
    ldr x9,[x29,#392]
    str x9,[sp,#184]
    ldr x9,[x29,#400]
    str x9,[sp,#192]
    ldr x9,[x29,#408]
    str x9,[sp,#200]
    ldr x9,[x29,#416]
    str x9,[sp,#208]
    ldr x9,[x29,#424]
    str x9,[sp,#216]
    ldr x9,[x29,#432]
    str x9,[sp,#224]
    ldr x9,[x29,#440]
    str x9,[sp,#232]
    ldr x9,[x29,#448]
    str x9,[sp,#240]
    ldr x9,[x29,#456]
    str x9,[sp,#248]
    ldr x9,[x29,#464]
    str x9,[sp,#256]
    ldr x9,[x29,#472]
    str x9,[sp,#264]
    ldr x9,[x29,#480]
    str x9,[sp,#272]
    ldr x9,[x29,#488]
    str x9,[sp,#280]
    ldr x9,[x29,#496]
    str x9,[sp,#288]
    ldr x9,[x29,#504]
    str x9,[sp,#296]
    ldr x9,[x29,#512]
    str x9,[sp,#304]
    ldr x9,[x29,#520]
    str x9,[sp,#312]
    ldr x9,[x29,#528]
    str x9,[sp,#320]

    ldr x9,[x29,#128]
    ldr w19,[x9]
    ldr x9,[x29,#136]
    ldr w20,[x9]
    ldr x9,[x29,#144]
    ldr w21,[x9]
    ldr x9,[x29,#152]
    ldr w22,[x9]
    cmp w21,#1
    b.lt .Ldomain
    cmp w22,#1
    b.lt .Ldomain
    cmp w19,#1
    b.lt .Ldomain
    cmp w20,w21
    b.gt .Ldomain
    cmp w19,w20
    b.gt .Lreturn
    uxtw x21,w21
    uxtw x22,w22
    mul x26,x21,x22
    mov x9,#12
    mul x9,x21,x9
    add x9,x9,#47
    and x9,x9,#-16
    mov x10,#1048576
    cmp x9,x10
    b.hi .Ldomain
    sub sp,sp,x9
    add x27,sp,#32
    str x27,[x29,#352]
    add x28,x27,x21,lsl #3
    str x28,[x29,#360]
    ldr x9,[x29,#120]
    ldr w9,[x9,#312]
    str w9,[x29,#368]
    mov w9,#3
    str w9,[x29,#348]
    adrp x9,:got:__yomcst_MOD_rcpd
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rcpd]
    ldr d0,[x9]
    str d0,[x29,#328]
    fmov d1,#1.0
    fdiv d1,d1,d0
    str d1,[x29,#336]
    mov x23,#1
.Lhalf_row:
    cmp x23,x22
    b.ge .Lboundaries
    sub w24,w19,#1
.Lhalf_column:
    madd x25,x23,x21,x24
    sub x16,x25,x21
    ldr x9,[x29,#160]
    ldr d0,[x9,x16,lsl #3]
    ldr d1,[x9,x25,lsl #3]
    ldr d2,[x29,#328]
    fmul d0,d2,d0
    fmul d1,d2,d1
    ldr x9,[x29,#200]
    ldr d3,[x9,x16,lsl #3]
    ldr d4,[x9,x25,lsl #3]
    fadd d0,d0,d3
    fadd d1,d1,d4
    fmaxnm d0,d0,d1
    ldr x9,[x29,#248]
    ldr d1,[x9,x25,lsl #3]
    fsub d0,d0,d1
    ldr d1,[x29,#336]
    fmul d0,d0,d1
    ldr x9,[x29,#224]
    str d0,[x9,x25,lsl #3]
    ldr x9,[x29,#168]
    ldr d0,[x9,x16,lsl #3]
    ldr x9,[x29,#232]
    str d0,[x9,x25,lsl #3]
    ldr x9,[x29,#176]
    ldr d0,[x9,x16,lsl #3]
    ldr x9,[x29,#240]
    str d0,[x9,x25,lsl #3]
    ldr x9,[x29,#208]
    ldr d0,[x9,x25,lsl #3]
    str d0,[x27,x24,lsl #3]
    mov w9,#1
    str w9,[x28,x24,lsl #2]
    add w24,w24,#1
    cmp w24,w20
    b.lt .Lhalf_column
    add w9,w23,#1
    str w9,[x29,#344]
    sub w10,w22,#1
    cmp w9,w10
    b.ge .Lnext_half_row
    ldr w10,[x29,#368]
    cmp w9,w10
    b.lt .Lnext_half_row
    // Complete two-pass environment adjustment, with original ABI addresses.
    ldr x0,[x29,#112]
    ldr x1,[x29,#128]
    ldr x2,[x29,#136]
    ldr x3,[x29,#144]
    ldr x4,[x29,#152]
    add x5,x29,#344
    mov x6,x27
    ldr x7,[x29,#224]
    ldr x9,[x29,#240]
    str x9,[sp]
    str x28,[sp,#8]
    add x9,x29,#348
    str x9,[sp,#16]
    str xzr,[sp,#24]
    bl md2asm_cuinin_environment
    sub w24,w19,#1
.Ladjust_humidity:
    madd x25,x23,x21,x24
    sub x16,x25,x21
    ldr x9,[x29,#168]
    ldr d0,[x9,x16,lsl #3]
    ldr x9,[x29,#176]
    ldr d1,[x9,x16,lsl #3]
    fmin d0,d0,d1
    ldr x9,[x29,#240]
    ldr d2,[x9,x25,lsl #3]
    fsub d2,d2,d1
    fadd d0,d0,d2
    fmov d1,xzr
    fmaxnm d0,d0,d1
    ldr x9,[x29,#232]
    str d0,[x9,x25,lsl #3]
    add w24,w24,#1
    cmp w24,w20
    b.lt .Ladjust_humidity
.Lnext_half_row:
    add x23,x23,#1
    b .Lhalf_row
.Lboundaries:
    sub x23,x22,#1
    sub w24,w19,#1
.Lboundary_column:
    madd x25,x23,x21,x24
    ldr x9,[x29,#160]
    ldr d0,[x9,x25,lsl #3]
    ldr d1,[x29,#328]
    fmul d0,d1,d0
    ldr x9,[x29,#200]
    ldr d1,[x9,x25,lsl #3]
    fadd d0,d0,d1
    ldr x9,[x29,#248]
    ldr d1,[x9,x25,lsl #3]
    fsub d0,d0,d1
    ldr d1,[x29,#336]
    fmul d0,d0,d1
    ldr x9,[x29,#224]
    str d0,[x9,x25,lsl #3]
    ldr x9,[x29,#168]
    ldr d0,[x9,x25,lsl #3]
    ldr x9,[x29,#232]
    str d0,[x9,x25,lsl #3]
    ldr x9,[x29,#160]
    ldr d0,[x9,x24,lsl #3]
    ldr x9,[x29,#224]
    str d0,[x9,x24,lsl #3]
    ldr x9,[x29,#168]
    ldr d0,[x9,x24,lsl #3]
    ldr x9,[x29,#232]
    str d0,[x9,x24,lsl #3]
    add w24,w24,#1
    cmp w24,w20
    b.lt .Lboundary_column
    mov x23,#0
.Lplume_row:
    cmp x23,x22
    b.ge .Ldone
    sub w24,w19,#1
.Lplume_column:
    madd x25,x23,x21,x24
    ldr x9,[x29,#224]
    ldr d0,[x9,x25,lsl #3]
    ldr x9,[x29,#256]
    str d0,[x9,x25,lsl #3]
    ldr x9,[x29,#272]
    str d0,[x9,x25,lsl #3]
    ldr x9,[x29,#232]
    ldr d0,[x9,x25,lsl #3]
    ldr x9,[x29,#264]
    str d0,[x9,x25,lsl #3]
    ldr x9,[x29,#280]
    str d0,[x9,x25,lsl #3]
    ldr x9,[x29,#320]
    str xzr,[x9,x25,lsl #3]
    ldr x9,[x29,#216]
    str wzr,[x9,x25,lsl #2]
    mov x16,x25
    cbz x23,.Lwind_source
    sub x16,x25,x21
.Lwind_source:
    ldr x9,[x29,#184]
    ldr d0,[x9,x16,lsl #3]
    ldr x9,[x29,#288]
    str d0,[x9,x25,lsl #3]
    ldr x9,[x29,#304]
    str d0,[x9,x25,lsl #3]
    ldr x9,[x29,#192]
    ldr d0,[x9,x16,lsl #3]
    ldr x9,[x29,#296]
    str d0,[x9,x25,lsl #3]
    ldr x9,[x29,#312]
    str d0,[x9,x25,lsl #3]
    add w24,w24,#1
    cmp w24,w20
    b.lt .Lplume_column
    add x23,x23,#1
    b .Lplume_row
.Ldone:
    mov sp,x29
.Lreturn:
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp x29,x30,[sp],#384
    ret
.Ldomain:
    brk #0x4c3
.size CUININ_SYMBOL,.-CUININ_SYMBOL
.section .note.GNU-stack,"",%progbits
