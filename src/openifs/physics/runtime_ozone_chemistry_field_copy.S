/* Original GPINO3CH runtime interface.
 * Contract skills/md2asm/references/openifs/physics/runtime_ozone_chemistry_field_copy.md.
 * Direct assembly with live dimensions and unchanged accepted arithmetic. */
/* Runtime GPINO3CH copy. See the runtime ozone chemistry field-copy contract.
 * x0 G20400,x1 MODEL4275088,x2 controls16,x3 lat int32[P],x4 out,x5bytes.
 * Live P/L/monthly table dimensions. Selected seven-coefficient physics.
 * Return0 success or2 atomic refusal. No FP, call or allocation. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_copy_runtime_ozone_chemistry_fields
.type md2asm_copy_runtime_ozone_chemistry_fields,%function
md2asm_copy_runtime_ozone_chemistry_fields:
 cbz x0,.Lcopy_bad
 cbz x1,.Lcopy_bad
 cbz x2,.Lcopy_bad
 cbz x3,.Lcopy_bad
 cbz x4,.Lcopy_bad
 orr x6,x0,x1
 orr x6,x6,x2
 orr x6,x6,x4
 tst x6,#7
 b.ne .Lcopy_bad
 tst x3,#3
 b.ne .Lcopy_bad
 ldr w14,[x0,#5144]
 sub w6,w14,#1
 cmp w6,#1023
 b.hi .Lcopy_bad
 ldr w15,[x0,#5224]
 sub w6,w15,#1
 cmp w6,#511
 b.hi .Lcopy_bad
 mov x13,#7
 mul x13,x15,x13
 mul x6,x13,x14
 lsl x6,x6,#3
 cmp x5,x6
 b.lo .Lcopy_bad
 adds x5,x4,x6
 b.cs .Lcopy_bad
 ldp w6,w7,[x2]
 ldr w8,[x2,#8]
 cmp w8,w14
 b.ne .Lcopy_bad
 ldr w8,[x2,#12]
 cbnz w8,.Lcopy_bad
 cmp w6,#1
 b.lt .Lcopy_bad
 add w8,w14,#1
 cmp w6,w8
 b.gt .Lcopy_bad
 sub w8,w6,#1
 cmp w7,w8
 b.lt .Lcopy_bad
 cmp w7,w14
 b.gt .Lcopy_bad
 mov x8,#4564
 movk x8,#24,lsl#16
 ldr w9,[x1,x8]
 cmp w9,#7
 b.ne .Lcopy_bad
 add x8,x8,#8
 ldr w9,[x1,x8]
 cmp w9,#1
 b.ne .Lcopy_bad
 add x8,x8,#4
 ldr w9,[x1,x8]
 cbnz w9,.Lcopy_bad
 mov x8,#25352
 movk x8,#64,lsl#16
 add x8,x1,x8
 ldr x9,[x8]
 cbz x9,.Lcopy_bad
 tst x9,#7
 b.ne .Lcopy_bad
 ldr x10,[x8,#16]
 cmp x10,#8
 b.ne .Lcopy_bad
 ldr x10,[x8,#24]
 ldr x11,=0x0000030200000000
 cmp x10,x11
 b.ne .Lcopy_bad
 ldr x10,[x8,#32]
 cmp x10,#8
 b.ne .Lcopy_bad
 ldr x10,[x8,#40]
 cmp x10,#1
 b.ne .Lcopy_bad
 ldp x10,x11,[x8,#48]
 cmp x10,#1
 b.ne .Lcopy_bad
 cmp x11,x13
 b.ne .Lcopy_bad
 ldr x10,[x8,#64]
 cmp x10,x13
 b.ne .Lcopy_bad
 ldp x10,x16,[x8,#72]
 cmn x10,#1
 b.ne .Lcopy_bad
 sub x16,x16,#2
 sub x10,x16,#1
 mov x11,#65535
 cmp x10,x11
 b.hi .Lcopy_bad
 ldr x10,[x8,#8]
 sub x11,x13,#1
 cmp x10,x11
 b.ne .Lcopy_bad
 /* Reject output overlap with all complete borrowed owners. */
 add x10,x16,#4
 mul x10,x10,x13
 lsl x10,x10,#3
 adds x11,x9,x10
 b.cs .Lcopy_bad
 cmp x4,x11
 b.hs .Lcopy_owner_clear
 cmp x9,x5
 b.lo .Lcopy_bad
.Lcopy_owner_clear:
 mov x10,#20400
 adds x11,x0,x10
 b.cs .Lcopy_bad
 cmp x4,x11
 b.hs .Lcopy_geo_clear
 cmp x0,x5
 b.lo .Lcopy_bad
.Lcopy_geo_clear:
 mov x10,#0x3b90
 movk x10,#0x41,lsl#16
 adds x11,x1,x10
 b.cs .Lcopy_bad
 cmp x4,x11
 b.hs .Lcopy_model_clear
 cmp x1,x5
 b.lo .Lcopy_bad
.Lcopy_model_clear:
 adds x11,x2,#16
 b.cs .Lcopy_bad
 cmp x4,x11
 b.hs .Lcopy_control_clear
 cmp x2,x5
 b.lo .Lcopy_bad
.Lcopy_control_clear:
 lsl x10,x14,#2
 adds x11,x3,x10
 b.cs .Lcopy_bad
 cmp x4,x11
 b.hs .Lcopy_lat_clear
 cmp x3,x5
 b.lo .Lcopy_bad
.Lcopy_lat_clear:
 mov w10,w6
.Lcopy_validate_lat:
 cmp w10,w7
 b.gt .Lcopy_valid
 sub w11,w10,#1
 ldr w12,[x3,w11,uxtw#2]
 sub w12,w12,#1
 cmp w12,w16
 b.hs .Lcopy_bad
 add w10,w10,#1
 b .Lcopy_validate_lat
.Lcopy_valid:
 cmp w6,w7
 b.gt .Lcopy_done
 mov x8,#0
.Lcopy_variable:
 mov w10,w6
.Lcopy_row:
 sub w11,w10,#1
 ldr w12,[x3,w11,uxtw#2]
 add w12,w12,#1
 madd x12,x12,x13,x8
 ldr x12,[x9,x12,lsl#3]
 madd x15,x8,x14,x11
 str x12,[x4,x15,lsl#3]
 add w10,w10,#1
 cmp w10,w7
 b.le .Lcopy_row
 add x8,x8,#1
 cmp x8,x13
 b.lo .Lcopy_variable
.Lcopy_done:
 mov w0,#0
 ret
.Lcopy_bad:
 mov w0,#2
 ret
.size md2asm_copy_runtime_ozone_chemistry_fields,.-md2asm_copy_runtime_ozone_chemistry_fields
.ltorg
.section .note.GNU-stack,"",%progbits
