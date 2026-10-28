/* Exact IOGRIDE source field order, layer labels and unit scaling.
 * This private child borrows complete buffers and performs no allocation.
 * Contract skills/md2asm/references/openifs/output/runtime_fullpos_file_writers.md.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_select_runtime_physical_output_fields
.type md2asm_select_runtime_physical_output_fields,%function
md2asm_select_runtime_physical_output_fields:
 mrs x9,fpcr
 cbnz x9,.Lphysical_bad_leaf
 cbz x0,.Lphysical_bad_leaf
 cmp w2,#1
 b.lt .Lphysical_bad_leaf
 movz w9,#0xb400
 movk w9,#0x64,lsl#16
 cmp w2,w9
 b.hi .Lphysical_bad_leaf
 sub w9,w3,#1
 cmp w9,#1023
 b.hi .Lphysical_bad_leaf
 ldrsw x9,[x0]
 cmp x9,#1639
 b.hi .Lphysical_bad_leaf
 sub sp,sp,#256
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mov x19,x0
 mov x20,x1
 sxtw x21,w2
 sxtw x22,w3
 mov x23,x4
 mov x24,x5
 mov x25,x6
 mov x26,x7
 mov x27,x9
 ldr x9,[sp,#256]
 str x9,[sp,#112]
 cbz x27,.Lphysical_ok
 cbz x20,.Lphysical_bad
 cbz x23,.Lphysical_bad
 cbz x24,.Lphysical_bad
 cbz x26,.Lphysical_bad
 lsl x10,x27,#3
 cmp x9,x10
 b.lo .Lphysical_bad
 adds x10,x23,x10
 b.cs .Lphysical_bad
 mul x10,x21,x27
 lsl x10,x10,#3
 cmp x25,x10
 b.lo .Lphysical_bad
 adds x10,x24,x10
 b.cs .Lphysical_bad
 ldr x9,[x20]
 cbz x9,.Lphysical_bad
 tst x9,#7
 b.ne .Lphysical_bad
 str x9,[sp,#120]
 ldr x9,[x20,#16]
 cmp x9,#8
 b.ne .Lphysical_bad
 ldrb w9,[x20,#28]
 cmp w9,#3
 b.ne .Lphysical_bad
 ldrb w9,[x20,#29]
 cmp w9,#3
 b.ne .Lphysical_bad
 ldr x9,[x20,#40]
 cmp x9,#1
 b.ne .Lphysical_bad
 ldr x9,[x20,#48]
 cmp x9,#1
 b.ne .Lphysical_bad
 ldr x9,[x20,#56]
 cmp x9,x22
 b.ne .Lphysical_bad
 ldr x9,[x20,#64]
 cmp x9,x22
 b.ne .Lphysical_bad
 ldr x9,[x20,#72]
 cmp x9,#1
 b.ne .Lphysical_bad
 ldr x10,[x20,#80]
 cmp x10,x27
 b.lt .Lphysical_bad
 str x10,[sp,#128]
 umulh x11,x10,x22
 cbnz x11,.Lphysical_bad
 mul x11,x10,x22
 lsr x12,x11,#61
 cbnz x12,.Lphysical_bad
 ldr x12,[x20,#88]
 cmp x12,x11
 b.ne .Lphysical_bad
 lsl x12,x11,#3
 str x12,[sp,#144]
 ldr x12,[x20,#96]
 cmp x12,#1
 b.ne .Lphysical_bad
 add x12,x21,x22
 sub x12,x12,#1
 udiv x12,x12,x22
 ldr x13,[x20,#104]
 cmp x13,x12
 b.ne .Lphysical_bad
 str x12,[sp,#136]
 umulh x13,x11,x12
 cbnz x13,.Lphysical_bad
 mul x13,x11,x12
 lsr x14,x13,#61
 cbnz x14,.Lphysical_bad
 ldr x14,[sp,#120]
 adds x14,x14,x13,lsl#3
 b.cs .Lphysical_bad
 add x11,x11,x22
 add x11,x11,#1
 neg x11,x11
 ldr x12,[x20,#8]
 cmp x12,x11
 b.ne .Lphysical_bad
 add x9,x19,#72
 ldr x10,[x9]
 cbz x10,.Lphysical_bad
 str x10,[sp,#152]
 ldr x10,[x9,#8]
 cmn x10,#1
 b.ne .Lphysical_bad
 ldr x10,[x9,#16]
 cmp x10,#4
 b.ne .Lphysical_bad
 ldrb w10,[x9,#28]
 cmp w10,#1
 b.ne .Lphysical_bad
 ldrb w10,[x9,#29]
 cmp w10,#1
 b.ne .Lphysical_bad
 ldr x10,[x9,#40]
 cmp x10,#1
 b.ne .Lphysical_bad
 ldr x10,[x9,#48]
 cmp x10,#1
 b.ne .Lphysical_bad
 ldr x10,[x9,#56]
 cmp x10,x27
 b.lt .Lphysical_bad
 ldr x9,[x26]
 cbz x9,.Lphysical_bad
 tbnz x9,#63,.Lphysical_bad
 and x10,x9,#0x7ff0000000000000
 movz x11,#0x7ff0,lsl#48
 cmp x10,x11
 b.eq .Lphysical_bad
 ldr x9,[x26,#8]
 cbz x9,.Lphysical_bad
 tbnz x9,#63,.Lphysical_bad
 and x10,x9,#0x7ff0000000000000
 cmp x10,x11
 b.eq .Lphysical_bad
 stp xzr,xzr,[sp,#160]
 str xzr,[sp,#176]
 mov x28,#0
.Lphysical_field:
 ldr x9,[sp,#152]
 ldr w10,[x9,x28,lsl#2]
 str w10,[sp,#192]
 mov w11,#0
 adrp x9,.Lphysical_layer_codes
 add x9,x9,:lo12:.Lphysical_layer_codes
 mov x12,#0
.Lphysical_layer:
 ldr w13,[x9,x12,lsl#2]
 cmp w13,w10
 b.ne .Lphysical_layer_next
 add x13,sp,#160
 ldr w11,[x13,x12,lsl#2]
 cmp x12,#4
 b.hs .Lphysical_zero_layer
 add w11,w11,#1
 str w11,[x13,x12,lsl#2]
 b .Lphysical_layer_done
.Lphysical_zero_layer:
 add w14,w11,#1
 str w14,[x13,x12,lsl#2]
 b .Lphysical_layer_done
.Lphysical_layer_next:
 add x12,x12,#1
 cmp x12,#6
 b.ne .Lphysical_layer
.Lphysical_layer_done:
 add x9,x23,x28,lsl#3
 stp w10,w11,[x9]
 str x24,[sp,#184]
 ldr x9,[sp,#120]
 mul x10,x28,x22
 add x9,x9,x10,lsl#3
 mov x10,#0
 mov x11,x21
.Lphysical_block:
 mov x12,x22
 cmp x11,x22
 csel x12,x11,x22,lo
 mov x13,x9
 mov x14,x12
.Lphysical_point:
 ldr x15,[x13],#8
 str x15,[x24],#8
 subs x14,x14,#1
 b.ne .Lphysical_point
 sub x11,x11,x12
 cbz x11,.Lphysical_scale
 ldr x12,[sp,#144]
 add x9,x9,x12
 add x10,x10,#1
 b .Lphysical_block
.Lphysical_scale:
 fmov d0,#1.0
 ldr w10,[sp,#192]
 adrp x9,.Lphysical_water_codes
 add x9,x9,:lo12:.Lphysical_water_codes
 mov x11,#0
.Lphysical_water_lookup:
 ldr w12,[x9,x11,lsl#2]
 cmp w12,w10
 b.eq .Lphysical_water_scale
 add x11,x11,#1
 cmp x11,#14
 b.ne .Lphysical_water_lookup
 adrp x9,.Lphysical_gravity_codes
 add x9,x9,:lo12:.Lphysical_gravity_codes
 mov x11,#0
.Lphysical_gravity_lookup:
 ldr w12,[x9,x11,lsl#2]
 cmp w12,w10
 b.eq .Lphysical_gravity_scale
 add x11,x11,#1
 cmp x11,#3
 b.ne .Lphysical_gravity_lookup
 b .Lphysical_scale_compare
.Lphysical_water_scale:
 ldr d1,[x26,#8]
 fdiv d0,d0,d1
 b .Lphysical_scale_compare
.Lphysical_gravity_scale:
 ldr d1,[x26]
 fdiv d0,d0,d1
.Lphysical_scale_compare:
 fmov d1,#1.0
 fcmp d0,d1
 b.eq .Lphysical_next_field
 ldr x9,[sp,#184]
 mov x10,x21
.Lphysical_multiply:
 ldr d1,[x9]
 fmul d1,d1,d0
 str d1,[x9],#8
 subs x10,x10,#1
 b.ne .Lphysical_multiply
.Lphysical_next_field:
 add x28,x28,#1
 cmp x28,x27
 b.ne .Lphysical_field
.Lphysical_ok:
 mov w0,#0
 b .Lphysical_restore
.Lphysical_bad:
 mov w0,#2
.Lphysical_restore:
 ldr x18,[sp,#96]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp]
 add sp,sp,#256
 ret
.Lphysical_bad_leaf:
 mov w0,#2
 ret
.size md2asm_select_runtime_physical_output_fields,.-md2asm_select_runtime_physical_output_fields
.section .rodata
.p2align 2
.Lphysical_layer_codes:
 .word 260510,260511,228141,228038,33,238
.Lphysical_water_codes:
 .word 141,142,143,228,144,228216,182,228251,198,205,9,8,239,240
.Lphysical_gravity_codes:
 .word 173,244,160
.section .note.GNU-stack,"",%progbits
