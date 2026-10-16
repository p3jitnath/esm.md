/* Own selected SETUP_GMV and its integer index maps.
 * Physics formulations/openifs/dynamics/forecast_time_loop.md.
 * Contract skills/md2asm/references/openifs/setup/grid_motion_field_storage.md.
 * Explicit owned inputs, complete fresh GMV1560, five read-only record pairs,
 * and selected six-word controls. Return0/1/2. No original state or callable. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_grid_motion_fields
.type md2asm_initialize_grid_motion_fields,%function
md2asm_initialize_grid_motion_fields:
 cbz x0,.Lgm_bad_leaf
 cmp x1,#1560
 b.lo .Lgm_bad_leaf
 cbz x2,.Lgm_bad_leaf
 cbz x3,.Lgm_bad_leaf
 orr x4,x0,x2
 tst x4,#7
 b.ne .Lgm_bad_leaf
 tst x3,#3
 b.ne .Lgm_bad_leaf
 adds x4,x0,#1560
 b.cs .Lgm_bad_leaf
 adds x5,x2,#80
 b.cs .Lgm_bad_leaf
 adds x6,x3,#24
 b.cs .Lgm_bad_leaf
 cmp x0,x5
 b.hs .Lgm_table_clear
 cmp x2,x4
 b.lo .Lgm_bad_leaf
.Lgm_table_clear:
 cmp x0,x6
 b.hs .Lgm_controls_clear
 cmp x3,x4
 b.lo .Lgm_bad_leaf
.Lgm_controls_clear:
 mrs x5,fpcr
 cbnz x5,.Lgm_bad_leaf
 adr x5,.Lgm_expected_controls
 mov x6,#0
.Lgm_control_loop:
 ldr w7,[x3,x6]
 ldr w8,[x5,x6]
 /* NUNDEFLD is a live NAMCT0 override and must be outside valid indices. */
 cmp x6,#12
 b.ne .Lgm_fixed_control
 cmp w7,#0
 b.ge .Lgm_bad_leaf
 b .Lgm_next_control
.Lgm_fixed_control:
 cmp w7,w8
 b.ne .Lgm_bad_leaf
.Lgm_next_control:
 add x6,x6,#4
 cmp x6,#24
 b.lo .Lgm_control_loop
 adr x5,.Lgm_record_sizes
 mov x6,#0
