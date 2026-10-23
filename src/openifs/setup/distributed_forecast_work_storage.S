/* Qualified live-provider contract: skills/md2asm/references/openifs/setup/operational_enclosing_model_storage.md. */
/* Operational source-ordered six-owner storage bridge.
 * Contract: skills/md2asm/references/openifs/setup/operational_forecast_work_storage.md.
 * AAPCS64: borrowed stable Geometry17096, MODEL4275088, FIELDS529288.
 * create(x0 Geometry,x1 MODEL,x2 FIELDS,x3 zero output8); advance/release(x0 owner128).
 * Raw array allocation preserves source-unwritten departure-point values. */
.arch armv8.2-a
.text
.macro OADDR out,base,off
 mov x17,#(\off & 65535)
 movk x17,#(\off >> 16),lsl#16
 add \out,\base,x17
.endm
.macro ENTER bytes
 sub sp,sp,#\bytes
 stp x29,x30,[sp]
 mov x29,sp
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 stp x22,x23,[sp,#48]
 stp x24,x25,[sp,#64]
 stp x26,x27,[sp,#80]
 str x28,[sp,#96]
.endm
.macro LEAVE bytes
 ldp x18,x19,[sp,#16]
 ldp x20,x21,[sp,#32]
 ldp x22,x23,[sp,#48]
 ldp x24,x25,[sp,#64]
 ldp x26,x27,[sp,#80]
 ldr x28,[sp,#96]
 ldp x29,x30,[sp]
 add sp,sp,#\bytes
 ret
.endm
.p2align 4
.global md2asm_create_distributed_forecast_work_storage
.type md2asm_create_distributed_forecast_work_storage,%function
md2asm_create_distributed_forecast_work_storage:
 ENTER 640
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 bl .Lrecords
 cbnz w0,.Lcreate_reject
 cbz x22,.Lcreate_reject
 tst x22,#7
 b.ne .Lcreate_reject
 adds x10,x22,#8
 b.cs .Lcreate_reject
 ldr x9,[x22]
 cbnz x9,.Lcreate_reject
 /* The output word must be outside all borrowed record spans. */
 mov x11,x19
 mov x12,#17096
 bl .Loutput_clear
 cbnz w0,.Lcreate_reject
 mov x11,x20
 mov x12,#(4275088 & 65535)
 movk x12,#(4275088 >> 16),lsl#16
 bl .Loutput_clear
 cbnz w0,.Lcreate_reject
 mov x11,x21
 mov x12,#(529288 & 65535)
 movk x12,#(529288 >> 16),lsl#16
 bl .Loutput_clear
 cbnz w0,.Lcreate_reject
 OADDR x9,x20,1359328
 ldp w10,w11,[x9]
 cbnz w10,.Lcreate_reject
 cmp w11,#1
 b.lt .Lcreate_reject
 OADDR x9,x20,1568900
 ldp w10,w11,[x9]
 cmp w10,#1
 b.ne .Lcreate_reject
 cmp w11,#1
 b.ne .Lcreate_reject
 OADDR x9,x20,1578148
 ldr w10,[x9]
 cmp w10,#1
 b.ne .Lcreate_reject
 bl .Lall_empty
 cbnz w0,.Lcreate_reject
 mrs x26,fpcr
 cbnz x26,.Lcreate_reject
 mrs x27,fpsr
 bl __errno_location
 mov x24,x0
 ldr w25,[x24]
 /* Retain every MODEL byte changed by the three dynamic children. */
 OADDR x0,x20,1565736
 add x1,sp,#192
 mov x2,#136
 bl .Lcopy
 OADDR x0,x20,1577456
 add x1,sp,#328
 mov x2,#64
 bl .Lcopy
 OADDR x0,x20,1577528
 add x1,sp,#392
 mov x2,#136
 bl .Lcopy
 OADDR x9,x20,1577520
 ldr w10,[x9]
 str w10,[sp,#528]
 OADDR x9,x20,1577800
 ldr x10,[x9]
 ldr w11,[x9,#8]
 str x10,[sp,#536]
 str w11,[sp,#544]
 mov x0,#1
 mov x1,#128
 bl calloc
 cbz x0,.Lcreate_nomemory
 mov x23,x0
 mov x0,x19
 mov x1,#17096
 mov x2,x20
 mov x3,#(4275088 & 65535)
 movk x3,#(4275088 >> 16),lsl#16
 bl md2asm_operational_allocate_saved_departure_points
 cbnz w0,.Lcreate_rollback
 adrp x9,.Lmagic
 ldr x9,[x9,:lo12:.Lmagic]
 str x9,[x23]
 stp x19,x20,[x23,#8]
 str x21,[x23,#24]
 mov x9,#1
 str x9,[x23,#32]
 OADDR x9,x20,1565736
 ldr x10,[x9]
 str x10,[x23,#40]
 str x23,[x22]
 mov w28,#0
 b .Lcreate_restore_env
.Lcreate_rollback:
 mov w28,w0
 mov x0,x20
 mov x1,#(4275088 & 65535)
 movk x1,#(4275088 >> 16),lsl#16
 bl md2asm_operational_release_forecast_dynamic_storage
 add x0,sp,#192
 OADDR x1,x20,1565736
 mov x2,#136
 bl .Lcopy
 add x0,sp,#328
 OADDR x1,x20,1577456
 mov x2,#64
 bl .Lcopy
 add x0,sp,#392
 OADDR x1,x20,1577528
 mov x2,#136
 bl .Lcopy
 OADDR x9,x20,1577520
 ldr w10,[sp,#528]
 str w10,[x9]
 OADDR x9,x20,1577800
 ldr x10,[sp,#536]
 ldr w11,[sp,#544]
 str x10,[x9]
 str w11,[x9,#8]
 mov x0,x23
 bl free
 b .Lcreate_restore_env
.Lcreate_nomemory:
 mov w28,#1
.Lcreate_restore_env:
 str w25,[x24]
 msr fpcr,x26
 msr fpsr,x27
 mov w0,w28
 b .Lcreate_exit
.Lcreate_reject:
 mov w0,#2
.Lcreate_exit:
 LEAVE 640
.size md2asm_create_distributed_forecast_work_storage,.-md2asm_create_distributed_forecast_work_storage
.p2align 4
.global md2asm_advance_distributed_forecast_work_storage
.type md2asm_advance_distributed_forecast_work_storage,%function
md2asm_advance_distributed_forecast_work_storage:
 ENTER 640
 mov x23,x0
 bl .Lowner
 cbnz w0,.Ladvance_exit
 ldr x9,[x23,#32]
 cmp x9,#4
 b.hs .Ladvance_bad
 mrs x26,fpcr
 cbnz x26,.Ladvance_bad
 mrs x27,fpsr
 bl __errno_location
 mov x24,x0
 ldr w25,[x24]
 ldr x9,[x23,#32]
 cmp x9,#1
 b.eq .Ladvance_lagged
 cmp x9,#2
 b.eq .Ladvance_saved
 /* First GP_MODEL: preserve descriptors if a later allocation fails. */
 add x0,x21,#2104
 add x1,sp,#192
 mov x2,#136
 bl .Lcopy
 add x0,x21,#2240
 add x1,sp,#328
 mov x2,#136
 bl .Lcopy
 add x0,x21,#3552
 add x1,sp,#464
 mov x2,#136
 bl .Lcopy
 OADDR x9,x20,256
 ldr w10,[x9]
 cmp w10,#64
 b.hi .Ladvance_bad_env
 mov w9,#17
 str w9,[sp,#112]
 mov w9,#137
 str w9,[sp,#116]
 mov x9,#5160
 ldr w9,[x19,x9]
 str w9,[sp,#120]
 str w10,[sp,#124]
 mov x0,x21
 mov x1,#(529288 & 65535)
 movk x1,#(529288 >> 16),lsl#16
 add x2,sp,#112
 bl md2asm_operational_prepare_next_time_fields
 mov w28,w0
 cbz w0,.Ladvance_next_success
 add x0,sp,#192
 add x1,x21,#2104
 mov x2,#136
 bl .Lcopy
 add x0,sp,#328
 add x1,x21,#2240
 mov x2,#136
 bl .Lcopy
 add x0,sp,#464
 add x1,x21,#3552
 mov x2,#136
 bl .Lcopy
 b .Ladvance_env
.Ladvance_next_success:
 ldr x9,[x21,#2104]
 str x9,[x23,#64]
 ldr x9,[x21,#2240]
 str x9,[x23,#72]
 ldr x9,[x21,#3552]
 str x9,[x23,#80]
 ldp x9,x10,[sp,#112]
 stp x9,x10,[x23,#88]
 b .Ladvance_success
.Ladvance_lagged:
 /* SUSAVTEND allocation and the following SUDYN 0.5 assignment. */
 mov x0,x19
 mov x1,#17096
 mov x2,x20
 mov x3,#(4275088 & 65535)
 movk x3,#(4275088 >> 16),lsl#16
 bl md2asm_operational_initialize_lagged_tendency_configuration
 mov w28,w0
 cbnz w0,.Ladvance_env
 OADDR x9,x20,1577456
 ldr x10,[x9]
 str x10,[x23,#48]
 b .Ladvance_success
.Ladvance_saved:
 /* SUSC2B allocates and zeroes SAVTEND only after intervening setup. */
 mov x0,x19
 mov x1,#17096
 mov x2,x20
 mov x3,#(4275088 & 65535)
 movk x3,#(4275088 >> 16),lsl#16
 bl md2asm_operational_allocate_saved_physics_tendencies
 mov w28,w0
 cbnz w0,.Ladvance_env
 OADDR x9,x20,1577528
 ldr x10,[x9]
 str x10,[x23,#56]
.Ladvance_success:
 ldr x9,[x23,#32]
 add x9,x9,#1
 str x9,[x23,#32]
 mov w28,#0
 b .Ladvance_env
.Ladvance_bad_env:
 mov w28,#2
.Ladvance_env:
 str w25,[x24]
 msr fpcr,x26
 msr fpsr,x27
 mov w0,w28
 b .Ladvance_exit
.Ladvance_bad:
 mov w0,#2
.Ladvance_exit:
 LEAVE 640
.size md2asm_advance_distributed_forecast_work_storage,.-md2asm_advance_distributed_forecast_work_storage
.p2align 4
.global md2asm_release_distributed_forecast_work_storage
.type md2asm_release_distributed_forecast_work_storage,%function
md2asm_release_distributed_forecast_work_storage:
 cbz x0,.Lnull_release
 ENTER 128
 mov x23,x0
 bl .Lowner
 cbnz w0,.Lrelease_exit
 bl __errno_location
 mov x24,x0
 ldr w25,[x24]
 mrs x26,fpcr
 mrs x27,fpsr
 ldr x9,[x23,#32]
 cmp x9,#4
 b.ne .Lrelease_dynamic
 mov x0,x21
 bl md2asm_operational_release_next_time_fields
.Lrelease_dynamic:
 mov x0,x20
 mov x1,#(4275088 & 65535)
 movk x1,#(4275088 >> 16),lsl#16
 bl md2asm_operational_release_forecast_dynamic_storage
 str xzr,[x23]
 mov x0,x23
 bl free
 str w25,[x24]
 msr fpcr,x26
 msr fpsr,x27
 mov w0,#0
.Lrelease_exit:
 LEAVE 128
.Lnull_release:
 mov w0,#0
 ret
.size md2asm_release_distributed_forecast_work_storage,.-md2asm_release_distributed_forecast_work_storage
/* Helpers retain x18..x28 and return 0/2. */
.Lrecords:
 cbz x19,.Lhelper_bad
 cbz x20,.Lhelper_bad
 cbz x21,.Lhelper_bad
 orr x9,x19,x20
 orr x9,x9,x21
 tst x9,#7
 b.ne .Lhelper_bad
 mov x9,#17096
 adds x10,x19,x9
 b.cs .Lhelper_bad
 mov x9,#(4275088 & 65535)
 movk x9,#(4275088 >> 16),lsl#16
 adds x11,x20,x9
 b.cs .Lhelper_bad
 mov x9,#(529288 & 65535)
 movk x9,#(529288 >> 16),lsl#16
 adds x12,x21,x9
 b.cs .Lhelper_bad
 cmp x19,x11
 b.hs .Lrecord_pair2
 cmp x20,x10
 b.lo .Lhelper_bad
.Lrecord_pair2:
 cmp x19,x12
 b.hs .Lrecord_pair3
 cmp x21,x10
 b.lo .Lhelper_bad
.Lrecord_pair3:
 cmp x20,x12
 b.hs .Lrecord_shape
 cmp x21,x11
 b.lo .Lhelper_bad
.Lrecord_shape:
 mov x9,#5144
 ldr w10,[x19,x9]
 cmp w10,#17
 b.ne .Lhelper_bad
 mov x9,#5224
 ldr w10,[x19,x9]
 cmp w10,#137
 b.ne .Lhelper_bad
 mov x9,#5160
 ldr w10,[x19,x9]
 mov w11,#(97055 & 65535)
 movk w11,#(97055 >> 16),lsl#16
 cmp w10,w11
 b.ne .Lhelper_bad
 mov w0,#0
 ret
.Loutput_clear:
 add x12,x11,x12
 cmp x22,x12
 b.hs .Lhelper_good
 cmp x11,x10
 b.lo .Lhelper_bad
.Lhelper_good:
 mov w0,#0
 ret
.Lhelper_bad:
 mov w0,#2
 ret
.Lall_empty:
 OADDR x9,x20,1565736
 ldr x10,[x9]
 cbnz x10,.Lhelper_bad
 OADDR x9,x20,1577456
 ldr x10,[x9]
 cbnz x10,.Lhelper_bad
 OADDR x9,x20,1577528
 ldr x10,[x9]
 cbnz x10,.Lhelper_bad
.Lnext_empty:
 ldr x9,[x21,#2104]
 cbnz x9,.Lhelper_bad
 ldr x9,[x21,#2240]
 cbnz x9,.Lhelper_bad
 ldr x9,[x21,#3552]
 cbnz x9,.Lhelper_bad
 mov w0,#0
 ret
.Lowner:
 cbz x23,.Lhelper_bad
 tst x23,#7
 b.ne .Lhelper_bad
 adds x9,x23,#128
 b.cs .Lhelper_bad
 adrp x9,.Lmagic
 ldr x9,[x9,:lo12:.Lmagic]
 ldr x10,[x23]
 cmp x9,x10
 b.ne .Lhelper_bad
 ldp x19,x20,[x23,#8]
 ldr x21,[x23,#24]
 /* Save the caller return because record validation is a leaf call. */
 mov x16,x30
 bl .Lrecords
 mov x30,x16
 cbnz w0,.Lhelper_bad
 ldr x9,[x23,#32]
 sub x10,x9,#1
 cmp x10,#3
 b.hi .Lhelper_bad
 OADDR x9,x20,1565736
 ldr x10,[x9]
 ldr x11,[x23,#40]
 cbz x11,.Lhelper_bad
 cmp x10,x11
 b.ne .Lhelper_bad
 OADDR x9,x20,1577456
 ldr x10,[x9]
 ldr x11,[x23,#48]
 cmp x10,x11
 b.ne .Lhelper_bad
 OADDR x9,x20,1577528
 ldr x10,[x9]
 ldr x11,[x23,#56]
 cmp x10,x11
 b.ne .Lhelper_bad
 ldr x9,[x23,#32]
 cmp x9,#4
 b.ne .Lnext_empty
 ldr x9,[x21,#2104]
 ldr x10,[x23,#64]
 cmp x9,x10
 b.ne .Lhelper_bad
 ldr x9,[x21,#2240]
 ldr x10,[x23,#72]
 cmp x9,x10
 b.ne .Lhelper_bad
 ldr x9,[x21,#3552]
 ldr x10,[x23,#80]
 cmp x9,x10
 b.ne .Lhelper_bad
 mov w0,#0
 ret
.Lcopy:
 ldr x9,[x0],#8
 str x9,[x1],#8
 subs x2,x2,#8
 b.ne .Lcopy
 ret
.section .rodata
.p2align 3
.Lmagic: .ascii "OPWORK01"
.section .note.GNU-stack,"",%progbits
