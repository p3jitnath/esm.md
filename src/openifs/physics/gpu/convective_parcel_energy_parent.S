.equ CE_CAPE,0 // Contract: skills/md2asm-gpu/references/openifs/physics/convective_energy_diagnostics.md. Accepted ordered parcel assembly.
.equ CE_CIN,1
.equ CE_THMIX,2
.equ CE_QMIX,3
.equ CE_PMIX,4
.equ CE_PLCL,5
.equ CE_EXN,6
.equ CE_THETAD,7
.equ CE_THV,8
.equ CE_ZDZ,9
.equ CE_TU,10
.equ CE_QS,11
.equ CE_PAPMASK,12
.equ CE_TMIX,13
.equ CE_THVMIX,14
.equ CE_THETEU,15
.equ CE_CIN2,16
.equ CE_PMIXA,17
.equ CE_ZMASK,18
.equ CE_DEPMASK,19
.equ CE_JDEP,20


// Direct CUANCAPE2 from formulations/openifs/physics/convective_energy_diagnostics.md.
// ABI and ordered arithmetic: skills/md2asm/references/openifs/physics/convective_energy_diagnostics.md.
// Original source: arpifs/phys_ec/cuancape2.F90.
.text
.p2align 4
.macro ARG reg,index
 ldr \reg,[x19,#(\index*8)]
.endm
.macro IN reg,index
 ARG x9,\index
 ldr \reg,[x9,x20,lsl #3]
.endm
.macro OUT reg,index
 ARG x9,\index
 str \reg,[x9,x20,lsl #3]
.endm
.macro IN2 reg,index,col=x21
 ARG x9,\index
 madd x10,\col,x22,x20
 ldr \reg,[x9,x10,lsl #3]
.endm
.macro OUT2 reg,index,col=x21
 ARG x9,\index
 madd x10,\col,x22,x20
 str \reg,[x9,x10,lsl #3]
.endm
.macro L reg,id
 ldr x9,[sp,#(3072+\id*8)]
 ldr \reg,[x9,x20,lsl #3]
.endm
.macro LS reg,id
 ldr x9,[sp,#(3072+\id*8)]
 str \reg,[x9,x20,lsl #3]
.endm
.macro L2 reg,id,col=x21
 ldr x9,[sp,#(3072+\id*8)]
 madd x10,\col,x22,x20
 ldr \reg,[x9,x10,lsl #3]
.endm
.macro LS2 reg,id,col=x21
 ldr x9,[sp,#(3072+\id*8)]
 madd x10,\col,x22,x20
 str \reg,[x9,x10,lsl #3]
.endm
.macro LI reg,id
 ldr x9,[sp,#(3072+\id*8)]
 ldr \reg,[x9,x20,lsl #2]
.endm
.macro LIS reg,id
 ldr x9,[sp,#(3072+\id*8)]
 str \reg,[x9,x20,lsl #2]
.endm
.macro LI2 reg,id,col=x21
 ldr x9,[sp,#(3072+\id*8)]
 madd x10,\col,x22,x20
 ldr \reg,[x9,x10,lsl #2]
.endm
.macro LIS2 reg,id,col=x21
 ldr x9,[sp,#(3072+\id*8)]
 madd x10,\col,x22,x20
 str \reg,[x9,x10,lsl #2]
.endm
.macro CONST reg,name
 adr x9,.Lce_\name
 ldr \reg,[x9]
.endm
.macro GLOBAL reg,module,name
 adrp x9,:got:__\module\()_MOD_\name
 ldr x9,[x9,:got_lo12:__\module\()_MOD_\name]
 ldr \reg,[x9]
.endm
.macro CALL name
 str x18,[sp,#2016]
 bl \name
 ldr x18,[sp,#2016]
.endm
.macro ROWS label
 mov x20,x23
\label:
.endm
.macro NEXT label
 add x20,x20,#1
 cmp x20,x24
 b.lt \label
.endm
// Revision 2 preserves the subfreezing temperature sign across CONST scratch.
.global md2asm_convective_energy_diagnostics_phase_r2_7358525
.type md2asm_convective_energy_diagnostics_phase_r2_7358525,%function
.global md2asm_convective_energy_diagnostics_7358525
.type md2asm_convective_energy_diagnostics_7358525,%function
md2asm_convective_energy_diagnostics_phase_r2_7358525:
md2asm_convective_energy_diagnostics_7358525:
 mov x16,sp
 sub sp,sp,#1,lsl #12
 add x17,sp,#1024
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
 str x18,[x17,#160]
 add x19,sp,#1280
 stp x0,x1,[x19]
 stp x2,x3,[x19,#16]
 stp x4,x5,[x19,#32]
 stp x6,x7,[x19,#48]
 mov x10,#8
.Lce_arguments:
 ldr x9,[x16],#8
 str x9,[x19,x10,lsl #3]
 add x10,x10,#1
 cmp x10,#13
 b.lt .Lce_arguments
 mrs x9,fpcr
 cbnz x9,.Lce_reject
 ARG x25,0
 ARG x9,1
 ldr w9,[x9,#4]
 cbnz w9,.Lce_reject
 ARG x9,4
 ldr w22,[x9]
 cmp w22,#1
 b.lt .Lce_reject
 cmp w22,#4096
 b.gt .Lce_reject
 ARG x9,5
 ldr w28,[x9]
 cmp w28,#4
 b.lt .Lce_reject
 cmp w28,#512
 b.gt .Lce_reject
 ARG x9,2
 ldrsw x23,[x9]
 sub x23,x23,#1
 cmp x23,#0
 b.lt .Lce_reject
 ARG x9,3
 ldrsw x24,[x9]
 cmp x24,x22
 b.gt .Lce_reject
 cmp x24,x23
 b.le .Lce_reject
 ldr w9,[x25,#308]
 cmp w9,#3
 b.lt .Lce_reject
 cmp w9,w28
 b.ge .Lce_reject
 str w9,[sp,#1448]
 ldr w9,[x25,#312]
 cmp w9,#1
 b.lt .Lce_reject
 ldr w10,[sp,#1448]
 cmp w9,w10
 b.ge .Lce_reject
 str w9,[sp,#1452]
 ldr w9,[x25,#320]
 ldr w10,[sp,#1452]
 cmp w9,w10
 b.lt .Lce_reject
 cmp w9,w28
 b.ge .Lce_reject
 str w9,[sp,#1456]
 adrp x9,:got:__yomhook_MOD_lhook
 ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
 ldr w9,[x9]
 cmp w9,#1
 b.hi .Lce_reject
 str w9,[sp,#1496]
 cbz w9,.Lce_entry_hook_done
 adr x0,.Lce_hook_name
 add x1,sp,#1500
 str wzr,[x1]
 add x2,sp,#1504
 mov x3,#8
 CALL __yomhook_MOD_dr_hook_default8
.Lce_entry_hook_done:
 mov x0,#100
 mul x0,x28,x0
 add x0,x0,#60
 mul x0,x0,x22
 add x0,x0,#336
 CALL malloc
 cbz x0,.Lce_reject
 str x0,[sp,#1512]
 mov x11,x0
 str x11,[sp,#3072] // CAPE
 mul x12,x22,x28
 add x11,x11,x12,lsl #3
 add x11,x11,#15
 and x11,x11,#-16
 str x11,[sp,#3080] // CIN
 mul x12,x22,x28
 add x11,x11,x12,lsl #3
 add x11,x11,#15
 and x11,x11,#-16
 str x11,[sp,#3088] // THMIX
 mul x12,x22,x28
 add x11,x11,x12,lsl #3
 add x11,x11,#15
 and x11,x11,#-16
 str x11,[sp,#3096] // QMIX
 mul x12,x22,x28
 add x11,x11,x12,lsl #3
 add x11,x11,#15
 and x11,x11,#-16
 str x11,[sp,#3104] // PMIX
 mul x12,x22,x28
 add x11,x11,x12,lsl #3
 add x11,x11,#15
 and x11,x11,#-16
 str x11,[sp,#3112] // PLCL
 mul x12,x22,x28
 add x11,x11,x12,lsl #3
 add x11,x11,#15
 and x11,x11,#-16
 str x11,[sp,#3120] // EXN
 mul x12,x22,x28
 add x11,x11,x12,lsl #3
 add x11,x11,#15
 and x11,x11,#-16
 str x11,[sp,#3128] // THETAD
 mul x12,x22,x28
 add x11,x11,x12,lsl #3
 add x11,x11,#15
 and x11,x11,#-16
 str x11,[sp,#3136] // THV
 mul x12,x22,x28
 add x11,x11,x12,lsl #3
 add x11,x11,#15
 and x11,x11,#-16
 str x11,[sp,#3144] // ZDZ
 mul x12,x22,x28
 add x11,x11,x12,lsl #3
 add x11,x11,#15
 and x11,x11,#-16
 str x11,[sp,#3152] // TU
 mul x12,x22,x28
 add x11,x11,x12,lsl #3
 add x11,x11,#15
 and x11,x11,#-16
 str x11,[sp,#3160] // QS
 mul x12,x22,x28
 add x11,x11,x12,lsl #3
 add x11,x11,#15
 and x11,x11,#-16
 str x11,[sp,#3168] // PAPMASK
 mul x12,x22,x28
 add x11,x11,x12,lsl #2
 add x11,x11,#15
 and x11,x11,#-16
 str x11,[sp,#3176] // TMIX
 add x11,x11,x22,lsl #3
 add x11,x11,#15
 and x11,x11,#-16
 str x11,[sp,#3184] // THVMIX
 add x11,x11,x22,lsl #3
 add x11,x11,#15
 and x11,x11,#-16
 str x11,[sp,#3192] // THETEU
 add x11,x11,x22,lsl #3
 add x11,x11,#15
 and x11,x11,#-16
 str x11,[sp,#3200] // CIN2
 add x11,x11,x22,lsl #3
 add x11,x11,#15
 and x11,x11,#-16
 str x11,[sp,#3208] // PMIXA
 add x11,x11,x22,lsl #3
 add x11,x11,#15
 and x11,x11,#-16
 str x11,[sp,#3216] // ZMASK
 add x11,x11,x22,lsl #2
 add x11,x11,#15
 and x11,x11,#-16
 str x11,[sp,#3224] // DEPMASK
 add x11,x11,x22,lsl #2
 add x11,x11,#15
 and x11,x11,#-16
 str x11,[sp,#3232] // JDEP
 mov x12,#3
 mul x12,x12,x22
 add x11,x11,x12,lsl #2
 add x11,x11,#15
 and x11,x11,#-16

 CALL md2asm_convective_thermodynamic_gpu_phase
 CALL md2asm_convective_hydrostatic_gpu_phase
 CALL md2asm_convective_departure_gpu_phase
 // Complete50/100hPa mixed preparation; original recomputed-parcel setup follows.
 CALL md2asm_convective_mixed_layer_gpu_phase
 mov x26,#0
.Lce_recomputed_parcel:
 CALL md2asm_convective_recomputed_parcel_gpu_phase
 cbnz x0,.Lce_fused_parcel_done
 sub x21,x28,#2
 // Complete recomputed parcel initial phase.
 CALL md2asm_convective_recomputed_initial_gpu_phase
 sub x21,x28,#3
 ldrsw x11,[sp,#1452]
 sub x11,x11,#1
 str x11,[sp,#1536]
 cmp x21,x11
 b.lt .Lce_recomputed_ascent_done
.Lce_recomputed_ascent_level:
 // Complete recomputed parcel pre_child phase.
 CALL md2asm_convective_recomputed_pre_child_gpu_phase
 // Preserve all twelve formal child addresses, including omitted optional null.
 ARG x0,1
 ARG x1,2
 ARG x2,3
 ARG x3,4
 ARG x4,5
 add w9,w21,#1
 str w9,[sp,#1444]
 add x5,sp,#1444
 ARG x6,6
 mul x9,x21,x22
 add x6,x6,x9,lsl #3
 ldr x7,[sp,#(3072+CE_TU*8)]
 ldr x9,[sp,#(3072+CE_QS*8)]
 str x9,[sp]
 ldr x9,[sp,#(3072+CE_ZMASK*8)]
 str x9,[sp,#8]
 mov w9,#1
 str w9,[sp,#1440]
 add x9,sp,#1440
 str x9,[sp,#16]
 str xzr,[sp,#24]
 CALL md2asm_cuadjtq
 // Complete recomputed parcel post_child phase.
 CALL md2asm_convective_recomputed_post_child_gpu_phase
 sub x21,x21,#1
 ldr x11,[sp,#1536]
 cmp x21,x11
 b.ge .Lce_recomputed_ascent_level
.Lce_recomputed_ascent_done:
 // Complete recomputed parcel output phase.
 CALL md2asm_convective_recomputed_output_gpu_phase
.Lce_fused_parcel_done:
 add x26,x26,#1
 cmp x26,#3
 b.lt .Lce_recomputed_parcel
 ldr x0,[sp,#1512]
 CALL free
 ldr w9,[sp,#1496]
 cbz w9,.Lce_exit_hook_done
 adr x0,.Lce_hook_name
 add x1,sp,#1500
 mov w9,#1
 str w9,[x1]
 add x2,sp,#1504
 mov x3,#8
 CALL __yomhook_MOD_dr_hook_default8
.Lce_exit_hook_done:
 add x17,sp,#1024
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
 ldr x18,[x17,#160]
 add sp,sp,#1,lsl #12
 ret
.Lce_reject:
 brk #0x53a
.size md2asm_convective_energy_diagnostics_phase_r2_7358525,.-md2asm_convective_energy_diagnostics_phase_r2_7358525
.size md2asm_convective_energy_diagnostics_7358525,.-md2asm_convective_energy_diagnostics_7358525
.section .rodata
.p2align 3
.Lce_one: .double 1.0
.Lce_half: .double 0.5
.Lce_pressure_eighty: .double 8000.0
.Lce_pressure_sixty: .double 6000.0
.Lce_pressure_thirty: .double 3000.0
.Lce_pressure_departure_depth: .double 35000.0
.Lce_pressure_fifty: .double 5000.0
.Lce_pressure_hundred: .double 10000.0
.Lce_saturation_floor: .double 0.00000001
.Lce_dewpoint_floor: .double 0.0001
.Lce_lcl_first: .double 0.212
.Lce_lcl_second: .double 0.001571
.Lce_lcl_third: .double 0.000436
.Lce_condensation_minimum: .double 160.0
.Lce_small_energy: .double 20.0
.Lce_hook_name: .ascii "CUANCAPE2"
.section .note.GNU-stack,"",%progbits
