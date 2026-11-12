/* GPU physical setup route. Original interface and ordered arithmetic are preserved.
 * Contract: skills/md2fort-gpu/references/openifs/setup/physical_setup.md
 * Original source: src/openifs/dynamics/selected_gridpoint_norms.S
 */
// Original contract: skills/md2fort/references/openifs/dynamics/selected_gridpoint_norms.md
#include "../../support/gpu/preserved_scalar_calls.inc.S"
.arch armv8.2-a
.text
.p2align 4
.global md2asm_compute_selected_gridpoint_norms
.type md2asm_compute_selected_gridpoint_norms,%function
md2asm_compute_selected_gridpoint_norms:
 cbz x0,.Lg_early_bad
 cbz x1,.Lg_early_bad
 cbz x2,.Lg_early_bad
 cbz x3,.Lg_early_bad
 tst x0,#7
 b.ne .Lg_early_bad
 tst x1,#7
 b.ne .Lg_early_bad
 tst x2,#3
 b.ne .Lg_early_bad
 tst x3,#7
 b.ne .Lg_early_bad
 cmp x4,#264
 b.lo .Lg_early_bad
 sub sp,sp,#4096
 stp x19,x20,[sp,#64]
 stp x21,x22,[sp,#80]
 stp x23,x24,[sp,#96]
 stp x25,x26,[sp,#112]
 stp x27,x28,[sp,#128]
 stp x29,x30,[sp,#144]
 mov x19,x0
 mov x20,x1
 str x3,[sp,#224]
 str x18,[sp,#240]
 ldp w9,w10,[x2]
 orr w9,w9,w10
 cbnz w9,.Lg_bad
 ldr w9,[x2,#8]
 cmp w9,#1
 b.ne .Lg_bad
 mrs x9,fpcr
 cbnz x9,.Lg_bad
 mov x9,#5144
 ldr w10,[x19,x9]
 cmp w10,#24
 b.ne .Lg_bad
 mov x9,#5160
 ldr w10,[x19,x9]
 cmp w10,#86
 b.ne .Lg_bad
 mov x9,#5224
 ldr w10,[x19,x9]
 cmp w10,#19
 b.ne .Lg_bad
 mov x9,#7376
 ldr w10,[x19,x9]
 cmp w10,#2048
 b.ne .Lg_bad
 ldr x9,[x20]
 cbz x9,.Lg_bad
 ldr x9,[x20,#16]
 cmp x9,#8
 b.ne .Lg_bad
 ldrb w9,[x20,#28]
 cmp w9,#4
 b.ne .Lg_bad
 ldr x9,[x20,#40]
 mov x10,#1
 cmp x9,x10
 b.ne .Lg_bad
 ldr x9,[x20,#48]
 cmp x9,#1
 b.ne .Lg_bad
 ldr x9,[x20,#56]
 cmp x9,#24
 b.ne .Lg_bad
 ldr x9,[x20,#64]
 mov x10,#24
 cmp x9,x10
 b.ne .Lg_bad
 ldr x9,[x20,#72]
 cmp x9,#1
 b.ne .Lg_bad
 ldr x9,[x20,#80]
 cmp x9,#19
 b.ne .Lg_bad
 ldr x9,[x20,#88]
 mov x10,#456
 cmp x9,x10
 b.ne .Lg_bad
 ldr x9,[x20,#96]
 cmp x9,#1
 b.ne .Lg_bad
 ldr x9,[x20,#104]
 cmp x9,#8
 b.ne .Lg_bad
 ldr x9,[x20,#112]
 mov x10,#3648
 cmp x9,x10
 b.ne .Lg_bad
 ldr x9,[x20,#120]
 cmp x9,#1
 b.ne .Lg_bad
 ldr x9,[x20,#128]
 cmp x9,#86
 b.ne .Lg_bad
 ldr x9,[x20,#8]
 mov x10,#-4129
 cmp x9,x10
 b.ne .Lg_bad
 ldr x21,[x20,#1088]
 cbz x21,.Lg_bad
 ldr w22,[x21]
 cmp w22,#8
 b.ne .Lg_bad
.Lg_started:
 mov x23,#0
 mov x24,#0
 mov x9,#3848
 add x28,x21,x9
.Lg_select:
 cmp x24,x22
 b.ge .Lg_selected
 ldr w9,[x28,#52]
 cbz w9,.Lg_select_next
 add x9,sp,#512
 str w24,[x9,x23,lsl #2]
 add x23,x23,#1
.Lg_select_next:
 add x28,x28,#368
 add x24,x24,#1
 b .Lg_select
.Lg_selected:
 str w23,[sp,#288]
 cmp x23,#8
 b.ne .Lg_bad
 mov x9,#16512
 mul x0,x23,x9
 str x18,[sp,#240]
 bl malloc
 ldr x18,[sp,#240]
 cbz x0,.Lg_allocation_failed
 mov x21,x0
 mov x24,#0
 ldr x28,[sp,#224]
.Lg_field:
 cmp x24,x23
 b.ge .Lg_reduction
 add x9,sp,#512
 ldrsw x22,[x9,x24,lsl #2]
 mov x25,#0
.Lg_block:
 cmp x25,#86
 b.ge .Lg_extrema
 mov x26,#24
 cmp x25,#85
 b.ne .Lg_fullblock
 mov x26,#8
.Lg_fullblock:
 ldr x9,[x20,#8]
 ldr x10,[x20,#48]
 add x10,x10,xzr
 ldr x11,[x20,#40]
 madd x9,x10,x11,x9
 ldr x10,[x20,#72]
 add x10,x10,xzr
 ldr x11,[x20,#64]
 madd x9,x10,x11,x9
 ldr x10,[x20,#96]
 add x10,x10,x22
 ldr x11,[x20,#88]
 madd x9,x10,x11,x9
 ldr x10,[x20,#120]
 add x10,x10,xzr
 ldr x11,[x20,#112]
 madd x9,x10,x11,x9
 ldr x10,[x20]
 ldr d2,[x10,x9,lsl #3]
 fmov d3,d2
 mov x27,#0
.Lg_zero_cells:
 madd x9,x25,x23,x24
 mov x10,#24
 madd x9,x9,x10,x27
 str xzr,[x21,x9,lsl #3]
 add x27,x27,#1
 cmp x27,x26
 b.lt .Lg_zero_cells
 mov x15,#0
.Lg_level:
 mov x27,#0
.Lg_cell:
 ldr x9,[x20,#8]
 ldr x10,[x20,#48]
 add x10,x10,x27
 ldr x11,[x20,#40]
 madd x9,x10,x11,x9
 ldr x10,[x20,#72]
 add x10,x10,x15
 ldr x11,[x20,#64]
 madd x9,x10,x11,x9
 ldr x10,[x20,#96]
 add x10,x10,x22
 ldr x11,[x20,#88]
 madd x9,x10,x11,x9
 ldr x10,[x20,#120]
 add x10,x10,x25
 ldr x11,[x20,#112]
 madd x9,x10,x11,x9
 ldr x10,[x20]
 ldr d0,[x10,x9,lsl #3]
 madd x12,x25,x23,x24
 mov x13,#24
 madd x12,x12,x13,x27
 ldr d1,[x21,x12,lsl #3]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d1,destination,d1,real,x16,0,d0
 str d1,[x21,x12,lsl #3]
 md2asm_gpu_preserved_scalar md2asm_gpu_output_numeric_cell_host,18,d2,destination,d2,real,x16,0,d0
 md2asm_gpu_preserved_scalar md2asm_gpu_output_numeric_cell_host,17,d3,destination,d3,real,x16,0,d0
 add x27,x27,#1
 cmp x27,x26
 b.lt .Lg_cell
 add x15,x15,#1
 cmp x15,#19
 b.lt .Lg_level
 add x9,sp,#640
 str d2,[x9,x25,lsl #3]
 add x9,sp,#1344
 str d3,[x9,x25,lsl #3]
 add x25,x25,#1
 b .Lg_block
.Lg_extrema:
 add x9,sp,#640
 ldr d2,[x9]
 add x10,sp,#1344
 ldr d3,[x10]
 mov x11,#1
.Lg_minmax_reduce:
 ldr d0,[x9,x11,lsl #3]
 ldr d1,[x10,x11,lsl #3]
 md2asm_gpu_preserved_scalar md2asm_gpu_output_numeric_cell_host,18,d2,destination,d2,real,x16,0,d0
 md2asm_gpu_preserved_scalar md2asm_gpu_output_numeric_cell_host,17,d3,destination,d3,real,x16,0,d1
 add x11,x11,#1
 cmp x11,#86
 b.lt .Lg_minmax_reduce
 add x9,x28,x24,lsl #5
 stp d2,d3,[x9,#16]
 add x24,x24,#1
 b .Lg_field
.Lg_reduction:
 add x0,sp,#2048
 mov x1,x21
 mov x2,#24
 mov x3,#8
 mov x4,#86
 mov w5,#3
 bl .Lg_array_descriptor
 add x0,sp,#2160
 add x1,sp,#304
 mov x2,#8
 mov w5,#1
 bl .Lg_array_descriptor
 add x0,sp,#2224
 add x1,sp,#384
 mov x2,#8
 mov w5,#1
 bl .Lg_array_descriptor
 add x0,sp,#2288
 add x1,sp,#448
 mov x2,#8
 mov w5,#1
 bl .Lg_array_descriptor
 mov x9,#0
.Lg_copy_input_extremes:
 add x10,x28,x9,lsl#5
 ldp x11,x12,[x10,#16]
 add x13,sp,#384
 str x11,[x13,x9,lsl#3]
 add x13,sp,#448
 str x12,[x13,x9,lsl#3]
 add x9,x9,#1
 cmp x9,#8
 b.lo .Lg_copy_input_extremes
 mov w9,#1
 str w9,[sp,#292]
 add x0,sp,#2048
 add x1,sp,#288
 mov x9,#5144
 add x2,x19,x9
 add x3,sp,#2160
 add x4,sp,#2224
 add x5,sp,#2288
 add x6,sp,#292
 mov x9,#5168
 add x7,x19,x9
 str x18,[sp,#240]
 bl gpnorm_trans_
 ldr x18,[sp,#240]
 mov x24,#0
 adr x9,.Lg_levels
 ldr d2,[x9]
.Lg_average_store:
 add x9,sp,#304
 ldr d0,[x9,x24,lsl#3]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d1,destination,d0,real,x16,0,d2
 add x10,x28,x24,lsl #5
 stp d0,d1,[x10]
 add x9,sp,#384
 ldr x11,[x9,x24,lsl#3]
 add x9,sp,#448
 ldr x12,[x9,x24,lsl#3]
 stp x11,x12,[x10,#16]
 add x24,x24,#1
 cmp x24,x23
 b.lt .Lg_average_store
 mov x0,x21
 str x18,[sp,#240]
 bl free
 ldr x18,[sp,#240]
.Lg_finished:
 ldr x9,[sp,#224]
 str w23,[x9,#256]
 mov w0,#0
.Lg_return:
 ldr x18,[sp,#240]
 ldp x19,x20,[sp,#64]
 ldp x21,x22,[sp,#80]
 ldp x23,x24,[sp,#96]
 ldp x25,x26,[sp,#112]
 ldp x27,x28,[sp,#128]
 ldp x29,x30,[sp,#144]
 add sp,sp,#4096
 ret
.Lg_bad:
 mov w0,#2
 b .Lg_return
.Lg_allocation_failed:
 mov w0,#1
 b .Lg_return
.Lg_early_bad:
 mov w0,#2
 ret
.Lg_array_descriptor:
 str x1,[x0]
 mov x6,#8
 str x6,[x0,#16]
 str wzr,[x0,#24]
 mov w6,#0x300
 orr w6,w6,w5
 str w6,[x0,#28]
 mov x6,#8
 str x6,[x0,#32]
 mov x6,#1
 mov x7,#1
 mov x8,#0
 add x9,x0,#40
.Lg_descriptor_dimension:
 stp x6,x7,[x9]
 str x2,[x9,#16]
 add x8,x8,x6
 mul x6,x6,x2
 add x9,x9,#24
 subs w5,w5,#1
 b.eq .Lg_descriptor_done
 mov x2,x3
 mov x3,x4
 b .Lg_descriptor_dimension
.Lg_descriptor_done:
 neg x8,x8
 str x8,[x0,#8]
 ret
.section .rodata
.p2align 3
.Lg_levels:
 .double 19.0
.section .note.GNU-stack,"",%progbits
