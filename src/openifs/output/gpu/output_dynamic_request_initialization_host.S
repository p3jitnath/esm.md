#include "../../support/gpu/preserved_weather_calls.inc.S"
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_output_dynamic_requests
.type md2asm_initialize_output_dynamic_requests,%function
md2asm_initialize_output_dynamic_requests:
 sub sp,sp,#224
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 stp x0,x1,[sp,#104]
 stp x2,x3,[sp,#120]
 stp x4,x5,[sp,#136]
 str x6,[sp,#152]
 mrs x9,fpcr
 mrs x10,fpsr
 stp x9,x10,[sp,#160]
 bl __errno_location
 str x0,[sp,#176]
 ldr w9,[x0]
 str w9,[sp,#184]
 ldp x0,x1,[sp,#104]
 ldp x2,x3,[sp,#120]
 ldp x4,x5,[sp,#136]
 ldr x6,[sp,#152]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 adrp x22,.Ldyn_request_map
 add x22,x22,:lo12:.Ldyn_request_map
 mov x23,#0
.Ldyn_select_record:
 ldr w9,[x22]
 add x24,x21,w9,uxtw
 ldr w9,[x22,#4]
 ldr w25,[x20,w9,uxtw]
 cmp w25,#64
 b.hi .Ldyn_failure
 cmp x23,#7
 b.eq .Ldyn_allocate_2d
 ldr w9,[x22,#8]
 ldr w26,[x20,w9,uxtw]
 cmp w26,#64
 b.hi .Ldyn_failure
 mov x0,x24
 mov w1,w25
 mov w2,w26
 bl md2asm_allocate_output_dynamic_3d_request
 ldr w9,[x22,#20]
 ldr w10,[x19,w9,uxtw]
 str w10,[x24,#8]
 ldr w9,[x22,#24]
 ldr w10,[x19,w9,uxtw]
 str w10,[x24,#12]
 ldr w9,[x22,#16]
 ldr x9,[x20,w9,uxtw]
 ldr x10,[x24,#16]
 ldr w11,[x22,#28]
 mov x12,#0
.Ldyn_copy_levels:
 cmp x12,x26
 b.hs .Ldyn_copy_fields
 cbnz w11,.Ldyn_copy_integer_level
 ldr x13,[x9,x12,lsl#3]
 str x13,[x10,x12,lsl#3]
 b .Ldyn_next_level
.Ldyn_copy_integer_level:
 ldr w13,[x9,x12,lsl#2]
 md2asm_gpu_full_scalar md2asm_gpu_startup_integer_cell_host,18,d0,w13 // scvtf d0,w13
 str d0,[x10,x12,lsl#3]
.Ldyn_next_level:
 add x12,x12,#1
 b .Ldyn_copy_levels
.Ldyn_allocate_2d:
 mov x0,x24
 mov w1,w25
 bl md2asm_allocate_output_dynamic_2d_request
.Ldyn_copy_fields:
 ldr w9,[x22,#12]
 ldr x26,[x20,w9,uxtw]
 mov x27,#0
 cmp x23,#7
 mov x9,#80
 mov x10,#8
 csel x9,x9,x10,ne
 ldr x28,[x24,x9]
.Ldyn_lookup_field:
 cmp x27,x25
 b.hs .Ldyn_next_record
 ldr w9,[x26,x27,lsl#2]
 mov x10,#6072
 add x10,x19,x10
 mov x11,#0
.Ldyn_search:
 ldr w12,[x10]
 cmp w12,w9
 b.ne .Ldyn_search_next
 cmp x23,#7
 b.ne .Ldyn_field_found
 ldr w12,[x10,#36]
 cbnz w12,.Ldyn_field_found
.Ldyn_search_next:
 add x10,x10,#112
 add x11,x11,#1
 cmp x11,#686
 b.lo .Ldyn_search
 b .Ldyn_failure
.Ldyn_field_found:
 add w11,w11,#1
 str w11,[x28,x27,lsl#2]
 add x27,x27,#1
 b .Ldyn_lookup_field
.Ldyn_next_record:
 add x22,x22,#32
 add x23,x23,#1
 cmp x23,#8
 b.lo .Ldyn_select_record
 ldr x9,[sp,#176]
 ldr w10,[sp,#184]
 str w10,[x9]
 ldp x9,x10,[sp,#160]
 msr fpcr,x9
 msr fpsr,x10
 ldr x18,[sp,#96]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp]
 add sp,sp,#224
 ret
.size md2asm_initialize_output_dynamic_requests,.-md2asm_initialize_output_dynamic_requests
.Ldyn_failure:
 mov x0,#116
 mov x8,#94
 svc #0
 brk #0
.section .rodata
.p2align 3
.Ldyn_request_map:
 .word 0,1376,1344,384,896,503688,503716,0
 .word 1488,1380,1348,448,960,503708,503736,0
 .word 496,1384,1352,512,1024,503692,503720,0
 .word 992,1388,1356,576,1088,503696,503724,0
 .word 1984,1372,1364,320,1280,503712,503740,1
 .word 2976,1392,1360,640,1152,503700,503728,0
 .word 2480,1396,1368,704,1216,503704,503732,0
 .word 3472,1404,0,768,0,0,0,0
.section .note.GNU-stack,"",%progbits
