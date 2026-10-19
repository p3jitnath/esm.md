/* GPU physical setup route. Original interface and ordered arithmetic are preserved.
 * Contract: skills/md2asm-gpu/references/openifs/setup/physical_setup.md
 * Original source: src/openifs/setup/dynamical_configuration.S
 */
// Original contract: skills/md2asm/references/openifs/setup/dynamical_configuration.md
#include "../../support/gpu/preserved_scalar_calls.inc.S"
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_dynamical_configuration
.type md2asm_initialize_dynamical_configuration,%function
md2asm_initialize_dynamical_configuration:
 cbz x0,.Ldyn_bad_leaf
 cbz x1,.Ldyn_bad_leaf
 cmp x1,#64,lsl#12
 b.hi .Ldyn_bad_leaf
 adds x9,x0,x1
 b.cs .Ldyn_bad_leaf
 cbz x2,.Ldyn_bad_leaf
 tst x2,#7
 b.ne .Ldyn_bad_leaf
 cmp x3,#320
 b.lo .Ldyn_bad_leaf
 adds x10,x2,#320
 b.cs .Ldyn_bad_leaf
 cmp x2,x9
 b.hs .Ldyn_disjoint
 cmp x0,x10
 b.lo .Ldyn_bad_leaf
.Ldyn_disjoint:
 mrs x9,fpcr
 cbnz x9,.Ldyn_bad_leaf
 stp x29,x30,[sp,#-48]!
 stp x19,x20,[sp,#16]
 str x18,[sp,#32]
 mov x29,sp
 mov x19,x2
 adr x2,.Ldyn_group
 mov x3,#10
 bl md2asm_require_empty_physics_group
 cbnz w0,.Ldyn_bad
 str wzr,[x19,#284]
 adr x9,.Ldyn_literal_RT00_DYN
 ldr d0,[x9]
 str d0,[x19,#64]
 adr x9,.Ldyn_literal_RP00_DYN
 ldr d0,[x9]
 str d0,[x19,#72]
 str xzr,[x19,#80]
 str xzr,[x19,#88]
 str wzr,[x19,#300]
 str xzr,[x19,#56]
 adr x9,.Ldyn_literal_RUSPLRADI
 ldr d0,[x9]
 str d0,[x19,#24]
 adr x9,.Ldyn_literal_RUSCORIOI
 ldr d0,[x9]
 str d0,[x19,#40]
 adr x9,.Ldyn_literal_RUSPLRG
 ldr d0,[x9]
 str d0,[x19,#48]
 fmov d1,#1.0
 ldr d0,[x19,#24]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d2,destination,d1,real,x16,0,d0
 str d2,[x19,#16]
 fmov d1,#1.0
 ldr d0,[x19,#40]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d2,destination,d1,real,x16,0,d0
 str d2,[x19,#32]
 fmov d1,#1.0
 ldr d0,[x19,#48]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d2,destination,d1,real,x16,0,d0
 str d2,[x19,#0]
 adr x9,.Ldyn_literal_RPLDARE
 ldr d0,[x9]
 str d0,[x19,#8]
 mov x9,#0x2020202020202020
 str x9,[x19,#304]
 str w9,[x19,#312]
 mov w9,#-1
 str w9,[x19,#292]
 str wzr,[x19,#272]
 str wzr,[x19,#276]
 mov w9,#9
 str w9,[x19,#296]
 str wzr,[x19,#280]
 adr x9,.Ldyn_literal_RDELTA_T
 ldr d0,[x9]
 str d0,[x19,#112]
 adr x9,.Ldyn_literal_RDELTA_THETA
 ldr d0,[x9]
 str d0,[x19,#120]
 adr x9,.Ldyn_literal_RSIGMAB
 ldr d0,[x9]
 str d0,[x19,#96]
 fmov d1,#1.0
 ldr d0,[x19,#96]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d2,destination,d1,real,x16,0,d0
 str d2,[x19,#104]
 adr x9,.Ldyn_literal_RPRESSURE_SCALE
 ldr d0,[x9]
 str d0,[x19,#128]
 adr x9,.Ldyn_literal_RHS_KAPPA
 ldr d0,[x9]
 str d0,[x19,#168]
 str wzr,[x19,#288]
 adr x9,.Ldyn_literal_RTHSW_0
 ldr d0,[x9]
 str d0,[x19,#176]
 adr x9,.Ldyn_literal_RPHSW_PL
 ldr d0,[x9]
 str d0,[x19,#200]
 adr x9,.Ldyn_literal_RPHSW_D
 ldr d0,[x9]
 str d0,[x19,#184]
 adr x9,.Ldyn_literal_RJACSLDIA
 ldr d0,[x9]
 str d0,[x19,#224]
 adr x9,.Ldyn_literal_RLIPSLDIA
 ldr d0,[x9]
 str d0,[x19,#232]
 fmov d1,#1.0
 ldr d0,[x19,#24]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d2,destination,d1,real,x16,0,d0
 str d2,[x19,#16]
 fmov d1,#1.0
 ldr d0,[x19,#40]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,4,none,comparison,d0,real,x16,0,zero
 b.eq .Ldyn_zero_coriolis
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d2,destination,d1,real,x16,0,d0
 str d2,[x19,#32]
 b .Ldyn_coriolis_done
.Ldyn_zero_coriolis:
 str xzr,[x19,#32]
.Ldyn_coriolis_done:
 fmov d1,#1.0
 ldr d0,[x19,#48]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d2,destination,d1,real,x16,0,d0
 str d2,[x19,#0]
 mov w0,#0
 b .Ldyn_return
.Ldyn_bad:
 mov w0,#2
.Ldyn_return:
 ldr x18,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#48
 ret
.Ldyn_bad_leaf:
 mov w0,#2
 ret
.size md2asm_initialize_dynamical_configuration,.-md2asm_initialize_dynamical_configuration
.section .rodata
.Ldyn_group:
 .ascii "NAMDYNCORE"
.p2align 3
.Ldyn_literal_RT00_DYN:
 .double 288.15
.Ldyn_literal_RP00_DYN:
 .double 101315.0
.Ldyn_literal_RUSPLRADI:
 .double 1.0
.Ldyn_literal_RUSCORIOI:
 .double 1.0
.Ldyn_literal_RUSPLRG:
 .double 1.0
.Ldyn_literal_RPLDARE:
 .double 1.0
.Ldyn_literal_RDELTA_T:
 .double 60.0
.Ldyn_literal_RDELTA_THETA:
 .double 10.0
.Ldyn_literal_RSIGMAB:
 .double 0.7
.Ldyn_literal_RPRESSURE_SCALE:
 .double 0.00001
.Ldyn_literal_RHS_KAPPA:
 .quad 0x3fd2492492492492
.Ldyn_literal_RTHSW_0:
 .double 200.0
.Ldyn_literal_RPHSW_PL:
 .double 10.0
.Ldyn_literal_RPHSW_D:
 .double 10000.0
.Ldyn_literal_RJACSLDIA:
 .double 1.5
.Ldyn_literal_RLIPSLDIA:
 .double 5.0
.section .note.GNU-stack,"",%progbits
