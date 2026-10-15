/* Read current output geometry and scalar metadata, with no numerical stage.
 * Contract: skills/md2asm/references/openifs/output/grib_output_metadata.md. x0 Geometry17096, x1 output512.
 * Typed GNU12 offsets; canonical rank-one descriptors are guarded before reads.
 */
.arch armv8.2-a
.macro metadata_address destination,symbol
 adrp \destination,:got:\symbol
 ldr \destination,[\destination,:got_lo12:\symbol]
.endm
.macro metadata_scalar destination,symbol
 metadata_address x17,\symbol
 ldr \destination,[x17]
.endm
.macro metadata_descriptor lower,upper,offset
 ldr x10,[x9]
 cbz x10,.Lmetadata_fail
 tst x10,#7
 b.ne .Lmetadata_fail
 ldr x11,[x9,#8]
 mov x12,#\offset
 cmp x11,x12
 b.ne .Lmetadata_fail
 ldr x11,[x9,#16]
 cmp x11,#8
 b.ne .Lmetadata_fail
 ldr w11,[x9,#24]
 cbnz w11,.Lmetadata_fail
 ldrb w11,[x9,#28]
 cmp w11,#1
 b.ne .Lmetadata_fail
 ldrb w11,[x9,#29]
 cmp w11,#3
 b.ne .Lmetadata_fail
 ldrh w11,[x9,#30]
 cbnz w11,.Lmetadata_fail
 ldr x11,[x9,#32]
 cmp x11,#8
 b.ne .Lmetadata_fail
 ldr x11,[x9,#40]
 cmp x11,#1
 b.ne .Lmetadata_fail
 ldr x11,[x9,#48]
 mov x12,#\lower
 cmp x11,x12
 b.ne .Lmetadata_fail
 ldr x11,[x9,#56]
 cmp x11,#\upper
 b.ne .Lmetadata_fail
.endm
.text
.p2align 4
.global md2asm_read_grib_output_metadata
.type md2asm_read_grib_output_metadata,%function
md2asm_read_grib_output_metadata:
 cbz x0,.Lmetadata_invalid
 cbz x1,.Lmetadata_invalid
 orr x9,x0,x1
 tst x9,#7
 b.ne .Lmetadata_invalid
 sub sp,sp,#528
 str x19,[sp,#512]
 str x20,[sp,#520]
 mov x19,x0
 mov x20,x1
 mov x9,sp
 mov x10,#32
.Lmetadata_zero:
 stp xzr,xzr,[x9],#16
 subs x10,x10,#1
 b.ne .Lmetadata_zero
 mov x9,#4872
 ldr w10,[x19,x9]
 cmp w10,#32
 b.ne .Lmetadata_fail
 mov x9,#4936
 ldr w10,[x19,x9]
 cmp w10,#64
 b.ne .Lmetadata_fail
 mov x9,#5172
 ldr w10,[x19,x9]
 cmp w10,#21
 b.ne .Lmetadata_fail
 mov x9,#5224
 ldr w10,[x19,x9]
 cmp w10,#19
 b.ne .Lmetadata_fail
 mov x9,#7376
 ldr w10,[x19,x9]
 cmp w10,#2048
 b.ne .Lmetadata_fail
 mov x9,#7524
 ldr w10,[x19,x9]
 cbnz w10,.Lmetadata_fail
 mov x9,#7520
 ldr w10,[x19,x9]
 cmp w10,#1
 b.hi .Lmetadata_fail
 str x10,[sp,#80]
 mov x9,#7512
 ldr x10,[x19,x9]
 movz x11,#0x3ff0,lsl#48
 cmp x10,x11
 b.ne .Lmetadata_fail
 str x10,[sp,#88]
 mov x10,#21
 str x10,[sp,#40]
 mov x10,#32
 str x10,[sp,#48]
 mov x10,#64
 str x10,[sp,#56]
 mov x10,#19
 str x10,[sp,#64]
 metadata_scalar w10,__yomct0_MOD_nstepini
 cbnz w10,.Lmetadata_fail
 metadata_scalar w10,__yomct0_MOD_lobsc1
 cbnz w10,.Lmetadata_fail
 metadata_scalar w10,__yomvareps_MOD_lvareps
 cbnz w10,.Lmetadata_fail
 metadata_scalar w10,__yomgrib_MOD_nlocgrb
 cmp w10,#1
 b.ne .Lmetadata_fail
 str x10,[sp,#24]
 metadata_scalar w10,__yomgrib_MOD_nstream
 cmp w10,#1025
 b.ne .Lmetadata_fail
 str x10,[sp,#32]
 metadata_scalar w10,__yomgrib_MOD_ncycle
 sxtw x10,w10
 str x10,[sp,#16]
 metadata_scalar w10,__yomrip0_MOD_nindat
 sxtw x10,w10
 str x10,[sp]
 metadata_scalar w10,__yomrip0_MOD_nsssss
 mov w11,#3600
 udiv w12,w10,w11
 msub w13,w12,w11,w10
 cbnz w13,.Lmetadata_fail
 cmp w12,#23
 b.hi .Lmetadata_fail
 mov w11,#100
 mul w10,w12,w11
 str x10,[sp,#8]
 metadata_address x17,__yomgrib_MOD_ctype
 ldrh w10,[x17]
 mov w11,#0x6366
 cmp w10,w11
 b.ne .Lmetadata_fail
 strh w10,[sp,#112]
 metadata_address x17,__yomgrib_MOD_cfclass
 ldrh w10,[x17]
 mov w11,#0x6472
 cmp w10,w11
 b.ne .Lmetadata_fail
 strh w10,[sp,#120]
 metadata_address x17,__yomct0_MOD_cnmexp
 ldr w10,[x17]
 str w10,[sp,#128]
 mov x9,#4744
 add x9,x19,x9
 metadata_descriptor -1,34,1
 ldr x11,[x10,#16]
 str x11,[sp,#96]
 ldr x11,[x10,#264]
 str x11,[sp,#104]
 ldr x13,[x19,#3240]
 cbz x13,.Lmetadata_fail
 tst x13,#7
 b.ne .Lmetadata_fail
 add x9,x13,#128
 metadata_descriptor 0,19,0
 mov x14,x10
 add x9,x13,#64
 metadata_descriptor 0,19,0
 mov x15,x10
 add x9,sp,#144
 mov x11,#20
.Lmetadata_A:
 ldr x12,[x14],#8
 str x12,[x9],#8
 subs x11,x11,#1
 b.ne .Lmetadata_A
 mov x11,#20
.Lmetadata_B:
 ldr x12,[x15],#8
 str x12,[x9],#8
 subs x11,x11,#1
 b.ne .Lmetadata_B
 mov x9,sp
 mov x10,x20
 mov x11,#32
.Lmetadata_copy:
 ldp x12,x13,[x9],#16
 stp x12,x13,[x10],#16
 subs x11,x11,#1
 b.ne .Lmetadata_copy
 mov w0,#0
 b .Lmetadata_restore
.Lmetadata_fail:
 mov w0,#2
.Lmetadata_restore:
 ldr x19,[sp,#512]
 ldr x20,[sp,#520]
 add sp,sp,#528
 ret
.Lmetadata_invalid:
 mov w0,#2
 ret
.size md2asm_read_grib_output_metadata,.-md2asm_read_grib_output_metadata
.section .note.GNU-stack,"",%progbits
