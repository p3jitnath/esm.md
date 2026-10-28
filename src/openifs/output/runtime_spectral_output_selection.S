/* Source field order for IOSPECE ML/PL and exact spectral payload copies.
 * Contract skills/md2asm/references/openifs/output/runtime_fullpos_file_writers.md.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_build_runtime_spectral_output_selection
.type md2asm_build_runtime_spectral_output_selection,%function
md2asm_build_runtime_spectral_output_selection:
 cbz x0,.Lselect_bad_leaf
 cmp w1,#109
 b.eq .Lselect_prefix_ok
 cmp w1,#112
 b.eq .Lselect_prefix_ok
 cmp w1,#118
 b.eq .Lselect_prefix_ok
 cmp w1,#116
 b.ne .Lselect_bad_leaf
.Lselect_prefix_ok:
 cmp w2,#0
 b.lt .Lselect_bad_leaf
 cmp w3,#1
 b.lt .Lselect_bad_leaf
 ldrsw x9,[x0]
 mov x10,#65536
 cmp x9,x10
 b.hi .Lselect_bad_leaf
 ldrsw x11,[x0,#608]
 cmp x11,x10
 b.hi .Lselect_bad_leaf
 sub sp,sp,#176
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mov x19,x0
 mov w20,w1
 mov x21,x9
 sxtw x22,w3
 mov x23,x4
 mov x24,x5
 mov x25,x6
 mov x26,x7
 ldr x27,[sp,#176]
 cbz x27,.Lselect_bad
 str w2,[sp,#160]
 cbz x21,.Lselect_empty
 add x0,x19,#72
 mov x1,#4
 mov x2,x21
 mov w3,#1
 bl .Lselection_array
 cbz x0,.Lselect_bad
 str x0,[sp,#112]
 add x0,x19,#136
 mov x1,#4
 mov x2,x21
 mov w3,#2
 bl .Lselection_array
 cbz x0,.Lselect_bad
 str x0,[sp,#120]
 add x0,x19,#264
 mov x1,#8
 mov x2,x21
 mov w3,#3
 bl .Lselection_array
 cbz x0,.Lselect_bad
 str x0,[sp,#128]
 add x0,x19,#616
 mov x1,#4
 mov x2,x21
 mov w3,#1
 bl .Lselection_array
 cbz x0,.Lselect_bad
 str x0,[sp,#136]
 add x0,x19,#680
 mov x1,#4
 mov x2,x21
 mov w3,#1
 bl .Lselection_array
 cbz x0,.Lselect_bad
 str x0,[sp,#144]
 str wzr,[sp,#104]
.Lselection_pass:
 mov x10,#0
 mov x11,#0
 mov x28,#0
.Lselection_field:
 ldr x9,[sp,#112]
 ldr w12,[x9,x28,lsl#2]
 ldr x9,[sp,#120]
 ldr w13,[x9,x28,lsl#2]
 cmp w13,#1
 b.hi .Lselect_bad
 cmp w20,#112
 b.ne .Lselection_not_pressure_skip
 cmp w12,#129
 b.ne .Lselection_not_pressure_skip
 cbnz w13,.Lselection_next_field
.Lselection_not_pressure_skip:
 cmp w20,#109
 b.eq .Lselection_model_level
 ldr x9,[sp,#120]
 ldr w13,[x9,x10,lsl#2]
 cmp w13,#1
 b.hi .Lselect_bad
 cmp w20,#112
 b.ne .Lselection_other_level
 cbz w13,.Lselection_level_current
 mov w14,#0x86a0
 movk w14,#1,lsl#16
 b .Lselection_level_done
.Lselection_other_level:
 ldr x9,[sp,#128]
 ldr d0,[x9,x10,lsl#3]
 cmp w20,#118
 b.ne .Lselection_convert_level
 ldr w9,[sp,#104]
 cbz w9,.Lselection_validate_pv
 adrp x9,.Lpv_scale
 ldr d1,[x9,:lo12:.Lpv_scale]
 fmul d0,d0,d1
 b .Lselection_convert_level
.Lselection_validate_pv:
 fmov x9,d0
 tbnz x9,#63,.Lselect_bad
 movz x17,#0x4000,lsl#48
 cmp x9,x17
 b.hi .Lselect_bad
 mov w14,#0
 b .Lselection_level_done
.Lselection_model_level:
 cbz w13,.Lselection_level_current
 mov w14,#1
 b .Lselection_level_done
.Lselection_level_current:
 ldr x9,[sp,#128]
 ldr d0,[x9,x28,lsl#3]
.Lselection_convert_level:
 ldr w9,[sp,#104]
 cbnz w9,.Lselection_nint
 fmov x9,d0
 tbnz x9,#63,.Lselect_bad
 adrp x17,.Lint32_maximum
 ldr x17,[x17,:lo12:.Lint32_maximum]
 cmp x9,x17
 b.hi .Lselect_bad
 mov w14,#0
 b .Lselection_level_done
.Lselection_nint:
 fcvtas w14,d0
.Lselection_level_done:
 ldr x9,[sp,#136]
 ldr w15,[x9,x28,lsl#2]
 cmp w15,#1
 b.lt .Lselect_bad
 ldr x9,[sp,#144]
 ldr w16,[x9,x28,lsl#2]
 cmp w16,#1
 b.lt .Lselect_bad
 cmp w15,w22
 b.ne .Lselection_other_set
 ldr w9,[x19,#608]
 cmp w16,w9
 b.gt .Lselect_bad
 ldr w9,[sp,#104]
 cbz w9,.Lselection_local_count
 str w16,[x25,x11,lsl#2]
.Lselection_local_count:
 add x11,x11,#1
.Lselection_other_set:
 ldr w9,[sp,#104]
 cbz w9,.Lselection_global_count
 add x9,x23,x10,lsl#4
 stp w12,w14,[x9]
 stp w15,w16,[x9,#8]
.Lselection_global_count:
 add x10,x10,#1
.Lselection_next_field:
 add x28,x28,#1
 cmp x28,x21
 b.ne .Lselection_field
 ldr w9,[sp,#104]
 cbnz w9,.Lselection_complete
 cmp x10,x24
 b.hi .Lselect_bad
 cmp x11,x26
 b.hi .Lselect_bad
 cbz x10,.Lselection_global_empty
 cbz x23,.Lselect_bad
 adds x9,x23,x10,lsl#4
 b.cs .Lselect_bad
.Lselection_global_empty:
 cbz x11,.Lselection_local_empty
 cbz x25,.Lselect_bad
 adds x9,x25,x11,lsl#2
 b.cs .Lselect_bad
.Lselection_local_empty:
 mov w9,#1
 str w9,[sp,#104]
 b .Lselection_pass
.Lselection_complete:
 stp w10,w11,[x27]
 mov w0,#0
 b .Lselect_restore
.Lselect_empty:
 str xzr,[x27]
 mov w0,#0
 b .Lselect_restore
.Lselect_bad:
 mov w0,#2
.Lselect_restore:
 ldr x18,[sp,#96]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp]
 add sp,sp,#176
 ret
.Lselect_bad_leaf:
 mov w0,#2
 ret
.Lselection_array:
 ldr x9,[x0]
 cbz x9,.Lselection_array_bad
 ldr x10,[x0,#8]
 cmn x10,#1
 b.ne .Lselection_array_bad
 ldr x10,[x0,#16]
 cmp x10,x1
 b.ne .Lselection_array_bad
 ldrb w10,[x0,#28]
 cmp w10,#1
 b.ne .Lselection_array_bad
 ldrb w10,[x0,#29]
 cmp w10,w3
 b.ne .Lselection_array_bad
 ldr x10,[x0,#40]
 cmp x10,#1
 b.ne .Lselection_array_bad
 ldr x10,[x0,#48]
 cmp x10,#1
 b.ne .Lselection_array_bad
 ldr x10,[x0,#56]
 cmp x10,x2
 b.lt .Lselection_array_bad
 umulh x10,x10,x1
 cbnz x10,.Lselection_array_bad
 ldr x10,[x0,#56]
 mul x10,x10,x1
 adds x10,x9,x10
 b.cs .Lselection_array_bad
 mov x0,x9
 ret
.Lselection_array_bad:
 mov x0,#0
 ret
.size md2asm_build_runtime_spectral_output_selection,.-md2asm_build_runtime_spectral_output_selection
.p2align 4
.global md2asm_pack_runtime_spectral_output_fields
.type md2asm_pack_runtime_spectral_output_fields,%function
md2asm_pack_runtime_spectral_output_fields:
 cbz x2,.Lpack_done
 cbz x0,.Lpack_bad
 cbz x1,.Lpack_bad
 cbz x4,.Lpack_bad
 cbz x3,.Lpack_bad
 mov x6,#65536
 cmp x2,x6
 b.hi .Lpack_bad
 ldr x6,[x0]
 cbz x6,.Lpack_bad
 ldr x7,[x0,#16]
 cmp x7,#8
 b.ne .Lpack_bad
 ldrb w7,[x0,#28]
 cmp w7,#2
 b.ne .Lpack_bad
 ldrb w7,[x0,#29]
 cmp w7,#3
 b.ne .Lpack_bad
 ldr x7,[x0,#40]
 cmp x7,#1
 b.ne .Lpack_bad
 ldr x7,[x0,#48]
 cmp x7,#1
 b.ne .Lpack_bad
 ldr x7,[x0,#56]
 cmp x7,#1
 b.lt .Lpack_bad
 ldr x8,[x0,#64]
 cmp x8,x7
 b.ne .Lpack_bad
 ldr x8,[x0,#72]
 cmp x8,#1
 b.ne .Lpack_bad
 ldr x8,[x0,#80]
 cmp x8,x3
 b.ne .Lpack_bad
 ldr x8,[x0,#8]
 add x9,x7,#1
 neg x9,x9
 cmp x8,x9
 b.ne .Lpack_bad
 umulh x8,x2,x3
 cbnz x8,.Lpack_bad
 mul x8,x2,x3
 lsr x9,x8,#61
 cbnz x9,.Lpack_bad
 lsl x8,x8,#3
 cmp x8,x5
 b.hi .Lpack_bad
 adds x9,x4,x8
 b.cs .Lpack_bad
 umulh x8,x7,x3
 cbnz x8,.Lpack_bad
 mul x8,x7,x3
 lsr x9,x8,#61
 cbnz x9,.Lpack_bad
 adds x9,x6,x8,lsl#3
 b.cs .Lpack_bad
 mov x8,#0
.Lpack_check:
 ldrsw x9,[x1,x8,lsl#2]
 cmp x9,#1
 b.lt .Lpack_bad
 cmp x9,x7
 b.gt .Lpack_bad
 add x8,x8,#1
 cmp x8,x2
 b.ne .Lpack_check
 mov x8,#0
.Lpack_field:
 ldrsw x9,[x1,x8,lsl#2]
 sub x9,x9,#1
 add x9,x6,x9,lsl#3
 mov x10,#0
.Lpack_coefficient:
 ldr x11,[x9]
 str x11,[x4],#8
 add x9,x9,x7,lsl#3
 add x10,x10,#1
 cmp x10,x3
 b.ne .Lpack_coefficient
 add x8,x8,#1
 cmp x8,x2
 b.ne .Lpack_field
.Lpack_done:
 mov w0,#0
 ret
.Lpack_bad:
 mov w0,#2
 ret
.size md2asm_pack_runtime_spectral_output_fields,.-md2asm_pack_runtime_spectral_output_fields
.section .rodata
.p2align 3
.Lpv_scale: .double 1000000000.0
.Lint32_maximum: .double 2147483647.0
.section .note.GNU-stack,"",%progbits