.Lgm_record_loop:
 lsl x7,x6,#4
 add x7,x2,x7
 ldp x8,x9,[x7]
 cbz x8,.Lgm_bad_leaf
 tst x8,#7
 b.ne .Lgm_bad_leaf
 ldr x10,[x5,x6,lsl#3]
 cmp x9,x10
 b.lo .Lgm_bad_leaf
 adds x11,x8,x10
 b.cs .Lgm_bad_leaf
 cmp x0,x11
 b.hs .Lgm_record_clear
 cmp x8,x4
 b.lo .Lgm_bad_leaf
.Lgm_record_clear:
 add x6,x6,#1
 cmp x6,#5
 b.lo .Lgm_record_loop
 ldr x8,[x2]
 ldr w9,[x8,#5144]
 sub w9,w9,#1
 cmp w9,#63
 b.hi .Lgm_bad_leaf
 ldr w9,[x8,#5224]
 sub w9,w9,#1
 cmp w9,#63
 b.hi .Lgm_bad_leaf
 ldr w9,[x8,#5160]
 sub w9,w9,#1
 cmp w9,#127
 b.hi .Lgm_bad_leaf
 ldr x8,[x2,#64]
 ldr w9,[x8,#0]
 cmp w9,#0
 b.ne .Lgm_bad_leaf
 ldr w9,[x8,#4]
 cmp w9,#0
 b.ne .Lgm_bad_leaf
 ldr w9,[x8,#8]
 cmp w9,#0
 b.ne .Lgm_bad_leaf
 ldr w9,[x8,#20]
 cmp w9,#1
 b.ne .Lgm_bad_leaf
 ldr w9,[x8,#40]
 cmp w9,#0
 b.ne .Lgm_bad_leaf
 ldr w9,[x8,#44]
 cmp w9,#0
 b.ne .Lgm_bad_leaf
 ldr w9,[x8,#48]
 cmp w9,#0
 b.ne .Lgm_bad_leaf
 ldr w9,[x8,#56]
 cmp w9,#0
 b.ne .Lgm_bad_leaf
 ldr w9,[x8,#68]
 cmp w9,#0
 b.ne .Lgm_bad_leaf
 ldr w9,[x8,#200]
 cmp w9,#1
 b.ne .Lgm_bad_leaf
 ldr w9,[x8,#280]
 cmp w9,#0
 b.ne .Lgm_bad_leaf
 ldr w9,[x8,#300]
 cmp w9,#0
 b.ne .Lgm_bad_leaf
 ldr w9,[x8,#304]
 cmp w9,#0
 b.ne .Lgm_bad_leaf
 ldr w9,[x8,#332]
 cmp w9,#0
 b.ne .Lgm_bad_leaf
 ldr w9,[x8,#336]
 cmp w9,#0
 b.ne .Lgm_bad_leaf
 ldr x8,[x2,#32]
 ldr w9,[x8,#164]
 cmp w9,#1
 b.hi .Lgm_bad_leaf
 ldr w9,[x8,#168]
 cmp w9,#1
 b.hi .Lgm_bad_leaf
 ldr w9,[x8,#0]
 cmp w9,#1
 b.ne .Lgm_bad_leaf
 mov x5,#0
.Lgm_fresh_loop:
 ldr x6,[x0,x5]
 cbnz x6,.Lgm_bad_leaf
 add x5,x5,#8
 cmp x5,#1560
 b.lo .Lgm_fresh_loop
 stp x29,x30,[sp,#-128]!
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x18,x27,[sp,#80]
 mov x19,x0
 mov x20,x2
 mov x21,x3
 bl __errno_location
 mov x22,x0
 ldr w23,[x0]
 ldr x1,[x20,#32]
 ldr x2,[x20,#64]
 mov x3,x21
 mov x0,x19
 bl md2asm_initialize_grid_motion_index_maps
 ldr x24,[x20]
 ldr w25,[x24,#5144]
 ldr w26,[x24,#5224]
 ldr w27,[x24,#5160]
 ldr w9,[x19,#992]
 umull x0,w25,w26
 mul x0,x0,x9
 mul x0,x0,x27
 lsl x0,x0,#3
 bl malloc
 cbz x0,.Lgm_alloc_failed
 str x0,[x19]
 mov x1,x19
 mov x2,#4
 mov x3,x25
 mov x4,x26
 ldr w5,[x19,#992]
 mov x6,x27
 bl .Lgm_descriptor
 ldr w9,[x19,#996]
 umull x0,w25,w9
 mul x0,x0,x27
 lsl x0,x0,#3
 bl malloc
 cbz x0,.Lgm_alloc_failed
 str x0,[x19,#136]
 add x1,x19,#136
 mov x2,#3
 mov x3,x25
 ldr w4,[x19,#996]
 mov x5,x27
 mov x6,#1
 bl .Lgm_descriptor
 mov w0,#0
 b .Lgm_return
.Lgm_alloc_failed:
 ldr x0,[x19]
 cbz x0,.Lgm_cleanup_done
 bl free
 str xzr,[x19]
.Lgm_cleanup_done:
 mov w0,#1
.Lgm_return:
 str w23,[x22]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x18,x27,[sp,#80]
 ldp x29,x30,[sp],#128
 ret
.Lgm_bad_leaf:
 mov w0,#2
 ret
.size md2asm_initialize_grid_motion_fields,.-md2asm_initialize_grid_motion_fields

/* Internal GNU descriptor writer. x1 descriptor, x2 rank3/4, x3..6 extents.
 * The owner word is already set. All lower bounds are one, element width8. */
.Lgm_descriptor:
 mov x7,#8
 str x7,[x1,#16]
 str wzr,[x1,#24]
 strb w2,[x1,#28]
 mov w8,#3
 strb w8,[x1,#29]
 strh wzr,[x1,#30]
 str x7,[x1,#32]
 mov x8,#1
 str x8,[x1,#40]
 str x8,[x1,#48]
 str x3,[x1,#56]
 str x3,[x1,#64]
 str x8,[x1,#72]
 str x4,[x1,#80]
 mul x9,x3,x4
 str x9,[x1,#88]
 str x8,[x1,#96]
 str x5,[x1,#104]
 add x10,x3,#1
 add x10,x10,x9
 cmp x2,#3
 b.eq .Lgm_descriptor_end
 mul x11,x9,x5
 str x11,[x1,#112]
 str x8,[x1,#120]
 str x6,[x1,#128]
 add x10,x10,x11
.Lgm_descriptor_end:
 neg x10,x10
 str x10,[x1,#8]
 ret

.p2align 4
.global md2asm_initialize_grid_motion_index_maps
.type md2asm_initialize_grid_motion_index_maps,%function
/* Raw selected child. x0 GMV1560,x1 TDIMF176,x2 TDYNA456,x3 controls24.
 * Caller validates full ranges and selected flags. All instructions are integer. */
md2asm_initialize_grid_motion_index_maps:
 ldr w9,[x3,#12]
 mov x10,#992
.Lgm_sentinel_loop:
 str w9,[x0,x10]
 add x10,x10,#4
 cmp x10,#1556
 b.lo .Lgm_sentinel_loop
 mov w10,#0
 mov w11,#0
 ldr w12,[x1,#164]
 cbz w12,.Lgm_t0_0_no_horizontal_derivatives
 add w10,w10,#1
 str w10,[x0,#1036]
 add w10,w10,#1
 str w10,[x0,#1032]
.Lgm_t0_0_no_horizontal_derivatives:
 add w10,w10,#1
 str w10,[x0,#1012]
 add w10,w10,#1
 str w10,[x0,#1016]
 ldr w13,[x1,#168]
 cbz w13,.Lgm_t0_0_no_wind_derivatives
 add w10,w10,#1
 str w10,[x0,#1040]
 add w10,w10,#1
 str w10,[x0,#1044]
.Lgm_t0_0_no_wind_derivatives:
 str w10,[x0,#1008]
 add w10,w10,#1
 str w10,[x0,#1020]
 cbz w12,.Lgm_t0_0_no_temperature_derivatives
 add w10,w10,#1
 str w10,[x0,#1028]
 add w10,w10,#1
 str w10,[x0,#1024]
.Lgm_t0_0_no_temperature_derivatives:
 add w11,w11,#1
 str w11,[x0,#1096]
 cbz w12,.Lgm_t0_0_no_pressure_derivatives
 add w11,w11,#1
 str w11,[x0,#1104]
 add w11,w11,#1
 str w11,[x0,#1100]
.Lgm_t0_0_no_pressure_derivatives:
 add w10,w10,#1
 str w10,[x0,#1088]
 add w10,w10,#1
 str w10,[x0,#1092]
 str w10,[x0,#1000]
 str w11,[x0,#1004]
 mov w10,#0
 mov w11,#0
 ldr w12,[x1,#164]
 cbz w12,.Lgm_t0_1_no_horizontal_derivatives
 add w10,w10,#1
 str w10,[x0,#1484]
 add w10,w10,#1
 str w10,[x0,#1480]
.Lgm_t0_1_no_horizontal_derivatives:
 add w10,w10,#1
 str w10,[x0,#1460]
 add w10,w10,#1
 str w10,[x0,#1464]
 ldr w13,[x1,#168]
 cbz w13,.Lgm_t0_1_no_wind_derivatives
 add w10,w10,#1
 str w10,[x0,#1488]
 add w10,w10,#1
 str w10,[x0,#1492]
.Lgm_t0_1_no_wind_derivatives:
 str w10,[x0,#1456]
 add w10,w10,#1
 str w10,[x0,#1468]
 cbz w12,.Lgm_t0_1_no_temperature_derivatives
 add w10,w10,#1
 str w10,[x0,#1476]
 add w10,w10,#1
 str w10,[x0,#1472]
.Lgm_t0_1_no_temperature_derivatives:
 add w11,w11,#1
 str w11,[x0,#1544]
 cbz w12,.Lgm_t0_1_no_pressure_derivatives
 add w11,w11,#1
 str w11,[x0,#1552]
 add w11,w11,#1
 str w11,[x0,#1548]
.Lgm_t0_1_no_pressure_derivatives:
 add w10,w10,#1
 str w10,[x0,#1536]
 add w10,w10,#1
 str w10,[x0,#1540]
 str w10,[x0,#1448]
 str w11,[x0,#1452]
 ldr w10,[x0,#1000]
 mov w12,w10
 add w10,w10,#1
 str w10,[x0,#1116]
 add w10,w10,#1
 str w10,[x0,#1120]
 add w10,w10,#1
 str w10,[x0,#1136]
 add w10,w10,#1
 str w10,[x0,#1140]
 add w10,w10,#1
 str w10,[x0,#1148]
 add w10,w10,#1
 str w10,[x0,#1156]
 add w10,w10,#1
 str w10,[x0,#1164]
 add w10,w10,#1
 str w10,[x0,#1316]
 add w10,w10,#1
 str w10,[x0,#1320]
 sub w9,w10,w12
 str w9,[x0,#1108]
 mov w9,#0
 str w9,[x0,#1112]
 str w10,[x0,#992]
 ldr w9,[x0,#1004]
 str w9,[x0,#996]
 mov w9,#1
 str w9,[x0,#1368]
 mov w9,#2
 str w9,[x0,#1372]
 mov w9,#3
 str w9,[x0,#1376]
 mov w9,#1
 str w9,[x0,#1388]
 mov w9,#2
 str w9,[x0,#1392]
 mov w9,#1
 str w9,[x0,#1400]
 mov w9,#3
 str w9,[x0,#1360]
 mov w9,#1
 str w9,[x0,#1364]
 ldr w9,[x0,#1012]
 str w9,[x0,#1404]
 ldr w9,[x0,#1016]
 str w9,[x0,#1408]
 ldr w9,[x0,#1020]
 str w9,[x0,#1412]
 ldr w9,[x0,#1096]
 str w9,[x0,#1416]
 mov w9,#1
 str w9,[x0,#1424]
 mov w9,#2
 str w9,[x0,#1428]
 mov w9,#3
 str w9,[x0,#1432]
 mov w9,#3
 str w9,[x0,#1420]
 mov w9,#1
 str w9,[x0,#1436]
 mov w9,#1
 str w9,[x0,#1440]
 mov w9,#1
 str w9,[x0,#1444]
 mov w0,#0
 ret
.size md2asm_initialize_grid_motion_index_maps,.-md2asm_initialize_grid_motion_index_maps
.p2align 4
.global md2asm_zero_grid_motion_fields
.type md2asm_zero_grid_motion_fields,%function
/* Source ZERO_YOMGMV: only GMV/GMVS logical cells, valid live selected record. */
md2asm_zero_grid_motion_fields:
 mov x9,x0
 mov x10,#0
.Lgm_zero_owner:
 ldr x11,[x9,x10]
 cbz x11,.Lgm_zero_next
 add x12,x9,x10
 ldr x13,[x12,#88]
 ldr x14,[x12,#104]
 mul x13,x13,x14
 cbnz x10,.Lgm_zero_extent_ready
 ldr x14,[x12,#128]
 mul x13,x13,x14
.Lgm_zero_extent_ready:
 cbz x13,.Lgm_zero_next
.Lgm_zero_words:
 str xzr,[x11],#8
 subs x13,x13,#1
 b.ne .Lgm_zero_words
.Lgm_zero_next:
 cbnz x10,.Lgm_zero_done
 mov x10,#136
 b .Lgm_zero_owner
.Lgm_zero_done:
 mov w0,#0
 ret
.size md2asm_zero_grid_motion_fields,.-md2asm_zero_grid_motion_fields
.p2align 4
.global md2asm_release_grid_motion_fields
.type md2asm_release_grid_motion_fields,%function
/* Selected DEALXMO owner release statements; record and metadata stay live. */
md2asm_release_grid_motion_fields:
 stp x29,x30,[sp,#-48]!
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x18,x21,[sp,#32]
 mov x19,x0
 bl __errno_location
 mov x20,x0
 ldr w21,[x0]
 ldr x0,[x19]
 cbz x0,.Lgm_release_second
 bl free
 str xzr,[x19]
.Lgm_release_second:
 ldr x0,[x19,#136]
 cbz x0,.Lgm_release_done
 bl free
 str xzr,[x19,#136]
.Lgm_release_done:
 str w21,[x20]
 mov w0,#0
 ldp x19,x20,[sp,#16]
 ldp x18,x21,[sp,#32]
 ldp x29,x30,[sp],#48
 ret
.size md2asm_release_grid_motion_fields,.-md2asm_release_grid_motion_fields
.section .rodata
.p2align 3
.Lgm_expected_controls: .word 1,1,0,-99999999,0,0
.Lgm_record_sizes: .quad 17096,448,176,1096,456
.section .note.GNU-stack,"",%progbits
