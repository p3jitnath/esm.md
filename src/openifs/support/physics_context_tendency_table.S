// Solver contract skills/md2asm/references/openifs/support/physics_context_block_services.md.
// Contract: skills/md2asm/references/openifs/support/physics_context_block_services.md. Integer address service only.
.arch armv8.2-a
.text
.p2align 4
.global md2asm_physics_driver_tendency_table
.type md2asm_physics_driver_tendency_table,%function
md2asm_physics_driver_tendency_table:
 adrp x15,md2asm_block_context_native_counters
 add x15,x15,:lo12:md2asm_block_context_native_counters
 ldr x17,[x15,#24]
 add x17,x17,#1
 str x17,[x15,#24]
 ldr x6,[x0]
 ldr x7,[x0,#40]
 ldr x8,[x0,#24]
 ldr w9,[x2]
 sub w9,w9,#1
 ldr w10,[x6,#5144]
 ldr w11,[x6,#5224]
 mul x12,x10,x11
 cbnz w4,.Ltendency_other
 str x6,[x5,#0]
 movz x16,#192
 add x13,x7,x16
 str x13,[x5,#8]
 adrp x13,.Ltendency_one
 add x13,x13,:lo12:.Ltendency_one
 str x13,[x5,#16]
 str x3,[x5,#24]
 movz x16,#21248
 movk x16,#63,lsl #16
 add x13,x7,x16
 str x13,[x5,#32]
 ldr x13,[x0,#128]
 movz x16,#1360
 ldr w14,[x8,x16]
 mul x14,x14,x9
 movz x16,#1368
 ldr w15,[x8,x16]
 sub w15,w15,#1
 add x14,x14,x15
 mul x14,x14,x12
 add x13,x13,x14,lsl #3
 str x13,[x5,#40]
 ldr x13,[x0,#128]
 movz x16,#1360
 ldr w14,[x8,x16]
 mul x14,x14,x9
 movz x16,#1372
 ldr w15,[x8,x16]
 sub w15,w15,#1
 add x14,x14,x15
 mul x14,x14,x12
 add x13,x13,x14,lsl #3
 str x13,[x5,#48]
 ldr x13,[x0,#128]
 movz x16,#1360
 ldr w14,[x8,x16]
 mul x14,x14,x9
 movz x16,#1376
 ldr w15,[x8,x16]
 sub w15,w15,#1
 add x14,x14,x15
 mul x14,x14,x12
 add x13,x13,x14,lsl #3
 str x13,[x5,#56]
 ldr x13,[x0,#144]
 movz x16,#256
 ldr w14,[x7,x16]
 mul x14,x14,x9
 mul x14,x14,x12
 add x13,x13,x14,lsl #3
 str x13,[x5,#64]
 ldr x13,[x0,#112]
 movz x16,#992
 ldr w14,[x8,x16]
 mul x14,x14,x9
 movz x16,#1404
 ldr w15,[x8,x16]
 sub w15,w15,#1
 add x14,x14,x15
 mul x14,x14,x12
 add x13,x13,x14,lsl #3
 str x13,[x5,#72]
 ldr x13,[x0,#112]
 movz x16,#992
 ldr w14,[x8,x16]
 mul x14,x14,x9
 movz x16,#1408
 ldr w15,[x8,x16]
 sub w15,w15,#1
 add x14,x14,x15
 mul x14,x14,x12
 add x13,x13,x14,lsl #3
 str x13,[x5,#80]
 ldr x13,[x0,#112]
 movz x16,#992
 ldr w14,[x8,x16]
 mul x14,x14,x9
 movz x16,#1412
 ldr w15,[x8,x16]
 sub w15,w15,#1
 add x14,x14,x15
 mul x14,x14,x12
 add x13,x13,x14,lsl #3
 str x13,[x5,#88]
 ldr x13,[x0,#160]
 movz x16,#240
 ldr w14,[x7,x16]
 mul x14,x14,x9
 mul x14,x14,x12
 add x13,x13,x14,lsl #3
 str x13,[x5,#96]
 ldr x13,[x1,#0]
 movz x16,#256
 ldr w14,[x7,x16]
 mul x14,x14,x9
 mul x14,x14,x12
 add x13,x13,x14,lsl #3
 str x13,[x5,#104]
 ret
.Ltendency_other:
 movz x16,#5736
 movk x16,#24,lsl #16
 add x13,x7,x16
 str x13,[x5,#0]
 movz x16,#192
 add x13,x7,x16
 str x13,[x5,#8]
 movz x16,#5144
 add x13,x6,x16
 str x13,[x5,#16]
 adrp x13,.Ltendency_one
 add x13,x13,:lo12:.Ltendency_one
 str x13,[x5,#24]
 str x3,[x5,#32]
 movz x16,#5224
 add x13,x6,x16
 str x13,[x5,#40]
 movz x16,#21248
 movk x16,#63,lsl #16
 add x13,x7,x16
 str x13,[x5,#48]
 movz x16,#61888
 movk x16,#23,lsl #16
 add x13,x7,x16
 str x13,[x5,#56]
 ldr x13,[x0,#112]
 movz x16,#992
 ldr w14,[x8,x16]
 mul x14,x14,x9
 movz x16,#1404
 ldr w15,[x8,x16]
 sub w15,w15,#1
 add x14,x14,x15
 mul x14,x14,x12
 add x13,x13,x14,lsl #3
 str x13,[x5,#64]
 ldr x13,[x0,#112]
 movz x16,#992
 ldr w14,[x8,x16]
 mul x14,x14,x9
 movz x16,#1408
 ldr w15,[x8,x16]
 sub w15,w15,#1
 add x14,x14,x15
 mul x14,x14,x12
 add x13,x13,x14,lsl #3
 str x13,[x5,#72]
 ldr x13,[x0,#112]
 movz x16,#992
 ldr w14,[x8,x16]
 mul x14,x14,x9
 movz x16,#1412
 ldr w15,[x8,x16]
 sub w15,w15,#1
 add x14,x14,x15
 mul x14,x14,x12
 add x13,x13,x14,lsl #3
 str x13,[x5,#80]
 ldr x13,[x0,#160]
 movz x16,#240
 ldr w14,[x7,x16]
 mul x14,x14,x9
 mul x14,x14,x12
 add x13,x13,x14,lsl #3
 str x13,[x5,#88]
 ldr x13,[x1,#0]
 movz x16,#256
 ldr w14,[x7,x16]
 mul x14,x14,x9
 mul x14,x14,x12
 add x13,x13,x14,lsl #3
 str x13,[x5,#96]
 ldr x13,[x1,#8]
 mov x14,x9
 mul x14,x14,x12
 add x13,x13,x14,lsl #3
 str x13,[x5,#104]
 ldr x13,[x0,#128]
 movz x16,#1360
 ldr w14,[x8,x16]
 mul x14,x14,x9
 movz x16,#1368
 ldr w15,[x8,x16]
 sub w15,w15,#1
 add x14,x14,x15
 mul x14,x14,x12
 add x13,x13,x14,lsl #3
 str x13,[x5,#112]
 ldr x13,[x0,#128]
 movz x16,#1360
 ldr w14,[x8,x16]
 mul x14,x14,x9
 movz x16,#1372
 ldr w15,[x8,x16]
 sub w15,w15,#1
 add x14,x14,x15
 mul x14,x14,x12
 add x13,x13,x14,lsl #3
 str x13,[x5,#120]
 ldr x13,[x0,#128]
 movz x16,#1360
 ldr w14,[x8,x16]
 mul x14,x14,x9
 movz x16,#1376
 ldr w15,[x8,x16]
 sub w15,w15,#1
 add x14,x14,x15
 mul x14,x14,x12
 add x13,x13,x14,lsl #3
 str x13,[x5,#128]
 ldr x13,[x0,#144]
 movz x16,#256
 ldr w14,[x7,x16]
 mul x14,x14,x9
 mul x14,x14,x12
 add x13,x13,x14,lsl #3
 str x13,[x5,#136]
 ret
.size md2asm_physics_driver_tendency_table,.-md2asm_physics_driver_tendency_table
.data
.p2align 2
.Ltendency_one:
 .word 1
.section .note.GNU-stack,"",%progbits
