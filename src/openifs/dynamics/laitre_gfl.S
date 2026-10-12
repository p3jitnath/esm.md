/* Atmospheric constituent interpolation dispatch, revision 1.
 * Physics input is formulations/openifs/dynamics/departure_field_transport.md.
 * The frozen forecast uses native three-dimensional and WENO interpolation.
 * Supported selector paths and unsupported prewrite guards are in the contract.
 * The interface has 23 pointer arguments and a hidden 12-byte string length.
 */
.text
.p2align 4
.macro GFL_ARG reg,n
 ldr \reg,[sp,#(128+8*\n)]
.endm
.macro GFL_PLANE dst,base,count,ndim
 cmp w9,#1
 b.lt .Lgfl_bad
 ldr w10,[x19,#\ndim]
 add w11,w9,#(\count-1)
 cmp w11,w10
 b.hi .Lgfl_bad
 sub w9,w9,#1
 uxtw x9,w9
 madd \dst,x9,x20,\base
.endm
.global md2asm_laitre_gfl_7259755
.type md2asm_laitre_gfl_7259755,%function
md2asm_laitre_gfl_7259755:
 mrs x9,fpcr
 cbnz x9,.Lgfl_bad
 mov x16,sp
 sub sp,sp,#1024
 add x17,sp,#960
 stp x19,x20,[x17]
 stp x21,x22,[x17,#16]
 stp x23,x24,[x17,#32]
 stp x29,x30,[x17,#48]
 mov x29,sp
 stp x0,x1,[sp,#128]
 stp x2,x3,[sp,#144]
 stp x4,x5,[sp,#160]
 stp x6,x7,[sp,#176]

 ldp x9,x10,[x16,#0]
 stp x9,x10,[sp,#192]

 ldp x9,x10,[x16,#16]
 stp x9,x10,[sp,#208]

 ldp x9,x10,[x16,#32]
 stp x9,x10,[sp,#224]

 ldp x9,x10,[x16,#48]
 stp x9,x10,[sp,#240]

 ldp x9,x10,[x16,#64]
 stp x9,x10,[sp,#256]

 ldp x9,x10,[x16,#80]
 stp x9,x10,[sp,#272]

 ldp x9,x10,[x16,#96]
 stp x9,x10,[sp,#288]

 ldp x9,x10,[x16,#112]
 stp x9,x10,[sp,#304]

 GFL_ARG x9,23
 cmp x9,#12
 b.ne .Lgfl_bad
 GFL_ARG x19,2
 cbz x19,.Lgfl_bad
 tst x19,#7
 b.ne .Lgfl_bad
 GFL_ARG x9,4
 ldrsw x11,[x9]
 cmp x11,#1
 b.lt .Lgfl_bad
 GFL_ARG x9,5
 ldrsw x12,[x9]
 cmp x12,#1
 b.lt .Lgfl_bad
 cmp x12,#1024
 b.gt .Lgfl_bad
 GFL_ARG x9,8
 ldrsw x13,[x9]
 cmp x13,#4
 b.lt .Lgfl_bad
 cmp x13,#256
 b.gt .Lgfl_bad
 mul x20,x12,x13
 lsl x20,x20,#3
 GFL_ARG x9,6
 ldrsw x14,[x9]
 cmp x14,#1
 b.lt .Lgfl_bad
 add x15,x12,#1
 cmp x14,x15
 b.gt .Lgfl_bad
 GFL_ARG x9,7
 ldrsw x15,[x9]
 cmp x15,#0
 b.lt .Lgfl_bad
 cmp x15,x12
 b.gt .Lgfl_bad
 GFL_ARG x9,9
 ldrsw x14,[x9]
 GFL_ARG x9,10
 ldrsw x15,[x9]
 sub x15,x15,x14
 add x15,x15,#1
 cmp x15,#1
 b.lt .Lgfl_bad
 mul x15,x15,x11
 mov x9,#0x7fffffff
 cmp x15,x9
 b.gt .Lgfl_bad
 GFL_ARG x9,12
 ldrsw x24,[x9]
 cmp x24,#1
 b.lt .Lgfl_bad
 cmp x24,#4
 b.gt .Lgfl_bad
 sub x24,x24,#1
 ldr w9,[x19,#6472]
 cmp w9,#1
 b.lt .Lgfl_bad
 ldr w9,[x19,#6644]
 cmp w9,#1
 b.lt .Lgfl_bad
 GFL_ARG x9,15
 ldr w9,[x9]
 cmp w9,#1
 b.hi .Lgfl_bad
 GFL_ARG x21,18
 GFL_ARG x22,19
 GFL_ARG x9,13
 cbz x9,.Lgfl_bad
 ldr x23,[x9]
 ldr w24,[x9,#8]

 movz x9,#16716

 movk x9,#21577,lsl #16

 movk x9,#19793,lsl #32

 movk x9,#21288,lsl #48

 cmp x23,x9
 b.ne .Lgfl_name_next_0

 movz w9,#17484

 movk w9,#8233,lsl #16

 cmp w24,w9
 b.eq .Lgfl_name_0
.Lgfl_name_next_0:

 movz x9,#16716

 movk x9,#21577,lsl #16

 movk x9,#19793,lsl #32

 movk x9,#10312,lsl #48

 cmp x23,x9
 b.ne .Lgfl_name_next_1

 movz w9,#19539

 movk w9,#10564,lsl #16

 cmp w24,w9
 b.eq .Lgfl_name_1
.Lgfl_name_next_1:

 movz x9,#16716

 movk x9,#21577,lsl #16

 movk x9,#18770,lsl #32

 movk x9,#21288,lsl #48

 cmp x23,x9
 b.ne .Lgfl_name_next_2

 movz w9,#17484

 movk w9,#8233,lsl #16

 cmp w24,w9
 b.eq .Lgfl_name_2
.Lgfl_name_next_2:

 movz x9,#16716

 movk x9,#21577,lsl #16

 movk x9,#19793,lsl #32

 movk x9,#19752,lsl #48

 cmp x23,x9
 b.ne .Lgfl_name_next_3

 movz w9,#17473

 movk w9,#8233,lsl #16

 cmp w24,w9
 b.eq .Lgfl_name_3
.Lgfl_name_next_3:

 movz x9,#16716

 movk x9,#21577,lsl #16

 movk x9,#19793,lsl #32

 movk x9,#10291,lsl #48

 cmp x23,x9
 b.ne .Lgfl_name_next_4

 movz w9,#16717

 movk w9,#10564,lsl #16

 cmp w24,w9
 b.eq .Lgfl_name_4
.Lgfl_name_next_4:

 movz x9,#16716

 movk x9,#21577,lsl #16

 movk x9,#19793,lsl #32

 movk x9,#10316,lsl #48

 cmp x23,x9
 b.ne .Lgfl_name_next_5

 movz w9,#16717

 movk w9,#10564,lsl #16

 cmp w24,w9
 b.eq .Lgfl_name_5
.Lgfl_name_next_5:

 movz x9,#16716

 movk x9,#21577,lsl #16

 movk x9,#19793,lsl #32

 movk x9,#10312,lsl #48

 cmp x23,x9
 b.ne .Lgfl_name_next_6

 movz w9,#16717

 movk w9,#10564,lsl #16

 cmp w24,w9
 b.eq .Lgfl_name_6
.Lgfl_name_next_6:

 movz x9,#16716

 movk x9,#21577,lsl #16

 movk x9,#18770,lsl #32

 movk x9,#19752,lsl #48

 cmp x23,x9
 b.ne .Lgfl_name_next_7

 movz w9,#17473

 movk w9,#8233,lsl #16

 cmp w24,w9
 b.eq .Lgfl_name_7
.Lgfl_name_next_7:

 movz x9,#16716

 movk x9,#21577,lsl #16

 movk x9,#19793,lsl #32

 movk x9,#17459,lsl #48

 cmp x23,x9
 b.ne .Lgfl_name_next_8

 movz w9,#8224

 movk w9,#8224,lsl #16

 cmp w24,w9
 b.eq .Lgfl_name_8
.Lgfl_name_next_8:

 movz x9,#16716

 movk x9,#21577,lsl #16

 movk x9,#19793,lsl #32

 movk x9,#13132,lsl #48

 cmp x23,x9
 b.ne .Lgfl_name_next_9

 movz w9,#8260

 movk w9,#8224,lsl #16

 cmp w24,w9
 b.eq .Lgfl_name_9
.Lgfl_name_next_9:

 movz x9,#16716

 movk x9,#21577,lsl #16

 movk x9,#19793,lsl #32

 movk x9,#8224,lsl #48

 cmp x23,x9
 b.ne .Lgfl_name_next_10

 movz w9,#8224

 movk w9,#8224,lsl #16

 cmp w24,w9
 b.eq .Lgfl_name_10
.Lgfl_name_next_10:

 movz x9,#16716

 movk x9,#21577,lsl #16

 movk x9,#19793,lsl #32

 movk x9,#8264,lsl #48

 cmp x23,x9
 b.ne .Lgfl_name_next_11

 movz w9,#8224

 movk w9,#8224,lsl #16

 cmp w24,w9
 b.eq .Lgfl_name_11
.Lgfl_name_next_11:

 movz x9,#16716

 movk x9,#21577,lsl #16

 movk x9,#18770,lsl #32

 movk x9,#8224,lsl #48

 cmp x23,x9
 b.ne .Lgfl_name_next_12

 movz w9,#8224

 movk w9,#8224,lsl #16

 cmp w24,w9
 b.eq .Lgfl_name_12
.Lgfl_name_next_12:

 movz x9,#16716

 movk x9,#21577,lsl #16

 movk x9,#22354,lsl #32

 movk x9,#20037,lsl #48

 cmp x23,x9
 b.ne .Lgfl_name_next_13

 movz w9,#20815

 movk w9,#8269,lsl #16

 cmp w24,w9
 b.eq .Lgfl_name_13
.Lgfl_name_next_13:

 movz x9,#16716

 movk x9,#21577,lsl #16

 movk x9,#22354,lsl #32

 movk x9,#20037,lsl #48

 cmp x23,x9
 b.ne .Lgfl_name_next_14

 movz w9,#20815

 movk w9,#18509,lsl #16

 cmp w24,w9
 b.eq .Lgfl_name_14
.Lgfl_name_next_14:

 movz x9,#16716

 movk x9,#21577,lsl #16

 movk x9,#22354,lsl #32

 movk x9,#20037,lsl #48

 cmp x23,x9
 b.ne .Lgfl_name_next_15

 movz w9,#8271

 movk w9,#8224,lsl #16

 cmp w24,w9
 b.eq .Lgfl_name_15
.Lgfl_name_next_15:

 b .Lgfl_bad

.Lgfl_name_0:
 mov w9,#2
 str w9,[sp,#384]

 mov w9,#1
 str w9,[sp,#388]

 b .Lgfl_sld

.Lgfl_name_1:
 mov w9,#1
 str w9,[sp,#384]

 mov w9,#1
 str w9,[sp,#388]

 b .Lgfl_sld

.Lgfl_name_2:
 mov w9,#0
 str w9,[sp,#384]

 mov w9,#1
 str w9,[sp,#388]

 b .Lgfl_sld

.Lgfl_name_3:
 mov w9,#2
 str w9,[sp,#384]

 mov w9,#1
 str w9,[sp,#388]

 b .Lgfl_mad

.Lgfl_name_4:
 mov w9,#2
 str w9,[sp,#384]

 mov w9,#3
 str w9,[sp,#388]

 b .Lgfl_mad

.Lgfl_name_5:
 mov w9,#1
 str w9,[sp,#384]

 mov w9,#3
 str w9,[sp,#388]

 b .Lgfl_mad

.Lgfl_name_6:
 mov w9,#1
 str w9,[sp,#384]

 mov w9,#1
 str w9,[sp,#388]

 b .Lgfl_mad

.Lgfl_name_7:
 mov w9,#0
 str w9,[sp,#384]

 mov w9,#1
 str w9,[sp,#388]

 b .Lgfl_mad

.Lgfl_name_8:
 mov w9,#2
 str w9,[sp,#384]

 mov w9,#3
 str w9,[sp,#388]

 b .Lgfl_normal

.Lgfl_name_9:
 mov w9,#1
 str w9,[sp,#384]

 mov w9,#3
 str w9,[sp,#388]

 b .Lgfl_normal

.Lgfl_name_10:
 mov w9,#2
 str w9,[sp,#384]

 mov w9,#1
 str w9,[sp,#388]

 b .Lgfl_normal

.Lgfl_name_11:
 mov w9,#1
 str w9,[sp,#384]

 mov w9,#1
 str w9,[sp,#388]

 b .Lgfl_normal

.Lgfl_name_12:
 mov w9,#0
 str w9,[sp,#384]

 mov w9,#1
 str w9,[sp,#388]

 b .Lgfl_normal

.Lgfl_name_13:
 mov w9,#2
 str w9,[sp,#384]

 mov w9,#2
 str w9,[sp,#388]

 b .Lgfl_normal

.Lgfl_name_14:
 mov w9,#1
 str w9,[sp,#384]

 mov w9,#2
 str w9,[sp,#388]

 b .Lgfl_normal

.Lgfl_name_15:
 mov w9,#0
 str w9,[sp,#384]

 mov w9,#2
 str w9,[sp,#388]

 b .Lgfl_normal

.Lgfl_sld:
 GFL_ARG x9,15
 ldr w9,[x9]
 cbz w9,.Lgfl_sld_heat

 mov w9,#6452
 str w9,[sp,#448]

 mov w9,#6448
 str w9,[sp,#452]

 mov w9,#6556
 str w9,[sp,#456]

 mov w9,#6540
 str w9,[sp,#460]

 mov w9,#6580
 str w9,[sp,#468]

 mov w9,#6456
 str w9,[sp,#476]

 mov w9,#0
 str w9,[sp,#464]
 b .Lgfl_coefficients

.Lgfl_sld_heat:

 mov w9,#6452
 str w9,[sp,#448]

 mov w9,#6448
 str w9,[sp,#452]

 mov w9,#6576
 str w9,[sp,#456]

 mov w9,#6572
 str w9,[sp,#460]

 mov w9,#6584
 str w9,[sp,#468]

 mov w9,#6456
 str w9,[sp,#476]

 mov w9,#1
 str w9,[sp,#464]
 b .Lgfl_coefficients

.Lgfl_mad:

 mov w9,#6464
 str w9,[sp,#448]

 mov w9,#6460
 str w9,[sp,#452]

 mov w9,#6608
 str w9,[sp,#456]

 mov w9,#6592
 str w9,[sp,#460]

 mov w9,#6624
 str w9,[sp,#468]

 mov w9,#6468
 str w9,[sp,#476]

 mov w9,#0
 str w9,[sp,#464]
 b .Lgfl_coefficients

.Lgfl_normal:

 mov w9,#6452
 str w9,[sp,#448]

 mov w9,#6448
 str w9,[sp,#452]

 mov w9,#6520
 str w9,[sp,#456]

 mov w9,#6504
 str w9,[sp,#460]

 mov w9,#6536
 str w9,[sp,#468]

 mov w9,#6456
 str w9,[sp,#476]

 mov w9,#0
 str w9,[sp,#464]
 b .Lgfl_coefficients

 .Lgfl_coefficients:
 GFL_ARG x24,12
 ldr w24,[x24]
 sub w24,w24,#1
 ldr w9,[sp,#448]
 ldr w9,[x19,x9]
 GFL_PLANE x14,x21,1,6472
 str x14,[sp,#400]
 ldr w9,[sp,#452]
 ldr w9,[x19,x9]
 GFL_PLANE x14,x21,4,6472
 str x14,[sp,#416]
 ldr w10,[sp,#464]
 ldr w9,[sp,#456]
 cbnz w10,.Lgfl_cla_scalar
 add w9,w9,w24,lsl #2
.Lgfl_cla_scalar:
 ldr w9,[x19,x9]
 GFL_PLANE x14,x22,3,6644
 str x14,[sp,#408]
 ldr w10,[sp,#464]
 ldr w9,[sp,#460]
 cbnz w10,.Lgfl_clo_scalar
 add w9,w9,w24,lsl #2
.Lgfl_clo_scalar:
 ldr w9,[x19,x9]
 GFL_PLANE x14,x22,6,6644
 str x14,[sp,#424]
 ldr w10,[sp,#388]
 cmp w10,#2
 b.eq .Lgfl_weno_coefficients
 ldr w9,[sp,#468]
 ldr w9,[x19,x9]
 GFL_PLANE x14,x22,3,6644
 str x14,[sp,#432]
 ldr w10,[sp,#388]
 cmp w10,#3
 b.eq .Lgfl_qm3d_coefficients
 b .Lgfl_call_cubic
.Lgfl_weno_coefficients:
 ldr w9,[sp,#468]
 ldr w9,[x19,x9]
 GFL_PLANE x14,x22,9,6644
 str x14,[sp,#432]
 ldr w9,[x19,#6640]
 GFL_PLANE x14,x22,3,6644
 str x14,[sp,#440]
 b .Lgfl_call_weno
.Lgfl_qm3d_coefficients:
 ldr w9,[sp,#476]
 ldr w9,[x19,x9]
 GFL_PLANE x14,x21,1,6472
 str x14,[sp,#480]
 GFL_ARG x9,1
 cbz x9,.Lgfl_bad
 tst x9,#7
 b.ne .Lgfl_bad
 add x9,x9,#264
 ldr w10,[x9]
 cmp w10,#1
 b.hi .Lgfl_bad
 str x9,[sp,#488]
 GFL_ARG x9,0
 cbz x9,.Lgfl_bad
 tst x9,#7
 b.ne .Lgfl_bad
 ldr x9,[x9,#3248]
 cbz x9,.Lgfl_bad
 tst x9,#7
 b.ne .Lgfl_bad
 str x9,[sp,#496]
 b .Lgfl_call_qm3d

.Lgfl_call_cubic:

 mov w9,#0
 str w9,[sp,#392]

 GFL_ARG x9,4

 mov x0,x9

 GFL_ARG x9,5

 mov x1,x9

 GFL_ARG x9,6

 mov x2,x9

 GFL_ARG x9,7

 mov x3,x9

 GFL_ARG x9,8

 mov x4,x9

 GFL_ARG x9,9

 mov x5,x9

 GFL_ARG x9,10

 mov x6,x9

 add x9,sp,#384

 mov x7,x9

 ldr x9,[sp,#400]

 str x9,[sp,#0]

 ldr x9,[sp,#408]

 str x9,[sp,#8]

 ldr x9,[sp,#416]

 str x9,[sp,#16]

 ldr x9,[sp,#424]

 str x9,[sp,#24]

 GFL_ARG x9,17

 str x9,[sp,#32]

 ldr x9,[sp,#432]

 str x9,[sp,#40]

 GFL_ARG x9,20

 str x9,[sp,#48]

 GFL_ARG x9,21

 str x9,[sp,#56]

 mov x9,xzr

 str x9,[sp,#64]

 mov x9,xzr

 str x9,[sp,#72]

 bl laitri_assembly_
 b .Lgfl_done

.Lgfl_call_qm3d:

 mov w9,#1
 str w9,[sp,#392]

 ldr x9,[sp,#496]

 mov x0,x9

 ldr x9,[sp,#488]

 mov x1,x9

 GFL_ARG x9,4

 mov x2,x9

 GFL_ARG x9,5

 mov x3,x9

 GFL_ARG x9,6

 mov x4,x9

 GFL_ARG x9,7

 mov x5,x9

 GFL_ARG x9,8

 mov x6,x9

 GFL_ARG x9,9

 mov x7,x9

 GFL_ARG x9,10

 str x9,[sp,#0]

 add x9,sp,#384

 str x9,[sp,#8]

 ldr x9,[sp,#400]

 str x9,[sp,#16]

 ldr x9,[sp,#408]

 str x9,[sp,#24]

 ldr x9,[sp,#416]

 str x9,[sp,#32]

 ldr x9,[sp,#424]

 str x9,[sp,#40]

 GFL_ARG x9,17

 str x9,[sp,#48]

 ldr x9,[sp,#432]

 str x9,[sp,#56]

 ldr x9,[sp,#480]

 str x9,[sp,#64]

 GFL_ARG x9,20

 str x9,[sp,#72]

 GFL_ARG x9,21

 str x9,[sp,#80]

 bl md2asm_laitriqm3d_complete_status_7259755
 b .Lgfl_done

.Lgfl_call_weno:

 mov w9,#2
 str w9,[sp,#392]

 add x9,x19,#456

 mov x0,x9

 GFL_ARG x9,4

 mov x1,x9

 GFL_ARG x9,5

 mov x2,x9

 GFL_ARG x9,6

 mov x3,x9

 GFL_ARG x9,7

 mov x4,x9

 GFL_ARG x9,8

 mov x5,x9

 GFL_ARG x9,9

 mov x6,x9

 GFL_ARG x9,10

 mov x7,x9

 add x9,sp,#384

 str x9,[sp,#0]

 ldr x9,[sp,#400]

 str x9,[sp,#8]

 ldr x9,[sp,#408]

 str x9,[sp,#16]

 ldr x9,[sp,#416]

 str x9,[sp,#24]

 ldr x9,[sp,#424]

 str x9,[sp,#32]

 GFL_ARG x9,17

 str x9,[sp,#40]

 GFL_ARG x9,16

 str x9,[sp,#48]

 ldr x9,[sp,#440]

 str x9,[sp,#56]

 ldr x9,[sp,#432]

 str x9,[sp,#64]

 GFL_ARG x9,20

 str x9,[sp,#72]

 GFL_ARG x9,21

 str x9,[sp,#80]

 GFL_ARG x9,14

 str x9,[sp,#88]

 mov x9,xzr

 str x9,[sp,#96]

 mov x9,xzr

 str x9,[sp,#104]

 bl md2asm_laitri_weno
 b .Lgfl_done

 .Lgfl_done:
 adrp x9,.Lgfl_parent_calls
 add x9,x9,:lo12:.Lgfl_parent_calls
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
 ldr w11,[sp,#392]
 add x9,x9,#8
 ldr x10,[x9,x11,lsl #3]
 add x10,x10,#1
 str x10,[x9,x11,lsl #3]
 add x17,sp,#960
 ldp x19,x20,[x17]
 ldp x21,x22,[x17,#16]
 ldp x23,x24,[x17,#32]
 ldp x29,x30,[x17,#48]
 add sp,sp,#1024
 ret
.size md2asm_laitre_gfl_7259755,.-md2asm_laitre_gfl_7259755
.Lgfl_bad:
 brk #0x32b
 b .Lgfl_bad
.global laitre_gfl_
.type laitre_gfl_,%function
.set laitre_gfl_,md2asm_laitre_gfl_7259755

.global md2asm_laitre_gfl_calls_get
.type md2asm_laitre_gfl_calls_get,%function
md2asm_laitre_gfl_calls_get:
 adrp x9,.Lgfl_parent_calls
 add x9,x9,:lo12:.Lgfl_parent_calls
 ldr x0,[x9,#0]
 ret
.size md2asm_laitre_gfl_calls_get,.-md2asm_laitre_gfl_calls_get

.global md2asm_laitre_gfl_cubic_calls_get
.type md2asm_laitre_gfl_cubic_calls_get,%function
md2asm_laitre_gfl_cubic_calls_get:
 adrp x9,.Lgfl_parent_calls
 add x9,x9,:lo12:.Lgfl_parent_calls
 ldr x0,[x9,#8]
 ret
.size md2asm_laitre_gfl_cubic_calls_get,.-md2asm_laitre_gfl_cubic_calls_get

.global md2asm_laitre_gfl_qm3d_calls_get
.type md2asm_laitre_gfl_qm3d_calls_get,%function
md2asm_laitre_gfl_qm3d_calls_get:
 adrp x9,.Lgfl_parent_calls
 add x9,x9,:lo12:.Lgfl_parent_calls
 ldr x0,[x9,#16]
 ret
.size md2asm_laitre_gfl_qm3d_calls_get,.-md2asm_laitre_gfl_qm3d_calls_get

.global md2asm_laitre_gfl_weno_calls_get
.type md2asm_laitre_gfl_weno_calls_get,%function
md2asm_laitre_gfl_weno_calls_get:
 adrp x9,.Lgfl_parent_calls
 add x9,x9,:lo12:.Lgfl_parent_calls
 ldr x0,[x9,#24]
 ret
.size md2asm_laitre_gfl_weno_calls_get,.-md2asm_laitre_gfl_weno_calls_get

.bss
.p2align 3
.Lgfl_parent_calls: .zero 32
.section .note.GNU-stack,"",%progbits
