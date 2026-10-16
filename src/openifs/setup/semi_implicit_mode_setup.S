/* Complete selected SUBMAT and SUSI vertical-mode computations.
 * Contract skills/md2asm/references/openifs/dynamics/semi_implicit_mode_setup.md.
 * x0 Geometry, x1 capacity, x2 MODEL, x3 capacity. Return0/1/2/3.
 * Source order and each FP64 rounding point are preserved. */
.arch armv8.2-a
.text
.macro MODE_POINTER dst,offset
 movz \dst,#(\offset & 65535)
 movk \dst,#(\offset >> 16),lsl#16
 ldr \dst,[x20,\dst]
.endm
.p2align 4
.global md2asm_initialize_semi_implicit_modes
.type md2asm_initialize_semi_implicit_modes,%function
md2asm_initialize_semi_implicit_modes:
 sub sp,sp,#512
 stp x18,x19,[sp,#64]
 stp x20,x21,[sp,#80]
 stp x22,x23,[sp,#96]
 stp x24,x25,[sp,#112]
 stp x26,x27,[sp,#128]
 stp x28,x29,[sp,#144]
 str x30,[sp,#160]
 mov x19,x0
 mov x20,x2
 mov x22,xzr
 cbz x0,.Lmode_bad
 cbz x2,.Lmode_bad
 orr x9,x0,x2
 tst x9,#7
 b.ne .Lmode_bad
 mov x9,#17096
 cmp x1,x9
 b.lo .Lmode_bad
 adds x10,x0,x9
 b.cs .Lmode_bad
 movz x9,#(4275088 & 65535)
 movk x9,#(4275088 >> 16),lsl#16
 cmp x3,x9
 b.lo .Lmode_bad
 adds x11,x2,x9
 b.cs .Lmode_bad
 cmp x10,x2
 b.ls .Lmode_records_disjoint
 cmp x11,x0
 b.hi .Lmode_bad
.Lmode_records_disjoint:
 mrs x9,fpcr
 cbnz x9,.Lmode_bad
 mov x9,#5224
 ldr w21,[x19,x9]
 sub w9,w21,#1
 cmp w9,#254
 b.hi .Lmode_bad
 str w21,[sp,#192]
 mov w9,#1
 str w9,[sp,#196]
 str w9,[sp,#204]
 movz x9,#(1567068 & 65535)
 movk x9,#(1567068 >> 16),lsl#16
 ldr w9,[x20,x9]
 cbnz w9,.Lmode_bad
 movz x9,#(1570368 & 65535)
 movk x9,#(1570368 >> 16),lsl#16
 ldr w9,[x20,x9]
 cbnz w9,.Lmode_bad
 ldr x9,[x19,#3264]
 cbz x9,.Lmode_bad
 tst x9,#7
 b.ne .Lmode_bad
 ldr w9,[x9,#184]
 cbnz w9,.Lmode_bad
 /* Positive finite pressure and normalisation are required by the source. */
 adr x12,.Lmode_positive_scalar_offsets
 mov x13,#0
.Lmode_positive_scalars:
 ldr w9,[x12,x13,lsl#2]
 ldr x10,[x20,x9]
 tbnz x10,#63,.Lmode_bad
 cbz x10,.Lmode_bad
 ubfx x11,x10,#52,#11
 cmp x11,#2047
 b.eq .Lmode_bad
 add x13,x13,#1
 cmp x13,#2
 b.lo .Lmode_positive_scalars
 /* Check the five complete owned descriptors before any output store. */
 mov x23,#0
.Lmode_owned_descriptor:
 adr x9,.Lmode_owner_offsets
 ldr w9,[x9,x23,lsl#2]
 add x0,x20,x9
 mov x1,x21
 mov x2,#2
 mov x9,#1
 cmp x23,#3
 csel x2,x9,x2,eq
 mov x3,#1
 bl .Lmode_descriptor_bounds
 cbnz w0,.Lmode_bad
 add x9,sp,#400
 add x9,x9,x23,lsl#4
 stp x4,x5,[x9]
 /* Writable owners cannot alias parent records or an earlier owner. */
 mov x9,#17096
 add x9,x19,x9
 cmp x4,x9
 b.hs .Lmode_owner_model
 cmp x5,x19
 b.hi .Lmode_bad
.Lmode_owner_model:
 movz x9,#(4275088 & 65535)
 movk x9,#(4275088 >> 16),lsl#16
 add x9,x20,x9
 cmp x4,x9
 b.hs .Lmode_owner_previous
 cmp x5,x20
 b.hi .Lmode_bad
.Lmode_owner_previous:
 mov x10,#0
.Lmode_owner_pair:
 cmp x10,x23
 b.hs .Lmode_owner_admitted
 add x9,sp,#400
 add x9,x9,x10,lsl#4
 ldp x11,x12,[x9]
 cmp x4,x12
 b.hs .Lmode_owner_pair_next
 cmp x5,x11
 b.hi .Lmode_bad
.Lmode_owner_pair_next:
 add x10,x10,#1
 b .Lmode_owner_pair
.Lmode_owner_admitted:
 add x23,x23,#1
 cmp x23,#5
 b.lo .Lmode_owned_descriptor
 mov x23,#0
.Lmode_pressure_descriptor:
 adr x9,.Lmode_pressure_offsets
 ldr w9,[x9,x23,lsl#2]
 add x0,x20,x9
 mov x1,x21
 mov x2,#1
 mov x3,#1
 cmp x23,#4
 csel x3,xzr,x3,eq
 bl .Lmode_descriptor_bounds
 cbnz w0,.Lmode_bad
 mov x10,#0
.Lmode_pressure_alias:
 add x9,sp,#400
 add x9,x9,x10,lsl#4
 ldp x11,x12,[x9]
 cmp x4,x12
 b.hs .Lmode_pressure_alias_next
 cmp x5,x11
 b.hi .Lmode_bad
.Lmode_pressure_alias_next:
 add x10,x10,#1
 cmp x10,#5
 b.lo .Lmode_pressure_alias
 add x23,x23,#1
 cmp x23,#7
 b.lo .Lmode_pressure_descriptor
 MODE_POINTER x9,1567320
 mov x10,#0
.Lmode_positive_weights:
 ldr x11,[x9,x10,lsl#3]
 tbnz x11,#63,.Lmode_bad
 cbz x11,.Lmode_bad
 ubfx x12,x11,#52,#11
 cmp x12,#2047
 b.eq .Lmode_bad
 add x10,x10,#1
 cmp x10,x21
 b.lo .Lmode_positive_weights
 mul x23,x21,x21
 lsl x23,x23,#3
 lsl x24,x21,#3
 /* Reserve five matrices, bounded vector work and alignment padding. */
 mov x9,#5
 mul x0,x23,x9
 mov x9,#96
 madd x0,x21,x9,x0
 add x0,x0,#128
 bl malloc
 cbz x0,.Lmode_allocation_failed
 mov x22,x0
 str x22,[sp,#208]
 add x9,x22,x23
 str x9,[sp,#216]
 add x9,x9,x23
 str x9,[sp,#224]
 add x9,x9,x24
 str x9,[sp,#232]
 add x9,x9,x23
 str x9,[sp,#240]
 add x9,x9,x24
 str x9,[sp,#248]
 add x9,x9,x24
 str x9,[sp,#256]
 add x9,x9,x23
 str x9,[sp,#264]
 add x10,x24,#8
 add x9,x9,x10
 str x9,[sp,#272]
 add x10,x21,#1
 add x9,x9,x10,lsl#2
 add x9,x9,#15
 and x9,x9,#-16
 str x9,[sp,#280]
 add x9,x9,x23
 str x9,[sp,#288]
 add x9,x9,x24,lsl#2
 str x9,[sp,#296]
 add x9,x9,x21,lsl#2
 str x9,[sp,#304]
 ldr x25,[sp,#400]
 ldr x26,[sp,#416]
 ldr x27,[sp,#432]
 ldr x28,[sp,#448]
 ldr x9,[sp,#464]
 str x9,[sp,#312]
 /* SUBMAT applies the two accepted operators to an identity basis. */
 mov x9,#0
.Lmode_identity_column:
 mov x10,#0
.Lmode_identity_row:
 cmp x9,x10
 mov x11,#0x3ff0000000000000
 csel x11,x11,xzr,eq
 madd x12,x9,x21,x10
 str x11,[x22,x12,lsl#3]
 add x10,x10,#1
 cmp x10,x21
 b.lo .Lmode_identity_row
 add x9,x9,#1
 cmp x9,x21
 b.lo .Lmode_identity_column
 mov x0,x19
 movz x9,#(1564592 & 65535)
 movk x9,#(1564592 >> 16),lsl#16
 add x1,x20,x9
 add x2,sp,#196
 add x3,sp,#192
 ldr x4,[sp,#208]
 ldr x5,[sp,#216]
 ldr x6,[sp,#224]
 mov x7,x3
 bl md2asm_lassie_sitnu
 mov x0,x19
 movz x9,#(1564592 & 65535)
 movk x9,#(1564592 >> 16),lsl#16
 add x1,x20,x9
 add x2,sp,#196
 add x3,sp,#192
 ldr x4,[sp,#208]
 ldr x5,[sp,#216]
 ldr x6,[sp,#224]
 mov x7,x3
 str x3,[sp]
 bl md2asm_lassie_sigam
 ldr x10,[sp,#232]
 mov x9,#0
 lsr x11,x23,#3
.Lmode_store_B:
 ldr x12,[x22,x9,lsl#3]
 str x12,[x25,x9,lsl#3]
 str x12,[x10,x9,lsl#3]
 add x9,x9,#1
 cmp x9,x11
 b.lo .Lmode_store_B
 /* The external service uses original EIGSOL's ten-address interface. */
 add x0,sp,#192
 mov x1,x0
 ldr x2,[sp,#232]
 ldr x3,[sp,#240]
 ldr x4,[sp,#248]
 add x5,sp,#204
 ldr x6,[sp,#256]
 ldr x7,[sp,#272]
 ldr x9,[sp,#264]
 str x9,[sp]
 add x9,sp,#200
 str x9,[sp,#8]
 bl md2asm_semi_implicit_eigenvalues
 ldr w9,[sp,#200]
 cbnz w9,.Lmode_numerical_failed
 /* XUTRII's strict-greater bubble ordering keeps equal values stable. */
 ldr x12,[sp,#272]
 mov x9,#0
.Lmode_sort_indices:
 add w10,w9,#1
 str w10,[x12,x9,lsl#2]
 add x9,x9,#1
 cmp x9,x21
 b.lo .Lmode_sort_indices
 ldr x13,[sp,#240]
 sub x14,x21,#1
.Lmode_sort_pass:
 mov x15,#0
 mov x9,#0
.Lmode_sort_pair:
 cmp x9,x14
 b.hs .Lmode_sort_pass_end
 ldrsw x10,[x12,x9,lsl#2]
 add x11,x9,#1
 ldrsw x11,[x12,x11,lsl#2]
 sub x16,x10,#1
 sub x17,x11,#1
 ldr d0,[x13,x16,lsl#3]
 ldr d1,[x13,x17,lsl#3]
 fcmp d0,d1
 b.le .Lmode_sort_pair_end
 str w11,[x12,x9,lsl#2]
 add x16,x9,#1
 str w10,[x12,x16,lsl#2]
 mov x15,#1
.Lmode_sort_pair_end:
 add x9,x9,#1
 b .Lmode_sort_pair
.Lmode_sort_pass_end:
 cbnz x15,.Lmode_sort_pass
 ldr x14,[sp,#248]
 ldr x15,[sp,#216]
 add x16,x15,x24
 mov x9,#0
.Lmode_sorted_frequency_copy:
 ldrsw x10,[x12,x9,lsl#2]
 sub x10,x10,#1
 ldr x11,[x13,x10,lsl#3]
 str x11,[x15,x9,lsl#3]
 ldr x11,[x14,x10,lsl#3]
 str x11,[x16,x9,lsl#3]
 add x9,x9,#1
 cmp x9,x21
 b.lo .Lmode_sorted_frequency_copy
 mov x9,#0
.Lmode_sorted_frequency_store:
 ldr x10,[x15,x9,lsl#3]
 str x10,[x13,x9,lsl#3]
 ldr x10,[x16,x9,lsl#3]
 str x10,[x14,x9,lsl#3]
 add x9,x9,#1
 cmp x9,x21
 b.lo .Lmode_sorted_frequency_store
 ldr x13,[sp,#256]
 ldr x14,[sp,#232]
 mov x9,#0
.Lmode_sorted_mode_column:
 ldrsw x10,[x12,x9,lsl#2]
 sub x10,x10,#1
 mul x10,x10,x21
 mul x11,x9,x21
 mov x15,#0
.Lmode_sorted_mode_row:
 add x16,x10,x15
 ldr x17,[x13,x16,lsl#3]
 add x16,x11,x15
 str x17,[x14,x16,lsl#3]
 add x15,x15,#1
 cmp x15,x21
 b.lo .Lmode_sorted_mode_row
 add x9,x9,#1
 cmp x9,x21
 b.lo .Lmode_sorted_mode_column
 mov x9,#0
 lsr x10,x23,#3
.Lmode_sorted_mode_store:
 ldr x11,[x14,x9,lsl#3]
 str x11,[x13,x9,lsl#3]
 add x9,x9,#1
 cmp x9,x10
 b.lo .Lmode_sorted_mode_store
 mov x9,#0
.Lmode_reverse_row:
 mov x10,#0
.Lmode_reverse_column:
 madd x11,x10,x21,x9
 ldr x12,[x13,x11,lsl#3]
 sub x11,x21,x10
 sub x11,x11,#1
 madd x11,x11,x21,x9
 str x12,[x26,x11,lsl#3]
 add x10,x10,#1
 cmp x10,x21
 b.lo .Lmode_reverse_column
 add x9,x9,#1
 cmp x9,x21
 b.lo .Lmode_reverse_row
 ldr x13,[sp,#240]
 ldr x14,[sp,#248]
 mov x9,#0
 ldr d0,[x14]
.Lmode_reverse_values:
 ldr x10,[x13,x9,lsl#3]
 sub x11,x21,x9
 sub x11,x11,#1
 str x10,[x28,x11,lsl#3]
 ldr d1,[x14,x9,lsl#3]
 fcmp d0,d1
 fcsel d0,d0,d1,ge
 add x9,x9,#1
 cmp x9,x21
 b.lo .Lmode_reverse_values
 str d0,[sp,#336]
 /* Normalise each mode with the original pressure-weighted sum. */
 MODE_POINTER x12,1567320
 movz x9,#(1567104 & 65535)
 movk x9,#(1567104 >> 16),lsl#16
 ldr d6,[x20,x9]
 movz x9,#(1568768 & 65535)
 movk x9,#(1568768 >> 16),lsl#16
 ldr d7,[x20,x9]
 mov x9,#0
.Lmode_normalise_column:
 mul x10,x9,x21
 mov x11,#0
 fmov d0,xzr
.Lmode_normalise_sum:
 add x13,x10,x11
 ldr d1,[x26,x13,lsl#3]
 fmul d2,d1,d1
 ldr d3,[x12,x11,lsl#3]
 fmul d2,d2,d3
 fadd d0,d0,d2
 add x11,x11,#1
 cmp x11,x21
 b.lo .Lmode_normalise_sum
 fdiv d0,d0,d6
 fdiv d0,d0,d7
 fsqrt d0,d0
 mov x11,#0
.Lmode_normalise_divide:
 add x13,x10,x11
 ldr d1,[x26,x13,lsl#3]
 fdiv d1,d1,d0
 str d1,[x26,x13,lsl#3]
 add x11,x11,#1
 cmp x11,x21
 b.lo .Lmode_normalise_divide
 add x9,x9,#1
 cmp x9,x21
 b.lo .Lmode_normalise_column
 mov x9,#0
.Lmode_sign_column:
 mul x10,x9,x21
 add x11,x10,x21
 sub x11,x11,#1
 ldr d0,[x26,x11,lsl#3]
 fcmp d0,#0.0
 b.ge .Lmode_sign_next
 mov x11,#0
.Lmode_sign_row:
 add x12,x10,x11
 ldr d0,[x26,x12,lsl#3]
 fneg d0,d0
 str d0,[x26,x12,lsl#3]
 add x11,x11,#1
 cmp x11,x21
 b.lo .Lmode_sign_row
.Lmode_sign_next:
 add x9,x9,#1
 cmp x9,x21
 b.lo .Lmode_sign_column
 mov x0,x21
 mov x1,x26
 mov x2,x27
 ldr x3,[sp,#280]
 ldr x4,[sp,#288]
 ldr x5,[sp,#296]
 ldr x6,[sp,#304]
 bl md2asm_invert_scaled_mode_matrix
 cbnz w0,.Lmode_numerical_failed
 ldr d0,[sp,#336]
 fcmp d0,#0.0
 b.ne .Lmode_numerical_failed
 /* Source LSIDG/LESIDG/stability branches are inactive in this route. */
 mov x0,x21
 mov x1,x25
 ldr x2,[sp,#312]
 ldr x3,[sp,#280]
 ldr x4,[sp,#288]
 ldr x5,[sp,#296]
 ldr x6,[sp,#304]
 bl md2asm_invert_scaled_mode_matrix
 cbnz w0,.Lmode_numerical_failed
 mov w23,#0
 b .Lmode_cleanup
.Lmode_bad:
 mov w23,#2
 b .Lmode_cleanup
.Lmode_allocation_failed:
 mov w23,#1
 b .Lmode_cleanup
.Lmode_numerical_failed:
 mov w23,#3
.Lmode_cleanup:
 cbz x22,.Lmode_return
 mov x0,x22
 bl free
.Lmode_return:
 mov w0,w23
 ldr x30,[sp,#160]
 ldp x28,x29,[sp,#144]
 ldp x26,x27,[sp,#128]
 ldp x24,x25,[sp,#112]
 ldp x22,x23,[sp,#96]
 ldp x20,x21,[sp,#80]
 ldp x18,x19,[sp,#64]
 add sp,sp,#512
 ret
/* Validate a source-owned dense FP64 descriptor. x3 is its lower bound. */
.Lmode_descriptor_bounds:
 ldr x4,[x0]
 cbz x4,.Lmode_descriptor_bad
 tst x4,#7
 b.ne .Lmode_descriptor_bad
 ldr x9,[x0,#16]
 cmp x9,#8
 b.ne .Lmode_descriptor_bad
 ldrh w9,[x0,#28]
 add w10,w2,#0x300
 cmp w9,w10
 b.ne .Lmode_descriptor_bad
 ldr x9,[x0,#32]
 cmp x9,#8
 b.ne .Lmode_descriptor_bad
 ldr x9,[x0,#40]
 cmp x9,#1
 b.ne .Lmode_descriptor_bad
 ldp x9,x10,[x0,#48]
 cmp x9,x3
 b.ne .Lmode_descriptor_bad
 cmp x10,x1
 b.ne .Lmode_descriptor_bad
 neg x11,x3
 sub x12,x1,x3
 add x12,x12,#1
 cmp x2,#2
 b.ne .Lmode_descriptor_origin
 ldp x9,x10,[x0,#64]
 cmp x9,x1
 b.ne .Lmode_descriptor_bad
 cmp x10,#1
 b.ne .Lmode_descriptor_bad
 ldr x9,[x0,#80]
 cmp x9,x1
 b.ne .Lmode_descriptor_bad
 sub x11,x11,x1
 mul x12,x1,x1
.Lmode_descriptor_origin:
 ldr x9,[x0,#8]
 cmp x9,x11
 b.ne .Lmode_descriptor_bad
 adds x5,x4,x12,lsl#3
 b.cs .Lmode_descriptor_bad
 mov w0,#0
 ret
.Lmode_descriptor_bad:
 mov w0,#2
 ret
.size md2asm_initialize_semi_implicit_modes,.-md2asm_initialize_semi_implicit_modes
.section .rodata
.p2align 2
.Lmode_owner_offsets: .word 1567640,1567728,1567816,1567904,1569224
.Lmode_pressure_offsets: .word 1567192,1567256,1567320,1567384,1567448,1567512,1567576
.Lmode_positive_scalar_offsets: .word 1567104,1568768
.section .note.GNU-stack,"",%progbits
