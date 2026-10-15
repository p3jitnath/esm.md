/* Direct selected STEPO body from OpenIFS 48.1.1.
 * Physics formulations/openifs/dynamics/forecast_time_step.md.
 * Contract skills/md2asm/references/openifs/dynamics/forecast_time_step.md.
 * Original interface, private entries and frozen arithmetic are preserved. */
.arch armv8-a
.text
.p2align 4
.macro GLOBAL r,name
 adrp \r,:got:\name
 ldr \r,[\r,:got_lo12:\name]
.endm
.macro MODEL r,offset
 movz x16,#(\offset & 65535)
 movk x16,#(\offset >> 16),lsl #16
 add \r,x22,x16
.endm
.macro GUARD name,value
 GLOBAL x9,\name
 ldr w9,[x9]
 cmp w9,#\value
 b.ne .Lst_bad
.endm
.macro PROFILE phase
 GLOBAL x9,__yomhook_MOD_lhook
 ldr w9,[x9]
 cbz w9,91f
 adrp x0,.Lst_name
 add x0,x0,:lo12:.Lst_name
 adrp x1,.Lst_phase_\phase
 add x1,x1,:lo12:.Lst_phase_\phase
 add x2,sp,#448
 mov x3,#5
 bl __yomhook_MOD_dr_hook_default8
