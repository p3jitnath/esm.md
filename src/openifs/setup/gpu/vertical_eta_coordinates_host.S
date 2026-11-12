// Complete vertical eta setup. Contract: skills/md2fort-gpu/references/openifs/setup/vertical_eta_coordinates.md.
#include "../../support/gpu/preserved_weather_calls.inc.S"
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_vertical_eta_coordinates
.type md2asm_initialize_vertical_eta_coordinates,%function
md2asm_initialize_vertical_eta_coordinates:
 cbz x0,.Leta_reject
 cbz x1,.Leta_reject
 cbz x2,.Leta_reject
 orr x9,x0,x1
 orr x9,x9,x2
 tst x9,#7
 b.ne .Leta_reject
 mrs x9,fpcr
 cbnz x9,.Leta_reject
 ldr x9,[x1]
 tbnz x9,#63,.Leta_reject
 cbz x9,.Leta_reject
 ubfx x10,x9,#52,#11
 cmp x10,#2047
 b.eq .Leta_reject
 ldr x9,[x1,#8]
 ldr x10,.Leta_pi
 cmp x9,x10
 b.ne .Leta_reject
 ldp x9,x10,[x2]
 cbz x9,.Leta_reject
 cbz x10,.Leta_reject
 cmp x9,x10
 b.eq .Leta_reject
 orr x9,x9,x10
 tst x9,#7
 b.ne .Leta_reject
 adr x9,.Leta_associations
 mov x10,#0
.Leta_associated:
 ldp w11,w12,[x9],#8
 ldr x13,[x0,w11,uxtw]
 add x14,x0,w12,uxtw
 cmp x13,x14
 b.ne .Leta_reject
 add x10,x10,#1
 cmp x10,#4
 b.lo .Leta_associated
 adr x9,.Leta_controls
 mov x10,#0
.Leta_control_check:
 ldp w11,w12,[x9],#8
 ldr w13,[x0,w11,uxtw]
 cmp w13,w12
 b.ne .Leta_reject
 add x10,x10,#1
 cmp x10,#11
 b.lo .Leta_control_check
 ldr x9,[x0,#3152]
 cbnz x9,.Leta_reject
 ldr x9,[x0,#3160]
 mov x10,#0x3fe0000000000000
 cmp x9,x10
 b.ne .Leta_reject
 adr x9,.Leta_array_bounds
 mov x10,#0
.Leta_descriptor_check:
 ldr x11,[x9]
 add x11,x0,x11
 ldr x12,[x11]
 cbz x12,.Leta_reject
 tst x12,#7
 b.ne .Leta_reject
 ldr x12,[x11,#16]
 cmp x12,#8
 b.ne .Leta_reject
 ldr x12,[x11,#24]
 mov x13,#0x30100000000
 cmp x12,x13
 b.ne .Leta_reject
 ldr x12,[x11,#32]
 cmp x12,#8
 b.ne .Leta_reject
 ldr x12,[x11,#40]
 cmp x12,#1
 b.ne .Leta_reject
 ldp x12,x13,[x11,#48]
 ldp x14,x15,[x9,#8]
 cmp x12,x14
 b.ne .Leta_reject
 cmp x13,x15
 b.ne .Leta_reject
 ldr x13,[x11,#8]
 add x13,x13,x12
 cbnz x13,.Leta_reject
 add x9,x9,#24
 add x10,x10,#1
 cmp x10,#9
 b.lo .Leta_descriptor_check
 sub sp,sp,#320
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x18,[sp,#64]
 stp d8,d9,[sp,#80]
 stp d10,d11,[sp,#96]
 stp d12,d13,[sp,#112]
 stp d14,d15,[sp,#128]
 mov x19,x0
 ldp d8,d9,[x1]
 mov x25,x2
 ldr d10,[x19,#3152]
 ldr d11,[x19,#3160]
 // Complete numerical eta span; original guards and epilogue remain.
 bl md2asm_vertical_eta_coordinates_gpu_phase
 mov w0,#0
 ldp d8,d9,[sp,#80]
 ldp d10,d11,[sp,#96]
 ldp d12,d13,[sp,#112]
 ldp d14,d15,[sp,#128]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x18,[sp,#64]
 ldp x29,x30,[sp]
 add sp,sp,#320
 ret
.Leta_reject:
 mov w0,#2
 ret
.size md2asm_initialize_vertical_eta_coordinates,.-md2asm_initialize_vertical_eta_coordinates
.p2align 3
.Leta_pi: .quad 0x400921fb54442d18
.Leta_associations:
 .word 3240,16,3248,528,3256,848,3264,3024
.Leta_controls:
 .word 5224,19,5252,19,3040,0,3044,0,3076,1,3132,1
 .word 3136,0,3180,0,3056,4,3068,17,8,0
.Leta_array_bounds:
 .quad 16,0,19,144,0,19,80,0,19
 .quad 528,0,19,656,0,20,592,0,19,720,0,20
 .quad 784,1,19,848,1,17
.section .note.GNU-stack,"",%progbits
