#include "../../support/gpu/preserved_weather_calls.inc.S"
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_output_field_requests
.type md2asm_initialize_output_field_requests,%function
md2asm_initialize_output_field_requests:
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
 mov x19,x2
 mov x20,x0
 uxtw x21,w1
 cmp x21,#1
 b.lo .Lfield_failure
 cmp x21,#64
 b.hi .Lfield_failure
 ldr w9,[x20,#32]
 cbnz w9,.Lfield_failure
 mov x9,#0
.Lfield_fresh:
 ldr x10,[x19,x9]
 cbnz x10,.Lfield_failure
 add x9,x9,#64
 cmp x9,#1344
 b.lo .Lfield_fresh
 mov x9,#0
.Lfield_zero:
 str xzr,[x19,x9]
 add x9,x9,#8
 cmp x9,#1424
 b.lo .Lfield_zero
 mov x9,#0
 add x11,x19,#1372
.Lfield_counts:
 ldr w10,[x20,x9]
 cmp w10,#64
 b.hi .Lfield_failure
 str w10,[x11,x9]
 add x9,x9,#4
 cmp x9,#28
 b.lo .Lfield_counts
 ldr w9,[x20,#28]
 cmp w9,#64
 b.hi .Lfield_failure
 str w9,[x19,#1404]
 adrp x22,.Lfield_level_map
 add x22,x22,:lo12:.Lfield_level_map
 mov x23,#6
.Lfield_real_count:
 ldp w9,w10,[x22]
 ldp w11,w12,[x22,#8]
 add x0,x20,w9,uxtw
 mov w1,w12
 bl .Lfield_count_real
 ldr w10,[x22,#4]
 ldr w11,[x22,#8]
 ldr w9,[x20,w10,uxtw]
 cmp w9,#0
 csel x0,x0,xzr,ne
 str w0,[x19,w11,uxtw]
 add x22,x22,#16
 subs x23,x23,#1
 b.ne .Lfield_real_count
 ldr w9,[x20]
 cbz w9,.Lfield_model_count_ready
 add x10,x20,#2368
 ldr w9,[x10]
 cmn w9,#99
 b.ne .Lfield_count_model_list
 mov x9,x21
 b .Lfield_store_model_count
.Lfield_count_model_list:
 mov x9,#0
.Lfield_model_loop:
 ldr w11,[x10,x9,lsl#2]
 tbnz w11,#31,.Lfield_store_model_count
 cmp w11,#1
 b.lo .Lfield_failure
 cmp w11,w21
 b.hi .Lfield_failure
 add x9,x9,#1
 cmp x9,#64
 b.lo .Lfield_model_loop
.Lfield_store_model_count:
 str w9,[x19,#1364]
.Lfield_model_count_ready:
 adrp x22,.Lfield_owner_map
 add x22,x22,:lo12:.Lfield_owner_map
 mov x23,#21
.Lfield_allocate:
 ldp w9,w10,[x22]
 ldp w11,w12,[x22,#8]
 add x24,x19,w9,uxtw
 ldr w25,[x19,w12,uxtw]
 mov x0,x24
 mov x1,x10
 mov x2,#1
 mov x3,x11
 mov x4,x25
 bl md2asm_allocate_output_request_descriptor
 ldr w10,[x22,#4]
 ldr w11,[x22,#8]
 ldr w12,[x22,#16]
 cmp w11,#6
 b.eq .Lfield_fill_names
 mov x13,#0
 add x14,x20,w12,uxtw
 ldr x15,[x24]
 cmp w11,#3
 b.eq .Lfield_copy_real
 cmp w12,#2368
 b.eq .Lfield_copy_model
.Lfield_copy_integer:
 cmp x13,x25
 b.hs .Lfield_next_owner
 ldr w16,[x14,x13,lsl#2]
 str w16,[x15,x13,lsl#2]
 add x13,x13,#1
 b .Lfield_copy_integer
.Lfield_copy_real:
 cmp x13,x25
 b.hs .Lfield_next_owner
 ldr x16,[x14,x13,lsl#3]
 str x16,[x15,x13,lsl#3]
 add x13,x13,#1
 b .Lfield_copy_real
.Lfield_copy_model:
 ldr w9,[x14]
 cmn w9,#99
 b.ne .Lfield_copy_integer
 mov x13,#0
.Lfield_generate_model:
 cmp x13,x25
 b.hs .Lfield_next_owner
 add w16,w13,#1
 str w16,[x15,x13,lsl#2]
 add x13,x13,#1
 b .Lfield_generate_model
.Lfield_fill_names:
 ldr x15,[x24]
 mul x14,x25,x10
 mov x13,#0
 mov w16,#32
.Lfield_blank_loop:
 cmp x13,x14
 b.hs .Lfield_next_owner
 strb w16,[x15,x13]
 add x13,x13,#1
 b .Lfield_blank_loop
.Lfield_next_owner:
 add x22,x22,#20
 subs x23,x23,#1
 b.ne .Lfield_allocate
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
.size md2asm_initialize_output_field_requests,.-md2asm_initialize_output_field_requests
.Lfield_count_real:
 mov x9,#0
 cbz w1,.Lfield_limit_zero
 cmp w1,#1
 b.ne .Lfield_limit_temperature
 movz x10,#34464
 movk x10,#1,lsl#16
 md2asm_gpu_full_scalar md2asm_gpu_startup_integer_cell_host,17,d1,x10 // scvtf d1,x10
 b .Lfield_count_loop
.Lfield_limit_temperature:
 mov x10,#-999
 md2asm_gpu_full_scalar md2asm_gpu_startup_integer_cell_host,17,d1,x10 // scvtf d1,x10
 b .Lfield_count_loop
.Lfield_limit_zero:
 fmov d1,xzr
.Lfield_count_loop:
 ldr d0,[x0,x9,lsl#3]
 cmp w1,#1
 b.eq .Lfield_count_positive_limit
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,4,none,d0,d1,comparison // fcmp d0,d1
 b.mi .Lfield_count_done
 b .Lfield_count_next
.Lfield_count_positive_limit:
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,4,none,d0,d1,comparison // fcmp d0,d1
 b.ge .Lfield_count_done
.Lfield_count_next:
 add x9,x9,#1
 cmp x9,#64
 b.lo .Lfield_count_loop
.Lfield_count_done:
 mov x0,x9
 ret
.Lfield_failure:
 mov x0,#116
 mov x8,#94
 svc #0
 brk #0
.section .rodata
.p2align 3
.Lfield_level_map:
 .word 2624,4,1344,0,3136,8,1348,0,3648,12,1352,0
 .word 4160,16,1356,1,4672,20,1360,2,5184,24,1368,0
.Lfield_owner_map:
 .word 0,12,6,1400,0,64,16,6,1404,0,128,16,6,1408,0
 .word 192,16,6,1412,0,256,16,6,1416,0
 .word 320,4,1,1372,64,384,4,1,1376,320,448,4,1,1380,576
 .word 512,4,1,1384,832,576,4,1,1388,1088,640,4,1,1392,1344
 .word 704,4,1,1396,1600,768,4,1,1404,1856,832,4,1,1408,2112
 .word 896,8,3,1344,2624,960,8,3,1348,3136,1024,8,3,1352,3648
 .word 1088,8,3,1356,4160,1152,8,3,1360,4672,1216,8,3,1368,5184
 .word 1280,4,1,1364,2368
.section .note.GNU-stack,"",%progbits
