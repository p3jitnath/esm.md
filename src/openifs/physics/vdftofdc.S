/* Complete turbulent terrain-drag coefficients, formulation revision 1.
 * Physics formulations/openifs/physics/turbulent_terrain_drag.md.
 * Contract skills/md2asm/references/openifs/physics/vdftofdc.md.
 * Ten addresses use x0..x7 and two caller stack slots.
 * The 256-byte fixed frame preserves x19..x29, LR and d8..d15.
 * Two column vectors use at most 65536 additional aligned stack bytes.
 * Preserve x18 and FPCR, and clear every output column at each level. */
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL vdftofdc_
#endif
#ifndef POWER_SYMBOL
#define POWER_SYMBOL md2asm_pow_original_rounding_candidate
#endif
.text
.p2align 4
.macro GLOBAL reg,symbol
    adrp x8,:got:\symbol
    ldr x8,[x8,:got_lo12:\symbol]
    ldr \reg,[x8]
.endm
.global ORIGINAL_SYMBOL
.type ORIGINAL_SYMBOL,%function
ORIGINAL_SYMBOL:
    sub sp,sp,#256
    stp x29,x30,[sp,#0]
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    stp d8,d9,[sp,#96]
    stp d10,d11,[sp,#112]
    stp d12,d13,[sp,#128]
    stp d14,d15,[sp,#144]
    mov x29,sp
    cbz x0,.Lreject
    cbz x1,.Lreject
    cbz x2,.Lreject
    cbz x3,.Lreject
    cbz x4,.Lreject
    ldrsw x27,[x3]
    cmp x27,#0
    b.lt .Lreject
    cmp x27,#4096
    b.gt .Lreject
    ldr w8,[x4]
    cmp w8,#0
    b.lt .Lreject
    cmp w8,#1024
    b.gt .Lreject
    str w8,[x29,#168]
    ldr w8,[x1]
    sub w8,w8,#1
    cmp w8,#0
    b.lt .Lreject
    cmp w8,w27
    b.gt .Lreject
    str w8,[x29,#160]
    ldr w8,[x2]
    cmp w8,#0
    b.lt .Lreject
    cmp w8,w27
    b.gt .Lreject
    str w8,[x29,#164]
    mrs x8,fpcr
    cbnz x8,.Lreject
    mov x19,x5
    mov x20,x6
    mov x21,x7
    ldr x22,[x29,#256]
    ldr x23,[x29,#264]
    cbz x27,.Lpointersready
    cbz x22,.Lreject
    ldr w8,[x29,#168]
    cbz w8,.Lpointersready
    cbz x19,.Lreject
    cbz x20,.Lreject
    cbz x21,.Lreject
    cbz x23,.Lreject
.Lpointersready:
    ldr d11,[x0,#48]
    ldr d0,.Lcmd
    fmul d11,d11,d0
    ldr d0,.Lcorr
    fmul d11,d11,d0
    ldr d0,.Lic
    fmul d11,d11,d0
    ldr d0,.Lfact1
    fmul d11,d11,d0
    GLOBAL d8,__yomcst_MOD_rg
    GLOBAL d0,__yomdyncore_MOD_rplrg
    ldr d9,.L1500
    fdiv d9,d9,d0
    ldr d10,.L5000
    fdiv d10,d10,d0
    ldr d12,.Lrepdu2
    lsl x8,x27,#4
    sub sp,sp,x8
    mov x24,sp
    add x25,x24,x27,lsl #3
    ldr w26,[x29,#160]
    ldr w8,[x29,#164]
    cmp w26,w8
    b.ge .Llevels
.Lcoeff:
    ldr d0,[x22,x26,lsl #3]
    fmul d0,d0,d0
    fmul d0,d11,d0
    str d0,[x24,x26,lsl #3]
    add w26,w26,#1
    ldr w8,[x29,#164]
    cmp w26,w8
    b.lt .Lcoeff
.Llevels:
    mov w28,#0
    ldr w8,[x29,#168]
    cmp w28,w8
    b.ge .Ldone
.Llevel:
    ldr w26,[x29,#160]
    ldr w8,[x29,#164]
    cmp w26,w8
    b.ge .Lclearall
.Lselected:
    madd x8,x28,x27,x26
    ldr d0,[x21,x8,lsl #3]
    fdiv d13,d0,d8
    fcmp d13,d10
    b.le .Lactive
    str xzr,[x25,x26,lsl #3]
    b .Lnext
.Lactive:
    /* The original recomputes height after its gather decision. */
    fdiv d13,d0,d8
    ldr d1,[x19,x8,lsl #3]
    ldr d2,[x20,x8,lsl #3]
    fmul d1,d1,d1
    fmul d2,d2,d2
    fadd d1,d1,d2
    fmaxnm d1,d1,d12
    fsqrt d14,d1
    fdiv d0,d13,d9
    fmov d1,#1.5
    bl POWER_SYMBOL
    fneg d0,d0
    bl exp
    fmov d15,d0
    fmov d0,d13
    ldr d1,.Lexponent
    bl POWER_SYMBOL
    ldr d1,[x24,x26,lsl #3]
    fmul d1,d14,d1
    fmul d1,d1,d15
    fmul d1,d1,d0
    str d1,[x25,x26,lsl #3]
.Lnext:
    add w26,w26,#1
    ldr w8,[x29,#164]
    cmp w26,w8
    b.lt .Lselected
.Lclearall:
    mov w26,#0
    cbz x27,.Lnextlevel
.Lclear:
    madd x8,x28,x27,x26
    str xzr,[x23,x8,lsl #3]
    add w26,w26,#1
    cmp w26,w27
    b.lt .Lclear
    ldr w26,[x29,#160]
    ldr w8,[x29,#164]
    cmp w26,w8
    b.ge .Lnextlevel
.Lscatter:
    madd x8,x28,x27,x26
    ldr d0,[x25,x26,lsl #3]
    str d0,[x23,x8,lsl #3]
    add w26,w26,#1
    ldr w8,[x29,#164]
    cmp w26,w8
    b.lt .Lscatter
.Lnextlevel:
    add w28,w28,#1
    ldr w8,[x29,#168]
    cmp w28,w8
    b.lt .Llevel
.Ldone:
    mov sp,x29
    ldp d8,d9,[sp,#96]
    ldp d10,d11,[sp,#112]
    ldp d12,d13,[sp,#128]
    ldp d14,d15,[sp,#144]
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp x29,x30,[sp,#0]
    add sp,sp,#256
    ret
.Lreject:
    mov w0,#116
    bl _exit
.size ORIGINAL_SYMBOL,.-ORIGINAL_SYMBOL
.p2align 3
.Lcmd: .quad 0x3f747ae140000000
.Lcorr: .quad 0x3fe3333340000000
.Lic: .quad 0x4000df3b60000000
.Lfact1: .quad 0x3eb7f28871d058fb
.Lrepdu2: .quad 0x3f847ae147ae147c
.Lexponent: .quad 0xbff3333340000000
.L1500: .double 1500.0
.L5000: .double 5000.0
.section .note.GNU-stack,"",%progbits
