#include "../../support/gpu/preserved_weather_calls.inc.S"
.text
.align 2
.macro A n,r
    ldr \r,[sp,#128+8*\n]
.endm
.macro C r,n
    ldr \r,[x26,#8*\n]
.endm
.macro V n,r
    ldr x12,[sp,#512+32*\n]
    ldr x13,[sp,#520+32*\n]
    madd x15,x19,x13,x12
    ldr \r,[x15]
.endm
.macro M n,r,axis=x21
    ldr x12,[sp,#512+32*\n]
    ldr x13,[sp,#520+32*\n]
    ldr x14,[sp,#528+32*\n]
    madd x15,x19,x13,x12
    madd x15,\axis,x14,x15
    ldr \r,[x15]
.endm
.macro SV n,r
    ldr x12,[sp,#512+32*\n]
    ldr x13,[sp,#520+32*\n]
    madd x15,x19,x13,x12
    str \r,[x15]
.endm
.macro SM n,r,axis=x21
    ldr x12,[sp,#512+32*\n]
    ldr x13,[sp,#520+32*\n]
    ldr x14,[sp,#528+32*\n]
    madd x15,x19,x13,x12
    madd x15,\axis,x14,x15
    str \r,[x15]
.endm
.macro O n,off,r
    A \n,x12
    ldr \r,[x12,#\off]
.endm
.global md2asm_surfrad_ctl_wrapper_body
.type md2asm_surfrad_ctl_wrapper_body,%function
md2asm_surfrad_ctl_wrapper_body:
    mrs x9,fpcr
    cbnz x9,.Lreject
    mov x10,sp
    sub sp,sp,#9,lsl #12
    stp x29,x30,[sp]
    mov x29,sp
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    stp x0,x1,[sp,#128]
    stp x2,x3,[sp,#144]
    stp x4,x5,[sp,#160]
    stp x6,x7,[sp,#176]
    mov x9,#0
.Largs:
    ldr x11,[x10,x9,lsl #3]
    add x12,sp,#192
    str x11,[x12,x9,lsl #3]
    add x9,x9,#1
    cmp x9,#35
    b.lt .Largs
    mov x9,#0
.Lptrs:
    add x10,sp,#128
    ldr x11,[x10,x9,lsl #3]
    cbz x11,.Lbad
    tst x11,#3
    b.ne .Lbad
    add x9,x9,#1
    cmp x9,#43
    b.lt .Lptrs
    add x9,sp,#512
    mov x10,#86
.Lclear:
    stp xzr,xzr,[x9],#16
    subs x10,x10,#1
    b.ne .Lclear
    adrp x26,.Lconstants
    add x26,x26,:lo12:.Lconstants
    A 6,x9
    ldrsw x20,[x9]
    cmp x20,#1
    b.lt .Lbad
    cmp x20,#4096
    b.gt .Lbad
    A 4,x9
    ldrsw x19,[x9]
    cmp x19,#1
    b.lt .Lbad
    sub x19,x19,#1
    cmp x19,x20
    b.gt .Lbad
    A 5,x9
    ldrsw x27,[x9]
    cmp x27,#0
    b.lt .Lbad
    cmp x27,x20
    b.gt .Lbad
    str x19,[sp,#2008]
    str x27,[sp,#2016]
    A 7,x9
    ldrsw x24,[x9]
    cmp x24,#9
    b.eq .Ltilesok
    cmp x24,#10
    b.ne .Lbad
.Ltilesok:
    A 8,x9
    ldrsw x22,[x9]
    cmp x22,#2
    b.eq .Lswok
    cmp x22,#6
    b.ne .Lbad
.Lswok:
    A 9,x9
    ldrsw x23,[x9]
    cmp x23,#2
    b.lt .Lbad
    cmp x23,#32
    b.gt .Lbad
    A 29,x9
    ldrsw x10,[x9]
    cmp x10,x22
    b.ne .Lbad
    ldrsw x10,[x9,#8]
    cmp x10,#1
    b.lt .Lbad
    cmp x10,x22
    b.ge .Lbad
    str x10,[sp,#2048]
    ldrsw x10,[x9,#12]
    cmp x10,#2
    b.lt .Lbad
    cmp x10,#16
    b.gt .Lbad
    str x10,[sp,#2056]
    cmp x23,#2
    b.eq .Llwok
    cmp x23,x10
    b.lt .Lbad
.Llwok:
    A 27,x9
    ldr w10,[x9]
    cmp w10,#1
    b.lt .Lbad
    cmp w10,#6
    b.gt .Lbad
    A 30,x25
    A 0,x9
    ldr w10,[x9]
    cmp w10,#1
    b.lt .Lbad
    cmp w10,#31
    b.gt .Lbad
    A 1,x9
    ldr w10,[x9]
    cmp w10,#1
    b.lt .Lbad
    cmp w10,#12
    b.gt .Lbad
    A 3,x9
    ldr w10,[x9]
    cmp w10,#0
    b.lt .Lbad
    mov w11,#20864
    movk w11,#1,lsl #16
    cmp w10,w11
    b.ge .Lbad
    mov x21,#0
    adrp x28,.Ldescs
    add x28,x28,:lo12:.Ldescs
.Ldescsloop:
    add x9,x28,x21,lsl #4
    ldp w10,w11,[x9]
    ldp w2,w4,[x9,#8]
    add x12,sp,#128
    ldr x0,[x12,x10,lsl #3]
    add x1,sp,#512
    add x1,x1,x10,lsl #5
    mov x3,x20
    cmp w10,#2
    b.ne .Ldimn
    mov x3,#12
.Ldimn:
    cmp w10,#14
    b.ne .Lnotcoeff
    mov x4,#6
    O 29,16,w9
    cmp w9,#2
    b.eq .Lhavecols
    mov x4,#4
    b .Lhavecols
.Lnotcoeff:
    cmp w10,#23
    b.eq .Ltilereq
    cmp w10,#39
    b.ne .Lnottiles
.Ltilereq:
    mov x4,x24
    b .Lhavecols
.Lnottiles:
    cmp w10,#34
    b.eq .Lswreq
    cmp w10,#35
    b.ne .Lnotsw
.Lswreq:
    mov x4,x22
    b .Lhavecols
.Lnotsw:
    cmp w10,#37
    b.ne .Lhavecols
    mov x4,x23
.Lhavecols:
    mov w5,w11
    bl .Ldescriptor
    add x21,x21,#1
    cmp x21,#25
    b.lt .Ldescsloop
    A 28,x0
    add x1,sp,#2880
    mov w2,#3
    mov x3,x22
    mov x4,#0
    mov w5,#1
    bl .Ldescriptor
    A 28,x0
    add x0,x0,#64
    add x1,sp,#2912
    mov w2,#3
    mov x3,#12
    mov x4,x22
    mov w5,#2
    bl .Ldescriptor
    A 28,x0
    add x0,x0,#152
    add x1,sp,#2944
    mov w2,#3
    mov x3,#12
    mov x4,x22
    mov w5,#2
    bl .Ldescriptor
    A 31,x0
    add x0,x0,#944
    ldr x9,[x0,#48]
    cbnz x9,.Lbad
    add x1,sp,#2976
    mov w2,#3
    mov x3,#8
    mov x4,#0
    mov w5,#1
    bl .Ldescriptor
    A 31,x0
    add x0,x0,#1008
    ldr x9,[x0,#48]
    cbnz x9,.Lbad
    add x1,sp,#3008
    mov w2,#3
    mov x3,#8
    mov x4,#0
    mov w5,#1
    bl .Ldescriptor
    mov x21,#34
.Laliasout:
    add x9,sp,#512
    add x9,x9,x21,lsl #5
    ldr x0,[x9]
    ldr x1,[x9,#24]
    mov x10,#0
.Laliasdata:
    cmp x10,x21
    b.eq .Laliasnext
    add x9,sp,#512
    add x9,x9,x10,lsl #5
    ldr x2,[x9]
    cbz x2,.Laliasnext
    ldr x3,[x9,#24]
    cmp x0,x3
    b.hs .Laliasnext
    cmp x2,x1
    b.lo .Lbad
.Laliasnext:
    add x10,x10,#1
    cmp x10,#43
    b.lt .Laliasdata
    mov x10,#0
    adrp x11,.Lsizes
    add x11,x11,:lo12:.Lsizes
.Laliasobjects:
    add x9,sp,#128
    ldr x2,[x9,x10,lsl #3]
    ldrh w3,[x11,x10,lsl #1]
    add x3,x2,x3
    cmp x0,x3
    b.hs .Laliasobjnext
    cmp x2,x1
    b.lo .Lbad
.Laliasobjnext:
    add x10,x10,#1
    cmp x10,#43
    b.lt .Laliasobjects
    add x9,sp,#2880
    mov x10,#0
.Laliasnested:
    ldr x2,[x9]
    ldr x3,[x9,#24]
    cmp x0,x3
    b.hs .Laliasnestednext
    cmp x2,x1
    b.lo .Lbad
.Laliasnestednext:
    add x9,x9,#32
    add x10,x10,#1
    cmp x10,#5
    b.lt .Laliasnested
    add x21,x21,#1
    cmp x21,#42
    b.lt .Laliasout
    mov x19,#26
.Lobjectalign:
    add x9,sp,#128
    ldr x9,[x9,x19,lsl #3]
    tst x9,#7
    b.ne .Lbad
    add x19,x19,#1
    cmp x19,#34
    b.lt .Lobjectalign
    ldr x19,[sp,#2008]
.Lindexpreflight:
    cmp x19,x27
    b.ge .Lindexdone
    V 22,w9
    cmp w9,#0
    b.lt .Lbad
    cmp w9,#7
    b.gt .Lbad
    V 13,d0
    C d1,0
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,4,none,d0,d1,real,early,comparison // fcmp d0,d1
    b.vs .Lbad
    b.lt .Lbad
    fmov d1,#20.0
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,4,none,d0,d1,real,early,comparison // fcmp d0,d1
    b.gt .Lbad
    add x19,x19,#1
    b .Lindexpreflight
.Lindexdone:
    add x28,sp,#4096
    str xzr,[sp,#1984]
    str x28,[sp,#1992]
    str x28,[sp,#2800]
    mov x9,#-1
    str x9,[sp,#2808]
    mov x9,#8
    str x9,[sp,#2816]
    mov x9,#0
    str x9,[sp,#2824]
    mov w9,#0x301
    strh w9,[sp,#2828]
    mov x9,#8
    str x9,[sp,#2832]
    mov x9,#1
    str x9,[sp,#2840]
    str x9,[sp,#2848]
    str x20,[sp,#2856]
    O 27,8,d1
    C d0,1
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,3,d0,d0,d1,real,early // fdiv d0,d0,d1
    str d0,[sp,#2096]
    A 0,x9
    ldrsw x10,[x9]
    A 1,x9
    ldrsw x11,[x9]
    cmp x10,#15
    b.lt .Learlymonth
    sub x12,x11,#1
    mov x13,#12
    udiv x14,x11,x13
    msub x13,x14,x13,x11
    str x12,[sp,#3040]
    str x13,[sp,#3048]
    ldr x14,[sp,#576]
    ldr x15,[sp,#584]
    madd x14,x12,x15,x14
    ldrsw x14,[x14]
    sub x15,x14,x10
    add x15,x15,#15
    b .Lmonthweight
.Learlymonth:
    add x12,x11,#10
    mov x13,#12
    udiv x14,x12,x13
    msub x12,x14,x13,x12
    sub x13,x11,#1
    str x12,[sp,#3040]
    str x13,[sp,#3048]
    ldr x14,[sp,#576]
    ldr x16,[sp,#584]
    madd x14,x12,x16,x14
    ldrsw x14,[x14]
    mov x15,#15
    sub x15,x15,x10
.Lmonthweight:
 md2asm_gpu_upper_operation md2asm_gpu_radiation_controller_cell_host,17,d0,x14,zero,real,early // scvtf d0,x14
    O 26,16,d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d2,real,early // fmul d0,d0,d2
 md2asm_gpu_upper_operation md2asm_gpu_radiation_controller_cell_host,17,d1,x15,zero,real,early // scvtf d1,x15
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2,real,early // fmul d1,d1,d2
    A 3,x9
    ldrsw x9,[x9]
 md2asm_gpu_upper_operation md2asm_gpu_radiation_controller_cell_host,17,d2,x9,zero,real,early // scvtf d2,x9
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2,real,early // fsub d1,d1,d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,3,d1,d1,d0,real,early // fdiv d1,d1,d0
    str d1,[sp,#2112]
    C d2,1
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d1,real,early // fsub d2,d2,d1
    str d2,[sp,#2120]
    fmov d0,xzr
    fmov d1,xzr
    fmov d2,xzr
    fmov d3,xzr
    fmov d4,xzr
    mov x21,#0
.Lsolarsums:
    ldr x9,[sp,#2880]
    ldr x10,[sp,#2888]
    madd x9,x21,x10,x9
    ldr d5,[x9]
    ldr x10,[sp,#2048]
    cmp x21,x10
    b.ge .Lnisum
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d5,real,early // fadd d0,d0,d5
    b .Lsumdone
.Lnisum:
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d5,real,early // fadd d1,d1,d5
.Lsumdone:
    A 42,x9
    ldr w9,[x9]
    cbz w9,.Licesumskip
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d4,d4,d5,real,early // fadd d4,d4,d5
    ldr d6,[sp,#2112]
    ldr d7,[sp,#2120]
    ldr x9,[sp,#2912]
    ldr x10,[sp,#2920]
    ldr x11,[sp,#2928]
    madd x9,x21,x11,x9
    ldr x12,[sp,#3040]
    ldr x13,[sp,#3048]
    madd x14,x12,x10,x9
    madd x15,x13,x10,x9
    ldr d16,[x14]
    ldr d17,[x15]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d16,d16,d6,real,early // fmul d16,d16,d6
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d17,d17,d7,real,early // fmul d17,d17,d7
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d16,d16,d17,real,early // fadd d16,d16,d17
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d16,d5,d16,real,early // fmul d16,d5,d16
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d16,real,early // fadd d2,d2,d16
    ldr x9,[sp,#2944]
    ldr x10,[sp,#2952]
    ldr x11,[sp,#2960]
    madd x9,x21,x11,x9
    madd x14,x12,x10,x9
    madd x15,x13,x10,x9
    ldr d16,[x14]
    ldr d17,[x15]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d16,d16,d6,real,early // fmul d16,d16,d6
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d17,d17,d7,real,early // fmul d17,d17,d7
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d16,d16,d17,real,early // fadd d16,d16,d17
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d16,d5,d16,real,early // fmul d16,d5,d16
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d3,d3,d16,real,early // fadd d3,d3,d16
.Licesumskip:
    add x21,x21,#1
    cmp x21,x22
    b.lt .Lsolarsums
    str d0 ,[sp,#2128]
    str d1 ,[sp,#2136]
    str d2 ,[sp,#2144]
    str d3 ,[sp,#2152]
    str d4,[sp,#2160]
    A 4,x0
    A 5,x1
    A 33,x2
    A 18,x3
    add x4,sp,#2800
    bl md2asm_canalb_wrapper_child
    ldr x19,[sp,#2008]
    cmp x19,x27
    b.ge .Lreturn
.Lcolumn:
    V 18,d0
 md2asm_gpu_upper_operation md2asm_gpu_canopy_light_cell_host,18,d0,d0,zero,real,early // bl md2asm_acos_original_rounding
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d0,d0,real,early // fmul d1,d0,d0
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d0,d1,real,early // fmul d2,d0,d1
    C d3,2
    C d4,3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d4,d4,d1,real,early // fmul d4,d4,d1
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d3,d3,d4,real,early // fsub d3,d3,d4
    C d4,4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d4,d4,d2,real,early // fmul d4,d4,d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d3,d3,d4,real,early // fadd d3,d3,d4
    str d3,[sp,#2200]
    C d3,5
    C d4,6
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d4,d4,d1,real,early // fmul d4,d4,d1
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d3,d3,d4,real,early // fsub d3,d3,d4
    C d4,7
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d4,d4,d2,real,early // fmul d4,d4,d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d3,d3,d4,real,early // fadd d3,d3,d4
    str d3,[sp,#2208]
    V 19,d0
    O 27,8,d1
    ldr d2,[sp,#2096]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1,real,early // fsub d0,d0,d1
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d2,real,early // fmul d0,d0,d2
    str d0,[sp,#2232]
    C d0,0
    C d1,1
    O 32,848,w9
    cbz w9,.Licefraction
    V 24,d2
    O 32,192,d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,4,none,d2,d3,real,early,comparison // fcmp d2,d3
    b.le .Licefraction
    C d0,1
    C d1,0
.Licefraction:
    str d0 ,[sp,#2216]
    str d1 ,[sp,#2224]
    O 31,440,w9
    cbz w9,.Lscalarsoil
    V 22,w9
    cmp w9,#0
    b.le .Lfullprop
    sxtw x9,w9
    ldr x10,[sp,#2976]
    ldr x11,[sp,#2984]
    madd x10,x9,x11,x10
    ldr d1,[x10]
    ldr x10,[sp,#3008]
    ldr x11,[sp,#3016]
    madd x10,x9,x11,x10
    ldr d2,[x10]
    b .Lsoilprop
.Lscalarsoil:
    O 31,128,d1
    O 31,136,d2
.Lsoilprop:
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2,real,early // fsub d1,d1,d2
    C d3,1
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,3,d1,d3,d1,real,early // fdiv d1,d3,d1
    V 21,d0
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d2,real,early // fsub d0,d0,d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1,real,early // fmul d0,d0,d1
    C d1,0
    C d2,1
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,14,d0,d0,d2,real,early // fmin d0,d0,d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,5,d0,d0,d1,real,early // fmax d0,d0,d1
    b .Lpropdone
.Lfullprop:
    C d0,1
.Lpropdone:
    str d0,[sp,#2240]
    mov x21,#0
.Lemissband:
    add x9,x25,#744
    ldr d0,[x9,x21,lsl #3]
    add x9,x25,#616
    ldr d1,[x9,x21,lsl #3]
    add x9,x25,#488
    ldr d2,[x9,x21,lsl #3]
    add x9,x25,#360
    ldr d3,[x9,x21,lsl #3]
    ldr d4,[sp,#2240]
    C d5,1
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d5,d5,d4,real,early // fsub d5,d5,d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d6,d2,d4,real,early // fmul d6,d2,d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d7,d3,d5,real,early // fmul d7,d3,d5
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d6,d6,d7,real,early // fadd d6,d6,d7
    str d0,[sp,#2496]
    str d1,[sp,#2504]
    str d2,[sp,#2512]
    str d6,[sp,#2520]
    str d1,[sp,#2528]
    str d6,[sp,#2536]
    str d6,[sp,#2544]
    V 11,d7
    C d16,8
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,4,none,d7,d16,real,early,comparison // fcmp d7,d16
 // Complete radiation selection region 48.
 b.le .Lrad_select_else_48
 fmov d7,d3
 b .Lrad_select_done_48
.Lrad_select_else_48:
 fmov d7,d6
.Lrad_select_done_48:
    str d7,[sp,#2552]
    fmov d16,xzr
    mov x10,#0
.Lemissti:
    add x9,sp,#2496
    ldr d17,[x9,x10,lsl #3]
    M 23,d18,x10
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d17,d17,d18,real,early // fmul d17,d17,d18
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d16,d16,d17,real,early // fadd d16,d16,d17
    add x10,x10,#1
    cmp x10,#8
    b.lt .Lemissti
    cmp x24,#10
    b.ne .Lnoemissurban
    O 33,296,d17
    mov x10,#9
    M 23,d18,x10
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d17,d17,d18,real,early // fmul d17,d17,d18
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d16,d16,d17,real,early // fadd d16,d16,d17
.Lnoemissurban:
    O 32,848,w9
    cbz w9,.Lnoemisslake
    ldr d17,[sp,#2224]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d17,d0,d17,real,early // fmul d17,d0,d17
    ldr d18,[sp,#2216]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d18,d1,d18,real,early // fmul d18,d1,d18
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d17,d17,d18,real,early // fadd d17,d17,d18
    mov x10,#8
    M 23,d18,x10
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d17,d18,d17,real,early // fmul d17,d18,d17
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d16,d16,d17,real,early // fadd d16,d16,d17
.Lnoemisslake:
    add x9,sp,#2304
    str d16,[x9,x21,lsl #3]
    add x21,x21,#1
    ldr x9,[sp,#2056]
    cmp x21,x9
    b.lt .Lemissband
    cmp x23,x9
    b.lt .Lconvertlw
    mov x21,#0
.Lcopylw:
    add x9,sp,#2304
    ldr d0,[x9,x21,lsl #3]
    SM 37,d0
    add x21,x21,#1
    ldr x9,[sp,#2056]
    cmp x21,x9
    b.lt .Lcopylw
    b .Lbroadlw
.Lconvertlw:
    mov x21,#0
.Loldweight:
    fmov d0,xzr
    mov x10,#0
    add x9,x25,#1000
    lsl x11,x21,#7
    add x9,x9,x11
.Loldsum:
    ldr d1,[x9,x10,lsl #3]
    add x11,sp,#2304
    ldr d2,[x11,x10,lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d2,d1,real,early // fmul d1,d2,d1
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1,real,early // fadd d0,d0,d1
    add x10,x10,#1
    ldr x11,[sp,#2056]
    cmp x10,x11
    b.lt .Loldsum
    SM 37,d0
    add x21,x21,#1
    cmp x21,#2
    b.lt .Loldweight
.Lbroadlw:
    cmp x23,#2
    b.ne .Lweightlw
    fmov d16,xzr
    fmov d17,xzr
    mov x21,#0
.Lplanck:
    A 27,x9
    add x9,x9,#16
    mov x10,#48
    madd x9,x21,x10,x9
    ldr d0,[x9,#40]
    ldr d1,[sp,#2232]
    mov x10,#4
.Lhorner:
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d1,d0,real,early // fmul d0,d1,d0
    ldr d2,[x9,x10,lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d2,d0,real,early // fadd d0,d2,d0
    subs x10,x10,#1
    b.ge .Lhorner
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d16,d16,d0,real,early // fadd d16,d16,d0
    cmp x21,#2
    b.eq .Lwindow
    cmp x21,#3
    b.eq .Lwindow
    mov x10,#1
    b .Lloadthermal
.Lwindow:
    mov x10,#0
.Lloadthermal:
    M 37,d1,x10
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1,real,early // fmul d0,d0,d1
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d17,d17,d0,real,early // fadd d17,d17,d0
    add x21,x21,#1
    O 27,0,w9
    cmp w21,w9
    b.lt .Lplanck
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,3,d0,d17,d16,real,early // fdiv d0,d17,d16
    SV 38,d0
    b .Lsolarcolumn
.Lweightlw:
    fmov d0,xzr
    mov x21,#0
.Ldirectlw:
    M 37,d1
    add x9,x25,#872
    ldr d2,[x9,x21,lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2,real,early // fmul d1,d1,d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1,real,early // fadd d0,d0,d1
    add x21,x21,#1
    ldr x9,[sp,#2056]
    cmp x21,x9
    b.lt .Ldirectlw
    SV 38,d0
.Lsolarcolumn:
    C d0,0
    SV 36,d0
    mov x21,#0
.Lzerotiles:
    SM 39,d0
    add x21,x21,#1
    cmp x21,x24
    b.lt .Lzerotiles
    C d0,1
    C d1,1
    A 42,x9
    ldr w9,[x9]
    cbz w9,.Lscalesdone
    V 12,d2
    C d3,0
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,4,none,d2,d3,real,early,comparison // fcmp d2,d3
    b.le .Lscalesdone
    ldr d3,[sp,#2160]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3,real,early // fmul d2,d2,d3
    ldr d3,[sp,#2144]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,3,d0,d2,d3,real,early // fdiv d0,d2,d3
    ldr d3,[sp,#2152]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,3,d1,d2,d3,real,early // fdiv d1,d2,d3
.Lscalesdone:
    str d0 ,[sp,#3056]
    str d1 ,[sp,#3064]
    mov x21,#0
.Lsolarband:
    O 29,16,w9
    ldr x10,[sp,#2048]
    cmp x21,x10
    cset w11,ge
    cmp w9,#1
    b.eq .Lfour
    cmp w9,#2
    b.eq .Lsix
    cmp w9,#3
    b.eq .Ltwo
    V 11,d0
    fmov d1,d0
    b .Llanddone
.Lfour:
    lsl x10,x11,#1
    M 14,d1,x10
    add x10,x10,#1
    M 14,d0,x10
    b .Llandclip
.Ltwo:
    lsl x10,x11,#1
    add x10,x10,#1
    M 14,d0,x10
    fmov d1,d0
    b .Llandclip
.Lsix:
    mov x10,#3
    mul x10,x11,x10
    M 14,d0,x10
    fmov d1,d0
    add x10,x10,#1
    M 14,d2,x10
    ldr d3,[sp,#2200]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d3,d2,d3,real,early // fmul d3,d2,d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d3,real,early // fadd d1,d1,d3
    C d3,9
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d3,d2,d3,real,early // fmul d3,d2,d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d3,real,early // fadd d0,d0,d3
    add x10,x10,#1
    M 14,d2,x10
    ldr d3,[sp,#2208]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d3,d2,d3,real,early // fmul d3,d2,d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d3,real,early // fadd d1,d1,d3
    C d3,10
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d3,d2,d3,real,early // fmul d3,d2,d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d3,real,early // fadd d0,d0,d3
.Llandclip:
    ldr d2,[x25,#352]
    C d3,1
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d3,d3,d2,real,early // fsub d3,d3,d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,5,d0,d0,d2,real,early // fmax d0,d0,d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,14,d0,d3,d0,real,early // fmin d0,d3,d0
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,5,d1,d1,d2,real,early // fmax d1,d1,d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,14,d1,d3,d1,real,early // fmin d1,d3,d1
.Llanddone:
    str d0,[sp,#2512]
    str d0,[sp,#2520]
    str d0,[sp,#2536]
    str d0,[sp,#2552]
    str d1,[sp,#2608]
    str d1,[sp,#2616]
    str d1,[sp,#2632]
    str d1,[sp,#2648]
    cmp x24,#10
    b.ne .Lnourbanland
    O 33,272,d2
    C d3,1
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d3,d3,d2,real,early // fadd d3,d3,d2
    C d4,1
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,3,d4,d4,d3,real,early // fdiv d4,d4,d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,3,d2,d2,d3,real,early // fdiv d2,d2,d3
    O 33,40,d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d4,d3,d4,real,early // fmul d4,d3,d4
    ldr x9,[sp,#1992]
    ldr d3,[x9,x19,lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d3,d2,real,early // fmul d2,d3,d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d4,d2,real,early // fadd d2,d4,d2
    str d2,[sp,#2568]
    str d2,[sp,#2664]
    V 15,d3
    C d4,1
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d4,d4,d3,real,early // fsub d4,d4,d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d4,real,early // fmul d0,d0,d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d4,real,early // fmul d1,d1,d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3,real,early // fmul d2,d2,d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d2,real,early // fadd d0,d0,d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2,real,early // fadd d1,d1,d2
    str d0,[sp,#2512]
    str d1,[sp,#2608]
.Lnourbanland:
    ldr d0,[x25,#344]
    str d0,[sp,#2496]
    V 18,d0
    C d1,11
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,8,d0,d0,d1,real,early // bl md2asm_pow_original_rounding_candidate
    C d1,12
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d1,d0,real,early // fmul d0,d1,d0
    C d1,13
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1,real,early // fadd d0,d0,d1
    C d1,14
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,3,d0,d1,d0,real,early // fdiv d0,d1,d0
    ldr d1,[x25,#352]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,5,d0,d0,d1,real,early // fmax d0,d0,d1
    str d0,[sp,#2592]
    ldr d0,[sp,#2112]
    ldr d1,[sp,#2120]
    ldr x9,[sp,#2912]
    ldr x10,[sp,#2920]
    ldr x11,[sp,#2928]
    madd x9,x21,x11,x9
    ldr x12,[sp,#3040]
    ldr x13,[sp,#3048]
    madd x14,x12,x10,x9
    madd x15,x13,x10,x9
    ldr d2,[x14]
    ldr d3,[x15]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d0,d2,real,early // fmul d2,d0,d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d3,d1,d3,real,early // fmul d3,d1,d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3,real,early // fadd d2,d2,d3
    ldr d4,[sp,#3056]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d4,d2,real,early // fmul d2,d4,d2
    C d4,1
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,14,d2,d4,d2,real,early // fmin d2,d4,d2
    ldr x9,[sp,#2944]
    ldr x10,[sp,#2952]
    ldr x11,[sp,#2960]
    madd x9,x21,x11,x9
    madd x14,x12,x10,x9
    madd x15,x13,x10,x9
    ldr d3,[x14]
    ldr d4,[x15]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d3,d0,d3,real,early // fmul d3,d0,d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d4,d1,d4,real,early // fmul d4,d1,d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d3,d3,d4,real,early // fadd d3,d3,d4
    ldr d4,[sp,#3064]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d3,d4,d3,real,early // fmul d3,d4,d3
    C d4,1
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,14,d3,d4,d3,real,early // fmin d3,d4,d3
    V 10,w9
    cmp w9,#0
 // Complete radiation selection region 111.
 b.eq .Lrad_select_else_111
 fmov d2,d2
 b .Lrad_select_done_111
.Lrad_select_else_111:
 fmov d2,d3
.Lrad_select_done_111:
    str d2,[sp,#2504]
    str d2,[sp,#2600]
    V 17,d0
    C d1,15
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d0,real,early // fsub d1,d1,d0
    C d2,16
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d2,d1,real,early // fmul d1,d2,d1
    C d2,17
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d2,real,early // fsub d0,d0,d2
    C d2,18
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d2,d0,real,early // fmul d0,d2,d0
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d1,d0,real,early // fadd d0,d1,d0
    C d1,15
    C d2,17
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2,real,early // fsub d1,d1,d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,3,d0,d0,d1,real,early // fdiv d0,d0,d1
    C d1,19
    C d2,20
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,5,d0,d0,d1,real,early // fmax d0,d0,d1
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,14,d0,d2,d0,real,early // fmin d0,d2,d0
    ldr x9,[sp,#2048]
    cmp x21,x9
    b.lt .Lsnowready
    ldr d1,[sp,#2128]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1,real,early // fmul d0,d0,d1
    V 17,d1
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d1,d0,real,early // fsub d0,d1,d0
    ldr d1,[sp,#2136]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,3,d0,d0,d1,real,early // fdiv d0,d0,d1
    C d1,19
    C d2,20
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,5,d0,d0,d1,real,early // fmax d0,d0,d1
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,14,d0,d2,d0,real,early // fmin d0,d2,d0
.Lsnowready:
    str d0,[sp,#2528]
    str d0,[sp,#2624]
    O 31,448,w9
    cbz w9,.Lforestdefault
    V 13,d0
 md2asm_gpu_upper_operation md2asm_gpu_tile_boundary_cell_host,17,x10,d0,zero,real,early,integer,256,register_after_upper // fcvtas x10,d0
    b .Lforestindex
.Lforestdefault:
    mov x10,#0
.Lforestindex:
    ldr x9,[sp,#2048]
    cmp x21,x9
    mov x11,#21
    csel x11,xzr,x11,lt
    add x10,x10,x11
    add x9,x25,#8
    ldr d0,[x9,x10,lsl #3]
    cmp x24,#10
    b.ne .Lforestready
    V 15,d1
    C d2,0
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,4,none,d1,d2,real,early,comparison // fcmp d1,d2
    b.le .Lforestready
    C d2,1
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d1,real,early // fsub d2,d2,d1
    V 16,d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d3,d2,real,early // fmul d2,d3,d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d3,d0,d2,real,early // fmul d3,d0,d2
    C d4,21
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d4,d0,real,early // fmul d0,d4,d0
    ldr d5,[sp,#2568]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d5,d4,d5,real,early // fmul d5,d4,d5
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d5,real,early // fadd d0,d0,d5
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1,real,early // fmul d0,d0,d1
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d3,d0,real,early // fadd d0,d3,d0
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d1,real,early // fadd d2,d2,d1
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,3,d0,d0,d2,real,early // fdiv d0,d0,d2
.Lforestready:
    str d0,[sp,#2544]
    str d0,[sp,#2640]
    O 32,848,w9
    cbz w9,.Llakeexpone
    O 26,0,d0
    V 25,d1
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d0,d1,real,early // fsub d1,d0,d1
    C d2,22
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d2,d1,real,early // fmul d1,d2,d1
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,3,d0,d1,d0,real,early // fdiv d0,d1,d0
 md2asm_gpu_upper_operation md2asm_gpu_lake_energy_cell_host,18,d0,d0,zero,real,early // bl exp
    b .Llakeexpdone
.Llakeexpone:
    C d0,1
.Llakeexpdone:
    C d1,1
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d0,real,early // fsub d1,d1,d0
    C d2,23
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d2,d1,real,early // fmul d1,d2,d1
    C d2,24
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d2,d0,real,early // fmul d0,d2,d0
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d1,d0,real,early // fadd d0,d1,d0
    ldr d1,[sp,#2216]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1,real,early // fmul d0,d0,d1
    ldr d1,[sp,#2224]
    ldr d2,[sp,#2496]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d1,real,early // fmul d2,d2,d1
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d0,real,early // fadd d2,d2,d0
    str d2,[sp,#2560]
    ldr d2,[sp,#2592]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d1,real,early // fmul d2,d2,d1
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d0,real,early // fadd d2,d2,d0
    str d2,[sp,#2656]
    ldr x9,[sp,#2880]
    ldr x10,[sp,#2888]
    madd x9,x21,x10,x9
    ldr d16,[x9]
    mov x10,#0
.Ltileupdate:
    cmp x10,#8
    b.ne .Ltileactive
    O 32,848,w9
    cbz w9,.Ltileskip
.Ltileactive:
    add x9,sp,#2496
    ldr d0,[x9,x10,lsl #3]
    add x9,sp,#2592
    ldr d1,[x9,x10,lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1,real,early // fadd d0,d0,d1
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d16,d0,real,early // fmul d0,d16,d0
    C d1,21
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1,real,early // fmul d0,d0,d1
    M 39,d1,x10
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d1,d0,real,early // fadd d0,d1,d0
    SM 39,d0,x10
.Ltileskip:
    add x10,x10,#1
    cmp x10,x24
    b.lt .Ltileupdate
    fmov d0,xzr
    fmov d1,xzr
    mov x10,#0
.Lmean:
    add x9,sp,#2496
    ldr d2,[x9,x10,lsl #3]
    add x9,sp,#2592
    ldr d3,[x9,x10,lsl #3]
    M 23,d4,x10
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d4,d2,real,early // fmul d2,d4,d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d3,d4,d3,real,early // fmul d3,d4,d3
    cbnz x10,.Lmeanadd
    fmov d0,d2
    fmov d1,d3
    b .Lmeannext
.Lmeanadd:
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d2,real,early // fadd d0,d0,d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d3,real,early // fadd d1,d1,d3
.Lmeannext:
    add x10,x10,#1
    cmp x10,#8
    b.lt .Lmean
    cmp x24,#10
    b.ne .Lmeanlake
    mov x10,#9
    M 23,d4,x10
    ldr d2,[sp,#2568]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d4,d2,real,early // fmul d2,d4,d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d2,real,early // fadd d0,d0,d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2,real,early // fadd d1,d1,d2
.Lmeanlake:
    O 32,848,w9
    cbz w9,.Lmeanready
    mov x10,#8
    M 23,d4,x10
    ldr d2,[sp,#2560]
    ldr d3,[sp,#2656]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d4,d2,real,early // fmul d2,d4,d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d3,d4,d3,real,early // fmul d3,d4,d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d2,real,early // fadd d0,d0,d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d3,real,early // fadd d1,d1,d3
.Lmeanready:
    SM 34,d0
    SM 35,d1
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d16,d0,real,early // fmul d0,d16,d0
    V 36,d1
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d1,d0,real,early // fadd d0,d1,d0
    SV 36,d0
    add x21,x21,#1
    cmp x21,x22
    b.lt .Lsolarband
    O 29,28,w9
    cbz w9,.Loceanconstant
    V 20,d0
    C d1,25
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,4,none,d0,d1,real,early,comparison // fcmp d0,d1
    b.gt .Loceancap
    C d1,26
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,4,none,d0,d1,real,early,comparison // fcmp d0,d1
    b.gt .Loceanwindhigh
    C d1,27
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d1,d0,real,early // fmul d0,d1,d0
    C d1,28
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1,real,early // fadd d0,d0,d1
    b .Loceanexp
.Loceanwindhigh:
    C d1,29
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d1,d0,real,early // fmul d0,d1,d0
    C d1,30
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1,real,early // fadd d0,d0,d1
.Loceanexp:
 md2asm_gpu_upper_operation md2asm_gpu_lake_energy_cell_host,18,d0,d0,zero,real,early // bl exp
    b .Loceanlog
.Loceancap:
    C d0,31
.Loceanlog:
 md2asm_gpu_upper_operation md2asm_gpu_radiation_controller_cell_host,18,d0,d0,zero,real,early // bl md2asm_log10_radiation_original_rounding
    C d1,21
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d1,d0,real,early // fmul d0,d1,d0
    C d1,32
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d0,real,early // fadd d1,d1,d0
    C d0,33
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,8,d0,d0,d1,real,early // bl md2asm_pow_original_rounding_candidate
    b .Loceanready
.Loceanconstant:
    O 29,32,d0
.Loceanready:
    SV 41,d0
    O 29,24,w9
    cbz w9,.Llandconstant
    V 20,d0
    C d1,26
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,4,none,d0,d1,real,early,comparison // fcmp d0,d1
    b.gt .Llandwindhigh
    C d1,27
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d1,d0,real,early // fmul d0,d1,d0
    C d1,34
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1,real,early // fadd d0,d0,d1
    b .Llandexp
.Llandwindhigh:
    C d1,29
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d1,d0,real,early // fmul d0,d1,d0
    C d1,30
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1,real,early // fadd d0,d0,d1
.Llandexp:
 md2asm_gpu_upper_operation md2asm_gpu_lake_energy_cell_host,18,d0,d0,zero,real,early // bl exp
 md2asm_gpu_upper_operation md2asm_gpu_radiation_controller_cell_host,18,d0,d0,zero,real,early // bl md2asm_log10_radiation_original_rounding
    C d1,8
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d1,d0,real,early // fmul d0,d1,d0
    C d1,35
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d0,real,early // fadd d1,d1,d0
    C d0,33
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,8,d0,d0,d1,real,early // bl md2asm_pow_original_rounding_candidate
    b .Llandready
.Llandconstant:
    O 29,40,d0
.Llandready:
    SV 40,d0
    add x19,x19,#1
    cmp x19,x27
    b.lt .Lcolumn
.Lreturn:
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp x29,x30,[sp]
    add sp,sp,#9,lsl #12
    ret
.Ldescriptor:
    tst x0,#7
    b.ne .Lbad
    ldr x6,[x0]
    cbz x6,.Lbad
    cmp w2,#3
    mov x7,#4
    mov x8,#8
    csel x7,x8,x7,eq
    sub x8,x7,#1
    tst x6,x8
    b.ne .Lbad
    ldr x8,[x0,#16]
    cmp x8,x7
    b.ne .Lbad
    ldr x8,[x0,#32]
    cmp x8,x7
    b.ne .Lbad
    ldrb w8,[x0,#28]
    cmp w8,w5
    b.ne .Lbad
    ldrb w8,[x0,#29]
    cmp w8,w2
    b.ne .Lbad
    ldr x8,[x0,#40]
    cmp x8,#0
    b.le .Lbad
    ldp x9,x10,[x0,#48]
    subs x10,x10,x9
    b.vs .Lbad
    adds x10,x10,#1
    b.vs .Lbad
    cmp x10,x3
    b.lt .Lbad
    cmp x10,#4096
    b.gt .Lbad
    sub x10,x10,#1
    umulh x9,x10,x8
    cbnz x9,.Lbad
    mul x10,x10,x8
    mov x11,#0
    cmp w5,#1
    b.eq .Lspan
    ldr x11,[x0,#64]
    cmp x11,x10
    b.le .Lbad
    cmp x11,#0
    b.le .Lbad
    ldp x12,x13,[x0,#72]
    subs x13,x13,x12
    b.vs .Lbad
    adds x13,x13,#1
    b.vs .Lbad
    cmp x13,x4
    b.lt .Lbad
    cmp x13,#32
    b.gt .Lbad
    sub x13,x13,#1
    umulh x12,x13,x11
    cbnz x12,.Lbad
    mul x13,x13,x11
    adds x10,x10,x13
    b.cs .Lbad
.Lspan:
    mov x12,#0xffffff
    cmp x10,x12
    b.hi .Lbad
    add x10,x10,#1
    mul x10,x10,x7
    adds x10,x6,x10
    b.cs .Lbad
    mul x8,x8,x7
    mul x11,x11,x7
    stp x6,x8,[x1]
    stp x11,x10,[x1,#16]
    ret
.Lbad:
    mov sp,x29
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp x29,x30,[sp]
    add sp,sp,#9,lsl #12
.Lreject:
    b abort
.size md2asm_surfrad_ctl_wrapper_body,.-md2asm_surfrad_ctl_wrapper_body
.section .rodata
.align 3
.Lconstants:
    .double 0.,1.,-.007574,.070987,.307588,-1.284909,.166314,.041840,.30,.189184,-1.377622,1.4,1.1,.15,.037,.74,.57,.47,.89,.02,.98,.5,-95.6,.7,.4,30.,15.,.16,1.44,.13,1.89,327.,1.2,10.,1.45,2.21
.Ldescs:
    .word 2,1,1,0
    .word 10,1,2,0
    .word 11,1,3,0
    .word 12,1,3,0
    .word 13,1,3,0
    .word 14,2,3,6
    .word 15,1,3,0
    .word 16,1,3,0
    .word 17,1,3,0
    .word 18,1,3,0
    .word 19,1,3,0
    .word 20,1,3,0
    .word 21,1,3,0
    .word 22,1,1,0
    .word 23,2,3,10
    .word 24,1,3,0
    .word 25,1,3,0
    .word 34,2,3,6
    .word 35,2,3,6
    .word 36,1,3,0
    .word 37,2,3,16
    .word 38,1,3,0
    .word 39,2,3,10
    .word 40,1,3,0
    .word 41,1,3,0
.Lsizes:
    .hword 4,4,64,4,4,4,4,4,4,4,64,64,64,64,88,64,64,64,64,64,64,64,64,88,64,64,128,304,240,48,1256,2416,856,472,88,88,64,88,64,88,64,64,4
.section .note.GNU-stack,"",%progbits
