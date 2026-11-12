/* Complete orographic parameter field with preserved cloud and wave siblings.
 * Contract: skills/md2fort-gpu/references/openifs/setup/orographic_parameter_field_complete_contract.md
 * Original source: src/openifs/setup/cloud_gravity_wave_parameter_fields.S
 */
// Original contract: skills/md2fort/references/openifs/setup/cloud_gravity_wave_setup.md
#include "../../support/gpu/preserved_scalar_calls.inc.S"
.arch armv8.2-a
.text
.p2align 4
.global md2asm_diagnostic_cloud_parameter_fields
.type md2asm_diagnostic_cloud_parameter_fields,%function
md2asm_diagnostic_cloud_parameter_fields:
 mov x3,#-1
 stp x1,x3,[x0]
 mov x3,#8
 str x3,[x0,#16]
 str x3,[x0,#32]
 mov x3,#0x301
 lsl x3,x3,#32
 str x3,[x0,#24]
 mov x3,#1
 stp x3,x3,[x0,#40]
 mov x3,#19
 str x3,[x0,#56]
 adrp x3,.Lcloud_constants
 add x3,x3,:lo12:.Lcloud_constants
 add x4,x0,#64
 mov w5,#24
.Lcloud_scalar:
 ldr x6,[x3],#8
 str x6,[x4],#8
 subs w5,w5,#1
 b.ne .Lcloud_scalar
 mov w3,#1
 str w3,[x0,#256]
 mov x3,#0
.Lcloud_eta:
 ldr x4,[x2,x3]
 str x4,[x1,x3]
 add x3,x3,#8
 cmp x3,#152
 b.lo .Lcloud_eta
 ret
.size md2asm_diagnostic_cloud_parameter_fields,.-md2asm_diagnostic_cloud_parameter_fields
.p2align 4
.global md2asm_orographic_gravity_wave_parameter_fields
.type md2asm_orographic_gravity_wave_parameter_fields,%function
md2asm_orographic_gravity_wave_parameter_fields:
 b md2asm_gpu_orographic_parameter_field_phase_host
.size md2asm_orographic_gravity_wave_parameter_fields,.-md2asm_orographic_gravity_wave_parameter_fields
.p2align 4
.global md2asm_nonorographic_gravity_wave_parameter_fields
.type md2asm_nonorographic_gravity_wave_parameter_fields,%function
md2asm_nonorographic_gravity_wave_parameter_fields:
 adrp x4,.Lnonorographic_constants
 add x4,x4,:lo12:.Lnonorographic_constants
 mov w5,#1
 str w5,[x0,#28]
 ldr x5,[x4]
 str x5,[x0,#72]
 str x5,[x0,#48]
 stp xzr,xzr,[x0,#56]
 ldr x5,[x4,#8]
 str x5,[x0,#104]
 ldr x5,[x4,#16]
 str x5,[x0,#80]
 mov w5,#1
 str w5,[x0,#36]
 ldr x5,[x4,#24]
 str x5,[x0,#112]
 mov w5,#1
 str w5,[x0]
 mov w5,#2
 str w5,[x0,#40]
 ldr x5,[x4,#32]
 str x5,[x0,#128]
 ldr x5,[x4,#40]
 stp x5,x5,[x0,#136]
 str x5,[x0,#152]
 ldr x5,[x4,#16]
 str x5,[x0,#160]
 str wzr,[x0,#4]
 str wzr,[x0,#8]
 str wzr,[x0,#12]
 ldr d16,[x2]
 ldr d17,[x3]
 ldr d18,[x4,#24]
 fmov d0,d16
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,4,none,comparison,d17,real,x16,0,d16
 b.lt .Lnonorographic_frequency
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d18,real,x16,0,d17
.Lnonorographic_frequency:
 str d0,[x0,#120]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d0,destination,d0,real,x16,0,d17
 md2asm_gpu_preserved_scalar md2asm_gpu_physical_setup_numeric_cell_host,24,w5,destination,d0,real,x16,0,zero
 md2asm_gpu_preserved_scalar md2asm_gpu_startup_integer_cell_host,18,d0,destination,w5,general,w16,168,zero
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d0,real,x16,0,d17
 str d0,[x0,#120]
 ldr x5,[x0,#72]
 str x5,[x0,#48]
 mov w5,#18
 stp w5,w5,[x0,#16]
 str w5,[x0,#24]
 adrp x4,.Lwave_launch_pressures
 add x4,x4,:lo12:.Lwave_launch_pressures
 ldp d16,d17,[x4]
 ldr d18,[x4,#16]
 mov x4,#144
.Lnonorographic_launch:
 ldr d0,[x1,x4]
 lsr w5,w4,#3
 add w5,w5,#1
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,4,none,comparison,d0,real,x16,0,d16
 b.le .Lnonorographic_launch_second
 str w5,[x0,#16]
.Lnonorographic_launch_second:
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,4,none,comparison,d0,real,x16,0,d17
 b.le .Lnonorographic_launch_third
 str w5,[x0,#20]
.Lnonorographic_launch_third:
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,4,none,comparison,d0,real,x16,0,d18
 b.le .Lnonorographic_launch_next
 str w5,[x0,#24]
.Lnonorographic_launch_next:
 sub x4,x4,#8
 cbnz x4,.Lnonorographic_launch
 ldr w5,[x0,#16]
 str w5,[x0,#32]
 ret
.size md2asm_nonorographic_gravity_wave_parameter_fields,.-md2asm_nonorographic_gravity_wave_parameter_fields
.section .rodata
.p2align 3
.Lcloud_constants:
 .quad 0x4000000000000000
 .quad 0x3fd3333333333333
 .quad 0x3fd999999999999a
 .quad 0x3fc0000000000000
 .quad 0x3ff8000000000000
 .quad 0x3fe999999999999a
 .quad 0x3fd999999999999a
 .quad 0x3f1a36e2eb1c432d
 .quad 0x42374876e8000000
 .quad 0x4000000000000000
 .quad 0x3ff0000000000000
 .quad 0x3fdccccccccccccd
 .quad 0x3fe999999999999a
 .quad 0x4059000000000000
 .quad 0xc024000000000000
 .quad 0xbfeccccccccccccd
 .quad 0x4014000000000000
 .quad 0xbfb999999999999a
 .quad 0xc024000000000000
 .quad 0x3feccccccccccccd
 .quad 0x3fe6666666666666
 .quad 0x3fa999999999999a
 .quad 0x3d719799812dea11
 .quad 0x3d719799812dea11
.p2align 3
.Lwave_constants:
 .double 80000.0,0.5,0.94,9.9
.Lwave_drag_constants:
 .double 0.3,1.0,0.15,3.0,0.25,0.40,0.10,1.0e-12,1.0e-7
.Lwave_limiter_pressure:
 .double 1000.0
.Lwave_tendency_constants:
 .double 20.0,80.0
.Lnonorographic_constants:
 .double 0.00375,1.0,2000.0,2.0,20.0,-0.25
.Lwave_launch_pressures:
 .double 45000.0,70000.0,20000.0
.section .note.GNU-stack,"",%progbits
