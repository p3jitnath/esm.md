/* LASCAW follows formulations/openifs/dynamics/departure_point_weights.md.
 * The md2asm contract fixes the one-process domain and separate FP64 rounding.
 * Private accepted children complete latitude, longitude and vertical weights. */
#ifndef MD2ASM_LASCAW_SYMBOL
#define MD2ASM_LASCAW_SYMBOL lascaw_
#endif
#ifndef LASCAW_CLA_CHILD
#define LASCAW_CLA_CHILD lascaw_cla_assembly_
#endif
#ifndef LASCAW_CLO_CHILD
#define LASCAW_CLO_CHILD lascaw_clo_assembly_
#endif
#ifndef LASCAW_VINTW_CHILD
#define LASCAW_VINTW_CHILD lascaw_vintw_assembly_
#endif
.text
.p2align 4
.global MD2ASM_LASCAW_SYMBOL
.type MD2ASM_LASCAW_SYMBOL,%function
.macro PTR reg,arg
 ldr \reg,[sp,#(192+8*\arg)]
.endm
.macro INT reg,arg
 PTR x9,\arg
 ldr \reg,[x9]
.endm
.macro READ reg,arg,offset=x27
 PTR x9,\arg
 ldr \reg,[x9,\offset]
.endm
.macro WRITE reg,arg,offset=x27
 PTR x9,\arg
 str \reg,[x9,\offset]
.endm
.macro REAL reg,arg
 PTR x9,\arg
 ldr \reg,[x9]
.endm
MD2ASM_LASCAW_SYMBOL:
 mov x16,sp
 sub sp,sp,#1600
 add x17,sp,#1440
 stp x19,x20,[x17,#0]
 stp x21,x22,[x17,#16]
 stp x23,x24,[x17,#32]
 stp x25,x26,[x17,#48]
 stp x27,x28,[x17,#64]
 stp x29,x30,[x17,#80]
 stp d8,d9,[x17,#96]
 stp d10,d11,[x17,#112]
 stp d12,d13,[x17,#128]
 stp d14,d15,[x17,#144]
 stp x0,x1,[sp,#192]
 stp x2,x3,[sp,#208]
 stp x4,x5,[sp,#224]
 stp x6,x7,[sp,#240]
 add x10,sp,#256
 mov x11,#70
.Llc_args:
 ldr x12,[x16],#8
 str x12,[x10],#8
 subs x11,x11,#1
 b.ne .Llc_args
 adrp x9,:got:__yommp0_MOD_nproc
 ldr x9,[x9,:got_lo12:__yommp0_MOD_nproc]
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Llc_reject
 mrs x9,fpcr
 cbnz x9,.Llc_reject
 INT w19,4
 INT w20,8
 cmp w19,#1024
 b.hi .Llc_reject
 cmp w20,#2
 b.lt .Llc_reject
 cmp w20,#256
 b.gt .Llc_reject
 INT w22,6
 sub w22,w22,#1
 cmp w22,w19
 b.hi .Llc_reject
 INT w23,7
 cmp w23,w19
 b.hi .Llc_reject
 INT w10,5
 sub w11,w10,#1
 cmp w11,#2
 b.hi .Llc_reject
 str w10,[sp,#948]
 INT w10,11
 str w10,[sp,#944]
 cmp w10,#101
 b.lt .Llc_reject
 cmp w10,#106
 b.le .Llc_kind_ok
 cmp w10,#201
 b.lt .Llc_reject
 cmp w10,#203
 b.gt .Llc_reject
.Llc_kind_ok:
 INT w11,12
 cmp w11,#1
 b.hi .Llc_reject
 INT w11,13
 cmp w11,#1
 b.eq .Llc_weno_extent
 cmp w11,#3
 b.ne .Llc_reject
.Llc_weno_extent:
 str w11,[sp,#952]
 INT w12,14
 cmp w12,#1
 b.hi .Llc_reject
 str w12,[sp,#956]
 cmp w10,#104
 b.ne .Llc_hermite_extent
 cmp w12,#1
 b.ne .Llc_reject
.Llc_hermite_extent:
 mov x10,#15
.Llc_logicals:
 add x9,sp,#192
 ldr x9,[x9,x10,lsl #3]
 ldr w11,[x9]
 cmp w11,#1
 b.hi .Llc_reject
 add x10,x10,#1
 cmp x10,#23
 b.lo .Llc_logicals
 INT w10,2
 cmp w10,#1
 b.hi .Llc_reject
 str w10,[sp,#980]
 INT w10,23
 cmp w10,#1
 b.hi .Llc_reject
 PTR x14,3
 ldr w10,[x14,#76]
 cmp w10,#1
 b.hi .Llc_reject
 str w10,[sp,#896]
 ldr w10,[x14,#108]
 cmp w10,#1
 b.hi .Llc_reject
 str w10,[sp,#900]
 INT w10,17
 str w10,[sp,#904]
 str wzr,[sp,#908]
 ldr w10,[sp,#944]
 cmp w10,#103
 cset w13,ge
 cmp w10,#106
 cset w12,le
 and w13,w13,w12
 cmp w10,#203
 cset w12,eq
 orr w13,w13,w12
 INT w11,15
 and w11,w11,w13
 str w11,[sp,#880]
 INT w12,17
 and w12,w12,w11
 str w12,[sp,#888]
 str wzr,[sp,#892]
 INT w11,16
 and w11,w11,w13
 cmp w10,#102
 b.eq .Llc_hoi_h
 cmp w10,#202
 b.ne .Llc_quad_h_ready
.Llc_hoi_h:
 ldr d0,[x14,#320]
 fcmp d0,#0.0
 cset w11,ne
.Llc_quad_h_ready:
 str w11,[sp,#884]
 INT w11,19
 cmp w10,#103
 cset w12,ge
 cmp w10,#106
 cset w15,le
 and w12,w12,w15
 and w11,w11,w12
 str w11,[sp,#940]
 cbz w11,.Llc_turb_extent
 ldr w12,[sp,#948]
 cmp w12,#3
 b.ne .Llc_reject
.Llc_turb_extent:
 INT w11,20
 and w11,w11,w13
 INT w12,21
 and w12,w12,w11
 str w12,[sp,#932]
 INT w12,22
 and w12,w12,w11
 str w12,[sp,#936]
 ldr w11,[x14,#152]
 cmp w11,#1
 b.hi .Llc_reject
 cmp w10,#202
 csel w11,wzr,w11,eq
 str w11,[sp,#928]
 ldr d0,[x14,#112]
 str d0,[sp,#912]
 str d0,[sp,#920]
 cmp w10,#102
 b.eq .Llc_hoi_min
 cmp w10,#202
 b.ne .Llc_min_ready
.Llc_hoi_min:
 ldr d0,[x14,#320]
 str d0,[sp,#912]
 ldr d0,[x14,#312]
 str d0,[sp,#920]
.Llc_min_ready:
 cmp w10,#106
 b.ne .Llc_physics_flags
 str wzr,[sp,#900]
.Llc_physics_flags:
 ldr w11,[sp,#880]
 cbz w11,.Llc_slhd_defined
 ldr w11,[sp,#884]
 ldr w12,[sp,#888]
 orr w11,w11,w12
 cbz w11,.Llc_reject
.Llc_slhd_defined:
 INT w11,23
 cbz w11,.Llc_phys_defined
 cmp w10,#200
 b.ge .Llc_phys_defined
 cmp w10,#101
 b.eq .Llc_phys_defined
 ldr w11,[sp,#896]
 cbz w11,.Llc_phys_defined
 ldr w11,[sp,#900]
 ldr w12,[sp,#904]
 orr w11,w11,w12
 cbz w11,.Llc_reject
.Llc_phys_defined:
 mov w11,#0
 cmp w10,#106
 b.eq .Llc_weno_yes
 cmp w10,#102
 b.ne .Llc_weno_flag
 ldr w11,[x14,#328]
 cmp w11,#1
 b.hi .Llc_reject
 cbz w11,.Llc_weno_flag
.Llc_weno_yes:
 mov w11,#1
 ldr w12,[sp,#952]
 cmp w12,#3
 b.ne .Llc_reject
 cmp w20,#4
 b.lt .Llc_reject
.Llc_weno_flag:
 str w11,[sp,#984]
 PTR x14,1
 ldr w10,[x14,#1672]
 ldr w11,[x14,#1676]
 sub w12,w11,w10
 add w12,w12,#1
 cmp w12,#1
 b.lt .Llc_reject
 cmp w12,#4096
 b.gt .Llc_reject
 str w10,[sp,#960]
 str w11,[sp,#964]
 str x12,[sp,#968]
 ldr w10,[x14,#1016]
 str w10,[sp,#976]
 mul x21,x19,x20
 // Allocate all complete local families once, outside any timing claim.
 ldr w10,[sp,#948]
 lsl x10,x10,#3
 add x10,x10,#128
 mul x0,x10,x21
 add x0,x0,#32
 bl malloc
 cbz x0,.Llc_reject
 mov x29,x0
 str x0,[sp,#816]
 add x0,x0,x21,lsl #2
 add x0,x0,#7
 and x0,x0,#-8
 str x0,[sp,#824]
 mov x10,#24
 madd x0,x21,x10,x0
 str x0,[sp,#832]
 madd x0,x21,x10,x0
 str x0,[sp,#840]
 ldr w11,[sp,#948]
 lsl x11,x11,#3
 madd x0,x21,x11,x0
 str x0,[sp,#848]
 madd x0,x21,x10,x0
 str x0,[sp,#856]
 mov x10,#48
 madd x0,x21,x10,x0
 str x0,[sp,#864]
 fmov d8,xzr
 fmov d9,#1.0
 fmov d10,#0.5
 fmov d11,#0.75
 adrp x9,.Llc_epsilon
 ldr d12,[x9,:lo12:.Llc_epsilon]
 ldr w10,[sp,#944]
 cmp w10,#200
 b.ge .Llc_factor_ready
 REAL d0,43
 PTR x9,35
 add x10,x20,#1
 ldr d1,[x9,x10,lsl #3]
 ldr d2,[x9]
 fsub d1,d1,d2
 fdiv d13,d0,d1
.Llc_factor_ready:
 // The first turbulence plane is unused unless the split-physics pass sets it.
 mov x25,#0
.Llc_initial_level:
 cmp x25,x20
 b.hs .Llc_points
 mov x24,x22
.Llc_initial_row:
 cmp x24,x23
 b.hs .Llc_initial_next
 madd x26,x25,x19,x24
 lsl x27,x26,#3
 ldr w10,[sp,#940]
 cbz w10,.Llc_initial_static
 READ d0,46
 ldr x9,[sp,#840]
 add x9,x9,x21,lsl #3
 str d0,[x9,x27]
 READ d0,47
 ldr x9,[sp,#840]
 add x9,x9,x21,lsl #4
 str d0,[x9,x27]
.Llc_initial_static:
 INT w10,23
 cbz w10,.Llc_initial_done
 ldr w10,[sp,#948]
 sub x10,x10,#1
 mul x10,x10,x21
 ldr x9,[sp,#840]
 add x9,x9,x10,lsl #3
 str d9,[x9,x27]
.Llc_initial_done:
 add x24,x24,#1
 b .Llc_initial_row
.Llc_initial_next:
 add x25,x25,#1
 b .Llc_initial_level
.Llc_points:
 mov x25,#0
.Llc_point_level:
 cmp x25,x20
 b.hs .Llc_horizontal
 mov x24,x22
.Llc_point_row:
 cmp x24,x23
 b.hs .Llc_point_next
 madd x26,x25,x19,x24
 lsl x27,x26,#3
 READ d14,33
 REAL d0,25
 fsub d0,d0,d14
 REAL d1,24
 fmul d0,d1,d0
 fadd d0,d0,d11
 fadd d0,d0,d12
 fcvtzs w10,d0
 PTR x9,1
 ldr w11,[x9,#1720]
 sub w10,w10,w11
 ldr w11,[sp,#960]
 sub w12,w10,w11
 PTR x9,27
 sxtw x12,w12
 ldr d0,[x9,x12,lsl #3]
 fsub d0,d0,d14
 fadd d0,d0,d12
 fmov x11,d0
 tbnz x11,#63,.Llc_lat_minus_two
 sub w28,w10,#1
 b .Llc_lat_selected
.Llc_lat_minus_two:
 sub w28,w10,#2
.Llc_lat_selected:
 sxtw x28,w28
 ldr x9,[sp,#816]
 str w28,[x9,x26,lsl #2]
 ldrsw x11,[sp,#960]
 sub x10,x28,x11
 PTR x9,27
 add x9,x9,x10,lsl #3
 ldp d16,d17,[x9]
 ldp d18,d19,[x9,#16]
 fsub d0,d14,d17
 fsub d1,d18,d17
 fadd d1,d1,d12
 fdiv d0,d0,d1
 WRITE d0,51
 ldr w11,[sp,#944]
 cmp w11,#202
 b.eq .Llc_two_cubic_distance
 cmp w11,#203
 b.ne .Llc_distance_ready
.Llc_two_cubic_distance:
 fsub d0,d14,d17
 fsub d1,d18,d17
 fdiv d0,d0,d1
 WRITE d0,51
.Llc_distance_ready:
 cmp w11,#101
 b.eq .Llc_vertical
 cmp w11,#201
 b.eq .Llc_vertical
 fsub d16,d14,d16
 fsub d17,d14,d17
 fsub d18,d14,d18
 fsub d19,d14,d19
 // The local cubic table has row, coefficient, then level order.
 mul x10,x25,x19
 add x10,x26,x10,lsl #1
 lsl x10,x10,#3
 str x10,[sp,#1008]
 ldr w12,[sp,#960]
 add x12,x28,#1
 ldrsw x11,[sp,#960]
 sub x12,x12,x11
 PTR x9,28
 add x9,x9,x12,lsl #3
 ldr d20,[x9]
 ldr x11,[sp,#968]
 add x9,x9,x11,lsl #3
 ldr d21,[x9]
 add x9,x9,x11,lsl #3
 ldr d22,[x9]
 fmul d0,d16,d18
 fmul d0,d0,d19
 fmul d0,d0,d20
 fmul d1,d16,d17
 fmul d1,d1,d19
 fmul d1,d1,d21
 fmul d2,d16,d17
 fmul d2,d2,d18
 fmul d2,d2,d22
 ldr x9,[sp,#824]
 add x9,x9,x10
 str d0,[x9]
 add x9,x9,x19,lsl #3
 str d1,[x9]
 add x9,x9,x19,lsl #3
 str d2,[x9]
 ldr w11,[sp,#932]
 cbnz w11,.Llc_lat_correction
 READ d3,51
 WRITE d3,52
 b .Llc_lat_correction_store
.Llc_lat_correction:
 READ d4,49
 fsub d5,d9,d4
 READ d3,51
 fmul d3,d3,d4
 fmul d6,d10,d5
 fadd d3,d3,d6
 WRITE d3,52
 fsub d6,d16,d17
 fsub d7,d19,d18
 // n2-n1 is z1-z2, with exactly the source node subtraction.
 ldrsw x11,[sp,#960]
 add x12,x28,#1
 sub x12,x12,x11
 PTR x9,27
 add x9,x9,x12,lsl #3
 ldp d0,d1,[x9]
 fsub d0,d1,d0
 fmul d0,d10,d0
 fmul d0,d0,d5
 fmul d1,d17,d4
 fadd d17,d1,d0
 fmul d1,d18,d4
 fsub d18,d1,d0
 fadd d16,d6,d17
 fadd d19,d7,d18
 fmul d0,d16,d18
 fmul d0,d0,d19
 fmul d0,d0,d20
 fmul d1,d16,d17
 fmul d1,d1,d19
 fmul d1,d1,d21
 fmul d2,d16,d17
 fmul d2,d2,d18
 fmul d2,d2,d22
.Llc_lat_correction_store:
 ldr x10,[sp,#1008]
 ldr x9,[sp,#832]
 add x9,x9,x10
 str d0,[x9]
 add x9,x9,x19,lsl #3
 str d1,[x9]
 add x9,x9,x19,lsl #3
 str d2,[x9]
.Llc_vertical:
 ldr w10,[sp,#944]
 cmp w10,#200
 b.ge .Llc_surface_level
 READ d15,34
 fmul d0,d15,d13
 fcvtzs w11,d0
 sxtw x11,w11
 PTR x9,36
 ldr w12,[x9,x11,lsl #2]
 sub w12,w12,#1
 sub w11,w20,#2
 cmp w12,w11
 b.ge .Llc_level_selected
 add w11,w12,#2
 sxtw x11,w11
 PTR x9,35
 ldr d0,[x9,x11,lsl #3]
 fsub d0,d15,d0
 fcmp d0,d8
 b.le .Llc_level_selected
 add w12,w12,#1
.Llc_level_selected:
 str w12,[sp,#1000]
 PTR x9,65
 str w12,[x9,x26,lsl #2]
 add w11,w12,#1
 sxtw x11,w11
 PTR x9,35
 add x9,x9,x11,lsl #3
 ldp d0,d1,[x9]
 fsub d2,d15,d0
 fsub d1,d1,d0
 fdiv d2,d2,d1
 WRITE d2,68
 cmp w10,#101
 b.eq .Llc_surface_level
 ldr w11,[sp,#936]
 cbz w11,.Llc_vertical_correction_store
 READ d4,50
 fmul d2,d2,d4
 fsub d4,d9,d4
 fmul d4,d10,d4
 fadd d2,d2,d4
.Llc_vertical_correction_store:
 WRITE d2,69
.Llc_surface_level:
 add w11,w25,#1
 INT w12,12
 cbz w12,.Llc_surface_selected
 INT w11,9
.Llc_surface_selected:
 str w11,[sp,#988]
 mov x16,#0
 ldr w10,[sp,#944]
 cmp w10,#201
 b.ne .Llc_longitude
 mov x16,#1
.Llc_longitude:
 add x12,x28,x16
 ldrsw x11,[sp,#960]
 sub x13,x12,x11
 PTR x9,26
 ldr d0,[x9,x13,lsl #3]
 READ d1,32
 fmul d0,d1,d0
 fcvtzs w14,d0
 scvtf d1,w14
 fsub d0,d0,d1
 madd x17,x16,x21,x26
 lsl x17,x17,#3
 WRITE d0,57,x17
 ldr w10,[sp,#944]
 cmp w10,#101
 b.eq .Llc_longitude_address
 cmp w10,#201
 b.eq .Llc_longitude_address
 ldr w11,[sp,#932]
 cbz w11,.Llc_longitude_correction_store
 READ d1,48
 fmul d0,d0,d1
 fsub d1,d9,d1
 fmul d1,d10,d1
 fadd d0,d0,d1
.Llc_longitude_correction_store:
 WRITE d0,58,x17
.Llc_longitude_address:
 PTR x9,10
 ldr w11,[x9,x13,lsl #2]
 INT w15,9
 ldr w13,[sp,#976]
 msub w11,w13,w15,w11
 PTR x9,1
 // Preserve the provider's full integer array descriptor strides.
 ldr x15,[x9,#336]
 ldr x0,[x9,#368]
 sxtw x14,w14
 madd x15,x14,x0,x15
 ldr x0,[x9,#392]
 madd x15,x12,x0,x15
 ldr x9,[x9,#328]
 ldr w15,[x9,x15,lsl #2]
 add w11,w11,w15
 ldr w10,[sp,#944]
 cmp w10,#200
 b.ge .Llc_longitude_surface
 ldr w15,[sp,#1000]
 b .Llc_longitude_kl0
.Llc_longitude_surface:
 ldr w15,[sp,#988]
.Llc_longitude_kl0:
 madd w15,w13,w15,w11
 madd x17,x16,x21,x26
 lsl x17,x17,#2
 WRITE w15,63,x17
 cmp w10,#101
 b.eq .Llc_longitude_next
 cmp w10,#200
 b.ge .Llc_longitude_next
 ldr w15,[sp,#988]
 madd w15,w13,w15,w11
 WRITE w15,64,x17
.Llc_longitude_next:
 add x16,x16,#1
 cmp w10,#201
 b.eq .Llc_longitude_two
 cmp x16,#4
 b.lo .Llc_longitude
 b .Llc_point_done
.Llc_longitude_two:
 cmp x16,#3
 b.lo .Llc_longitude
.Llc_point_done:
 add x24,x24,#1
 b .Llc_point_row
.Llc_point_next:
 add x25,x25,#1
 b .Llc_point_level
.Llc_horizontal:
 ldr w10,[sp,#944]
 cmp w10,#101
 b.eq .Llc_finish
 cmp w10,#201
 b.eq .Llc_finish
 cmp w10,#200
 b.ge .Llc_horizontal_normal
 ldr w10,[sp,#880]
 INT w11,18
 and w10,w10,w11
 cbz w10,.Llc_horizontal_normal
 // First generate the separate heat weights, then the ordinary families.
 add x9,sp,#880
 str x9,[sp,#1024]
 add x9,sp,#912
 str x9,[sp,#1032]
 PTR x9,45
 str x9,[sp,#1040]
 ldr x9,[sp,#840]
 str x9,[sp,#1048]
 PTR x9,53
 str x9,[sp,#1056]
 PTR x9,56
 str x9,[sp,#1064]
 PTR x9,55
 str x9,[sp,#1072]
 PTR x9,59
 str x9,[sp,#1080]
 PTR x9,62
 str x9,[sp,#1088]
 PTR x9,61
 str x9,[sp,#1096]
 bl .Llc_latlon
.Llc_horizontal_normal:
 mov x24,#0
.Llc_horizontal_slot:
 add x9,sp,#880
 str x9,[sp,#1024]
 add x9,sp,#912
 str x9,[sp,#1032]
 PTR x9,44
 str x9,[sp,#1040]
 mul x10,x24,x21
 ldr x9,[sp,#840]
 add x9,x9,x10,lsl #3
 str x9,[sp,#1048]
 mov x11,#3
 mul x12,x10,x11
 lsl x12,x12,#3
 PTR x9,53
 add x9,x9,x12
 str x9,[sp,#1056]
 PTR x9,56
 add x9,x9,x12
 str x9,[sp,#1064]
 PTR x9,54
 add x9,x9,x12
 str x9,[sp,#1072]
 lsl x12,x12,#1
 PTR x9,59
 add x9,x9,x12
 str x9,[sp,#1080]
 PTR x9,62
 add x9,x9,x12
 str x9,[sp,#1088]
 PTR x9,60
 add x9,x9,x12
 str x9,[sp,#1096]
 ldr w10,[sp,#944]
 cmp w10,#200
 b.ge .Llc_horizontal_call
 INT w10,23
 cbz w10,.Llc_horizontal_turbulence
 ldr w11,[sp,#948]
 add w10,w24,#1
 cmp w10,w11
 b.ne .Llc_horizontal_turbulence
 add x9,sp,#896
 str x9,[sp,#1024]
 ldr x9,[sp,#1048]
 str x9,[sp,#1040]
 ldr x9,[sp,#1056]
 str x9,[sp,#1072]
 ldr x9,[sp,#848]
 str x9,[sp,#1056]
 ldr x9,[sp,#1080]
 str x9,[sp,#1096]
 ldr x9,[sp,#856]
 str x9,[sp,#1080]
 b .Llc_horizontal_call
.Llc_horizontal_turbulence:
 ldr w10,[sp,#940]
 cmp x24,#0
 csel w10,wzr,w10,eq
 str w10,[sp,#892]
.Llc_horizontal_call:
 bl .Llc_latlon
 ldr w10,[sp,#944]
 cmp w10,#200
 b.ge .Llc_finish
 add x24,x24,#1
 ldr w10,[sp,#948]
 cmp x24,x10
 b.lo .Llc_horizontal_slot
 // Only the vertical quadratic selector changes for the midpoint option.
 ldr w10,[sp,#944]
 cmp w10,#102
 b.ne .Llc_vertical_weights
 PTR x9,3
 ldr d0,[x9,#312]
 fcmp d0,d8
 cset w10,ne
 str w10,[sp,#884]
.Llc_vertical_weights:
 ldr w10,[sp,#984]
 cbnz w10,.Llc_weno_weights
 PTR x9,65
 str x9,[sp,#1016]
 add x9,sp,#920
 str x9,[sp,#1032]
 str xzr,[sp,#1112]
 bl .Llc_vintw
 b .Llc_extra_vertical
.Llc_weno_weights:
 mov x24,#2
.Llc_weno_slot:
 mov x25,#0
.Llc_weno_level:
 cmp x25,x20
 b.hs .Llc_weno_call
 mov x28,x22
.Llc_weno_row:
 cmp x28,x23
 b.hs .Llc_weno_next
 madd x26,x25,x19,x28
 PTR x9,65
 ldr w10,[x9,x26,lsl #2]
 mov w11,w10
 ldr w12,[sp,#980]
 eor w12,w12,#1
 cbz x24,.Llc_weno_store
 cmp x24,#1
 b.eq .Llc_weno_lower
 sub w11,w10,#1
 cmp w11,w12
 csel w11,w12,w11,lt
 sub w13,w11,w10
 add w13,w13,#1
 PTR x9,66
 str w13,[x9,x26,lsl #2]
 b .Llc_weno_store
.Llc_weno_lower:
 sub w12,w20,w12
 sub w12,w12,#2
 add w11,w10,#1
 cmp w11,w12
 csel w11,w12,w11,gt
 PTR x9,66
 ldr w13,[x9,x26,lsl #2]
 add w13,w13,w11
 sub w13,w13,w10
 sub w13,w13,#1
 str w13,[x9,x26,lsl #2]
.Llc_weno_store:
 ldr x9,[sp,#864]
 str w11,[x9,x26,lsl #2]
 add x28,x28,#1
 b .Llc_weno_row
.Llc_weno_next:
 add x25,x25,#1
 b .Llc_weno_level
.Llc_weno_call:
 ldr x9,[sp,#864]
 str x9,[sp,#1016]
 add x9,sp,#1136
 str d8,[sp,#1136]
 str x9,[sp,#1032]
 mov x10,#24
 mul x10,x24,x10
 mul x10,x10,x21
 str x10,[sp,#1112]
 bl .Llc_vintw
 subs x24,x24,#1
 b.ge .Llc_weno_slot
 // Parent WENO coefficients retain the source's boundary convention.
 mov x25,#0
.Llc_cw_level:
 cmp x25,x20
 b.hs .Llc_extra_vertical
 mov x24,x22
.Llc_cw_row:
 cmp x24,x23
 b.hs .Llc_cw_next
 madd x26,x25,x19,x24
 lsl x27,x26,#3
 READ d15,68
 ldr w10,[sp,#980]
 cbz w10,.Llc_cw_general
 adrp x9,.Llc_tenth
 ldr d0,[x9,:lo12:.Llc_tenth]
 fmov d1,#2.0
 fadd d1,d1,d15
 fmul d0,d0,d1
 fmov d2,#3.0
 fsub d2,d2,d15
 fmul d0,d0,d2
 WRITE d0,67
 adrp x9,.Llc_twentieth
 ldr d0,[x9,:lo12:.Llc_twentieth]
 fmul d3,d0,d1
 fadd d1,d9,d15
 fmul d3,d3,d1
 add x17,x26,x21
 lsl x17,x17,#3
 WRITE d3,67,x17
 fmov d1,#2.0
 fsub d1,d1,d15
 fmul d0,d0,d1
 fmul d0,d0,d2
 add x17,x26,x21,lsl #1
 lsl x17,x17,#3
 WRITE d0,67,x17
 b .Llc_cw_done
.Llc_cw_general:
 PTR x9,65
 ldr w28,[x9,x26,lsl #2]
 cmp w28,#1
 b.le .Llc_cw_done
 sub w10,w20,#3
 cmp w28,w10
 b.ge .Llc_cw_done
 READ d14,34
 PTR x9,35
 sub x10,x28,#1
 ldr d0,[x9,x10,lsl #3]
 fsub d16,d14,d0
 ldr d0,[x9,x28,lsl #3]
 fsub d17,d14,d0
 add x10,x28,#3
 ldr d0,[x9,x10,lsl #3]
 fsub d18,d14,d0
 add x10,x28,#4
 ldr d0,[x9,x10,lsl #3]
 fsub d19,d14,d0
 PTR x9,41
 sub x10,x28,#1
 ldr d0,[x9,x10,lsl #3]
 fmul d0,d0,d16
 fmul d0,d0,d19
 WRITE d0,67
 add x10,x10,x20
 PTR x9,41
 ldr d0,[x9,x10,lsl #3]
 fmul d0,d0,d16
 fmul d0,d0,d17
 add x17,x26,x21
 lsl x17,x17,#3
 WRITE d0,67,x17
 add x10,x10,x20
 PTR x9,41
 ldr d0,[x9,x10,lsl #3]
 fmul d0,d0,d18
 fmul d0,d0,d19
 add x17,x26,x21,lsl #1
 lsl x17,x17,#3
 WRITE d0,67,x17
.Llc_cw_done:
 add x24,x24,#1
 b .Llc_cw_row
.Llc_cw_next:
 add x25,x25,#1
 b .Llc_cw_level
.Llc_extra_vertical:
 ldr w10,[sp,#944]
 cmp w10,#104
 b.eq .Llc_extra_start
 cmp w10,#105
 b.ne .Llc_finish
.Llc_extra_start:
 mov x25,#0
.Llc_extra_level:
 cmp x25,x20
 b.hs .Llc_finish
 mov x24,x22
.Llc_extra_row:
 cmp x24,x23
 b.hs .Llc_extra_next
 madd x26,x25,x19,x24
 lsl x27,x26,#3
 PTR x9,65
 ldr w28,[x9,x26,lsl #2]
 ldr w10,[sp,#944]
 cmp w10,#105
 b.eq .Llc_spline
 READ d15,68
 fsub d16,d9,d15
 fmul d17,d15,d15
 fmov d18,#2.0
 fmul d18,d18,d15
 fadd d0,d9,d18
 fmul d1,d16,d16
 fmul d0,d1,d0
 WRITE d0,77
 fmov d0,#3.0
 fsub d0,d0,d18
 fmul d0,d17,d0
 add x17,x26,x21
 lsl x17,x17,#3
 WRITE d0,77,x17
 fmul d0,d15,d16
 fmul d0,d0,d16
 add x17,x26,x21,lsl #1
 lsl x17,x17,#3
 WRITE d0,77,x17
 fneg d0,d15
 fmul d0,d0,d15
 fmul d0,d0,d16
 mov x10,#3
 madd x17,x21,x10,x26
 lsl x17,x17,#3
 WRITE d0,77,x17
 PTR x9,35
 ldr d0,[x9,x28,lsl #3]
 add x10,x28,#1
 ldr d1,[x9,x10,lsl #3]
 add x10,x28,#2
 ldr d2,[x9,x10,lsl #3]
 add x10,x28,#3
 ldr d3,[x9,x10,lsl #3]
 fsub d16,d2,d1
 fsub d17,d2,d0
 fmul d17,d10,d17
 fsub d18,d3,d1
 fmul d18,d10,d18
 fmul d0,d10,d16
 fdiv d1,d0,d17
 fdiv d2,d0,d18
 cmp w28,#0
 b.eq .Llc_hermite_top
 sub w10,w20,#2
 cmp w28,w10
 b.ne .Llc_hermite_store
 fdiv d2,d16,d18
 fmov d3,d8
 b .Llc_hermite_bottom_store
.Llc_hermite_top:
 fmov d1,d8
 fdiv d0,d16,d17
 WRITE d1,76
 add x17,x26,x21
 lsl x17,x17,#3
 WRITE d0,76,x17
 b .Llc_hermite_right
.Llc_hermite_store:
 WRITE d1,76
 add x17,x26,x21
 lsl x17,x17,#3
 WRITE d1,76,x17
.Llc_hermite_right:
 fmov d3,d2
 b .Llc_hermite_right_store
.Llc_hermite_bottom_store:
 WRITE d1,76
 add x17,x26,x21
 lsl x17,x17,#3
 WRITE d1,76,x17
.Llc_hermite_right_store:
 add x17,x26,x21,lsl #1
 lsl x17,x17,#3
 WRITE d2,76,x17
 mov x10,#3
 madd x17,x21,x10,x26
 lsl x17,x17,#3
 WRITE d3,76,x17
 b .Llc_extra_done
.Llc_spline:
 READ d15,34
 PTR x9,35
 add x10,x28,#1
 ldr d0,[x9,x10,lsl #3]
 fsub d15,d15,d0
 PTR x9,0
 ldp x10,x11,[x9,#152]
 ldr x12,[x9,#192]
 ldr x13,[x9,#216]
 ldr x14,[x9,#240]
 str x10,[sp,#1144]
 str x14,[sp,#1152]
 mov x16,#0
.Llc_spline_coefficient:
 mov x15,#4
 sub x15,x15,x16
 madd x17,x15,x12,x11
 add x15,x28,x16
 madd x17,x15,x13,x17
 add x17,x17,x14
 ldr x9,[sp,#1144]
 add x9,x9,x17,lsl #3
 ldr d0,[x9]
 ldr d1,[x9,x14,lsl #3]
 add x9,x9,x14,lsl #3
 ldr d2,[x9,x14,lsl #3]
 add x9,x9,x14,lsl #3
 ldr d3,[x9,x14,lsl #3]
 fmul d3,d15,d3
 fadd d2,d2,d3
 fmul d2,d15,d2
 fadd d1,d1,d2
 fmul d1,d15,d1
 fadd d0,d0,d1
 madd x17,x16,x21,x26
 lsl x17,x17,#3
 WRITE d0,75,x17
 add x16,x16,#1
 cmp x16,#4
 b.lo .Llc_spline_coefficient
.Llc_extra_done:
 add x24,x24,#1
 b .Llc_extra_row
.Llc_extra_next:
 add x25,x25,#1
 b .Llc_extra_level
.Llc_finish:
 mov x0,x29
 bl free
 add x17,sp,#1440
 ldp x19,x20,[x17,#0]
 ldp x21,x22,[x17,#16]
 ldp x23,x24,[x17,#32]
 ldp x25,x26,[x17,#48]
 ldp x27,x28,[x17,#64]
 ldp x29,x30,[x17,#80]
 ldp d8,d9,[x17,#96]
 ldp d10,d11,[x17,#112]
 ldp d12,d13,[x17,#128]
 ldp d14,d15,[x17,#144]
 add sp,sp,#1600
 ret
.Llc_reject:
 mov w0,#116
 bl _exit
 brk #0

.Llc_latlon:
 str x30,[sp,#1120]
 PTR x0,1
 PTR x1,3
 PTR x2,8
 PTR x3,4
 PTR x4,6
 PTR x5,7
 ldr x6,[sp,#1024]
 ldr x7,[sp,#1032]
 ldr x9,[sp,#816]
 str x9,[sp,#0]
 ldr x9,[sp,#824]
 str x9,[sp,#8]
 ldr x9,[sp,#832]
 str x9,[sp,#16]
 PTR x9,51
 str x9,[sp,#24]
 PTR x9,52
 str x9,[sp,#32]
 ldr x9,[sp,#1040]
 str x9,[sp,#40]
 ldr x9,[sp,#1048]
 str x9,[sp,#48]
 PTR x9,29
 str x9,[sp,#56]
 PTR x9,30
 str x9,[sp,#64]
 PTR x9,31
 str x9,[sp,#72]
 ldr x9,[sp,#1056]
 str x9,[sp,#80]
 ldr x9,[sp,#1064]
 str x9,[sp,#88]
 ldr x9,[sp,#1072]
 str x9,[sp,#96]
 bl LASCAW_CLA_CHILD
 mov x17,#1
 mul x17,x17,x21
 lsl x17,x17,#3
 PTR x0,3
 PTR x1,8
 PTR x2,4
 PTR x3,6
 PTR x4,7
 ldr x5,[sp,#1024]
 ldr x6,[sp,#1032]
 PTR x7,57
 add x7,x7,x17
 PTR x9,58
 add x9,x9,x17
 str x9,[sp,#0]
 ldr x9,[sp,#1040]
 str x9,[sp,#8]
 ldr x9,[sp,#1048]
 str x9,[sp,#16]
 ldr x9,[sp,#1080]
 str x9,[sp,#24]
 ldr x9,[sp,#1088]
 str x9,[sp,#32]
 ldr x9,[sp,#1096]
 str x9,[sp,#40]
 bl LASCAW_CLO_CHILD
 mov x17,#2
 mul x17,x17,x21
 lsl x17,x17,#3
 PTR x0,3
 PTR x1,8
 PTR x2,4
 PTR x3,6
 PTR x4,7
 ldr x5,[sp,#1024]
 ldr x6,[sp,#1032]
 PTR x7,57
 add x7,x7,x17
 PTR x9,58
 add x9,x9,x17
 str x9,[sp,#0]
 ldr x9,[sp,#1040]
 str x9,[sp,#8]
 ldr x9,[sp,#1048]
 str x9,[sp,#16]
 ldr x9,[sp,#1080]
 mov x16,#24
 madd x9,x21,x16,x9
 str x9,[sp,#24]
 ldr x9,[sp,#1088]
 mov x16,#24
 madd x9,x21,x16,x9
 str x9,[sp,#32]
 ldr x9,[sp,#1096]
 mov x16,#24
 madd x9,x21,x16,x9
 str x9,[sp,#40]
 bl LASCAW_CLO_CHILD
 ldr x30,[sp,#1120]
 ret
.Llc_vintw:
 str x30,[sp,#1128]
 PTR x0,3
 PTR x1,4
 PTR x2,8
 PTR x3,6
 PTR x4,7
 add x5,sp,#936
 add x6,sp,#880
 add x7,sp,#928
 PTR x9,18
 str x9,[sp,#0]
 ldr x9,[sp,#1032]
 str x9,[sp,#8]
 ldr x9,[sp,#1016]
 str x9,[sp,#16]
 PTR x9,34
 str x9,[sp,#24]
 PTR x9,68
 str x9,[sp,#32]
 PTR x9,69
 str x9,[sp,#40]
 PTR x9,50
 str x9,[sp,#48]
 PTR x9,44
 str x9,[sp,#56]
 PTR x9,45
 str x9,[sp,#64]
 PTR x9,35
 str x9,[sp,#72]
 PTR x9,37
 str x9,[sp,#80]
 PTR x9,38
 str x9,[sp,#88]
 PTR x9,39
 str x9,[sp,#96]
 PTR x9,40
 str x9,[sp,#104]
 PTR x9,70
 ldr x17,[sp,#1112]
 add x9,x9,x17
 str x9,[sp,#112]
 PTR x9,74
 str x9,[sp,#120]
 PTR x9,71
 str x9,[sp,#128]
 PTR x9,72
 str x9,[sp,#136]
 PTR x9,73
 ldr x17,[sp,#1112]
 add x9,x9,x17
 str x9,[sp,#144]
 bl LASCAW_VINTW_CHILD
 ldr x30,[sp,#1128]
 ret
.size MD2ASM_LASCAW_SYMBOL,.-MD2ASM_LASCAW_SYMBOL
.section .rodata
.p2align 3
.Llc_epsilon:
 .quad 0x0079000000000000
.Llc_tenth:
 .quad 0x3fb999999999999a
.Llc_twentieth:
 .quad 0x3fa999999999999a
.section .note.GNU-stack,"",%progbits
