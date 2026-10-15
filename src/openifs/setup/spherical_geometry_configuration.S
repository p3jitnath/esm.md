/* Selected source-ordered SUGEM_NAML owner construction.
 * Contract skills/md2asm/references/openifs/setup/spherical_geometry_configuration.md. x0 Geometry, x1 three int32
 * frame words, x2 three FP64 frame values. No namelist solver fallback.
 * w0=0 success,1 cleaned allocation failure,2 unchanged unsupported input.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_spherical_geometry
.type md2asm_initialize_spherical_geometry,%function
md2asm_initialize_spherical_geometry:
 cbz x0,.Lsg_reject
 cbz x1,.Lsg_reject
 cbz x2,.Lsg_reject
 orr x9,x0,x2
 tst x9,#7
 b.ne .Lsg_reject
 tst x1,#3
 b.ne .Lsg_reject
 ldr w9,[x1]
 cmp w9,#1
 b.hi .Lsg_reject
 ldr w10,[x1,#4]
 cmp w10,#1
 b.ne .Lsg_reject
 ldr w10,[x1,#8]
 cbnz w10,.Lsg_reject
 cbz w9,.Lsg_stretch_supported
 ldr x9,[x2,#16]
 mov x10,#0x3ff0000000000000
 cmp x9,x10
 b.ne .Lsg_reject
.Lsg_stretch_supported:
 ldr x9,[x0]
 cbz x9,.Lsg_reject
 tst x9,#3
 b.ne .Lsg_reject
 mov x9,#7576
 ldr x10,[x0,x9]
 cbnz x10,.Lsg_reject
 mov x9,#7640
 ldr x10,[x0,x9]
 cbnz x10,.Lsg_reject
 mov x9,#4872
 ldr w10,[x0,x9]
 cmp w10,#1
 b.lt .Lsg_reject
 cmp w10,#256,lsl#12
 b.gt .Lsg_reject
 mov x9,#4884
 ldr w11,[x0,x9]
 cmp w11,#48
 b.hi .Lsg_reject
 mov x9,#4888
 ldr w12,[x0,x9]
 mov w13,#1
 sub w13,w13,w11
 cmp w12,w13
 b.ne .Lsg_reject
 mov x9,#4904
 ldr w12,[x0,x9]
 add w13,w10,w11
 cmp w12,w13
 b.ne .Lsg_reject
 mov x9,#4936
 ldr w10,[x0,x9]
 cmp w10,#1
 b.lt .Lsg_reject
 cmp w10,#256,lsl#12
 b.gt .Lsg_reject
 mov x9,#5172
 ldr w10,[x0,x9]
 cmp w10,#1
 b.lt .Lsg_reject
 mov w11,#8191
 cmp w10,w11
 b.gt .Lsg_reject
 mov x9,#5208
 ldr w11,[x0,x9]
 cmp w10,w11
 b.ne .Lsg_reject
 mrs x9,fpcr
 cbnz x9,.Lsg_reject
 sub sp,sp,#128
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 str x18,[sp,#80]
 str x9,[sp,#88]
 mrs x9,fpsr
 str x9,[sp,#96]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 bl __errno_location
 mov x24,x0
 ldr w9,[x24]
 str w9,[sp,#104]
 mov x9,#4904
 ldrsw x10,[x19,x9]
 mov x9,#4888
 ldrsw x11,[x19,x9]
 sub x22,x10,x11
 add x22,x22,#1
 mov x25,#0
 mov x26,#7576
.Lsg_allocate:
 lsl x0,x22,#2
 bl malloc
 cbz x0,.Lsg_allocation_failed
 add x23,x19,x26
 str x0,[x23]
 mov x9,#4888
 ldrsw x10,[x19,x9]
 neg x11,x10
 str x11,[x23,#8]
 mov x11,#4
 str x11,[x23,#16]
 str xzr,[x23,#24]
 mov w12,#0x101
 str w12,[x23,#28]
 str x11,[x23,#32]
 mov x11,#1
 str x11,[x23,#40]
 str x10,[x23,#48]
 mov x9,#4904
 ldrsw x10,[x19,x9]
 str x10,[x23,#56]
 add x25,x25,#1
 add x26,x26,#64
 cmp x25,#2
 b.lo .Lsg_allocate
 /* The borrowed logical flag is not an owned pointer slot. */
 ldr x9,[x19]
 str wzr,[x9]
 ldr x9,[sp,#96]
 msr fpsr,x9
 ldr x18,[sp,#80]
 /* Source's initial rounding route remains observable through FPSR. */
 ldr w9,[x20]
 cbz w9,.Lsg_final_controls
 mov x9,#4936
 ldr w10,[x19,x9]
 mov x9,#5172
 ldr w11,[x19,x9]
 sub w10,w10,#1
 sub w10,w10,w11,lsl#1
 scvtf d0,w10
 scvtf d1,w11
 fdiv d0,d0,d1
 fmov d1,#10.0
 fmul d0,d0,d1
 frinta d0,d0
 fcvtzs w10,d0
 scvtf d0,w10
 fdiv d0,d0,d1
.Lsg_final_controls:
 fmov d0,#1.0
 mov x9,#7496
 str d0,[x19,x9]
 mov x9,#7504
 str xzr,[x19,x9]
 mov x9,#7512
 str d0,[x19,x9]
 mov x9,#7520
 mov w10,#1
 str w10,[x19,x9]
 mov x9,#7524
 str wzr,[x19,x9]
 mov x9,#4936
 ldr w10,[x19,x9]
 add w11,w10,#3
 mov w12,#3
 sdiv w11,w11,w12
 mov x9,#5172
 ldr w12,[x19,x9]
 cmp w12,w11
 b.le .Lsg_final_increment
 fmov d0,xzr
.Lsg_final_increment:
 mov x9,#7528
 str d0,[x19,x9]
 /* Complete NLOENG, preserving every incoming NLOEN payload byte. */
 mov x9,#7640
 ldr x9,[x19,x9]
 mov x11,#0
.Lsg_rows:
 str w10,[x9,x11,lsl#2]
 add x11,x11,#1
 cmp x11,x22
 b.lo .Lsg_rows
 mov w0,#0
 b .Lsg_return
.Lsg_allocation_failed:
 mov x0,x19
 bl md2asm_release_spherical_geometry
 mov w0,#1
.Lsg_return:
 ldr w9,[sp,#104]
 str w9,[x24]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldr x18,[sp,#80]
 ldp x29,x30,[sp]
 add sp,sp,#128
 ret
.Lsg_reject:
 mov w0,#2
 ret
.size md2asm_initialize_spherical_geometry,.-md2asm_initialize_spherical_geometry
.p2align 4
.global md2asm_release_spherical_geometry
.type md2asm_release_spherical_geometry,%function
md2asm_release_spherical_geometry:
 sub sp,sp,#48
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x18,[sp,#32]
 mov x29,sp
 mov x19,x0
 mov x20,#7576
 mov x21,#0
.Lsg_release:
 ldr x0,[x19,x20]
 cbz x0,.Lsg_release_next
 bl free
 str xzr,[x19,x20]
.Lsg_release_next:
 add x20,x20,#64
 add x21,x21,#1
 cmp x21,#2
 b.lo .Lsg_release
 ldp x19,x20,[sp,#16]
 ldp x21,x18,[sp,#32]
 ldp x29,x30,[sp]
 add sp,sp,#48
 ret
.size md2asm_release_spherical_geometry,.-md2asm_release_spherical_geometry
.section .note.GNU-stack,"",%progbits
