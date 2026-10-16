/* Contract: skills/md2asm/references/openifs/setup/partition_array_storage.md.
 * Allocate:x0 owned Geometry[17096],x1 serial int32 settings[5],x2 phase0..2.
 * Release:x0 Geometry,x1 phase. Status w0=0,1 allocation,2 input.
 * Phase0/1/2 owns26/2/6 arrays. Failure clears phase pointers; bounds may remain.
 * Payloads are source-unwritten. Setup272B/release112B frames,16B aligned.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_allocate_serial_partition_arrays
.type md2asm_allocate_serial_partition_arrays,%function
md2asm_allocate_serial_partition_arrays:
 cbz x0,.Lpart_reject
 cbz x1,.Lpart_reject
 tst x0,#7
 b.ne .Lpart_reject
 tst x1,#3
 b.ne .Lpart_reject
 cmp x2,#2
 b.hi .Lpart_reject
 mov x9,#0
.Lpart_settings:
 ldr w10,[x1,x9,lsl#2]
 cmp w10,#1
 b.ne .Lpart_reject
 add x9,x9,#1
 cmp x9,#5
 b.lo .Lpart_settings
 sub sp,sp,#272
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mrs x9,fpcr
 mrs x10,fpsr
 stp x9,x10,[sp,#104]
 mov x29,sp
 mov x19,x0
 mov x20,x2
 add x21,sp,#128
 stp xzr,xzr,[x21]
 stp xzr,xzr,[x21,#16]
 stp xzr,xzr,[x21,#32]
 stp xzr,xzr,[x21,#48]
 stp xzr,xzr,[x21,#64]
 stp xzr,xzr,[x21,#80]
 stp xzr,xzr,[x21,#96]
 stp xzr,xzr,[x21,#112]
 mov x9,#1
 mov x10,#2
 stp x9,x10,[x21]
 cmp x20,#1
 b.eq .Lpart_block_inputs
 cmp x20,#2
 b.eq .Lpart_local_inputs
 ldr w9,[x19,#5208]
 cmp w9,#21
 b.hi .Lpart_saved_reject
 add x9,x9,#1
 str x9,[x21,#16]
 ldr w9,[x19,#5172]
 ldr w10,[x19,#5176]
 cmp w9,#21
 b.hi .Lpart_saved_reject
 cmp w10,#21
 b.hi .Lpart_saved_reject
 cmp w9,w10
 csel w9,w9,w10,hs
 add x9,x9,#1
 str x9,[x21,#24]
 ldrsw x9,[x19,#4888]
 add x10,x9,#1
 cmp x10,#2
 b.hi .Lpart_saved_reject
 str x9,[x21,#32]
 ldrsw x10,[x19,#4904]
 mov x11,#33
 sub x11,x11,x9
 cmp x10,x11
 b.ne .Lpart_saved_reject
 sub x10,x10,x9
 add x10,x10,#1
 str x10,[x21,#40]
 ldr w9,[x19,#4872]
 cmp w9,#32
 b.ne .Lpart_saved_reject
 str x9,[x21,#48]
 ldr w9,[x19,#5224]
 cmp w9,#19
 b.hi .Lpart_saved_reject
 str x9,[x21,#56]
 b .Lpart_inputs_done
.Lpart_block_inputs:
 ldr w9,[x19,#5144]
 sub w10,w9,#1
 cmp w10,#23
 b.hi .Lpart_saved_reject
 ldr w10,[x19,#5160]
 cmp w10,#86
 b.hi .Lpart_saved_reject
 stp x9,x10,[x21,#64]
 b .Lpart_inputs_done
.Lpart_local_inputs:
 ldr w9,[x19,#5228]
 cmp w9,#19
 b.hi .Lpart_saved_reject
 str x9,[x21,#80]
 ldr w9,[x19,#4892]
 sub w10,w9,#1
 cmp w10,#31
 b.hi .Lpart_saved_reject
 str x9,[x21,#88]
 ldr w10,[x19,#4908]
 cmp w10,#32
 b.hi .Lpart_saved_reject
 add w11,w10,#1
 cmp w11,w9
 b.lo .Lpart_saved_reject
 sub x10,x10,x9
 add x10,x10,#1
 str x10,[x21,#96]
 ldr w9,[x19,#7376]
 ldr w10,[x19,#7388]
 cmp w9,#2048
 b.hi .Lpart_saved_reject
 sub w11,w10,#1
 cmp w11,#2047
 b.hi .Lpart_saved_reject
 cmp w9,w10
 b.hi .Lpart_saved_reject
 stp x9,x10,[x21,#104]
.Lpart_inputs_done:
 bl .Lpart_select_table
 mov x24,#0
.Lpart_fresh_check:
 add x16,x22,x24,lsl#4
 ldr w9,[x16]
 ldr x10,[x19,x9]
 cbnz x10,.Lpart_saved_reject
 add x24,x24,#1
 cmp x24,x23
 b.lo .Lpart_fresh_check
 bl __errno_location
 mov x26,x0
 ldr w27,[x26]
 mov x24,#0
.Lpart_allocate:
 add x16,x22,x24,lsl#4
 ldr w9,[x16]
 add x25,x19,x9
 ldrb w9,[x16,#7]
 ldr x10,[x21,x9,lsl#3]
 ldrb w9,[x16,#8]
 ldr x11,[x21,x9,lsl#3]
 mul x0,x10,x11
 lsl x0,x0,#2
 cmp x0,#1
 csinc x0,x0,xzr,hs
 bl malloc
 cbz x0,.Lpart_allocation_failed
 str x0,[x25]
 add x16,x22,x24,lsl#4
 ldrb w9,[x16,#6]
 ldr x11,[x21,x9,lsl#3]
 ldrb w9,[x16,#7]
 ldr x10,[x21,x9,lsl#3]
 ldrb w9,[x16,#8]
 ldr x12,[x21,x9,lsl#3]
 ldrb w13,[x16,#4]
 neg x9,x11
 cmp w13,#2
 sub x14,x9,x10
 csel x9,x14,x9,eq
 str x9,[x25,#8]
 mov x9,#4
 str x9,[x25,#16]
 str x9,[x25,#32]
 ldrb w14,[x16,#5]
 orr w14,w13,w14,lsl#8
 lsl x14,x14,#32
 str x14,[x25,#24]
 mov x9,#1
 stp x9,x11,[x25,#40]
 add x11,x11,x10
 sub x11,x11,#1
 str x11,[x25,#56]
 cmp w13,#2
 b.ne .Lpart_descriptor_done
 stp x10,x9,[x25,#64]
 str x12,[x25,#80]
.Lpart_descriptor_done:
 add x24,x24,#1
 cmp x24,x23
 b.lo .Lpart_allocate
 mov w0,#0
 b .Lpart_with_errno_return
.Lpart_allocation_failed:
 mov x24,#0
.Lpart_failure_cleanup:
 add x16,x22,x24,lsl#4
 ldr w9,[x16]
 add x25,x19,x9
 ldr x0,[x25]
 cbz x0,.Lpart_failure_next
 bl free
 str xzr,[x25]
.Lpart_failure_next:
 add x24,x24,#1
 cmp x24,x23
 b.lo .Lpart_failure_cleanup
 mov w0,#1
.Lpart_with_errno_return:
 str w27,[x26]
 b .Lpart_return
.Lpart_saved_reject:
 mov w0,#2
.Lpart_return:
 ldp x9,x10,[sp,#104]
 msr fpcr,x9
 msr fpsr,x10
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldr x18,[sp,#96]
 ldp x29,x30,[sp]
 add sp,sp,#272
 ret
.Lpart_reject:
 mov w0,#2
 ret
/* Private leaf uses x20 phase and returns immutable table x22,count x23. */
.Lpart_select_table:
 adrp x22,.Lpart_phase0
 add x22,x22,:lo12:.Lpart_phase0
 mov x23,#26
 cbz x20,.Lpart_table_return
 adrp x22,.Lpart_phase1
 add x22,x22,:lo12:.Lpart_phase1
 mov x23,#2
 cmp x20,#1
 b.eq .Lpart_table_return
 adrp x22,.Lpart_phase2
 add x22,x22,:lo12:.Lpart_phase2
 mov x23,#6
