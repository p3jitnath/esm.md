#include "../../support/gpu/preserved_weather_calls.inc.S"
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_selected_fullpos_filters
.type md2asm_initialize_selected_fullpos_filters,%function
md2asm_initialize_selected_fullpos_filters:
 cbz x0,.Lparent_early_bad
 cbz x1,.Lparent_early_bad
 orr x9,x0,x1
 tst x9,#7
 b.ne .Lparent_early_bad
 adds x10,x0,#112
 b.cs .Lparent_early_bad
 movz x9,#13408
 movk x9,#2,lsl#16
 cmp x2,x9
 b.lo .Lparent_early_bad
 adds x11,x1,x9
 b.cs .Lparent_early_bad
 sub sp,sp,#352
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#336]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 add x12,sp,#96
 stp x0,x10,[x12]
 stp x1,x11,[x12,#16]
 adr x13,.Lparent_sizes
 mov x14,#0
.Lparent_view:
 add x9,x19,x14,lsl#4
 ldp x10,x11,[x9]
 cbz x10,.Lparent_bad
 ldr x15,[x13,x14,lsl#3]
 cbnz x14,.Lparent_fixed_view
 cbz x11,.Lparent_bad
 cmp x11,#64,lsl#12
 b.hi .Lparent_bad
 mov x15,x11
 b .Lparent_view_size
.Lparent_fixed_view:
 tst x10,#7
 b.ne .Lparent_bad
 cmp x11,x15
 b.lo .Lparent_bad
.Lparent_view_size:
 adds x11,x10,x15
 b.cs .Lparent_bad
 add x9,x14,#2
 add x9,x12,x9,lsl#4
 stp x10,x11,[x9]
 add x14,x14,#1
 cmp x14,#7
 b.lo .Lparent_view
 ldr x25,[x19,#16]
 ldp x10,x11,[x25]
 cbz x10,.Lparent_bad
 tst x10,#7
 b.ne .Lparent_bad
 mov x9,#51112
 cmp x11,x9
 b.lo .Lparent_bad
 adds x11,x10,x9
 b.cs .Lparent_bad
 add x9,sp,#240
 stp x10,x11,[x9]
 mov x9,#0
.Lparent_range_outer:
 add x10,sp,#96
 add x10,x10,x9,lsl#4
 ldp x11,x12,[x10]
 add x13,x9,#1
.Lparent_range_inner:
 cmp x13,#10
 b.hs .Lparent_range_next
 add x10,sp,#96
 add x10,x10,x13,lsl#4
 ldp x14,x15,[x10]
 cmp x11,x15
 b.hs .Lparent_range_distinct
 cmp x14,x12
 b.lo .Lparent_bad
.Lparent_range_distinct:
 add x13,x13,#1
 b .Lparent_range_inner
.Lparent_range_next:
 add x9,x9,#1
 cmp x9,#9
 b.lo .Lparent_range_outer
 ldr x26,[x19,#32]
 ldr x24,[x19,#48]
 ldr x23,[x19,#64]
 ldr x21,[x19,#80]
 ldr x22,[x19,#96]
 ldr w9,[x25,#28]
 cmp w9,#1
 b.ne .Lparent_bad
 ldp x9,x10,[x23,#16]
 orr x9,x9,x10
 cbnz x9,.Lparent_bad
 ldr w9,[x23,#36]
 cbnz w9,.Lparent_bad
 ldr w9,[x23,#32]
 sub w9,w9,#1
 cmp w9,#4094
 b.hi .Lparent_bad
 ldr x9,[x23,#40]
 mov x10,#0x3ff0000000000000
 cmp x9,x10
 b.ne .Lparent_bad
 ldr w9,[x24,#20]
 cbnz w9,.Lparent_bad
 ldr w9,[x24,#12]
 cmp w9,#1
 b.ne .Lparent_bad
 add x9,x24,#24
 mov x10,#15
.Lparent_zero_cutoffs:
 ldr w11,[x9],#4
 cbnz w11,.Lparent_bad
 subs x10,x10,#1
 b.ne .Lparent_zero_cutoffs
 add x9,x26,#276
 mov x10,#8
.Lparent_scientific_switches:
 ldr w11,[x9],#4
 cmp w11,#1
 b.ne .Lparent_bad
 subs x10,x10,#1
 b.ne .Lparent_scientific_switches
 ldr x9,[x21]
 ldr x10,[x21,#64]
 ldr x11,[x21,#160]
 orr x9,x9,x10
 orr x9,x9,x11
 cbnz x9,.Lparent_bad
 movz x9,#13328
 movk x9,#2,lsl#16
 add x27,x20,x9
 adr x10,.Lparent_configuration_outputs
 mov x11,#0
.Lparent_configuration_table:
 ldp x12,x13,[x10],#16
 add x12,x20,x12
 add x14,x27,x11,lsl#4
 stp x12,x13,[x14]
 add x11,x11,#1
 cmp x11,#5
 b.lo .Lparent_configuration_table
 ldr w10,[x22,#36]
 movz x9,#5812
 movk x9,#1,lsl#16
 str w10,[x20,x9]
 ldp x0,x1,[x19]
 mov x2,x25
 mov x3,x27
 movz x9,#5824
 movk x9,#1,lsl#16
 add x4,x20,x9
 mov x5,x9
 bl md2asm_initialize_selected_fullpos_configuration
 ldr x18,[sp,#336]
 cbnz w0,.Lparent_return
 movz x9,#11648
 movk x9,#2,lsl#16
 add x27,x20,x9
 mov x10,x27
 mov x11,#178
.Lparent_fresh_temporary:
 str xzr,[x10],#8
 subs x11,x11,#1
 b.ne .Lparent_fresh_temporary
 mov x9,#8928
 add x0,x20,x9
 mov x1,#62384
 mov x2,x23
 mov x3,x27
 mov x4,#1424
 bl md2asm_initialize_selected_fullpos_fields
 ldr x18,[sp,#336]
 cbnz w0,.Lparent_return
 mov x0,#4
 bl malloc
 ldr x18,[sp,#336]
 cbz x0,.Lparent_allocation_failed
 mov x25,x0
 ldr w9,[x23,#32]
 md2asm_gpu_full_scalar md2asm_gpu_startup_integer_cell_host,18,d0,w9 // scvtf d0,w9
 ldr d1,[x23,#40]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0,d0,d1
 md2asm_gpu_full_scalar md2asm_gpu_startup_integer_cell_host,20,w10,d0 // fcvtas w10,d0
 ldr w11,[x24,#20]
 cmp w11,w10
 csel w10,w11,w10,ge
 cmp w10,w9
 cset w28,gt
 str wzr,[x25]
 movz x9,#13072
 movk x9,#2,lsl#16
 add x26,x20,x9
 mov x10,x21
 mov x11,#15
.Lparent_copy_filter_preimage:
 ldp x12,x13,[x10],#16
 stp x12,x13,[x26],#16
 subs x11,x11,#1
 b.ne .Lparent_copy_filter_preimage
 ldr x12,[x10]
 str x12,[x26]
 movz x9,#13072
 movk x9,#2,lsl#16
 add x26,x20,x9
 mov x9,#-1
 stp x25,x9,[x26]
 mov x9,#4
 mov x10,#0x201
 lsl x10,x10,#32
 stp x9,x10,[x26,#16]
 mov x10,#1
 stp x9,x10,[x26,#32]
 stp x10,x10,[x26,#48]
 str w28,[x26,#152]
 mov x0,x27
 mov x1,#1424
 bl md2asm_release_selected_fullpos_fields
 ldr x18,[sp,#336]
 mov x9,x26
 mov x10,x21
 mov x11,#15
.Lparent_commit_filter:
 ldp x12,x13,[x9],#16
 stp x12,x13,[x10],#16
 subs x11,x11,#1
 b.ne .Lparent_commit_filter
 ldr x12,[x9]
 str x12,[x10]
 movz x9,#5776
 movk x9,#1,lsl#16
 add x9,x20,x9
 ldp x10,x11,[x9]
 stp x10,x11,[x22]
 ldp x10,x11,[x9,#16]
 stp x10,x11,[x22,#16]
 ldp x10,x11,[x9,#32]
 stp x10,x11,[x22,#32]
 mov w0,#0
 b .Lparent_return
.Lparent_allocation_failed:
 mov x0,x27
 mov x1,#1424
 bl md2asm_release_selected_fullpos_fields
 ldr x18,[sp,#336]
 mov w0,#1
 b .Lparent_return
.Lparent_bad:
 mov w0,#2
.Lparent_return:
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp]
 add sp,sp,#352
 ret
.Lparent_early_bad:
 mov w0,#2
 ret
.size md2asm_initialize_selected_fullpos_filters,.-md2asm_initialize_selected_fullpos_filters
.global md2asm_release_selected_fullpos_filters
.type md2asm_release_selected_fullpos_filters,%function
md2asm_release_selected_fullpos_filters:
 cbz x0,.Lparent_release_bad
 tst x0,#7
 b.ne .Lparent_release_bad
 cmp x1,#248
 b.lo .Lparent_release_bad
 adds x9,x0,#248
 b.cs .Lparent_release_bad
 stp x29,x30,[sp,#-32]!
 stp x19,x18,[sp,#16]
 mov x29,sp
 mov x19,x0
 ldr x0,[x19]
 bl free
 ldr x18,[sp,#24]
 str xzr,[x19]
 mov w0,#0
 ldp x19,x18,[sp,#16]
 ldp x29,x30,[sp],#32
 ret
.Lparent_release_bad:
 mov w0,#2
 ret
.size md2asm_release_selected_fullpos_filters,.-md2asm_release_selected_fullpos_filters
.section .rodata
.p2align 3
.Lparent_sizes: .quad 0,32,312,8424,48,248,48
.Lparent_configuration_outputs: .quad 0,8544,8544,312,8856,72,8928,62384,71312,48
.section .note.GNU-stack,"",%progbits
