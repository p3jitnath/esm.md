// Complete selected serial SUFPGRIB and its setup-name/stream children.
// x0 table96: six pointer/capacity pairs, as the frozen contract defines.
// Return0 success,2 before mutation on bad input,1 atomic allocation failure.
// Frame1920; source character/integer order; only malloc/free are external.
.text
.p2align 2
.global md2asm_initialize_fullpos_grib_setup
.type md2asm_initialize_fullpos_grib_setup,%function
md2asm_initialize_fullpos_grib_setup:
 cbz x0,.Learly_bad
 tst x0,#7
 b.ne .Learly_bad
 adds x9,x0,#96
 b.cs .Learly_bad
 sub sp,sp,#1920
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#1904]
 mov x29,sp
 mov x19,x0
 add x10,sp,#96
 stp x0,x9,[x10]
 adr x11,.Lrecord_sizes
 mov x12,#0
.Lrecord_guard:
 ldp x13,x14,[x0],#16
 ldr x15,[x11],#8
 cbz x13,.Lbad
 tst x13,#7
 b.ne .Lbad
 cmp x14,x15
 b.lo .Lbad
 adds x14,x13,x15
 b.cs .Lbad
 add x10,x10,#16
 stp x13,x14,[x10]
 add x12,x12,#1
 cmp x12,#6
 b.lo .Lrecord_guard
 ldr x20,[x19]
 ldr x21,[x19,#16]
 ldr x22,[x19,#32]
 ldr x23,[x19,#48]
 ldr x24,[x19,#64]
 ldr x25,[x19,#80]
 ldr w26,[x22]
 sub w9,w26,#1
 cmp w9,#4095
 b.hi .Lbad
 ldp w9,w10,[x22,#4]
 cmp w9,w26
 b.ne .Lbad
 cmp w10,w26
 b.ne .Lbad
 ldp w9,w10,[x25,#12]
 cmp w9,#1
 b.ne .Lbad
 cmp w10,#1
 b.ne .Lbad
 ldr x9,[x25,#400]
 ldr x10,[x25,#480]
 orr x9,x9,x10
 cbnz x9,.Lbad
 ldr w9,[x23,#388]
 cmp w9,#4095
 b.hi .Lbad
 ldr w9,[x20,#288]
 ldr w10,[x20,#292]
 cmp w9,#1
 b.ne .Lbad
 cmp w10,#1
 b.ne .Lbad
 add x9,x20,#296
 mov x10,#9
.Ldisabled:
 ldr w11,[x9],#4
 cbnz w11,.Lbad
 subs x10,x10,#1
 b.ne .Ldisabled
 ldr w9,[x20,#332]
 cmp w9,#1
 b.ne .Lbad
 // Validate only the characters consumed by the selected source branch.
 mov x9,#0
.Lexperiment_chars:
 ldrb w10,[x20,x9]
 sub w10,w10,#32
 cmp w10,#94
 b.hi .Lbad
 add x9,x9,#1
 cmp x9,#4
 b.lo .Lexperiment_chars
 add x9,x20,#16
 mov x10,#10
.Lprefix_chars:
 ldrb w11,[x9],#1
 sub w11,w11,#32
 cmp w11,#94
 b.hi .Lbad
 subs x10,x10,#1
 b.ne .Lprefix_chars
 add x9,x20,#32
 mov x10,#0
 mov x12,#0
.Lpath_chars:
 ldrb w11,[x9,x10]
 sub w13,w11,#32
 cmp w13,#94
 b.hi .Lbad
 add x10,x10,#1
 cmp w11,#32
 csel x12,x12,x10,eq
 cmp x10,#200
 b.lo .Lpath_chars
 cmp x12,#200
 b.hi .Lbad
 add x0,x22,#88
 mov x1,#1
 mov x2,#1
 bl .Lsource_descriptor
 cbnz w0,.Lbad
 add x9,sp,#208
 stp x3,x4,[x9]
 ldr w9,[x3]
 cmp w9,w26
 b.ne .Lbad
 add x0,x22,#152
 mov x1,x26
 mov x2,#2
 bl .Lsource_descriptor
 cbnz w0,.Lbad
 add x9,sp,#224
 stp x3,x4,[x9]
 mov x9,#0
.Lidentity:
 ldr w10,[x3,x9,lsl#2]
 add x9,x9,#1
 cmp w10,w9
 b.ne .Lbad
 cmp x9,x26
 b.lo .Lidentity
 mov x9,#0
.Lrange_outer:
 add x10,sp,#96
 add x10,x10,x9,lsl#4
 ldp x11,x12,[x10]
 add x13,x9,#1
.Lrange_inner:
 cmp x13,#9
 b.hs .Lrange_next
 add x10,sp,#96
 add x10,x10,x13,lsl#4
 ldp x14,x15,[x10]
 cmp x11,x15
 b.hs .Lrange_disjoint
 cmp x14,x12
 b.lo .Lbad
.Lrange_disjoint:
 add x13,x13,#1
 b .Lrange_inner
.Lrange_next:
 add x9,x9,#1
 cmp x9,#8
 b.lo .Lrange_outer
 // Keep all source-unwritten filename bytes in the private copy.
 add x9,sp,#368
 mov x10,x24
 mov x11,#96
.Lcopy_names_in:
 ldp x12,x13,[x10],#16
 stp x12,x13,[x9],#16
 subs x11,x11,#1
 b.ne .Lcopy_names_in
 mov x0,x20
 add x1,sp,#624
 add x2,sp,#368
 mov w3,#'s'
 bl .Lsetup_names
 mov x0,x20
 add x1,sp,#1136
 add x2,sp,#368
 mov w3,#'m'
 bl .Lsetup_names
 add x0,sp,#368
 bl .Lremove_stamp
 add x0,sp,#624
 bl .Lremove_stamp
 add x0,sp,#1136
 bl .Lremove_stamp
 add x9,sp,#1392
 mov x10,#0
.Lclimate_copy:
 ldrb w11,[x21,x10]
 strb w11,[x9,x10]
 add x10,x10,#1
 cmp x10,#180
 b.lo .Lclimate_copy
 mov w11,#32
.Lclimate_pad:
 strb w11,[x9,x10]
 add x10,x10,#1
 cmp x10,#256
 b.lo .Lclimate_pad
 // Source allocates NFPMAX first, then NUMPROCFP.
 mov x27,#0
 mov x28,#0
 mov x0,#4
 bl malloc
 ldr x18,[sp,#1904]
 cbz x0,.Lallocation_failed
 mov x27,x0
 ldr w9,[x23,#388]
 str w9,[x27]
 lsl x0,x26,#2
 bl malloc
 ldr x18,[sp,#1904]
 cbz x0,.Lallocation_failed
 mov x28,x0
 ldr x10,[sp,#224]
 mov x9,#0
 mov w11,#1
.Lprocess_map:
 ldr w12,[x10,x9,lsl#2]
 sub w12,w12,#1
 str w11,[x28,x12,lsl#2]
 add x9,x9,#1
 cmp x9,x26
 b.lo .Lprocess_map
 add x0,sp,#240
 mov x1,x27
 mov x2,#1
 bl .Lmake_descriptor
 add x0,sp,#304
 mov x1,x28
 mov x2,x26
 bl .Lmake_descriptor
 // Publish exactly the three source scalar stores and two descriptors.
 str w26,[x25,#464]
 str w26,[x25,#468]
 str w26,[x25,#472]
 add x9,sp,#240
 add x10,x25,#480
 mov x11,#4
.Lpublish_max:
 ldp x12,x13,[x9],#16
 stp x12,x13,[x10],#16
 subs x11,x11,#1
 b.ne .Lpublish_max
 add x9,sp,#304
 add x10,x25,#400
 mov x11,#4
.Lpublish_map:
 ldp x12,x13,[x9],#16
 stp x12,x13,[x10],#16
 subs x11,x11,#1
 b.ne .Lpublish_map
 add x9,sp,#368
 mov x10,x24
 mov x11,#96
.Lpublish_names:
 ldp x12,x13,[x9],#16
 stp x12,x13,[x10],#16
 subs x11,x11,#1
 b.ne .Lpublish_names
 mov w0,#0
 b .Lreturn
.Lallocation_failed:
 cbz x27,.Lfailed_return
 mov x0,x27
 bl free
 ldr x18,[sp,#1904]
.Lfailed_return:
 mov w0,#1
 b .Lreturn
.Lbad:
 mov w0,#2
.Lreturn:
 ldr x18,[sp,#1904]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp]
 add sp,sp,#1920
 ret
.Learly_bad:
 mov w0,#2
 ret
.size md2asm_initialize_fullpos_grib_setup,.-md2asm_initialize_fullpos_grib_setup
// Typed contiguous INTEGER4 source descriptor: rank1(n) or rank2(n,1).
.Lsource_descriptor:
 ldr x3,[x0]
 cbz x3,.Ldescriptor_bad
 tst x3,#3
 b.ne .Ldescriptor_bad
 lsl x4,x1,#2
 adds x4,x3,x4
 b.cs .Ldescriptor_bad
 mov x9,#-1
 cmp x2,#1
 b.eq .Lorigin_ready
 neg x9,x1
 sub x9,x9,#1
.Lorigin_ready:
 ldr x10,[x0,#8]
 cmp x10,x9
 b.ne .Ldescriptor_bad
 ldr x9,[x0,#16]
 cmp x9,#4
 b.ne .Ldescriptor_bad
 ldr x9,[x0,#24]
 movz x10,#0x0100,lsl#32
 orr x10,x10,x2,lsl#32
 cmp x9,x10
 b.ne .Ldescriptor_bad
 ldr x9,[x0,#32]
 cmp x9,#4
 b.ne .Ldescriptor_bad
 ldp x9,x10,[x0,#40]
 cmp x9,#1
 b.ne .Ldescriptor_bad
 cmp x10,#1
 b.ne .Ldescriptor_bad
 ldr x9,[x0,#56]
 cmp x9,x1
 b.ne .Ldescriptor_bad
 cmp x2,#1
 b.eq .Ldescriptor_good
 ldr x9,[x0,#64]
 cmp x9,x1
 b.ne .Ldescriptor_bad
 ldp x9,x10,[x0,#72]
 cmp x9,#1
 b.ne .Ldescriptor_bad
 cmp x10,#1
 b.ne .Ldescriptor_bad
.Ldescriptor_good:
 mov w0,#0
 ret
.Ldescriptor_bad:
 mov w0,#2
 ret
.Lmake_descriptor:
 str x1,[x0]
 mov x9,#-1
 str x9,[x0,#8]
 mov x9,#4
 str x9,[x0,#16]
 str x9,[x0,#32]
 movz x9,#0x0101,lsl#32
 str x9,[x0,#24]
 mov x9,#1
 stp x9,x9,[x0,#40]
 str x2,[x0,#56]
 ret
// Selected SUECFNAME calls: LDINCfalse, step5, NTIMEFMT0, no analysis modes.
.Lsetup_names:
 mov x4,#0x2020
 movk x4,#0x2020,lsl#16
 movk x4,#0x2020,lsl#32
 movk x4,#0x2020,lsl#48
 mov x5,#0
.Lpad_pair:
 str x4,[x1,x5]
 str x4,[x2,x5]
 add x5,x5,#8
 cmp x5,#256
 b.lo .Lpad_pair
 add x4,x0,#16
 cmp w3,#'s'
 b.eq .Lselected_prefix
 add x4,x0,#21
.Lselected_prefix:
 mov x5,#0
.Lgrid_prefix:
 ldrb w6,[x4,x5]
 strb w6,[x1,x5]
 add x5,x5,#1
 cmp x5,#5
 b.lo .Lgrid_prefix
 mov x5,#0
 add x4,x1,#5
.Lgrid_experiment:
 ldrb w6,[x0,x5]
 strb w6,[x4,x5]
 add x5,x5,#1
 cmp x5,#4
 b.lo .Lgrid_experiment
 add x4,x1,#9
 adr x5,.Lstamp
 ldr w6,[x5]
 str w6,[x4]
 ldrh w6,[x5,#4]
 strh w6,[x4,#4]
 ldrb w6,[x5,#6]
 strb w6,[x4,#6]
 add x4,x0,#32
 mov x5,#200
.Ltrim_path:
 cbz x5,.Lpath_ready
 sub x6,x5,#1
 ldrb w7,[x4,x6]
 cmp w7,#32
 b.ne .Lpath_ready
 sub x5,x5,#1
 b .Ltrim_path
.Lpath_ready:
 mov x6,#0
.Lpath_copy:
 cmp x6,x5
 b.hs .Lpath_copied
 ldrb w7,[x4,x6]
 strb w7,[x2,x6]
 add x6,x6,#1
 b .Lpath_copy
.Lpath_copied:
 add x2,x2,x5
 adr x4,.Lspectral_label
 mov x5,#0
.Lspectral_label_copy:
 ldrb w6,[x4,x5]
 strb w6,[x2,x5]
 add x5,x5,#1
 cmp x5,#5
 b.lo .Lspectral_label_copy
 add x2,x2,#5
 mov x5,#0
.Lspectral_experiment:
 ldrb w6,[x0,x5]
 strb w6,[x2,x5]
 add x5,x5,#1
 cmp x5,#4
 b.lo .Lspectral_experiment
 add x2,x2,#4
 adr x5,.Lstamp
 ldr w6,[x5]
 str w6,[x2]
 ldrh w6,[x5,#4]
 strh w6,[x2,#4]
 ldrb w6,[x5,#6]
 strb w6,[x2,#6]
 ret
.Lremove_stamp:
 mov x9,#256
.Ltrim_name:
 sub x10,x9,#1
 ldrb w11,[x0,x10]
 cmp w11,#32
 b.ne .Lstamp_end
 sub x9,x9,#1
 b .Ltrim_name
.Lstamp_end:
 sub x9,x9,#7
 mov w11,#32
.Lclear_stamp:
 strb w11,[x0,x9]
 add x9,x9,#1
 cmp x9,#256
 b.lo .Lclear_stamp
 ret
.p2align 2
.global md2asm_release_fullpos_grib_setup
.type md2asm_release_fullpos_grib_setup,%function
md2asm_release_fullpos_grib_setup:
 cbz x0,.Lrelease_bad
 tst x0,#7
 b.ne .Lrelease_bad
 cmp x1,#872
 b.lo .Lrelease_bad
 adds x9,x0,#872
 b.cs .Lrelease_bad
 stp x29,x30,[sp,#-48]!
 stp x19,x18,[sp,#16]
 mov x19,x0
 ldr x0,[x19,#480]
 cbz x0,.Lrelease_map
 bl free
 ldr x18,[sp,#24]
 str xzr,[x19,#480]
.Lrelease_map:
 ldr x0,[x19,#400]
 cbz x0,.Lrelease_done
 bl free
 ldr x18,[sp,#24]
 str xzr,[x19,#400]
.Lrelease_done:
 ldp x19,x18,[sp,#16]
 ldp x29,x30,[sp],#48
 mov w0,#0
 ret
.Lrelease_bad:
 mov w0,#2
 ret
.size md2asm_release_fullpos_grib_setup,.-md2asm_release_fullpos_grib_setup
.section .rodata
.p2align 3
.Lrecord_sizes: .quad 336,180,848,472,1536,872
.Lstamp: .ascii "+000005"
.Lspectral_label: .ascii "ICMSH"
.section .note.GNU-stack,"",%progbits
