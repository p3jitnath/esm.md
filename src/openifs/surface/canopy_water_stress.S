/* Direct selected COTWORESTRESS body from OpenIFS 48.1.1.
 * Physics formulations/openifs/surface/canopy_water_stress.md.
 * Contract skills/md2asm/references/openifs/surface/canopy_water_stress.md.
 * Frozen numerical body and current private interfaces are preserved. */
.text
.p2align 4
.macro ARG reg, argument
    ldr \reg,[x19,#(\argument*8)]
.endm
.macro INPUT reg, argument
    ARG x9,\argument
    ldr x9,[x9]
    ldr \reg,[x9,x20,lsl #3]
.endm
.macro OUTPUT reg, argument
    ARG x9,\argument
    ldr x9,[x9]
    str \reg,[x9,x20,lsl #3]
.endm
.macro TABLE reg, offset
    ARG x9,20
    ldr x9,[x9,#\offset]
    ldr \reg,[x9,x26,lsl #3]
.endm
.macro PARAM reg, offset
    ARG x9,20
    ldr \reg,[x9,#\offset]
.endm
.macro CONSTANT reg, name
    adrp x9,.LC_\name
    ldr \reg,[x9,:lo12:.LC_\name]
.endm
.macro MATH name
    str x18,[sp,#1776]
    bl \name
    ldr x18,[sp,#1776]
.endm
.macro GAMMA_RESPONSE
    TABLE d0,656
    MATH log
    ldr d1,[sp,#968]
    fmul d0,d1,d0
    MATH exp
    TABLE d1,592
    fmul d0,d1,d0
    str d0,[sp,#1032]
.endm
.macro GM_FROM_DMAX
    ldr d0,[sp,#1000]
    CONSTANT d1,THOUSAND
    fmul d0,d0,d1
    MATH log
    TABLE d1,1232
    fmul d0,d1,d0
    TABLE d1,1168
    fadd d0,d1,d0
    MATH exp
    CONSTANT d1,THOUSAND
    fdiv d0,d0,d1
    str d0,[sp,#984]
.endm
.macro WATER_SCALE
    ldr d0,[sp,#984]
    INPUT d1,17
    fmul d0,d0,d1
    TABLE d1,1744
    fdiv d0,d0,d1
    str d0,[sp,#984]
.endm
.macro WOODY_FZERO
    ldr d0,[sp,#984]
    CONSTANT d1,THOUSAND
    fmul d0,d0,d1
    MATH log
    PARAM d1,176
    fsub d0,d1,d0
    PARAM d1,184
    fdiv d0,d0,d1
    CONSTANT d1,NINETY_FIVE_PERCENT
    fmin d0,d1,d0
    str d0,[sp,#992]
.endm
.macro RESPONSE base, q10, low, high, destination
    TABLE d0,\q10
    MATH log
    ldr d1,[sp,#968]
    fmul d0,d1,d0
    MATH exp
    .if \base
        TABLE d1,\base
    .else
        ldr d1,[sp,#984]
    .endif
    fmul d0,d1,d0
    str d0,[sp,#1120]
    TABLE d0,\low
    ldr d1,[sp,#960]
    fsub d0,d0,d1
    CONSTANT d1,THREE_TENTHS
    fmul d0,d1,d0
    MATH exp
    fmov d1,#1.0
    fadd d0,d1,d0
    str d0,[sp,#1128]
    ldr d0,[sp,#960]
    TABLE d1,\high
    fsub d0,d0,d1
    CONSTANT d1,THREE_TENTHS
    fmul d0,d1,d0
    MATH exp
    fmov d1,#1.0
    fadd d0,d1,d0
    ldr d1,[sp,#1128]
    fmul d0,d1,d0
    ldr d1,[sp,#1120]
    fdiv d0,d1,d0
    str d0,[sp,#\destination]
.endm
.macro CHECK_DESCRIPTOR argument, bytes, kind
    ARG x9,\argument
    ldr x10,[x9]
    cbz x10,.Lreject
    tst x10,#(\bytes-1)
    b.ne .Lreject
    ldr x10,[x9,#16]
    cmp x10,#\bytes
    b.ne .Lreject
    ldr x10,[x9,#32]
    cmp x10,#\bytes
    b.ne .Lreject
    ldrb w10,[x9,#28]
    cmp w10,#1
    b.ne .Lreject
    ldrb w10,[x9,#29]
    cmp w10,#\kind
    b.ne .Lreject
    ldr x10,[x9,#40]
    cmp x10,#1
    b.ne .Lreject
    ldp x10,x11,[x9,#48]
    sub x11,x11,x10
    add x11,x11,#1
    cmp x11,x21
    b.lt .Lreject
    ldr x11,[x9,#8]
    add x11,x11,x10
    cbnz x11,.Lreject
.endm
.macro CHECK_PARAMETER offset, bytes, kind
    ARG x9,20
    add x9,x9,#\offset
    ldr x10,[x9]
    cbz x10,.Lreject
    tst x10,#(\bytes-1)
    b.ne .Lreject
    ldr x10,[x9,#16]
    cmp x10,#\bytes
    b.ne .Lreject
    ldr x10,[x9,#32]
    cmp x10,#\bytes
    b.ne .Lreject
    ldrb w10,[x9,#28]
    cmp w10,#1
    b.ne .Lreject
    ldrb w10,[x9,#29]
    cmp w10,#\kind
    b.ne .Lreject
    ldr x10,[x9,#8]
    cbnz x10,.Lreject
    ldr x10,[x9,#40]
    cmp x10,#1
    b.ne .Lreject
    ldr x10,[x9,#48]
    cbnz x10,.Lreject
    ldr x10,[x9,#56]
    cmp x10,#20
    b.ne .Lreject
.endm
.macro CHECK_CHILD_TABLE offset
    ARG x9,21
    add x9,x9,#\offset
    ldr x10,[x9]
    cbz x10,.Lreject
    tst x10,#7
    b.ne .Lreject
    ldr x10,[x9,#16]
    cmp x10,#8
    b.ne .Lreject
    ldr x10,[x9,#32]
    cmp x10,#8
    b.ne .Lreject
    ldrb w10,[x9,#28]
    cmp w10,#2
    b.ne .Lreject
    ldrb w10,[x9,#29]
    cmp w10,#3
    b.ne .Lreject
    ldr x10,[x9,#8]
    cmn x10,#21
    b.ne .Lreject
    ldr x10,[x9,#40]
    cmp x10,#1
    b.ne .Lreject
    ldr x10,[x9,#48]
    cmp x10,#1
    b.ne .Lreject
    ldr x10,[x9,#56]
    cmp x10,#20
    b.ne .Lreject
    ldr x10,[x9,#64]
    cmp x10,#20
    b.ne .Lreject
    ldr x10,[x9,#72]
    cmp x10,#1
    b.ne .Lreject
    ldr x10,[x9,#80]
    cmp x10,#2
    b.ne .Lreject
.endm
.global md2asm_cotworestress_7358525
.type md2asm_cotworestress_7358525,%function
md2asm_cotworestress_7358525:
    sub sp,sp,#2048
    stp x19,x20,[sp,#192]
    stp x21,x22,[sp,#208]
    stp x23,x24,[sp,#224]
    stp x25,x26,[sp,#240]
    stp x27,x28,[sp,#256]
    stp x29,x30,[sp,#272]
    add x19,sp,#320
    stp x0,x1,[x19]
    stp x2,x3,[x19,#16]
    stp x4,x5,[x19,#32]
    stp x6,x7,[x19,#48]
    add x11,sp,#2048
    mov x10,#8
.Larguments:
    ldr x9,[x11],#8
    str x9,[x19,x10,lsl #3]
    add x10,x10,#1
    cmp x10,#30
    b.lt .Larguments
    mrs x9,fpcr
    cbnz x9,.Lreject
    mov x10,#0
.Lpointers:
    ldr x9,[x19,x10,lsl #3]
    cbz x9,.Lreject
    tst x9,#3
    b.ne .Lreject
    add x10,x10,#1
    cmp x10,#30
    b.lt .Lpointers
    ARG x9,2
    ldr w21,[x9]
    cmp w21,#1
    b.lt .Lreject
    cmp w21,#4096
    b.gt .Lreject
    ARG x9,0
    ldr w20,[x9]
    sub w20,w20,#1
    cmp w20,#0
    b.lt .Lreject
    cmp w20,w21
    b.gt .Lreject
    str w20,[sp,#576]
    ARG x9,1
    ldr w25,[x9]
    cmp w25,#0
    b.lt .Lreject
    cmp w25,w21
    b.gt .Lreject
    cmp w25,w20
    b.lt .Lreject
    ARG x9,22
    ldr w9,[x9,#764]
    cmp w9,#1
    b.ne .Lreject
    ARG x9,21
    ldr w10,[x9]
    cmp w10,#20
    b.ne .Lreject
    ldr w10,[x9,#4]
    cmp w10,#21
    b.ne .Lreject
    ldr w10,[x9,#8]
    cmp w10,#2
    b.ne .Lreject

    CHECK_DESCRIPTOR 3,4,1
    CHECK_DESCRIPTOR 4,4,1
    CHECK_DESCRIPTOR 6,8,3
    CHECK_DESCRIPTOR 7,8,3
    CHECK_DESCRIPTOR 8,8,3
    CHECK_DESCRIPTOR 9,8,3
    CHECK_DESCRIPTOR 10,8,3
    CHECK_DESCRIPTOR 11,8,3
    CHECK_DESCRIPTOR 12,8,3
    CHECK_DESCRIPTOR 13,8,3
    CHECK_DESCRIPTOR 14,8,3
    CHECK_DESCRIPTOR 15,8,3
    CHECK_DESCRIPTOR 16,8,3
    CHECK_DESCRIPTOR 17,8,3
    CHECK_DESCRIPTOR 18,8,3
    CHECK_DESCRIPTOR 24,8,3
    CHECK_DESCRIPTOR 25,8,3
    CHECK_DESCRIPTOR 26,8,3
    CHECK_DESCRIPTOR 27,8,3
    CHECK_DESCRIPTOR 28,8,3
    CHECK_DESCRIPTOR 29,8,3
    CHECK_PARAMETER 1552,8,3
    CHECK_PARAMETER 464,8,3
    CHECK_PARAMETER 1680,8,3
    CHECK_PARAMETER 1616,8,3
    CHECK_PARAMETER 528,8,3
    CHECK_PARAMETER 1168,8,3
    CHECK_PARAMETER 1232,8,3
    CHECK_PARAMETER 592,8,3
    CHECK_PARAMETER 656,8,3
    CHECK_PARAMETER 1296,4,2
    CHECK_PARAMETER 1744,8,3
    CHECK_PARAMETER 912,8,3
    CHECK_PARAMETER 976,8,3
    CHECK_PARAMETER 1040,8,3
    CHECK_PARAMETER 1104,8,3
    CHECK_PARAMETER 720,8,3
    CHECK_PARAMETER 784,8,3
    CHECK_PARAMETER 848,8,3
    CHECK_CHILD_TABLE 384
    CHECK_CHILD_TABLE 472
    CHECK_CHILD_TABLE 560
    CHECK_CHILD_TABLE 648
    CHECK_CHILD_TABLE 736
    CHECK_CHILD_TABLE 824
    CHECK_CHILD_TABLE 912
    CHECK_CHILD_TABLE 1000
    CHECK_CHILD_TABLE 1088
    CHECK_CHILD_TABLE 1176
    // The actual PFRTI backing owns all selected water, ice and lake columns.
    ARG x9,5
    ldr x10,[x9]
    cbz x10,.Lreject
    tst x10,#7
    b.ne .Lreject
    ldr x10,[x9,#16]
    cmp x10,#8
    b.ne .Lreject
    ldr x10,[x9,#32]
    cmp x10,#8
    b.ne .Lreject
    ldrb w10,[x9,#28]
    cmp w10,#2
    b.ne .Lreject
    ldrb w10,[x9,#29]
    cmp w10,#3
    b.ne .Lreject
    ldr x10,[x9,#40]
    cmp x10,#1
    b.ne .Lreject
    ldp x10,x11,[x9,#48]
    sub x11,x11,x10
    add x11,x11,#1
    cmp x11,x21
    b.lt .Lreject
    ldr x12,[x9,#64]
    cmp x12,x11
    b.ne .Lreject
    str x12,[sp,#584]
    ldr x11,[x9,#72]
    cmp x11,#1
    b.ne .Lreject
    ldr x13,[x9,#8]
    add x13,x13,x10
    add x13,x13,x12
    cbnz x13,.Lreject
    ldr x11,[x9,#80]
    cmp x11,#2
    b.lt .Lreject
    ARG x9,23
    ldr w9,[x9,#848]
    cmp w9,#1
    b.hi .Lreject
    str w9,[sp,#592]
    cbz w9,.Ldomain_begin
    cmp x11,#9
    b.lt .Lreject
.Ldomain_begin:
    cmp w20,w25
    b.ge .Lallocate
.Ldomain_row:
    ARG x9,3
    ldr x9,[x9]
    ldr w26,[x9,x20,lsl #2]
    cmp w26,#0
    b.lt .Lreject
    cmp w26,#20
    b.gt .Lreject
    INPUT d0,8
    fcmp d0,#0.0
    b.le .Lreject
    b.vs .Lreject
    add x20,x20,#1
    cmp x20,x25
    b.lt .Ldomain_row
.Lallocate:
    // Profiling only: preserve the original readonly control and default8 ABI.
    adrp x9,:got:__yomhook_MOD_lhook
    ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
    ldr w9,[x9]
    cmp w9,#1
    b.hi .Lreject
    str w9,[sp,#1840]
    cbz w9,.Lcanopy_hook_entry_done
    adr x0,.Lcanopy_hook_name
    add x1,sp,#1844
    str wzr,[x1]
    add x2,sp,#1848
    mov x3,#31
    MATH __yomhook_MOD_dr_hook_default8
.Lcanopy_hook_entry_done:
    lsl x0,x21,#5
    MATH malloc
    cbz x0,.Lreject
    mov x22,x0
    add x23,x22,x21,lsl #3
    add x24,x23,x21,lsl #3
    add x28,x24,x21,lsl #3
    mov x9,x22
    lsl x10,x21,#2
.Lzero:
    str xzr,[x9],#8
    subs x10,x10,#1
    b.ne .Lzero
    // Four immutable descriptors describe the complete private child planes.

    str x22,[sp,#640]
    mov x9,#-1
    str x9,[sp,#648]
    mov x9,#4
    str x9,[sp,#656]
    str xzr,[sp,#664]
    mov w9,#1
    strb w9,[sp,#668]
    mov w9,#2
    strb w9,[sp,#669]
    mov x9,#4
    str x9,[sp,#672]
    mov x9,#1
    str x9,[sp,#680]
    str x9,[sp,#688]
    str x21,[sp,#696]
    str x23,[sp,#704]
    mov x9,#-1
    str x9,[sp,#712]
    mov x9,#8
    str x9,[sp,#720]
    str xzr,[sp,#728]
    mov w9,#1
    strb w9,[sp,#732]
    mov w9,#3
    strb w9,[sp,#733]
    mov x9,#8
    str x9,[sp,#736]
    mov x9,#1
    str x9,[sp,#744]
    str x9,[sp,#752]
    str x21,[sp,#760]
    str x24,[sp,#768]
    mov x9,#-1
    str x9,[sp,#776]
    mov x9,#8
    str x9,[sp,#784]
    str xzr,[sp,#792]
    mov w9,#1
    strb w9,[sp,#796]
    mov w9,#3
    strb w9,[sp,#797]
    mov x9,#8
    str x9,[sp,#800]
    mov x9,#1
    str x9,[sp,#808]
    str x9,[sp,#816]
    str x21,[sp,#824]
    str x28,[sp,#832]
    mov x9,#-1
    str x9,[sp,#840]
    mov x9,#8
    str x9,[sp,#848]
    str xzr,[sp,#856]
    mov w9,#1
    strb w9,[sp,#860]
    mov w9,#3
    strb w9,[sp,#861]
    mov x9,#8
    str x9,[sp,#864]
    mov x9,#1
    str x9,[sp,#872]
    str x9,[sp,#880]
    str x21,[sp,#888]
    ldr w20,[sp,#576]
    cmp x20,x25
    b.ge .Lchild
.Lrow:
    bl .Lland
    str w9,[x22,x20,lsl #2]
    cbz w9,.Lco2
    INPUT d0,10
    ARG x9,19
    ldr d1,[x9]
    fsub d0,d0,d1
    str d0,[sp,#960]
    CONSTANT d1,TWENTY_FIVE
    fsub d0,d0,d1
    CONSTANT d1,TENTH
    fmul d0,d1,d0
    str d0,[sp,#968]
    INPUT d0,14
    PARAM d1,48
    fmul d0,d0,d1
    str d0,[sp,#976]
    ARG x9,3
    ldr x9,[x9]
    ldr w26,[x9,x20,lsl #2]
    TABLE d0,1552
    str d0,[sp,#984]
    TABLE d0,464
    str d0,[sp,#992]
    TABLE d0,1680
    str d0,[sp,#1000]
    TABLE d0,1616
    str d0,[sp,#1008]
    TABLE d0,528
    str d0,[sp,#1016]
    ARG x9,20
    ldr x9,[x9,#1296]
    ldr w27,[x9,x26,lsl #2]

    cmp w26,#0
    b.eq .Lherb
    cmp w26,#1
    b.eq .Lherb
    cmp w26,#2
    b.eq .Lherb
    cmp w26,#7
    b.eq .Lherb
    cmp w26,#9
    b.eq .Lherb
    cmp w26,#10
    b.eq .Lherb
    cmp w26,#11
    b.eq .Lherb
    cmp w26,#13
    b.eq .Lherb
    cmp w26,#16
    b.eq .Lherb
    cmp w26,#17
    b.eq .Lherb
    cmp w26,#20
    b.eq .Lherb
    cmp w26,#3
    b.eq .Lwoody
    cmp w26,#4
    b.eq .Lwoody
    cmp w26,#5
    b.eq .Lwoody
    cmp w26,#6
    b.eq .Lwoody
    cmp w26,#18
    b.eq .Lwoody
    cmp w26,#19
    b.eq .Lwoody
    b .Lhumidity
.Lherb:
    ldr d0,[sp,#984]
    CONSTANT d1,THOUSAND
    fmul d0,d0,d1
    MATH log
    TABLE d1,1168
    fsub d0,d0,d1
    TABLE d1,1232
    fdiv d0,d0,d1
    MATH exp
    CONSTANT d1,THOUSAND
    fdiv d0,d0,d1
    str d0,[sp,#1024]
    GAMMA_RESPONSE
    INPUT d0,17
    TABLE d1,1744
    fcmp d0,d1
    b.lt .Lherb_below
    // The product is rounded before division and the final addition.
    cbz w27,.Lherb_offensive_above
    PARAM d2,192
    b .Lherb_above_common
.Lherb_offensive_above:
    PARAM d2,200
.Lherb_above_common:
    ldr d3,[sp,#1024]
    fsub d3,d3,d2
    fsub d0,d0,d1
    fmul d0,d3,d0
    fmov d3,#1.0
    fsub d1,d3,d1
    fdiv d0,d0,d1
    fadd d0,d2,d0
    str d0,[sp,#1000]
    GM_FROM_DMAX
    b .Lherb_wilting
.Lherb_below:
    cbz w27,.Lherb_offensive_below
    PARAM d0,192
    str d0,[sp,#1000]
    GM_FROM_DMAX
    WATER_SCALE
    b .Lherb_wilting
.Lherb_offensive_below:
    PARAM d2,200
    fmul d0,d2,d0
    fdiv d0,d0,d1
    str d0,[sp,#1000]
    PARAM d0,200
    str d0,[sp,#1144]
    ldr d1,[sp,#1000]
    str d1,[sp,#1152]
    str d0,[sp,#1000]
    GM_FROM_DMAX
    ldr d0,[sp,#1152]
    str d0,[sp,#1000]
.Lherb_wilting:
    cbnz w27,.Lhumidity
    ldr d0,[sp,#1000]
    PARAM d1,192
    fcmp d0,d1
    b.gt .Lhumidity
    str d1,[sp,#1000]
    GM_FROM_DMAX
    WATER_SCALE
    b .Lhumidity
.Lwoody:
    GAMMA_RESPONSE
    ldr d0,[sp,#984]
    CONSTANT d1,THOUSAND
    fmul d0,d0,d1
    MATH log
    PARAM d1,168
    fsub d0,d1,d0
    PARAM d1,184
    fdiv d0,d0,d1
    str d0,[sp,#1040]
    ldr d0,[sp,#984]
    CONSTANT d1,THOUSAND
    fmul d0,d0,d1
    MATH log
    PARAM d1,176
    fsub d0,d1,d0
    PARAM d1,184
    fdiv d0,d0,d1
    str d0,[sp,#1048]
    PARAM d0,184
    ldr d1,[sp,#1040]
    fmul d0,d0,d1
    PARAM d1,176
    fsub d0,d1,d0
    MATH exp
    CONSTANT d1,THOUSAND
    fdiv d0,d0,d1
    str d0,[sp,#1056]
    INPUT d0,17
    TABLE d1,1744
    fcmp d0,d1
    b.lt .Lwoody_below
    cbz w27,.Lwoody_offensive_above
    ldr d2,[sp,#1040]
    ldr d3,[sp,#1048]
    fsub d2,d2,d3
    fsub d0,d0,d1
    fmul d0,d2,d0
    fmov d2,#1.0
    fsub d1,d2,d1
    fdiv d0,d0,d1
    fadd d0,d3,d0
    str d0,[sp,#992]
    b .Lhumidity
.Lwoody_offensive_above:
    ldr d2,[sp,#984]
    ldr d3,[sp,#1056]
    fsub d2,d2,d3
    fsub d0,d0,d1
    fmul d0,d2,d0
    fmov d2,#1.0
    fsub d1,d2,d1
    fdiv d0,d0,d1
    fadd d0,d3,d0
    str d0,[sp,#984]
    ldr d0,[sp,#1040]
    str d0,[sp,#992]
    b .Lhumidity
.Lwoody_below:
    cbz w27,.Lwoody_offensive_below
    WATER_SCALE
    ldr d0,[sp,#984]
    CONSTANT d1,MICRO
    fmax d0,d1,d0
    str d0,[sp,#984]
    WOODY_FZERO
    b .Lhumidity
.Lwoody_offensive_below:
    ldr d0,[sp,#1056]
    INPUT d1,17
    fmul d0,d0,d1
    TABLE d1,1744
    fdiv d0,d0,d1
    str d0,[sp,#984]
    WOODY_FZERO
.Lhumidity:
    ldr d0,[sp,#1000]
    OUTPUT d0,29
    INPUT d0,6
    ARG x9,19
    ldr d1,[x9,#32]
    fmul d0,d1,d0
    INPUT d1,7
    ARG x9,19
    ldr d2,[x9,#48]
    fmul d1,d2,d1
    fmov d2,#1.0
    fadd d1,d2,d1
    fmul d0,d0,d1
    INPUT d1,9
    fdiv d0,d1,d0
    str d0,[sp,#1072]
    INPUT d0,12
    fmov d1,xzr
    fmin d0,d1,d0
    INPUT d1,15
    fmul d0,d0,d1
    ldr d1,[sp,#1072]
    fdiv d0,d0,d1
    INPUT d1,7
    fsub d1,d1,d0
    str d1,[x23,x20,lsl #3]
    INPUT d1,18
    INPUT d2,7
    fsub d1,d1,d2
    fadd d0,d1,d0
    fmov d1,xzr
    fmax d0,d1,d0
    OUTPUT d0,28
    INPUT d0,16
    CONSTANT d1,TENTH
    fmax d0,d0,d1
    str d0,[sp,#1088]
    RESPONSE 912,976,1040,1104,1064
    RESPONSE 0,720,784,848,984
.Lco2:
    INPUT d0,8
    str d0,[x24,x20,lsl #3]
    add x20,x20,#1
    cmp x20,x25
    b.lt .Lrow
.Lchild:

    ARG x9,0
    mov x0,x9
    ARG x9,1
    mov x1,x9
    ARG x9,2
    mov x2,x9
    add x9,sp,#640
    mov x3,x9
    ARG x9,3
    mov x4,x9
    ARG x9,4
    mov x5,x9
    ARG x9,20
    mov x6,x9
    ARG x9,21
    mov x7,x9
    ARG x9,19
    str x9,[sp,#0]
    ARG x9,14
    str x9,[sp,#8]
    ARG x9,9
    str x9,[sp,#16]
    ARG x9,18
    str x9,[sp,#24]
    add x9,sp,#704
    str x9,[sp,#32]
    ARG x9,7
    str x9,[sp,#40]
    ARG x9,6
    str x9,[sp,#48]
    ARG x9,10
    str x9,[sp,#56]
    ARG x9,11
    str x9,[sp,#64]
    ARG x9,17
    str x9,[sp,#72]
    add x9,sp,#768
    str x9,[sp,#80]
    ARG x9,13
    str x9,[sp,#88]
    add x9,sp,#832
    str x9,[sp,#96]
    ARG x9,25
    str x9,[sp,#104]
    ARG x9,26
    str x9,[sp,#112]
    ARG x9,24
    str x9,[sp,#120]
    MATH md2asm_canopy_private_leaf
    ldr w20,[sp,#576]
    cmp x20,x25
    b.ge .Lrelease
.Lresistance:
    ldr w9,[x22,x20,lsl #2]
    cbz w9,.Lzero_resistance
    ARG x9,3
    ldr x9,[x9]
    ldr w9,[x9,x20,lsl #2]
    cmp w9,#0
    b.le .Lzero_resistance
    ldr d0,[x28,x20,lsl #3]
    PARAM d1,128
    fmax d0,d1,d0
    fmov d1,#1.0
    fdiv d0,d1,d0
    b .Lwrite_resistance
.Lzero_resistance:
    fmov d0,xzr
.Lwrite_resistance:
    OUTPUT d0,27
    add x20,x20,#1
    cmp x20,x25
    b.lt .Lresistance
.Lrelease:
    mov x0,x22
    MATH free
    adrp x9,.Lparent_calls
    ldr x10,[x9,:lo12:.Lparent_calls]
    add x10,x10,#1
    str x10,[x9,:lo12:.Lparent_calls]
    ldr w9,[sp,#1840]
    cbz w9,.Lcanopy_hook_exit_done
    adr x0,.Lcanopy_hook_name
    add x1,sp,#1844
    mov w9,#1
    str w9,[x1]
    add x2,sp,#1848
    mov x3,#31
    MATH __yomhook_MOD_dr_hook_default8
.Lcanopy_hook_exit_done:
    ldp x19,x20,[sp,#192]
    ldp x21,x22,[sp,#208]
    ldp x23,x24,[sp,#224]
    ldp x25,x26,[sp,#240]
    ldp x27,x28,[sp,#256]
    ldp x29,x30,[sp,#272]
    add sp,sp,#2048
    ret
.Lreject:
    bl abort
    brk #0
// This local subroutine only forms the original rounded land predicate.
.Lland:
    ARG x9,5
    ldr x9,[x9]
    ldr x10,[sp,#584]
    ldr d0,[x9,x20,lsl #3]
    add x11,x20,x10
    ldr d1,[x9,x11,lsl #3]
    fadd d0,d0,d1
    ldr w11,[sp,#592]
    cbz w11,.Lland_compare
    add x11,x20,x10,lsl #3
    ldr d1,[x9,x11,lsl #3]
    fadd d0,d0,d1
.Lland_compare:
    fmov d1,#0.5
    fcmp d0,d1
    cset w9,le
    ret
.size md2asm_cotworestress_7358525,.-md2asm_cotworestress_7358525
.global md2asm_cotworestress_calls_get
.type md2asm_cotworestress_calls_get,%function
md2asm_cotworestress_calls_get:
    adrp x9,.Lparent_calls
    ldr x0,[x9,:lo12:.Lparent_calls]
    ret
.size md2asm_cotworestress_calls_get,.-md2asm_cotworestress_calls_get
// The private wrapper forwards every original leaf pointer and counts complete calls.
.hidden md2asm_canopy_private_leaf
.type md2asm_canopy_private_leaf,%function
md2asm_canopy_private_leaf:
    sub sp,sp,#144
    stp x18,x30,[sp,#128]
    add x9,sp,#144
    mov x10,#0
.Lleaf_stack:
    ldr x11,[x9,x10,lsl #3]
    str x11,[sp,x10,lsl #3]
    add x10,x10,#1
    cmp x10,#16
    b.lt .Lleaf_stack
    bl md2asm_farquhar
    adrp x9,.Lprivate_leaf_calls
    ldr x10,[x9,:lo12:.Lprivate_leaf_calls]
    add x10,x10,#1
    str x10,[x9,:lo12:.Lprivate_leaf_calls]
    ldp x18,x30,[sp,#128]
    add sp,sp,#144
    ret
.size md2asm_canopy_private_leaf,.-md2asm_canopy_private_leaf
.global md2asm_canopy_private_leaf_calls_get
.type md2asm_canopy_private_leaf_calls_get,%function
md2asm_canopy_private_leaf_calls_get:
    adrp x9,.Lprivate_leaf_calls
    ldr x0,[x9,:lo12:.Lprivate_leaf_calls]
    ret
.size md2asm_canopy_private_leaf_calls_get,.-md2asm_canopy_private_leaf_calls_get
.section .rodata
.p2align 3

.LC_THOUSAND: .quad 0x408f400000000000
.LC_TWENTY_FIVE: .quad 0x4039000000000000
.LC_TENTH: .quad 0x3fb999999999999a
.LC_THREE_TENTHS: .quad 0x3fd3333333333333
.LC_MICRO: .quad 0x3eb0c6f7a0b5ed8d
.LC_NINETY_FIVE_PERCENT: .quad 0x3fee666666666666
.LC_HUNDREDTH: .quad 0x3f847ae147ae147b
.LC_DEFAULT_EPSILON: .quad 0x3e80000000000000
.bss
.p2align 3
.Lparent_calls: .zero 8
.Lprivate_leaf_calls: .zero 8
.section .rodata
.Lcanopy_hook_name: .ascii "COTWORESTRESS_MOD:COTWORESTRESS"
.section .note.GNU-stack,"",%progbits
