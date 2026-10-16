/* Selected source SUDYN, SUALDYNB, SUSAVTEND and SUSC2B owned stages.
 * Contract: skills/md2asm/references/openifs/dynamics/forecast_dynamic_storage.md.
 * All records and payloads are caller-owned. No original OpenIFS provider. */
.arch armv8.2-a
.text
.p2align 4
.macro MADDR reg,base,offset
 mov x17,#(\offset&65535)
 movk x17,#(\offset>>16),lsl#16
 add \reg,\base,x17
.endm
.global md2asm_initialize_forecast_dynamics_defaults
.type md2asm_initialize_forecast_dynamics_defaults,%function
md2asm_initialize_forecast_dynamics_defaults:
 cbz x0,.Lbad
 cbz x2,.Lbad
 tst x0,#7
 b.ne .Lbad
 tst x2,#3
 b.ne .Lbad
 mov x9,#(4275088&65535)
 movk x9,#65,lsl#16
 cmp x1,x9
 b.lo .Lbad
 adds x9,x0,x9
 b.cs .Lbad
 adds x9,x2,#16
 b.cs .Lbad
 ldp w9,w10,[x2]
 cmp w9,#1
 b.ne .Lbad
 cmp w10,#1
 b.ne .Lbad
 ldp w9,w10,[x2,#8]
 cbnz w9,.Lbad
 cmp w10,#1
 b.ne .Lbad
 MADDR x9,x0,1567072
 mov x10,#0x3ff0000000000000
 str x10,[x9]
 MADDR x9,x0,1568836
 str wzr,[x9]
 MADDR x9,x0,1567172
 str wzr,[x9]
 mov w0,#0
 ret
.size md2asm_initialize_forecast_dynamics_defaults,.-md2asm_initialize_forecast_dynamics_defaults
.Lbad:
 mov w0,#2
 ret
.p2align 4
.global md2asm_allocate_saved_departure_points
.type md2asm_allocate_saved_departure_points,%function
md2asm_allocate_saved_departure_points:
 mov w8,#0
 b .Lallocate_rank4
.size md2asm_allocate_saved_departure_points,.-md2asm_allocate_saved_departure_points
.global md2asm_allocate_saved_physics_tendencies
.type md2asm_allocate_saved_physics_tendencies,%function
md2asm_allocate_saved_physics_tendencies:
 mov w8,#1
 b .Lallocate_rank4
.size md2asm_allocate_saved_physics_tendencies,.-md2asm_allocate_saved_physics_tendencies
/* Both entries take Geometry, Geometry capacity, MODEL, MODEL capacity. */
.Lallocate_rank4:
 mov x16,x30
 bl .Lvalidate_geometry_model_leaf
 mov x30,x16
 cbnz w9,.Lbad
 sub sp,sp,#256
 stp x18,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 mov x19,x2
 mov x20,x0
 mov w21,w8
 mov x9,#5144
 ldr w22,[x20,x9]
 sub w10,w22,#1
 cmp w10,#1023
 b.hi .Lrank4_bad
 mov x9,#5224
 ldr w23,[x20,x9]
 sub w10,w23,#1
 cmp w10,#254
 b.hi .Lrank4_bad
 mov x9,#5160
 ldr w24,[x20,x9]
 sub w10,w24,#1
 cmp w10,#4095
 b.hi .Lrank4_bad
 cbnz w21,.Ltendency_guards
 MADDR x9,x19,1568900
 ldp w10,w11,[x9]
 cmp w10,#1
 b.ne .Lrank4_bad
 cmp w11,#1
 b.ne .Lrank4_bad
 MADDR x25,x19,1565736
 b .Lrank4_fresh
.Ltendency_guards:
 MADDR x9,x19,1578148
 ldr w10,[x9]
 cmp w10,#1
 b.ne .Lrank4_bad
 MADDR x9,x19,1577520
 ldr w10,[x9]
 cmp w10,#3
 b.ne .Lrank4_bad
 MADDR x25,x19,1577528
.Lrank4_fresh:
 ldr x9,[x25]
 cbnz x9,.Lrank4_bad
 mul x27,x22,x23
 mov x9,#3
 mul x27,x27,x9
 mul x27,x27,x24
 lsl x0,x27,#3
 bl malloc
 cbz x0,.Lrank4_failed
 mov x26,x0
 cbz w21,.Lrank4_descriptor
 mov x9,x26
 mov x10,x27
.Lzero_tendencies:
 str xzr,[x9],#8
 subs x10,x10,#1
 b.ne .Lzero_tendencies
.Lrank4_descriptor:
 add x28,sp,#112
 str x26,[x28]
 mul x9,x22,x23
 mov x10,#3
 mul x10,x9,x10
 add x11,x22,x9
 add x11,x11,x10
 add x11,x11,#1
 neg x11,x11
 str x11,[x28,#8]
 mov x11,#8
 str x11,[x28,#16]
 str wzr,[x28,#24]
 mov w11,#0x304
 strh w11,[x28,#28]
 strh wzr,[x28,#30]
 mov x11,#8
 str x11,[x28,#32]
 mov x11,#1
 stp x11,x11,[x28,#40]
 str x22,[x28,#56]
 stp x22,x11,[x28,#64]
 str x23,[x28,#80]
 stp x9,x11,[x28,#88]
 mov x12,#3
 str x12,[x28,#104]
 stp x10,x11,[x28,#112]
 str x24,[x28,#128]
 mov x9,x28
 mov x10,x25
 mov x11,#136
 bl .Lcopy_record
 mov w0,#0
 b .Lrank4_done
.Lrank4_bad:
 mov w0,#2
 b .Lrank4_done
.Lrank4_failed:
 mov w0,#1
.Lrank4_done:
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x18,x30,[sp]
 add sp,sp,#256
 ret
/* Leaf validation returns w9 zero, retaining arguments and selector w8. */
.Lvalidate_geometry_model_leaf:
 mov w9,#2
 cbz x0,.Lvalidate_done
 cbz x2,.Lvalidate_done
 orr x10,x0,x2
 tst x10,#7
 b.ne .Lvalidate_done
 mov x10,#17096
 cmp x1,x10
 b.lo .Lvalidate_done
 adds x10,x0,x10
 b.cs .Lvalidate_done
 mov x10,#(4275088&65535)
 movk x10,#65,lsl#16
 cmp x3,x10
 b.lo .Lvalidate_done
 adds x10,x2,x10
 b.cs .Lvalidate_done
 mov w9,#0
.Lvalidate_done:
 ret
.p2align 4
.global md2asm_initialize_lagged_tendency_configuration
.type md2asm_initialize_lagged_tendency_configuration,%function
md2asm_initialize_lagged_tendency_configuration:
 mov x16,x30
 bl .Lvalidate_geometry_model_leaf
 mov x30,x16
 cbnz w9,.Lbad
 sub sp,sp,#128
 stp x18,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 mov x19,x2
 mov x9,#5224
 ldr w20,[x0,x9]
 sub w10,w20,#1
 cmp w10,#254
 b.hi .Lconfiguration_bad
 MADDR x9,x19,1578148
 ldr w10,[x9]
 cmp w10,#1
 b.ne .Lconfiguration_bad
 MADDR x21,x19,1577456
 ldr x9,[x21]
 cbnz x9,.Lconfiguration_bad
 lsl x0,x20,#3
 bl malloc
 cbz x0,.Lconfiguration_failed
 mov x22,x0
 mov x9,x22
 mov x10,x20
 mov x11,#0x3fe0000000000000
.Lhalf_weights:
 str x11,[x9],#8
 subs x10,x10,#1
 b.ne .Lhalf_weights
 add x9,sp,#64
 str x22,[x9]
 mov x10,#-1
 str x10,[x9,#8]
 mov x10,#8
 str x10,[x9,#16]
 str wzr,[x9,#24]
 mov w10,#0x301
 strh w10,[x9,#28]
 strh wzr,[x9,#30]
 mov x10,#8
 str x10,[x9,#32]
 mov x10,#1
 stp x10,x10,[x9,#40]
 str x20,[x9,#56]
 mov x10,x21
 mov x11,#64
 bl .Lcopy_record
 MADDR x9,x19,1577520
 mov w10,#3
 str w10,[x9]
 MADDR x9,x19,1577800
 mov w10,#1
 mov w11,#2
 stp w10,w11,[x9]
 mov w10,#3
 str w10,[x9,#8]
 mov w0,#0
 b .Lconfiguration_done
.Lconfiguration_bad:
 mov w0,#2
 b .Lconfiguration_done
.Lconfiguration_failed:
 mov w0,#1
.Lconfiguration_done:
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x18,x30,[sp]
 add sp,sp,#128
 ret
.size md2asm_initialize_lagged_tendency_configuration,.-md2asm_initialize_lagged_tendency_configuration
.Lcopy_record:
 ldr x12,[x9],#8
 str x12,[x10],#8
 subs x11,x11,#8
 b.ne .Lcopy_record
 ret
.p2align 4
.global md2asm_release_forecast_dynamic_storage
.type md2asm_release_forecast_dynamic_storage,%function
md2asm_release_forecast_dynamic_storage:
 cbz x0,.Lbad
 tst x0,#7
 b.ne .Lbad
 mov x9,#(4275088&65535)
 movk x9,#65,lsl#16
 cmp x1,x9
 b.lo .Lbad
 stp x18,x30,[sp,#-48]!
 stp x19,x20,[sp,#16]
 str x21,[sp,#32]
 mov x19,x0
 adr x20,.Lowner_offsets
 mov w21,#3
.Lrelease_owner:
 ldr w9,[x20],#4
 add x9,x19,x9
 ldr x0,[x9]
 cbz x0,.Lrelease_next
 str xzr,[x9]
 bl free
.Lrelease_next:
 subs w21,w21,#1
 b.ne .Lrelease_owner
 mov w0,#0
 ldr x21,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x18,x30,[sp],#48
 ret
.size md2asm_release_forecast_dynamic_storage,.-md2asm_release_forecast_dynamic_storage
.p2align 2
.Lowner_offsets: .word 1577528,1577456,1565736
.section .note.GNU-stack,"",%progbits
