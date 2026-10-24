/* Direct complete Cartesian departure-point route.
 * Physics formulations/openifs/dynamics/cartesian_departure_points.md.
 * Contract skills/md2asm/references/openifs/dynamics/cartesian_departure_points.md.
 * Twenty-four original pointer arguments, FP64 source rounding, FPCR zero.
 * The routine owns all predictors, interpolation calls, updates and work arrays.
 * Prepared privately for genuine-call and saved-forecast acceptance. */
.text
.p2align 4
.global md2asm_larmes_xyz_7259755
.type md2asm_larmes_xyz_7259755,%function
.macro TR_ARG reg,index
 ldr \reg,[x21,#8*\index]
.endm
.macro TR_FIELD reg,base,offset
 mov x17,#\offset
 add \reg,\base,x17
.endm
.macro TR_MODEL reg,offset
 TR_FIELD \reg,x20,\offset
.endm
.macro TR_CHILD index
 str x9,[sp,#320+8*\index]
.endm
.macro TR_FINITE reg
 lsr x12,\reg,#52
 and x12,x12,#2047
 cmp x12,#2047
 b.eq .Ltrajectory_bad
.endm
.macro TR_PB2_CACHE offset,slot
 TR_ARG x9,8
 TR_MODEL x10,\offset
 ldrsw x10,[x10]
 cmp x10,#1
 b.lt .Ltrajectory_bad
 sub x10,x10,#1
 TR_MODEL x11,9184
 ldrsw x11,[x11]
 add x12,x10,x23
 cmp x12,x11
 b.gt .Ltrajectory_bad
 mul x10,x10,x22
 add x9,x9,x10,lsl #3
 str x9,[sp,#\slot]
.endm
md2asm_larmes_xyz_7259755:
 mov x16,sp
 sub sp,sp,#2048
 add x17,sp,#1856
 stp x19,x20,[x17]
 stp x21,x22,[x17,#16]
 stp x23,x24,[x17,#32]
 stp x25,x26,[x17,#48]
 stp x27,x28,[x17,#64]
 stp x29,x30,[x17,#80]
 stp d8,d9,[x17,#96]
 stp d10,d11,[x17,#112]
 stp d12,d13,[x17,#128]
 stp d14,d15,[x17,#144]
 add x21,sp,#704
 stp x0,x1,[x21]
 stp x2,x3,[x21,#16]
 stp x4,x5,[x21,#32]
 stp x6,x7,[x21,#48]
 add x10,x21,#64
 mov x9,#16
.Ltrajectory_arguments:
 ldr x11,[x16],#8
 str x11,[x10],#8
 subs x9,x9,#1
 b.ne .Ltrajectory_arguments
#ifdef CARTESIAN_EXPLICIT_CONTEXT
 ldr x9,[x16]
 cbz x9,.Ltrajectory_bad
 tst x9,#7
 b.ne .Ltrajectory_bad
 adds x10,x9,#16
 b.cs .Ltrajectory_bad
 str x9,[sp,#1808]
 ldp x10,x11,[x9]
 cbz x10,.Ltrajectory_bad
 cbz x11,.Ltrajectory_bad
 orr x12,x10,x11
 tst x12,#7
 b.ne .Ltrajectory_bad
 adds x12,x10,#520
 b.cs .Ltrajectory_bad
 adds x12,x11,#360
 b.cs .Ltrajectory_bad
 str x10,[sp,#1816]
 str x11,[sp,#1824]
#endif
 mrs x9,fpcr
 cbnz x9,.Ltrajectory_bad
 mov x9,#0
.Ltrajectory_pointer_guard:
 ldr x10,[x21,x9,lsl #3]
 cbz x10,.Ltrajectory_bad
 tst x10,#3
 b.ne .Ltrajectory_bad
 add x9,x9,#1
 cmp x9,#24
 b.lo .Ltrajectory_pointer_guard
 TR_ARG x19,0
 TR_ARG x20,2
 TR_FIELD x9,x19,5144
 ldrsw x22,[x9]
 cmp x22,#1
 b.lt .Ltrajectory_bad
 cmp x22,#1024
 b.gt .Ltrajectory_bad
 TR_FIELD x9,x19,5224
 ldrsw x23,[x9]
 cmp x23,#4
 b.lt .Ltrajectory_bad
 cmp x23,#256
 b.gt .Ltrajectory_bad
 mul x24,x22,x23
 lsl x24,x24,#3
 TR_MODEL x9,4672
 ldr w9,[x9]
 cmp w9,#2
 b.lt .Ltrajectory_bad
 cmp w9,#16
 b.gt .Ltrajectory_bad
 str w9,[sp,#1244]
 TR_MODEL x9,5024
 ldr w9,[x9]
 cbnz w9,.Ltrajectory_bad
 TR_MODEL x9,4760
 ldr w9,[x9]
 cmp w9,#1
 b.hi .Ltrajectory_bad
 TR_MODEL x9,328
 ldr w9,[x9]
 cbnz w9,.Ltrajectory_bad
 TR_MODEL x9,220
 ldr w9,[x9]
 cmp w9,#1
 b.hi .Ltrajectory_bad
 TR_MODEL x9,4764
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Ltrajectory_bad
 TR_MODEL x9,4756
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Ltrajectory_bad
 TR_MODEL x9,4924
 ldr w9,[x9]
 cmp w9,#0
 b.ne .Ltrajectory_bad
 TR_MODEL x9,4668
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Ltrajectory_bad
 TR_MODEL x9,4660
 ldr w9,[x9]
 cmp w9,#0
 b.ne .Ltrajectory_bad
 TR_MODEL x9,212
 ldr w9,[x9]
 cmp w9,#0
 b.ne .Ltrajectory_bad
 TR_MODEL x9,236
 ldr w9,[x9]
 cmp w9,#0
 b.ne .Ltrajectory_bad
 TR_MODEL x9,240
 ldr w9,[x9]
 cmp w9,#0
 b.ne .Ltrajectory_bad
 TR_MODEL x9,244
 ldr w9,[x9]
 cmp w9,#0
 b.ne .Ltrajectory_bad
 TR_MODEL x9,100
 ldr w9,[x9]
 cmp w9,#0
 b.ne .Ltrajectory_bad
 TR_ARG x9,3
 ldrsw x10,[x9]
 cmp x10,#1
 b.lt .Ltrajectory_bad
 add x11,x22,#1
 cmp x10,x11
 b.gt .Ltrajectory_bad
 sub x10,x10,#1
 str x10,[sp,#1224]
 TR_ARG x9,4
 ldrsw x11,[x9]
 cmp x11,x22
 b.gt .Ltrajectory_bad
 cmp x11,x10
 b.lt .Ltrajectory_bad
 str x11,[sp,#1216]
 /* Complete arrival-wind views, validated before caller writes. */
 TR_PB2_CACHE 9228,1176
 TR_PB2_CACHE 9232,1184
 TR_PB2_CACHE 9240,1192
 TR_PB2_CACHE 9236,1200
 /* Cartesian record selection from the actual contiguous record descriptor. */
 TR_FIELD x9,x19,8472
 ldr x10,[x9]
 cbz x10,.Ltrajectory_bad
 ldr x11,[x9,#16]
 cmp x11,#1472
 b.ne .Ltrajectory_bad
 ldr x11,[x9,#40]
 cmp x11,#1
 b.ne .Ltrajectory_bad
 ldp x11,x12,[x9,#48]
 TR_ARG x13,11
 ldrsw x13,[x13]
 cmp x13,x11
 b.lt .Ltrajectory_bad
 cmp x13,x12
 b.gt .Ltrajectory_bad
 sub x13,x13,x11
 mov x12,#1472
 madd x10,x13,x12,x10
 ldr x9,[x10,#512]
 cbz x9,.Ltrajectory_bad
 str x9,[sp,#1136]
 ldr x9,[x10,#576]
 cbz x9,.Ltrajectory_bad
 str x9,[sp,#1144]
 ldr x9,[x10,#640]
 cbz x9,.Ltrajectory_bad
 str x9,[sp,#1152]
 /* Complete tangent-basis owners for the selected non-curved RHS. */
 TR_MODEL x9,4760
 ldr w9,[x9]
 cbnz w9,.Ltrajectory_no_rotation_owners
 ldr x9,[x10,#256]
 cbz x9,.Ltrajectory_bad
 str x9,[sp,#1280]
 ldr x9,[x10,#128]
 cbz x9,.Ltrajectory_bad
 str x9,[sp,#1288]
 ldr x9,[x10,#192]
 cbz x9,.Ltrajectory_bad
 str x9,[sp,#1296]
 TR_ARG x9,17
 TR_MODEL x10,6820
 ldrsw x10,[x10]
 cmp x10,#1
 b.lt .Ltrajectory_bad
 TR_MODEL x11,6828
 ldrsw x11,[x11]
 cmp x10,x11
 b.gt .Ltrajectory_bad
 sub x10,x10,#1
 madd x9,x10,x24,x9
 str x9,[sp,#1304]
 TR_ARG x9,17
 TR_MODEL x10,6824
 ldrsw x10,[x10]
 cmp x10,#1
 b.lt .Ltrajectory_bad
 TR_MODEL x11,6828
 ldrsw x11,[x11]
 cmp x10,x11
 b.gt .Ltrajectory_bad
 sub x10,x10,#1
 madd x9,x10,x24,x9
 str x9,[sp,#1312]
.Ltrajectory_no_rotation_owners:
 TR_FIELD x9,x19,3248
 ldr x9,[x9]
 cbz x9,.Ltrajectory_bad
 ldr x10,[x9,#128]
 cbz x10,.Ltrajectory_bad
 str x10,[sp,#1160]
 ldr x11,[x9]
 cbz x11,.Ltrajectory_bad
 str x11,[sp,#1168]
 TR_ARG x9,17
 TR_MODEL x10,6812
 ldrsw x10,[x10]
 cmp x10,#1
 b.lt .Ltrajectory_bad
 TR_MODEL x11,6828
 ldrsw x11,[x11]
 cmp x10,x11
 b.gt .Ltrajectory_bad
 sub x10,x10,#1
 madd x9,x10,x24,x9
 str x9,[sp,#1120]
 TR_ARG x9,17
 TR_MODEL x10,6816
 ldrsw x10,[x10]
 cmp x10,#1
 b.lt .Ltrajectory_bad
 TR_MODEL x11,6828
 ldrsw x11,[x11]
 cmp x10,x11
 b.gt .Ltrajectory_bad
 sub x10,x10,#1
 madd x9,x10,x24,x9
 str x9,[sp,#1128]
#ifdef CARTESIAN_EXPLICIT_CONTEXT
 ldr x0,[sp,#1808]
 add x1,x0,#16
 bl .Ltrajectory_new_readonly_overlap
 ldr x0,[sp,#1816]
 add x1,x0,#520
 bl .Ltrajectory_new_readonly_overlap
 ldr x0,[sp,#1824]
 add x1,x0,#360
 bl .Ltrajectory_new_readonly_overlap
#endif
 /* Source preliminary constants retain each separate rounding point. */
 TR_ARG x9,1
 ldr d0,[x9,#248]
 fmov x9,d0
 TR_FINITE x9
 str d0,[sp,#976]
 fmov d1,#0.5
 fmul d1,d1,d0
 str d1,[sp,#984]
#ifdef CARTESIAN_EXPLICIT_CONTEXT
 ldr x9,[sp,#1816]
#else
 adrp x9,:got:__yomcst_MOD_rpi
 ldr x9,[x9,:got_lo12:__yomcst_MOD_rpi]
#endif
 ldr d0,[x9]
 fmov d1,#2.0
 fmul d0,d1,d0
 str d0,[sp,#992]
 ldr x9,[sp,#1160]
 ldr d0,[x9]
 str d0,[sp,#1016]
 add x10,x23,#1
 ldr d0,[x9,x10,lsl #3]
 str d0,[sp,#1024]
 TR_MODEL x10,4680
 ldr d0,[x10]
 fmov d1,#1.0
 fsub d1,d1,d0
 ldr x11,[sp,#1168]
 ldr d2,[x11]
 fmul d1,d1,d2
 ldr d2,[x9,#8]
 fmul d0,d0,d2
 fadd d0,d1,d0
 str d0,[sp,#1000]
 TR_MODEL x10,4688
 ldr d0,[x10]
 fmov d1,#1.0
 fsub d1,d1,d0
 ldr d2,[x11,x23,lsl #3]
 fmul d1,d1,d2
 ldr d2,[x9,x23,lsl #3]
 fmul d0,d0,d2
 fadd d0,d1,d0
 str d0,[sp,#1008]
 TR_MODEL x9,4768
 ldr w9,[x9]
 cmp w9,#1
 b.hi .Ltrajectory_bad
#ifdef CARTESIAN_EXPLICIT_CONTEXT
 ldr x10,[sp,#1824]
 ldr w10,[x10,#36]
#else
 adrp x10,:got:__yomct3_MOD_nstep
 ldr x10,[x10,:got_lo12:__yomct3_MOD_nstep]
 ldr w10,[x10]
#endif
 cmp w10,#1
 csel w9,w9,wzr,ge
 str w9,[sp,#1232]
 cbz w9,.Ltrajectory_no_full_pc
 TR_MODEL x10,336
 ldr w9,[x10]
 TR_MODEL x10,340
 ldr w10,[x10]
 cbnz w10,.Ltrajectory_no_full_pc
 TR_MODEL x10,3036
 ldr w10,[x10]
 cmp w10,#0
 csel w9,w9,wzr,gt
 b .Ltrajectory_full_pc_store
.Ltrajectory_no_full_pc:
 mov w9,#0
.Ltrajectory_full_pc_store:
 str w9,[sp,#1236]
 TR_MODEL x9,2792
 ldr d0,[x9]
 fmul d14,d0,d0
 TR_MODEL x9,2800
 ldr d0,[x9]
 fmul d15,d0,d0
 fmov d8,xzr
 fmov d9,xzr
 mov x26,#0
.Ltrajectory_wind_level:
 ldr x27,[sp,#1224]
.Ltrajectory_wind_column:
 ldr x9,[sp,#1216]
 cmp x27,x9
 b.ge .Ltrajectory_wind_next_level
 madd x28,x26,x22,x27
 lsl x28,x28,#3
 ldr x9,[sp,#1184]
 ldr d0,[x9,x28]
 fmov x10,d0
 TR_FINITE x10
 fmul d0,d0,d0
 fmax d8,d0,d8
 ldr x9,[sp,#1176]
 ldr d0,[x9,x28]
 fmov x10,d0
 TR_FINITE x10
 fmul d0,d0,d0
 fmax d9,d0,d9
 ldr x9,[sp,#1192]
 ldr x10,[x9,x28]
 TR_FINITE x10
 ldr x9,[sp,#1200]
 ldr x10,[x9,x28]
 TR_FINITE x10
 add x27,x27,#1
 b .Ltrajectory_wind_column
.Ltrajectory_wind_next_level:
 add x26,x26,#1
 cmp x26,x23
 b.lo .Ltrajectory_wind_level
 fcmp d8,d14
 b.gt .Ltrajectory_bad
 fcmp d9,d14
 b.gt .Ltrajectory_bad
 /* Own every temporary owner. C*8 is x24, with three column-counter planes. */
 TR_MODEL x9,6472
 ldrsw x10,[x9]
 cmp x10,#1
 b.lt .Ltrajectory_bad
 TR_MODEL x9,6644
 ldrsw x11,[x9]
 cmp x11,#1
 b.lt .Ltrajectory_bad
 add x12,x10,x11
 add x12,x12,#3
 mul x12,x12,x24
 mov x9,#12
 madd x0,x22,x9,x12
 str x0,[sp,#1112]
 bl malloc
 cbz x0,.Ltrajectory_bad
 mov x25,x0
 mov x1,#0
 ldr x2,[sp,#1112]
 bl memset
 str x25,[sp,#1040]
 add x9,x25,x24
 str x9,[sp,#1048]
 add x9,x9,x24
 str x9,[sp,#1056]
 TR_MODEL x10,6472
 ldrsw x10,[x10]
 madd x9,x10,x24,x9
 str x9,[sp,#1064]
 TR_MODEL x10,6644
 ldrsw x10,[x10]
 madd x9,x10,x24,x9
 str x9,[sp,#1072]
 add x9,x9,x24,lsr #1
 str x9,[sp,#1080]
 add x9,x9,x24,lsr #1
 str x9,[sp,#1088]
 add x9,x9,x22,lsl #2
 str x9,[sp,#1096]
 add x9,x9,x22,lsl #2
 str x9,[sp,#1104]
 /* Fixed scalar controls and one-word unused numerical dummies. */
 str xzr,[sp,#896]
 mov w9,#1
 str w9,[sp,#904]
 str w9,[sp,#908]
 str xzr,[sp,#912]
 str xzr,[sp,#920]
 add x17,sp,#928
 stp xzr,xzr,[x17]
 stp xzr,xzr,[x17,#16]
 str xzr,[sp,#960]
 /* Populate the complete unchanged interpolation interface. */
 TR_ARG x9,0
 TR_CHILD 0
 TR_ARG x9,2
 TR_CHILD 1
 TR_ARG x9,3
 TR_CHILD 2
 TR_ARG x9,4
 TR_CHILD 3
 TR_ARG x9,5
 TR_CHILD 4
 TR_ARG x9,6
 TR_CHILD 6
 TR_ARG x9,10
 TR_CHILD 14
 TR_ARG x9,11
 TR_CHILD 15
 TR_ARG x9,15
 TR_CHILD 16
 TR_ARG x9,16
 TR_CHILD 17
 TR_ARG x9,12
 TR_CHILD 29
 TR_ARG x9,13
 TR_CHILD 30
 TR_ARG x9,17
 TR_CHILD 31
 TR_ARG x9,18
 TR_CHILD 32
 TR_ARG x9,19
 TR_CHILD 33
 TR_ARG x9,21
 TR_CHILD 37
 TR_ARG x9,22
 TR_CHILD 38
 TR_ARG x9,23
 TR_CHILD 39
 add x9,sp,#896
 TR_CHILD 5
 add x9,sp,#912
 TR_CHILD 8
 add x9,sp,#916
 TR_CHILD 9
 add x9,sp,#908
 TR_CHILD 10
 add x9,sp,#904
 TR_CHILD 11
 add x9,sp,#900
 TR_CHILD 12
 add x9,sp,#920
 TR_CHILD 13
 add x9,sp,#928
 TR_CHILD 18
 add x9,sp,#936
 TR_CHILD 19
 add x9,sp,#944
 TR_CHILD 20
 add x9,sp,#952
 TR_CHILD 21
 add x9,sp,#960
 TR_CHILD 36
 TR_MODEL x9,5024
 TR_CHILD 7
 TR_ARG x9,8
 TR_MODEL x10,9320
 ldrsw x10,[x10]
 sub x10,x10,#1
 mul x10,x10,x22
 add x9,x9,x10,lsl #3
 TR_CHILD 22
 TR_ARG x9,8
 TR_MODEL x10,9324
 ldrsw x10,[x10]
 sub x10,x10,#1
 mul x10,x10,x22
 add x9,x9,x10,lsl #3
 TR_CHILD 23
 TR_ARG x9,8
 TR_MODEL x10,9328
 ldrsw x10,[x10]
 sub x10,x10,#1
 mul x10,x10,x22
 add x9,x9,x10,lsl #3
 TR_CHILD 24
 TR_ARG x9,7
 TR_MODEL x10,8992
 ldrsw x10,[x10]
 sub x10,x10,#1
 TR_ARG x11,5
 ldrsw x11,[x11,#1016]
 mul x10,x10,x11
 add x9,x9,x10,lsl #3
 TR_CHILD 25
 TR_ARG x9,7
 TR_MODEL x10,8996
 ldrsw x10,[x10]
 sub x10,x10,#1
 TR_ARG x11,5
 ldrsw x11,[x11,#1016]
 mul x10,x10,x11
 add x9,x9,x10,lsl #3
 TR_CHILD 26
 TR_ARG x9,7
 TR_MODEL x10,9000
 ldrsw x10,[x10]
 sub x10,x10,#1
 TR_ARG x11,5
 ldrsw x11,[x11,#1016]
 mul x10,x10,x11
 add x9,x9,x10,lsl #3
 TR_CHILD 27
 TR_ARG x9,7
 TR_MODEL x10,9004
 ldrsw x10,[x10]
 sub x10,x10,#1
 TR_ARG x11,5
 ldrsw x11,[x11,#1016]
 mul x10,x10,x11
 add x9,x9,x10,lsl #3
 TR_CHILD 28
 ldr x9,[sp,#1048]
 TR_CHILD 34
 ldr x9,[sp,#1040]
 TR_CHILD 35
 ldr x9,[sp,#1056]
 TR_CHILD 40
 ldr x9,[sp,#1064]
 TR_CHILD 41
 ldr x9,[sp,#1072]
 TR_CHILD 42
 ldr x9,[sp,#1080]
 TR_CHILD 43
 /* Initial source predictor, including complete saved-point selection. */
 mov x26,#1
.Ltrajectory_initial_level:
 ldr x27,[sp,#1224]
.Ltrajectory_initial_column:
 ldr x9,[sp,#1216]
 cmp x27,x9
 b.ge .Ltrajectory_initial_next_level
 sub x28,x26,#1
 madd x28,x28,x22,x27
 lsl x28,x28,#3
 ldr w9,[sp,#1232]
 cbz w9,.Ltrajectory_euler_cartesian
 TR_ARG x9,14
 ldr d0,[x9,x28]
 ldr x10,[sp,#1120]
 str d0,[x10,x28]
 add x9,x9,x24
 ldr d0,[x9,x28]
 ldr x10,[sp,#1128]
 str d0,[x10,x28]
 ldr w9,[sp,#1236]
 cbnz w9,.Ltrajectory_saved_eta
 TR_ARG x9,9
 ldr d0,[x9,x28]
 ldr x9,[sp,#1200]
 ldr d1,[x9,x28]
 fmul d0,d0,d1
 fcmp d0,#0.0
 b.gt .Ltrajectory_saved_eta
 b .Ltrajectory_initial_eta
.Ltrajectory_saved_eta:
 TR_ARG x9,14
 add x9,x9,x24,lsl #1
 ldr d0,[x9,x28]
 TR_ARG x10,16
 str d0,[x10,x28]
 b .Ltrajectory_initial_advance
.Ltrajectory_euler_cartesian:
 ldr d12,[sp,#976]
 ldr x9,[sp,#1176]
 ldr d0,[x9,x28]
 fmul d0,d12,d0
 ldr x9,[sp,#1136]
 ldr d1,[x9,x27,lsl #3]
 fsub d8,d1,d0
 ldr x9,[sp,#1184]
 ldr d0,[x9,x28]
 fmul d0,d12,d0
 ldr x9,[sp,#1144]
 ldr d1,[x9,x27,lsl #3]
 fsub d9,d1,d0
 ldr x9,[sp,#1192]
 ldr d0,[x9,x28]
 fmul d0,d12,d0
 ldr x9,[sp,#1152]
 ldr d1,[x9,x27,lsl #3]
 fsub d10,d1,d0
 bl .Ltrajectory_angles
.Ltrajectory_initial_eta:
 ldr x9,[sp,#1200]
 ldr d0,[x9,x28]
 ldr d1,[sp,#976]
 fmul d0,d1,d0
 ldr x9,[sp,#1160]
 ldr d1,[x9,x26,lsl #3]
 fsub d0,d1,d0
 bl .Ltrajectory_eta_store
.Ltrajectory_initial_advance:
 add x27,x27,#1
 b .Ltrajectory_initial_column
.Ltrajectory_initial_next_level:
 add x26,x26,#1
 cmp x26,x23
 b.le .Ltrajectory_initial_level
 mov w9,#2
 str w9,[sp,#1240]
.Ltrajectory_iteration:
 /* First eight child pointers in registers and every remaining stack word. */
 add x10,sp,#384
 mov x11,sp
 mov x9,#36
.Ltrajectory_child_stack:
 ldr x12,[x10],#8
 str x12,[x11],#8
 subs x9,x9,#1
 b.ne .Ltrajectory_child_stack
 ldp x0,x1,[sp,#320]
 ldp x2,x3,[sp,#336]
 ldp x4,x5,[sp,#352]
 ldp x6,x7,[sp,#368]
#ifdef CARTESIAN_EXPLICIT_CONTEXT
 ldr x9,[sp,#1816]
 str x9,[sp,#288]
#endif
 bl md2asm_larcina_7240564
 mov x26,#1
.Ltrajectory_midpoint_level:
 ldr x27,[sp,#1224]
.Ltrajectory_midpoint_column:
 ldr x9,[sp,#1216]
 cmp x27,x9
 b.ge .Ltrajectory_midpoint_next_level
 sub x28,x26,#1
 madd x28,x28,x22,x27
 lsl x28,x28,#3
 ldr d12,[sp,#984]
 TR_ARG x9,18
 ldr d0,[x9,x28]
 ldr x9,[sp,#1176]
 ldr d1,[x9,x28]
 fadd d0,d0,d1
 fmul d0,d12,d0
 ldr x9,[sp,#1136]
 ldr d1,[x9,x27,lsl #3]
 fsub d8,d1,d0
 TR_ARG x9,19
 ldr d0,[x9,x28]
 ldr x9,[sp,#1184]
 ldr d1,[x9,x28]
 fadd d0,d0,d1
 fmul d0,d12,d0
 ldr x9,[sp,#1144]
 ldr d1,[x9,x27,lsl #3]
 fsub d9,d1,d0
 ldr x9,[sp,#1048]
 ldr d0,[x9,x28]
 ldr x9,[sp,#1192]
 ldr d1,[x9,x28]
 fadd d0,d0,d1
 fmul d0,d12,d0
 ldr x9,[sp,#1152]
 ldr d1,[x9,x27,lsl #3]
 fsub d10,d1,d0
 bl .Ltrajectory_angles
 ldr x9,[sp,#1040]
 ldr d0,[x9,x28]
 ldr x9,[sp,#1200]
 ldr d1,[x9,x28]
 fadd d0,d0,d1
 ldr d1,[sp,#984]
 fmul d0,d1,d0
 ldr x9,[sp,#1160]
 ldr d1,[x9,x26,lsl #3]
 fsub d0,d1,d0
 fmov d14,d0
 bl .Ltrajectory_eta_store
 ldr w9,[sp,#1240]
 ldr w10,[sp,#1244]
 cmp w9,w10
 b.ne .Ltrajectory_midpoint_advance
 /* Original NINT is ties away from zero. Counters remain integer storage. */
 ldr d0,[sp,#1016]
 fsub d0,d14,d0
 fmov d1,#0.5
 fsub d0,d0,d1
 fcvtas w9,d0
 mov w10,#-1
 cmp w9,w10
 csel w9,w9,w10,gt
 cmp w9,#0
 csel w9,w9,wzr,lt
 ldr x10,[sp,#1088]
 ldr w11,[x10,x27,lsl #2]
 sub w11,w11,w9
 str w11,[x10,x27,lsl #2]
 ldr d0,[sp,#1024]
 fsub d0,d0,d14
 fsub d0,d0,d1
 fcvtas w9,d0
 mov w10,#-1
 cmp w9,w10
 csel w9,w9,w10,gt
 cmp w9,#0
 csel w9,w9,wzr,lt
 ldr x10,[sp,#1096]
 ldr w11,[x10,x27,lsl #2]
 sub w11,w11,w9
 str w11,[x10,x27,lsl #2]
.Ltrajectory_midpoint_advance:
 add x27,x27,#1
 b .Ltrajectory_midpoint_column
.Ltrajectory_midpoint_next_level:
 add x26,x26,#1
 cmp x26,x23
 b.le .Ltrajectory_midpoint_level
 ldr w9,[sp,#1240]
 add w9,w9,#1
 str w9,[sp,#1240]
 ldr w10,[sp,#1244]
 cmp w9,w10
 b.le .Ltrajectory_iteration
 /* Optional diagnostic wind and complete saved coordinates. */
 mov x26,#0
.Ltrajectory_final_level:
 ldr x27,[sp,#1224]
.Ltrajectory_final_column:
 ldr x9,[sp,#1216]
 cmp x27,x9
 b.ge .Ltrajectory_final_next_level
 madd x28,x26,x22,x27
 lsl x28,x28,#3
 TR_MODEL x9,216
 ldr w9,[x9]
 cbz w9,.Ltrajectory_no_wind_copy
 ldr x9,[sp,#1040]
 ldr d0,[x9,x28]
 TR_ARG x10,20
 str d0,[x10,x28]
.Ltrajectory_no_wind_copy:
 TR_MODEL x9,4760
 ldr w9,[x9]
 cbnz w9,.Ltrajectory_no_rotation
 ldr x9,[sp,#1128]
 ldr d0,[x9,x28]
 bl md2asm_sin_original_rounding
 fmov d8,d0
 ldr x9,[sp,#1128]
 ldr d0,[x9,x28]
 bl md2asm_cos_original_rounding
 fmov d9,d0
 ldr x9,[sp,#1280]
 ldr d0,[x9,x27,lsl #3]
 ldr x9,[sp,#1120]
 ldr d1,[x9,x28]
 fsub d0,d0,d1
 bl md2asm_sin_original_rounding
 fmov d10,d0
 ldr x9,[sp,#1280]
 ldr d0,[x9,x27,lsl #3]
 ldr x9,[sp,#1120]
 ldr d1,[x9,x28]
 fsub d0,d0,d1
 bl md2asm_cos_original_rounding
 fmov d11,d0
 ldr x9,[sp,#1288]
 ldr d12,[x9,x27,lsl #3]
 ldr x9,[sp,#1296]
 ldr d13,[x9,x27,lsl #3]
 /* Preserve every original separate multiplication and addition. */
 fmul d0,d8,d10
 fneg d1,d12
 fmul d1,d1,d10
 fmul d2,d13,d9
 fmul d3,d12,d8
 fmul d3,d3,d11
 fadd d2,d2,d3
 fmul d3,d12,d8
 fmul d4,d13,d9
 fmul d4,d4,d11
 fadd d3,d3,d4
 fmov d4,#1.0
 fadd d3,d4,d3
 fadd d2,d11,d2
 fdiv d2,d2,d3
 ldr x9,[sp,#1304]
 str d2,[x9,x28]
 fsub d0,d0,d1
 fdiv d0,d0,d3
 ldr x9,[sp,#1312]
 str d0,[x9,x28]
.Ltrajectory_no_rotation:
 TR_MODEL x9,4768
 ldr w9,[x9]
 cbz w9,.Ltrajectory_no_save
 TR_ARG x10,14
 ldr x9,[sp,#1120]
 ldr d0,[x9,x28]
 str d0,[x10,x28]
 add x10,x10,x24
 ldr x9,[sp,#1128]
 ldr d0,[x9,x28]
 str d0,[x10,x28]
 add x10,x10,x24
 TR_ARG x9,16
 ldr d0,[x9,x28]
 str d0,[x10,x28]
.Ltrajectory_no_save:
 add x27,x27,#1
 b .Ltrajectory_final_column
.Ltrajectory_final_next_level:
 add x26,x26,#1
 cmp x26,x23
 b.lo .Ltrajectory_final_level
 /* The source reporting branch owns its numerical calculations. The
  * formatted diagnostic text is outside saved forecast state bytes. */
 TR_MODEL x9,220
 ldr w9,[x9]
 cbz w9,.Ltrajectory_reporting_done
 mov x26,#0
.Ltrajectory_reporting_side:
 ldr x27,[sp,#1224]
.Ltrajectory_reporting_column:
 ldr x9,[sp,#1216]
 cmp x27,x9
 b.ge .Ltrajectory_reporting_next_side
 add x9,sp,#1088
 ldr x9,[x9,x26,lsl #3]
 ldr w9,[x9,x27,lsl #2]
 cbz w9,.Ltrajectory_reporting_next_column
 /* Original finite MAXVAL traverses all vertical levels. */
 ldr x9,[sp,#1040]
 ldr d0,[x9,x27,lsl #3]
 mov x10,#1
.Ltrajectory_reporting_maximum:
 madd x11,x10,x22,x27
 ldr d1,[x9,x11,lsl #3]
 fmax d0,d0,d1
 add x10,x10,#1
 cmp x10,x23
 b.lo .Ltrajectory_reporting_maximum
 str d0,[sp,#1344]
 /* Select the complete CSGEOM record before reading its cosine owner. */
 TR_FIELD x9,x19,8024
 ldr x10,[x9]
 cbz x10,.Ltrajectory_bad
 ldr x11,[x9,#16]
 cmp x11,#384
 b.ne .Ltrajectory_bad
 ldp x11,x12,[x9,#48]
 TR_ARG x13,11
 ldrsw x13,[x13]
 cmp x13,x11
 b.lt .Ltrajectory_bad
 cmp x13,x12
 b.gt .Ltrajectory_bad
 sub x13,x13,x11
 mov x12,#384
 madd x10,x13,x12,x10
 ldr x9,[x10]
 cbz x9,.Ltrajectory_bad
 ldr d0,[x9,x27,lsl #3]
 bl md2asm_acos_original_rounding
 ldr x9,=0x4066800000000000
 fmov d1,x9
 fmul d0,d0,d1
#ifdef CARTESIAN_EXPLICIT_CONTEXT
 ldr x9,[sp,#1816]
#else
 adrp x9,:got:__yomcst_MOD_rpi
 ldr x9,[x9,:got_lo12:__yomcst_MOD_rpi]
#endif
 ldr d1,[x9]
 fdiv d0,d0,d1
 str d0,[sp,#1352]
 TR_FIELD x9,x19,8472
 ldr x10,[x9]
 ldr x11,[x9,#48]
 TR_ARG x13,11
 ldrsw x13,[x13]
 sub x13,x13,x11
 mov x12,#1472
 madd x10,x13,x12,x10
 ldr x9,[x10,#128]
 cbz x9,.Ltrajectory_bad
 ldr d0,[x9,x27,lsl #3]
 bl md2asm_asin_original_rounding
 ldr x9,=0x4066800000000000
 fmov d1,x9
 fmul d0,d0,d1
#ifdef CARTESIAN_EXPLICIT_CONTEXT
 ldr x9,[sp,#1816]
#else
 adrp x9,:got:__yomcst_MOD_rpi
 ldr x9,[x9,:got_lo12:__yomcst_MOD_rpi]
#endif
 ldr d1,[x9]
 fdiv d0,d0,d1
 str d0,[sp,#1360]
 adrp x9,.Ltrajectory_report_calculations
 add x9,x9,:lo12:.Ltrajectory_report_calculations
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
.Ltrajectory_reporting_next_column:
 add x27,x27,#1
 b .Ltrajectory_reporting_column
.Ltrajectory_reporting_next_side:
 add x26,x26,#1
 cmp x26,#2
 b.lo .Ltrajectory_reporting_side
.Ltrajectory_reporting_done:
 mov x0,x25
 bl free
 adrp x9,.Ltrajectory_calls
 add x9,x9,:lo12:.Ltrajectory_calls
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
 add x17,sp,#1856
 ldp x19,x20,[x17]
 ldp x21,x22,[x17,#16]
 ldp x23,x24,[x17,#32]
 ldp x25,x26,[x17,#48]
 ldp x27,x28,[x17,#64]
 ldp x29,x30,[x17,#80]
 ldp d8,d9,[x17,#96]
 ldp d10,d11,[x17,#112]
 ldp d12,d13,[x17,#128]
 ldp d14,d15,[x17,#144]
 add sp,sp,#2048
 ret
.size md2asm_larmes_xyz_7259755,.-md2asm_larmes_xyz_7259755

/* These local helpers preserve the main frame and all live index registers. */
.type .Ltrajectory_angles,%function
.Ltrajectory_angles:
 add x17,sp,#1264
 stp x29,x30,[x17]
 fmul d0,d8,d8
 fmul d1,d9,d9
 fadd d0,d0,d1
 fmul d1,d10,d10
 fadd d0,d0,d1
 fsqrt d0,d0
 fdiv d12,d10,d0
 fmov d0,d9
 fmov d1,d8
 bl md2asm_atan2_original_rounding
 fmov d13,d0
 fmov x9,d0
 and x9,x9,#0x8000000000000000
 mov x10,#0x3fe0000000000000
 orr x9,x9,x10
 fmov d1,x9
 fmov d0,#0.5
 fsub d0,d0,d1
 ldr d1,[sp,#992]
 fmul d0,d0,d1
 fadd d13,d0,d13
 ldr x9,[sp,#1120]
 str d13,[x9,x28]
 fmov d0,d12
 bl md2asm_asin_original_rounding
 ldr x9,[sp,#1128]
 str d0,[x9,x28]
 add x17,sp,#1264
 ldp x29,x30,[x17]
 ret
.size .Ltrajectory_angles,.-.Ltrajectory_angles
.type .Ltrajectory_eta_store,%function
.Ltrajectory_eta_store:
 ldr d1,[sp,#1000]
 fmax d0,d1,d0
 ldr d1,[sp,#1008]
 fmin d0,d1,d0
 TR_ARG x9,16
 str d0,[x9,x28]
 ret
.size .Ltrajectory_eta_store,.-.Ltrajectory_eta_store
#ifdef CARTESIAN_EXPLICIT_CONTEXT
/* Check one new read-only owner against every complete caller output. */
.Ltrajectory_new_readonly_overlap:
 mov x2,#12
.Ltrajectory_new_readonly_loop:
 ldr x3,[x21,x2,lsl#3]
 mov x4,#4
 cmp x2,#14
 b.lt .Ltrajectory_new_extent
 mov x4,x24
 cmp x2,#14
 b.ne .Ltrajectory_new_not_saved
 add x4,x24,x24,lsl#1
 b .Ltrajectory_new_extent
.Ltrajectory_new_not_saved:
 cmp x2,#15
 b.ne .Ltrajectory_new_not_geo
 ldrsw x5,[x20,#6808]
 b .Ltrajectory_new_planes
.Ltrajectory_new_not_geo:
 cmp x2,#17
 b.ne .Ltrajectory_new_not_coord
 ldrsw x5,[x20,#6828]
.Ltrajectory_new_planes:
 sub x6,x5,#1
 cmp x6,#1023
 b.hi .Ltrajectory_bad
 mul x4,x24,x5
 b .Ltrajectory_new_extent
.Ltrajectory_new_not_coord:
 cmp x2,#21
 b.lt .Ltrajectory_new_extent
 cmp x2,#23
 b.eq .Ltrajectory_new_level_index
 lsl x4,x24,#1
 b .Ltrajectory_new_extent
.Ltrajectory_new_level_index:
 lsr x4,x24,#1
.Ltrajectory_new_extent:
 adds x5,x3,x4
 b.cs .Ltrajectory_bad
 cmp x0,x5
 b.hs .Ltrajectory_new_readonly_next
 cmp x3,x1
 b.lo .Ltrajectory_bad
.Ltrajectory_new_readonly_next:
 add x2,x2,#1
 cmp x2,#24
 b.lo .Ltrajectory_new_readonly_loop
 ret
#endif
.Ltrajectory_bad:
 bl abort
 brk #0x73b
 b .Ltrajectory_bad
.ltorg
#ifndef CARTESIAN_EXPLICIT_CONTEXT
.global larmes_xyz_
.type larmes_xyz_,%function
larmes_xyz_:
 b md2asm_larmes_xyz_7259755
.size larmes_xyz_,.-larmes_xyz_
#endif
.global md2asm_larmes_xyz_calls_get
.type md2asm_larmes_xyz_calls_get,%function
md2asm_larmes_xyz_calls_get:
 adrp x9,.Ltrajectory_calls
 ldr x0,[x9,:lo12:.Ltrajectory_calls]
 ret
.size md2asm_larmes_xyz_calls_get,.-md2asm_larmes_xyz_calls_get
/* Other forecast callers share the accepted complete WENO assembly child. */
.global md2asm_laitri_weno
.hidden md2asm_laitri_weno
.type md2asm_laitri_weno,%function
md2asm_laitri_weno:
 b laitri_weno_
.size md2asm_laitri_weno,.-md2asm_laitri_weno
.global md2asm_larmes_reporting_calculations_get
.type md2asm_larmes_reporting_calculations_get,%function
md2asm_larmes_reporting_calculations_get:
 adrp x9,.Ltrajectory_report_calculations
 ldr x0,[x9,:lo12:.Ltrajectory_report_calculations]
 ret
.size md2asm_larmes_reporting_calculations_get,.-md2asm_larmes_reporting_calculations_get
.data
.p2align 3
.Ltrajectory_calls:.xword 0
.Ltrajectory_report_calculations:.xword 0
.section .note.GNU-stack,"",%progbits
