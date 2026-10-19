#include "../../support/gpu/preserved_weather_calls.inc.S"
/* Complete declared RADPAR radiation preparation. Source order is frozen.
 * Selected coarse forecast has prognostic clouds and accepted direct children.
 * Physics formulations/openifs/radiation/radiation_preparation.md.
 * Contract skills/md2asm/references/openifs/radiation/radiation_parent_contract.md.
 * 68 ordinary addresses and a measured 4,275,088-byte MODEL owner. */
#ifndef RADPAR_SYMBOL
#define RADPAR_SYMBOL md2asm_radpar
#endif
.text
.p2align 4
.global RADPAR_SYMBOL
.type RADPAR_SYMBOL,%function
RADPAR_SYMBOL:
    sub sp,sp,#2,lsl #12
    stp x19,x20,[sp,#320]
    stp x21,x22,[sp,#336]
    stp x23,x24,[sp,#352]
    stp x25,x26,[sp,#368]
    stp x27,x28,[sp,#384]
    stp x29,x30,[sp,#400]
    stp d8,d9,[sp,#416]
    stp d10,d11,[sp,#432]
    stp d12,d13,[sp,#448]
    stp d14,d15,[sp,#464]
    str x18,[sp,#304]
    mov x29,sp
    add x20,x29,#512
    stp x0,x1,[x20,#0]
    stp x2,x3,[x20,#16]
    stp x4,x5,[x20,#32]
    stp x6,x7,[x20,#48]
    add x11,sp,#2,lsl #12
    mov x10,#8
.Lrp_save:
    ldr x9,[x11],#8
    str x9,[x20,x10,lsl #3]
    add x10,x10,#1
    cmp x10,#68
    b.lo .Lrp_save
    mrs x9,fpcr
    cbnz x9,.Lrp_bad
    mov x10,#0
.Lrp_ptrs:
    ldr x9,[x20,x10,lsl #3]
    cbz x9,.Lrp_bad
    tst x9,#3
    b.ne .Lrp_bad
    add x10,x10,#1
    cmp x10,#68
    b.lo .Lrp_ptrs
    ldr x19,[x20]
    ldr x9,[x20,#24]
    ldr w21,[x9]
    cmp w21,#1
    b.lt .Lrp_bad
    cmp w21,#2048
    b.gt .Lrp_bad
    ldr x9,[x20,#64]
    ldr w22,[x9]
    cmp w22,#3
    b.lt .Lrp_bad
    cmp w22,#512
    b.gt .Lrp_bad
    ldr x9,[x20,#8]
    ldr w24,[x9]
    sub w24,w24,#1
    cmp w24,#0
    b.lt .Lrp_bad
    cmp w24,w21
    b.ge .Lrp_bad
    ldr x9,[x20,#16]
    ldr w25,[x9]
    cmp w25,#0
    b.lt .Lrp_bad
    cmp w25,w21
    b.gt .Lrp_bad
    movz x9,#4532
    movk x9,#24,lsl #16
    add x9,x19,x9
    ldr w23,[x9]
    cmp w23,#8
    b.lt .Lrp_bad
    cmp w23,#16
    b.gt .Lrp_bad
.Lrp_tiles_ok:
    movz x9,#5036
    movk x9,#24,lsl #16
    add x9,x19,x9
    ldr w10,[x9]
    cmp w10,#1
    b.hi .Lrp_bad
    cbz w10,.Lrp_cloud_ok
    movz x9,#5092
    movk x9,#24,lsl #16
    add x9,x19,x9
    ldr w10,[x9]
    cmp w10,#1
    b.ne .Lrp_bad
.Lrp_cloud_ok:
    movz x9,#5068
    movk x9,#24,lsl #16
    add x9,x19,x9
    ldr w10,[x9]
    cmp w10,#1
    b.hi .Lrp_bad
    movz x9,#55648
    movk x9,#23,lsl #16
    add x9,x19,x9
    ldr w10,[x9]
    cmp w10,#1
    b.hi .Lrp_bad
    movz x9,#15436
    movk x9,#24,lsl #16
    add x9,x19,x9
    ldr w10,[x9]
    cmp w10,#1
    b.hi .Lrp_bad
    ldr x9,[x20,#32]
    ldr w10,[x9]
    cmp w10,#1
    b.lt .Lrp_bad
    cmp w10,#32
    b.gt .Lrp_bad
    ldr x9,[x20,#40]
    ldr w10,[x9]
    cmp w10,#1
    b.lt .Lrp_bad
    cmp w10,#32
    b.gt .Lrp_bad
    movz x9,#35924
    movk x9,#24,lsl #16
    add x9,x19,x9
    ldr w10,[x9]
    cmp w10,#1
    b.lt .Lrp_bad
    cmp w10,#6
    b.gt .Lrp_bad
    movz x9,#35944
    movk x9,#24,lsl #16
    add x9,x19,x9
    ldr w10,[x9]
    cmp w10,#1
    b.lt .Lrp_bad
    cmp w10,#32
    b.gt .Lrp_bad
    movz x9,#35936
    movk x9,#24,lsl #16
    add x9,x19,x9
    ldr w10,[x9]
    cmp w10,#1
    b.lt .Lrp_bad
    cmp w10,#16
    b.gt .Lrp_bad
    movz x9,#35924
    movk x9,#24,lsl #16
    add x9,x19,x9
    ldr w10,[x9]
    movz x9,#35944
    movk x9,#24,lsl #16
    add x9,x19,x9
    ldr w11,[x9]
    cmp w11,w10
    b.lt .Lrp_bad
    movz x9,#5464
    movk x9,#24,lsl #16
    add x9,x19,x9
    ldr x9,[x9]
    cbz x9,.Lrp_bad
    tst x9,#7
    b.ne .Lrp_bad
    ldr x9,[x20,#240]
    ldr x10,[x9]
    cbz x10,.Lrp_bad
    ldp x10,x11,[x9,#48]
    sub x11,x11,x10
    add x11,x11,#1
    cmp x11,x21
    b.lt .Lrp_bad
    mov x0,#1
    add x1,x23,x23
    add x1,x1,#24
    mul x1,x1,x21
    lsl x1,x1,#3
    bl calloc
    cbz x0,.Lrp_bad
    mov x28,x0
    mov x10,#0
    mov x11,x0
.Lrp_rows:
    add x9,x29,#1104
    str x11,[x9,x10,lsl #3]
    add x11,x11,x21,lsl #3
    add x10,x10,#1
    cmp x10,#24
    b.lo .Lrp_rows
    str x11,[x29,#1296]
    mul x9,x21,x23
    add x11,x11,x9,lsl #3
    str x11,[x29,#1304]
    mov w9,#2
    str w9,[x29,#1056]
    mov w9,#-1
    str w9,[x29,#1372]
    add x0,x29,#2048
    ldr x1,[x20,#296]
    mov x3,#0
    mov x2,x21
    mov x4,#8
    mov x5,#3
    bl .Lrp_desc
    add x0,x29,#2136
    ldr x1,[x20,#304]
    mov x3,#0
    mov x2,x21
    mov x4,#8
    mov x5,#3
    bl .Lrp_desc
    add x0,x29,#2224
    ldr x1,[x20,#312]
    mov x3,#0
    mov x2,x21
    mov x4,#8
    mov x5,#3
    bl .Lrp_desc
    add x0,x29,#2312
    ldr x1,[x20,#360]
    mov x3,#0
    mov x2,x21
    mov x4,#8
    mov x5,#3
    bl .Lrp_desc
    add x0,x29,#2400
    ldr x1,[x20,#368]
    mov x3,#0
    mov x2,x21
    mov x4,#8
    mov x5,#3
    bl .Lrp_desc
    add x0,x29,#2488
    ldr x1,[x20,#320]
    mov x3,#0
    mov x2,x21
    mov x4,#8
    mov x5,#3
    bl .Lrp_desc
    add x0,x29,#2576
    ldr x1,[x20,#328]
    mov x3,#0
    mov x2,x21
    mov x4,#8
    mov x5,#3
    bl .Lrp_desc
    add x0,x29,#2664
    ldr x1,[x20,#336]
    mov x3,#0
    mov x2,x21
    mov x4,#8
    mov x5,#3
    bl .Lrp_desc
    add x0,x29,#2752
    ldr x1,[x20,#344]
    mov x3,#0
    mov x2,x21
    mov x4,#8
    mov x5,#3
    bl .Lrp_desc
    add x0,x29,#2840
    ldr x1,[x20,#352]
    mov x3,#0
    mov x2,x21
    mov x4,#8
    mov x5,#3
    bl .Lrp_desc
    add x0,x29,#2928
    ldr x1,[x20,#264]
    mov x3,#0
    mov x2,x21
    mov x4,#8
    mov x5,#3
    bl .Lrp_desc
    add x0,x29,#3016
    ldr x1,[x20,#376]
    mov x3,#0
    mov x2,x21
    mov x4,#8
    mov x5,#3
    bl .Lrp_desc
    add x0,x29,#3104
    ldr x1,[x20,#224]
    mov x3,#0
    mov x2,x21
    mov x4,#8
    mov x5,#3
    bl .Lrp_desc
    add x0,x29,#3192
    ldr x1,[x20,#208]
    mov x3,#0
    mov x2,x21
    mov x4,#8
    mov x5,#3
    bl .Lrp_desc
    add x0,x29,#3280
    ldr x1,[x20,#280]
    mov x3,#0
    mov x2,x21
    mov x4,#8
    mov x5,#3
    bl .Lrp_desc
    add x0,x29,#3368
    ldr x1,[x20,#184]
    mov x3,#0
    mov x2,x21
    mov x4,#8
    mov x5,#3
    bl .Lrp_desc
    add x0,x29,#3456
    ldr x1,[x20,#408]
    mov x3,#0
    mov x2,x21
    mov x4,#4
    mov x5,#2
    bl .Lrp_desc
    add x0,x29,#3544
    ldr x1,[x20,#232]
    mov x3,#0
    mov x2,x21
    mov x4,#8
    mov x5,#3
    bl .Lrp_desc
    add x0,x29,#3632
    ldr x1,[x20,#272]
    mov x3,#0
    mov x2,x21
    mov x4,#8
    mov x5,#3
    bl .Lrp_desc
    add x0,x29,#3720
    ldr x1,[x20,#176]
    mov x3,#0
    mov x2,x21
    mov x4,#8
    mov x5,#3
    bl .Lrp_desc
    add x0,x29,#3808
    ldr x1,[x20,#216]
    mov x3,#0
    mov x2,x21
    mov x4,#8
    mov x5,#3
    bl .Lrp_desc
    add x0,x29,#3896
    ldr x1,[x20,#432]
    mov x3,#0
    mov x2,x21
    mov x4,#8
    mov x5,#3
    bl .Lrp_desc
    add x0,x29,#3984
    ldr x1,[x20,#440]
    mov x3,#0
    mov x2,x21
    mov x4,#8
    mov x5,#3
    bl .Lrp_desc
    add x0,x29,#4072
    ldr x1,[x20,#528]
    mov x3,#0
    mov x2,x21
    mov x4,#8
    mov x5,#3
    bl .Lrp_desc
    mov x17,#4160
    add x0,x29,x17
    ldr x1,[x20,#256]
    mov x3,#0
    mov x2,x21
    mov x4,#8
    mov x5,#3
    bl .Lrp_desc
    mov x17,#4248
    add x0,x29,x17
    ldr x1,[x29,#1104]
    mov x3,#0
    mov x2,x21
    mov x4,#8
    mov x5,#3
    bl .Lrp_desc
    mov x17,#4336
    add x0,x29,x17
    ldr x1,[x29,#1112]
    mov x3,#0
    mov x2,x21
    mov x4,#8
    mov x5,#3
    bl .Lrp_desc
    mov x17,#4424
    add x0,x29,x17
    ldr x1,[x29,#1120]
    mov x3,#0
    mov x2,x21
    mov x4,#8
    mov x5,#3
    bl .Lrp_desc
    mov x17,#4512
    add x0,x29,x17
    ldr x1,[x29,#1128]
    mov x3,#0
    mov x2,x21
    mov x4,#8
    mov x5,#3
    bl .Lrp_desc
    mov x17,#4600
    add x0,x29,x17
    ldr x1,[x29,#1136]
    mov x3,#0
    mov x2,x21
    mov x4,#8
    mov x5,#3
    bl .Lrp_desc
    mov x17,#4688
    add x0,x29,x17
    ldr x1,[x29,#1144]
    mov x3,#0
    mov x2,x21
    mov x4,#8
    mov x5,#3
    bl .Lrp_desc
    mov x17,#4776
    add x0,x29,x17
    ldr x1,[x29,#1152]
    mov x3,#0
    mov x2,x21
    mov x4,#8
    mov x5,#3
    bl .Lrp_desc
    mov x17,#4864
    add x0,x29,x17
    ldr x1,[x29,#1160]
    mov x3,#0
    mov x2,x21
    mov x4,#8
    mov x5,#3
    bl .Lrp_desc
    mov x17,#4952
    add x0,x29,x17
    ldr x1,[x29,#1168]
    mov x3,#0
    mov x2,x21
    mov x4,#8
    mov x5,#3
    bl .Lrp_desc
    mov x17,#5040
    add x0,x29,x17
    ldr x1,[x29,#1176]
    mov x3,#0
    mov x2,x21
    mov x4,#8
    mov x5,#3
    bl .Lrp_desc
    mov x17,#5128
    add x0,x29,x17
    ldr x1,[x29,#1184]
    mov x3,#0
    mov x2,x21
    mov x4,#8
    mov x5,#3
    bl .Lrp_desc
    mov x17,#5216
    add x0,x29,x17
    ldr x1,[x29,#1192]
    mov x3,#0
    mov x2,x21
    mov x4,#8
    mov x5,#3
    bl .Lrp_desc
    mov x17,#5304
    add x0,x29,x17
    ldr x1,[x29,#1200]
    mov x3,#0
    mov x2,x21
    mov x4,#8
    mov x5,#3
    bl .Lrp_desc
    mov x17,#5392
    add x0,x29,x17
    ldr x1,[x29,#1208]
    mov x3,#0
    mov x2,x21
    mov x4,#8
    mov x5,#3
    bl .Lrp_desc
    mov x17,#5480
    add x0,x29,x17
    ldr x1,[x29,#1216]
    mov x3,#0
    mov x2,x21
    mov x4,#4
    mov x5,#1
    bl .Lrp_desc
    mov x17,#5568
    add x0,x29,x17
    ldr x1,[x29,#1224]
    mov x3,#0
    mov x2,x21
    mov x4,#4
    mov x5,#1
    bl .Lrp_desc
    mov x17,#5656
    add x0,x29,x17
    ldr x1,[x29,#1232]
    mov x3,#0
    mov x2,x21
    mov x4,#4
    mov x5,#1
    bl .Lrp_desc
    mov x17,#5744
    add x0,x29,x17
    ldr x1,[x29,#1240]
    mov x3,#0
    mov x2,x21
    mov x4,#4
    mov x5,#1
    bl .Lrp_desc
    mov x17,#5832
    add x0,x29,x17
    ldr x1,[x29,#1248]
    mov x3,#0
    mov x2,x21
    mov x4,#4
    mov x5,#1
    bl .Lrp_desc
    mov x17,#5920
    add x0,x29,x17
    ldr x1,[x29,#1256]
    mov x3,#0
    mov x2,x21
    mov x4,#4
    mov x5,#1
    bl .Lrp_desc
    mov x17,#6008
    add x0,x29,x17
    ldr x1,[x29,#1264]
    mov x3,#0
    mov x2,x21
    mov x4,#4
    mov x5,#2
    bl .Lrp_desc
    mov x17,#6096
    add x0,x29,x17
    ldr x1,[x29,#1272]
    mov x3,#0
    mov x2,x21
    mov x4,#4
    mov x5,#2
    bl .Lrp_desc
    mov x17,#6184
    add x0,x29,x17
    ldr x1,[x29,#1280]
    mov x3,#0
    mov x2,x21
    mov x4,#4
    mov x5,#2
    bl .Lrp_desc
    mov x17,#6272
    add x0,x29,x17
    ldr x1,[x29,#1288]
    mov x3,#0
    mov x2,x21
    mov x4,#4
    mov x5,#2
    bl .Lrp_desc
    mov x17,#6360
    add x0,x29,x17
    ldr x1,[x29,#1296]
    mov x3,x23
    mov x2,x21
    mov x4,#8
    mov x5,#3
    bl .Lrp_desc
    mov x17,#6448
    add x0,x29,x17
    ldr x1,[x29,#1304]
    mov x3,x23
    mov x2,x21
    mov x4,#8
    mov x5,#3
    bl .Lrp_desc
    mov x17,#6536
    add x0,x29,x17
    ldr x1,[x20,#160]
    ldr x9,[x20,#40]
    ldr w3,[x9]
    mov x2,x21
    mov x4,#8
    mov x5,#3
    bl .Lrp_desc
    mov x17,#6624
    add x0,x29,x17
    ldr x1,[x20,#168]
    ldr x9,[x20,#40]
    ldr w3,[x9]
    mov x2,x21
    mov x4,#8
    mov x5,#3
    bl .Lrp_desc
    mov x17,#6712
    add x0,x29,x17
    ldr x1,[x20,#248]
    ldr x9,[x20,#40]
    ldr w3,[x9]
    mov x2,x21
    mov x4,#8
    mov x5,#3
    bl .Lrp_desc
    mov x17,#6800
    add x0,x29,x17
    ldr x1,[x20,#192]
    ldr x9,[x20,#32]
    ldr w3,[x9]
    mov x2,x21
    mov x4,#8
    mov x5,#3
    bl .Lrp_desc
    mov x17,#6888
    add x0,x29,x17
    ldr x1,[x20,#416]
    movz x9,#35944
    movk x9,#24,lsl #16
    add x9,x19,x9
    ldr w3,[x9]
    mov x2,x21
    mov x4,#8
    mov x5,#3
    bl .Lrp_desc
    mov x17,#6976
    add x0,x29,x17
    ldr x1,[x20,#424]
    movz x9,#35944
    movk x9,#24,lsl #16
    add x9,x19,x9
    ldr w3,[x9]
    mov x2,x21
    mov x4,#8
    mov x5,#3
    bl .Lrp_desc
    mov x17,#7064
    add x0,x29,x17
    ldr x1,[x20,#520]
    movz x9,#35936
    movk x9,#24,lsl #16
    add x9,x19,x9
    ldr w3,[x9]
    mov x2,x21
    mov x4,#8
    mov x5,#3
    bl .Lrp_desc
    mov x17,#7152
    add x0,x29,x17
    add x1,x29,#1320
    mov x2,#12
    mov x3,#0
    mov x4,#4
    mov x5,#1
    bl .Lrp_desc
    ldr x9,[x20,#80]
    ldr w10,[x9]
    ldr x9,[x20,#72]
    ldr w11,[x9]
    cmp w10,w11
    b.ne .Lrp_units
    mov x26,x24
    fmov d0,#1.0
.Lrp_initial:
    cmp x26,x25
    b.ge .Lrp_units
    ldr x9,[x20,#384]
    str d0,[x9,x26,lsl #3]
    ldr x9,[x20,#392]
    str d0,[x9,x26,lsl #3]
    ldr x9,[x20,#400]
    str xzr,[x9,x26,lsl #3]
    ldr x9,[x20,#288]
    ldr x10,[x9,x26,lsl #3]
    ldr x9,[x20,#536]
    str x10,[x9,x26,lsl #3]
    add x26,x26,#1
    b .Lrp_initial
.Lrp_units:
    adrp x9,:got:__yomcst_MOD_rg
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rg]
    ldr d8,[x9]
    fmov d1,#0.5
    mov x26,x24
.Lrp_units_loop:
    cmp x26,x25
    b.ge .Lrp_tile_call
    ldr x9,[x20,#264]
    ldr d0,[x9,x26,lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,4,none,d0,d1,real,early,comparison // fcmp d0,d1
    b.le .Lrp_no_terrain
    ldr x9,[x20,#368]
    ldr d0,[x9,x26,lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,3,d0,d0,d8,real,early // fdiv d0,d0,d8
    b .Lrp_terrain_store
.Lrp_no_terrain:
    fmov d0,xzr
.Lrp_terrain_store:
    ldr x9,[x29,#1104]
    str d0,[x9,x26,lsl #3]

    ldr x9,[x20,#536]
    ldr d0,[x9,x26,lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,3,d0,d0,d8,real,early // fdiv d0,d0,d8
    ldr x9,[x29,#1208]
    str d0,[x9,x26,lsl #3]
    ldr x9,[x20,#184]
    ldr x10,[x9,x26,lsl #3]
    ldr x9,[x29,#1112]
    str x10,[x9,x26,lsl #3]
    add x26,x26,#1
    b .Lrp_units_loop
.Lrp_tile_call:
    ldr x9,[x20,#8]
    mov x0,x9
    ldr x9,[x20,#16]
    mov x1,x9
    ldr x9,[x20,#24]
    mov x2,x9
    movz x9,#4532
    movk x9,#24,lsl #16
    add x9,x19,x9
    mov x3,x9
    movz x9,#4528
    movk x9,#24,lsl #16
    add x9,x19,x9
    mov x4,x9
    add x9,x29,#2048
    mov x5,x9
    add x9,x29,#2136
    mov x6,x9
    add x9,x29,#2224
    mov x7,x9
    add x9,x29,#2312
    str x9,[sp,#0]
    mov x17,#4248
    add x9,x29,x17
    str x9,[sp,#8]
    add x9,x29,#2488
    str x9,[sp,#16]
    add x9,x29,#2576
    str x9,[sp,#24]
    add x9,x29,#2664
    str x9,[sp,#32]
    add x9,x29,#2752
    str x9,[sp,#40]
    add x9,x29,#2840
    str x9,[sp,#48]
    mov x17,#4424
    add x9,x29,x17
    str x9,[sp,#56]
    mov x17,#4512
    add x9,x29,x17
    str x9,[sp,#64]
    add x9,x29,#2928
    str x9,[sp,#72]
    add x9,x29,#3016
    str x9,[sp,#80]
    add x9,x29,#3104
    str x9,[sp,#88]
    add x9,x29,#3192
    str x9,[sp,#96]
    add x9,x29,#3280
    str x9,[sp,#104]
    mov x17,#6536
    add x9,x29,x17
    str x9,[sp,#112]
    mov x17,#4336
    add x9,x29,x17
    str x9,[sp,#120]
    mov x17,#6624
    add x9,x29,x17
    str x9,[sp,#128]
    add x9,x29,#3456
    str x9,[sp,#136]
    mov x17,#6008
    add x9,x29,x17
    str x9,[sp,#144]
    mov x17,#6096
    add x9,x29,x17
    str x9,[sp,#152]
    mov x17,#6184
    add x9,x29,x17
    str x9,[sp,#160]
    mov x17,#6272
    add x9,x29,x17
    str x9,[sp,#168]
    mov x17,#5480
    add x9,x29,x17
    str x9,[sp,#176]
    mov x17,#5568
    add x9,x29,x17
    str x9,[sp,#184]
    mov x17,#5656
    add x9,x29,x17
    str x9,[sp,#192]
    mov x17,#5744
    add x9,x29,x17
    str x9,[sp,#200]
    mov x17,#4600
    add x9,x29,x17
    str x9,[sp,#208]
    mov x17,#4688
    add x9,x29,x17
    str x9,[sp,#216]
    mov x17,#4776
    add x9,x29,x17
    str x9,[sp,#224]
    mov x17,#4864
    add x9,x29,x17
    str x9,[sp,#232]
    mov x17,#4952
    add x9,x29,x17
    str x9,[sp,#240]
    mov x17,#5040
    add x9,x29,x17
    str x9,[sp,#248]
    mov x17,#6360
    add x9,x29,x17
    str x9,[sp,#256]
    movz x9,#5464
    movk x9,#24,lsl #16
    add x9,x19,x9
    ldr x10,[x9]
    mov x9,#7680
    add x9,x10,x9
    str x9,[sp,#264]
    mov x9,#10336
    add x9,x10,x9
    str x9,[sp,#272]
    mov x9,#4104
    add x9,x10,x9
    str x9,[sp,#280]
    mov x9,#5640
    add x9,x10,x9
    str x9,[sp,#288]
    bl md2asm_surface_tile_boundary
    mov x26,x24
.Lrp_tile_check:
    cmp x26,x25
    b.ge .Lrp_surface_branch
    fmov d0,xzr
    mov x27,#0
    ldr x10,[x29,#1296]
    add x10,x10,x26,lsl #3
.Lrp_tile_sum:
    ldr d1,[x10]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,4,none,d1,xzr,real,early,comparison // fcmp d1,#0.0
    b.lt .Lrp_bad
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1,real,early // fadd d0,d0,d1
    add x10,x10,x21,lsl #3
    add x27,x27,#1
    cmp x27,x23
    b.lo .Lrp_tile_sum
    adrp x9,.Lrp_constants
    add x9,x9,:lo12:.Lrp_constants
    ldr d1,[x9,#0]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,4,none,d0,d1,real,early,comparison // fcmp d0,d1
    b.gt .Lrp_bad
    fmov d0,#1.0
    ldr x9,[x29,#1136]
    ldr d1,[x9,x26,lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1,real,early // fsub d0,d0,d1
    ldr x9,[x29,#1144]
    ldr d1,[x9,x26,lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1,real,early // fsub d0,d0,d1
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,4,none,d0,xzr,real,early,comparison // fcmp d0,#0.0
    b.lt .Lrp_bad
    add x26,x26,#1

    b .Lrp_tile_check
.Lrp_surface_branch:
    mov x26,x24
    adrp x9,.Lrp_constants
    add x9,x9,:lo12:.Lrp_constants
    ldr d2,[x9,#8]
.Lrp_indices:
    cmp x26,x25
    b.ge .Lrp_surface_select
    ldr x9,[x20,#384]
    ldr d0,[x9,x26,lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d2,real,early // fadd d0,d0,d2
 md2asm_gpu_upper_operation md2asm_gpu_cape_diagnostics_cell_host,17,w10,d0,zero,real,early,integer // fcvtzs w10,d0
    ldr x9,[x29,#1248]
    str w10,[x9,x26,lsl #2]
    ldr x9,[x20,#392]
    ldr d0,[x9,x26,lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d2,real,early // fadd d0,d0,d2
 md2asm_gpu_upper_operation md2asm_gpu_cape_diagnostics_cell_host,17,w10,d0,zero,real,early,integer // fcvtzs w10,d0
    ldr x9,[x29,#1256]
    str w10,[x9,x26,lsl #2]
    add x26,x26,#1
    b .Lrp_indices
.Lrp_surface_select:
    movz x9,#5068
    movk x9,#24,lsl #16
    add x9,x19,x9
    ldr w9,[x9]
    cbz w9,.Lrp_default_surface
    mov x26,x24
.Lrp_wind_loop:
    cmp x26,x25
    b.ge .Lrp_date
    sub x10,x22,#1
    madd x10,x10,x21,x26
    ldr x9,[x20,#120]
    ldr d0,[x9,x10,lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d0,real,early // fmul d0,d0,d0
    ldr x9,[x20,#128]
    ldr d1,[x9,x10,lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d1,real,early // fmul d1,d1,d1
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1,real,early // fadd d0,d0,d1
 md2asm_gpu_upper_operation md2asm_gpu_lake_energy_cell_host,17,d0,d0,zero,real,early // fsqrt d0,d0
    ldr x9,[x29,#1184]
    str d0,[x9,x26,lsl #3]
    add x26,x26,#1
    b .Lrp_wind_loop
.Lrp_date:
    adrp x9,:got:__yomrip0_MOD_nindat
    ldr x9,[x9,:got_lo12:__yomrip0_MOD_nindat]
    ldr w10,[x9]
    mov w11,#10000
    sdiv w12,w10,w11
    str w12,[x29,#1072]
    mov w11,#100
    sdiv w12,w10,w11
    msub w13,w12,w11,w10
    str w13,[x29,#1064]
    sdiv w13,w12,w11
    msub w13,w13,w11,w12
    str w13,[x29,#1068]
    movz x9,#48640
    movk x9,#20,lsl #16
    add x9,x19,x9
    ldr d0,[x9]
 md2asm_gpu_upper_operation md2asm_gpu_startup_integer_cell_host,20,w10,d0,zero,real,early,integer // fcvtas w10,d0
    adrp x9,:got:__yomrip0_MOD_nsssss
    ldr x9,[x9,:got_lo12:__yomrip0_MOD_nsssss]
    ldr w11,[x9]
    add w10,w10,w11
    adrp x9,:got:__yomcst_MOD_rday
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rday]
    ldr d0,[x9]
 md2asm_gpu_upper_operation md2asm_gpu_startup_integer_cell_host,20,w11,d0,zero,real,early,integer // fcvtas w11,d0
    sdiv w12,w10,w11
    msub w13,w12,w11,w10
    str w12,[x29,#1076]
    str w13,[x29,#1080]
    movz x9,#55648
    movk x9,#23,lsl #16
    add x9,x19,x9
    ldr w9,[x9]
    cbz w9,.Lrp_calendar

    movz x9,#48792
    movk x9,#23,lsl #16
    add x0,x19,x9
    ldr x1,[x20,#48]
    ldr x2,[x20,#8]
    ldr x3,[x20,#16]
    mov x4,xzr
    mov x5,xzr
    ldr x6,[x29,#1200]
    add x6,x6,x24,lsl #3
    mov x7,xzr
    str xzr,[sp]
    bl md2asm_icestatenemo
.Lrp_calendar:
    add x9,x29,#1064
    mov x0,x9
    add x9,x29,#1068
    mov x1,x9
    add x9,x29,#1072
    mov x2,x9
    add x9,x29,#1076
    mov x3,x9
    add x9,x29,#1084
    mov x4,x9
    add x9,x29,#1088
    mov x5,x9
    add x9,x29,#1092
    mov x6,x9
    add x9,x29,#1320
    mov x7,x9
    add x9,x29,#1372
    str x9,[sp,#0]
    bl md2asm_updcal
    mov x17,#6712
    add x9,x29,x17
    mov w10,#1
    strb w10,[x9,#28]
    mov x17,#6800
    add x9,x29,x17
    mov w10,#1
    strb w10,[x9,#28]
    mov x17,#6888
    add x9,x29,x17
    mov x11,x9
    movz x9,#35924
    movk x9,#24,lsl #16
    add x10,x19,x9
    ldr w10,[x10]
    str x10,[x11,#80]
    mov x17,#6976
    add x9,x29,x17
    mov x11,x9
    movz x9,#35924
    movk x9,#24,lsl #16
    add x10,x19,x9
    ldr w10,[x10]
    str x10,[x11,#80]
    movz x9,#5464
    movk x9,#24,lsl #16
    add x9,x19,x9
    mov x0,x9
    add x9,x29,#1084
    mov x1,x9
    add x9,x29,#1088
    mov x2,x9
    mov x17,#7152
    add x9,x29,x17
    mov x3,x9
    add x9,x29,#1080
    mov x4,x9
    ldr x9,[x20,#8]
    mov x5,x9
    ldr x9,[x20,#16]
    mov x6,x9
    ldr x9,[x20,#24]
    mov x7,x9
    movz x9,#4532
    movk x9,#24,lsl #16
    add x9,x19,x9
    str x9,[sp,#0]
    movz x9,#35924
    movk x9,#24,lsl #16
    add x9,x19,x9
    str x9,[sp,#8]
    movz x9,#35936
    movk x9,#24,lsl #16
    add x9,x19,x9
    str x9,[sp,#16]
    mov x17,#6184
    add x9,x29,x17
    str x9,[sp,#24]
    add x9,x29,#3544
    str x9,[sp,#32]
    mov x17,#5304
    add x9,x29,x17
    str x9,[sp,#40]
    add x9,x29,#2224
    str x9,[sp,#48]
    ldr x9,[x20,#240]
    str x9,[sp,#56]
    add x9,x29,#2664
    str x9,[sp,#64]
    add x9,x29,#2576
    str x9,[sp,#72]
    mov x17,#6712
    add x9,x29,x17
    str x9,[sp,#80]
    add x9,x29,#3632
    str x9,[sp,#88]
    add x9,x29,#3720
    str x9,[sp,#96]
    mov x17,#5128
    add x9,x29,x17
    str x9,[sp,#104]
    mov x17,#6800
    add x9,x29,x17
    str x9,[sp,#112]
    mov x17,#5744
    add x9,x29,x17
    str x9,[sp,#120]
    mov x17,#6360
    add x9,x29,x17
    str x9,[sp,#128]
    add x9,x29,#3192
    str x9,[sp,#136]
    add x9,x29,#3808
    str x9,[sp,#144]
    mov x17,#6888
    add x9,x29,x17
    str x9,[sp,#152]
    mov x17,#6976
    add x9,x29,x17
    str x9,[sp,#160]
    mov x17,#5216
    add x9,x29,x17
    str x9,[sp,#168]
    mov x17,#7064
    add x9,x29,x17
    str x9,[sp,#176]
    add x9,x29,#4072
    str x9,[sp,#184]
    mov x17,#6448
    add x9,x29,x17
    str x9,[sp,#192]
    add x9,x29,#3896
    str x9,[sp,#200]
    add x9,x29,#3984
    str x9,[sp,#208]
    movz x9,#55648
    movk x9,#23,lsl #16
    add x9,x19,x9
    str x9,[sp,#216]
    bl md2asm_surfrad
    movz x9,#35924
    movk x9,#24,lsl #16
    add x9,x19,x9
    ldr w27,[x9]
    movz x9,#35944
    movk x9,#24,lsl #16
    add x9,x19,x9
    ldr w23,[x9]
    b .Lrp_background_bands
.Lrp_default_surface:
    mov x27,#0
    movz x9,#35944
    movk x9,#24,lsl #16
    add x9,x19,x9
    ldr w23,[x9]
.Lrp_background_bands:
    cmp x27,x23
    b.ge .Lrp_default_emiss_check
    mov x26,x24
.Lrp_background_rows:
    cmp x26,x25
    b.ge .Lrp_background_next
    madd x10,x27,x21,x26
    ldr x9,[x20,#232]
    ldr x11,[x9,x26,lsl #3]
    ldr x9,[x20,#416]
    str x11,[x9,x10,lsl #3]
    ldr x9,[x20,#424]
    str x11,[x9,x10,lsl #3]
    add x26,x26,#1
    b .Lrp_background_rows
.Lrp_background_next:
    add x27,x27,#1
    b .Lrp_background_bands
.Lrp_default_emiss_check:
    movz x9,#5068
    movk x9,#24,lsl #16
    add x9,x19,x9
    ldr w9,[x9]
    cbnz w9,.Lrp_saturation
    mov x26,x24
.Lrp_default_emiss:
    cmp x26,x25
    b.ge .Lrp_saturation
    ldr x9,[x20,#256]
    ldr x11,[x9,x26,lsl #3]
    ldr x9,[x20,#528]
    str x11,[x9,x26,lsl #3]
    movz x9,#35936
    movk x9,#24,lsl #16
    add x9,x19,x9
    ldr w23,[x9]
    mov x27,#0
    ldr x9,[x20,#520]
    add x10,x9,x26,lsl #3
.Lrp_emiss_bands:
    str x11,[x10]
    add x10,x10,x21,lsl #3
    add x27,x27,#1
    cmp x27,x23
    b.lo .Lrp_emiss_bands
    movz x9,#36416
    movk x9,#24,lsl #16
    add x9,x19,x9
    ldr x11,[x9]
    ldr x9,[x20,#432]
    str x11,[x9,x26,lsl #3]
    movz x9,#36424
    movk x9,#24,lsl #16
    add x9,x19,x9
    ldr x11,[x9]
    ldr x9,[x20,#440]
    str x11,[x9,x26,lsl #3]
    add x26,x26,#1
    b .Lrp_default_emiss
.Lrp_saturation:
    ldr x9,[x20,#8]
    mov x0,x9
    ldr x9,[x20,#16]
    mov x1,x9
    ldr x9,[x20,#24]
    mov x2,x9
    ldr x9,[x20,#56]
    mov x3,x9
    ldr x9,[x20,#64]
    mov x4,x9
    movz x9,#15436
    movk x9,#24,lsl #16
    add x9,x19,x9
    mov x5,x9
    ldr x9,[x20,#96]
    mov x6,x9
    ldr x9,[x20,#104]
    mov x7,x9
    ldr x9,[x20,#472]
    str x9,[sp,#0]
    add x9,x29,#1056
    str x9,[sp,#8]
    bl md2asm_satur_7240564
    movz x9,#5036
    movk x9,#24,lsl #16
    add x9,x19,x9
    ldr w9,[x9]
    cbz w9,.Lrp_no_cloud
    movz x9,#35880
    movk x9,#24,lsl #16
    add x9,x19,x9
    ldr w9,[x9]
    cmp w9,#0
    cset w9,ne
    str w9,[x29,#1060]
    movz x9,#36864
    movk x9,#62,lsl #16
    add x9,x19,x9
    mov x0,x9
    movz x9,#35864
    movk x9,#24,lsl #16
    add x9,x19,x9
    mov x1,x9
    movz x9,#21392
    movk x9,#28,lsl #16
    add x9,x19,x9
    mov x2,x9
    movz x9,#5472
    movk x9,#24,lsl #16
    add x9,x19,x9
    mov x3,x9
    movz x9,#48608
    movk x9,#20,lsl #16
    add x9,x19,x9
    mov x4,x9
    ldr x9,[x20,#8]
    mov x5,x9
    ldr x9,[x20,#16]
    mov x6,x9
    ldr x9,[x20,#24]
    mov x7,x9
    ldr x9,[x20,#64]
    str x9,[sp,#0]
    ldr x9,[x20,#88]
    str x9,[sp,#8]
    ldr x9,[x20,#96]
    str x9,[sp,#16]
    ldr x9,[x20,#152]
    str x9,[sp,#24]
    ldr x9,[x20,#136]
    str x9,[sp,#32]
    ldr x9,[x20,#144]
    str x9,[sp,#40]
    ldr x9,[x20,#104]
    str x9,[sp,#48]
    ldr x9,[x20,#280]
    str x9,[sp,#56]
    ldr x9,[x20,#280]
    str x9,[sp,#64]
    add x9,x29,#1060
    str x9,[sp,#72]
    ldr x9,[x20,#480]
    str x9,[sp,#80]
    ldr x9,[x20,#488]
    str x9,[sp,#88]
    ldr x9,[x20,#496]
    str x9,[sp,#96]
    ldr x9,[x20,#504]
    str x9,[sp,#104]
    ldr x9,[x20,#512]
    str x9,[sp,#112]
    ldr x9,[x20,#448]
    str x9,[sp,#120]
    ldr x9,[x20,#456]
    str x9,[sp,#128]
    ldr x9,[x20,#464]
    str x9,[sp,#136]
    bl md2asm_cldpp
    b .Lrp_finish
.Lrp_no_cloud:
    mov x27,#0
.Lrp_no_cloud_levels:
    cmp x27,x22
    b.ge .Lrp_no_cloud_cover
    mov x26,x24
.Lrp_no_cloud_rows:
    cmp x26,x25
    b.ge .Lrp_no_cloud_next
    madd x10,x27,x21,x26
    ldr x9,[x20,#448]
    str xzr,[x9,x10,lsl #3]
    ldr x9,[x20,#464]
    str xzr,[x9,x10,lsl #3]
    ldr x9,[x20,#456]
    str xzr,[x9,x10,lsl #3]
    add x26,x26,#1
    b .Lrp_no_cloud_rows
.Lrp_no_cloud_next:
    add x27,x27,#1
    b .Lrp_no_cloud_levels
.Lrp_no_cloud_cover:
    mov x26,x24
.Lrp_no_cloud_cover_rows:
    cmp x26,x25
    b.ge .Lrp_finish
    ldr x9,[x20,#480]
    str xzr,[x9,x26,lsl #3]
    ldr x9,[x20,#488]
    str xzr,[x9,x26,lsl #3]
    ldr x9,[x20,#496]
    str xzr,[x9,x26,lsl #3]
    ldr x9,[x20,#504]
    str xzr,[x9,x26,lsl #3]
    ldr x9,[x20,#512]
    str xzr,[x9,x26,lsl #3]
    add x26,x26,#1
    b .Lrp_no_cloud_cover_rows
.Lrp_finish:
    mov x0,x28
    bl free
    ldr x18,[sp,#304]
    ldp x19,x20,[sp,#320]
    ldp x21,x22,[sp,#336]
    ldp x23,x24,[sp,#352]
    ldp x25,x26,[sp,#368]
    ldp x27,x28,[sp,#384]
    ldp x29,x30,[sp,#400]
    ldp d8,d9,[sp,#416]
    ldp d10,d11,[sp,#432]
    ldp d12,d13,[sp,#448]
    ldp d14,d15,[sp,#464]
    add sp,sp,#2,lsl #12
    ret
.Lrp_bad:
    bl abort
    brk #0
.size RADPAR_SYMBOL,.-RADPAR_SYMBOL
/* x0 descriptor, x1 base, x2 rows, x3 second extent or zero,
 * x4 element width, x5 GNU type code. No numerical stage lives here. */
.Lrp_desc:
    str x1,[x0]
    mov x9,#-1
    cbz x3,.Lrp_desc_offset
    sub x9,x9,x2
.Lrp_desc_offset:
    str x9,[x0,#8]
    str x4,[x0,#16]
    str wzr,[x0,#24]
    mov w9,#1
    cmp x3,#0
    cinc w9,w9,ne
    strb w9,[x0,#28]
    strb w5,[x0,#29]
    strh wzr,[x0,#30]
    str x4,[x0,#32]
    mov x9,#1
    stp x9,x9,[x0,#40]
    str x2,[x0,#56]
    str x2,[x0,#64]
    str x9,[x0,#72]
    str x3,[x0,#80]
    ret
.section .rodata
.p2align 3
.Lrp_constants:
    .double 1.01
    .double 0.01
.section .note.GNU-stack,"",%progbits
