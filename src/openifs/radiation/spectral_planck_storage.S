/* Contract: skills/md2asm/references/openifs/radiation/spectral_planck_setup.md.
 * Fresh/released source-layout record240 and owned constants520.
 * Constructor x0 record,x1 capacity,x2 constants,x3 capacity; return0/1/2.
 * Release x0 record,x1 capacity; return0/2. No original metadata or state. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_create_selected_spectral_planck
.type md2asm_create_selected_spectral_planck,%function
md2asm_create_selected_spectral_planck:
 cbz x0,.Lsps_bad_leaf
 cbz x2,.Lsps_bad_leaf
 orr x4,x0,x2
 tst x4,#7
 b.ne .Lsps_bad_leaf
 cmp x1,#240
 b.lo .Lsps_bad_leaf
 cmp x3,#520
 b.lo .Lsps_bad_leaf
 adds x4,x0,#240
 b.cs .Lsps_bad_leaf
 adds x5,x2,#520
 b.cs .Lsps_bad_leaf
 cmp x0,x5
 b.hs .Lsps_no_alias
 cmp x2,x4
 b.lo .Lsps_bad_leaf
.Lsps_no_alias:
 ldr x4,[x0,#24]
 ldr x5,[x0,#112]
 ldr x6,[x0,#176]
 orr x4,x4,x5
 orr x4,x4,x6
 cbnz x4,.Lsps_bad_leaf
 mrs x4,fpcr
 cbnz x4,.Lsps_bad_leaf
 mov x4,#0
 mov x5,#0x7ff0000000000000
.Lsps_constants:
 ldr x6,[x2,x4]
 cbz x6,.Lsps_bad_leaf
 cmp x6,x5
 b.hs .Lsps_bad_leaf
 add x4,x4,#8
 cmp x4,#32
 b.lo .Lsps_constants
 stp x29,x30,[sp,#-96]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x18,[sp,#48]
 mov x29,sp
 mov x19,x0
 mov x20,x2
 bl __errno_location
 str x0,[sp,#64]
 ldr w9,[x0]
 str w9,[sp,#72]
 mov x0,#16
 bl malloc
 cbz x0,.Lsps_failed
 mov x21,x0
 add x0,x19,#112
 mov x1,x21
 adr x2,.Lsps_bound_descriptor
 mov x3,#8
 bl .Lsps_descriptor
 adr x9,.Lsps_bounds
 ldp x10,x11,[x9]
 stp x10,x11,[x21]
 mov x0,#12
 bl malloc
 cbz x0,.Lsps_failed
 mov x21,x0
 add x0,x19,#176
 mov x1,x21
 adr x2,.Lsps_map_descriptor
 mov x3,#8
 bl .Lsps_descriptor
 mov w9,#1
 mov w10,#2
 stp w9,w10,[x21]
 str w9,[x21,#8]
 mov w9,#2
 mov w10,#201
 stp w9,w10,[x19]
 adr x9,.Lsps_temperature
 ldp x10,x11,[x9]
 stp x10,x11,[x19,#8]
 mov x0,#3216
 bl malloc
 cbz x0,.Lsps_failed
 mov x21,x0
 add x0,x19,#24
 mov x1,x21
 adr x2,.Lsps_lut_descriptor
 mov x3,#11
 bl .Lsps_descriptor
 mov x0,x21
 mov w1,#0
 mov x2,#3216
 bl memset
 mov x0,x19
 mov x1,x20
 bl md2asm_fill_selected_spectral_planck_table
 ldr x9,[sp,#64]
 ldr w10,[sp,#72]
 str w10,[x9]
 mov w0,#0
 b .Lsps_return
.Lsps_failed:
 ldr x9,[sp,#64]
 ldr w21,[x9]
 mov x0,x19
 mov x1,#240
 bl md2asm_release_selected_spectral_planck
 ldr x9,[sp,#64]
 str w21,[x9]
 mov w0,#1
.Lsps_return:
 ldp x23,x18,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#96
 ret
.Lsps_bad_leaf:
 mov w0,#2
 ret
.size md2asm_create_selected_spectral_planck,.-md2asm_create_selected_spectral_planck
/* Copy source descriptor words, then attach the owned base address. */
.Lsps_descriptor:
 mov x9,x0
 str x1,[x9],#8
 add x2,x2,#8
 sub x3,x3,#1
.Lsps_descriptor_word:
 ldr x10,[x2],#8
 str x10,[x9],#8
 subs x3,x3,#1
 b.ne .Lsps_descriptor_word
 ret
.p2align 4
.global md2asm_release_selected_spectral_planck
.type md2asm_release_selected_spectral_planck,%function
md2asm_release_selected_spectral_planck:
 cbz x0,.Lsps_release_bad
 tst x0,#7
 b.ne .Lsps_release_bad
 cmp x1,#240
 b.lo .Lsps_release_bad
 adds x2,x0,#240
 b.cs .Lsps_release_bad
 stp x29,x30,[sp,#-48]!
 stp x19,x20,[sp,#16]
 str x18,[sp,#32]
 mov x29,sp
 mov x19,x0
 mov x20,#0
.Lsps_release_owner:
 adr x9,.Lsps_owner_offsets
 ldr w9,[x9,x20,lsl#2]
 ldr x0,[x19,x9]
 cbz x0,.Lsps_release_next
 bl free
 adr x9,.Lsps_owner_offsets
 ldr w9,[x9,x20,lsl#2]
 str xzr,[x19,x9]
.Lsps_release_next:
 add x20,x20,#1
 cmp x20,#3
 b.lo .Lsps_release_owner
 mov w0,#0
 ldr x18,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#48
 ret
.Lsps_release_bad:
 mov w0,#2
 ret
.size md2asm_release_selected_spectral_planck,.-md2asm_release_selected_spectral_planck
.section .rodata
.p2align 3
.Lsps_bound_descriptor: .quad 0,-1,8,0x30100000000,8,1,1,2
.Lsps_map_descriptor: .quad 0,-1,4,0x10100000000,4,1,1,3
.Lsps_lut_descriptor: .quad 0,-3,8,0x30200000000,8,1,1,2,2,1,201
.Lsps_bounds: .double 8.0e-6,13.0e-6
.Lsps_temperature: .double 150.0,1.0
.Lsps_owner_offsets: .word 24,112,176
.section .note.GNU-stack,"",%progbits