91:
.endm
.global md2asm_stepo_output_r2_7358525
.type md2asm_stepo_output_r2_7358525,%function
md2asm_stepo_output_r2_7358525:
 mov x17,sp
 sub sp,sp,#1280
 stp x18,x30,[sp,#80]
 stp x19,x20,[sp,#96]
 stp x21,x22,[sp,#112]
 stp x23,x24,[sp,#128]
 stp x25,x26,[sp,#144]
 stp x27,x28,[sp,#160]
 str x29,[sp,#176]
 str x0,[sp,#256]
 str x1,[sp,#264]
 str x2,[sp,#272]
 str x3,[sp,#280]
 str x4,[sp,#288]
 str x5,[sp,#296]
 str x6,[sp,#304]
 str x7,[sp,#312]
 ldr x9,[x17,#0]
 str x9,[sp,#320]
 ldr x9,[x17,#8]
 str x9,[sp,#328]
 ldr x9,[x17,#16]
 str x9,[sp,#336]
 ldr x9,[x17,#24]
 str x9,[sp,#344]
 ldr x9,[x17,#32]
 str x9,[sp,#352]
 mrs x9,fpcr
 cbnz x9,.Lst_bad
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 mov x23,x4
 ldr x9,[sp,#352]
 cmp x9,#9
 b.ne .Lst_bad
 GUARD __yomct0_MOD_nconf,1
 GUARD __yomct0_MOD_lelam,0
 GUARD __yomct0_MOD_lr2d,0
 GUARD __yommp0_MOD_nproc,1
 GUARD __yomrlx_MOD_lrlxg,0
 GUARD __yomiau_MOD_liau,0
 MODEL x9,1570400
 ldr w9,[x9]
 cbnz w9,.Lst_bad
 MODEL x9,1535608
 ldr w9,[x9]
 cbnz w9,.Lst_bad
 MODEL x9,1552928
 ldr w9,[x9]
 cbnz w9,.Lst_bad
 MODEL x9,1567168
 ldr w9,[x9]
 cbnz w9,.Lst_bad
 MODEL x9,4233012
 ldr w9,[x9]
 cbnz w9,.Lst_bad
 MODEL x9,4233020
 ldr w9,[x9]
 cbnz w9,.Lst_bad
 MODEL x9,4233024
 ldr w9,[x9]
 cbnz w9,.Lst_bad
 MODEL x9,1359328
 ldr w9,[x9]
 cbnz w9,.Lst_bad
 MODEL x9,1359332
 ldr w9,[x9]
 cmp w9,#25
 b.ne .Lst_bad
 GLOBAL x9,__yomct3_MOD_nstep
 ldr w24,[x9]
 cmp w24,#24
 b.hi .Lst_bad
 ldrb w9,[x23]
 cmp w9,#65
 b.eq .Lst_first_ok
 cmp w9,#48
 b.ne .Lst_bad
.Lst_first_ok:
 ldrb w9,[x23,#1]
 cmp w9,#65
 b.ne .Lst_bad
 ldrb w9,[x23,#2]
 cmp w9,#65
 b.ne .Lst_bad
 ldrb w9,[x23,#3]
 cmp w9,#65
 b.ne .Lst_bad
 ldrb w9,[x23,#4]
 cmp w9,#48
 b.ne .Lst_bad
 ldrb w9,[x23,#5]
 cmp w9,#48
 b.ne .Lst_bad
 ldrb w9,[x23,#6]
 cmp w9,#65
 b.ne .Lst_bad
 ldrb w9,[x23,#7]
 cmp w9,#65
 b.ne .Lst_bad
 ldrb w9,[x23,#8]
 cmp w9,#65
 b.ne .Lst_bad
 ldr x9,[sp,#336]
 ldr x10,[sp,#344]
 cmp x9,#0
 cset w9,ne
 cmp x10,#0
 cset w10,ne
 and w9,w9,w10
 str w9,[sp,#432]
 mov w9,#1
 str w9,[sp,#436]
 str wzr,[sp,#440]
 GLOBAL x9,__yomtraj_MOD_trajec
 ldr x10,[x9]
 cbz x10,.Lst_bad
 ldr x11,[x9,#16]
 cmp x11,#512
 b.ne .Lst_bad
 ldrb w11,[x9,#28]
 cmp w11,#1
 b.ne .Lst_bad
 ldr x11,[x9,#48]
 cmp x24,x11
 b.lt .Lst_bad
 ldr x12,[x9,#56]
 cmp x24,x12
 b.gt .Lst_bad
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 madd x11,x12,x24,x11
 mov x12,#512
 madd x25,x11,x12,x10
 str x25,[sp,#456]
 PROFILE 0
 add x0,sp,#400
 mov x1,#0
 add x2,sp,#408
 add x3,sp,#416
 bl user_clock_
 GLOBAL x9,__yomtim_MOD_rstart
 ldr d0,[sp,#416]
 ldr d1,[x9]
 fsub d0,d0,d1
 str d0,[sp,#416]
 fadd d1,d1,d0
 str d1,[x9]
 GLOBAL x9,__yomtim_MOD_rvstart
 ldr d0,[sp,#408]
 ldr d1,[x9]
 fsub d0,d0,d1
 str d0,[sp,#408]
 fadd d1,d1,d0
 str d1,[x9]
 GLOBAL x9,__yomtim_MOD_rtimef
 ldr d0,[sp,#400]
 ldr d1,[x9]
 fsub d0,d0,d1
 str d0,[sp,#400]
 fadd d1,d1,d0
 str d1,[x9]
 // The source logarithm controls text frequency, not a weather field.
 adrp x9,.Lst_twentyfive
 ldr d0,[x9,:lo12:.Lst_twentyfive]
 bl log10
 fcvtzs w9,d0
 add w9,w9,#1
 cmp w9,#2
 b.ne .Lst_bad
 // The frozen 25-step schedule gives IJUM1.
 GLOBAL x0,__yomct3_MOD_nstep
 mov x1,x23
 mov x2,#9
 bl md2asm_step_log_
 GLOBAL x9,__yomct0_MOD_lopdis
 ldr w9,[x9]
 cbz w9,.Lst_no_opdis
 mov x0,x23
 adrp x1,.Lst_name
 add x1,x1,:lo12:.Lst_name
 add x2,sp,#416
 add x3,sp,#408
 add x4,sp,#400
 GLOBAL x5,__yomtim_MOD_rstart
 GLOBAL x6,__yomtim_MOD_rtimef
 GLOBAL x7,__yomct3_MOD_nstep
 MODEL x9,1564144
 str x9,[sp]
 mov x9,#9
 str x9,[sp,#8]
 mov x9,#5
 str x9,[sp,#16]
 bl opdis_
.Lst_no_opdis:
 ldrb w9,[x23]
 cmp w9,#48
 b.eq .Lst_no_iopack
 mov x0,x19
 mov x1,x20
 add x2,x21,#1560
 mov x3,x22
 mov x4,x23
 mov x5,#0
 mov x6,#0
 mov x7,#1
 bl md2asm_iopack_7358525
.Lst_no_iopack:
 mov x0,x19
 add x1,x20,#3416
 add x2,x20,#1856
 movz x16,#38096
 movk x16,#64,lsl #16
 add x3,x22,x16
 add x4,x22,#8
 movz x16,#56808
 movk x16,#23,lsl #16
 add x5,x22,x16
 movz x16,#59396
 movk x16,#23,lsl #16
 add x6,x22,x16
 movz x16,#59632
 movk x16,#23,lsl #16
 add x7,x22,x16
 mov x9,x23
 str x9,[sp,#0]
 movz x16,#22736
 movk x16,#0,lsl #16
 add x9,x20,x16
 str x9,[sp,#8]
 mov x9,x21
 str x9,[sp,#16]
 add x9,sp,#432
 str x9,[sp,#24]
 mov x9,#9
 str x9,[sp,#32]
 bl md2asm_transinvh_7358525
 ldr x25,[sp,#456]
 mov x0,x19
 mov x1,x20
 mov x2,x21
 mov x3,x22
 mov x4,x23
 add x5,sp,#436
 add x6,sp,#440
 movz x16,#22736
 movk x16,#0,lsl #16
 add x7,x20,x16
 mov x9,x25
 str x9,[sp,#0]
 ldr x9,[sp,#320]
 str x9,[sp,#8]
 ldr x9,[sp,#336]
 str x9,[sp,#16]
 ldr x9,[sp,#344]
 str x9,[sp,#24]
 ldr x9,[sp,#328]
 str x9,[sp,#32]
 mov x9,#9
 str x9,[sp,#40]
 bl md2asm_scan2m_output_r2_7358525
 ldrb w9,[x23,#7]
 strb w9,[sp,#444]
 mov x0,x19
 movz x16,#57008
 movk x16,#23,lsl #16
 add x1,x22,x16
 add x2,x20,#3416
 add x3,x20,#1856
 add x4,sp,#444
 add x5,x22,#16
 movz x16,#22736
 movk x16,#0,lsl #16
 add x6,x20,x16
 mov x7,#1
 bl md2asm_transdirh_7358525
 mov x0,x19
 mov x1,x22
 add x2,x23,#8
 movz x16,#22736
 movk x16,#0,lsl #16
 add x3,x20,x16
 add x4,x20,#1856
 mov x5,#1
 bl md2asm_spectral_calculation_driver_7358525
 PROFILE 1
 adrp x9,.Lmd_counts
 add x9,x9,:lo12:.Lmd_counts
 ldr x10,[x9,#0]
 add x10,x10,#1
 str x10,[x9,#0]
 ldp x18,x30,[sp,#80]
 ldp x19,x20,[sp,#96]
 ldp x21,x22,[sp,#112]
 ldp x23,x24,[sp,#128]
 ldp x25,x26,[sp,#144]
 ldp x27,x28,[sp,#160]
 ldr x29,[sp,#176]
 add sp,sp,#1280
 ret
.size md2asm_stepo_output_r2_7358525,.-md2asm_stepo_output_r2_7358525

.global md2asm_stepo_output_r2_count_get
.type md2asm_stepo_output_r2_count_get,%function
md2asm_stepo_output_r2_count_get:
 adrp x9,.Lmd_counts
 ldr x0,[x9,:lo12:.Lmd_counts]
 ret
.Lst_bad:
 mov w0,#108
 bl _exit
 brk #0
.data
.p2align 3
.Lmd_counts: .quad 0
.section .rodata
.p2align 3
.Lst_twentyfive: .double 25.0
.Lst_phase_0: .word 0
.Lst_phase_1: .word 1
.Lst_name: .ascii "STEPO"
.section .note.GNU-stack,"",%progbits
