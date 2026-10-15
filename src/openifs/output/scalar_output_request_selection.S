/* Selected scalar request metadata from SUVPOS and CPVPOSPR.
 * No floating-point calculation, allocation or original callable is used here.
 * x0 Q1160, x1 R496, x2 surface request224, x3 F503824, x4 SURF*, w5 V.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_select_scalar_output_request
.type md2asm_select_scalar_output_request,%function
md2asm_select_scalar_output_request:
 sub sp,sp,#112
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 ldr w23,[x4]
 mov w24,w5
 ldr x9,[x19,#72]
 mov x10,#686
.Lselect_zero_72:
 str wzr,[x9],#4
 subs x10,x10,#1
 b.ne .Lselect_zero_72
 ldr x9,[x19,#136]
 mov x10,#686
.Lselect_zero_136:
 str wzr,[x9],#4
 subs x10,x10,#1
 b.ne .Lselect_zero_136
 ldr x9,[x19,#200]
 mov x10,#686
.Lselect_zero_200:
 str wzr,[x9],#4
 subs x10,x10,#1
 b.ne .Lselect_zero_200
 ldr x9,[x19,#264]
 mov x10,#686
.Lselect_zero_264:
 str wzr,[x9],#4
 subs x10,x10,#1
 b.ne .Lselect_zero_264
 ldr x9,[x19,#328]
 mov x10,#686
.Lselect_zero_328:
 str wzr,[x9],#4
 subs x10,x10,#1
 b.ne .Lselect_zero_328
 /* Source surface requests are set before three-dimensional requests. */
 cbz w23,.Lselect_upper_start
 ldr w9,[x21]
 cmp w9,#1
 b.hi .Lselect_reject
 cbz w9,.Lselect_upper_start
 ldr x9,[x21,#8]
 ldr w9,[x9]
 cmp w9,#454
 b.ne .Lselect_reject
 mov x26,#453
 mov x9,#112
 madd x9,x26,x9,x22
 add x9,x9,#1,lsl #12
 add x9,x9,#1976
 ldr w10,[x9,#32]
 cbnz w10,.Lselect_surface_grid
 ldr w10,[x9,#16]
 cmp w10,#3
 mov w11,#1
 csel w10,w11,w10,eq
 b .Lselect_surface_fit
.Lselect_surface_grid:
 mov w10,#0
.Lselect_surface_fit:
 cmp w10,#1
 b.hi .Lselect_stop109
 ldr x9,[x19,#136]
 str w10,[x9,x26,lsl #2]
 mov w10,#1
 ldr x9,[x19,#72]
 str w10,[x9,x26,lsl #2]
 ldr x9,[x19,#328]
 str w10,[x9,x26,lsl #2]
 ldr x11,[x19,#456]
 mul x12,x26,x11
 ldr x9,[x19,#392]
 str w10,[x9,x12,lsl #2]
 ldr x9,[x21,#72]
 ldr w10,[x9]
 cmp w10,#1
 b.hi .Lselect_reject
 ldr x9,[x19,#480]
 str w10,[x9,x12,lsl #2]
 cbz w10,.Lselect_upper_start
 ldr x9,[x21,#136]
 ldr w10,[x9]
 ldr x9,[x19,#568]
 str w10,[x9,x12,lsl #2]
.Lselect_upper_start:
 ldr w9,[x20,#8]
 str w9,[x19,#1156]
 mov x25,#0
.Lselect_upper_field:
 ldr w9,[x20]
 cmp w9,#2
 b.hi .Lselect_reject
 cmp x25,x9
 b.hs .Lselect_finalize
 ldr x9,[x20,#80]
 ldr w10,[x9,x25,lsl #2]
 sub w9,w10,#5
 cmp w9,#1
 b.hi .Lselect_reject
 sub x26,x10,#1
 mov x9,#112
 madd x6,x26,x9,x22
 add x6,x6,#1,lsl #12
 add x6,x6,#1976
 mov x9,#0
 mov w10,#1
.Lselect_nil_search:
 /* CLNIL begins at the IGRIB-relative byte 44. */
 add x12,x6,#44
 ldrb w11,[x12,x9]
 cmp w11,w24
 csel w10,wzr,w10,eq
 add x9,x9,#1
 cmp x9,#16
 b.ne .Lselect_nil_search
 ldr x9,[x19,#72]
 str w10,[x9,x26,lsl #2]
 str w10,[sp,#96]
 ldr w9,[x6,#32]
 cbnz w9,.Lselect_upper_grid
 ldr w9,[x20,#8]
 sub w9,w9,#1
 cmp w9,#1
 b.hi .Lselect_upper_grid
 ldr w10,[x20,#12]
 cmp w10,#3
 mov w11,#1
 csel w10,w11,w10,eq
 ldr w9,[x6,#16]
 cmp w9,w10
 csel w10,w9,w10,ge
 cmp w10,#3
 csel w10,w11,w10,eq
 b .Lselect_upper_fit
.Lselect_upper_grid:
 mov w10,#0
.Lselect_upper_fit:
 ldr w9,[sp,#96]
 cbz w9,.Lselect_fit_store
 cmp w10,#1
 b.hi .Lselect_stop109
.Lselect_fit_store:
 ldr x9,[x19,#136]
 str w10,[x9,x26,lsl #2]
 ldr x9,[x20,#144]
 ldr w28,[x9,x25,lsl #2]
 ldr x9,[x19,#448]
 cmp x28,x9
 b.hi .Lselect_reject
 ldr x9,[x19,#328]
 str w28,[x9,x26,lsl #2]
 mov x27,#0
.Lselect_upper_level:
 cmp x27,x28
 b.hs .Lselect_upper_next
 ldr x9,[x20,#272]
 madd x10,x25,x9,x27
 ldr x9,[x19,#456]
 madd x12,x26,x9,x27
 ldr x9,[x20,#208]
 ldr w11,[x9,x10,lsl #2]
 ldr x9,[x19,#392]
 str w11,[x9,x12,lsl #2]
 ldr x9,[x20,#296]
 ldr w11,[x9,x10,lsl #2]
 cmp w11,#1
 b.hi .Lselect_reject
 ldr x9,[x19,#480]
 str w11,[x9,x12,lsl #2]
 cbz w11,.Lselect_upper_level_done
 ldr x9,[x20,#384]
 ldr w11,[x9,x10,lsl #2]
 ldr x9,[x19,#568]
 str w11,[x9,x12,lsl #2]
.Lselect_upper_level_done:
 add x27,x27,#1
 b .Lselect_upper_level
.Lselect_upper_next:
 add x25,x25,#1
 b .Lselect_upper_field
.Lselect_finalize:
 mov x0,x19
 bl md2asm_finalize_scalar_output_request
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp]
 add sp,sp,#112
 ret
.size md2asm_select_scalar_output_request,.-md2asm_select_scalar_output_request
.p2align 4
.global md2asm_finalize_scalar_output_request
.type md2asm_finalize_scalar_output_request,%function
md2asm_finalize_scalar_output_request:
 sub sp,sp,#112
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 mov x19,x0
 ldr w20,[x19,#1156]
 ldr x9,[x19,#448]
 cmp x9,#64
 b.hi .Lselect_reject
 cmp x9,#1
 b.lt .Lselect_reject
 mov x10,#686
 mul x11,x9,x10
 str x11,[sp,#96]
 ldr x9,[x19,#832]
 ldr x10,[sp,#96]
 mov w11,#1
.Lscalar_fill_832:
 str w11,[x9],#4
 subs x10,x10,#1
 b.ne .Lscalar_fill_832
 ldr x9,[x19,#920]
 ldr x10,[sp,#96]
 mov w11,#0
.Lscalar_fill_920:
 str w11,[x9],#4
 subs x10,x10,#1
 b.ne .Lscalar_fill_920
 ldr x9,[x19,#1008]
 ldr x10,[sp,#96]
 mov w11,#0
.Lscalar_fill_1008:
 str w11,[x9],#4
 subs x10,x10,#1
 b.ne .Lscalar_fill_1008
 ldr x9,[x19,#680]
 mov x10,#686
.Lscalar_zero_680:
 str wzr,[x9],#4
 subs x10,x10,#1
 b.ne .Lscalar_zero_680
 ldr x9,[x19,#744]
 mov x10,#2058
.Lscalar_zero_744:
 str wzr,[x9],#4
 subs x10,x10,#1
 b.ne .Lscalar_zero_744
 add x9,x19,#1096
 stp xzr,xzr,[x9]
 stp xzr,xzr,[x9,#16]
 stp xzr,xzr,[x9,#32]
 stp xzr,xzr,[x9,#48]
 str w20,[x19,#1156]
 mov x21,#0
 mov x22,#0
 mov x23,#0
 mov x25,#0
 mov x26,#1
 mov x27,#1
 mov x28,#1
.Lscalar_field:
 ldr x9,[x19,#72]
 ldr w10,[x9,x25,lsl #2]
 cbnz w10,.Lscalar_selected
 ldr x9,[x19,#136]
 str wzr,[x9,x25,lsl #2]
 ldr x9,[x19,#328]
 str wzr,[x9,x25,lsl #2]
 b .Lscalar_next
.Lscalar_selected:
 mov x24,x25
 add w10,w25,#1
 ldr x9,[x19,#8]
 str w10,[x9,x21,lsl #2]
 add x21,x21,#1
 ldr x9,[x19,#200]
 mov w10,#1
 str w10,[x9,x24,lsl #2]
 ldr x9,[x19,#328]
 ldr w13,[x9,x24,lsl #2]
 ldr x9,[x19,#136]
 ldr w14,[x9,x24,lsl #2]
 mov x15,#0
 ldr x9,[x19,#456]
 mul x12,x24,x9
.Lscalar_level:
 cmp x15,x13
 b.hs .Lscalar_pointers
 add x11,x12,x15
 ldr x9,[x19,#1008]
 mov w10,#1
 str w10,[x9,x11,lsl #2]
 cmp w14,#1
 b.lt .Lscalar_level_next
 add x10,x22,x15
 add x10,x10,#1
 ldr x9,[x19,#920]
 str w10,[x9,x11,lsl #2]
.Lscalar_level_next:
 add x15,x15,#1
 b .Lscalar_level
.Lscalar_pointers:
 cmp w14,#1
 b.lt .Lscalar_grid_pointer
 ldr x9,[x19,#744]
 add x10,x24,#686
 str w26,[x9,x10,lsl #2]
 str w27,[x9,x24,lsl #2]
 add x26,x26,x13
 add x22,x22,x13
 cmp w20,#2
 b.eq .Lscalar_next
 add x27,x27,x13
 b .Lscalar_next
.Lscalar_grid_pointer:
 ldr x9,[x19,#680]
 str w28,[x9,x24,lsl #2]
 add x28,x28,x13
 add x23,x23,x13
.Lscalar_next:
 add x25,x25,#1
 cmp x25,#686
 b.ne .Lscalar_field
 str w21,[x19]
 str w22,[x19,#1096]
 str w23,[x19,#1100]
 str w22,[x19,#1108]
 str w22,[x19,#1116]
 cmp w20,#2
 csel w9,wzr,w22,eq
 str w9,[x19,#1120]
 add w9,w22,w23
 str w9,[x19,#1124]
 str w22,[x19,#1128]
 str w22,[x19,#1140]
 str w22,[x19,#1148]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp]
 add sp,sp,#112
 ret
.size md2asm_finalize_scalar_output_request,.-md2asm_finalize_scalar_output_request
.Lselect_stop109:
 mov x0,#109
 mov x8,#94
 svc #0
 brk #0
.Lselect_reject:
 mov x0,#116
 mov x8,#94
 svc #0
 brk #0
.section .note.GNU-stack,"",%progbits
