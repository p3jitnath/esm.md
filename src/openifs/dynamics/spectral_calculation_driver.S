// Original routine SPCM. Direct AArch64 assembly.
// Physics formulations/openifs/dynamics/spectral_calculation_driver.md.
// Contract skills/md2asm/references/openifs/dynamics/spectral_calculation_driver.md.
// Supported 19-level, 506-coefficient route on one process.
// Full allocated buffers and source metadata follow the frozen contract.
.text
.p2align 4
.macro REC reg,base,off
 movz \reg,#(\off & 65535)
 movk \reg,#((\off >> 16) & 65535),lsl #16
 add \reg,\base,\reg
.endm
.macro CALL name
 str x18,[sp,#392]
 bl \name
 ldr x18,[sp,#392]
.endm
.macro PLACE index
 .if \index<8
  mov x\index,x9
 .else
  str x9,[sp,#((\index-8)*8)]
 .endif
.endm
.macro STAT section,event
 mov w9,#\section
 str w9,[sp,#436]
 mov w9,#\event
 str w9,[sp,#440]
 add x0,sp,#436
 add x1,sp,#440
 CALL gstats_
.endm
.global md2asm_spectral_calculation_driver_7358525
.type md2asm_spectral_calculation_driver_7358525,%function
md2asm_spectral_calculation_driver_7358525:
 sub sp,sp,#2048
 stp x19,x20,[sp,#192]
 stp x21,x22,[sp,#208]
 stp x23,x24,[sp,#224]
 stp x25,x26,[sp,#240]
 stp x27,x28,[sp,#256]
 stp x29,x30,[sp,#272]
 str x18,[sp,#288]
 stp x0,x1,[sp,#320]
 stp x2,x3,[sp,#336]
 str x4,[sp,#352]
 cmp x5,#1
 b.ne .Lscm_reject
 ldrb w9,[x2]
 str w9,[sp,#400]
 cmp w9,#65
 b.eq .Lscm_configuration_valid
 cmp w9,#73
 b.eq .Lscm_configuration_valid
 cmp w9,#48
 b.ne .Lscm_reject
.Lscm_configuration_valid:
 mov x19,x0
 mov x20,x1
 mov x21,x3
 mrs x9,fpcr
 cbnz x9,.Lscm_reject
 ldr w9,[x19,#5200]
 cmp w9,#506
 b.ne .Lscm_reject
 ldr w9,[x19,#7212]
 cmp w9,#506
 b.ne .Lscm_reject
 ldr w9,[x19,#7216]
 cmp w9,#506
 b.ne .Lscm_reject
 ldr w9,[x19,#7208]
 cmp w9,#1
 b.ne .Lscm_reject
 ldr w9,[x19,#5224]
 cmp w9,#19
 b.ne .Lscm_reject
 ldr w9,[x19,#5228]
 cmp w9,#19
 b.ne .Lscm_reject
 ldr w9,[x19,#5236]
 cmp w9,#19
 b.ne .Lscm_reject
 ldr w9,[x19,#5172]
 cmp w9,#21
 b.ne .Lscm_reject
 ldr w9,[x19,#5212]
 cmp w9,#22
 b.ne .Lscm_reject
 REC x9,x20,1569172
 ldr w10,[x9]
 cmp w10,#0
 b.ne .Lscm_reject
 REC x9,x20,1569164
 ldr w10,[x9]
 cmp w10,#0
 b.ne .Lscm_reject
 REC x9,x20,1569036
 ldr w10,[x9]
 cmp w10,#1
 b.ne .Lscm_reject
 REC x9,x20,1567068
 ldr w10,[x9]
 cmp w10,#0
 b.ne .Lscm_reject
 REC x9,x20,1567168
 ldr w10,[x9]
 cmp w10,#0
 b.ne .Lscm_reject
 REC x9,x20,1567180
 ldr w10,[x9]
 cmp w10,#0
 b.ne .Lscm_reject
 REC x9,x20,4233020
 ldr w10,[x9]
 cmp w10,#0
 b.ne .Lscm_reject
 REC x9,x20,1564144
 ldr w10,[x9]
 cmp w10,#0
 b.ne .Lscm_reject
 REC x9,x20,1564176
 ldr w10,[x9]
 cmp w10,#0
 b.ne .Lscm_reject
 REC x9,x20,1564136
 ldr w10,[x9]
 cmp w10,#0
 b.ne .Lscm_reject
 REC x9,x20,1564140
 ldr w10,[x9]
 cmp w10,#0
 b.ne .Lscm_reject
 REC x9,x20,1564336
 ldr w10,[x9]
 cmp w10,#1
 b.ne .Lscm_reject
 adrp x9,:got:__yommp0_MOD_nprtrn
 ldr x9,[x9,:got_lo12:__yommp0_MOD_nprtrn]
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Lscm_reject
 adrp x9,:got:__yommp0_MOD_nprtrv
 ldr x9,[x9,:got_lo12:__yommp0_MOD_nprtrv]
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Lscm_reject
 adrp x9,:got:__yomct0_MOD_lr3d
 ldr x9,[x9,:got_lo12:__yomct0_MOD_lr3d]
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Lscm_reject
 adrp x9,:got:__yomhook_MOD_lhook
 ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
 ldr w9,[x9]
 cmp w9,#1
 b.hi .Lscm_reject
 str w9,[sp,#376]
 cbz w9,.Lscm_entry_hook_done
 adr x0,.Lscm_hook_name
 add x1,sp,#380
 str wzr,[x1]
 add x2,sp,#384
 mov x3,#4
 CALL __yomhook_MOD_dr_hook_default8
.Lscm_entry_hook_done:
 str wzr,[sp,#404]
 mov w9,#1
 str w9,[sp,#408]
 mov w9,#506
 str w9,[sp,#412]
 mov w9,#-999
 str w9,[sp,#416]
 str w9,[sp,#420]
 movz x0,#(546504 & 65535)
 movk x0,#(546504 >> 16),lsl #16
 CALL malloc
 cbz x0,.Lscm_reject
 mov x22,x0
 add x0,sp,#512
 movz x9,#0
 movk x9,#0,lsl #16
 add x1,x22,x9
 mov x2,#1
 mov x3,#506
 mov x4,#1
 bl .Lscm_make_descriptor
 add x0,sp,#600
 movz x9,#4048
 movk x9,#0,lsl #16
 add x1,x22,x9
 mov x2,#2
 mov x3,#19
 mov x4,#506
 bl .Lscm_make_descriptor
 add x0,sp,#688
 movz x9,#15424
 movk x9,#1,lsl #16
 add x1,x22,x9
 mov x2,#2
 mov x3,#19
 mov x4,#506
 bl .Lscm_make_descriptor
 add x0,sp,#776
 movz x9,#26800
 movk x9,#2,lsl #16
 add x1,x22,x9
 mov x2,#2
 mov x3,#19
 mov x4,#506
 bl .Lscm_make_descriptor
 add x0,sp,#864
 movz x9,#38176
 movk x9,#3,lsl #16
 add x1,x22,x9
 mov x2,#2
 mov x3,#19
 mov x4,#506
 bl .Lscm_make_descriptor
 add x0,sp,#952
 movz x9,#49552
 movk x9,#4,lsl #16
 add x1,x22,x9
 mov x2,#2
 mov x3,#19
 mov x4,#506
 bl .Lscm_make_descriptor
 add x0,sp,#1040
 movz x9,#60928
 movk x9,#5,lsl #16
 add x1,x22,x9
 mov x2,#1
 mov x3,#506
 mov x4,#1
 bl .Lscm_make_descriptor
 add x0,sp,#1128
 movz x9,#64976
 movk x9,#5,lsl #16
 add x1,x22,x9
 mov x2,#2
 mov x3,#19
 mov x4,#506
 bl .Lscm_make_descriptor
 add x0,sp,#1216
 movz x9,#10816
 movk x9,#7,lsl #16
 add x1,x22,x9
 mov x2,#2
 mov x3,#19
 mov x4,#506
 bl .Lscm_make_descriptor
 add x0,sp,#1304
 movz x9,#22192
 movk x9,#8,lsl #16
 add x1,x22,x9
 mov x2,#2
 mov x3,#1
 mov x4,#1
 bl .Lscm_make_descriptor
 add x0,sp,#1392
 movz x9,#22200
 movk x9,#8,lsl #16
 add x1,x22,x9
 mov x2,#2
 mov x3,#1
 mov x4,#1
 bl .Lscm_make_descriptor
 add x0,sp,#1480
 movz x9,#22208
 movk x9,#8,lsl #16
 add x1,x22,x9
 mov x2,#2
 mov x3,#1
 mov x4,#1
 bl .Lscm_make_descriptor
 ldr x9,[x21,#2400]
 ldr x10,[sp,#512]
 mov x11,#506
.Lscm_copy_initial_pressure:
 ldr x12,[x9],#8
 str x12,[x10],#8
 subs x11,x11,#1
 b.ne .Lscm_copy_initial_pressure
 ldr w9,[sp,#400]
 cmp w9,#48
 b.eq .Lscm_store_pressure
 STAT 9,0
 STAT 1022,0
 mov x23,#0
.Lscm_coriolis_prepare:
 // MYMS is a 1-based dense integer table. NASM0 is zero-based.
 ldr x9,[x19,#3912]
 ldr w10,[x9,x23,lsl #2]
 str w10,[sp,#424]
 ldr x9,[x19,#3720]
 ldr w11,[x9,x10,lsl #2]
 str w11,[sp,#428]
 mov w12,#21
 sub w12,w12,w10
 add w12,w11,w12,lsl #1
 add w12,w12,#1
 str w12,[sp,#432]
 mov x0,x19
 REC x1,x20,1359328
 REC x2,x20,1564592
 add x3,sp,#424
 add x4,sp,#428
 add x5,sp,#432
 add x6,x21,#1520
 add x7,sp,#1128
 CALL md2asm_scm_coriolis_prepare
 add x23,x23,#1
 cmp x23,#22
 b.lt .Lscm_coriolis_prepare
 STAT 1022,1
 STAT 9,2
 STAT 54,0
 mov x9,x19
 PLACE 0
 REC x9,x20,1564144
 PLACE 1
 REC x9,x20,1564176
 PLACE 2
 add x9,x21,#1520
 PLACE 3
 add x9,x21,#1608
 PLACE 4
 add x9,x21,#1696
 PLACE 5
 add x9,x21,#2136
 PLACE 6
 add x9,x21,#2224
 PLACE 7
 mov x9,xzr
 PLACE 8
 mov x9,xzr
 PLACE 9
 add x9,sp,#512
 PLACE 10
 add x9,sp,#1128
 PLACE 11
 mov x9,xzr
 PLACE 12
 mov x9,xzr
 PLACE 13
 add x9,sp,#600
 PLACE 14
 add x9,sp,#688
 PLACE 15
 add x9,sp,#776
 PLACE 16
 add x9,sp,#864
 PLACE 17
 add x9,sp,#952
 PLACE 18
 mov x9,xzr
 PLACE 19
 mov x9,xzr
 PLACE 20
 add x9,sp,#1040
 PLACE 21
 add x9,sp,#1216
 PLACE 22
 mov x9,xzr
 PLACE 23
 mov x9,xzr
 PLACE 24
 mov x9,xzr
 PLACE 25
 mov x9,xzr
 PLACE 26
 add x9,sp,#404
 PLACE 27
 CALL md2asm_spectral_level_to_column_7358525
 STAT 54,2
 STAT 9,3
 mov x9,x19
 PLACE 0
 REC x9,x20,4232912
 PLACE 1
 REC x9,x20,1359328
 PLACE 2
 REC x9,x20,1564592
 PLACE 3
 REC x9,x20,1564136
 PLACE 4
 add x9,sp,#416
 PLACE 5
 add x9,sp,#420
 PLACE 6
 add x9,sp,#408
 PLACE 7
 add x9,sp,#412
 PLACE 8
 add x9,sp,#404
 PLACE 9
 add x9,sp,#600
 PLACE 10
 add x9,sp,#688
 PLACE 11
 add x9,sp,#776
 PLACE 12
 add x9,sp,#1040
 PLACE 13
 add x9,sp,#1304
 PLACE 14
 add x9,sp,#1392
 PLACE 15
 add x9,sp,#1480
 PLACE 16
 add x9,sp,#1216
 PLACE 17
 CALL md2asm_spcsi
 STAT 9,2
 STAT 54,3
 mov x9,x19
 PLACE 0
 REC x9,x20,1564144
 PLACE 1
 REC x9,x20,1564176
 PLACE 2
 add x9,sp,#600
 PLACE 3
 add x9,sp,#688
 PLACE 4
 add x9,sp,#776
 PLACE 5
 add x9,sp,#864
 PLACE 6
 add x9,sp,#952
 PLACE 7
 mov x9,xzr
 PLACE 8
 mov x9,xzr
 PLACE 9
 add x9,sp,#1040
 PLACE 10
 mov x9,xzr
 PLACE 11
 mov x9,xzr
 PLACE 12
 mov x9,xzr
 PLACE 13
 add x9,x21,#1520
 PLACE 14
 add x9,x21,#1608
 PLACE 15
 add x9,x21,#1696
 PLACE 16
 add x9,x21,#2136
 PLACE 17
 add x9,x21,#2224
 PLACE 18
 mov x9,xzr
 PLACE 19
 mov x9,xzr
 PLACE 20
 add x9,sp,#512
 PLACE 21
 mov x9,xzr
 PLACE 22
 mov x9,xzr
 PLACE 23
 mov x9,xzr
 PLACE 24
 mov x9,xzr
 PLACE 25
 mov x9,xzr
 PLACE 26
 add x9,sp,#404
 PLACE 27
 add x9,sp,#408
 PLACE 28
 CALL md2asm_spectral_column_to_level_7358525
 STAT 54,1
 STAT 9,3
 STAT 1024,0
 mov x23,#0
.Lscm_coriolis_correct:
 // MYMS is a 1-based dense integer table. NASM0 is zero-based.
 ldr x9,[x19,#3912]
 ldr w10,[x9,x23,lsl #2]
 str w10,[sp,#424]
 ldr x9,[x19,#3720]
 ldr w11,[x9,x10,lsl #2]
 str w11,[sp,#428]
 mov w12,#21
 sub w12,w12,w10
 add w12,w11,w12,lsl #1
 add w12,w12,#1
 str w12,[sp,#432]
 mov x0,x19
 REC x1,x20,1359328
 REC x2,x20,1564592
 add x3,sp,#424
 add x4,sp,#428
 add x5,sp,#432
 add x6,x21,#1608
 add x7,x21,#1520
 CALL md2asm_scm_coriolis_correct
 add x23,x23,#1
 cmp x23,#22
 b.lt .Lscm_coriolis_correct
 STAT 1024,1
 ldr w9,[sp,#400]
 cmp w9,#65
 b.ne .Lscm_finish_numerical
 mov x0,x19
 add x1,sp,#408
 add x2,sp,#412
 adrp x3,:got:__yomsp_MOD_spvor_flt
 ldr x3,[x3,:got_lo12:__yomsp_MOD_spvor_flt]
 adrp x4,:got:__yomsp_MOD_spdiv_flt
 ldr x4,[x4,:got_lo12:__yomsp_MOD_spdiv_flt]
 CALL md2asm_scm_spectral_filter
 mov x9,x19
 PLACE 0
 mov x9,x20
 PLACE 1
 add x9,sp,#408
 PLACE 2
 add x9,sp,#412
 PLACE 3
 add x9,x21,#1520
 PLACE 4
 add x9,x21,#1608
 PLACE 5
 add x9,x21,#1696
 PLACE 6
 add x9,x21,#2136
 PLACE 7
 add x9,x21,#2224
 PLACE 8
 add x9,x21,#2312
 PLACE 9
 add x9,x21,#2640
 PLACE 10
 add x9,sp,#512
 PLACE 11
 REC x9,x20,4269720
 PLACE 12
 REC x9,x20,4269808
 PLACE 13
 REC x9,x20,4269896
 PLACE 14
 REC x9,x20,4269984
 PLACE 15
 REC x9,x20,4270072
 PLACE 16
 REC x9,x20,4270160
 PLACE 17
 REC x9,x20,4270248
 PLACE 18
 CALL md2asm_spchor_7259755
.Lscm_finish_numerical:
 STAT 9,1
.Lscm_store_pressure:
 ldr x9,[sp,#512]
 ldr x10,[x21,#2400]
 mov x11,#506
.Lscm_copy_return_pressure:
 ldr x12,[x9],#8
 str x12,[x10],#8
 subs x11,x11,#1
 b.ne .Lscm_copy_return_pressure
 mov x0,x22
 CALL free
 ldr w9,[sp,#376]
 cbz w9,.Lscm_return
 adr x0,.Lscm_hook_name
 add x1,sp,#380
 mov w9,#1
 str w9,[x1]
 add x2,sp,#384
 mov x3,#4
 CALL __yomhook_MOD_dr_hook_default8
.Lscm_return:
 adrp x9,:got:md2asm_spectral_calculation_driver_count_7358525
 ldr x9,[x9,:got_lo12:md2asm_spectral_calculation_driver_count_7358525]
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
 ldp x19,x20,[sp,#192]
 ldp x21,x22,[sp,#208]
 ldp x23,x24,[sp,#224]
 ldp x25,x26,[sp,#240]
 ldp x27,x28,[sp,#256]
 ldp x29,x30,[sp,#272]
 ldr x18,[sp,#288]
 add sp,sp,#2048
 ret
.Lscm_reject:
 brk #0x53d
.size md2asm_spectral_calculation_driver_7358525,.-md2asm_spectral_calculation_driver_7358525

// GNU descriptor construction is metadata only. x3 rows, x4 columns.
.Lscm_make_descriptor:
 str x1,[x0]
 mov x9,#1
 str x9,[x0,#40]
 str x9,[x0,#48]
 str x3,[x0,#56]
 mov x10,#8
 str x10,[x0,#16]
 str x10,[x0,#32]
 cmp x2,#1
 b.eq .Lscm_make_rank1
 neg x10,x3
 sub x10,x10,#1
 str x10,[x0,#8]
 movz x10,#0x0302,lsl #32
 str x10,[x0,#24]
 str x3,[x0,#64]
 str x9,[x0,#72]
 str x4,[x0,#80]
 ret
.Lscm_make_rank1:
 mov x10,#-1
 str x10,[x0,#8]
 movz x10,#0x0301,lsl #32
 str x10,[x0,#24]
 ret
.section .rodata
.Lscm_hook_name: .ascii "SPCM"
.bss
.p2align 3
.global md2asm_spectral_calculation_driver_count_7358525
.type md2asm_spectral_calculation_driver_count_7358525,%object
md2asm_spectral_calculation_driver_count_7358525: .zero 8
.size md2asm_spectral_calculation_driver_count_7358525,8
.section .note.GNU-stack,"",%progbits
