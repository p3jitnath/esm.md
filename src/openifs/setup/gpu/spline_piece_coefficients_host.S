/* Complete selected spline coefficients. Contract: skills/md2fort-gpu/references/openifs/setup/complete_vertical_spline_calls.md.
 * Private frame4352: input320/400B, output768/3296B, context4096/64B,
 * record4160/64B, vector4224/16B, private counters4240/4248.
 */
.arch armv8-a
.text
.p2align 4
.macro piece_service name
 bl \name
 ldr x18,[sp,#96]
.endm
.global md2asm_spline_piece_coefficients
.type md2asm_spline_piece_coefficients,%function
md2asm_spline_piece_coefficients:
cbz x0,.Lpiece_reject
cbz x1,.Lpiece_reject
cbz x2,.Lpiece_reject
cbz x3,.Lpiece_reject
cbz x4,.Lpiece_reject
cbz x5,.Lpiece_reject
cbz x6,.Lpiece_reject
tst x0,#3
b.ne .Lpiece_reject
orr x9,x1,x2
orr x9,x9,x3
orr x9,x9,x4
orr x9,x9,x5
orr x9,x9,x6
tst x9,#7
b.ne .Lpiece_reject
ldp w9,w10,[x0]
cmp w9,#4
b.ne .Lpiece_reject
sub w11,w10,#21
cmp w11,#3
b.hi .Lpiece_reject
ldp w11,w12,[x0,#8]
orr w11,w11,w12
cbnz w11,.Lpiece_reject
ldp x11,x12,[x2]
cbnz x11,.Lpiece_reject
mov x13,#0x3ff0000000000000
cmp x12,x13
b.ne .Lpiece_reject
ldr x11,[x1]
ubfx x12,x11,#52,#11
cmp x12,#2047
b.eq .Lpiece_reject
tbz x11,#63,.Lpiece_guard_done
lsl x12,x11,#1
cbnz x12,.Lpiece_reject
.Lpiece_guard_done:
mov x17,#4352
sub sp,sp,x17
stp x29,x30,[sp]
mov x29,sp
stp x19,x20,[sp,#16]
stp x21,x22,[sp,#32]
stp x23,x24,[sp,#48]
stp x25,x26,[sp,#64]
stp x27,x28,[sp,#80]
str x18,[sp,#96]
str x0,[sp,#112]
str x1,[sp,#120]
str x2,[sp,#128]
str x3,[sp,#136]
str x4,[sp,#144]
str x5,[sp,#152]
str x6,[sp,#160]
str w10,[sp,#4256]
stp d8,d9,[sp,#176]
stp d10,d11,[sp,#192]
stp d12,d13,[sp,#208]
stp d14,d15,[sp,#224]
mrs x8,fpcr
mrs x9,fpsr
stp x8,x9,[sp,#240]
cbnz x8,.Lpiece_runtime_failure
piece_service __errno_location
str x0,[sp,#256]
ldr w8,[x0]
str w8,[sp,#264]
piece_service omp_in_parallel
cbnz w0,.Lpiece_runtime_failure
piece_service md2asm_openifs_gpu_prepare
cbnz w0,.Lpiece_runtime_failure
add x19,sp,#320
mov x17,#4096
add x20,sp,x17
ldr w22,[sp,#4256]
ldr x24,[sp,#152]
ldr x25,[sp,#160]
mov x9,#0
.Lpiece_zero_input:
str xzr,[x19,x9,lsl #3]
add x9,x9,#1
cmp x9,#50
b.lo .Lpiece_zero_input
ldr x10,[sp,#112]
add x11,x19,#0
ldr x12,[x10,#0]
str x12,[x11,#0]
ldr x12,[x10,#8]
str x12,[x11,#8]
ldr x10,[sp,#120]
add x11,x19,#16
ldr x12,[x10,#0]
str x12,[x11,#0]
ldr x10,[sp,#128]
add x11,x19,#24
ldr x12,[x10,#0]
str x12,[x11,#0]
ldr x12,[x10,#8]
str x12,[x11,#8]
ldr x10,[sp,#136]
add x11,x19,#40
ldr x12,[x10,#0]
str x12,[x11,#0]
ldr x12,[x10,#8]
str x12,[x11,#8]
ldr x12,[x10,#16]
str x12,[x11,#16]
ldr x12,[x10,#24]
str x12,[x11,#24]
ldr x12,[x10,#32]
str x12,[x11,#32]
ldr x12,[x10,#40]
str x12,[x11,#40]
ldr x12,[x10,#48]
str x12,[x11,#48]
ldr x12,[x10,#56]
str x12,[x11,#56]
ldr x12,[x10,#64]
str x12,[x11,#64]
ldr x12,[x10,#72]
str x12,[x11,#72]
ldr x12,[x10,#80]
str x12,[x11,#80]
ldr x12,[x10,#88]
str x12,[x11,#88]
ldr x12,[x10,#96]
str x12,[x11,#96]
ldr x12,[x10,#104]
str x12,[x11,#104]
ldr x12,[x10,#112]
str x12,[x11,#112]
ldr x12,[x10,#120]
str x12,[x11,#120]
ldr x10,[sp,#144]
add x11,x19,#168
add w13,w22,#4
mov x9,#0
.Lpiece_copy_knots:
ldr x12,[x10,x9,lsl #3]
str x12,[x11,x9,lsl #3]
add x9,x9,#1
cmp x9,x13
b.lo .Lpiece_copy_knots
add x8,sp,#768
mov x9,#0
.Lpiece_zero_output:
str xzr,[x8,x9,lsl #3]
add x9,x9,#1
cmp x9,#412
b.lo .Lpiece_zero_output
str x19,[sp,#4224]
str x8,[sp,#4232]
str xzr,[sp,#4240]
str xzr,[sp,#4248]
stp xzr,xzr,[x20]
stp xzr,xzr,[x20,#16]
stp xzr,xzr,[x20,#32]
stp xzr,xzr,[x20,#48]
mov w8,#1
str w8,[x20,#4]
ldr w8,[sp,#248]
str w8,[x20,#8]
mov x17,#4160
add x8,sp,x17
str x8,[x20,#48]
mov x9,#64
str x9,[x20,#56]
mov x8,#400
mov x9,#3296
str x8,[sp,#4160]
str x9,[sp,#4168]
str xzr,[sp,#4176]
str xzr,[sp,#4184]
mov x17,#4240
add x8,sp,x17
mov x9,#8
str x8,[sp,#4192]
str x9,[sp,#4200]
mov x17,#4248
add x8,sp,x17
str x8,[sp,#4208]
str x9,[sp,#4216]
ldp x8,x9,[sp,#240]
msr fpcr,x8
msr fpsr,x9
ldr x21,[sp,#256]
ldr w8,[sp,#264]
str w8,[x21]
adrp x0,.Lpiece_entry
add x0,x0,:lo12:.Lpiece_entry
mov x17,#4224
add x1,sp,x17
mov x2,x20
mov w3,#1
mov w4,#1
mov w5,#0
piece_service md2asm_openifs_gpu_launch
cbnz w0,.Lpiece_runtime_failure
ldr w8,[x20]
cbnz w8,.Lpiece_runtime_failure
ldr w8,[sp,#768]
cmp w8,#2
b.eq .Lpiece_no_commit
add x10,sp,#800
lsl x13,x22,#4
mov x9,#0
.Lpiece_copy_coefficients:
ldr x11,[x10,x9,lsl #3]
str x11,[x24,x9,lsl #3]
add x9,x9,#1
cmp x9,x13
b.lo .Lpiece_copy_coefficients
cbnz w8,.Lpiece_no_commit
add x10,sp,#3872
mov x9,#0
.Lpiece_copy_centres:
ldr x11,[x10,x9,lsl #3]
str x11,[x25,x9,lsl #3]
add x9,x9,#1
cmp x9,x22
b.lo .Lpiece_copy_centres
.Lpiece_no_commit:
ldr x8,[sp,#240]
msr fpcr,x8
ldr x9,[sp,#248]
ldr w10,[sp,#4104]
orr x9,x9,x10
msr fpsr,x9
ldr x21,[sp,#256]
ldr w8,[sp,#264]
str w8,[x21]
ldp d8,d9,[sp,#176]
ldp d10,d11,[sp,#192]
ldp d12,d13,[sp,#208]
ldp d14,d15,[sp,#224]
ldp x19,x20,[sp,#16]
ldp x21,x22,[sp,#32]
ldp x23,x24,[sp,#48]
ldp x25,x26,[sp,#64]
ldp x27,x28,[sp,#80]
ldr x18,[sp,#96]
ldp x29,x30,[sp]
ldr w0,[sp,#768]
mov x17,#4352
add sp,sp,x17
ret
.Lpiece_runtime_failure:
bl abort
brk #0
.Lpiece_reject:
mov w0,#2
ret
.size md2asm_spline_piece_coefficients,.-md2asm_spline_piece_coefficients
.section .rodata
.Lpiece_entry:.asciz "md2asm_gpu_coarse_spline_piece_coefficients"
.section .note.GNU-stack,"",%progbits
