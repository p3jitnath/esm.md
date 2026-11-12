/* GPU physical setup route. Original interface and ordered arithmetic are preserved.
 * Contract: skills/md2fort-gpu/references/openifs/setup/physical_setup.md
 * Original source: src/openifs/setup/surface_constant_family.S
 */
// Original contract: skills/md2fort/references/openifs/setup/surface_constant_family.md
#include "../../support/gpu/preserved_scalar_calls.inc.S"
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_surface_constant_family
.type md2asm_initialize_surface_constant_family,%function
md2asm_initialize_surface_constant_family:
 cbz x0,.Lsurface_constant_bad_leaf
 cbz x1,.Lsurface_constant_bad_leaf
 orr x2,x0,x1
 tst x2,#7
 b.ne .Lsurface_constant_bad_leaf
 adds x17,x0,#24
 b.cs .Lsurface_constant_bad_leaf
 adds x16,x1,#64
 b.cs .Lsurface_constant_bad_leaf
 mrs x2,fpcr
 cbnz x2,.Lsurface_constant_bad_leaf
 ldr x2,[x0]
 lsl x3,x2,#1
 cbz x3,.Lsurface_rotation_valid
 mov x3,#0x3fe0000000000000
 cmp x2,x3
 b.eq .Lsurface_rotation_valid
 mov x3,#0x3ff0000000000000
 cmp x2,x3
 b.eq .Lsurface_rotation_valid
 mov x3,#0x4000000000000000
 cmp x2,x3
 b.ne .Lsurface_constant_bad_leaf
