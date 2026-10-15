// Solver contract skills/md2asm/references/openifs/output/output_request_views.md.
/* Read-only selected FULLPOS request and view children.
 * Inputs are genuine GNU12 typed owners; descriptors and arrays stay unchanged.
 * Only output tables and three integer route counters are written.
 * No floating-point instruction, allocation, original call or numerical stage.
 */
.text
.p2align 4
.macro CONST reg,value
 movz \reg,#((\value)&65535)
 movk \reg,#(((\value)>>16)&65535),lsl #16
.endm
.macro COUNT offset
 adrp x16,md2asm_output_metadata_native_counters
 add x16,x16,:lo12:md2asm_output_metadata_native_counters
 ldr x17,[x16,#\offset]
 add x17,x17,#1
 str x17,[x16,#\offset]
.endm
/* GNU origin: base + element_bytes*(offset + sum(index*stride)). */
.macro ADDRESS1 result,owner,offset,index,shift
 ldr \result,[\owner,#\offset]
 ldr x11,[\owner,#(\offset+8)]
 ldr x12,[\owner,#(\offset+40)]
 madd x11,\index,x12,x11
 add \result,\result,x11,lsl #\shift
.endm
.macro ADDRESS2 result,owner,offset,a,b,shift
 ldr \result,[\owner,#\offset]
 ldr x11,[\owner,#(\offset+8)]
 ldr x12,[\owner,#(\offset+40)]
 madd x11,\a,x12,x11
 ldr x12,[\owner,#(\offset+64)]
 madd x11,\b,x12,x11
 add \result,\result,x11,lsl #\shift
.endm
.macro ADDRESS3 result,owner,offset,a,b,c
 ldr \result,[\owner,#\offset]
 ldr x11,[\owner,#(\offset+8)]
 ldr x12,[\owner,#(\offset+40)]
 madd x11,\a,x12,x11
 ldr x12,[\owner,#(\offset+64)]
 madd x11,\b,x12,x11
 ldr x12,[\owner,#(\offset+88)]
 madd x11,\c,x12,x11
 add \result,\result,x11,lsl #3
.endm
.macro ADDRESS4 result,owner,offset,a,b,c,d
 ldr \result,[\owner,#\offset]
 ldr x11,[\owner,#(\offset+8)]
 ldr x12,[\owner,#(\offset+40)]
 madd x11,\a,x12,x11
 ldr x12,[\owner,#(\offset+64)]
 madd x11,\b,x12,x11
 ldr x12,[\owner,#(\offset+88)]
 madd x11,\c,x12,x11
 ldr x12,[\owner,#(\offset+112)]
 madd x11,\d,x12,x11
 add \result,\result,x11,lsl #3
.endm
/* x0=Q, x1=CODE(i32*), x2=P(5*i64), all address arguments. */
.global md2asm_output_field_map_direct
.type md2asm_output_field_map_direct,%function
md2asm_output_field_map_direct:
 COUNT 0
 stp xzr,xzr,[x2]
 stp xzr,xzr,[x2,#16]
 str xzr,[x2,#32]
 ldrsw x3,[x1]
 ADDRESS1 x6,x0,72,x3,2
 ldr w6,[x6]
 cbz w6,.Lfield_return
 cmp x3,#5
 b.eq .Lfield_selected
 cmp x3,#6
 b.eq .Lfield_selected
 cmp x3,#454
 b.ne .Lstop109
.Lfield_selected:
 ADDRESS1 x6,x0,136,x3,2
 ldrsw x7,[x6]
 cmp x7,#1
 b.gt .Lstop109
 ADDRESS1 x6,x0,328,x3,2
 ldrsw x8,[x6]
 stp x8,x7,[x2]
 mov x4,#1
 cmp x7,#0
 b.le .Lfield_grid
 ADDRESS2 x6,x0,744,x3,x4,2
 ldrsw x8,[x6]
 ldrsw x9,[x0,#1096]
 b .Lfield_pointer
.Lfield_grid:
 ADDRESS1 x6,x0,680,x3,2
 ldrsw x8,[x6]
 ldrsw x9,[x0,#1100]
.Lfield_pointer:
 ADDRESS2 x6,x0,392,x4,x3,2
 stp x8,x6,[x2,#16]
 str x9,[x2,#32]
.Lfield_return:
 ret
.size md2asm_output_field_map_direct,.-md2asm_output_field_map_direct
.global md2asm_output_field_map_
.set md2asm_output_field_map_,md2asm_output_field_map_direct
/* x0=Geometry,x1=GMV,x2=GFL,x3=Model,x4=B(i32*),x5=P(24*i64). */
.p2align 4
.global md2asm_output_block_views_direct
.type md2asm_output_block_views_direct,%function
md2asm_output_block_views_direct:
 COUNT 8
 stp xzr,xzr,[x5,#0]
 stp xzr,xzr,[x5,#16]
 stp xzr,xzr,[x5,#32]
 stp xzr,xzr,[x5,#48]
 stp xzr,xzr,[x5,#64]
 stp xzr,xzr,[x5,#80]
 stp xzr,xzr,[x5,#96]
 stp xzr,xzr,[x5,#112]
 stp xzr,xzr,[x5,#128]
 stp xzr,xzr,[x5,#144]
 stp xzr,xzr,[x5,#160]
 stp xzr,xzr,[x5,#176]
 ldrsw x4,[x4]
 ldrsw x6,[x0,#5144]
 ldrsw x7,[x0,#5224]
 ldrsw x8,[x0,#7376]
 sub x9,x4,#1
 msub x9,x9,x6,x8
 cmp x9,x6
 csel x9,x9,x6,lt
 stp x6,x7,[x5]
 str x9,[x5,#16]
 mov x6,#1
 ldrsw x7,[x1,#1020]
 ADDRESS4 x8,x1,0,x6,x6,x7,x4
 str x8,[x5,#24]
 CONST x9,800032
 ldr x9,[x3,x9]
 ldrsw x7,[x9,#168]
 ADDRESS4 x8,x2,0,x6,x6,x7,x4
 str x8,[x5,#32]
 CONST x9,800048
 ldr x9,[x3,x9]
 ldrsw x7,[x9,#168]
 ADDRESS4 x8,x2,0,x6,x6,x7,x4
 str x8,[x5,#40]
 CONST x9,800040
 ldr x9,[x3,x9]
 ldrsw x7,[x9,#168]
 ADDRESS4 x8,x2,0,x6,x6,x7,x4
 str x8,[x5,#48]
 CONST x9,800112
 ldr x9,[x3,x9]
 ldrsw x7,[x9,#168]
 ADDRESS4 x8,x2,0,x6,x6,x7,x4
 str x8,[x5,#56]
 CONST x9,800104
 ldr x9,[x3,x9]
 ldrsw x7,[x9,#168]
 ADDRESS4 x8,x2,0,x6,x6,x7,x4
 str x8,[x5,#64]
 ldrsw x7,[x1,#1096]
 ADDRESS3 x8,x1,136,x6,x7,x4
 str x8,[x5,#72]
 /* TOROG is a rank-one array of 384-byte records. */
 ldr x9,[x0,#14024]
 ldr x11,[x0,#14032]
 ldr x12,[x0,#14064]
 madd x11,x4,x12,x11
 mov x12,#384
 madd x9,x11,x12,x9
 ldr x8,[x9]
 str x8,[x5,#80]
 ldr x8,[x9,#64]
 str x8,[x5,#96]
 ldr x8,[x9,#128]
 str x8,[x5,#104]
 /* TGSGEOM is a rank-one array of 1472-byte records. */
 ldr x9,[x0,#8472]
 ldr x11,[x0,#8480]
 ldr x12,[x0,#8512]
 madd x11,x4,x12,x11
 mov x12,#1472
 madd x9,x11,x12,x9
 ldr x8,[x9,#704]
 str x8,[x5,#88]
 ldrsw x7,[x1,#1100]
 ADDRESS3 x8,x1,136,x6,x7,x4
 str x8,[x5,#112]
 ldrsw x7,[x1,#1104]
 ADDRESS3 x8,x1,136,x6,x7,x4
 str x8,[x5,#120]
 ldrsw x7,[x1,#1012]
 ADDRESS4 x8,x1,0,x6,x6,x7,x4
 str x8,[x5,#128]
 ldrsw x7,[x1,#1016]
 ADDRESS4 x8,x1,0,x6,x6,x7,x4
 str x8,[x5,#136]
 ldr x8,[x0,#3240]
 str x8,[x5,#144]
 ldr x8,[x0,#3264]
 str x8,[x5,#152]
 ret
.size md2asm_output_block_views_direct,.-md2asm_output_block_views_direct
.global md2asm_output_block_views_
.set md2asm_output_block_views_,md2asm_output_block_views_direct
/* Eleven address arguments: F,E,S,M,PHY,SP,GP,OFN,KSTEP,TSTEP,P.
 * The last three addresses are at incoming sp+0,+8,+16. SP and GP are unused.
 */
.p2align 4
.global md2asm_output_io_views_direct
.type md2asm_output_io_views_direct,%function
md2asm_output_io_views_direct:
 COUNT 16
 ldp x9,x10,[sp]
 ldr x8,[sp,#16]
 ldr x11,[x0,#504]
 ldr x12,[x0,#512]
 ldr x13,[x0,#544]
 add x12,x12,x13
 mov x13,#472
 madd x11,x12,x13,x11
 add x12,x11,#440
 add x13,x11,#444
 stp x12,x13,[x8]
 add x12,x11,#448
 add x13,x0,#572
 stp x12,x13,[x8,#16]
 add x12,x0,#568
 add x13,x0,#580
 stp x12,x13,[x8,#32]
 stp x1,x2,[x8,#48]
 CONST x12,1578600
 add x12,x3,x12
 CONST x13,1577888
 add x13,x3,x13
 stp x12,x13,[x8,#64]
 stp x4,x7,[x8,#80]
 stp x9,x10,[x8,#96]
 add x12,x11,#460
 stp x12,x11,[x8,#112]
 CONST x12,5928
 add x12,x0,x12
 add x13,x0,#568
 stp x12,x13,[x8,#128]
 ret
.size md2asm_output_io_views_direct,.-md2asm_output_io_views_direct
.global md2asm_output_io_views_
.set md2asm_output_io_views_,md2asm_output_io_views_direct
/* Read integer-only call observations: 0=field map,1=block views,2=I/O views. */
.p2align 4
.global md2asm_output_metadata_count_get
.type md2asm_output_metadata_count_get,%function
md2asm_output_metadata_count_get:
 cmp x0,#3
 b.hs .Lcounter_absent
 adrp x1,md2asm_output_metadata_native_counters
 add x1,x1,:lo12:md2asm_output_metadata_native_counters
 ldr x0,[x1,x0,lsl #3]
 ret
.Lcounter_absent:
 mov x0,#0
 ret
.size md2asm_output_metadata_count_get,.-md2asm_output_metadata_count_get
.Lstop109:
 mov x0,#109
 mov x8,#94
 svc #0
 brk #0
.data
.p2align 3
.global md2asm_output_metadata_native_counters
.hidden md2asm_output_metadata_native_counters
.type md2asm_output_metadata_native_counters,%object
.size md2asm_output_metadata_native_counters,24
md2asm_output_metadata_native_counters:
 .zero 24
.section .note.GNU-stack,"",%progbits