.Lpart_table_return:
 ret
.size md2asm_allocate_serial_partition_arrays,.-md2asm_allocate_serial_partition_arrays
.p2align 4
.global md2asm_release_serial_partition_arrays
.type md2asm_release_serial_partition_arrays,%function
md2asm_release_serial_partition_arrays:
 cbz x0,.Lpart_release_reject
 tst x0,#7
 b.ne .Lpart_release_reject
 cmp x1,#2
 b.hi .Lpart_release_reject
 sub sp,sp,#112
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x18,[sp,#80]
 mrs x9,fpcr
 mrs x10,fpsr
 stp x9,x10,[sp,#96]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 bl .Lpart_select_table
 bl __errno_location
 mov x26,x0
 ldr w27,[x26]
 mov x24,#0
.Lpart_release_loop:
 add x16,x22,x24,lsl#4
 ldr w9,[x16]
 add x25,x19,x9
 ldr x0,[x25]
 cbz x0,.Lpart_release_next
 bl free
 str xzr,[x25]
.Lpart_release_next:
 add x24,x24,#1
 cmp x24,x23
 b.lo .Lpart_release_loop
 str w27,[x26]
 ldp x9,x10,[sp,#96]
 msr fpcr,x9
 msr fpsr,x10
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x18,[sp,#80]
 ldp x29,x30,[sp]
 add sp,sp,#112
 mov w0,#0
 ret
.Lpart_release_reject:
 mov w0,#2
 ret
.size md2asm_release_serial_partition_arrays,.-md2asm_release_serial_partition_arrays
.section .rodata
.p2align 4
/* Rows:physical offset,rank,type,lower/count/second-count parameter indices. */
.Lpart_phase0:
 .word 5832 /* YRMP%NUMLL */
 .byte 1,1,0,1,0
 .zero 7
 .word 6024 /* YRMP%NPSURF */
 .byte 1,1,0,0,0
 .zero 7
 .word 5256 /* YRMP%NUMPP */
 .byte 1,1,0,0,0
 .zero 7
 .word 5320 /* YRMP%NPROCM */
 .byte 1,1,15,2,0
 .zero 7
 .word 5384 /* YRMP%NPTRMS */
 .byte 1,1,0,0,0
 .zero 7
 .word 7248 /* YRMP%NPOSSP */
 .byte 1,1,0,1,0
 .zero 7
 .word 5448 /* YRMP%NALLMS */
 .byte 1,1,0,3,0
 .zero 7
 .word 7312 /* YRMP%NDIM0G */
 .byte 1,1,15,3,0
 .zero 7
 .word 5512 /* YRMP%NPTRLS */
 .byte 1,1,0,0,0
 .zero 7
 .word 5576 /* YRMP%NPTRSV */
 .byte 1,1,0,1,0
 .zero 7
 .word 5640 /* YRMP%NPTRSVF */
 .byte 1,1,0,1,0
 .zero 7
 .word 5704 /* YRMP%NPTRMF */
 .byte 1,1,0,1,0
 .zero 7
 .word 5768 /* YRMP%NSPSTAF */
 .byte 1,1,15,3,0
 .zero 7
 .word 5896 /* YRMP%NPTRLL */
 .byte 1,1,0,1,0
 .zero 7
 .word 6088 /* YRMP%NSTA */
 .byte 2,1,4,5,0
 .zero 7
 .word 6176 /* YRMP%NONL */
 .byte 2,1,4,5,0
 .zero 7
 .word 6264 /* YRMP%NPTRFRSTLAT */
 .byte 1,1,0,0,0
 .zero 7
 .word 6328 /* YRMP%NPTRLSTLAT */
 .byte 1,1,0,0,0
 .zero 7
 .word 6392 /* YRMP%NPTRLAT */
 .byte 1,1,0,6,0
 .zero 7
 .word 7080 /* YRMP%LSPLITLAT */
 .byte 1,2,0,6,0
 .zero 7
 .word 6456 /* YRMP%NFRSTLAT */
 .byte 1,1,0,0,0
 .zero 7
 .word 6520 /* YRMP%NLSTLAT */
 .byte 1,1,0,0,0
 .zero 7
 .word 6584 /* YRMP%NBSETLEV */
 .byte 1,1,0,7,0
 .zero 7
 .word 4968 /* YRDIM%NDLUNL */
 .byte 2,1,4,5,0
 .zero 7
 .word 5056 /* YRDIM%NDLUXL */
 .byte 2,1,4,5,0
 .zero 7
 .word 7392 /* YRGEM%NGPTOTL */
 .byte 2,1,0,0,0
 .zero 7
.Lpart_phase1:
 .word 6992 /* YRMP%NLONGPP */
 .byte 2,1,0,8,9
 .zero 7
 .word 6904 /* YRMP%NLATGPP */
 .byte 2,1,0,8,9
 .zero 7
.Lpart_phase2:
 .word 5960 /* YRMP%MYLEVS */
 .byte 1,1,0,10,0
 .zero 7
 .word 7144 /* YRMP%MYLATS */
 .byte 1,1,11,12,0
 .zero 7
 .word 6648 /* YRMP%NGLOBALINDEX */
 .byte 1,1,0,13,0
 .zero 7
 .word 6712 /* YRMP%NGLOBALAT */
 .byte 1,1,0,13,0
 .zero 7
 .word 6776 /* YRMP%NGLOBALPROC */
 .byte 1,1,0,14,0
 .zero 7
 .word 6840 /* YRMP%NLOCALINDEX */
 .byte 1,1,0,14,0
 .zero 7
.section .note.GNU-stack,"",%progbits
