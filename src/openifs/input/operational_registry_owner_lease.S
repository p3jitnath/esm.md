/* Contract: skills/md2asm/references/openifs/input/operational_registry_owner_lease.md.
 * Seven live arguments in x0..x6; return status in w0. Owner size8944B.
 * Complete storage lifetime for the admitted configuration; selected setup only.
 * A fatal partial registry requires process exit before any further consumer.
 */
.arch armv8.2-a
.text
.macro CONST dst,value
 movz \dst,#((\value)&65535)
 movk \dst,#(((\value)>>16)&65535),lsl#16
.endm
.macro ADDR dst,base,offset
 CONST x17,\offset
 add \dst,\base,x17
.endm
.macro GOT dst,name
 adrp \dst,:got:\name
 ldr \dst,[\dst,:got_lo12:\name]
.endm
.macro ENTER
 sub sp,sp,#256
 stp x29,x30,[sp]
 mov x29,sp
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 stp x22,x23,[sp,#48]
 stp x24,x25,[sp,#64]
 stp x26,x27,[sp,#80]
 str x28,[sp,#96]
.endm
.macro LEAVE
 ldr x28,[sp,#96]
 ldp x26,x27,[sp,#80]
 ldp x24,x25,[sp,#64]
 ldp x22,x23,[sp,#48]
 ldp x20,x21,[sp,#32]
 ldp x18,x19,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#256
 ret
.endm
.macro RECORDS
 ldr x8,[x26,#8]
 ldr x11,[x8,#16]
 ldr x12,[x8,#24]
 ldr x13,[x8,#48]
.endm
.macro PHASE name,code
 bl \name
 add w28,w0,#\code
 cbnz w0,.Llease_create_failed
 mov x9,#\code
 str x9,[x26,#32]
.endm
.macro UP_I base,offset,outoff
 ADDR x14,\base,\offset
 ldr w9,[x14]
 str w9,[x15,#\outoff]
.endm
.macro UP_D base,offset,outoff
 ADDR x14,\base,\offset
 ldr x9,[x14]
 str x9,[x15,#\outoff]
.endm
.p2align 4
.global md2asm_create_actual_registry_owner_lease
.type md2asm_create_actual_registry_owner_lease,%function
md2asm_create_actual_registry_owner_lease:
 ENTER
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 mov x23,x4
 mov x24,x5
 mov x25,x6
 mov x26,xzr
 mov w28,#2
 cbz x19,.Llease_create_return
 cbz x20,.Llease_create_return
 cbz x21,.Llease_create_return
 cbz x22,.Llease_create_return
 cbz x23,.Llease_create_return
 cbz x24,.Llease_create_return
 cbz x25,.Llease_create_return
 orr x9,x19,x20
 orr x9,x9,x24
 orr x9,x9,x25
 tst x9,#7
 b.ne .Llease_create_return
 ldr x9,[x25]
 cbnz x9,.Llease_create_return
 mrs x9,fpcr
 cbnz x9,.Llease_create_return
 ldr x9,[x19]
 movz x10,#0x5431
 movk x10,#0x5055,lsl#16
 movk x10,#0x494e,lsl#32
 movk x10,#0x4f50,lsl#48
 cmp x9,x10
 b.ne .Llease_create_return
 ldr x27,[x19,#8]
 cbz x27,.Llease_create_return
 ldr x9,[x20]
 cmp x9,x27
 b.ne .Llease_create_return
 ldr x9,[x20,#8]
 cbz x9,.Llease_create_return
 mov x0,#1
 mov x1,#8944
 bl calloc
 mov w28,#1
 cbz x0,.Llease_create_return
 mov x26,x0
 CONST x9,0x52474c31
 str x9,[x26]
 stp x19,x20,[x26,#16]
 GOT x0,md2asm_owned_initial_physical_constants
 mov x1,#520
 PHASE md2asm_initialize_physical_constants,0
 mov x0,x27
 mov x1,x24
 add x2,x26,#8
 PHASE md2asm_create_distributed_operational_model_storage,10
 ldr x0,[x26,#8]
 add x1,x19,#120
 ldp x2,x3,[x19,#16]
 ldr x4,[x20,#8]
 PHASE md2asm_attach_distributed_operational_model_configuration,20
 ldp x0,x1,[x19,#16]
 GOT x2,md2asm_owned_dynamical_namespace
 mov x3,#320
 PHASE md2asm_initialize_operational_dynamical_configuration,21
 RECORDS
 ADDR x0,x13,51696
 GOT x1,md2asm_owned_runtime_convection_clock
 mov x2,#360
 PHASE md2asm_initialize_operational_model_clock,22
 RECORDS
 add x0,x13,#584
 ldp x1,x2,[x19,#16]
 PHASE md2asm_initialize_actual_registry_physics_data,23
 RECORDS
 ldp x0,x1,[x19,#16]
 mov x2,x27
 mov x3,x11
 mov x4,x13
 PHASE md2asm_initialize_operational_lagrangian_controls,25
 ldr x0,[x26,#8]
 PHASE md2asm_begin_distributed_operational_model_work_storage,30
 ldr x0,[x26,#8]
 PHASE md2asm_advance_distributed_operational_model_work_storage,40
 add x0,x26,#3800
 mov x1,#744
 PHASE md2asm_initialize_dynamics_field_maps,41
 RECORDS
 mov x0,x11
 CONST x1,4275088
 PHASE md2asm_initialize_owned_initial_physics_interval,42
 RECORDS
 add x14,x26,#3672
 GOT x9,md2asm_owned_initial_physical_constants
 mov x10,#520
 stp x9,x10,[x14]
 GOT x9,md2asm_owned_dynamical_namespace
 mov x10,#320
 stp x9,x10,[x14,#16]
 GOT x9,md2asm_owned_ecmwf_thermal_namespace
 mov x10,#1920
 stp x9,x10,[x14,#32]
 add x14,x26,#3736
 GOT x9,md2asm_owned_initial_physical_constants
 ADDR x10,x27,20328
 stp x9,x10,[x14]
 add x9,x26,#3800
 add x10,x11,#192
 stp x9,x10,[x14,#16]
 mov x0,x27
 mov x1,x11
 add x2,x26,#3672
 add x3,x26,#3736
 ldp x4,x5,[x19,#16]
 ADDR x6,x26,4544
 PHASE md2asm_initialize_operational_ecmwf_physics_prefix,43
 RECORDS
 add x15,x26,#3448
 UP_I x13,40104,0
 UP_I x13,35768,4
 UP_I x11,1577888,8
 UP_I x11,4144592,12
 ADDR x14,x11,800184
 ldr x14,[x14]
 ldr w9,[x14,#52]
 str w9,[x15,#16]
 mov w9,#1
 str w9,[x15,#20]
 GOT x14,md2asm_owned_dynamical_namespace
 ldr w9,[x14,#276]
 str w9,[x15,#24]
 UP_I x11,4144116,28
 UP_I x11,4144588,32
 UP_I x11,1626928,36
 UP_I x11,1577924,40
 UP_I x11,4144684,44
 UP_I x11,1578268,48
 UP_I x27,5144,52
 UP_I x27,5172,56
 UP_I x27,4872,60
 UP_I x27,7376,64
 UP_I x27,7384,68
 UP_I x27,5224,72
 UP_I x27,5160,76
 UP_I x27,4936,80
 UP_I x11,4144676,84
 UP_D x11,1359528,88
 UP_D x11,4218656,96
 UP_D x11,4218664,104
 add x14,x26,#3560
 ADDR x9,x11,1608728
 mov x10,#2040
 stp x9,x10,[x14]
 ADDR x9,x11,1856400
 mov x10,#176
 stp x9,x10,[x14,#16]
 ADDR x9,x11,1627088
 CONST x10,229312
 stp x9,x10,[x14,#32]
 ADDR x9,x11,1622432
 mov x10,#32
 stp x9,x10,[x14,#48]
 ADDR x9,x11,1392648
 mov x10,#1384
 stp x9,x10,[x14,#64]
 add x9,x26,#64
 mov x10,#744
 stp x9,x10,[x14,#80]
 add x9,x26,#808
 mov x10,#2640
 stp x9,x10,[x14,#96]
 mov x0,x14
 ldp x1,x2,[x19,#16]
 GOT x3,md2asm_owned_initial_physical_constants
 add x4,x26,#3448
 PHASE md2asm_initialize_runtime_radiation_control_prefix,45
 RECORDS
 mov x0,x11
 CONST x1,4275088
 ldp x2,x3,[x19,#16]
 PHASE md2asm_initialize_runtime_radiation_owner_controls,46
 RECORDS
 mov x0,x11
 CONST x1,4275088
 mov x2,x27
 mov x3,#20400
 mov x4,#1
 lsl x4,x4,#36
 PHASE md2asm_create_runtime_radiation_flux_owners,47
 RECORDS
 mov x0,x12
 mov x1,x27
 mov x2,x11
 mov x3,x13
 add x4,x26,#48
 PHASE md2asm_create_runtime_ecmwf_physics_fields_from_owners,48
 ldr x0,[x26,#8]
 PHASE md2asm_advance_distributed_operational_model_work_storage,50
 ldr x0,[x26,#8]
 PHASE md2asm_allocate_distributed_operational_model_grid_motion,60
 ldr x0,[x26,#8]
 adr x1,.Llease_spectral_ids
 PHASE md2asm_initialize_distributed_operational_model_spectral,70
 mov x0,x21
 ldr x1,[x26,#8]
 PHASE md2asm_load_distributed_operational_model_spectral_state,80
 RECORDS
 ldr x9,[x26,#8]
 ldr w9,[x9,#784]
 cmp w9,#1
 mov w28,#87
 b.ne .Llease_create_failed
 ADDR x14,x13,35872
 ldr w9,[x14]
 str w9,[sp,#128]
 GOT x14,md2asm_owned_physics_runtime_data
 ldr w9,[x14]
 str w9,[sp,#132]
 ldr x14,[x8,#56]
 ldr w9,[x14,#124]
 ldr w10,[x14,#116]
 stp w9,w10,[sp,#136]
 mov x0,x27
 mov x1,#20400
 ADDR x14,x12,25200
 ldr x2,[x14]
 mov x3,#1
 cmp w9,#2
 CONST x14,6558720
 csel x3,x14,x3,eq
 add x4,sp,#128
 mov x5,#16
 PHASE md2asm_initialize_distributed_operational_orography,85
 mov x0,x22
 ldr x1,[x26,#8]
 PHASE md2asm_initialize_distributed_operational_model_surface,90
 mov x0,x23
 ldr x1,[x26,#8]
 PHASE md2asm_load_distributed_operational_model_upper_air_state,100
 ldr x0,[x26,#8]
 PHASE md2asm_advance_distributed_operational_model_work_storage,110
 RECORDS
 mov x0,x27
 mov x1,x12
 mov x2,x11
 add x3,x26,#52
 bl md2asm_prepare_runtime_field_registry
 ldr w9,[x26,#52]
 add w28,w9,#120
 cbnz w9,.Llease_create_fatal
 mov x9,#120
 str x9,[x26,#32]
 str xzr,[x26,#40]
 str x26,[x25]
 mov w28,#0
 b .Llease_create_return
.Llease_create_failed:
 str x28,[x26,#40]
 str x26,[sp,#112]
 add x0,sp,#112
 bl md2asm_release_actual_registry_owner_lease
 cbz w0,.Llease_create_return
 /* An unexpected cleanup refusal retains the complete ownership record. */
.Llease_create_fatal:
 mov x9,#1
 str x9,[x26,#56]
 str x28,[x26,#40]
 str x26,[x25]
.Llease_create_return:
 mov w0,w28
 LEAVE
.size md2asm_create_actual_registry_owner_lease,.-md2asm_create_actual_registry_owner_lease
.p2align 3
.Llease_spectral_ids:
 .word 138,155,130,152,129
.p2align 4
.global md2asm_release_actual_registry_owner_lease
.type md2asm_release_actual_registry_owner_lease,%function
md2asm_release_actual_registry_owner_lease:
 cbz x0,.Llease_release_bad_leaf
 tst x0,#7
 b.ne .Llease_release_bad_leaf
 adds x9,x0,#8
 b.cs .Llease_release_bad_leaf
 ldr x1,[x0]
 cbz x1,.Llease_release_empty
 tst x1,#7
 b.ne .Llease_release_bad_leaf
 mov x9,#8944
 adds x9,x1,x9
 b.cs .Llease_release_bad_leaf
 ldr x9,[x1]
 CONST x10,0x52474c31
 cmp x9,x10
 b.ne .Llease_release_bad_leaf
 ldr x9,[x1,#56]
 cbnz x9,.Llease_release_bad_leaf
 ldr x9,[x1,#32]
 cmp x9,#120
 b.hi .Llease_release_bad_leaf
 ENTER
 mov x19,x0
 mov x20,x1
 mrs x26,fpcr
 mrs x27,fpsr
 bl __errno_location
 mov x24,x0
 ldr w25,[x24]
 mov w28,#0
 ldr x21,[x20,#8]
 cbz x21,.Llease_release_outer
 ldr x22,[x21,#16]
 ldr x23,[x21,#24]
 ldr x9,[x20,#32]
 cmp x9,#120
 b.ne .Llease_release_TEC
 mov x0,x23
 CONST x1,529288
 bl md2asm_release_runtime_field_registry
 cbnz w0,.Llease_release_child_refused
 mov x9,#110
 str x9,[x20,#32]
 /* The source terrain producer ran after spectral loading. Its blocked
  * arrays remain live until the registry and all borrowing readers finish. */
.Llease_release_TEC:
 ldr x9,[x20,#32]
 cmp x9,#85
 b.lo .Llease_release_TEC_after_orography
 ldr x0,[x21,#8]
 bl md2asm_release_distributed_operational_orography
 cbnz w0,.Llease_release_child_refused
.Llease_release_TEC_after_orography:
 ldr x9,[x20,#32]
 cmp x9,#48
 b.lo .Llease_release_radiation
 mov x0,x23
 bl md2asm_release_runtime_ecmwf_physics_fields_from_owners
 cbnz w0,.Llease_release_child_refused
 mov x9,#47
 str x9,[x20,#32]
.Llease_release_radiation:
 ldr x9,[x20,#32]
 cmp x9,#47
 b.lo .Llease_release_Planck
 ADDR x0,x22,1606488
 mov x1,#2240
 bl md2asm_release_selected_radiation_fluxes
 cbnz w0,.Llease_release_child_refused
 mov x9,#46
 str x9,[x20,#32]
.Llease_release_Planck:
 ldr x9,[x20,#32]
 cmp x9,#45
 b.lo .Llease_release_CETA
 ADDR x0,x22,1610528
 mov x1,#240
 bl md2asm_release_selected_spectral_planck
 cbnz w0,.Llease_release_child_refused
 mov x9,#43
 str x9,[x20,#32]
.Llease_release_CETA:
 ldr x9,[x20,#32]
 cmp x9,#42
 b.lo .Llease_release_model
 mov x0,x22
 add x1,x20,#3672
 bl md2asm_release_operational_ecmwf_physics_prefix
 cbnz w0,.Llease_release_child_refused
 mov x9,#40
 str x9,[x20,#32]
.Llease_release_model:
 mov x0,x21
 bl md2asm_release_distributed_operational_model_storage
 cbnz w0,.Llease_release_child_refused
 str xzr,[x20,#8]
.Llease_release_outer:
 mov x0,x20
 bl free
 str xzr,[x19]
 b .Llease_release_restore
.Llease_release_child_refused:
 mov w28,w0
.Llease_release_restore:
 str w25,[x24]
 msr fpcr,x26
 msr fpsr,x27
 mov w0,w28
 LEAVE
.Llease_release_empty:
 mov w0,#0
 ret
.Llease_release_bad_leaf:
 mov w0,#2
 ret
.size md2asm_release_actual_registry_owner_lease,.-md2asm_release_actual_registry_owner_lease
.section .note.GNU-stack,"",%progbits
