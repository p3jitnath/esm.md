/* Contract: skills/md2asm/references/openifs/surface/surface_private_bindings.md. */
// Direct apparent soil energy, including integrated freezing heat.
// Qualified selected support for the owned SURFTSTP_CTL parent.
.text
.p2align 4
.macro ARG reg,arg
 ldr \reg,[x19,#(\arg*8)]
.endm
.macro IN reg,arg
 ARG x9,\arg
 ldr x10,[x9,#40]
 ldr x9,[x9]
 mul x10,x20,x10
 ldr \reg,[x9,x10,lsl #3]
.endm
.macro IN2 reg,arg
 ARG x9,\arg
 ldr x10,[x9,#40]
 ldr x11,[x9,#64]
 ldr x9,[x9]
 mul x10,x20,x10
 madd x10,x21,x11,x10
 ldr \reg,[x9,x10,lsl #3]
.endm
.macro OUT2 reg
 ARG x9,12
 ldr x10,[x9,#40]
 ldr x11,[x9,#64]
 ldr x9,[x9]
 mul x10,x20,x10
 madd x10,x21,x11,x10
 str \reg,[x9,x10,lsl #3]
.endm
.macro MASK arg
 ARG x9,\arg
 ldr x10,[x9,#40]
 ldr x9,[x9]
 mul x10,x20,x10
 ldr w11,[x9,x10,lsl #2]
.endm
.macro TABLE reg,offset,index
 add x9,x26,#\offset
 ldr x10,[x9,#48]
 sub x10,\index,x10
 ldr x11,[x9,#40]
 mul x10,x10,x11
 ldr x9,[x9]
 ldr \reg,[x9,x10,lsl #3]
.endm
.macro CONST reg,name
 adr x9,.Lse_\name
 ldr \reg,[x9]
.endm
.macro CALL name
 str x18,[sp,#296]
 bl \name
 ldr x18,[sp,#296]
.endm
.global md2asm_soil_energy_support_7358525
.type md2asm_soil_energy_support_7358525,%function
md2asm_soil_energy_support_7358525:
 sub sp,sp,#1024
 stp x19,x20,[sp,#192]
 stp x21,x22,[sp,#208]
 stp x23,x24,[sp,#224]
 stp x25,x26,[sp,#240]
 stp x27,x28,[sp,#256]
 stp x29,x30,[sp,#272]
 str x18,[sp,#288]
 add x19,sp,#320
 stp x0,x1,[x19]
 stp x2,x3,[x19,#16]
 stp x4,x5,[x19,#32]
 stp x6,x7,[x19,#48]
 add x11,sp,#1024
 mov x10,#8
.Lse_arguments:
 ldr x9,[x11],#8
 str x9,[x19,x10,lsl #3]
 add x10,x10,#1
 cmp x10,#13
 b.lt .Lse_arguments
 mrs x9,fpcr
 cbnz x9,.Lse_reject
 ARG x9,2
 ldr w22,[x9]
 cmp w22,#1
 b.lt .Lse_reject
 cmp w22,#4096
 b.gt .Lse_reject
 ARG x9,0
 ldrsw x23,[x9]
 sub x23,x23,#1
 cmp x23,#0
 b.lt .Lse_reject
 ARG x9,1
 ldrsw x24,[x9]
 cmp x24,x22
 b.gt .Lse_reject
 cmp x24,x23
 b.le .Lse_return
 ARG x9,3
 ldr w9,[x9]
 cmp w9,#4
 b.ne .Lse_reject
 ARG x25,10
 ARG x26,11
 adrp x9,:got:__yomhook_MOD_lhook
 ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
 ldr w9,[x9]
 cmp w9,#1
 b.hi .Lse_reject
 str w9,[sp,#432]
 cbz w9,.Lse_entry_hook_done
 adr x0,.Lse_hook_name
 add x1,sp,#436
 str wzr,[x1]
 add x2,sp,#440
 mov x3,#17
 CALL __yomhook_MOD_dr_hook_default8
.Lse_entry_hook_done:
 mov x0,x22
 mov x1,#32
 CALL calloc
 cbz x0,.Lse_reject
 mov x27,x0
 mov x21,#0
.Lse_phase_layer:
 mov x20,x23
.Lse_phase_row:
 MASK 4
 cbz w11,.Lse_phase_next
 IN2 d0,6
 ldr d1,[x26,#208]
 fcmp d0,d1
 b.ge .Lse_unfrozen
 ldr d1,[x26,#216]
 fcmp d0,d1
 b.le .Lse_frozen
 ldr d1,[x26,#224]
 fsub d0,d0,d1
 ldr d1,[x26,#232]
 fmul d0,d1,d0
 CALL md2asm_sin_original_rounding
 CONST d1,one
 fsub d0,d1,d0
 CONST d1,half
 fmul d0,d1,d0
 b .Lse_phase_store
.Lse_unfrozen:
 fmov d0,xzr
 b .Lse_phase_store
.Lse_frozen:
 CONST d0,one
.Lse_phase_store:
 madd x10,x21,x22,x20
 str d0,[x27,x10,lsl #3]
.Lse_phase_next:
 add x20,x20,#1
 cmp x20,x24
 b.lt .Lse_phase_row
 add x21,x21,#1
 cmp x21,#4
 b.lt .Lse_phase_layer
 mov x21,#0
.Lse_energy_layer:
 mov x20,x23
.Lse_energy_row:
 MASK 4
 cbz w11,.Lse_nonland
 ldr w9,[x26,#440]
 cbz w9,.Lse_scalar_soil
 ARG x9,7
 ldr x10,[x9,#40]
 ldr x9,[x9]
 mul x10,x20,x10
 ldrsw x28,[x9,x10,lsl #2]
 TABLE d0,944,x28
 TABLE d1,1520,x28
 b .Lse_soil_parameters_ready
.Lse_scalar_soil:
 ldr d0,[x26,#128]
 ldr d1,[x26,#8]
.Lse_soil_parameters_ready:
 IN d2,8
 IN d3,9
 fadd d2,d2,d3
 fmul d2,d2,d0
 IN2 d0,6
 fmul d0,d1,d0
 ldr d1,[x25,#64]
 adrp x9,:got:__yos_thf_MOD_rhoh2o
 ldr x9,[x9,:got_lo12:__yos_thf_MOD_rhoh2o]
 ldr d3,[x9]
 fmul d1,d1,d3
 fmul d1,d1,d2
 madd x10,x21,x22,x20
 ldr d2,[x27,x10,lsl #3]
 fmul d1,d1,d2
 fsub d0,d0,d1
 add x28,x21,#1
 TABLE d1,1584,x28
 fmul d0,d0,d1
 b .Lse_energy_store
.Lse_nonland:
 MASK 5
 cbz w11,.Lse_ocean
 ldr d0,[x26,#424]
 IN2 d1,6
 fmul d0,d0,d1
 add x28,x21,#1
 TABLE d1,1712,x28
 fmul d0,d0,d1
 b .Lse_energy_store
.Lse_ocean:
 fmov d0,xzr
.Lse_energy_store:
 OUT2 d0
 add x20,x20,#1
 cmp x20,x24
 b.lt .Lse_energy_row
 add x21,x21,#1
 cmp x21,#4
 b.lt .Lse_energy_layer
 mov x0,x27
 CALL free
 ldr w9,[sp,#432]
 cbz w9,.Lse_return
 adr x0,.Lse_hook_name
 add x1,sp,#436
 mov w9,#1
 str w9,[x1]
 add x2,sp,#440
 mov x3,#17
 CALL __yomhook_MOD_dr_hook_default8
.Lse_return:
 ldp x19,x20,[sp,#192]
 ldp x21,x22,[sp,#208]
 ldp x23,x24,[sp,#224]
 ldp x25,x26,[sp,#240]
 ldp x27,x28,[sp,#256]
 ldp x29,x30,[sp,#272]
 ldr x18,[sp,#288]
 add sp,sp,#1024
 ret
.Lse_reject:
 brk #0x533
.size md2asm_soil_energy_support_7358525,.-md2asm_soil_energy_support_7358525
.section .rodata
.p2align 3
.Lse_one: .double 1.0
.Lse_half: .double 0.5
.Lse_hook_name: .ascii "SRFENE_MOD:SRFENE"
.section .note.GNU-stack,"",%progbits
