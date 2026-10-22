/* Contract: skills/md2asm/references/openifs/setup/spectral_field_storage.md. */
/* Complete selected global serial SPECTRAL_FIELD construction and release.
 * Raw initialize x0=zero record2992B,w1=levels,w2=trunc,x3=IDs5,x4=dummy24B.
 * Return w0=0,1 allocation failure with cleanup,2 unsupported before mutation.
 * Production has no original module, type, vtable, callable or state packet.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_serial_spectral_field
.type md2asm_initialize_serial_spectral_field,%function
md2asm_initialize_serial_spectral_field:
 cbz x0,.Lspec_reject
 cbz x3,.Lspec_reject
 cbz x4,.Lspec_reject
 orr x9,x0,x4
 tst x9,#7
 b.ne .Lspec_reject
 tst x3,#3
 b.ne .Lspec_reject
 cmp w2,#1279
 b.ne .Lspec_legacy_dimensions
 cmp w1,#137
 b.eq .Lspec_dimensions_ready
.Lspec_legacy_dimensions:
 sub w9,w1,#1
 cmp w9,#63
 b.hi .Lspec_reject
 cmp w2,#63
 b.hi .Lspec_reject
.Lspec_dimensions_ready:
 mrs x9,fpcr
 cbnz x9,.Lspec_reject
 /* A fresh record is an explicit owned input, not a source type table. */
 mov x9,#0
.Lspec_check_zero_record:
 ldr x10,[x0,x9]
 cbnz x10,.Lspec_reject
 add x9,x9,#8
 cmp x9,#2992
 b.lo .Lspec_check_zero_record
 adr x9,.Lspec_ids
 mov x10,#0
