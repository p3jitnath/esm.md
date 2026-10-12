/* General model field interpolation dispatch, numerical revision 1.
 * Physical input is formulations/openifs/dynamics/departure_field_transport.md.
 * This complete source-derived dispatcher calls accepted native children.
 * There are 23 ordinary pointers and no hidden character length.
 * Inputs stay unchanged and each output retains its caller's unit.
 */
.text
.p2align 4
.macro GMV_ARG reg,n
 ldr \reg,[sp,#(128+8*\n)]
.endm
.macro GMV_PLANE dst,base,count,ndim
 cmp w9,#1
 b.lt .Lgmv_bad
 ldr w10,[x19,#\ndim]
 add w11,w9,#(\count-1)
 cmp w11,w10
 b.hi .Lgmv_bad
 sub w9,w9,#1
 uxtw x9,w9
 madd \dst,x9,x20,\base
.endm
.global md2asm_laitre_gmv_7259755
.type md2asm_laitre_gmv_7259755,%function
md2asm_laitre_gmv_7259755:
 mrs x9,fpcr
 cbnz x9,.Lgmv_bad
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

 ldr x9,[x16,#112]
 str x9,[sp,#304]
 GMV_ARG x19,0
 cbz x19,.Lgmv_bad
 tst x19,#7
 b.ne .Lgmv_bad
 GMV_ARG x9,1
 ldrsw x11,[x9]
 cmp x11,#1
 b.lt .Lgmv_bad
 GMV_ARG x9,2
 ldrsw x12,[x9]
 cmp x12,#1
 b.lt .Lgmv_bad
 cmp x12,#1024
 b.gt .Lgmv_bad
 GMV_ARG x9,5
 ldrsw x13,[x9]
 cmp x13,#4
 b.lt .Lgmv_bad
 cmp x13,#256
 b.gt .Lgmv_bad
 mul x20,x12,x13
 lsl x20,x20,#3
 GMV_ARG x9,3
 ldrsw x14,[x9]
 cmp x14,#1
 b.lt .Lgmv_bad
 add x15,x12,#1
 cmp x14,x15
 b.gt .Lgmv_bad
 GMV_ARG x9,4
 ldrsw x15,[x9]
 cmp x15,#0
 b.lt .Lgmv_bad
 cmp x15,x12
 b.gt .Lgmv_bad
 GMV_ARG x9,6
 ldrsw x14,[x9]
 GMV_ARG x9,7
 ldrsw x15,[x9]
 sub x15,x15,x14
 add x15,x15,#1
 cmp x15,#1
 b.lt .Lgmv_bad
 mul x15,x15,x11
 mov x9,#0x7fffffff
 cmp x15,x9
 b.gt .Lgmv_bad
 GMV_ARG x9,8
 ldrsw x24,[x9]
 cmp x24,#1
 b.lt .Lgmv_bad
 cmp x24,#4
 b.gt .Lgmv_bad
 sub x24,x24,#1
 ldr w9,[x19,#6472]
 cmp w9,#1
 b.lt .Lgmv_bad
 ldr w9,[x19,#6644]
 cmp w9,#1
 b.lt .Lgmv_bad

 GMV_ARG x9,9
 ldr w9,[x9]
 cmp w9,#1
 b.hi .Lgmv_bad

 GMV_ARG x9,10
 ldr w9,[x9]
 cmp w9,#1
 b.hi .Lgmv_bad

 GMV_ARG x9,11
 ldr w9,[x9]
 cmp w9,#1
 b.hi .Lgmv_bad

 GMV_ARG x9,12
 ldr w9,[x9]
 cmp w9,#1
 b.hi .Lgmv_bad

 GMV_ARG x9,14
 ldr w9,[x9]
 cmp w9,#1
 b.hi .Lgmv_bad

 GMV_ARG x9,15
 ldr w9,[x9]
 cmp w9,#1
 b.hi .Lgmv_bad

 GMV_ARG x9,16
 ldr w9,[x9]
 cmp w9,#1
 b.hi .Lgmv_bad

 GMV_ARG x21,19
 GMV_ARG x22,20
 GMV_ARG x9,15
 ldr w9,[x9]
 mov w10,#2
 cbnz w9,.Lgmv_qm
 GMV_ARG x9,16
 ldr w10,[x9]
.Lgmv_qm:
 str w10,[sp,#384]
 ldr w23,[x19,#6536]
 GMV_ARG x9,14
 ldr w9,[x9]
 cbnz w9,.Lgmv_im
 ldr w9,[x19,#152]
 cmp w9,#1
 b.hi .Lgmv_bad
 cbz w9,.Lgmv_im
 ldr w23,[x19,#6588]
.Lgmv_im:
 GMV_ARG x9,9
 ldr w9,[x9]
 cbnz w9,.Lgmv_linear
 /* Default horizontal coefficient fields and vertical selection. */
 mov w9,#6452
 str w9,[sp,#448]
 mov w9,#6448
 str w9,[sp,#452]
 mov w9,#6520
 str w9,[sp,#456]
 mov w9,#6504
 str w9,[sp,#460]
 str wzr,[sp,#464]
 str w23,[sp,#468]
 GMV_ARG x9,12
 ldr w9,[x9]
 add w9,w9,#1
 str w9,[sp,#472]
 GMV_ARG x9,11
 ldr w9,[x9]
 cbnz w9,.Lgmv_slhd
 GMV_ARG x9,10
 ldr w9,[x9]
 cbnz w9,.Lgmv_mad
 b .Lgmv_coefficients
.Lgmv_slhd:
 GMV_ARG x9,14
 ldr w9,[x9]
 cbz w9,.Lgmv_slhd_heat
 mov w9,#6556
 str w9,[sp,#456]
 mov w9,#6540
 str w9,[sp,#460]
 GMV_ARG x9,12
 ldr w9,[x9]
 cbnz w9,.Lgmv_slhd_wind_weno
 ldr w9,[x19,#6580]
 str w9,[sp,#468]
 b .Lgmv_coefficients
.Lgmv_slhd_wind_weno:
 ldr w9,[x19,#6536]
 str w9,[sp,#468]
 b .Lgmv_coefficients
.Lgmv_slhd_heat:
 mov w9,#6576
 str w9,[sp,#456]
 mov w9,#6572
 str w9,[sp,#460]
 mov w9,#1
 str w9,[sp,#464]
 GMV_ARG x9,12
 ldr w9,[x9]
 cbnz w9,.Lgmv_coefficients
 ldr w9,[x19,#6584]
 str w9,[sp,#468]
 b .Lgmv_coefficients
.Lgmv_mad:
 mov w9,#6464
 str w9,[sp,#448]
 mov w9,#6460
 str w9,[sp,#452]
 mov w9,#6608
 str w9,[sp,#456]
 mov w9,#6592
 str w9,[sp,#460]
 ldr w9,[x19,#6624]
 str w9,[sp,#468]
 mov w9,#1
 str w9,[sp,#472]
.Lgmv_coefficients:
 ldr w9,[sp,#448]
 ldr w9,[x19,x9]
 GMV_PLANE x14,x21,1,6472
 str x14,[sp,#400]
 ldr w9,[sp,#452]
 ldr w9,[x19,x9]
 GMV_PLANE x14,x21,4,6472
 str x14,[sp,#416]
 ldr w10,[sp,#464]
 ldr w9,[sp,#456]
 cbnz w10,.Lgmv_cla_scalar
 add w9,w9,w24,lsl #2
.Lgmv_cla_scalar:
 ldr w9,[x19,x9]
 GMV_PLANE x14,x22,3,6644
 str x14,[sp,#408]
 ldr w10,[sp,#464]
 ldr w9,[sp,#460]
 cbnz w10,.Lgmv_clo_scalar
 add w9,w9,w24,lsl #2
.Lgmv_clo_scalar:
 ldr w9,[x19,x9]
 GMV_PLANE x14,x22,6,6644
 str x14,[sp,#424]
 ldr w10,[sp,#472]
 cmp w10,#2
 b.eq .Lgmv_weno_coefficients
 ldr w9,[sp,#468]
 GMV_PLANE x14,x22,3,6644
 str x14,[sp,#432]
 b .Lgmv_call_cubic
.Lgmv_weno_coefficients:
 ldr w9,[sp,#468]
 GMV_PLANE x14,x22,9,6644
 str x14,[sp,#432]
 ldr w9,[x19,#6640]
 GMV_PLANE x14,x22,3,6644
 str x14,[sp,#440]
 b .Lgmv_call_weno
.Lgmv_linear:
 GMV_ARG x9,10
 ldr w9,[x9]
 cbnz w9,.Lgmv_linear_mad

 ldr w9,[x19,#6452]

 GMV_PLANE x14,x21,1,6472
 str x14,[sp,#400]

 ldr w9,[x19,#6448]

 add w9,w9,#1

 GMV_PLANE x14,x21,2,6472
 str x14,[sp,#416]

 ldr w9,[x19,#6456]

 GMV_PLANE x14,x21,1,6472
 str x14,[sp,#432]

 b .Lgmv_call_linear
.Lgmv_linear_mad:

 ldr w9,[x19,#6464]

 GMV_PLANE x14,x21,1,6472
 str x14,[sp,#400]

 ldr w9,[x19,#6460]

 add w9,w9,#1

 GMV_PLANE x14,x21,2,6472
 str x14,[sp,#416]

 ldr w9,[x19,#6468]

 GMV_PLANE x14,x21,1,6472
 str x14,[sp,#432]

 b .Lgmv_call_linear

.Lgmv_call_linear:

 mov w9,#0
 str w9,[sp,#388]

 GMV_ARG x9,1

 mov x0,x9

 GMV_ARG x9,2

 mov x1,x9

 GMV_ARG x9,3

 mov x2,x9

 GMV_ARG x9,4

 mov x3,x9

 GMV_ARG x9,5

 mov x4,x9

 GMV_ARG x9,6

 mov x5,x9

 GMV_ARG x9,7

 mov x6,x9

 ldr x9,[sp,#400]

 mov x7,x9

 ldr x9,[sp,#416]

 str x9,[sp,#0]

 GMV_ARG x9,18
 add x9,x9,x20,lsr #1

 str x9,[sp,#8]

 ldr x9,[sp,#432]

 str x9,[sp,#16]

 GMV_ARG x9,21

 str x9,[sp,#24]

 GMV_ARG x9,22

 str x9,[sp,#32]

 bl laitli_assembly_
 b .Lgmv_done

.Lgmv_call_cubic:

 mov w9,#1
 str w9,[sp,#388]

 GMV_ARG x9,1

 mov x0,x9

 GMV_ARG x9,2

 mov x1,x9

 GMV_ARG x9,3

 mov x2,x9

 GMV_ARG x9,4

 mov x3,x9

 GMV_ARG x9,5

 mov x4,x9

 GMV_ARG x9,6

 mov x5,x9

 GMV_ARG x9,7

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

 GMV_ARG x9,18

 str x9,[sp,#32]

 ldr x9,[sp,#432]

 str x9,[sp,#40]

 GMV_ARG x9,21

 str x9,[sp,#48]

 GMV_ARG x9,22

 str x9,[sp,#56]

 mov x9,xzr

 str x9,[sp,#64]

 mov x9,xzr

 str x9,[sp,#72]

 bl laitri_assembly_
 b .Lgmv_done

.Lgmv_call_weno:

 mov w9,#2
 str w9,[sp,#388]

 add x9,x19,#456

 mov x0,x9

 GMV_ARG x9,1

 mov x1,x9

 GMV_ARG x9,2

 mov x2,x9

 GMV_ARG x9,3

 mov x3,x9

 GMV_ARG x9,4

 mov x4,x9

 GMV_ARG x9,5

 mov x5,x9

 GMV_ARG x9,6

 mov x6,x9

 GMV_ARG x9,7

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

 GMV_ARG x9,18

 str x9,[sp,#40]

 GMV_ARG x9,17

 str x9,[sp,#48]

 ldr x9,[sp,#440]

 str x9,[sp,#56]

 ldr x9,[sp,#432]

 str x9,[sp,#64]

 GMV_ARG x9,21

 str x9,[sp,#72]

 GMV_ARG x9,22

 str x9,[sp,#80]

 GMV_ARG x9,13

 str x9,[sp,#88]

 mov x9,xzr

 str x9,[sp,#96]

 mov x9,xzr

 str x9,[sp,#104]

 bl md2asm_laitri_weno
 b .Lgmv_done

.Lgmv_done:
 adrp x9,.Lgmv_parent_calls
 add x9,x9,:lo12:.Lgmv_parent_calls
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
 ldr w11,[sp,#388]
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
.size md2asm_laitre_gmv_7259755,.-md2asm_laitre_gmv_7259755
.Lgmv_bad:
 brk #0x32a
 b .Lgmv_bad
.global laitre_gmv_
.type laitre_gmv_,%function
.set laitre_gmv_,md2asm_laitre_gmv_7259755

.global md2asm_laitre_gmv_calls_get
.type md2asm_laitre_gmv_calls_get,%function
md2asm_laitre_gmv_calls_get:
 adrp x9,.Lgmv_parent_calls
 add x9,x9,:lo12:.Lgmv_parent_calls
 ldr x0,[x9,#0]
 ret
.size md2asm_laitre_gmv_calls_get,.-md2asm_laitre_gmv_calls_get

.global md2asm_laitre_gmv_linear_calls_get
.type md2asm_laitre_gmv_linear_calls_get,%function
md2asm_laitre_gmv_linear_calls_get:
 adrp x9,.Lgmv_parent_calls
 add x9,x9,:lo12:.Lgmv_parent_calls
 ldr x0,[x9,#8]
 ret
.size md2asm_laitre_gmv_linear_calls_get,.-md2asm_laitre_gmv_linear_calls_get

.global md2asm_laitre_gmv_cubic_calls_get
.type md2asm_laitre_gmv_cubic_calls_get,%function
md2asm_laitre_gmv_cubic_calls_get:
 adrp x9,.Lgmv_parent_calls
 add x9,x9,:lo12:.Lgmv_parent_calls
 ldr x0,[x9,#16]
 ret
.size md2asm_laitre_gmv_cubic_calls_get,.-md2asm_laitre_gmv_cubic_calls_get

.global md2asm_laitre_gmv_weno_calls_get
.type md2asm_laitre_gmv_weno_calls_get,%function
md2asm_laitre_gmv_weno_calls_get:
 adrp x9,.Lgmv_parent_calls
 add x9,x9,:lo12:.Lgmv_parent_calls
 ldr x0,[x9,#24]
 ret
.size md2asm_laitre_gmv_weno_calls_get,.-md2asm_laitre_gmv_weno_calls_get

.bss
.p2align 3
.Lgmv_parent_calls: .zero 32
.section .note.GNU-stack,"",%progbits
