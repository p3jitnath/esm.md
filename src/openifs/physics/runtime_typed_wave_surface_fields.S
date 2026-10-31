/* Contract: skills/md2asm/references/openifs/physics/typed_wave_surface_fields.md
 * Select source-owned EC_PHYS wave views before numerical mutation.
 * The nine-owner ABI and declared spans are in the frozen contract. */
.arch armv8.2-a
.text
.p2align 4
.macro WV_RANGE reg,bytes
 cbz \reg,.Lwv_bad
 tst \reg,#7
 b.ne .Lwv_bad
 movz x16,#(\bytes&65535)
 movk x16,#((\bytes>>16)&65535),lsl#16
 adds x17,\reg,x16
 b.cs .Lwv_bad
.endm
.macro WV_ADDR reg,base,off
 movz x16,#(\off&65535)
 movk x16,#((\off>>16)&65535),lsl#16
 add \reg,\base,x16
.endm
.macro WV_VIEW row,slot,offset,second
 ldr x0,[sp,#\slot]
 WV_ADDR x0,x0,\offset
 mov x1,\second
 mov x2,x20
 add x3,x19,#(64+16*\row)
 bl .Lwv_descriptor
 cbnz w0,.Lwv_bad
.endm
.macro WV_SURFACE row,handle,descriptor
 WV_ADDR x0,x25,\handle
 ldr x0,[x0]
 WV_RANGE x0,64
 ldrsw x1,[x0]
 cmp x1,#1
 b.lt .Lwv_bad
 WV_ADDR x0,x26,\descriptor
 mov x2,x20
 add x3,x19,#(64+16*\row)
 bl .Lwv_descriptor
 cbnz w0,.Lwv_bad
.endm
.global md2asm_prepare_runtime_wave_surface_fields
.type md2asm_prepare_runtime_wave_surface_fields,%function
md2asm_prepare_runtime_wave_surface_fields:
 sub sp,sp,#768
 stp x18,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x29,[sp,#96]
 stp x0,x1,[sp,#112]
 stp x2,x3,[sp,#128]
 stp x4,x5,[sp,#144]
 stp x6,x7,[sp,#160]
 ldr x9,[sp,#768]
 str x9,[sp,#176]
 mrs x9,fpcr
 cbnz x9,.Lwv_bad
 WV_RANGE x1,4275088
 mov x27,x1
 WV_ADDR x9,x27,4271608
 ldr w9,[x9]
 cbz w9,.Lwv_success
 cmp w9,#1
 b.ne .Lwv_bad
 ldr x0,[sp,#112]
 WV_RANGE x0,192
 ldrsw x20,[x0,#12]
 sub x9,x20,#1
 cmp x9,#127
 b.hi .Lwv_bad
 ldrsw x21,[x0,#48]
 sub x9,x21,#6
 cmp x9,#131
 b.hi .Lwv_bad
 ldrsw x9,[x0]
 cmp x9,#1
 b.lt .Lwv_bad
 ldrsw x10,[x0,#4]
 cmp x10,x9
 b.lt .Lwv_bad
 cmp x10,x20
 b.gt .Lwv_bad
 add x19,sp,#192
 mov x11,#0
.Lwv_zero_table:
 str xzr,[x19,x11]
 add x11,x11,#8
 cmp x11,#432
 b.lo .Lwv_zero_table
 str w20,[x19]
 str w9,[x19,#4]
 str w10,[x19,#8]
 WV_ADDR x9,x27,4271536
 ldr w22,[x9]
 sub w9,w22,#1
 cmp w9,#2
 b.hi .Lwv_bad
 WV_ADDR x9,x27,4271624
 ldr w23,[x9]
 cmp w23,#1
 b.hi .Lwv_bad
 WV_ADDR x9,x27,4271620
 ldr w24,[x9]
 cmp w24,#1
 b.hi .Lwv_bad
 str w22,[x19,#12]
 str w23,[x19,#16]
 str w24,[x19,#20]
 WV_ADDR x9,x27,4271600
 ldr x9,[x9]
 str x9,[x19,#40]
 ldr x25,[sp,#128]
 WV_RANGE x25,18224
 ldr x26,[sp,#160]
 WV_RANGE x26,13680
 ldr x0,[sp,#136]
 WV_RANGE x0,1992
 ldr x0,[sp,#144]
 WV_RANGE x0,728
 ldr x0,[sp,#152]
 WV_RANGE x0,728
 ldr x0,[sp,#168]
 WV_RANGE x0,5064
 ldr x0,[sp,#176]
 WV_RANGE x0,520
 str x0,[x19,#32]
 WV_VIEW 0,136,448,x21
 WV_VIEW 1,144,416,x21
 WV_VIEW 2,152,328,x21
 cmp w22,#3
 b.ne .Lwv_stress
 cbnz w23,.Lwv_stress_done
.Lwv_stress:
 mov x28,#1
 WV_VIEW 3,160,10240,x28
 WV_VIEW 4,160,10328,x28
.Lwv_stress_done:
 WV_SURFACE 5,15688,9168
 WV_SURFACE 6,15696,9168
 WV_SURFACE 7,15704,9168
 WV_SURFACE 8,15712,9168
 WV_SURFACE 9,15720,9168
 WV_SURFACE 10,15728,9168
 cbz w24,.Lwv_output_current_done
 WV_SURFACE 11,15736,9168
 WV_SURFACE 12,15744,9168
.Lwv_output_current_done:
 cmp w22,#3
 b.ne .Lwv_neutral_done
 cbz w23,.Lwv_neutral_done
 WV_SURFACE 13,14368,8992
 WV_SURFACE 14,14376,8992
.Lwv_neutral_done:
 cbnz w24,.Lwv_input_current
 cmp w22,#3
 b.ne .Lwv_input_current_done
 cbz w23,.Lwv_input_current_done
.Lwv_input_current:
 WV_SURFACE 15,9176,8728
 WV_SURFACE 16,9184,8728
.Lwv_input_current_done:
 cmp w22,#3
 b.ne .Lwv_roughness_done
 cbnz w23,.Lwv_roughness_done
 WV_SURFACE 17,13384,8992
.Lwv_roughness_done:
 WV_VIEW 18,168,352,x21
 WV_VIEW 19,168,616,x21
 WV_SURFACE 20,8992,8728
 WV_SURFACE 21,9168,8728
 WV_SURFACE 22,9152,8728
 mov x0,x19
 mov x1,#432
 bl md2asm_calculate_runtime_wave_surface_fields
 b .Lwv_leave
.Lwv_success:
 mov w0,#0
 b .Lwv_leave
.Lwv_bad:
 mov w0,#2
.Lwv_leave:
 ldr x29,[sp,#96]
 ldp x27,x28,[sp,#80]
 ldp x25,x26,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x18,x30,[sp]
 add sp,sp,#768
 ret
.size md2asm_prepare_runtime_wave_surface_fields,.-md2asm_prepare_runtime_wave_surface_fields

/* This private leaf validates one declared array and publishes one view. */
.macro WV_MUL target,left,right
 smulh x13,\left,\right
 mul \target,\left,\right
 asr x17,\target,#63
 cmp x13,x17
 b.ne .Lwv_desc_bad
.endm
.macro WV_POINTER target,index
 lsl x12,\index,#3
 asr x13,x12,#3
 cmp x13,\index
 b.ne .Lwv_desc_bad
 cmp \index,#0
 b.lt .Lwv_negative\@
 adds \target,x4,x12
 b.cs .Lwv_desc_bad
 b .Lwv_pointer_ready\@
.Lwv_negative\@:
 adds \target,x4,x12
 b.cc .Lwv_desc_bad
.Lwv_pointer_ready\@:
 cbz \target,.Lwv_desc_bad
.endm
.Lwv_descriptor:
 ldr x4,[x0]
 cbz x4,.Lwv_desc_bad
 tst x4,#7
 b.ne .Lwv_desc_bad
 ldr x12,[x0,#16]
 cmp x12,#8
 b.ne .Lwv_desc_bad
 ldrb w12,[x0,#28]
 cmp w12,#2
 b.ne .Lwv_desc_bad
 ldrb w12,[x0,#29]
 cmp w12,#3
 b.ne .Lwv_desc_bad
 ldr x12,[x0,#32]
 cmp x12,#8
 b.ne .Lwv_desc_bad
 ldr x5,[x0,#8]
 ldp x6,x7,[x0,#40]
 ldr x8,[x0,#56]
 ldp x9,x10,[x0,#64]
 ldr x11,[x0,#80]
 cmp x6,#1
 b.ne .Lwv_desc_bad
 cmp x9,#1
 b.lt .Lwv_desc_bad
 lsr x12,x6,#61
 cbnz x12,.Lwv_desc_bad
 cmp x7,#1
 b.gt .Lwv_desc_bad
 cmp x8,x2
 b.lt .Lwv_desc_bad
 cmp x10,x1
 b.gt .Lwv_desc_bad
 cmp x11,x1
 b.lt .Lwv_desc_bad
 /* Original typed pointers are contiguous in both dimensions. */
 subs x12,x8,x7
 b.vs .Lwv_desc_bad
 adds x12,x12,#1
 b.vs .Lwv_desc_bad
 cmp x9,x12
 b.ne .Lwv_desc_bad
 WV_MUL x14,x6,x7
 adds x14,x14,x5
 b.vs .Lwv_desc_bad
 WV_MUL x12,x9,x10
 adds x14,x14,x12
 b.vs .Lwv_desc_bad
 subs x12,x8,x7
 b.vs .Lwv_desc_bad
 WV_MUL x15,x12,x6
 adds x15,x15,x14
 b.vs .Lwv_desc_bad
 subs x12,x11,x10
 b.vs .Lwv_desc_bad
 WV_MUL x12,x12,x9
 adds x15,x15,x12
 b.vs .Lwv_desc_bad
 WV_MUL x16,x9,x1
 adds x16,x16,x6
 b.vs .Lwv_desc_bad
 adds x16,x16,x5
 b.vs .Lwv_desc_bad
 WV_POINTER x14,x14
 WV_POINTER x15,x15
 adds x15,x15,#8
 b.cs .Lwv_desc_bad
 WV_POINTER x16,x16
 cmp x16,x14
 b.lo .Lwv_desc_bad
 sub x12,x2,#1
 WV_MUL x12,x12,x6
 lsl x13,x12,#3
 lsr x17,x13,#3
 cmp x17,x12
 b.ne .Lwv_desc_bad
 adds x13,x16,x13
 b.cs .Lwv_desc_bad
 adds x13,x13,#8
 b.cs .Lwv_desc_bad
 cmp x13,x15
 b.hi .Lwv_desc_bad
 lsl x6,x6,#3
 stp x16,x6,[x3]
 mov w0,#0
 ret
.Lwv_desc_bad:
 mov w0,#2
 ret
.section .note.GNU-stack,"",%progbits
