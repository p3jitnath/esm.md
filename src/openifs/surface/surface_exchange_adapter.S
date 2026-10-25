/* Shared default and original-source selection: skills/md2asm/references/openifs/surface/runtime_surface_turbulence.md. */
#ifndef MD2ASM_SURFACE_EXCHANGE_CONTROLLER_ENTRY
#define MD2ASM_SURFACE_EXCHANGE_CONTROLLER_ENTRY md2asm_surface_exchange_controller_sea_r2_7358525
#endif
/* Contract: skills/md2asm/references/openifs/surface/surface_private_bindings.md. */
// Direct SURFEXCDRIVER ABI adapter; all numerical stages belong to its direct child.
// GET_SURF resolves through the owned registry metadata interface.
.text
.p2align 4
.macro ARG reg,arg
 ldr \reg,[x19,#(\arg*8)]
.endm
.macro CALL name
 str x18,[sp,#2376]
 bl \name
 ldr x18,[sp,#2376]
.endm
.macro PLACE dest
 .if \dest<8
  mov x\dest,x9
 .else
  str x9,[sp,#((\dest-8)*8)]
 .endif
.endm
.global md2asm_surface_exchange_adapter_sea_r2_7358525
.type md2asm_surface_exchange_adapter_sea_r2_7358525,%function
md2asm_surface_exchange_adapter_sea_r2_7358525:
 mov x16,sp
 sub sp,sp,#4096
 add x17,sp,#1024
 stp x19,x20,[x17]
 stp x21,x22,[x17,#16]
 stp x23,x24,[x17,#32]
 stp x25,x26,[x17,#48]
 stp x27,x28,[x17,#64]
 stp x29,x30,[x17,#80]
 str x18,[x17,#96]
 add x19,sp,#1280
 stp x0,x1,[x19]
 stp x2,x3,[x19,#16]
 stp x4,x5,[x19,#32]
 stp x6,x7,[x19,#48]
 mov x10,#8
.Lsa_arguments:
 ldr x9,[x16],#8
 str x9,[x19,x10,lsl #3]
 add x10,x10,#1
 cmp x10,#131
 b.lt .Lsa_arguments
 ldr x9,[x16]
 str x9,[sp,#2384]
 cmp x9,#1
 b.ne .Lsa_reject
 mrs x9,fpcr
 cbnz x9,.Lsa_reject
 adrp x9,:got:__yomhook_MOD_lhook
 ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
 ldr w9,[x9]
 cmp w9,#1
 b.hi .Lsa_reject
 str w9,[sp,#2360]
 cbz w9,.Lsa_entry_hook_done
 adr x0,.Lsa_hook_name
 add x1,sp,#2364
 str wzr,[x1]
 add x2,sp,#2368
 mov x3,#13
 CALL __yomhook_MOD_dr_hook_default8
.Lsa_entry_hook_done:
 ARG x0,0
 CALL __yos_surf_MOD_get_surf
 mov x20,x0
 cbz x20,.Lsa_reject
 // KTVL dimension 1 >= KLON
 ARG x9,27
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // KCO2TYP dimension 1 >= KLON
 ARG x9,28
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // KTVH dimension 1 >= KLON
 ARG x9,29
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PCVL dimension 1 >= KLON
 ARG x9,30
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PCVH dimension 1 >= KLON
 ARG x9,31
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PCUR dimension 1 >= KLON
 ARG x9,32
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PLAIL dimension 1 >= KLON
 ARG x9,33
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PLAIH dimension 1 >= KLON
 ARG x9,34
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PSNM dimension 1 >= KLON
 ARG x9,37
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PSNM dimension 2 >= KLEVSN
 ARG x9,37
 ldr x10,[x9,#80]
 ARG x12,10
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PRSN dimension 1 >= KLON
 ARG x9,38
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PRSN dimension 2 >= KLEVSN
 ARG x9,38
 ldr x10,[x9,#80]
 ARG x12,10
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PMU0 dimension 1 >= KLON
 ARG x9,39
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PUMLEV dimension 1 >= KLON
 ARG x9,41
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PVMLEV dimension 1 >= KLON
 ARG x9,42
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PTMLEV dimension 1 >= KLON
 ARG x9,43
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PQMLEV dimension 1 >= KLON
 ARG x9,44
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PCMLEV dimension 1 >= KLON
 ARG x9,45
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PAPHMS dimension 1 >= KLON
 ARG x9,46
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PGEOMLEV dimension 1 >= KLON
 ARG x9,47
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PCPTGZLEV dimension 1 >= KLON
 ARG x9,48
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PSST dimension 1 >= KLON
 ARG x9,49
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PTSKM1M dimension 1 >= KLON
 ARG x9,50
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PCHAR dimension 1 >= KLON
 ARG x9,51
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PCHARHQ dimension 1 >= KLON
 ARG x9,52
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PSSRFL dimension 1 >= KLON
 ARG x9,53
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PSLRFL dimension 1 >= KLON
 ARG x9,54
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PEMIS dimension 1 >= KLON
 ARG x9,55
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PTICE dimension 1 >= KLON
 ARG x9,56
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PTSN dimension 1 >= KLON
 ARG x9,57
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PTSN dimension 2 >= KLEVSN
 ARG x9,57
 ldr x10,[x9,#80]
 ARG x12,10
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PWLMX dimension 1 >= KLON
 ARG x9,63
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PUCURR dimension 1 >= KLON
 ARG x9,64
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PVCURR dimension 1 >= KLON
 ARG x9,65
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PTSAM1M dimension 1 >= KLON
 ARG x9,67
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PTSAM1M dimension 2 >= KLEVS
 ARG x9,67
 ldr x10,[x9,#80]
 ARG x12,5
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PWSAM1M dimension 1 >= KLON
 ARG x9,68
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PWSAM1M dimension 2 >= KLEVS
 ARG x9,68
 ldr x10,[x9,#80]
 ARG x12,5
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // KSOTY dimension 1 >= KLON
 ARG x9,69
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PFRTI dimension 1 >= KLON
 ARG x9,70
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PFRTI dimension 2 >= KTILES
 ARG x9,70
 ldr x10,[x9,#80]
 ARG x12,6
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PALBTI dimension 1 >= KLON
 ARG x9,71
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PALBTI dimension 2 >= KTILES
 ARG x9,71
 ldr x10,[x9,#80]
 ARG x12,6
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PUSTRTI dimension 1 >= KLON
 ARG x9,72
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PUSTRTI dimension 2 >= KTILES
 ARG x9,72
 ldr x10,[x9,#80]
 ARG x12,6
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PVSTRTI dimension 1 >= KLON
 ARG x9,73
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PVSTRTI dimension 2 >= KTILES
 ARG x9,73
 ldr x10,[x9,#80]
 ARG x12,6
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PAHFSTI dimension 1 >= KLON
 ARG x9,74
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PAHFSTI dimension 2 >= KTILES
 ARG x9,74
 ldr x10,[x9,#80]
 ARG x12,6
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PEVAPTI dimension 1 >= KLON
 ARG x9,75
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PEVAPTI dimension 2 >= KTILES
 ARG x9,75
 ldr x10,[x9,#80]
 ARG x12,6
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PTSKTI dimension 1 >= KLON
 ARG x9,76
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PTSKTI dimension 2 >= KTILES
 ARG x9,76
 ldr x10,[x9,#80]
 ARG x12,6
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PANDAYVT dimension 1 >= KLON
 ARG x9,77
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PANDAYVT dimension 2 >= KVTYPES
 ARG x9,77
 ldr x10,[x9,#80]
 ARG x12,7
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PANFMVT dimension 1 >= KLON
 ARG x9,78
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PANFMVT dimension 2 >= KVTYPES
 ARG x9,78
 ldr x10,[x9,#80]
 ARG x12,7
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PZ0M dimension 1 >= KLON
 ARG x9,79
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PZ0H dimension 1 >= KLON
 ARG x9,80
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PSSRFLTI dimension 1 >= KLON
 ARG x9,81
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PSSRFLTI dimension 2 >= KTILES
 ARG x9,81
 ldr x10,[x9,#80]
 ARG x12,6
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PQSTI dimension 1 >= KLON
 ARG x9,82
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PQSTI dimension 2 >= KTILES
 ARG x9,82
 ldr x10,[x9,#80]
 ARG x12,6
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PDQSTI dimension 1 >= KLON
 ARG x9,83
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PDQSTI dimension 2 >= KTILES
 ARG x9,83
 ldr x10,[x9,#80]
 ARG x12,6
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PCPTSTI dimension 1 >= KLON
 ARG x9,84
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PCPTSTI dimension 2 >= KTILES
 ARG x9,84
 ldr x10,[x9,#80]
 ARG x12,6
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PCFHTI dimension 1 >= KLON
 ARG x9,85
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PCFHTI dimension 2 >= KTILES
 ARG x9,85
 ldr x10,[x9,#80]
 ARG x12,6
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PCFQTI dimension 1 >= KLON
 ARG x9,86
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PCFQTI dimension 2 >= KTILES
 ARG x9,86
 ldr x10,[x9,#80]
 ARG x12,6
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PCSATTI dimension 1 >= KLON
 ARG x9,87
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PCSATTI dimension 2 >= KTILES
 ARG x9,87
 ldr x10,[x9,#80]
 ARG x12,6
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PCAIRTI dimension 1 >= KLON
 ARG x9,88
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PCAIRTI dimension 2 >= KTILES
 ARG x9,88
 ldr x10,[x9,#80]
 ARG x12,6
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PCPTSTIU dimension 1 >= KLON
 ARG x9,89
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PCPTSTIU dimension 2 >= KTILES
 ARG x9,89
 ldr x10,[x9,#80]
 ARG x12,6
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PCSATTIU dimension 1 >= KLON
 ARG x9,90
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PCSATTIU dimension 2 >= KTILES
 ARG x9,90
 ldr x10,[x9,#80]
 ARG x12,6
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PCAIRTIU dimension 1 >= KLON
 ARG x9,91
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PCAIRTIU dimension 2 >= KTILES
 ARG x9,91
 ldr x10,[x9,#80]
 ARG x12,6
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PRAQTI dimension 1 >= KLON
 ARG x9,92
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PRAQTI dimension 2 >= KTILES
 ARG x9,92
 ldr x10,[x9,#80]
 ARG x12,6
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PTSRF dimension 1 >= KLON
 ARG x9,93
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PTSRF dimension 2 >= KTILES
 ARG x9,93
 ldr x10,[x9,#80]
 ARG x12,6
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PLAMSK dimension 1 >= KLON
 ARG x9,94
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PLAMSK dimension 2 >= KTILES
 ARG x9,94
 ldr x10,[x9,#80]
 ARG x12,6
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PKHLEV dimension 1 >= KLON
 ARG x9,95
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PKCLEV dimension 1 >= KLON
 ARG x9,96
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PCFMLEV dimension 1 >= KLON
 ARG x9,97
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PKMFL dimension 1 >= KLON
 ARG x9,98
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PKHFL dimension 1 >= KLON
 ARG x9,99
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PKQFL dimension 1 >= KLON
 ARG x9,100
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PEVAPSNW dimension 1 >= KLON
 ARG x9,101
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PZ0MW dimension 1 >= KLON
 ARG x9,102
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PZ0HW dimension 1 >= KLON
 ARG x9,103
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PZ0QW dimension 1 >= KLON
 ARG x9,104
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PBLENDPP dimension 1 >= KLON
 ARG x9,105
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PCPTSPP dimension 1 >= KLON
 ARG x9,106
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PQSAPP dimension 1 >= KLON
 ARG x9,107
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PBUOMPP dimension 1 >= KLON
 ARG x9,108
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PZDLPP dimension 1 >= KLON
 ARG x9,109
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PDHTLS dimension 1 >= KLON
 ARG x9,122
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PDHTLS dimension 2 >= KTILES
 ARG x9,122
 ldr x10,[x9,#80]
 ARG x12,6
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PDHTLS dimension 3 >= KDHVTLS+KDHFTLS
 ARG x9,122
 ldr x10,[x9,#104]
 ARG x12,12
 ldrsw x12,[x12]
 mov x11,x12
 ARG x12,13
 ldrsw x12,[x12]
 add x11,x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PDHTSS dimension 1 >= KLON
 ARG x9,123
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PDHTSS dimension 2 >= KLEVSN
 ARG x9,123
 ldr x10,[x9,#80]
 ARG x12,10
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PDHTSS dimension 3 >= KDHVTSS+KDHFTSS
 ARG x9,123
 ldr x10,[x9,#104]
 ARG x12,14
 ldrsw x12,[x12]
 mov x11,x12
 ARG x12,15
 ldrsw x12,[x12]
 add x11,x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PDHTTS dimension 1 >= KLON
 ARG x9,124
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PDHTTS dimension 2 >= KLEVS
 ARG x9,124
 ldr x10,[x9,#80]
 ARG x12,5
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PDHTTS dimension 3 >= KDHVTTS+KDHFTTS
 ARG x9,124
 ldr x10,[x9,#104]
 ARG x12,16
 ldrsw x12,[x12]
 mov x11,x12
 ARG x12,17
 ldrsw x12,[x12]
 add x11,x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PDHTIS dimension 1 >= KLON
 ARG x9,125
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PDHTIS dimension 2 >= KLEVI
 ARG x9,125
 ldr x10,[x9,#80]
 ARG x12,11
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PDHTIS dimension 3 >= KDHVTIS+KDHFTIS
 ARG x9,125
 ldr x10,[x9,#104]
 ARG x12,18
 ldrsw x12,[x12]
 mov x11,x12
 ARG x12,19
 ldrsw x12,[x12]
 add x11,x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PHLICE dimension 1 >= KLON
 ARG x9,58
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PTLICE dimension 1 >= KLON
 ARG x9,59
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PTLWML dimension 1 >= KLON
 ARG x9,60
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PTHKICE dimension 1 >= KLON
 ARG x9,61
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PSNTICE dimension 1 >= KLON
 ARG x9,62
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PDHCO2S dimension 1 >= KLON
 ARG x9,128
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PDHCO2S dimension 2 >= 2
 ARG x9,128
 ldr x10,[x9,#80]
 mov x11,#2
 cmp x10,x11
 b.lt .Lsa_reject
 // PDHCO2S dimension 3 >= KDHVCO2S+KDHFCO2S
 ARG x9,128
 ldr x10,[x9,#104]
 ARG x12,21
 ldrsw x12,[x12]
 mov x11,x12
 ARG x12,22
 ldrsw x12,[x12]
 add x11,x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PDHVEGS dimension 1 >= KLON
 ARG x9,126
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PDHVEGS dimension 2 >= 2
 ARG x9,126
 ldr x10,[x9,#80]
 mov x11,#2
 cmp x10,x11
 b.lt .Lsa_reject
 // PDHVEGS dimension 3 >= KDHVVEGS+KDHFVEGS
 ARG x9,126
 ldr x10,[x9,#104]
 ARG x12,23
 ldrsw x12,[x12]
 mov x11,x12
 ARG x12,24
 ldrsw x12,[x12]
 add x11,x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PWETB dimension 1 >= KLON
 ARG x9,117
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PWETL dimension 1 >= KLON
 ARG x9,118
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PWETLU dimension 1 >= KLON
 ARG x9,119
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PWETH dimension 1 >= KLON
 ARG x9,120
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PWETHS dimension 1 >= KLON
 ARG x9,121
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PEXDIAG dimension 1 >= KLON
 ARG x9,127
 ldr x10,[x9,#56]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 // PEXDIAG dimension 2 >= KDIAG
 ARG x9,127
 ldr x10,[x9,#80]
 ARG x12,8
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lsa_reject
 ARG x9,1
 PLACE 0
 ARG x9,2
 PLACE 1
 ARG x9,3
 PLACE 2
 ARG x9,4
 PLACE 3
 ARG x9,5
 PLACE 4
 ARG x9,6
 PLACE 5
 ARG x9,7
 PLACE 6
 ARG x9,8
 PLACE 7
 ARG x9,9
 PLACE 8
 ARG x9,10
 PLACE 9
 ARG x9,11
 PLACE 10
 ARG x9,12
 PLACE 11
 ARG x9,13
 PLACE 12
 ARG x9,14
 PLACE 13
 ARG x9,15
 PLACE 14
 ARG x9,16
 PLACE 15
 ARG x9,17
 PLACE 16
 ARG x9,18
 PLACE 17
 ARG x9,19
 PLACE 18
 ARG x9,20
 PLACE 19
 ARG x9,25
 PLACE 20
 ARG x9,26
 PLACE 21
 ARG x9,27
 PLACE 22
 ARG x9,28
 PLACE 23
 ARG x9,29
 PLACE 24
 ARG x9,30
 PLACE 25
 ARG x9,31
 PLACE 26
 ARG x9,32
 PLACE 27
 ARG x9,33
 PLACE 28
 ARG x9,34
 PLACE 29
 ARG x9,35
 PLACE 30
 ARG x9,36
 PLACE 31
 ARG x9,37
 PLACE 32
 ARG x9,38
 PLACE 33
 ARG x9,39
 PLACE 34
 ARG x9,40
 PLACE 35
 ARG x9,41
 PLACE 36
 ARG x9,42
 PLACE 37
 ARG x9,43
 PLACE 38
 ARG x9,44
 PLACE 39
 ARG x9,45
 PLACE 40
 ARG x9,46
 PLACE 41
 ARG x9,47
 PLACE 42
 ARG x9,48
 PLACE 43
 ARG x9,49
 PLACE 44
 ARG x9,50
 PLACE 45
 ARG x9,51
 PLACE 46
 ARG x9,52
 PLACE 47
 ARG x9,53
 PLACE 48
 ARG x9,54
 PLACE 49
 ARG x9,55
 PLACE 50
 ARG x9,56
 PLACE 51
 ARG x9,57
 PLACE 52
 ARG x9,58
 PLACE 53
 ARG x9,59
 PLACE 54
 ARG x9,60
 PLACE 55
 ARG x9,61
 PLACE 56
 ARG x9,62
 PLACE 57
 ARG x9,63
 PLACE 58
 ARG x9,64
 PLACE 59
 ARG x9,65
 PLACE 60
 ARG x9,66
 PLACE 61
 ARG x9,67
 PLACE 62
 ARG x9,68
 PLACE 63
 ARG x9,69
 PLACE 64
 ARG x9,70
 PLACE 65
 ARG x9,71
 PLACE 66
 ARG x9,72
 PLACE 67
 ARG x9,73
 PLACE 68
 ARG x9,74
 PLACE 69
 ARG x9,75
 PLACE 70
 ARG x9,76
 PLACE 71
 ARG x9,77
 PLACE 72
 ARG x9,78
 PLACE 73
 ARG x9,79
 PLACE 74
 ARG x9,80
 PLACE 75
 ARG x9,81
 PLACE 76
 ARG x9,82
 PLACE 77
 ARG x9,83
 PLACE 78
 ARG x9,84
 PLACE 79
 ARG x9,85
 PLACE 80
 ARG x9,86
 PLACE 81
 ARG x9,87
 PLACE 82
 ARG x9,88
 PLACE 83
 ARG x9,89
 PLACE 84
 ARG x9,90
 PLACE 85
 ARG x9,91
 PLACE 86
 ARG x9,92
 PLACE 87
 ARG x9,93
 PLACE 88
 ARG x9,94
 PLACE 89
 ARG x9,95
 PLACE 90
 ARG x9,96
 PLACE 91
 ARG x9,97
 PLACE 92
 ARG x9,98
 PLACE 93
 ARG x9,99
 PLACE 94
 ARG x9,100
 PLACE 95
 ARG x9,101
 PLACE 96
 ARG x9,102
 PLACE 97
 ARG x9,103
 PLACE 98
 ARG x9,104
 PLACE 99
 ARG x9,105
 PLACE 100
 ARG x9,106
 PLACE 101
 ARG x9,107
 PLACE 102
 ARG x9,108
 PLACE 103
 ARG x9,109
 PLACE 104
 ARG x9,110
 PLACE 105
 ARG x9,111
 PLACE 106
 ARG x9,112
 PLACE 107
 ARG x9,113
 PLACE 108
 ARG x9,114
 PLACE 109
 ARG x9,115
 PLACE 110
 ARG x9,116
 PLACE 111
 ARG x9,117
 PLACE 112
 ARG x9,118
 PLACE 113
 ARG x9,119
 PLACE 114
 ARG x9,120
 PLACE 115
 ARG x9,121
 PLACE 116
 ARG x9,122
 PLACE 117
 ARG x9,123
 PLACE 118
 ARG x9,124
 PLACE 119
 ARG x9,125
 PLACE 120
 ARG x9,126
 PLACE 121
 ARG x9,127
 PLACE 122
 ARG x9,128
 PLACE 123
 ARG x9,129
 PLACE 124
 ARG x9,130
 PLACE 125
 mov x9,#3816
 add x9,x20,x9
 PLACE 126
 mov x9,#3960
 add x9,x20,x9
 PLACE 127
 mov x9,#10336
 add x9,x20,x9
 PLACE 128
 mov x9,#0
 add x9,x20,x9
 PLACE 129
 mov x9,#2344
 add x9,x20,x9
 PLACE 130
 mov x9,#7680
 add x9,x20,x9
 PLACE 131
 mov x9,#4104
 add x9,x20,x9
 PLACE 132
 mov x9,#11112
 add x9,x20,x9
 PLACE 133
 ldr x9,[sp,#2384]
 str x9,[sp,#1008]
 CALL MD2ASM_SURFACE_EXCHANGE_CONTROLLER_ENTRY
 ldr w9,[sp,#2360]
 cbz w9,.Lsa_return
 adr x0,.Lsa_hook_name
 add x1,sp,#2364
 mov w9,#1
 str w9,[x1]
 add x2,sp,#2368
 mov x3,#13
 CALL __yomhook_MOD_dr_hook_default8
.Lsa_return:
 add x17,sp,#1024
 ldp x19,x20,[x17]
 ldp x21,x22,[x17,#16]
 ldp x23,x24,[x17,#32]
 ldp x25,x26,[x17,#48]
 ldp x27,x28,[x17,#64]
 ldp x29,x30,[x17,#80]
 ldr x18,[x17,#96]
 add sp,sp,#4096
 ret
.Lsa_reject:
 brk #0x532
.size md2asm_surface_exchange_adapter_sea_r2_7358525,.-md2asm_surface_exchange_adapter_sea_r2_7358525
.section .rodata
.Lsa_hook_name: .ascii "SURFEXCDRIVER"
.section .note.GNU-stack,"",%progbits