.Lspec_check_ids:
 ldr w11,[x9,x10,lsl#2]
 cmp x10,#3
 mov x12,#0
 mov x13,#3
 b.lo .Lspec_id_group
 mov x12,#3
 mov x13,#5
.Lspec_id_group:
 ldr w14,[x3,x12,lsl#2]
 cmp w14,w11
 b.eq .Lspec_id_found
 add x12,x12,#1
 cmp x12,x13
 b.lo .Lspec_id_group
 b .Lspec_reject
.Lspec_id_found:
 add x10,x10,#1
 cmp x10,#5
 b.lo .Lspec_check_ids
 sub sp,sp,#144
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mov x19,x0
 mov w20,w1
 mov w21,w2
 mov x22,x3
 mov x23,x4
 add w9,w21,#1
 add w10,w21,#2
 mul w28,w9,w10
 bl __errno_location
 mov x24,x0
 ldr w25,[x24]
 adr x27,.Lspec_owners
 mov x26,#0
.Lspec_allocate:
 ldr w0,[x27,#12]
 bl .Lspec_extent
 str x0,[sp,#112]
 ldr w0,[x27,#20]
 bl .Lspec_extent
 str x0,[sp,#120]
 ldr w0,[x27,#24]
 bl .Lspec_extent
 str x0,[sp,#128]
 ldr x9,[sp,#112]
 ldr x10,[sp,#120]
 mul x0,x0,x9
 mul x0,x0,x10
 ldr w9,[x27,#8]
 mul x0,x0,x9
 bl malloc
 cbz x0,.Lspec_failed
 mov x1,x0
 ldr w9,[x27]
 add x0,x19,w9,uxtw
 ldp w3,w2,[x27,#4]
 ldr w4,[x27,#16]
 ldr x5,[sp,#112]
 add x5,x5,x4
 sub x5,x5,#1
 ldr x6,[sp,#120]
 ldr x7,[sp,#128]
 bl .Lspec_descriptor
 add x27,x27,#32
 add x26,x26,#1
 cmp x26,#16
 b.lo .Lspec_allocate
 /* Scalar dimensions are exact bounded integer source expressions. */
 str w21,[x19,#288]
 str wzr,[x19,#292]
 mov w9,#2
 mov w10,#3
 str w9,[x19,#296]
 str w10,[x19,#300]
 str wzr,[x19,#304]
 str w9,[x19,#308]
 str w20,[x19,#312]
 str w20,[x19,#316]
 str w28,[x19,#320]
 str w28,[x19,#324]
 add w11,w21,#1
 str w11,[x19,#328]
 madd w10,w20,w10,w9
 mul w10,w10,w28
 str w10,[x19,#332]
 str w10,[x19,#336]
 ldr x0,[x19,#408]
 ldr x1,[x19,#792]
 ldr x2,[x19,#1136]
 ldr x3,[x19,#728]
 mov w4,w21
 bl md2asm_serial_spectral_wave_distribution
 cbnz w0,.Lspec_failed
 ldr x9,[x19,#1200]
 ldr x10,[x19,#792]
 ldr x11,[x19,#856]
 ldr x12,[x19,#408]
 ldr x13,[x19,#472]
 mov x14,#0
.Lspec_wave_maps:
 str w14,[x9,x14,lsl#2]
 ldr w15,[x10,x14,lsl#2]
 str w15,[x11,x14,lsl#2]
 ldr w15,[x12,x14,lsl#2]
 str w15,[x13,x14,lsl#2]
 add x14,x14,#1
 cmp w14,w21
 b.ls .Lspec_wave_maps
 ldr x9,[x19,#944]
 str w20,[x9]
 ldr x9,[x19,#1008]
 str wzr,[x9]
 ldr x9,[x19,#1072]
 mov w10,#1
 str w10,[x9]
 ldr x9,[x19,#344]
 mov w10,#2
 str w10,[x9]
 ldr x9,[x19,#1264]
 mov x10,#0
.Lspec_level_map:
 str w10,[x9,x10,lsl#2]
 add x10,x10,#1
 cmp w10,w20
 b.lo .Lspec_level_map
 ldr x9,[x19,#1328]
 adr x10,.Lspec_ids
 mov x11,#0
.Lspec_field_map:
 ldr w12,[x10,x11,lsl#2]
 str w12,[x9,x11,lsl#2]
 add x11,x11,#1
 cmp x11,#5
 b.lo .Lspec_field_map
 /* Every numerical owner starts at positive zero, as CREATE_SPEC requires. */
 ldr x0,[x19,#88]
 mul x1,x20,x28
 mov x9,#24
 mul x1,x1,x9
 bl .Lspec_zero
 ldr x0,[x19]
 lsl x1,x28,#4
 bl .Lspec_zero
 ldr x0,[x19,#200]
 mov x1,#16
 bl .Lspec_zero
 stp xzr,xzr,[x23]
 str xzr,[x23,#16]
 add x0,x19,#1456
 ldr x1,[x19,#1328]
 mov w2,#4
 mov w3,#1
 mov x4,#1
 mov x5,#3
 mov x6,#1
 mov x7,#1
 bl .Lspec_descriptor
 add x0,x19,#1392
 ldr x1,[x19,#1328]
 add x1,x1,#12
 mov w2,#4
 mov w3,#1
 mov x4,#1
 mov x5,#2
 mov x6,#1
 mov x7,#1
 bl .Lspec_descriptor
 adr x27,.Lspec_views
 mov x26,#0
.Lspec_view_loop:
 ldr w0,[x27,#16]
 bl .Lspec_extent
 str x0,[sp,#112]
 ldr w0,[x27,#20]
 bl .Lspec_extent
 str x0,[sp,#120]
 ldr w0,[x27,#24]
 bl .Lspec_extent
 str x0,[sp,#128]
 ldr w9,[x27,#8]
 cmp w9,#0
 b.eq .Lspec_view_sp3
 cmp w9,#1
 b.eq .Lspec_view_sp2
 cmp w9,#2
 b.eq .Lspec_view_sp1
 cmp w9,#3
 b.eq .Lspec_view_dummy3
 add x1,x23,#16
 b .Lspec_view_address_ready
.Lspec_view_dummy3:
 add x1,x23,#8
 b .Lspec_view_address_ready
.Lspec_view_sp3:
 ldr x1,[x19,#88]
 ldr w9,[x27,#12]
 mul x10,x20,x28
 mul x9,x9,x10
 add x1,x1,x9,lsl#3
 b .Lspec_view_address_ready
.Lspec_view_sp2:
 ldr x1,[x19]
 ldr w9,[x27,#12]
 mul x9,x9,x28
 add x1,x1,x9,lsl#3
 b .Lspec_view_address_ready
.Lspec_view_sp1:
 ldr x1,[x19,#200]
 ldr w9,[x27,#12]
 add x1,x1,x9,lsl#3
.Lspec_view_address_ready:
 ldr w9,[x27]
 add x0,x19,w9,uxtw
 mov w2,#8
 ldr w3,[x27,#4]
 mov x4,#1
 ldr x5,[sp,#112]
 ldr x6,[sp,#120]
 ldr x7,[sp,#128]
 bl .Lspec_descriptor
 add x27,x27,#32
 add x26,x26,#1
 cmp x26,#16
 b.lo .Lspec_view_loop
 mov w0,#0
 b .Lspec_return
.Lspec_failed:
 mov x0,x19
 bl md2asm_release_serial_spectral_field
 mov w0,#1
.Lspec_return:
 str w25,[x24]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldr x18,[sp,#96]
 ldp x29,x30,[sp]
 add sp,sp,#144
 ret
.Lspec_reject:
 mov w0,#2
 ret
.size md2asm_initialize_serial_spectral_field,.-md2asm_initialize_serial_spectral_field
/* Extent selectors:1=>N+1,2=>levels,3=>5,4=>S,5=>3,6=>2,0=>1. */
.Lspec_extent:
 cbz w0,.Lspec_extent_one
 cmp w0,#1
 b.eq .Lspec_extent_waves
 cmp w0,#2
 b.eq .Lspec_extent_levels
 cmp w0,#3
 b.eq .Lspec_extent_five
 cmp w0,#4
 b.eq .Lspec_extent_spectral
 cmp w0,#5
 b.eq .Lspec_extent_three
 mov w0,#2
 ret
.Lspec_extent_one: mov w0,#1
 ret
.Lspec_extent_waves: add w0,w21,#1
 ret
.Lspec_extent_levels: mov w0,w20
 ret
.Lspec_extent_five: mov w0,#5
 ret
.Lspec_extent_spectral: mov w0,w28
 ret
.Lspec_extent_three: mov w0,#3
 ret
/* GNU descriptor from actual source type layout; higher lower bounds are1. */
.Lspec_descriptor:
 str x1,[x0]
 str x2,[x0,#16]
 str xzr,[x0,#24]
 mov w9,#0x100
 mov w10,#0x300
 cmp w2,#8
 csel w9,w10,w9,eq
 orr w9,w9,w3
 str w9,[x0,#28]
 str x2,[x0,#32]
 mov x9,#1
 str x9,[x0,#40]
 stp x4,x5,[x0,#48]
 neg x11,x4
 sub x10,x5,x4
 add x10,x10,#1
 cmp w3,#2
 b.lo .Lspec_descriptor_done
 str x10,[x0,#64]
 str x9,[x0,#72]
 str x6,[x0,#80]
 sub x11,x11,x10
 cmp w3,#3
 b.lo .Lspec_descriptor_done
 mul x10,x10,x6
 str x10,[x0,#88]
 str x9,[x0,#96]
 str x7,[x0,#104]
 sub x11,x11,x10
.Lspec_descriptor_done:
 str x11,[x0,#8]
 ret
.Lspec_zero:
 cmp x1,#16
 b.lo .Lspec_zero_tail
 stp xzr,xzr,[x0],#16
 sub x1,x1,#16
 b .Lspec_zero
.Lspec_zero_tail:
 cbz x1,.Lspec_zero_done
 str xzr,[x0]
.Lspec_zero_done: ret
.p2align 4
.global md2asm_release_serial_spectral_field
.type md2asm_release_serial_spectral_field,%function
md2asm_release_serial_spectral_field:
 cbz x0,.Lspec_release_reject
 tst x0,#7
 b.ne .Lspec_release_reject
 sub sp,sp,#96
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x18,[sp,#48]
 mov x19,x0
 mrs x9,fpcr
 str x9,[sp,#64]
 mrs x9,fpsr
 str x9,[sp,#72]
 bl __errno_location
 mov x20,x0
 ldr w21,[x20]
 adr x9,.Lspec_pointer_offsets
 mov x10,#0
.Lspec_null_views:
 ldr w11,[x9,x10,lsl#2]
 str xzr,[x19,w11,uxtw]
 add x10,x10,#1
 cmp x10,#19
 b.lo .Lspec_null_views
 adr x22,.Lspec_release_offsets
 mov x23,#0
.Lspec_release_owner:
 ldr w9,[x22,x23,lsl#2]
 ldr x0,[x19,w9,uxtw]
 cbz x0,.Lspec_release_next
 bl free
 ldr w9,[x22,x23,lsl#2]
 str xzr,[x19,w9,uxtw]
.Lspec_release_next:
 add x23,x23,#1
 cmp x23,#19
 b.lo .Lspec_release_owner
 str w21,[x20]
 ldr x9,[sp,#64]
 msr fpcr,x9
 ldr x9,[sp,#72]
 msr fpsr,x9
 mov w0,#0
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x18,[sp,#48]
 ldp x29,x30,[sp]
 add sp,sp,#96
 ret
.Lspec_release_reject:
 mov w0,#2
 ret
.size md2asm_release_serial_spectral_field,.-md2asm_release_serial_spectral_field
.section .rodata
.p2align 3
.Lspec_ids: .word 138,155,130,152,129
.Lspec_owners:
 .word 1200,1,4,1,1,0,0,0 /* MYMS */
 .word 792,1,4,1,1,0,0,0 /* NALLMS */
 .word 1136,1,4,0,1,0,0,0 /* NPTRMS */
 .word 944,1,4,0,1,0,0,0 /* NUMLL */
 .word 1008,1,4,0,1,0,0,0 /* NPTRLL */
 .word 1072,1,4,0,1,0,0,0 /* NPSURF */
 .word 1264,1,4,2,1,0,0,0 /* MYLEVS */
 .word 408,1,4,1,0,0,0,0 /* NASM0 */
 .word 472,1,4,1,0,0,0,0 /* NASM0G */
 .word 728,1,4,0,1,0,0,0 /* NUMPP */
 .word 856,2,4,1,1,0,0,0 /* MS_PROC */
 .word 344,1,4,0,1,0,0,0 /* NS2L */
 .word 1328,1,4,3,1,0,0,0 /* NGRIB */
 .word 88,3,8,2,1,4,5,0 /* SP3D */
 .word 0,2,8,4,1,6,0,0 /* SP2D */
 .word 200,2,8,0,1,6,0,0 /* SP1D */
.Lspec_views:
 .word 1520,2,0,0,2,4,0,0 /* VOR */
 .word 1608,2,0,1,2,4,0,0 /* DIV */
 .word 1696,2,0,2,2,4,0,0 /* T */
 .word 1784,2,3,0,0,0,0,0 /* Q */
 .word 1872,2,3,0,0,0,0,0 /* O3 */
 .word 1960,2,3,0,0,0,0,0 /* L */
 .word 2136,2,3,0,0,0,0,0 /* SPD */
 .word 2224,2,3,0,0,0,0,0 /* SVD */
 .word 2312,2,3,0,0,0,0,0 /* NHX */
 .word 2400,1,1,0,4,0,0,0 /* SP */
 .word 2464,1,1,1,4,0,0,0 /* OROG */
 .word 2528,3,0,2,2,4,0,0 /* SCAL */
 .word 2640,3,4,0,0,0,0,0 /* GFL */
 .word 2752,3,0,2,2,4,0,0 /* HV */
 .word 2864,1,2,0,0,0,0,0 /* UB */
 .word 2928,1,2,1,0,0,0,0 /* VB */
.Lspec_pointer_offsets:
 .word 1392,1456,1520,1608,1696,1784,1872,1960,2048,2136,2224,2312,2400,2464,2528,2640,2752,2864,2928
.Lspec_release_offsets:
 .word 0,88,200,408,472,536,600,664,728,856,944,1008,1072,344,1328,1200,1264,792,1136
.section .note.GNU-stack,"",%progbits
