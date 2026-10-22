/* Complete selected SULEGA for 2,560 physical rows and two halo rows.
 * x0: writable 640-byte latitude record; x1: read-only 352-byte dimensions.
 * x2: read-only FP64 radius and pi (16 bytes).
 * w0: 0 success, 1 allocation failure, 2 refused input.
 * Contract: skills/md2asm/references/openifs/setup/operational_latitude_geometry.md.
 * Public TRANS_INQ and scalar asin supply the declared mathematical services.
 * The record receives nine owners. Private arrays follow source lifetime order.
 * Frame: 608 bytes. Preserve x18, saved integers and low 64 bits of d8-d11.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_operational_latitude_geometry
.type md2asm_initialize_operational_latitude_geometry,%function
md2asm_initialize_operational_latitude_geometry:
 mrs x9,fpcr
 cbnz x9,.Lolg_invalid
 cbz x0,.Lolg_invalid
 cbz x1,.Lolg_invalid
 cbz x2,.Lolg_invalid
 orr x9,x0,x1
 orr x9,x9,x2
 tst x9,#7
 b.ne .Lolg_invalid
 adds x9,x0,#640
 b.cs .Lolg_invalid
 adds x9,x1,#352
 b.cs .Lolg_invalid
 adds x9,x2,#16
 b.cs .Lolg_invalid
 ldr w9,[x1]
 cmp w9,#2560
 b.ne .Lolg_invalid
 ldr w9,[x1,#12]
 cmp w9,#2
 b.ne .Lolg_invalid
 ldr w9,[x1,#16]
 cmn w9,#1
 b.ne .Lolg_invalid
 ldr w9,[x1,#32]
 cmp w9,#2562
 b.ne .Lolg_invalid
 ldr w9,[x1,#296]
 cmp w9,#1
 b.lt .Lolg_invalid
 adrp x9,.Lolg_constants
 add x9,x9,:lo12:.Lolg_constants
 ldp x10,x11,[x2]
 ldp x12,x13,[x9]
 cmp x10,x12
 b.ne .Lolg_invalid
 cmp x11,x13
 b.ne .Lolg_invalid
 mov x9,x0
 mov w10,#9
.Lolg_fresh:
 ldr x11,[x9],#64
 cbnz x11,.Lolg_invalid
 subs w10,w10,#1
 b.ne .Lolg_fresh
 sub sp,sp,#608
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 stp d8,d9,[sp,#112]
 stp d10,d11,[sp,#128]
 stp xzr,xzr,[sp,#144]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 ldp d8,d11,[x21]
 bl __errno_location
 mov x27,x0
 ldr w28,[x27]
 mov x22,#0
.Lolg_allocate:
 mov x0,#20480
 cmp x22,#3
 b.lo .Lolg_allocate_call
 mov x0,#20512
.Lolg_allocate_call:
 bl malloc
 cbz x0,.Lolg_failed
 cmp x22,#1
 b.eq .Lolg_ZMU
 cmp x22,#2
 b.eq .Lolg_ZPHI
 mov x9,#0
 cbz x22,.Lolg_owner_index
 sub x9,x22,#2
.Lolg_owner_index:
 add x23,x19,x9,lsl#6
 str x0,[x23]
 mov x10,#-1
 mov x11,#1
 mov x12,#2560
 cbz x22,.Lolg_descriptor
 mov x10,#1
 mov x11,#-1
 mov x12,#2562
.Lolg_descriptor:
 str x10,[x23,#8]
 mov x10,#8
 str x10,[x23,#16]
 str x10,[x23,#32]
 mov x10,#0x301
 lsl x10,x10,#32
 str x10,[x23,#24]
 mov x10,#1
 stp x10,x11,[x23,#40]
 str x12,[x23,#56]
 b .Lolg_next_allocation
.Lolg_ZMU:
 str x0,[sp,#144]
 b .Lolg_next_allocation
.Lolg_ZPHI:
 str x0,[sp,#152]
.Lolg_next_allocation:
 add x22,x22,#1
 cmp x22,#11
 b.lo .Lolg_allocate
 ldp x25,x26,[sp,#144]
 add x0,sp,#160
 mov x9,#0
.Lolg_zero_arguments:
 str xzr,[x0,x9,lsl#3]
 add x9,x9,#1
 cmp x9,#47
 b.lo .Lolg_zero_arguments
 add x9,x20,#296
 str x9,[sp,#160]
 add x9,sp,#536
 str x25,[x9]
 mov x10,#-1
 str x10,[x9,#8]
 mov x10,#8
 str x10,[x9,#16]
 str x10,[x9,#32]
 mov x10,#0x301
 lsl x10,x10,#32
 str x10,[x9,#24]
 mov x10,#1
 stp x10,x10,[x9,#40]
 mov x10,#2560
 str x10,[x9,#56]
 str x9,[sp,#480]
 str x19,[sp,#488]
 bl md2asm_call_public_transform_inquiry
 mov x24,#0
 ldr x23,[x19,#64]
.Lolg_copy_mu:
 ldr x9,[x25,x24,lsl#3]
 add x10,x24,#2
 str x9,[x23,x10,lsl#3]
 add x24,x24,#1
 cmp x24,#2560
 b.lo .Lolg_copy_mu
 mov x24,#0
.Lolg_physical_rows:
 ldr d0,[x25,x24,lsl#3]
 fmul d1,d0,d0
 fmov d2,#1.0
 fsub d9,d2,d1
 bl asin
 str d0,[x26,x24,lsl#3]
 add x23,x24,#2
 lsl x23,x23,#3
 ldr x9,[x19,#128]
 str d9,[x9,x23]
 fmov d2,#1.0
 fdiv d0,d2,d9
 ldr x9,[x19,#192]
 str d0,[x9,x23]
 fsqrt d10,d9
 fdiv d1,d2,d10
 fmul d0,d8,d9
 fdiv d0,d2,d0
 ldr x9,[x19,#256]
 str d0,[x9,x23]
 ldr x9,[x19,#320]
 str d10,[x9,x23]
 ldr x9,[x19,#384]
 str d1,[x9,x23]
 fmul d0,d8,d10
 fdiv d0,d2,d0
 ldr x9,[x19,#448]
 str d0,[x9,x23]
 ldr d0,[x26,x24,lsl#3]
 ldr x9,[x19,#512]
 str d0,[x9,x23]
 add x24,x24,#1
 cmp x24,#2560
 b.lo .Lolg_physical_rows
 mov x0,x25
 bl free
 str xzr,[sp,#144]
 mov x24,#1
.Lolg_north_rows:
 add x10,x24,#1
 lsl x10,x10,#3
 mov x11,#2
 sub x11,x11,x24
 lsl x11,x11,#3
 mov x22,#64
.Lolg_north_arrays:
 ldr x9,[x19,x22]
 ldr x12,[x9,x10]
 str x12,[x9,x11]
 add x22,x22,#64
 cmp x22,#512
 b.lo .Lolg_north_arrays
 sub x9,x24,#1
 ldr d0,[x26,x9,lsl#3]
 fsub d0,d11,d0
 ldr x9,[x19,#512]
 str d0,[x9,x11]
 add x24,x24,#1
 cmp x24,#2
 b.ls .Lolg_north_rows
 mov x24,#1
.Lolg_south_rows:
 mov x10,#2562
 sub x10,x10,x24
 lsl x10,x10,#3
 add x11,x24,#2561
 lsl x11,x11,#3
 mov x22,#64
.Lolg_south_arrays:
 ldr x9,[x19,x22]
 ldr x12,[x9,x10]
 str x12,[x9,x11]
 add x22,x22,#64
 cmp x22,#512
 b.lo .Lolg_south_arrays
 mov x9,#2560
 sub x9,x9,x24
 ldr d0,[x26,x9,lsl#3]
 fneg d1,d11
 fsub d0,d1,d0
 ldr x9,[x19,#512]
 str d0,[x9,x11]
 add x24,x24,#1
 cmp x24,#2
 b.ls .Lolg_south_rows
 mov x0,x26
 bl free
 str xzr,[sp,#152]
 mov w0,#0
 b .Lolg_return
.Lolg_failed:
 mov x22,#0
.Lolg_failed_owners:
 add x23,x19,x22,lsl#6
 ldr x0,[x23]
 cbz x0,.Lolg_failed_next
 bl free
 str xzr,[x23]
.Lolg_failed_next:
 add x22,x22,#1
 cmp x22,#9
 b.lo .Lolg_failed_owners
 ldr x0,[sp,#144]
 cbz x0,.Lolg_failed_ZPHI
 bl free
.Lolg_failed_ZPHI:
 ldr x0,[sp,#152]
 cbz x0,.Lolg_failed_status
 bl free
.Lolg_failed_status:
 str w28,[x27]
 mov w0,#1
.Lolg_return:
 ldp d8,d9,[sp,#112]
 ldp d10,d11,[sp,#128]
 ldr x18,[sp,#96]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp]
 add sp,sp,#608
 ret
.Lolg_invalid:
 mov w0,#2
 ret
.size md2asm_initialize_operational_latitude_geometry,.-md2asm_initialize_operational_latitude_geometry
.p2align 4
.global md2asm_release_operational_latitude_geometry
.type md2asm_release_operational_latitude_geometry,%function
md2asm_release_operational_latitude_geometry:
 cbz x0,.Lolg_release_invalid
 tst x0,#7
 b.ne .Lolg_release_invalid
 sub sp,sp,#96
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x18,[sp,#48]
 mov x19,x0
 mrs x9,fpcr
 mrs x10,fpsr
 stp x9,x10,[sp,#64]
 bl __errno_location
 mov x20,x0
 ldr w21,[x20]
 mov x22,#0
.Lolg_release_loop:
 add x23,x19,x22,lsl#6
 ldr x0,[x23]
 cbz x0,.Lolg_release_next
 bl free
 str xzr,[x23]
.Lolg_release_next:
 add x22,x22,#1
 cmp x22,#9
 b.lo .Lolg_release_loop
 str w21,[x20]
 ldp x9,x10,[sp,#64]
 msr fpcr,x9
 msr fpsr,x10
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x18,[sp,#48]
 ldp x29,x30,[sp]
 add sp,sp,#96
 mov w0,#0
 ret
.Lolg_release_invalid:
 mov w0,#2
 ret
.size md2asm_release_operational_latitude_geometry,.-md2asm_release_operational_latitude_geometry
.section .rodata
.balign 8
.Lolg_constants:
 .quad 0x41584de740000000
 .quad 0x400921fb54442d18
.section .note.GNU-stack,"",%progbits
