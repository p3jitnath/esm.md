// Contract: skills/md2asm/references/openifs/radiation/runtime_shortwave_aerosol_extinction.md.
// Original eight by-address arguments, then context16 at incoming stack0.
// Context word0 is unread. Word8 points to the false-hook policy16.
// Status0 completes; status2 refuses before an output store. No external calls.
.arch armv8.2-a
.text
.p2align 4
.global md2asm_runtime_shortwave_aerosol_extinction
.type md2asm_runtime_shortwave_aerosol_extinction,%function
md2asm_runtime_shortwave_aerosol_extinction:
 mov x17,sp
 sub sp,sp,#512
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 add x19,sp,#128
 stp x0,x1,[x19]
 stp x2,x3,[x19,#16]
 stp x4,x5,[x19,#32]
 stp x6,x7,[x19,#48]
 ldr x8,[x17]
 str x8,[x19,#64]
 str wzr,[sp,#208]
 mrs x9,fpcr
 cbnz x9,.Lsw_bad
 // Validate all scalar, configuration and policy spans before reading them.
 mov x1,#4
 mov x2,#3
 bl .Lsw_span
 cbnz w0,.Lsw_bad
 ldr x0,[x19,#8]
 mov x1,#4
 mov x2,#3
 bl .Lsw_span
 cbnz w0,.Lsw_bad
 ldr x0,[x19,#16]
 mov x1,#4
 mov x2,#3
 bl .Lsw_span
 cbnz w0,.Lsw_bad
 ldr x0,[x19,#24]
 mov x1,#20040
 mov x2,#7
 bl .Lsw_span
 cbnz w0,.Lsw_bad
 ldr x0,[x19,#32]
 mov x1,#4
 mov x2,#3
 bl .Lsw_span
 cbnz w0,.Lsw_bad
 ldr x0,[x19,#64]
 mov x1,#16
 mov x2,#7
 bl .Lsw_span
 cbnz w0,.Lsw_bad
 ldr x9,[x19,#64]
 ldr x0,[x9,#8]
 mov x1,#16
 mov x2,#7
 bl .Lsw_span
 cbnz w0,.Lsw_bad
 ldr x9,[x19,#64]
 ldr x9,[x9,#8]
 ldr x10,[x9,#8]
 cbnz x10,.Lsw_bad
 ldr x0,[x9]
 mov x1,#4
 mov x2,#3
 bl .Lsw_span
 cbnz w0,.Lsw_bad
 ldr x9,[x19,#64]
 ldr x9,[x9,#8]
 ldr x9,[x9]
 ldr w9,[x9]
 cbnz w9,.Lsw_bad
 ldr x9,[x19]
 ldr w25,[x9]
 cmp w25,#1
 b.lt .Lsw_bad
 cmp w25,#128
 b.gt .Lsw_bad
 ldr x9,[x19,#8]
 ldr w20,[x9]
 ldr x9,[x19,#16]
 ldr w21,[x9]
 cmp w20,#1
 b.lt .Lsw_bad
 add w9,w25,#1
 cmp w20,w9
 b.gt .Lsw_bad
 cmp w21,#0
 b.lt .Lsw_bad
 cmp w21,w25
 b.gt .Lsw_bad
 sub w9,w20,#1
 cmp w21,w9
 b.lt .Lsw_bad
 ldr x9,[x19,#32]
 ldr w9,[x9]
 cmp w9,#10
 b.ne .Lsw_bad
 ldr x22,[x19,#24]
 mov x10,#6912
 ldr w9,[x22,x10]
 cmp w9,#12
 b.ne .Lsw_bad
 mov x10,#17800
 ldr w9,[x22,x10]
 cmp w9,#12
 b.ne .Lsw_bad
 ldr w9,[x22,x10,lsl#0]
 add x10,x10,#4
 ldr w9,[x22,x10]
 cmp w9,#18
 b.ne .Lsw_bad
 add x10,x10,#4
 ldr w9,[x22,x10]
 cmp w9,#13
 b.ne .Lsw_bad
 add x10,x10,#4
 ldr w9,[x22,x10]
 cmp w9,#12
 b.ne .Lsw_bad
 add x10,x10,#8
 ldr w9,[x22,x10]
 cmp w9,#14
 b.ne .Lsw_bad
 add x10,x10,#8
 ldr w9,[x22,x10]
 cmp w9,#1
 b.ne .Lsw_bad
 mov x10,#20004
 ldr w9,[x22,x10]
 cmp w9,#14
 b.ne .Lsw_bad
 // Undefined classes are checked even when the column interval is empty.
 mov x0,#11608
 add x0,x22,x0
 mov w1,#1
 mov x2,#4
 mov w3,#12
 mov w4,#0
 mov w5,#0
 mov w6,#1
 bl .Lsw_descriptor
 cbz x0,.Lsw_bad
 mov x23,x0
 mov x1,#48
 mov x2,#3
 bl .Lsw_span
 cbnz w0,.Lsw_bad
 mov w26,#0
 mov w9,#0
.Lsw_class:
 ldr w10,[x23,w9,uxtw#2]
 cmp w10,#1
 b.lt .Lsw_bad
 cmp w10,#3
 b.gt .Lsw_bad
 cmp w10,#2
 b.ne .Lsw_not_phobic
 orr w26,w26,#1
.Lsw_not_phobic:
 cmp w10,#3
 b.ne .Lsw_class_next
 orr w26,w26,#2
.Lsw_class_next:
 add w9,w9,#1
 cmp w9,#12
 b.lo .Lsw_class
 cmp w20,w21
 b.gt .Lsw_success
 str w26,[sp,#212]
 // The complete input spans use the live column count P.
 ldr x0,[x19,#40]
 mov x1,#96
 umull x1,w25,w1
 mov x2,#7
 bl .Lsw_span
 cbnz w0,.Lsw_bad
 ldr x0,[x19,#48]
 uxtw x1,w25
 lsl x1,x1,#3
 mov x2,#7
 bl .Lsw_span
 cbnz w0,.Lsw_bad
 mov x24,#0
 mov x27,#0
 mov x28,#0
 cbz w26,.Lsw_indices_ready
 mov x0,#11672
 add x0,x22,x0
 mov w1,#1
 mov x2,#4
 mov w3,#12
 mov w4,#0
 mov w5,#0
 mov w6,#1
 bl .Lsw_descriptor
 cbz x0,.Lsw_bad
 mov x24,x0
 mov x1,#48
 mov x2,#3
 bl .Lsw_span
 cbnz w0,.Lsw_bad
 mov w9,#0
.Lsw_type:
 ldr w10,[x23,w9,uxtw#2]
 cmp w10,#1
 b.eq .Lsw_type_next
 ldr w11,[x24,w9,uxtw#2]
 cmp w11,#1
 b.lt .Lsw_bad
 mov w12,#18
 mov w13,#13
 cmp w10,#2
 csel w12,w12,w13,eq
 cmp w11,w12
 b.gt .Lsw_bad
.Lsw_type_next:
 add w9,w9,#1
 cmp w9,#12
 b.lo .Lsw_type
.Lsw_indices_ready:
 ldr w26,[sp,#212]
 tbz w26,#0,.Lsw_phobic_ready
 mov x0,#11736
 add x0,x22,x0
 mov w1,#2
 mov x2,#8
 mov w3,#14
 mov w4,#18
 mov w5,#0
 mov w6,#3
 bl .Lsw_descriptor
 cbz x0,.Lsw_bad
 mov x27,x0
 mov x1,#2016
 mov x2,#7
 bl .Lsw_span
 cbnz w0,.Lsw_bad
.Lsw_phobic_ready:
 ldr w26,[sp,#212]
 tbz w26,#1,.Lsw_philic_ready
 mov x0,#12264
 add x0,x22,x0
 mov w1,#3
 mov x2,#8
 mov w3,#14
 mov w4,#12
 mov w5,#13
 mov w6,#3
 bl .Lsw_descriptor
 cbz x0,.Lsw_bad
 mov x28,x0
 mov x1,#17472
 mov x2,#7
 bl .Lsw_span
 cbnz w0,.Lsw_bad
.Lsw_philic_ready:
 mov x0,#13736
 add x0,x22,x0
 mov w1,#1
 mov x2,#8
 mov w3,#12
 mov w4,#0
 mov w5,#0
 mov w6,#3
 bl .Lsw_descriptor
 cbz x0,.Lsw_bad
 str x0,[sp,#224]
 mov x1,#96
 mov x2,#7
 bl .Lsw_span
 cbnz w0,.Lsw_bad
 // Validate the finite humidity thresholds without changing FPSR.
 ldr x10,[sp,#224]
 ldr x9,[x10]
 cbnz x9,.Lsw_bad
 fmov d1,xzr
 fmov d2,#1.0
 mov w11,#1
.Lsw_threshold:
 ldr x9,[x10,w11,uxtw#3]
 ubfx x12,x9,#52,#11
 cmp x12,#2047
 b.eq .Lsw_bad
 fmov d0,x9
 fcmp d0,d1
 b.ls .Lsw_bad
 fcmp d0,d2
 b.gt .Lsw_bad
 fmov d1,d0
 add w11,w11,#1
 cmp w11,#12
 b.lo .Lsw_threshold
 // Refuse overlap with every consumed complete input or metadata span.
 ldr x7,[x19,#56]
 cbz x7,.Lsw_bad
 tst x7,#7
 b.ne .Lsw_bad
 uxtw x8,w25
 lsl x8,x8,#3
 adds x8,x7,x8
 b.cs .Lsw_bad
 ldr w9,[sp,#208]
 add x10,sp,#256
.Lsw_output_disjoint:
 ldp x11,x12,[x10],#16
 cmp x8,x11
 b.ls .Lsw_output_next
 cmp x12,x7
 b.hi .Lsw_bad
.Lsw_output_next:
 subs w9,w9,#1
 b.ne .Lsw_output_disjoint
 sub w20,w20,#1
.Lsw_column:
ldr x9,[x19,#48]
ldr d0,[x9,w20,uxtw #3]
ldr x9,[sp,#224]
ldr d1,[x9,#88]
cmp w20,w20
mov w26,#12
fcmpe d0,d1
b.gt .Lsw_humidity_ready
mov w26,#1
.Lsw_humidity_bin:
ldr d1,[x9,w26,uxtw #3]
fcmpe d0,d1
b.le .Lsw_humidity_ready
b.vs .Lsw_humidity_ready
add w26,w26,#1
b .Lsw_humidity_bin
.Lsw_humidity_ready:
sub w26,w26,#1
fmov d2,xzr
mov w10,#0
.Lsw_species:
ldr w11,[x23,w10,uxtw #2]
cmp w11,#2
b.eq .Lsw_phobic
cmp w11,#3
b.ne .Lsw_next_species
ldr w12,[x24,w10,uxtw #2]
sub w12,w12,#1
mov w13,#168
mul w12,w12,w13
mov w13,#14
madd w12,w26,w13,w12
add w12,w12,#9
ldr d1,[x28,w12,uxtw #3]
b .Lsw_species_value
.Lsw_phobic:
ldr w12,[x24,w10,uxtw #2]
sub w12,w12,#1
mov w13,#14
mul w12,w12,w13
add w12,w12,#9
ldr d1,[x27,w12,uxtw #3]
.Lsw_species_value:
ldr x9,[x19,#40]
madd w12,w10,w25,w20
ldr d0,[x9,w12,uxtw #3]
fmul d0,d0,d1
fadd d2,d2,d0
.Lsw_next_species:
add w10,w10,#1
cmp w10,#12
b.lt .Lsw_species
ldr x9,[x19,#56]
str d2,[x9,w20,uxtw #3]
add w20,w20,#1
cmp w20,w21
b.lt .Lsw_column

.Lsw_done:
.Lsw_success:
 mov w0,#0
 b .Lsw_return
.Lsw_bad:
 mov w0,#2
.Lsw_return:
 ldr x18,[sp,#96]
 ldp x27,x28,[sp,#80]
 ldp x25,x26,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#512
 ret
// Add one complete consumed span. x0 is its start, x1 its bytes and x2
// its alignment mask. A bounded private table retains starts and ends.
.Lsw_span:
 cbz x0,.Lsw_span_bad
 tst x0,x2
 b.ne .Lsw_span_bad
 cbz x1,.Lsw_span_bad
 adds x9,x0,x1
 b.cs .Lsw_span_bad
 ldr w10,[sp,#208]
 cmp w10,#16
 b.hs .Lsw_span_bad
 add x11,sp,#256
 add x11,x11,w10,uxtw#4
 stp x0,x9,[x11]
 add w10,w10,#1
 str w10,[sp,#208]
 mov w0,#0
 ret
.Lsw_span_bad:
 mov w0,#2
 ret
// Validate a complete allocated GNU descriptor with known physical extents.
// x0 is the header; w1 rank; x2 element bytes; w3..w5 extents; w6 kind.
// Return the logical first-element pointer, or zero on metadata refusal.
.Lsw_descriptor:
 ldr x7,[x0]
 cbz x7,.Lsw_descriptor_bad
 sub x8,x2,#1
 tst x7,x8
 b.ne .Lsw_descriptor_bad
 ldr x8,[x0,#16]
 cmp x8,x2
 b.ne .Lsw_descriptor_bad
 ldr x8,[x0,#32]
 cmp x8,x2
 b.ne .Lsw_descriptor_bad
 ldrb w8,[x0,#28]
 cmp w8,w1
 b.ne .Lsw_descriptor_bad
 ldrb w8,[x0,#29]
 cmp w8,w6
 b.ne .Lsw_descriptor_bad
 add x9,x0,#40
 mov w10,#0
 mov x11,#1
 mov x12,#0
.Lsw_descriptor_axis:
 cmp w10,#0
 csel w13,w3,w4,eq
 cmp w10,#2
 csel w13,w5,w13,eq
 ldp x14,x15,[x9]
 ldr x16,[x9,#16]
 cmp x14,x11
 b.ne .Lsw_descriptor_bad
 cmp x15,#1
 b.ne .Lsw_descriptor_bad
 cmp x16,x13
 b.ne .Lsw_descriptor_bad
 add x12,x12,x11
 mul x11,x11,x13
 add x9,x9,#24
 add w10,w10,#1
 cmp w10,w1
 b.lo .Lsw_descriptor_axis
 ldr x8,[x0,#8]
 add x8,x8,x12
 cbnz x8,.Lsw_descriptor_bad
 mul x8,x11,x2
 adds x8,x7,x8
 b.cs .Lsw_descriptor_bad
 mov x0,x7
 ret
.Lsw_descriptor_bad:
 mov x0,#0
 ret
.size md2asm_runtime_shortwave_aerosol_extinction,.-md2asm_runtime_shortwave_aerosol_extinction
.section .note.GNU-stack,"",%progbits
