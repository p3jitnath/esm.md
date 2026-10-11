/* Complete LARCINA spherical Cartesian route, revision 1.
 * Physics: formulations/openifs/dynamics/departure_point_fields.md.
 * Contract: skills/md2asm/references/openifs/dynamics/larcina.md.
 * Forty-four original pointers. No driver supplies a numerical stage. */
.text
.p2align 4
.global md2asm_larcina_7240564
.type md2asm_larcina_7240564,%function
.macro LAR_ARG reg,index
 ldr \reg,[x28,#8*\index]
.endm
.macro LAR_FIELD reg,base,offset
 mov x17,#\offset
 add \reg,\base,x17
.endm
.macro LAR_PUT index
 str x9,[x27,#8*\index]
.endm
.macro LAR_VIEW index,parent,field,planes,dimension
 LAR_ARG x9,\parent
 LAR_FIELD x10,x20,\field
 ldrsw x10,[x10]
 cmp x10,#1
 b.lt .Llar_bad
 sub x10,x10,#1
 LAR_FIELD x11,x20,\dimension
 ldrsw x11,[x11]
 add x12,x10,#\planes
 cmp x12,x11
 b.gt .Llar_bad
 madd x9,x10,x24,x9
 LAR_PUT \index
.endm
/* Verify a complete contiguous descriptor before output writes. */
.macro LAR_DESC base,offset,element,rank
 LAR_FIELD x9,\base,\offset
 ldr x10,[x9]
 cbz x10,.Llar_bad
 tst x10,#(\element-1)
 b.ne .Llar_bad
 ldr x10,[x9,#16]
 cmp x10,#\element
 b.ne .Llar_bad
 ldr w10,[x9,#28]
 and w10,w10,#255
 cmp w10,#\rank
 b.ne .Llar_bad
 mov x13,#1
 mov x16,#0
 .set lar_dim,0
 .rept \rank
  ldr x10,[x9,#40+24*lar_dim]
  cmp x10,x13
  b.ne .Llar_bad
  ldp x10,x12,[x9,#48+24*lar_dim]
  msub x16,x10,x13,x16
  sub x12,x12,x10
  add x12,x12,#1
  cmp x12,#1
  b.lt .Llar_bad
  ldr x14,=2000001
  cmp x12,x14
  b.hi .Llar_bad
  mul x13,x13,x12
  .set lar_dim,lar_dim+1
 .endr
 ldr x10,[x9,#8]
 cmp x10,x16
 b.ne .Llar_bad
 ldr x10,[x9,#32]
 cmp x10,#\element
 b.ne .Llar_bad
 ldr w10,[x9,#28]
 lsr w10,w10,#8
 .if \element==8
 cmp w10,#3
 .else
 cmp w10,#1
 .endif
 b.ne .Llar_bad
.endm
md2asm_larcina_7240564:
 mov x16,sp
 sub sp,sp,#1,lsl #12
 add x17,sp,#3936
 stp x18,x19,[x17]
 stp x20,x21,[x17,#16]
 stp x22,x23,[x17,#32]
 stp x24,x25,[x17,#48]
 stp x26,x27,[x17,#64]
 stp x28,x29,[x17,#80]
 str x30,[x17,#96]
 add x28,sp,#1024
 stp x0,x1,[x28]
 stp x2,x3,[x28,#16]
 stp x4,x5,[x28,#32]
 stp x6,x7,[x28,#48]
 add x10,x28,#64
 mov x9,#36
.Llar_args:
 ldr x11,[x16],#8
 str x11,[x10],#8
 subs x9,x9,#1
 b.ne .Llar_args
 mrs x9,fpcr
 cbnz x9,.Llar_bad
 adrp x9,:got:__yommp0_MOD_nproc
 ldr x9,[x9,:got_lo12:__yommp0_MOD_nproc]
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Llar_bad
 LAR_ARG x19,0
 LAR_ARG x20,1
 LAR_ARG x21,4
 cbz x19,.Llar_bad
 cbz x20,.Llar_bad
 cbz x21,.Llar_bad
 tst x19,#7
 b.ne .Llar_bad
 tst x20,#7
 b.ne .Llar_bad
 tst x21,#7
 b.ne .Llar_bad

 LAR_ARG x9,2
 cbz x9,.Llar_bad
 tst x9,#3
 b.ne .Llar_bad

 LAR_ARG x9,3
 cbz x9,.Llar_bad
 tst x9,#3
 b.ne .Llar_bad

 LAR_ARG x9,5
 cbz x9,.Llar_bad
 tst x9,#3
 b.ne .Llar_bad

 LAR_ARG x9,6
 cbz x9,.Llar_bad
 tst x9,#3
 b.ne .Llar_bad

 LAR_ARG x9,7
 cbz x9,.Llar_bad
 tst x9,#3
 b.ne .Llar_bad

 LAR_ARG x9,8
 cbz x9,.Llar_bad
 tst x9,#3
 b.ne .Llar_bad

 LAR_ARG x9,9
 cbz x9,.Llar_bad
 tst x9,#3
 b.ne .Llar_bad

 LAR_ARG x9,10
 cbz x9,.Llar_bad
 tst x9,#3
 b.ne .Llar_bad

 LAR_ARG x9,11
 cbz x9,.Llar_bad
 tst x9,#3
 b.ne .Llar_bad

 LAR_ARG x9,13
 cbz x9,.Llar_bad
 tst x9,#3
 b.ne .Llar_bad

 LAR_ARG x9,14
 cbz x9,.Llar_bad
 tst x9,#7
 b.ne .Llar_bad

 LAR_ARG x9,15
 cbz x9,.Llar_bad
 tst x9,#3
 b.ne .Llar_bad

 LAR_ARG x9,17
 cbz x9,.Llar_bad
 tst x9,#7
 b.ne .Llar_bad

 LAR_ARG x9,29
 cbz x9,.Llar_bad
 tst x9,#3
 b.ne .Llar_bad

 LAR_ARG x9,30
 cbz x9,.Llar_bad
 tst x9,#3
 b.ne .Llar_bad

 LAR_ARG x9,31
 cbz x9,.Llar_bad
 tst x9,#7
 b.ne .Llar_bad

 LAR_ARG x9,37
 cbz x9,.Llar_bad
 tst x9,#3
 b.ne .Llar_bad

 LAR_ARG x9,38
 cbz x9,.Llar_bad
 tst x9,#3
 b.ne .Llar_bad

 LAR_ARG x9,39
 cbz x9,.Llar_bad
 tst x9,#3
 b.ne .Llar_bad

 LAR_ARG x9,40
 cbz x9,.Llar_bad
 tst x9,#7
 b.ne .Llar_bad

 LAR_ARG x9,41
 cbz x9,.Llar_bad
 tst x9,#7
 b.ne .Llar_bad

 LAR_ARG x9,42
 cbz x9,.Llar_bad
 tst x9,#3
 b.ne .Llar_bad

 LAR_ARG x9,43
 cbz x9,.Llar_bad
 tst x9,#3
 b.ne .Llar_bad

 LAR_ARG x9,7
 ldr w9,[x9]
 cbnz w9,.Llar_bad

 LAR_ARG x9,8
 ldr w9,[x9]
 cbnz w9,.Llar_bad

 LAR_ARG x9,9
 ldr w9,[x9]
 cbnz w9,.Llar_bad

 LAR_ARG x9,13
 ldr w9,[x9]
 cbnz w9,.Llar_bad

 LAR_FIELD x9,x20,4764
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Llar_bad

 LAR_FIELD x9,x20,4756
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Llar_bad

 LAR_FIELD x9,x20,4924
 ldr w9,[x9]
 cmp w9,#0
 b.ne .Llar_bad

 LAR_FIELD x9,x20,4668
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Llar_bad

 LAR_FIELD x9,x20,4660
 ldr w9,[x9]
 cmp w9,#0
 b.ne .Llar_bad

 LAR_FIELD x9,x20,212
 ldr w9,[x9]
 cmp w9,#0
 b.ne .Llar_bad

 LAR_FIELD x9,x20,236
 ldr w9,[x9]
 cmp w9,#0
 b.ne .Llar_bad

 LAR_FIELD x9,x20,240
 ldr w9,[x9]
 cmp w9,#0
 b.ne .Llar_bad

 LAR_FIELD x9,x20,244
 ldr w9,[x9]
 cmp w9,#0
 b.ne .Llar_bad

 LAR_FIELD x9,x20,100
 ldr w9,[x9]
 cmp w9,#0
 b.ne .Llar_bad

 LAR_FIELD x9,x20,1952
 ldr w9,[x9]
 cmp w9,#1
 b.hi .Llar_bad

 LAR_FIELD x9,x19,5144
 ldrsw x22,[x9]
 cmp x22,#1
 b.lt .Llar_bad
 cmp x22,#1024
 b.gt .Llar_bad
 LAR_FIELD x9,x19,5224
 ldrsw x23,[x9]
 cmp x23,#4
 b.lt .Llar_bad
 cmp x23,#256
 b.gt .Llar_bad
 mul x24,x22,x23
 lsl x24,x24,#3
 LAR_ARG x9,2
 ldrsw x10,[x9]
 cmp x10,#1
 b.lt .Llar_bad
 add x11,x22,#1
 cmp x10,x11
 b.gt .Llar_bad
 LAR_ARG x9,3
 ldrsw x10,[x9]
 cmp x10,#0
 b.lt .Llar_bad
 cmp x10,x22
 b.gt .Llar_bad
 LAR_ARG x9,5
 ldr w10,[x9]
 cmp w10,#1
 b.hi .Llar_bad
 LAR_ARG x9,10
 ldr w10,[x9]
 cmp w10,#1
 b.hi .Llar_bad
 LAR_ARG x9,11
 ldr w10,[x9]
 sub w11,w10,#1
 cmp w11,#2
 b.hi .Llar_bad
 /* Find the original interpolation type before any output. */
 mov w12,#1
 mov w13,#1
 cmp w10,#1
 b.ne .Llar_origin
 LAR_FIELD x9,x20,308
 ldr w9,[x9]
 cmp w9,#1
 b.hi .Llar_bad
 mov w11,#101
 cbz w9,.Llar_type_done
 mov w11,#102
 LAR_FIELD x9,x20,328
 ldr w9,[x9]
 cmp w9,#1
 b.hi .Llar_bad
 cbz w9,.Llar_type_done
 mov w13,#3
 b .Llar_type_done
.Llar_origin:
 cmp w10,#3
 b.ne .Llar_origin_two
 mov w12,#0
 LAR_FIELD x9,x20,232
 ldr w9,[x9]
 cmp w9,#1
 b.hi .Llar_bad
 mov w11,#103
 cbz w9,.Llar_type_done
 mov w11,#106
 mov w13,#3
 b .Llar_type_done
.Llar_origin_two:
 LAR_FIELD x9,x20,228
 ldr w9,[x9]
 cmp w9,#1
 b.hi .Llar_bad
 mov w11,#105
 cbnz w9,.Llar_type_done
 LAR_FIELD x9,x20,232
 ldr w9,[x9]
 cmp w9,#1
 b.hi .Llar_bad
 mov w11,#106
 cbnz w9,.Llar_type_weno
 LAR_ARG x9,5
 ldr w9,[x9]
 add w11,w9,#103
 b .Llar_type_done
.Llar_type_weno:
 mov w13,#3
.Llar_type_done:
 str w11,[sp,#3072]
 str w12,[sp,#3076]
 str w13,[sp,#3080]
 LAR_ARG x9,10
 ldr w9,[x9]
 cbz w9,.Llar_wind_guard_done
 cmp w10,#1
 b.ne .Llar_bad
 LAR_FIELD x9,x20,4748
 ldr w9,[x9]
 cmp w9,#3
 b.hi .Llar_bad
 LAR_FIELD x9,x20,328
 ldr w9,[x9]
 cbz w9,.Llar_no_weno_guard
 LAR_FIELD x9,x20,308
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Llar_bad
.Llar_no_weno_guard:

 LAR_ARG x9,25
 cbz x9,.Llar_bad
 tst x9,#7
 b.ne .Llar_bad

 LAR_ARG x9,26
 cbz x9,.Llar_bad
 tst x9,#7
 b.ne .Llar_bad

 LAR_ARG x9,27
 cbz x9,.Llar_bad
 tst x9,#7
 b.ne .Llar_bad

 LAR_ARG x9,28
 cbz x9,.Llar_bad
 tst x9,#7
 b.ne .Llar_bad

 LAR_ARG x9,32
 cbz x9,.Llar_bad
 tst x9,#7
 b.ne .Llar_bad

 LAR_ARG x9,33
 cbz x9,.Llar_bad
 tst x9,#7
 b.ne .Llar_bad

 LAR_ARG x9,34
 cbz x9,.Llar_bad
 tst x9,#7
 b.ne .Llar_bad

 LAR_ARG x9,35
 cbz x9,.Llar_bad
 tst x9,#7
 b.ne .Llar_bad

.Llar_wind_guard_done:
 ldrsw x25,[x21,#1672]
 ldrsw x26,[x21,#1676]
 sub x9,x26,x25
 cmp x9,#0
 b.lt .Llar_bad
 cmp x9,#4095
 b.gt .Llar_bad
 LAR_FIELD x9,x19,3264
 ldr x9,[x9]
 cbz x9,.Llar_bad
 str x9,[sp,#3096]
 LAR_FIELD x10,x19,3248
 ldr x10,[x10]
 cbz x10,.Llar_bad
 str x10,[sp,#3104]
 LAR_DESC x19,4808,8,1
 LAR_FIELD x9,x19,4808
 ldp x10,x11,[x9,#48]
 cmp x25,x10
 b.lt .Llar_bad
 cmp x26,x11
 b.gt .Llar_bad
 ldr x9,[sp,#3104]
 LAR_DESC x9,128,8,1

 ldr w9,[sp,#3072]
 cmp w9,#101
 b.eq .Llar_descriptor_skip_D_RIPI

 LAR_DESC x20,8480,8,2

 LAR_FIELD x9,x20,8480
 ldp x10,x11,[x9,#48]
 cmp x10,x25
 b.ne .Llar_bad
 cmp x11,x26
 b.ne .Llar_bad
 ldp x10,x11,[x9,#72]
 cmp x10,#1
 b.ne .Llar_bad
 cmp x11,#3
 b.ne .Llar_bad

.Llar_descriptor_skip_D_RIPI:

 ldr w9,[sp,#3072]
 cmp w9,#102
 b.ne .Llar_descriptor_skip_D_RSLD
 ldr x9,[x20,#320]
 lsl x9,x9,#1
 cbz x9,.Llar_descriptor_skip_D_RSLD

 LAR_DESC x20,8568,8,2

 LAR_FIELD x9,x20,8568
 ldp x10,x11,[x9,#48]
 cmp x10,x25
 b.ne .Llar_bad
 cmp x11,x26
 b.ne .Llar_bad
 ldp x10,x11,[x9,#72]
 cmp x10,#1
 b.ne .Llar_bad
 cmp x11,#3
 b.ne .Llar_bad

.Llar_descriptor_skip_D_RSLD:

 b .Llar_descriptor_skip_D_RSLDW

 LAR_DESC x20,8656,8,3

.Llar_descriptor_skip_D_RSLDW:

 b .Llar_descriptor_skip_D_R3DTW

 LAR_DESC x20,8768,8,3

.Llar_descriptor_skip_D_R3DTW:


 LAR_DESC x20,8352,4,1

.Llar_descriptor_skip_D_NVAUTF:

 ldr w9,[sp,#3072]
 cmp w9,#101
 b.eq .Llar_descriptor_skip_D_VCUICO

 LAR_DESC x20,7384,8,2

.Llar_descriptor_skip_D_VCUICO:

 ldr w9,[sp,#3072]
 cmp w9,#102
 b.ne .Llar_descriptor_skip_D_VSLD
 ldr x9,[x20,#312]
 lsl x9,x9,#1
 cbz x9,.Llar_descriptor_skip_D_VSLD

 LAR_DESC x20,7560,8,2

.Llar_descriptor_skip_D_VSLD:

 b .Llar_descriptor_skip_D_VSLDW

 LAR_DESC x20,7736,8,3

.Llar_descriptor_skip_D_VSLDW:

 ldr w9,[sp,#3072]
 cmp w9,#101
 b.eq .Llar_descriptor_skip_D_VSLVF
 ldr w9,[x20,#152]
 cbz w9,.Llar_descriptor_skip_D_VSLVF

 LAR_DESC x20,7960,8,3

.Llar_descriptor_skip_D_VSLVF:

 ldr w9,[sp,#3080]
 cmp w9,#3
 b.ne .Llar_descriptor_skip_D_GAMMA_WENO
 ldr x9,[sp,#3096]
 ldr w9,[x9,#16]
 cbnz w9,.Llar_descriptor_skip_D_GAMMA_WENO

 LAR_DESC x20,8184,8,2

.Llar_descriptor_skip_D_GAMMA_WENO:

 add x27,sp,#1536

 LAR_ARG x9,4
 LAR_PUT 1

 LAR_ARG x9,2
 LAR_PUT 6

 LAR_ARG x9,3
 LAR_PUT 7

 LAR_ARG x9,6
 LAR_PUT 10

 LAR_ARG x9,5
 LAR_PUT 14

 LAR_ARG x9,8
 LAR_PUT 15

 LAR_ARG x9,9
 LAR_PUT 16

 LAR_ARG x9,14
 LAR_PUT 26

 LAR_ARG x9,17
 LAR_PUT 34

 LAR_ARG x9,18
 LAR_PUT 44

 LAR_ARG x9,19
 LAR_PUT 45

 LAR_ARG x9,20
 LAR_PUT 46

 LAR_ARG x9,21
 LAR_PUT 47

 LAR_ARG x9,22
 LAR_PUT 48

 LAR_ARG x9,23
 LAR_PUT 49

 LAR_ARG x9,24
 LAR_PUT 50

 LAR_ARG x9,37
 LAR_PUT 63

 LAR_ARG x9,38
 LAR_PUT 64

 LAR_ARG x9,39
 LAR_PUT 65

 LAR_ARG x9,43
 LAR_PUT 66

 LAR_FIELD x9,x20,7120
 LAR_PUT 0

 LAR_FIELD x9,x20,0
 LAR_PUT 3

 LAR_FIELD x9,x19,5144
 LAR_PUT 4

 LAR_FIELD x9,x20,4668
 LAR_PUT 5

 LAR_FIELD x9,x19,5224
 LAR_PUT 8

 LAR_FIELD x9,x19,5244
 LAR_PUT 9

 LAR_FIELD x9,x20,100
 LAR_PUT 17

 LAR_FIELD x9,x20,1952
 LAR_PUT 18

 LAR_FIELD x9,x20,212
 LAR_PUT 19

 LAR_FIELD x9,x20,236
 LAR_PUT 20

 LAR_FIELD x9,x20,240
 LAR_PUT 21

 LAR_FIELD x9,x20,244
 LAR_PUT 22

 LAR_FIELD x9,x20,4660
 LAR_PUT 23

 LAR_FIELD x9,x19,7536
 LAR_PUT 24

 LAR_FIELD x9,x20,8336
 LAR_PUT 42

 LAR_FIELD x9,x20,8344
 LAR_PUT 43

 ldr x9,[sp,#3096]
 add x9,x9,#16
 LAR_PUT 2
 add x9,sp,#3072
 LAR_PUT 11
 add x9,sp,#3076
 LAR_PUT 12
 add x9,sp,#3080
 LAR_PUT 13
 /* Three source factors keep their separate rounding points. */
 LAR_FIELD x9,x19,7512
 ldr d0,[x9]
 fmov d1,#2.0
 fmul d0,d1,d0
 str d0,[sp,#3112]
 adrp x9,:got:__yomcst_MOD_rpi
 ldr x9,[x9,:got_lo12:__yomcst_MOD_rpi]
 ldr d0,[x9]
 fmul d2,d1,d0
 str d2,[sp,#3120]
 fmov d1,#0.5
 fmul d0,d1,d0
 str d0,[sp,#3088]
 add x9,sp,#3088
 LAR_PUT 25
 LAR_FIELD x9,x19,4808
 ldr x10,[x9,#48]
 ldr x9,[x9]
 sub x10,x25,x10
 add x9,x9,x10,lsl #3
 LAR_PUT 27
 ldr x9,[sp,#3104]
 ldr x9,[x9,#128]
 LAR_PUT 35

 LAR_FIELD x9,x20,8480
 ldr x9,[x9]
 LAR_PUT 28

 LAR_FIELD x9,x20,8568
 ldr x9,[x9]
 LAR_PUT 29

 LAR_FIELD x9,x20,8656
 ldr x9,[x9]
 LAR_PUT 30

 LAR_FIELD x9,x20,8768
 ldr x9,[x9]
 LAR_PUT 31

 LAR_FIELD x9,x20,8352
 ldr x9,[x9]
 LAR_PUT 36

 LAR_FIELD x9,x20,7384
 ldr x9,[x9]
 LAR_PUT 37

 LAR_FIELD x9,x20,7560
 ldr x9,[x9]
 LAR_PUT 38

 LAR_FIELD x9,x20,7736
 ldr x9,[x9]
 LAR_PUT 39

 LAR_FIELD x9,x20,7960
 ldr x9,[x9]
 LAR_PUT 40

 LAR_FIELD x9,x20,8184
 ldr x9,[x9]
 LAR_PUT 41

 LAR_VIEW 32,31,6812,1,6828

 LAR_VIEW 33,31,6816,1,6828

 LAR_VIEW 51,40,6452,1,6472

 LAR_VIEW 52,40,6464,1,6472

 LAR_VIEW 53,41,6520,3,6644

 LAR_VIEW 54,41,6556,3,6644

 LAR_VIEW 55,41,6576,3,6644

 LAR_VIEW 56,41,6608,3,6644

 LAR_VIEW 57,40,6448,4,6472

 LAR_VIEW 58,40,6460,4,6472

 LAR_VIEW 59,41,6504,6,6644

 LAR_VIEW 60,41,6540,6,6644

 LAR_VIEW 61,41,6572,6,6644

 LAR_VIEW 62,41,6592,6,6644

 LAR_VIEW 67,41,6640,3,6644

 LAR_VIEW 68,40,6456,1,6472

 LAR_VIEW 69,40,6468,1,6472

 LAR_VIEW 70,41,6536,9,6644

 LAR_VIEW 71,41,6580,3,6644

 LAR_VIEW 72,41,6584,3,6644

 LAR_VIEW 73,41,6588,9,6644

 LAR_VIEW 74,41,6624,3,6644

 LAR_VIEW 75,41,6628,4,6644

 LAR_VIEW 76,41,6632,4,6644

 LAR_VIEW 77,41,6636,4,6644

 /* Every whole writable owner has a distinct caller allocation. */
 add x14,sp,#3200
 mov x15,#0

 LAR_ARG x10,37
 lsl x11,x24,#1
 adds x11,x10,x11
 b.cs .Llar_bad
 stp x10,x11,[x14],#16
 add x15,x15,#1

 LAR_ARG x10,38
 lsl x11,x24,#1
 adds x11,x10,x11
 b.cs .Llar_bad
 stp x10,x11,[x14],#16
 add x15,x15,#1

 LAR_ARG x10,39
 lsr x11,x24,#1
 adds x11,x10,x11
 b.cs .Llar_bad
 stp x10,x11,[x14],#16
 add x15,x15,#1

 LAR_ARG x10,42
 lsr x11,x24,#1
 adds x11,x10,x11
 b.cs .Llar_bad
 stp x10,x11,[x14],#16
 add x15,x15,#1

 LAR_ARG x10,43
 lsr x11,x24,#1
 adds x11,x10,x11
 b.cs .Llar_bad
 stp x10,x11,[x14],#16
 add x15,x15,#1

 LAR_ARG x10,40
 LAR_FIELD x11,x20,6472
 ldrsw x11,[x11]
 mul x11,x11,x24
 adds x11,x10,x11
 b.cs .Llar_bad
 stp x10,x11,[x14],#16
 add x15,x15,#1

 LAR_ARG x10,41
 LAR_FIELD x11,x20,6644
 ldrsw x11,[x11]
 mul x11,x11,x24
 adds x11,x10,x11
 b.cs .Llar_bad
 stp x10,x11,[x14],#16
 add x15,x15,#1

 LAR_ARG x9,10
 ldr w9,[x9]
 cbz w9,.Llar_ranges_ready

 LAR_ARG x10,32
 adds x11,x10,x24
 b.cs .Llar_bad
 stp x10,x11,[x14],#16
 add x15,x15,#1

 LAR_ARG x10,33
 adds x11,x10,x24
 b.cs .Llar_bad
 stp x10,x11,[x14],#16
 add x15,x15,#1

 LAR_ARG x10,34
 adds x11,x10,x24
 b.cs .Llar_bad
 stp x10,x11,[x14],#16
 add x15,x15,#1

 LAR_ARG x10,35
 adds x11,x10,x24
 b.cs .Llar_bad
 stp x10,x11,[x14],#16
 add x15,x15,#1

.Llar_ranges_ready:
 add x14,sp,#3200
 mov x16,#0
.Llar_overlap_outer:
 add x13,x14,x16,lsl #4
 ldp x9,x10,[x13]
 add x17,x16,#1
.Llar_overlap_inner:
 cmp x17,x15
 b.hs .Llar_overlap_next
 add x13,x14,x17,lsl #4
 ldp x11,x12,[x13]
 cmp x9,x12
 b.hs .Llar_overlap_ok
 cmp x11,x10
 b.lo .Llar_bad
.Llar_overlap_ok:
 add x17,x17,#1
 b .Llar_overlap_inner
.Llar_overlap_next:
 add x16,x16,#1
 cmp x16,x15
 b.lo .Llar_overlap_outer
 LAR_ARG x10,0
 mov x11,#17096
 adds x1,x10,x11
 b.cs .Llar_bad
 mov x0,x10
 bl .Llar_readonly_overlap
 LAR_ARG x10,1
 mov x11,#13232
 adds x1,x10,x11
 b.cs .Llar_bad
 mov x0,x10
 bl .Llar_readonly_overlap
 LAR_ARG x10,4
 mov x11,#1800
 adds x1,x10,x11
 b.cs .Llar_bad
 mov x0,x10
 bl .Llar_readonly_overlap
 LAR_ARG x10,2
 mov x11,#4
 adds x1,x10,x11
 b.cs .Llar_bad
 mov x0,x10
 bl .Llar_readonly_overlap
 LAR_ARG x10,3
 mov x11,#4
 adds x1,x10,x11
 b.cs .Llar_bad
 mov x0,x10
 bl .Llar_readonly_overlap
 LAR_ARG x10,5
 mov x11,#4
 adds x1,x10,x11
 b.cs .Llar_bad
 mov x0,x10
 bl .Llar_readonly_overlap
 LAR_ARG x10,7
 mov x11,#4
 adds x1,x10,x11
 b.cs .Llar_bad
 mov x0,x10
 bl .Llar_readonly_overlap
 LAR_ARG x10,8
 mov x11,#4
 adds x1,x10,x11
 b.cs .Llar_bad
 mov x0,x10
 bl .Llar_readonly_overlap
 LAR_ARG x10,9
 mov x11,#4
 adds x1,x10,x11
 b.cs .Llar_bad
 mov x0,x10
 bl .Llar_readonly_overlap
 LAR_ARG x10,10
 mov x11,#4
 adds x1,x10,x11
 b.cs .Llar_bad
 mov x0,x10
 bl .Llar_readonly_overlap
 LAR_ARG x10,11
 mov x11,#4
 adds x1,x10,x11
 b.cs .Llar_bad
 mov x0,x10
 bl .Llar_readonly_overlap
 LAR_ARG x10,12
 mov x11,#4
 adds x1,x10,x11
 b.cs .Llar_bad
 mov x0,x10
 bl .Llar_readonly_overlap
 LAR_ARG x10,13
 mov x11,#4
 adds x1,x10,x11
 b.cs .Llar_bad
 mov x0,x10
 bl .Llar_readonly_overlap
 LAR_ARG x10,15
 mov x11,#4
 adds x1,x10,x11
 b.cs .Llar_bad
 mov x0,x10
 bl .Llar_readonly_overlap
 LAR_ARG x10,29
 mov x11,#4
 adds x1,x10,x11
 b.cs .Llar_bad
 mov x0,x10
 bl .Llar_readonly_overlap
 LAR_ARG x10,30
 mov x11,#4
 adds x1,x10,x11
 b.cs .Llar_bad
 mov x0,x10
 bl .Llar_readonly_overlap
 ldr x10,[sp,#3096]
 mov x11,#216
 adds x1,x10,x11
 b.cs .Llar_bad
 mov x0,x10
 bl .Llar_readonly_overlap
 ldr x10,[sp,#3104]
 mov x11,#320
 adds x1,x10,x11
 b.cs .Llar_bad
 mov x0,x10
 bl .Llar_readonly_overlap
 LAR_ARG x10,17
 mov x11,x24
 adds x1,x10,x11
 b.cs .Llar_bad
 mov x0,x10
 bl .Llar_readonly_overlap
 LAR_ARG x10,31
 LAR_FIELD x11,x20,6828
 ldrsw x11,[x11]
 mul x11,x11,x24
 adds x1,x10,x11
 b.cs .Llar_bad
 mov x0,x10
 bl .Llar_readonly_overlap
 LAR_ARG x10,6
 sub x11,x26,x25
 add x11,x11,#1
 lsl x11,x11,#2
 adds x1,x10,x11
 b.cs .Llar_bad
 mov x0,x10
 bl .Llar_readonly_overlap
 LAR_ARG x10,14
 sub x11,x26,x25
 add x11,x11,#1
 lsl x11,x11,#3
 adds x1,x10,x11
 b.cs .Llar_bad
 mov x0,x10
 bl .Llar_readonly_overlap
 LAR_DESC x19,4808,8,1
 LAR_FIELD x9,x19,4808
 ldr x10,[x9]
 mov x11,#8
 ldp x12,x13,[x9,#48]
 sub x13,x13,x12
 add x13,x13,#1
 mul x11,x11,x13
 adds x1,x10,x11
 b.cs .Llar_bad
 mov x0,x10
 bl .Llar_readonly_overlap
 ldr w9,[sp,#3072]
 cmp w9,#101
 b.eq .Llar_readonly_skip_D_RIPI
 LAR_DESC x20,8480,8,2
 LAR_FIELD x9,x20,8480
 ldr x10,[x9]
 mov x11,#8
 ldp x12,x13,[x9,#48]
 sub x13,x13,x12
 add x13,x13,#1
 mul x11,x11,x13
 ldp x12,x13,[x9,#72]
 sub x13,x13,x12
 add x13,x13,#1
 mul x11,x11,x13
 adds x1,x10,x11
 b.cs .Llar_bad
 mov x0,x10
 bl .Llar_readonly_overlap
.Llar_readonly_skip_D_RIPI:
 ldr w9,[sp,#3072]
 cmp w9,#102
 b.ne .Llar_readonly_skip_D_RSLD
 ldr x9,[x20,#320]
 lsl x9,x9,#1
 cbz x9,.Llar_readonly_skip_D_RSLD
 LAR_DESC x20,8568,8,2
 LAR_FIELD x9,x20,8568
 ldr x10,[x9]
 mov x11,#8
 ldp x12,x13,[x9,#48]
 sub x13,x13,x12
 add x13,x13,#1
 mul x11,x11,x13
 ldp x12,x13,[x9,#72]
 sub x13,x13,x12
 add x13,x13,#1
 mul x11,x11,x13
 adds x1,x10,x11
 b.cs .Llar_bad
 mov x0,x10
 bl .Llar_readonly_overlap
.Llar_readonly_skip_D_RSLD:
 b .Llar_readonly_skip_D_RSLDW
 LAR_DESC x20,8656,8,3
 LAR_FIELD x9,x20,8656
 ldr x10,[x9]
 mov x11,#8
 ldp x12,x13,[x9,#48]
 sub x13,x13,x12
 add x13,x13,#1
 mul x11,x11,x13
 ldp x12,x13,[x9,#72]
 sub x13,x13,x12
 add x13,x13,#1
 mul x11,x11,x13
 ldp x12,x13,[x9,#96]
 sub x13,x13,x12
 add x13,x13,#1
 mul x11,x11,x13
 adds x1,x10,x11
 b.cs .Llar_bad
 mov x0,x10
 bl .Llar_readonly_overlap
.Llar_readonly_skip_D_RSLDW:
 b .Llar_readonly_skip_D_R3DTW
 LAR_DESC x20,8768,8,3
 LAR_FIELD x9,x20,8768
 ldr x10,[x9]
 mov x11,#8
 ldp x12,x13,[x9,#48]
 sub x13,x13,x12
 add x13,x13,#1
 mul x11,x11,x13
 ldp x12,x13,[x9,#72]
 sub x13,x13,x12
 add x13,x13,#1
 mul x11,x11,x13
 ldp x12,x13,[x9,#96]
 sub x13,x13,x12
 add x13,x13,#1
 mul x11,x11,x13
 adds x1,x10,x11
 b.cs .Llar_bad
 mov x0,x10
 bl .Llar_readonly_overlap
.Llar_readonly_skip_D_R3DTW:
 LAR_DESC x20,8352,4,1
 LAR_FIELD x9,x20,8352
 ldr x10,[x9]
 mov x11,#4
 ldp x12,x13,[x9,#48]
 sub x13,x13,x12
 add x13,x13,#1
 mul x11,x11,x13
 adds x1,x10,x11
 b.cs .Llar_bad
 mov x0,x10
 bl .Llar_readonly_overlap
.Llar_readonly_skip_D_NVAUTF:
 ldr w9,[sp,#3072]
 cmp w9,#101
 b.eq .Llar_readonly_skip_D_VCUICO
 LAR_DESC x20,7384,8,2
 LAR_FIELD x9,x20,7384
 ldr x10,[x9]
 mov x11,#8
 ldp x12,x13,[x9,#48]
 sub x13,x13,x12
 add x13,x13,#1
 mul x11,x11,x13
 ldp x12,x13,[x9,#72]
 sub x13,x13,x12
 add x13,x13,#1
 mul x11,x11,x13
 adds x1,x10,x11
 b.cs .Llar_bad
 mov x0,x10
 bl .Llar_readonly_overlap
.Llar_readonly_skip_D_VCUICO:
 ldr w9,[sp,#3072]
 cmp w9,#102
 b.ne .Llar_readonly_skip_D_VSLD
 ldr x9,[x20,#312]
 lsl x9,x9,#1
 cbz x9,.Llar_readonly_skip_D_VSLD
 LAR_DESC x20,7560,8,2
 LAR_FIELD x9,x20,7560
 ldr x10,[x9]
 mov x11,#8
 ldp x12,x13,[x9,#48]
 sub x13,x13,x12
 add x13,x13,#1
 mul x11,x11,x13
 ldp x12,x13,[x9,#72]
 sub x13,x13,x12
 add x13,x13,#1
 mul x11,x11,x13
 adds x1,x10,x11
 b.cs .Llar_bad
 mov x0,x10
 bl .Llar_readonly_overlap
.Llar_readonly_skip_D_VSLD:
 b .Llar_readonly_skip_D_VSLDW
 LAR_DESC x20,7736,8,3
 LAR_FIELD x9,x20,7736
 ldr x10,[x9]
 mov x11,#8
 ldp x12,x13,[x9,#48]
 sub x13,x13,x12
 add x13,x13,#1
 mul x11,x11,x13
 ldp x12,x13,[x9,#72]
 sub x13,x13,x12
 add x13,x13,#1
 mul x11,x11,x13
 ldp x12,x13,[x9,#96]
 sub x13,x13,x12
 add x13,x13,#1
 mul x11,x11,x13
 adds x1,x10,x11
 b.cs .Llar_bad
 mov x0,x10
 bl .Llar_readonly_overlap
.Llar_readonly_skip_D_VSLDW:
 ldr w9,[sp,#3072]
 cmp w9,#101
 b.eq .Llar_readonly_skip_D_VSLVF
 ldr w9,[x20,#152]
 cbz w9,.Llar_readonly_skip_D_VSLVF
 LAR_DESC x20,7960,8,3
 LAR_FIELD x9,x20,7960
 ldr x10,[x9]
 mov x11,#8
 ldp x12,x13,[x9,#48]
 sub x13,x13,x12
 add x13,x13,#1
 mul x11,x11,x13
 ldp x12,x13,[x9,#72]
 sub x13,x13,x12
 add x13,x13,#1
 mul x11,x11,x13
 ldp x12,x13,[x9,#96]
 sub x13,x13,x12
 add x13,x13,#1
 mul x11,x11,x13
 adds x1,x10,x11
 b.cs .Llar_bad
 mov x0,x10
 bl .Llar_readonly_overlap
.Llar_readonly_skip_D_VSLVF:
 ldr w9,[sp,#3080]
 cmp w9,#3
 b.ne .Llar_readonly_skip_D_GAMMA_WENO
 ldr x9,[sp,#3096]
 ldr w9,[x9,#16]
 cbnz w9,.Llar_readonly_skip_D_GAMMA_WENO
 LAR_DESC x20,8184,8,2
 LAR_FIELD x9,x20,8184
 ldr x10,[x9]
 mov x11,#8
 ldp x12,x13,[x9,#48]
 sub x13,x13,x12
 add x13,x13,#1
 mul x11,x11,x13
 ldp x12,x13,[x9,#72]
 sub x13,x13,x12
 add x13,x13,#1
 mul x11,x11,x13
 adds x1,x10,x11
 b.cs .Llar_bad
 mov x0,x10
 bl .Llar_readonly_overlap
.Llar_readonly_skip_D_GAMMA_WENO:
 ldr x9,[sp,#3104]
 LAR_DESC x9,128,8,1
 LAR_FIELD x9,x9,128
 ldr x10,[x9]
 mov x11,#8
 ldp x12,x13,[x9,#48]
 sub x13,x13,x12
 add x13,x13,#1
 mul x11,x11,x13
 adds x1,x10,x11
 b.cs .Llar_bad
 mov x0,x10
 bl .Llar_readonly_overlap
 LAR_DESC x21,328,4,2
 LAR_FIELD x9,x21,328
 ldr x10,[x9]
 mov x11,#4
 ldp x12,x13,[x9,#48]
 sub x13,x13,x12
 add x13,x13,#1
 mul x11,x11,x13
 ldp x12,x13,[x9,#72]
 sub x13,x13,x12
 add x13,x13,#1
 mul x11,x11,x13
 adds x1,x10,x11
 b.cs .Llar_bad
 mov x0,x10
 bl .Llar_readonly_overlap
 LAR_DESC x21,1120,4,1
 LAR_FIELD x9,x21,1120
 ldr x10,[x9]
 mov x11,#4
 ldp x12,x13,[x9,#48]
 sub x13,x13,x12
 add x13,x13,#1
 mul x11,x11,x13
 adds x1,x10,x11
 b.cs .Llar_bad
 mov x0,x10
 bl .Llar_readonly_overlap
 LAR_FIELD x9,x20,228
 ldr w9,[x9]
 cbz w9,.Llar_ro_spline_done
 LAR_DESC x20,7272,8,3
 LAR_FIELD x9,x20,7272
 ldr x10,[x9]
 mov x11,#8
 ldp x12,x13,[x9,#48]
 sub x13,x13,x12
 add x13,x13,#1
 mul x11,x11,x13
 ldp x12,x13,[x9,#72]
 sub x13,x13,x12
 add x13,x13,#1
 mul x11,x11,x13
 ldp x12,x13,[x9,#96]
 sub x13,x13,x12
 add x13,x13,#1
 mul x11,x11,x13
 adds x1,x10,x11
 b.cs .Llar_bad
 mov x0,x10
 bl .Llar_readonly_overlap
.Llar_ro_spline_done:
 LAR_ARG x9,10
 ldr w9,[x9]
 cbz w9,.Llar_ro_wind_done
 LAR_ARG x10,25
 ldrsw x11,[x21,#1016]
 LAR_FIELD x12,x19,5248
 ldrsw x12,[x12]
 LAR_FIELD x13,x19,5244
 ldrsw x13,[x13]
 sub x12,x12,x13
 add x12,x12,#1
 mul x11,x11,x12
 lsl x11,x11,#3
 adds x1,x10,x11
 b.cs .Llar_bad
 mov x0,x10
 bl .Llar_readonly_overlap
 LAR_ARG x10,26
 ldrsw x11,[x21,#1016]
 LAR_FIELD x12,x19,5248
 ldrsw x12,[x12]
 LAR_FIELD x13,x19,5244
 ldrsw x13,[x13]
 sub x12,x12,x13
 add x12,x12,#1
 mul x11,x11,x12
 lsl x11,x11,#3
 adds x1,x10,x11
 b.cs .Llar_bad
 mov x0,x10
 bl .Llar_readonly_overlap
 LAR_ARG x10,27
 ldrsw x11,[x21,#1016]
 LAR_FIELD x12,x19,5248
 ldrsw x12,[x12]
 LAR_FIELD x13,x19,5244
 ldrsw x13,[x13]
 sub x12,x12,x13
 add x12,x12,#1
 mul x11,x11,x12
 lsl x11,x11,#3
 adds x1,x10,x11
 b.cs .Llar_bad
 mov x0,x10
 bl .Llar_readonly_overlap
 LAR_ARG x10,28
 ldrsw x11,[x21,#1016]
 LAR_FIELD x12,x19,5248
 ldrsw x12,[x12]
 LAR_FIELD x13,x19,5244
 ldrsw x13,[x13]
 sub x12,x12,x13
 add x12,x12,#1
 mul x11,x11,x12
 lsl x11,x11,#3
 adds x1,x10,x11
 b.cs .Llar_bad
 mov x0,x10
 bl .Llar_readonly_overlap
.Llar_ro_wind_done:
 /* Preserve the original complete child order, including an empty interval. */
 adrp x9,.Llar_parent_calls
 add x9,x9,:lo12:.Llar_parent_calls
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
 add x9,x27,#64
 mov x10,sp
 mov x11,#70
.Llar_stack:
 ldr x12,[x9],#8
 str x12,[x10],#8
 subs x11,x11,#1
 b.ne .Llar_stack
 ldp x0,x1,[x27]
 ldp x2,x3,[x27,#16]
 ldp x4,x5,[x27,#32]
 ldp x6,x7,[x27,#48]
 bl md2asm_larcina_lascaw_7240564
 LAR_ARG x9,10
 ldr w9,[x9]
 cbz w9,.Llar_done
 mov x22,#0
.Llar_components:
 add x9,x28,#200
 ldr x23,[x9,x22,lsl #3]
 add x9,x28,#256
 ldr x24,[x9,x22,lsl #3]
 LAR_FIELD x9,x20,328
 ldr w9,[x9]
 cbnz w9,.Llar_weno
 LAR_FIELD x9,x20,308
 ldr w9,[x9]
 cbnz w9,.Llar_cubic

 add x9,x21,#1016

 mov x0,x9

 ldr x9,[x27,#32]

 mov x1,x9

 ldr x9,[x27,#48]

 mov x2,x9

 ldr x9,[x27,#56]

 mov x3,x9

 ldr x9,[x27,#64]

 mov x4,x9

 ldr x9,[x27,#72]

 mov x5,x9

 LAR_FIELD x9,x19,5248

 mov x6,x9

 ldr x9,[x27,#408]

 mov x7,x9

 ldr x9,[x27,#8*57]
 mul x10,x22,xzr
 LAR_FIELD x10,x19,5144
 ldrsw x10,[x10]
 LAR_FIELD x11,x19,5224
 ldrsw x11,[x11]
 mul x10,x10,x11
 add x9,x9,x10,lsl #3

 str x9,[sp,#0]

 ldr x9,[x27,#8*63]
 LAR_FIELD x10,x19,5144
 ldrsw x10,[x10]
 LAR_FIELD x11,x19,5224
 ldrsw x11,[x11]
 mul x10,x10,x11
 add x9,x9,x10,lsl #2

 str x9,[sp,#8]

 ldr x9,[x27,#544]

 str x9,[sp,#16]

 mov x9,x23

 str x9,[sp,#24]

 mov x9,x24

 str x9,[sp,#32]

 bl md2asm_larcina_linear_7240564
 b .Llar_component_next

.Llar_cubic:

 add x9,x21,#1016

 mov x0,x9

 ldr x9,[x27,#32]

 mov x1,x9

 ldr x9,[x27,#48]

 mov x2,x9

 ldr x9,[x27,#56]

 mov x3,x9

 ldr x9,[x27,#64]

 mov x4,x9

 ldr x9,[x27,#72]

 mov x5,x9

 LAR_FIELD x9,x19,5248

 mov x6,x9

 LAR_FIELD x9,x20,4748

 mov x7,x9

 ldr x9,[x27,#408]

 str x9,[sp,#0]

 ldr x9,[x27,#424]

 str x9,[sp,#8]

 ldr x9,[x27,#456]

 str x9,[sp,#16]

 ldr x9,[x27,#472]

 str x9,[sp,#24]

 ldr x9,[x27,#504]

 str x9,[sp,#32]

 ldr x9,[x27,#560]

 str x9,[sp,#40]

 mov x9,x23

 str x9,[sp,#48]

 mov x9,x24

 str x9,[sp,#56]

 mov x9,xzr

 str x9,[sp,#64]

 mov x9,xzr

 str x9,[sp,#72]

 bl md2asm_larcina_cubic_7240564
 b .Llar_component_next

.Llar_weno:

 LAR_FIELD x9,x20,456

 mov x0,x9

 add x9,x21,#1016

 mov x1,x9

 ldr x9,[x27,#32]

 mov x2,x9

 ldr x9,[x27,#48]

 mov x3,x9

 ldr x9,[x27,#56]

 mov x4,x9

 ldr x9,[x27,#64]

 mov x5,x9

 ldr x9,[x27,#72]

 mov x6,x9

 LAR_FIELD x9,x19,5248

 mov x7,x9

 LAR_FIELD x9,x20,4748

 str x9,[sp,#0]

 ldr x9,[x27,#408]

 str x9,[sp,#8]

 ldr x9,[x27,#424]

 str x9,[sp,#16]

 ldr x9,[x27,#456]

 str x9,[sp,#24]

 ldr x9,[x27,#472]

 str x9,[sp,#32]

 ldr x9,[x27,#504]

 str x9,[sp,#40]

 ldr x9,[x27,#528]

 str x9,[sp,#48]

 ldr x9,[x27,#536]

 str x9,[sp,#56]

 ldr x9,[x27,#560]

 str x9,[sp,#64]

 mov x9,x23

 str x9,[sp,#72]

 mov x9,x24

 str x9,[sp,#80]

 mov x9,xzr

 str x9,[sp,#88]

 mov x9,xzr

 str x9,[sp,#96]

 mov x9,xzr

 str x9,[sp,#104]

 bl md2asm_larcina_weno_7240564
 b .Llar_component_next

.Llar_component_next:
 add x22,x22,#1
 cmp x22,#4
 b.lo .Llar_components
.Llar_done:
 add x17,sp,#3936
 ldp x18,x19,[x17]
 ldp x20,x21,[x17,#16]
 ldp x22,x23,[x17,#32]
 ldp x24,x25,[x17,#48]
 ldp x26,x27,[x17,#64]
 ldp x28,x29,[x17,#80]
 ldr x30,[x17,#96]
 add sp,sp,#1,lsl #12
 ret
.size md2asm_larcina_7240564,.-md2asm_larcina_7240564

.type .Llar_readonly_overlap,%function
.Llar_readonly_overlap:
 add x2,sp,#3200
 mov x3,#0
.Llar_readonly_loop:
 add x4,x2,x3,lsl #4
 ldp x5,x6,[x4]
 cmp x0,x6
 b.hs .Llar_readonly_next
 cmp x5,x1
 b.lo .Llar_bad
.Llar_readonly_next:
 add x3,x3,#1
 cmp x3,x15
 b.lo .Llar_readonly_loop
 ret
.size .Llar_readonly_overlap,.-.Llar_readonly_overlap
.Llar_bad:
 brk #0x31a
 b .Llar_bad
.ltorg

.p2align 4
.type md2asm_larcina_lascaw_7240564,%function
md2asm_larcina_lascaw_7240564:
 adrp x9,.Llar_lascaw_calls
 add x9,x9,:lo12:.Llar_lascaw_calls
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
 b md2asm_lascaw_7240564
.size md2asm_larcina_lascaw_7240564,.-md2asm_larcina_lascaw_7240564
.global md2asm_larcina_lascaw_calls_get
.type md2asm_larcina_lascaw_calls_get,%function
md2asm_larcina_lascaw_calls_get:
 adrp x9,.Llar_lascaw_calls
 ldr x0,[x9,:lo12:.Llar_lascaw_calls]
 ret
.size md2asm_larcina_lascaw_calls_get,.-md2asm_larcina_lascaw_calls_get

.p2align 4
.type md2asm_larcina_linear_7240564,%function
md2asm_larcina_linear_7240564:
 adrp x9,.Llar_linear_calls
 add x9,x9,:lo12:.Llar_linear_calls
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
 b laitli_assembly_
.size md2asm_larcina_linear_7240564,.-md2asm_larcina_linear_7240564
.global md2asm_larcina_linear_calls_get
.type md2asm_larcina_linear_calls_get,%function
md2asm_larcina_linear_calls_get:
 adrp x9,.Llar_linear_calls
 ldr x0,[x9,:lo12:.Llar_linear_calls]
 ret
.size md2asm_larcina_linear_calls_get,.-md2asm_larcina_linear_calls_get

.p2align 4
.type md2asm_larcina_cubic_7240564,%function
md2asm_larcina_cubic_7240564:
 adrp x9,.Llar_cubic_calls
 add x9,x9,:lo12:.Llar_cubic_calls
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
 b laitri_assembly_
.size md2asm_larcina_cubic_7240564,.-md2asm_larcina_cubic_7240564
.global md2asm_larcina_cubic_calls_get
.type md2asm_larcina_cubic_calls_get,%function
md2asm_larcina_cubic_calls_get:
 adrp x9,.Llar_cubic_calls
 ldr x0,[x9,:lo12:.Llar_cubic_calls]
 ret
.size md2asm_larcina_cubic_calls_get,.-md2asm_larcina_cubic_calls_get

.p2align 4
.type md2asm_larcina_weno_7240564,%function
md2asm_larcina_weno_7240564:
 adrp x9,.Llar_weno_calls
 add x9,x9,:lo12:.Llar_weno_calls
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
 b md2asm_laitri_weno
.size md2asm_larcina_weno_7240564,.-md2asm_larcina_weno_7240564
.global md2asm_larcina_weno_calls_get
.type md2asm_larcina_weno_calls_get,%function
md2asm_larcina_weno_calls_get:
 adrp x9,.Llar_weno_calls
 ldr x0,[x9,:lo12:.Llar_weno_calls]
 ret
.size md2asm_larcina_weno_calls_get,.-md2asm_larcina_weno_calls_get

.global md2asm_larcina_calls_get
.type md2asm_larcina_calls_get,%function
md2asm_larcina_calls_get:
 adrp x9,.Llar_parent_calls
 ldr x0,[x9,:lo12:.Llar_parent_calls]
 ret
.size md2asm_larcina_calls_get,.-md2asm_larcina_calls_get
.bss
.p2align 3
.Llar_parent_calls: .zero 8
.Llar_lascaw_calls: .zero 8
.Llar_linear_calls: .zero 8
.Llar_cubic_calls: .zero 8
.Llar_weno_calls: .zero 8
.section .note.GNU-stack,"",%progbits

/* Original normal entry for the selected complete native route. */
.global larcina_
.type larcina_,%function
.set larcina_,md2asm_larcina_7240564