.Lsurface_rotation_valid:
 ldr x2,[x0,#8]
 mov x3,#0x3fe0000000000000
 cmp x2,x3
 b.eq .Lsurface_gravity_valid
 mov x3,#0x3ff0000000000000
 cmp x2,x3
 b.eq .Lsurface_gravity_valid
 mov x3,#0x4000000000000000
 cmp x2,x3
 b.ne .Lsurface_constant_bad_leaf
.Lsurface_gravity_valid:
 ldr w2,[x0,#16]
 cmp w2,#1
 b.hi .Lsurface_constant_bad_leaf
 adr x4,.Lsurface_record_sizes
 mov x3,#0
.Lsurface_output_range:
 lsl x2,x3,#4
 add x2,x1,x2
 ldp x5,x6,[x2]
 cbz x5,.Lsurface_constant_bad_leaf
 tst x5,#7
 b.ne .Lsurface_constant_bad_leaf
 ldr x7,[x4,x3,lsl#3]
 cmp x6,x7
 b.lo .Lsurface_constant_bad_leaf
 adds x8,x5,x7
 b.cs .Lsurface_constant_bad_leaf
 cmp x5,x17
 b.hs .Lsurface_controls_clear
 cmp x0,x8
 b.lo .Lsurface_constant_bad_leaf
.Lsurface_controls_clear:
 cmp x5,x16
 b.hs .Lsurface_table_clear
 cmp x1,x8
 b.lo .Lsurface_constant_bad_leaf
.Lsurface_table_clear:
 mov x9,#0
.Lsurface_prior_range:
 cmp x9,x3
 b.hs .Lsurface_next_range
 lsl x10,x9,#4
 ldr x10,[x1,x10]
 ldr x11,[x4,x9,lsl#3]
 add x11,x10,x11
 cmp x5,x11
 b.hs .Lsurface_prior_clear
 cmp x10,x8
 b.lo .Lsurface_constant_bad_leaf
.Lsurface_prior_clear:
 add x9,x9,#1
 b .Lsurface_prior_range
.Lsurface_next_range:
 add x3,x3,#1
 cmp x3,#4
 b.lo .Lsurface_output_range
 stp x29,x30,[sp,#-64]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 str x18,[sp,#48]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 ldr x0,[x20]
 mov x1,x19
 bl md2asm_initialize_surface_fundamental_constants
 ldr x0,[x20,#16]
 ldr x1,[x20]
 bl md2asm_initialize_surface_saturation_constants
 ldr x0,[x20,#32]
 bl md2asm_initialize_surface_stability_constants
 ldr x0,[x20,#48]
 mov x1,x19
 bl md2asm_initialize_lake_parameter_constants
 mov w0,#0
 ldr x18,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#64
 ret
.Lsurface_constant_bad_leaf:
 mov w0,#2
 ret
.size md2asm_initialize_surface_constant_family,.-md2asm_initialize_surface_constant_family
.p2align 4
.global md2asm_initialize_surface_fundamental_constants
.type md2asm_initialize_surface_fundamental_constants,%function
md2asm_initialize_surface_fundamental_constants:
 adr x8,.Lsurface_physical_literals
 ldr d19,[x8,#0]
 str d19,[x0,#8]
 ldr d23,[x8,#8]
 ldr d21,[x8,#16]
 ldr d20,[x8,#24]
 ldr d22,[x8,#32]
 ldr d24,[x1]
 ldr d25,[x1,#8]
 ldr d16,[x8,#40]
 str d16,[x0,#16]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,4,none,comparison,d24,real,x16,0,zero
 b.eq .Lsurface_default_day
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d16,destination,d16,real,x16,0,d24
 str d16,[x0,#16]
.Lsurface_default_day:
 ldr d0,[x8,#48]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d17,destination,d0,real,x16,0,d16
 fmov d0,#2.0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d17,destination,d17,real,x16,0,d0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d17,destination,d17,real,x16,0,d19
 ldr d0,[x8,#56]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d17,destination,d17,real,x16,0,d0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d0,destination,d16,real,x16,0,d17
 fmov d1,#1.0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d1,real,x16,0,d0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d18,destination,d16,real,x16,0,d0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,4,none,comparison,d24,real,x16,0,zero
 b.eq .Lsurface_zero_rotation
 fmov d0,#2.0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d0,real,x16,0,d19
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d0,destination,d0,real,x16,0,d18
 str d0,[x0,#120]
 b .Lsurface_rotation_done
.Lsurface_zero_rotation:
 str xzr,[x0,#120]
.Lsurface_rotation_done:
 ldr d0,[x8,#64]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d0,real,x16,0,d25
 str d0,[x0,#104]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d1,destination,d19,real,x16,0,d19
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d1,destination,d1,real,x16,0,d1
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d1,destination,d1,real,x16,0,d19
 fmov d2,#2.0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d1,destination,d2,real,x16,0,d1
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d3,destination,d20,real,x16,0,d21
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d4,destination,d3,real,x16,0,d3
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d3,destination,d4,real,x16,0,d3
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d1,destination,d1,real,x16,0,d3
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d1,destination,d1,real,x16,0,d20
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d2,destination,d23,real,x16,0,d23
 fmov d3,#15.0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d2,destination,d3,real,x16,0,d2
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d0,destination,d1,real,x16,0,d2
 str d0,[x0,#96]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d22,real,x16,0,d20
 str d0,[x0,#24]
 ldr d1,[x8,#72]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d1,destination,d1,real,x16,0,d0
 ldr d2,[x8,#80]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d26,destination,d1,real,x16,0,d2
 str d26,[x0,#32]
 ldr d1,[x8,#72]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d1,destination,d1,real,x16,0,d0
 ldr d2,[x8,#88]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d27,destination,d1,real,x16,0,d2
 str d27,[x0,#40]
 fmov d1,#3.5
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d1,destination,d1,real,x16,0,d26
 str d1,[x0,#80]
 fmov d1,#4.0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d1,destination,d1,real,x16,0,d27
 str d1,[x0,#88]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d0,destination,d27,real,x16,0,d26
 fmov d1,#1.0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d0,destination,d0,real,x16,0,d1
 str d0,[x0,#48]
 ldr d0,[x8,#96]
 str d0,[x0,#0]
 ldr d0,[x8,#104]
 str d0,[x0,#72]
 ldr d1,[x8,#112]
 str d1,[x0,#56]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d0,destination,d1,real,x16,0,d0
 str d0,[x0,#64]
 ldr d0,[x8,#120]
 str d0,[x0,#112]
 mov w0,#0
 ret
.size md2asm_initialize_surface_fundamental_constants,.-md2asm_initialize_surface_fundamental_constants
.p2align 4
.global md2asm_initialize_surface_saturation_constants
.type md2asm_initialize_surface_saturation_constants,%function
md2asm_initialize_surface_saturation_constants:
 adr x8,.Lsurface_thermal_literals
 str xzr,[x0,#8]
 ldr d0,[x1,#112]
 ldr d1,[x8]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d0,destination,d0,real,x16,0,d1
 str d0,[x0]
 ldr d0,[x8,#8]
 ldr d1,[x1,#32]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d0,real,x16,0,d1
 ldr d1,[x1,#40]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d0,destination,d0,real,x16,0,d1
 str d0,[x0,#16]
 ldp d0,d1,[x8,#16]
 stp d0,d1,[x0,#24]
 ldp d2,d3,[x8,#32]
 stp d2,d3,[x0,#40]
 ldr d4,[x1]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d5,destination,d4,real,x16,0,d2
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d5,destination,d0,real,x16,0,d5
 str d5,[x0,#56]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d5,destination,d4,real,x16,0,d3
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d5,destination,d1,real,x16,0,d5
 str d5,[x0,#64]
 mov w0,#0
 ret
.size md2asm_initialize_surface_saturation_constants,.-md2asm_initialize_surface_saturation_constants
.p2align 4
.global md2asm_initialize_surface_stability_constants
.type md2asm_initialize_surface_stability_constants,%function
md2asm_initialize_surface_stability_constants:
 adr x7,.Lsurface_stability_rows
 mov x8,#14
.Lsurface_stability_scalar:
 ldp x9,x10,[x7],#16
 str x10,[x0,x9]
 subs x8,x8,#1
 b.ne .Lsurface_stability_scalar
 str xzr,[x0]
 fmov d29,#1.0
 fmov d30,#4.0
 fmov d31,#5.0
 ldr d28,[x0,#808]
 adrp x7,.Lsurface_iteration_constant
 add x7,x7,:lo12:.Lsurface_iteration_constant
 ldr d27,[x7]
 mov x4,#1
.Lsurface_table_point:
 md2asm_gpu_preserved_scalar md2asm_gpu_startup_integer_cell_host,17,d0,destination,x4,general,x16,160,zero
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d16,destination,d0,real,x16,0,d28
 sub x8,x4,#1
 ldr d17,[x0,x8,lsl #3]
 fmov d0,#0.5
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,4,none,comparison,d16,real,x16,0,d0
 mov x9,#3
 mov x10,#5
 csel x9,x10,x9,lt
.Lsurface_newton:
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d18,destination,d17,real,x16,0,d29
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d18,destination,d18,real,x16,0,d27
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d19,destination,d17,real,x16,0,d18
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d20,destination,d17,real,x16,0,d18
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d30,real,x16,0,d19
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d29,real,x16,0,d0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d0,real,x16,0,d0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d19,real,x16,0,d0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d1,destination,d31,real,x16,0,d19
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d1,destination,d29,real,x16,0,d1
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d1,destination,d1,real,x16,0,d1
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d0,destination,d0,real,x16,0,d1
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d21,destination,d16,real,x16,0,d0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d30,real,x16,0,d20
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d29,real,x16,0,d0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d0,real,x16,0,d0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d20,real,x16,0,d0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d1,destination,d31,real,x16,0,d20
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d1,destination,d29,real,x16,0,d1
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d1,destination,d1,real,x16,0,d1
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d0,destination,d0,real,x16,0,d1
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d22,destination,d16,real,x16,0,d0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d21,real,x16,0,d22
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d18,real,x16,0,d0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d1,destination,d21,real,x16,0,d22
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d0,destination,d0,real,x16,0,d1
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d17,destination,d17,real,x16,0,d0
 subs x9,x9,#1
 b.ne .Lsurface_newton
 str d17,[x0,x4,lsl #3]
 add x4,x4,#1
 cmp x4,#101
 b.lo .Lsurface_table_point
 fmov d0,#5.0
 str d0,[x0,#920]
 str d0,[x0,#928]
 str d0,[x0,#936]
 mov w0,#0
 ret
.size md2asm_initialize_surface_stability_constants,.-md2asm_initialize_surface_stability_constants
.p2align 4
.global md2asm_initialize_lake_parameter_constants
.type md2asm_initialize_lake_parameter_constants,%function
md2asm_initialize_lake_parameter_constants:
 adr x3,.Lsurface_lake_scalar_rows
 mov x4,#41
.Lsurface_lake_scalar:
 ldp x5,x6,[x3],#16
 str x6,[x0,x5]
 subs x4,x4,#1
 b.ne .Lsurface_lake_scalar
 ldr w12,[x1,#20]
 add x2,x0,#328
 mov w4,#1
 str w4,[x2]
 str w12,[x2,#4]
 add x2,x2,#8
 adr x3,.Lsurface_optical_values_0
 mov x4,#12
.Lsurface_optical_copy_0:
 ldr x5,[x3],#8
 str x5,[x2],#8
 subs x4,x4,#1
 b.ne .Lsurface_optical_copy_0
 add x2,x0,#432
 mov w4,#2
 str w4,[x2]
 str w12,[x2,#4]
 add x2,x2,#8
 adr x3,.Lsurface_optical_values_1
 mov x4,#12
.Lsurface_optical_copy_1:
 ldr x5,[x3],#8
 str x5,[x2],#8
 subs x4,x4,#1
 b.ne .Lsurface_optical_copy_1
 add x2,x0,#536
 mov w4,#1
 str w4,[x2]
 str w12,[x2,#4]
 add x2,x2,#8
 adr x3,.Lsurface_optical_values_2
 mov x4,#12
.Lsurface_optical_copy_2:
 ldr x5,[x3],#8
 str x5,[x2],#8
 subs x4,x4,#1
 b.ne .Lsurface_optical_copy_2
 add x2,x0,#640
 mov w4,#1
 str w4,[x2]
 str w12,[x2,#4]
 add x2,x2,#8
 adr x3,.Lsurface_optical_values_3
 mov x4,#12
.Lsurface_optical_copy_3:
 ldr x5,[x3],#8
 str x5,[x2],#8
 subs x4,x4,#1
 b.ne .Lsurface_optical_copy_3
 add x2,x0,#744
 mov w4,#1
 str w4,[x2]
 str w12,[x2,#4]
 add x2,x2,#8
 adr x3,.Lsurface_optical_values_4
 mov x4,#12
.Lsurface_optical_copy_4:
 ldr x5,[x3],#8
 str x5,[x2],#8
 subs x4,x4,#1
 b.ne .Lsurface_optical_copy_4
 ldr w9,[x1,#16]
 str w9,[x0,#848]
 mov w0,#0
 ret
.size md2asm_initialize_lake_parameter_constants,.-md2asm_initialize_lake_parameter_constants
.section .rodata
.p2align 3
.Lsurface_record_sizes:
 .quad 128,72,944,856
.Lsurface_physical_literals:
 .quad 0x400921fb54442d18
 .double 299792458.0,6.6260755e-34,1.380658e-23,6.0221367e23,86400.0,365.25,6.283076,9.80665,1000.0,28.9644,18.0153,273.16,2.5008e6,2.8345e6,100000.0
.Lsurface_thermal_literals:
 .double 100.0,611.21,17.502,22.587,32.19,-0.7
.Lsurface_iteration_constant:
 .double 0.001
.Lsurface_stability_rows:
 .quad 816,0x4024000000000000
 .quad 808,0x3fb999999999999a
 .quad 880,0x4014000000000000
 .quad 888,0x4010000000000000
 .quad 896,0x4014000000000000
 .quad 824,0x3ff0000000000000
 .quad 832,0x3fe5555555555555
 .quad 840,0x4014000000000000
 .quad 848,0x3fd6666666666666
 .quad 856,0x3fe5555555555555
 .quad 864,0x40230c30c30c30c3
 .quad 872,0x402c924924924925
 .quad 904,0x4030000000000000
 .quad 912,0x3ff921fb54442d18
.Lsurface_lake_scalar_rows:
 .quad 0,0x3fc5c28f5c28f5c3
 .quad 8,0x3ff0000000000000
 .quad 16,0x3fe0000000000000
 .quad 24,0x4024000000000000
 .quad 32,0x4034000000000000
 .quad 40,0x3f9eb851eb851eb8
 .quad 48,0x3f9eb851eb851eb8
 .quad 56,0x3fe0000000000000
 .quad 64,0x3fe999999999999a
 .quad 72,0x402aaaaaaaaaaaab
 .quad 80,0x401aaaaaaaaaaaab
 .quad 88,0x3fe38e38e38e38e4
 .quad 96,0x3fc3e93e93e93e94
 .quad 104,0x3fe5555555555555
 .quad 112,0x3fe3333333333333
 .quad 120,0x3fe0000000000000
 .quad 128,0x3ff0000000000000
 .quad 136,0x3fe0000000000000
 .quad 144,0x3ff0000000000000
 .quad 152,0x3ff0000000000000
 .quad 160,0x4000000000000000
 .quad 168,0x3fb5555555555555
 .quad 176,0x4008000000000000
 .quad 184,0x3ee4f8b588e368f1
 .quad 192,0x3e112e0be826d695
 .quad 200,0x3f847ae147ae147b
 .quad 208,0x408f400000000000
 .quad 216,0x3eb0c6f7a0b5ed8d
 .quad 224,0x3d19000000000000
 .quad 232,0x40239eb851eb851f
 .quad 240,0x407152147ae147ae
 .quad 248,0x4071126666666666
 .quad 256,0x3ef14f99d7684270
 .quad 264,0x408f400000000000
 .quad 272,0x408c700000000000
 .quad 280,0x4114244000000000
 .quad 288,0x40b0680000000000
 .quad 296,0x40a0680000000000
 .quad 304,0x3fe178d4fdf3b646
 .quad 312,0x400251eb851eb852
 .quad 320,0x414314c400000000
.Lsurface_optical_values_0:
 .double 1,0,0,0,0,0,3,10000000000.0,10000000000.0,10000000000.0,10000000000.0,10000000000.0
.Lsurface_optical_values_1:
 .double 0.1,0.9,0,0,0,0,2,0.2,10000000000.0,10000000000.0,10000000000.0,10000000000.0
.Lsurface_optical_values_2:
 .double 1,0,0,0,0,0,17.1,10000000000.0,10000000000.0,10000000000.0,10000000000.0,10000000000.0
.Lsurface_optical_values_3:
 .double 1,0,0,0,0,0,8.4,10000000000.0,10000000000.0,10000000000.0,10000000000.0,10000000000.0
.Lsurface_optical_values_4:
 .double 1,0,0,0,0,0,10000000.0,10000000000.0,10000000000.0,10000000000.0,10000000000.0,10000000000.0
.section .note.GNU-stack,"",%progbits
