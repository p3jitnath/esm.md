// Contract: skills/md2asm/references/openifs/output/fullpos_field_metadata_and_file_names.md.
/* SUFPOFNAME and GET_CLINC use the actual source clock and format owner. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_runtime_fullpos_output_file_names
.type md2asm_runtime_fullpos_output_file_names,%function
md2asm_runtime_fullpos_output_file_names:
 mov x17,sp
 sub sp,sp,#768
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 stp x0,x1,[sp,#112]
 stp x2,x3,[sp,#128]
 stp x4,x5,[sp,#144]
 cmp x6,#256
 b.ne .Ln_bad
 cmp x7,#256
 b.ne .Ln_bad
 ldr x9,[x17]
 cmp x9,#256
 b.hi .Ln_bad
 str x9,[sp,#160]
 ldr x9,[x17,#8]
 cbz x9,.Ln_bad
 ldr x10,[x9,#80]
 cbz x10,.Ln_bad
 ldr w10,[x10]
 cbnz w10,.Ln_bad
 ldr x10,[x9,#72]
 cbz x10,.Ln_bad
 ldr w28,[x10,#104]
 cmp w28,#2
 b.hi .Ln_bad
 mrs x9,fpcr
 cbnz x9,.Ln_bad
 mov x19,x0
 mov x20,x1
 cbz x19,.Ln_bad
 cbz x20,.Ln_bad
 ldr x21,[x19]
 ldr x22,[x20]
 cbz x21,.Ln_bad
 cbz x22,.Ln_bad
 ldr x23,[x19,#40]
 ldr x24,[x20,#40]
 cmp x23,#1
 b.lt .Ln_bad
 cmp x24,#1
 b.lt .Ln_bad
 lsl x23,x23,#8
 lsl x24,x24,#8
 ldr x25,[x19,#56]
 sub x9,x25,#1
 cmp x9,#7
 b.hi .Ln_bad
 ldr x10,[x20,#56]
 cmp x10,x25
 b.ne .Ln_bad
 mov x9,#256
 ldr x10,[x19,#16]
 cmp x9,x10
 b.ne .Ln_bad
 ldr x10,[x20,#16]
 cmp x9,x10
 b.ne .Ln_bad
 mov x9,#0x60100000000
 ldr x10,[x19,#24]
 cmp x9,x10
 b.ne .Ln_bad
 ldr x10,[x20,#24]
 cmp x9,x10
 b.ne .Ln_bad
 ldr x9,[x19,#48]
 cmp x9,#1
 b.ne .Ln_bad
 ldr x9,[x20,#48]
 cmp x9,#1
 b.ne .Ln_bad
 /* Build the optional extension length with source trailing-space trimming. */
 ldr x26,[sp,#160]
 cbnz x3,.Ln_extension
 mov x26,#0
.Ln_extension:
 cbz x26,.Ln_digits
 sub x9,x26,#1
 ldrb w10,[x3,x9]
 cmp w10,#32
 b.ne .Ln_digits
 sub x26,x26,#1
 b .Ln_extension
.Ln_digits:
 mov w27,#3
 cbz x4,.Ln_digits_ready
 ldr w27,[x4]
.Ln_digits_ready:
 cbz w27,.Ln_bad
 cmp w27,#0
 cneg w9,w27,lt
 cmp w27,#0
 b.lt .Ln_negative_digit_bound
 cmp w9,#6
 b.hi .Ln_bad
 b .Ln_digit_bound_ready
.Ln_negative_digit_bound:
 cmp w9,#16
 b.hi .Ln_bad
.Ln_digit_bound_ready:
 str w9,[sp,#168]
 add x10,sp,#192
 mov x11,#0x2020202020202020
 stp x11,x11,[x10]
 cbnz x2,.Ln_step
 mov w9,#0x4e49
 movk w9,#0x5449,lsl#16
 str w9,[sp,#192]
 mov x9,#4
 str x9,[sp,#176]
 b .Ln_preflight
.Ln_step:
 ldr w9,[x2]
 tbnz w9,#31,.Ln_bad
 mov w23,w9
 mov w24,#0
 mov w10,#0
 str w10,[sp,#184]
 cmp w27,#0
 b.lt .Ln_make_increment
 cbz x5,.Ln_make_increment
 ldr x10,[x5]
 tbnz x10,#63,.Ln_bad
 cbz x10,.Ln_bad
 ubfx x11,x10,#52,#11
 cmp x11,#2047
 b.eq .Ln_bad
 scvtf d0,w9
 fmov d1,x10
 fmul d0,d0,d1
 adrp x9,.Ln_time_constants
 add x9,x9,:lo12:.Ln_time_constants
 ldr d1,[x9]
 fdiv d2,d0,d1
 ldr d3,[x9,#16]
 fcmp d2,d3
 b.gt .Ln_bad
 cbnz w28,.Ln_minutes
 fcvtas w23,d2
 b .Ln_make_increment
.Ln_minutes:
 fcvtzs w23,d2
 scvtf d2,w23
 fmul d2,d2,d1
 fsub d0,d0,d2
 ldr d1,[x9,#8]
 fdiv d2,d0,d1
 cmp w28,#1
 b.ne .Ln_seconds
 fcvtas w24,d2
 b .Ln_make_increment
.Ln_seconds:
 fcvtzs w24,d2
 scvtf d2,w24
 fmul d2,d2,d1
 fsub d0,d0,d2
 fcvtas w10,d0
 str w10,[sp,#184]
.Ln_make_increment:
 ldr w9,[sp,#168]
 mov x10,#0
 add x11,sp,#192
 cmp w27,#0
 b.lt .Ln_raw_step
 mov w12,#43
 strb w12,[x11],#1
 mov x10,#1
 mov w12,#0x423f
 movk w12,#15,lsl#16
 cmp w23,w12
 cset w15,hi
 b .Ln_decimal_start
.Ln_raw_step:
 mov w15,#0
.Ln_decimal_start:
 mov w12,#10
 mov w13,w23
 mov w14,w9
.Ln_decimal:
 sub w14,w14,#1
 cbnz w15,.Ln_star
 udiv w16,w13,w12
 msub w17,w16,w12,w13
 add w17,w17,#48
 mov w13,w16
 b .Ln_store_digit
.Ln_star:
 mov w17,#42
.Ln_store_digit:
 strb w17,[x11,w14,uxtw]
 cbnz w14,.Ln_decimal
 add x10,x10,x9
 cmp w27,#0
 b.lt .Ln_increment_ready
 cbz w28,.Ln_increment_ready
 add x11,sp,#192
 add x11,x11,x10
 mov w12,#58
 strb w12,[x11]
 mov w12,#10
 udiv w13,w24,w12
 msub w14,w13,w12,w24
 add w13,w13,#48
 add w14,w14,#48
 strb w13,[x11,#1]
 strb w14,[x11,#2]
 add x10,x10,#3
 cmp w28,#2
 b.ne .Ln_increment_ready
 add x11,sp,#192
 add x11,x11,x10
 mov w12,#58
 strb w12,[x11]
 ldr w14,[sp,#184]
 mov w12,#10
 udiv w13,w14,w12
 msub w14,w13,w12,w14
 add w13,w13,#48
 add w14,w14,#48
 strb w13,[x11,#1]
 strb w14,[x11,#2]
 add x10,x10,#3
.Ln_increment_ready:
 str x10,[sp,#176]
.Ln_preflight:
 /* Re-read source strides because the time formatter used volatile scalar copies. */
 ldr x23,[x19,#40]
 ldr x24,[x20,#40]
 lsl x23,x23,#8
 lsl x24,x24,#8
 mov x27,#0
.Ln_check_name:
 madd x9,x27,x23,x21
 mov x10,#256
.Ln_trim_name:
 cbz x10,.Ln_trimmed
 sub x11,x10,#1
 ldrb w12,[x9,x11]
 cmp w12,#32
 b.ne .Ln_trimmed
 sub x10,x10,#1
 b .Ln_trim_name
.Ln_trimmed:
 add x11,sp,#224
 str x10,[x11,x27,lsl#3]
 ldr x11,[sp,#176]
 add x11,x11,x10
 add x11,x11,x26
 cmp x11,#256
 b.hi .Ln_bad
 add x27,x27,#1
 cmp x27,x25
 b.lo .Ln_check_name
 mov x27,#0
.Ln_write_name:
 madd x9,x27,x24,x22
 mov x10,#0x2020202020202020
 mov x11,#32
 mov x12,x9
.Ln_pad:
 str x10,[x12],#8
 subs x11,x11,#1
 b.ne .Ln_pad
 madd x10,x27,x23,x21
 add x11,sp,#224
 ldr x11,[x11,x27,lsl#3]
 mov x12,#0
.Ln_copy_prefix:
 cmp x12,x11
 b.hs .Ln_copy_increment_start
 ldrb w13,[x10,x12]
 strb w13,[x9,x12]
 add x12,x12,#1
 b .Ln_copy_prefix
.Ln_copy_increment_start:
 add x9,x9,x12
 add x10,sp,#192
 ldr x11,[sp,#176]
 mov x12,#0
.Ln_copy_increment:
 cmp x12,x11
 b.hs .Ln_copy_extension_start
 ldrb w13,[x10,x12]
 strb w13,[x9,x12]
 add x12,x12,#1
 b .Ln_copy_increment
.Ln_copy_extension_start:
 add x9,x9,x12
 ldr x10,[sp,#136]
 mov x12,#0
.Ln_copy_extension:
 cmp x12,x26
 b.hs .Ln_next_name
 ldrb w13,[x10,x12]
 strb w13,[x9,x12]
 add x12,x12,#1
 b .Ln_copy_extension
.Ln_next_name:
 add x27,x27,#1
 cmp x27,x25
 b.lo .Ln_write_name
 mov w0,#0
 b .Ln_return
.Ln_bad:
 mov w0,#2
.Ln_return:
 ldr x18,[sp,#96]
 ldp x27,x28,[sp,#80]
 ldp x25,x26,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#768
 ret
.size md2asm_runtime_fullpos_output_file_names,.-md2asm_runtime_fullpos_output_file_names
.section .rodata
.p2align 3
.Ln_time_constants:.double 3600.0,60.0,2147483647.0
.section .note.GNU-stack,"",%progbits
