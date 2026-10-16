/* Source build for the qualified private forecast graph.
 * Contract: skills/md2asm/references/openifs/dynamics/private_forecast_graph_sources.md.
 * Preserve the original interface, ordered arithmetic, and caller-owned storage. */
// Source contract: legendre_controller_contract_r1.md.
// Direct allocation and mode loops, with numerical children privately bound.
// Only typed field offsets enter this header, without numerical code.
.arch armv8-a
.include "legendre_transform_controllers_layout.inc.S"
.text
.p2align 4
.macro GLOBAL dst,name
 adrp \dst,:got:\name
 ldr \dst,[\dst,:got_lo12:\name]
.endm
.macro EVENT id,phase
 adrp x0,.Levent_\id
 add x0,x0,:lo12:.Levent_\id
 adrp x1,.Lphase_\phase
 add x1,x1,:lo12:.Lphase_\phase
 bl gstats_
.endm
.global md2asm_ltinv_ctl_7358525
.type md2asm_ltinv_ctl_7358525,%function
md2asm_ltinv_ctl_7358525:
 mov x17,sp
 sub sp,sp,#512
 stp x18,x30,[sp,#96]
 stp x19,x20,[sp,#112]
 stp x21,x22,[sp,#128]
 stp x23,x24,[sp,#144]
 stp x25,x26,[sp,#160]
 stp x27,x28,[sp,#176]
 str x29,[sp,#192]
 str x0,[sp,#208]
 str x1,[sp,#216]
 str x2,[sp,#224]
 str x3,[sp,#232]
 str x4,[sp,#240]
 str x5,[sp,#248]
 str x6,[sp,#256]
 str x7,[sp,#264]
 ldr x9,[x17,#0]
 str x9,[sp,#272]
 ldr x9,[x17,#8]
 str x9,[sp,#280]
 ldr x9,[x17,#16]
 str x9,[sp,#288]
 ldr x9,[x17,#24]
 str x9,[sp,#296]
 ldr x9,[x17,#32]
 str x9,[sp,#304]
 ldr x9,[sp,#304]
 cbnz x9,.Lctl_bad
 GLOBAL x9,__tpm_distr_MOD_nproc
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Lctl_bad
 GLOBAL x9,__tpm_distr_MOD_d
 ldr x19,[x9]
 cbz x19,.Lctl_bad
 ldr w20,[x19,#D_NUMP]
 cmp w20,#1
 b.lt .Lctl_bad
 cmp w20,#22
 b.gt .Lctl_bad
 ldr w21,[x19,#D_NLENGT0B]
 cmp w21,#1
 b.lt .Lctl_bad
 ldr x9,[sp,#208]
 cbz x9,.Lctl_bad
 ldr w10,[x9]
 cmp w10,#0
 b.lt .Lctl_bad
 cmp w10,#136
 b.gt .Lctl_bad
 ldr x9,[sp,#216]
 cbz x9,.Lctl_bad
 ldr w10,[x9]
 cmp w10,#0
 b.lt .Lctl_bad
 cmp w10,#136
 b.gt .Lctl_bad
 ldr x9,[sp,#224]
 cbz x9,.Lctl_bad
 ldr w10,[x9]
 cmp w10,#0
 b.lt .Lctl_bad
 cmp w10,#136
 b.gt .Lctl_bad
 ldr x9,[sp,#232]
 cbz x9,.Lctl_bad
 ldr w10,[x9]
 cmp w10,#0
 b.lt .Lctl_bad
 cmp w10,#136
 b.gt .Lctl_bad
 ldr x9,[sp,#208]
 ldr w22,[x9]
 lsl w23,w22,#1
 str w23,[sp,#320]
 mul w21,w21,w23
 cmp w21,#0
 b.lt .Lctl_bad
 EVENT 102,0
 ldr x9,[sp,#216]
 ldr w9,[x9]
 lsl w9,w9,#3
 ldr x10,[sp,#224]
 ldr w10,[x10]
 add w9,w9,w10,lsl #1
 ldr x10,[sp,#232]
 ldr w10,[x10]
 add w9,w9,w10,lsl #1
 str w9,[sp,#324]
 GLOBAL x24,__tpm_trans_MOD_foubuf
 mov x0,x24
 mov w1,w21
 mov w2,#0
 bl .Lctl_ensure
 GLOBAL x25,__tpm_trans_MOD_foubuf_in
 mov x0,x25
 mov w1,w21
 mov w2,#1
 bl .Lctl_ensure
 GLOBAL x9,__tpm_flt_MOD_s
 ldr x9,[x9]
 cbz x9,.Lctl_bad
 ldr w9,[x9,#S_LDLL]
 cbz w9,.Lltinv_ctl_clear_done
 mov x0,x25
 bl .Lctl_zero
.Lltinv_ctl_clear_done:
 cbz w22,.Lltinv_ctl_modes_done
 EVENT 1647,0
 mov w26,#1
.Lltinv_ctl_mode:
 str w26,[sp,#328]
 add x0,x19,#D_MYMS
 sxtw x1,w26
 bl .Lctl_int1
 str w0,[sp,#332]
 cmp w0,#0
 b.lt .Lctl_bad
 cmp w0,#21
 b.gt .Lctl_bad
 add x0,sp,#332
 add x1,sp,#328
 ldr x2,[sp,#208]
 ldr x3,[sp,#216]
 ldr x4,[sp,#224]
 ldr x5,[sp,#232]
 add x6,sp,#324
 add x7,sp,#320
 ldr x9,[sp,#240]
 str x9,[sp,#0]
 ldr x9,[sp,#248]
 str x9,[sp,#8]
 ldr x9,[sp,#256]
 str x9,[sp,#16]
 ldr x9,[sp,#264]
 str x9,[sp,#24]
 ldr x9,[sp,#272]
 str x9,[sp,#32]
 ldr x9,[sp,#280]
 str x9,[sp,#40]
 ldr x9,[sp,#288]
 str x9,[sp,#48]
 ldr x9,[sp,#296]
 str x9,[sp,#56]
 ldr x9,[sp,#304]
 str x9,[sp,#64]
 bl md2asm_ltinv_native
 add w26,w26,#1
 cmp w26,w20
 b.le .Lltinv_ctl_mode
.Lltinv_ctl_modes_done:
 cbz w22,.Lltinv_ctl_event_done
 EVENT 1647,1
.Lltinv_ctl_event_done:
 EVENT 102,1
 EVENT 152,0
 mov x0,x25
 mov x1,x24
 add x2,sp,#320
 bl md2asm_trmtol_7358525
 EVENT 152,1
 GLOBAL x9,__tpm_gen_MOD_lalloperm
 ldr w9,[x9]
 cbnz w9,.Lltinv_ctl_retain_done
 mov x0,x25
 bl .Lctl_release
.Lltinv_ctl_retain_done:
 adrp x9,.Lcontroller_counts
 add x9,x9,:lo12:.Lcontroller_counts
 ldr x10,[x9,#0]
 add x10,x10,#1
 str x10,[x9,#0]
 ldp x18,x30,[sp,#96]
 ldp x19,x20,[sp,#112]
 ldp x21,x22,[sp,#128]
 ldp x23,x24,[sp,#144]
 ldp x25,x26,[sp,#160]
 ldp x27,x28,[sp,#176]
 ldr x29,[sp,#192]
 add sp,sp,#512
 ret
.size md2asm_ltinv_ctl_7358525,.-md2asm_ltinv_ctl_7358525
.global md2asm_ltdir_ctl_7358525
.type md2asm_ltdir_ctl_7358525,%function
md2asm_ltdir_ctl_7358525:
 mov x17,sp
 sub sp,sp,#512
 stp x18,x30,[sp,#96]
 stp x19,x20,[sp,#112]
 stp x21,x22,[sp,#128]
 stp x23,x24,[sp,#144]
 stp x25,x26,[sp,#160]
 stp x27,x28,[sp,#176]
 str x29,[sp,#192]
 str x0,[sp,#208]
 str x1,[sp,#216]
 str x2,[sp,#224]
 str x3,[sp,#232]
 str x4,[sp,#240]
 str x5,[sp,#248]
 str x6,[sp,#256]
 str x7,[sp,#264]
 ldr x9,[x17,#0]
 str x9,[sp,#272]
 ldr x9,[x17,#8]
 str x9,[sp,#280]
 ldr x9,[x17,#16]
 str x9,[sp,#288]
 GLOBAL x9,__tpm_distr_MOD_nproc
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Lctl_bad
 GLOBAL x9,__tpm_distr_MOD_d
 ldr x19,[x9]
 cbz x19,.Lctl_bad
 ldr w20,[x19,#D_NUMP]
 cmp w20,#1
 b.lt .Lctl_bad
 cmp w20,#22
 b.gt .Lctl_bad
 ldr w21,[x19,#D_NLENGT0B]
 cmp w21,#1
 b.lt .Lctl_bad
 ldr x9,[sp,#208]
 cbz x9,.Lctl_bad
 ldr w10,[x9]
 cmp w10,#0
 b.lt .Lctl_bad
 cmp w10,#136
 b.gt .Lctl_bad
 ldr x9,[sp,#216]
 cbz x9,.Lctl_bad
 ldr w10,[x9]
 cmp w10,#0
 b.lt .Lctl_bad
 cmp w10,#136
 b.gt .Lctl_bad
 ldr x9,[sp,#224]
 cbz x9,.Lctl_bad
 ldr w10,[x9]
 cmp w10,#0
 b.lt .Lctl_bad
 cmp w10,#136
 b.gt .Lctl_bad
 ldr x9,[sp,#208]
 ldr w22,[x9]
 lsl w23,w22,#1
 str w23,[sp,#320]
 mul w21,w21,w23
 cmp w21,#0
 b.lt .Lctl_bad
 GLOBAL x24,__tpm_trans_MOD_foubuf
 mov x0,x24
 mov w1,w21
 mov w2,#0
 bl .Lctl_ensure
 GLOBAL x25,__tpm_trans_MOD_foubuf_in
 EVENT 153,0
 mov x0,x25
 mov x1,x24
 add x2,sp,#320
 bl md2asm_trltom_7358525
 EVENT 153,1
 GLOBAL x9,__tpm_gen_MOD_lalloperm
 ldr w9,[x9]
 cbnz w9,.Lltdir_ctl_input_retained
 mov x0,x25
 bl .Lctl_release
.Lltdir_ctl_input_retained:
 EVENT 103,0
 EVENT 1645,0
 cbz w22,.Lltdir_ctl_modes_done
 mov w26,#1
.Lltdir_ctl_mode:
 str w26,[sp,#328]
 add x0,x19,#D_MYMS
 sxtw x1,w26
 bl .Lctl_int1
 str w0,[sp,#332]
 cmp w0,#0
 b.lt .Lctl_bad
 cmp w0,#21
 b.gt .Lctl_bad
 add x0,sp,#332
 add x1,sp,#328
 ldr x2,[sp,#208]
 ldr x3,[sp,#216]
 ldr x4,[sp,#224]
 add x5,sp,#320
 ldr x6,[sp,#232]
 ldr x7,[sp,#240]
 ldr x9,[sp,#248]
 str x9,[sp,#0]
 ldr x9,[sp,#256]
 str x9,[sp,#8]
 ldr x9,[sp,#264]
 str x9,[sp,#16]
 ldr x9,[sp,#272]
 str x9,[sp,#24]
 ldr x9,[sp,#280]
 str x9,[sp,#32]
 ldr x9,[sp,#288]
 str x9,[sp,#40]
 bl md2asm_ltdir_7358525
 add w26,w26,#1
 cmp w26,w20
 b.le .Lltdir_ctl_mode
.Lltdir_ctl_modes_done:
 EVENT 1645,1
 GLOBAL x9,__tpm_gen_MOD_lalloperm
 ldr w9,[x9]
 cbnz w9,.Lltdir_ctl_retain_done
 mov x0,x24
 bl .Lctl_release
.Lltdir_ctl_retain_done:
 EVENT 103,1
 adrp x9,.Lcontroller_counts
 add x9,x9,:lo12:.Lcontroller_counts
 ldr x10,[x9,#8]
 add x10,x10,#1
 str x10,[x9,#8]
 ldp x18,x30,[sp,#96]
 ldp x19,x20,[sp,#112]
 ldp x21,x22,[sp,#128]
 ldp x23,x24,[sp,#144]
 ldp x25,x26,[sp,#160]
 ldp x27,x28,[sp,#176]
 ldr x29,[sp,#192]
 add sp,sp,#512
 ret
.size md2asm_ltdir_ctl_7358525,.-md2asm_ltdir_ctl_7358525
// A source ALLOCATE creates the same 64-byte GNU real rank-one descriptor.
// x2 selects zero only for the first allocation of an inverse input buffer.
.Lctl_ensure:
 sub sp,sp,#64
 stp x18,x30,[sp,#0]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 mov x19,x0
 sxtw x20,w1
 cmp x20,#1
 mov x9,#1
 csel x20,x20,x9,ge
 mov w21,w2
 mov w22,#0
 ldr x0,[x19]
 cbz x0,.Lctl_first_alloc
 ldr x9,[x19,#56]
 ldr x10,[x19,#48]
 sub x9,x9,x10
 add x9,x9,#1
 cmp x9,x20
 b.ge .Lctl_ensure_done
 bl free
 str xzr,[x19]
 b .Lctl_allocate
.Lctl_first_alloc:
 mov w22,#1
.Lctl_allocate:
 lsl x0,x20,#3
 bl malloc
 cbz x0,.Lctl_bad
 str x0,[x19]
 mov x9,#-1
 str x9,[x19,#8]
 mov x9,#8
 str x9,[x19,#16]
 str wzr,[x19,#24]
 mov w9,#1
 strb w9,[x19,#28]
 mov w9,#3
 strb w9,[x19,#29]
 strh wzr,[x19,#30]
 mov x9,#8
 str x9,[x19,#32]
 mov x9,#1
 stp x9,x9,[x19,#40]
 str x20,[x19,#56]
 and w9,w21,w22
 cbz w9,.Lctl_ensure_done
 mov x0,x19
 bl .Lctl_zero
.Lctl_ensure_done:
 ldp x18,x30,[sp,#0]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 add sp,sp,#64
 ret
.Lctl_zero:
 ldr x9,[x0]
 cbz x9,.Lctl_bad
 ldr x10,[x0,#56]
 ldr x11,[x0,#48]
 sub x10,x10,x11
 add x10,x10,#1
 cmp x10,#1
 b.lt .Lctl_bad
.Lctl_zero_word:
 str xzr,[x9],#8
 subs x10,x10,#1
 b.ne .Lctl_zero_word
 ret
.Lctl_release:
 sub sp,sp,#32
 stp x18,x30,[sp,#0]
 str x19,[sp,#16]
 mov x19,x0
 ldr x0,[x19]
 cbz x0,.Lctl_release_done
 bl free
 str xzr,[x19]
.Lctl_release_done:
 ldr x19,[sp,#16]
 ldp x18,x30,[sp,#0]
 add sp,sp,#32
 ret
.Lctl_int1:
 ldr x9,[x0]
 cbz x9,.Lctl_bad
 ldr x10,[x0,#16]
 cmp x10,#4
 b.ne .Lctl_bad
 ldrb w10,[x0,#28]
 cmp w10,#1
 b.ne .Lctl_bad
 ldr x10,[x0,#48]
 cmp x1,x10
 b.lt .Lctl_bad
 ldr x10,[x0,#56]
 cmp x1,x10
 b.gt .Lctl_bad
 ldr x10,[x0,#8]
 ldr x11,[x0,#40]
 madd x10,x1,x11,x10
 ldr w0,[x9,x10,lsl #2]
 ret
.Lctl_bad:
 bl abort
 brk #0
.global md2asm_legendre_controllers_count_get
.type md2asm_legendre_controllers_count_get,%function
md2asm_legendre_controllers_count_get:
 cmp w0,#2
 b.hs .Lctl_count_zero
 adrp x9,.Lcontroller_counts
 add x9,x9,:lo12:.Lcontroller_counts
 ldr x0,[x9,x0,lsl #3]
 ret
.Lctl_count_zero:
 mov x0,#0
 ret
.data
.p2align 3
.Lcontroller_counts: .quad 0,0
.Lphase_0: .word 0
.Lphase_1: .word 1
.Levent_102: .word 102
.Levent_103: .word 103
.Levent_152: .word 152
.Levent_153: .word 153
.Levent_1647: .word 1647
.Levent_1645: .word 1645
.section .note.GNU-stack,"",%progbits
