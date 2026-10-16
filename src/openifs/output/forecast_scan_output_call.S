/* SCAN2M selected output call.
 * Contract: skills/md2asm/references/openifs/dynamics/retained_forecast_callers.md.
 * Original by-address interfaces and frozen child order are retained. */
.text
.p2align 4
.macro GLOBAL r,name
 adrp \r,:got:\name
 ldr \r,[\r,:got_lo12:\name]
.endm
.macro CALL name
 str x18,[sp,#320]
 bl \name
 ldr x18,[sp,#320]
.endm
.macro EVENT phase
 adrp x0,.Lsc_event
 add x0,x0,:lo12:.Lsc_event
 adrp x1,.Lsc_phase_\phase
 add x1,x1,:lo12:.Lsc_phase_\phase
 CALL gstats_
.endm
.global md2asm_scan_selected_output_call_7358525
.type md2asm_scan_selected_output_call_7358525,%function
md2asm_scan_selected_output_call_7358525:
 mov x17,sp
 mov x16,#4096
 sub sp,sp,x16
 stp x18,x30,[sp,#192]
 stp x19,x20,[sp,#208]
 stp x21,x22,[sp,#224]
 stp x23,x24,[sp,#240]
 stp x25,x26,[sp,#256]
 stp x27,x28,[sp,#272]
 str x29,[sp,#288]
 str x0,[sp,#384]
 mrs x9,fpcr
 cbnz x9,.Lbad
 ldr x19,[sp,#384]
 ldr x20,[x19,#256]
 ldr x21,[x19,#264]
 cbz x20,.Lsc_done
 cbz x21,.Lsc_done
 ldr x22,[x19,#176]
 ldr x23,[x19,#184]
 ldr x24,[x19,#200]
 GLOBAL x9,__yomfpc_MOD_lfppacking
 ldr w9,[x9]
 cbnz w9,.Lbad
 movz x16,#4956
 movk x16,#8,lsl #16
 add x9,x23,x16
 ldr w9,[x9]
 cbnz w9,.Lbad
 EVENT 0
 mov x0,#1
 CALL malloc
 cbz x0,.Lbad
 mov x16,#944
 add x17,sp,x16
 str x0,[x17]
 GLOBAL x9,__yomhook_MOD_lhook
 ldr w9,[x9]
 cbz w9,.Lsc_hook_0
 adrp x0,.Lsc_name
 add x0,x0,:lo12:.Lsc_name
 adrp x1,.Lsc_phase_0
 add x1,x1,:lo12:.Lsc_phase_0
 add x2,sp,#336
 mov x3,#9
 CALL __yomhook_MOD_dr_hook_default8
.Lsc_hook_0:
 GLOBAL x9,__yomhook_MOD_lhook
 ldr w9,[x9]
 cbz w9,.Lsc_hook_1
 adrp x0,.Lsc_name
 add x0,x0,:lo12:.Lsc_name
 adrp x1,.Lsc_phase_1
 add x1,x1,:lo12:.Lsc_phase_1
 add x2,sp,#336
 mov x3,#9
 CALL __yomhook_MOD_dr_hook_default8
.Lsc_hook_1:
 GLOBAL x9,__yomppc_MOD_mfpphy
 mov x16,#952
 add x17,sp,x16
 str x9,[x17]
 mov x16,#1024
 add x0,sp,x16
 mov x16,#952
 add x17,sp,x16
 ldr x1,[x17]
 mov w2,#1
 mov w3,#4
 mov x4,#1639
 CALL .Ldense
 mov w9,#1
 str w9,[sp,#960]
 str w9,[sp,#964]
 str wzr,[sp,#968]
 str x20,[sp,#640]
 str x22,[sp,#648]
 mov x16,#1856
 add x9,x23,x16
 str x9,[sp,#656]
 mov x16,#3416
 add x9,x23,x16
 str x9,[sp,#664]
 mov x16,#4512
 add x9,x23,x16
 str x9,[sp,#672]
 mov x16,#35304
 add x9,x23,x16
 str x9,[sp,#680]
 movz x16,#968
 movk x16,#3,lsl #16
 add x9,x23,x16
 str x9,[sp,#688]
 movz x16,#856
 movk x16,#3,lsl #16
 add x9,x23,x16
 ldr x9,[x9]
 str x9,[sp,#696]
 movz x16,#3904
 movk x16,#8,lsl #16
 add x9,x23,x16
 ldr x9,[x9]
 str x9,[sp,#704]
 movz x16,#4956
 movk x16,#8,lsl #16
 add x9,x23,x16
 str x9,[sp,#712]
 mov x16,#944
 add x17,sp,x16
 ldr x9,[x17]
 str x9,[sp,#720]
 str x24,[sp,#728]
 movz x16,#48808
 movk x16,#20,lsl #16
 add x9,x24,x16
 str x9,[sp,#736]
 GLOBAL x9,__yomct3_MOD_nstep
 str x9,[sp,#744]
 movz x16,#48612
 movk x16,#20,lsl #16
 add x9,x24,x16
 str x9,[sp,#752]
 mov x16,#960
 add x9,sp,x16
 str x9,[sp,#760]
 mov x16,#964
 add x9,sp,x16
 str x9,[sp,#768]
 mov x16,#968
 add x9,sp,x16
 str x9,[sp,#776]
 str x21,[sp,#784]
 GLOBAL x9,__yomppc_MOD_nfpphy
 str x9,[sp,#792]
 mov x16,#1024
 add x9,sp,x16
 str x9,[sp,#800]
 ldr x0,[sp,#640]
 ldr x1,[sp,#648]
 ldr x2,[sp,#656]
 ldr x3,[sp,#664]
 ldr x4,[sp,#672]
 ldr x5,[sp,#680]
 ldr x6,[sp,#688]
 ldr x7,[sp,#696]
 ldr x9,[sp,#704]
 str x9,[sp,#0]
 ldr x9,[sp,#712]
 str x9,[sp,#8]
 ldr x9,[sp,#720]
 str x9,[sp,#16]
 ldr x9,[sp,#728]
 str x9,[sp,#24]
 ldr x9,[sp,#736]
 str x9,[sp,#32]
 ldr x9,[sp,#744]
 str x9,[sp,#40]
 ldr x9,[sp,#752]
 str x9,[sp,#48]
 ldr x9,[sp,#760]
 str x9,[sp,#56]
 ldr x9,[sp,#768]
 str x9,[sp,#64]
 ldr x9,[sp,#776]
 str x9,[sp,#72]
 ldr x9,[sp,#784]
 str x9,[sp,#80]
 ldr x9,[sp,#792]
 str x9,[sp,#88]
 ldr x9,[sp,#800]
 str x9,[sp,#96]
 CALL md2asm_fullpos_drv_7358525
 mov x16,#944
 add x17,sp,x16
 ldr x0,[x17]
 CALL free
 EVENT 1
.Lsc_done:
 adrp x9,.Lcounts
 add x9,x9,:lo12:.Lcounts
 ldr x10,[x9,#0]
 add x10,x10,#1
 str x10,[x9,#0]
 ldp x18,x30,[sp,#192]
 ldp x19,x20,[sp,#208]
 ldp x21,x22,[sp,#224]
 ldp x23,x24,[sp,#240]
 ldp x25,x26,[sp,#256]
 ldp x27,x28,[sp,#272]
 ldr x29,[sp,#288]
 mov x16,#4096
 add sp,sp,x16
 ret
.size md2asm_scan_selected_output_call_7358525,.-md2asm_scan_selected_output_call_7358525
.Ldense:
 str x1,[x0]
 str xzr,[x0,#8]
 str x3,[x0,#16]
 str wzr,[x0,#24]
 strb w2,[x0,#28]
 mov w9,#3
 cmp w3,#4
 mov w10,#1
 csel w9,w10,w9,eq
 strb w9,[x0,#29]
 strh wzr,[x0,#30]
 str x3,[x0,#32]
 mov x9,#1
 str x9,[x0,#40]
 str x9,[x0,#48]
 str x4,[x0,#56]
 neg x10,x9
 cmp w2,#1
 b.eq .Ldense_last
 str x4,[x0,#64]
 str x9,[x0,#72]
 str x5,[x0,#80]
 sub x10,x10,x4
 cmp w2,#2
 b.eq .Ldense_last
 mul x11,x4,x5
 str x11,[x0,#88]
 str x9,[x0,#96]
 str x6,[x0,#104]
 sub x10,x10,x11
.Ldense_last:
 str x10,[x0,#8]
 ret
.Lbad:
 CALL abort
 brk #0
.section .rodata
.Lsc_event:.word 30
.Lsc_phase_0:.word 0
.Lsc_phase_1:.word 1
.Lsc_name:.ascii "SP2GPMCUF"
.bss
.p2align 3
.Lcounts:.skip 8
.section .note.GNU-stack,"",%progbits
