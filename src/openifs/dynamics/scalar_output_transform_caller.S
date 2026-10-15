// Original interfaces: TRANSDIR_FP.
// Contract: skills/md2asm/references/openifs/dynamics/scalar_output_transform_caller.md.
// Current private ready receipt is retained in the publication manifest.
.arch armv8.2-a+simd
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
.macro PROFILE name,length,phase
 GLOBAL x9,__yomhook_MOD_lhook
 ldr w9,[x9]
 cbz w9,91f
 adrp x0,.Lname_\name
 add x0,x0,:lo12:.Lname_\name
 adrp x1,.Lphase_\phase
 add x1,x1,:lo12:.Lphase_\phase
 add x2,sp,#336
 mov x3,#\length
 CALL __yomhook_MOD_dr_hook_default8
91:
.endm
.macro EVENT id,phase
 adrp x0,.Levent_\id
 add x0,x0,:lo12:.Levent_\id
 adrp x1,.Lphase_\phase
 add x1,x1,:lo12:.Lphase_\phase
 CALL gstats_
.endm

.global md2asm_transdir_fp_scalar_grid_binding_r2_7358525
.set md2asm_transdir_fp_scalar_grid_binding_r2_7358525,md2asm_transdir_fp_7358525
.global md2asm_transdir_fp_7358525
.type md2asm_transdir_fp_7358525,%function
md2asm_transdir_fp_7358525:
 mov x17,sp
 mov x16,#2048
 sub sp,sp,x16
 stp x18,x30,[sp,#192]
 stp x19,x20,[sp,#208]
 stp x21,x22,[sp,#224]
 stp x23,x24,[sp,#240]
 stp x25,x26,[sp,#256]
 stp x27,x28,[sp,#272]
 str x29,[sp,#288]
 str x0,[sp,#384]
 str x1,[sp,#392]
 str x2,[sp,#400]
 str x3,[sp,#408]
 str x4,[sp,#416]
 str x5,[sp,#424]
 str x6,[sp,#432]
 str x7,[sp,#440]
 mrs x9,fpcr
 cbnz x9,.Lbad
 ldr x19,[sp,#384]
 ldr w20,[x19,#1128]
 cmp w20,#39
 b.hi .Lbad
 ldr w9,[x19,#1132]
 cbnz w9,.Lbad
 PROFILE transdirfp,11,0
 mov w9,#24
 str w9,[sp,#960]
 mov w9,#1
 str w9,[sp,#964]
 add x10,sp,#1024
 mov w11,w20
 cbz w11,.Ltd_sets_done
.Ltd_set:
 str w9,[x10],#4
 subs w11,w11,#1
 b.ne .Ltd_set
.Ltd_sets_done:
 mov x16,#1024
 add x9,sp,x16
 mov x16,#1200
 add x17,sp,x16
 str x9,[x17]
 mov x16,#1280
 add x0,sp,x16
 mov x16,#1200
 add x17,sp,x16
 ldr x1,[x17]
 mov w2,#1
 mov w3,#4
 mov x4,x20
 CALL .Ldense
 cbz w20,.Ltd_done
 mov x9,#0
 str x9,[sp,#640]
 mov x9,#0
 str x9,[sp,#648]
 mov x9,#0
 str x9,[sp,#656]
 mov x9,#0
 str x9,[sp,#664]
 mov x9,#0
 str x9,[sp,#672]
 mov x9,#0
 str x9,[sp,#680]
 mov x9,#0
 str x9,[sp,#688]
 mov x9,#0
 str x9,[sp,#696]
 mov x9,#0
 str x9,[sp,#704]
 mov x9,#0
 str x9,[sp,#712]
 mov x9,#0
 str x9,[sp,#720]
 mov x9,#0
 str x9,[sp,#728]
 mov x9,#0
 str x9,[sp,#736]
 mov x9,#0
 str x9,[sp,#744]
 mov x9,#0
 str x9,[sp,#752]
 mov x9,#0
 str x9,[sp,#760]
 mov x9,#0
 str x9,[sp,#768]
 mov x9,#0
 str x9,[sp,#776]
 mov x9,#0
 str x9,[sp,#784]
 ldr x9,[sp,#408]
 str x9,[sp,#656]
 mov x16,#960
 add x9,sp,x16
 str x9,[sp,#696]
 mov x16,#1280
 add x9,sp,x16
 str x9,[sp,#712]
 mov x16,#964
 add x9,sp,x16
 str x9,[sp,#720]
 ldr x9,[sp,#400]
 str x9,[sp,#752]
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
 CALL md2asm_dir_trans_7358525
 .Ltd_done:
 PROFILE transdirfp,11,1
 CALL md2asm_selected_output_stage_counts_7358525
 mov x9,x0
 ldr x10,[x9,#16]
 add x10,x10,#1
 str x10,[x9,#16]
 ldp x18,x30,[sp,#192]
 ldp x19,x20,[sp,#208]
 ldp x21,x22,[sp,#224]
 ldp x23,x24,[sp,#240]
 ldp x25,x26,[sp,#256]
 ldp x27,x28,[sp,#272]
 ldr x29,[sp,#288]
 mov x16,#2048
 add sp,sp,x16
 ret
.size md2asm_transdir_fp_7358525,.-md2asm_transdir_fp_7358525

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
.p2align 3
.Lphase_0:.word 0
.Lphase_1:.word 1
.Lname_transdirfp:.ascii "TRANSDIR_FP"
.section .note.GNU-stack,"",%progbits
