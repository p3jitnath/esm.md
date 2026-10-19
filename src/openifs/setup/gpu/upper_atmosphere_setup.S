/* GPU physical setup route. Original interface and ordered arithmetic are preserved.
 * Contract: skills/md2asm-gpu/references/openifs/setup/physical_setup.md
 * Original source: src/openifs/setup/upper_atmosphere_setup.S
 */
// Original contract: skills/md2asm/references/openifs/setup/upper_atmosphere_setup.md
#include "../../support/gpu/preserved_scalar_calls.inc.S"
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_upper_atmosphere_setup
.type md2asm_initialize_upper_atmosphere_setup,%function
md2asm_initialize_upper_atmosphere_setup:
 stp x29,x30,[sp,#-336]!
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 stp x22,x23,[sp,#48]
 stp x24,x25,[sp,#64]
 stp x26,x27,[sp,#80]
 str x28,[sp,#96]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 cbz x0,.Lupper_bad
 cbz x1,.Lupper_bad
 cmp x1,#64,lsl#12
 b.hi .Lupper_bad
 adds x9,x0,x1
 b.cs .Lupper_bad
 stp x0,x9,[sp,#128]
 cbz x21,.Lupper_bad
 tst x21,#7
 b.ne .Lupper_bad
 adds x9,x21,#48
 b.cs .Lupper_bad
 stp x21,x9,[sp,#144]
 cbz x22,.Lupper_bad
 tst x22,#7
 b.ne .Lupper_bad
 adds x9,x22,#72
 b.cs .Lupper_bad
 stp x22,x9,[sp,#160]
 mrs x9,fpcr
 cbnz x9,.Lupper_bad
 ldr w9,[x22,#48]
 cmp w9,#19
 b.ne .Lupper_bad
 ldr w9,[x22,#52]
 sub w9,w9,#1
 cmp w9,#99
 b.hi .Lupper_bad
 ldr w9,[x22,#56]
 cbnz w9,.Lupper_bad
 ldr w9,[x22,#60]
 cmp w9,#1
 b.hi .Lupper_bad
 ldr w9,[x22,#64]
 cmp w9,#1
 b.ne .Lupper_bad
 ldp x9,x10,[x22,#0]
 cmp x10,#152
 b.lo .Lupper_bad
 cbz x9,.Lupper_bad
 tst x9,#7
 b.ne .Lupper_bad
 adds x10,x9,#152
 b.cs .Lupper_bad
 stp x9,x10,[sp,#176]
 ldp x9,x10,[x22,#16]
 cmp x10,#160
 b.lo .Lupper_bad
 cbz x9,.Lupper_bad
 tst x9,#7
 b.ne .Lupper_bad
 adds x10,x9,#160
 b.cs .Lupper_bad
 stp x9,x10,[sp,#192]
 ldp x9,x10,[x22,#32]
 cmp x10,#160
 b.lo .Lupper_bad
 cbz x9,.Lupper_bad
 tst x9,#7
 b.ne .Lupper_bad
 adds x10,x9,#160
 b.cs .Lupper_bad
 stp x9,x10,[sp,#208]
 ldp x9,x10,[x21,#0]
 cmp x10,#496
 b.lo .Lupper_bad
 cbz x9,.Lupper_bad
 tst x9,#7
 b.ne .Lupper_bad
 adds x10,x9,#496
 b.cs .Lupper_bad
 stp x9,x10,[sp,#224]
 ldp x9,x10,[x21,#16]
 cmp x10,#160
 b.lo .Lupper_bad
 cbz x9,.Lupper_bad
 tst x9,#7
 b.ne .Lupper_bad
 adds x10,x9,#160
 b.cs .Lupper_bad
 stp x9,x10,[sp,#240]
 ldp x9,x10,[x21,#32]
 cmp x10,#32
 b.lo .Lupper_bad
 cbz x9,.Lupper_bad
 tst x9,#7
 b.ne .Lupper_bad
 adds x10,x9,#32
 b.cs .Lupper_bad
 stp x9,x10,[sp,#256]
 mov x9,#6
.Lupper_range_output:
 add x10,sp,#128
 add x10,x10,x9,lsl#4
 ldp x11,x12,[x10]
 add x13,sp,#128
 mov x14,#0
.Lupper_range_input:
 ldp x15,x16,[x13],#16
 cmp x11,x16
 b.hs .Lupper_range_next
 cmp x15,x12
 b.lo .Lupper_bad
.Lupper_range_next:
 add x14,x14,#1
 cmp x14,x9
 b.lo .Lupper_range_input
 add x9,x9,#1
 cmp x9,#9
 b.lo .Lupper_range_output
 ldr x9,[x22]
 adr x10,.Lupper_limits
 ldr x10,[x10]
 mov x11,#0
 mov x12,#0
.Lupper_pressure_domain:
 ldr x13,[x9,x12,lsl#3]
 cbz x13,.Lupper_bad
 cmp x13,x10
 b.hi .Lupper_bad
 cmp x13,x11
 b.lo .Lupper_bad
 mov x11,x13
 add x12,x12,#1
 cmp x12,#19
 b.lo .Lupper_pressure_domain
 ldr x9,[x22,#16]
 ldr x10,[x22,#32]
 mov x11,#0x3ff0000000000000
 mov x12,#0
.Lupper_hybrid_domain:
 ldr x13,[x9,x12,lsl#3]
 ldr x14,[x10,x12,lsl#3]
 and x15,x13,#0x7fffffffffffffff
 cmp x15,x11
 b.hi .Lupper_bad
 cmp x13,#0
 b.ge .Lupper_a_nonnegative
 cbnz x15,.Lupper_bad
.Lupper_a_nonnegative:
 and x15,x14,#0x7fffffffffffffff
 cmp x15,x11
 b.hi .Lupper_bad
 cmp x14,#0
 b.ge .Lupper_b_nonnegative
 cbnz x15,.Lupper_bad
.Lupper_b_nonnegative:
 add x12,x12,#1
 cmp x12,#20
 b.lo .Lupper_hybrid_domain
 mov x0,x19
 mov x1,x20
 adr x2,.Lupper_group0
 mov x3,#7
 bl md2asm_require_empty_physics_group
 cbnz w0,.Lupper_bad
 mov x0,x19
 mov x1,x20
 adr x2,.Lupper_group1
 mov x3,#9
 bl md2asm_require_empty_physics_group
 cbnz w0,.Lupper_bad
 mov x0,x19
 mov x1,x20
 adr x2,.Lupper_group2
 mov x3,#7
 bl md2asm_require_empty_physics_group
 cbnz w0,.Lupper_bad
 ldr x0,[x21]
 ldr x1,[x22]
 add x2,x22,#48
 bl md2asm_initialize_top_physics_parameters_raw
 ldr x0,[x21,#16]
 ldr x1,[x22]
 ldr w2,[x22,#48]
 bl md2asm_initialize_nonorographic_wave_parameters_raw
 ldr x0,[x21,#32]
 ldr x1,[x22,#16]
 ldr x2,[x22,#32]
 ldr w3,[x22,#48]
 ldr w4,[x22,#52]
 bl md2asm_initialize_convective_energy_controls_raw
 mov w0,#0
 b .Lupper_return
.Lupper_bad:
 mov w0,#2
.Lupper_return:
 ldr x28,[sp,#96]
 ldp x26,x27,[sp,#80]
 ldp x24,x25,[sp,#64]
 ldp x22,x23,[sp,#48]
 ldp x20,x21,[sp,#32]
 ldp x18,x19,[sp,#16]
 ldp x29,x30,[sp],#336
 ret
.size md2asm_initialize_upper_atmosphere_setup,.-md2asm_initialize_upper_atmosphere_setup
.p2align 4
.global md2asm_search_pressure_parameter_level
.global seapre_
.type md2asm_search_pressure_parameter_level,%function
md2asm_search_pressure_parameter_level:
seapre_:
 ldr w9,[x3]
 str w9,[x1]
 ldr d0,[x0]
.Lupper_search_pressure:
 sub w10,w9,#1
 ldr d1,[x2,x10,lsl#3]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,4,none,comparison,d0,real,x16,0,d1
 b.gt .Lupper_search_next
 str w9,[x1]
.Lupper_search_next:
 subs w9,w9,#1
 b.ne .Lupper_search_pressure
 ret
.size md2asm_search_pressure_parameter_level,.-md2asm_search_pressure_parameter_level
.p2align 4
.global md2asm_initialize_top_physics_parameters_raw
.type md2asm_initialize_top_physics_parameters_raw,%function
md2asm_initialize_top_physics_parameters_raw:
 stp x29,x30,[sp,#-64]!
 stp x19,x20,[sp,#16]
 stp x21,x18,[sp,#32]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 mov x21,x2
 str xzr,[x19,#272]
 str xzr,[x19,#280]
 str xzr,[x19,#288]
 str xzr,[x19,#296]
 str xzr,[x19,#304]
 str xzr,[x19,#328]
 adr x9,.Lupper_top_ET850
 ldr x9,[x9]
 str x9,[x19,#312]
 adr x9,.Lupper_top_ET950
 ldr x9,[x9]
 str x9,[x19,#320]
 str xzr,[x19,#336]
 str xzr,[x19,#344]
 str xzr,[x19,#352]
 str xzr,[x19,#360]
 str xzr,[x19,#368]
 str xzr,[x19,#376]
 str xzr,[x19,#384]
 str xzr,[x19,#392]
 str xzr,[x19,#400]
 mov w9,#1
 str w9,[x19,#200]
 mov w9,#1
 str w9,[x19,#204]
 mov w9,#1
 str w9,[x19,#208]
 mov w9,#1
 str w9,[x19,#212]
 mov w9,#1
 str w9,[x19,#216]
 mov w9,#1
 str w9,[x19,#228]
 mov w9,#1
 str w9,[x19,#232]
 mov w9,#1
 str w9,[x19,#236]
 mov w9,#1
 str w9,[x19,#240]
 mov w9,#1
 str w9,[x19,#244]
 mov w9,#1
 str w9,[x19,#248]
 mov w9,#1
 str w9,[x19,#252]
 ldr w9,[x21]
 str w9,[x19,#256]
 ldr w9,[x21]
 str w9,[x19,#260]
 ldr w9,[x21]
 str w9,[x19,#264]
 str xzr,[x19,#408]
 str xzr,[x19,#416]
 str xzr,[x19,#424]
 str xzr,[x19,#432]
 str xzr,[x19,#440]
 str xzr,[x19,#448]
 str xzr,[x19,#456]
 str xzr,[x19,#464]
 str xzr,[x19,#472]
 adr x9,.Lupper_top_RFMESOQ
 ldr x9,[x9]
 str x9,[x19,#192]
 str xzr,[x19,#480]
 adr x9,.Lupper_top_TPSCLIM
 ldr x9,[x9]
 str x9,[x19,#488]
 add x0,x19,#312
 add x1,x19,#220
 mov x2,x20
 mov x3,x21
 bl md2asm_search_pressure_parameter_level
 add x0,x19,#320
 add x1,x19,#224
 mov x2,x20
 mov x3,x21
 bl md2asm_search_pressure_parameter_level
 ldp x21,x18,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#64
 ret
.size md2asm_initialize_top_physics_parameters_raw,.-md2asm_initialize_top_physics_parameters_raw
.p2align 4
.global md2asm_initialize_nonorographic_wave_parameters_raw
.type md2asm_initialize_nonorographic_wave_parameters_raw,%function
md2asm_initialize_nonorographic_wave_parameters_raw:
 movz w9,#0x4152
 movk w9,#0x444e,lsl#16
 str w9,[x0,#0]
 adr x9,.Lupper_wave_NORGWD_DZFRON
 ldr x9,[x9]
 str x9,[x0,#136]
 adr x9,.Lupper_wave_NORGWD_GFRON
 ldr x9,[x9]
 str x9,[x0,#144]
 str xzr,[x0,#152]
 adr x9,.Lupper_wave_NORGWD_PRMAX
 ldr x9,[x9]
 str x9,[x0,#8]
 adr x9,.Lupper_wave_NORGWD_DZ
 ldr x9,[x9]
 str x9,[x0,#16]
 adr x9,.Lupper_wave_NORGWD_PTROPO
 ldr x9,[x9]
 str x9,[x0,#24]
 adr x9,.Lupper_wave_NORGWD_RUWMAX
 ldr x9,[x9]
 str x9,[x0,#40]
 adr x9,.Lupper_wave_NORGWD_SAT
 ldr x9,[x9]
 str x9,[x0,#48]
 adr x9,.Lupper_wave_NORGWD_RDISS
 ldr x9,[x9]
 str x9,[x0,#56]
 adr x9,.Lupper_wave_NORGWD_DELTAT
 ldr x9,[x9]
 str x9,[x0,#64]
 adr x9,.Lupper_wave_NORGWD_KMIN
 ldr x9,[x9]
 str x9,[x0,#72]
 adr x9,.Lupper_wave_NORGWD_KMAX
 ldr x9,[x9]
 str x9,[x0,#80]
 adr x9,.Lupper_wave_NORGWD_CMIN
 ldr x9,[x9]
 str x9,[x0,#88]
 adr x9,.Lupper_wave_NORGWD_CMAX
 ldr x9,[x9]
 str x9,[x0,#96]
 adr x9,.Lupper_wave_NORGWD_PLAUNCH
 ldr x9,[x9]
 str x9,[x0,#104]
 adr x9,.Lupper_wave_NORGWD_PNOVERDIF
 ldr x9,[x9]
 str x9,[x0,#120]
 ldr d0,[x0,#104]
 mov w9,w2
 mov w10,w2
.Lupper_norgwd_nlaunch:
 sub w11,w9,#1
 ldr d1,[x1,x11,lsl#3]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,4,none,comparison,d1,real,x16,0,d0
 b.le .Lupper_norgwd_nlaunch_next
 mov w10,w9
.Lupper_norgwd_nlaunch_next:
 subs w9,w9,#1
 b.ne .Lupper_norgwd_nlaunch
 sub w10,w2,w10
 str w10,[x0,#112]
 ldr d0,[x0,#24]
 mov w9,w2
 mov w10,w2
.Lupper_norgwd_ntropo:
 sub w11,w9,#1
 ldr d1,[x1,x11,lsl#3]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,4,none,comparison,d1,real,x16,0,d0
 b.le .Lupper_norgwd_ntropo_next
 mov w10,w9
.Lupper_norgwd_ntropo_next:
 subs w9,w9,#1
 b.ne .Lupper_norgwd_ntropo
 sub w10,w2,w10
 str w10,[x0,#32]
 ldr d0,[x0,#120]
 mov w9,w2
 mov w10,w2
.Lupper_norgwd_nnoverdif:
 sub w11,w9,#1
 ldr d1,[x1,x11,lsl#3]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,4,none,comparison,d1,real,x16,0,d0
 b.le .Lupper_norgwd_nnoverdif_next
 mov w10,w9
.Lupper_norgwd_nnoverdif_next:
 subs w9,w9,#1
 b.ne .Lupper_norgwd_nnoverdif
 str w10,[x0,#128]
 ret
.size md2asm_initialize_nonorographic_wave_parameters_raw,.-md2asm_initialize_nonorographic_wave_parameters_raw
.p2align 4
.global md2asm_initialize_convective_energy_controls_raw
.type md2asm_initialize_convective_energy_controls_raw,%function
md2asm_initialize_convective_energy_controls_raw:
 str w4,[x0]
 mov w9,#1
 str w9,[x0,#4]
 str xzr,[x0,#16]
 adr x9,.Lupper_cape_threshold
 ldr d4,[x9]
 str d4,[x0,#24]
 fmov d5,#0.5
 mov x9,#1
.Lupper_cape_level:
 ldr d0,[x1,x9,lsl#3]
 ldr d1,[x2,x9,lsl#3]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d0,real,x16,0,d1
 sub x10,x9,#1
 ldr d1,[x1,x10,lsl#3]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d0,real,x16,0,d1
 ldr d1,[x2,x10,lsl#3]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d0,real,x16,0,d1
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d0,real,x16,0,d5
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,4,none,comparison,d0,real,x16,0,d4
 b.gt .Lupper_cape_next
 str w9,[x0,#8]
.Lupper_cape_next:
 add x9,x9,#1
 cmp w9,w3
 b.ls .Lupper_cape_level
 ret
.size md2asm_initialize_convective_energy_controls_raw,.-md2asm_initialize_convective_energy_controls_raw
.section .rodata
.p2align 3
.Lupper_limits:
 .quad 0x41086a0000000000
.Lupper_cape_threshold:
 .quad 0x3fe6666666666666
.Lupper_group0:
 .ascii "NAMTOPH"
.Lupper_group1:
 .ascii "NAMNORGWD"
.Lupper_group2:
 .ascii "NAMCAPE"
.p2align 3
.Lupper_top_ET850:
 .quad 0x40f4c08000000000
.p2align 3
.Lupper_top_ET950:
 .quad 0x40f7318000000000
.p2align 3
.Lupper_top_RFMESOQ:
 .quad 0x3ecf3f60681fa40a
.p2align 3
.Lupper_top_TPSCLIM:
 .quad 0x4068a00000000000
.p2align 3
.Lupper_wave_NORGWD_DZFRON:
 .quad 0x408f400000000000
.p2align 3
.Lupper_wave_NORGWD_GFRON:
 .quad 0x3fe3333340000000
.p2align 3
.Lupper_wave_NORGWD_PRMAX:
 .quad 0x3f2e573ac0000000
.p2align 3
.Lupper_wave_NORGWD_DZ:
 .quad 0x408f400000000000
.p2align 3
.Lupper_wave_NORGWD_PTROPO:
 .quad 0x40d3880000000000
.p2align 3
.Lupper_wave_NORGWD_RUWMAX:
 .quad 0x3f947ae147ae147b
.p2align 3
.Lupper_wave_NORGWD_SAT:
 .quad 0x3feb333333333333
.p2align 3
.Lupper_wave_NORGWD_RDISS:
 .quad 0x4044000000000000
.p2align 3
.Lupper_wave_NORGWD_DELTAT:
 .quad 0x40f5180000000000
.p2align 3
.Lupper_wave_NORGWD_KMIN:
 .quad 0x3f0a36e2e0000000
.p2align 3
.Lupper_wave_NORGWD_KMAX:
 .quad 0x3f33a92a40000000
.p2align 3
.Lupper_wave_NORGWD_CMIN:
 .quad 0x3ff0000000000000
.p2align 3
.Lupper_wave_NORGWD_CMAX:
 .quad 0x403e000000000000
.p2align 3
.Lupper_wave_NORGWD_PLAUNCH:
 .quad 0x40f3880000000000
.p2align 3
.Lupper_wave_NORGWD_PNOVERDIF:
 .quad 0x40c3880000000000
.section .note.GNU-stack,"",%progbits
