/* Snow shortwave transport, formulation revision 1.
 * Physics formulations/openifs/surface/snow_shortwave_transport.md.
 * Contract skills/md2asm/references/openifs/surface/srfsn_ssrabs.md.
 * Twelve address arguments use x0..x7 and four caller stack slots.
 * Positive GNU descriptor strides retain complete output padding.
 * The 2048-byte frame holds depth, extinction and transport vectors.
 * Preserve x19..x29, LR, x18, d8..d15 and FPCR. */
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL __srfsn_ssrabs_mod_MOD_srfsn_ssrabs
#endif
#ifndef POWER_SYMBOL
#define POWER_SYMBOL md2asm_pow_original_rounding_candidate
#endif
.text
.p2align 4
.macro SHAPE desc,rows,cols=0,width=8
    cbz \desc,.Lreject
    ldr x8,[\desc]
    cbz x8,.Lreject
    tst x8,#(\width-1)
    b.ne .Lreject
    ldr x9,[\desc,#16]
    cmp x9,#\width
    b.ne .Lreject
    ldr x9,[\desc,#32]
    cmp x9,#\width
    b.ne .Lreject
    ldr x9,[\desc,#40]
    cmp x9,#0
    b.le .Lreject
    ldp x10,x11,[\desc,#48]
    sub x11,x11,x10
    add x11,x11,#1
    cmp x11,\rows
    b.lt .Lreject
    .ifc \cols,0
    .else
      ldr x12,[\desc,#64]
      mul x11,x11,x9
      cmp x12,x11
      b.lt .Lreject
      ldp x10,x11,[\desc,#72]
      sub x11,x11,x10
      add x11,x11,#1
      cmp x11,\cols
      b.lt .Lreject
    .endif
.endm
/* Dummy array indices start at descriptor.data, not its caller lower bound. */
.macro ADDRESS desc,col,width=8
    ldr x8,[\desc]
    ldr x9,[\desc,#40]
    mul x9,x9,x28
    .ifc \col,-1
    .else
      ldr x10,[\desc,#64]
      madd x9,x10,\col,x9
    .endif
    .if \width == 8
      add x8,x8,x9,lsl #3
    .else
      add x8,x8,x9,lsl #2
    .endif
.endm
.global ORIGINAL_SYMBOL
.type ORIGINAL_SYMBOL,%function
ORIGINAL_SYMBOL:
    sub sp,sp,#2048
    stp x19,x20,[sp,#0]
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x25,x26,[sp,#48]
    stp x27,x28,[sp,#64]
    stp x29,x30,[sp,#80]
    cbz x0,.Lreject
    cbz x1,.Lreject
    cbz x2,.Lreject
    cbz x3,.Lreject
    ldr w8,[x0]
    sub w8,w8,#1
    str w8,[sp,#224]
    ldr w9,[x1]
    str w9,[sp,#228]
    ldr w26,[x2]
    ldr w27,[x3]
    cmp w26,#1
    b.lt .Lreject
    cmp w26,#4096
    b.gt .Lreject
    cmp w27,#1
    b.lt .Lreject
    cmp w27,#64
    b.gt .Lreject
    cmp w8,#0
    b.lt .Lreject
    cmp w8,w26
    b.gt .Lreject
    cmp w9,#0
    b.lt .Lreject
    cmp w9,w26
    b.gt .Lreject
    mrs x10,fpcr
    cbnz x10,.Lreject
    cmp w8,w9
    b.ge .Ldone
    mov x19,x4
    mov x20,x5
    mov x21,x6
    mov x22,x7
    ldr x23,[sp,#2048]
    ldr x24,[sp,#2056]
    ldr x25,[sp,#2072]
    cbz x24,.Lreject
    SHAPE x19,x26,0,4
    mov x13,#7
    SHAPE x20,x26,x13
    SHAPE x21,x26,x13
    SHAPE x22,x26,x27
    SHAPE x23,x26,x27
    add x13,x27,#1
    SHAPE x25,x26,x13
    ldp x8,x9,[x25,#72]
    sub x9,x9,x8
    add x9,x9,#1
    cmp x9,x13
    b.ne .Lreject
    mov w8,#1
    str w8,[sp,#216]             /* KLACT persists across columns and tiles. */
    str wzr,[sp,#220]
.Ltile:
    ldr w28,[sp,#224]
.Lcolumn:
    ADDRESS x19,-1,4
    ldr w8,[x8]
    cbnz w8,.Lnosnow
    ldr w8,[sp,#220]
    lsl w8,w8,#1
    add w29,w8,#4
    ADDRESS x20,x29
    ldr d0,[x8]
    str d0,[sp,#232]
    ADDRESS x21,x29
    ldr d0,[x8]
    str d0,[sp,#240]
    mov w29,#0
    ldr d3,.Lepsilon
.Lactive:
    ADDRESS x22,x29
    ldr d0,[x8]
    fcmp d0,d3
    add w8,w29,#1
    ldr w9,[sp,#216]
    csel w9,w8,w9,gt
    str w9,[sp,#216]
    add w29,w29,#1
    cmp w29,w27
    b.lt .Lactive
    mov w29,#0
.Lprepare:
    ADDRESS x22,x29
    ldr d0,[x8]
    ADDRESS x23,x29
    ldr d1,[x8]
    str d1,[sp,#208]
    fdiv d2,d0,d1
    ldr d3,[x24,#416]
    fminnm d2,d2,d3
    fmov d3,xzr
    fmaxnm d2,d2,d3
    add x8,sp,#256
    str d2,[x8,x29,lsl #3]
    fmov d0,d1
    fmov d1,#4.0
    bl POWER_SYMBOL
    ldr d1,[x24,#2048]
    fmul d0,d1,d0
    ldr d1,[x24,#2032]
    fadd d0,d0,d1
    ldr d1,[x24,#2056]
    fminnm d0,d0,d1
    fmov d1,#0.5
    bl POWER_SYMBOL
    ldr d1,[sp,#208]
    ldr d2,[x24,#2080]
    fmul d1,d1,d2
    fdiv d1,d1,d0
    ldr d2,[x24,#2072]
    fminnm d1,d1,d2
    ldr d2,[x24,#2064]
    fmaxnm d1,d1,d2
    add x8,sp,#768
    str d1,[x8,x29,lsl #3]
    add w29,w29,#1
    ldr w8,[sp,#216]
    cmp w29,w8
    b.lt .Lprepare
    ldr d0,[sp,#768]
    ldr d1,[sp,#256]
    fnmul d0,d1,d0
    bl exp
    ldr d1,.Lepsilon
    fmaxnm d0,d0,d1
    ldr d2,[sp,#240]
    fmul d3,d2,d0
    str d3,[sp,#1280]
    fmov d1,#1.0
    fsub d1,d1,d0
    fmul d1,d1,d2
    fsub d2,d2,d1
    str d2,[sp,#200]
    mov w29,#1
    ldr w8,[sp,#216]
    cmp w29,w8
    b.ge .Lbottom
.Ldeeper:
    add x8,sp,#768
    ldr d0,[x8,x29,lsl #3]
    add x8,sp,#256
    ldr d1,[x8,x29,lsl #3]
    fnmul d0,d1,d0
    bl exp
    fmov d1,#1.0
    fsub d1,d1,d0
    ldr d2,[sp,#200]
    fmul d1,d1,d2
    add x8,sp,#1280
    str d1,[x8,x29,lsl #3]
    fsub d2,d2,d1
    str d2,[sp,#200]
    add w29,w29,#1
    ldr w8,[sp,#216]
    cmp w29,w8
    b.lt .Ldeeper
.Lbottom:
    ldr d0,[sp,#200]
    add x8,sp,#1280
    str d0,[x8,x29,lsl #3]
    mov w29,#0
.Lweight:
    ADDRESS x25,x29
    ldr d0,[x8]
    add x9,sp,#1280
    ldr d1,[x9,x29,lsl #3]
    ldr d2,[sp,#232]
    fmul d1,d2,d1
    fadd d0,d0,d1
    str d0,[x8]
    add w29,w29,#1
    ldr w9,[sp,#216]
    cmp w29,w9
    b.le .Lweight
    b .Lnextcolumn
.Lnosnow:
    mov w29,#0
.Lclear:
    ADDRESS x25,x29
    str xzr,[x8]
    add w29,w29,#1
    cmp w29,w27
    b.le .Lclear
.Lnextcolumn:
    add w28,w28,#1
    ldr w8,[sp,#228]
    cmp w28,w8
    b.lt .Lcolumn
    ldr w8,[sp,#220]
    add w8,w8,#1
    str w8,[sp,#220]
    cmp w8,#2
    b.lt .Ltile
.Ldone:
    ldp x19,x20,[sp,#0]
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x25,x26,[sp,#48]
    ldp x27,x28,[sp,#64]
    ldp x29,x30,[sp,#80]
    add sp,sp,#2048
    ret
.Lreject:
    mov w0,#116
    bl _exit
.size ORIGINAL_SYMBOL,.-ORIGINAL_SYMBOL
.p2align 3
.Lepsilon:
    .quad 0x3ce4000000000000
.section .note.GNU-stack,"",%progbits
