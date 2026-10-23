/* Contract: skills/md2asm/references/openifs/setup/distributed_spectral_field_storage.md. */
/* Bind live accepted SUMP/SULAP owners to the complete spectral constructor.
 * x0 record2992, x1 cap, x2 Geometry, x3 cap, x4 partition4096, x5 cap,
 * x6 IDs20, x7 dummy24. All borrowed owners remain live during this call. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_owned_distributed_spectral_field
.type md2asm_initialize_owned_distributed_spectral_field,%function
md2asm_initialize_owned_distributed_spectral_field:
 cbz x2,.Ldsbind_bad
 cbz x4,.Ldsbind_bad
 orr x9,x2,x4
 tst x9,#7
 b.ne .Ldsbind_bad
 mov w9,#17096
 cmp x3,x9
 b.lo .Ldsbind_bad
 cmp x5,#4096
 b.lo .Ldsbind_bad
 adds x9,x2,x9
 b.cs .Ldsbind_bad
 adds x9,x4,#4096
 b.cs .Ldsbind_bad
 ldr x9,[x4]
 cmp x9,x2
 b.ne .Ldsbind_bad
 ldr x9,[x4,#8]
 ldr x10,.Ldsbind_cookie
 cmp x9,x10
 b.ne .Ldsbind_bad
 ldr w9,[x4,#16]
 cmp w9,#3
 b.ne .Ldsbind_bad
 stp x29,x30,[sp,#-256]!
 mov x29,sp
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 stp x22,x23,[sp,#48]
 stp x24,x25,[sp,#64]
 stp x26,x27,[sp,#80]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x4
 mov x23,x6
 mov x24,x7
 add x25,sp,#96
 ldp w9,w10,[x22,#64]
 stp w9,w10,[x25]
 ldp w9,w10,[x22,#32]
 stp w9,w10,[x25,#8]
 adr x26,.Ldsbind_maps
 add x27,x25,#16
 mov w15,#8
.Ldsbind_map:
 ldp w9,w10,[x26],#8
 add x9,x21,x9
 ldr x11,[x9]
 cbz x11,.Ldsbind_refuse
 ldr x12,[x9,#16]
 cmp x12,#4
 b.ne .Ldsbind_refuse
 ldr x12,[x9,#40]
 cmp x12,#1
 b.ne .Ldsbind_refuse
 ldp x12,x13,[x9,#48]
 sub x13,x13,x12
 add x13,x13,#1
 lsl x13,x13,#2
 cmp x13,x10
 b.ne .Ldsbind_refuse
 stp x11,x10,[x27],#16
 subs w15,w15,#1
 b.ne .Ldsbind_map
 ldr w9,[x21,#5200]
 ldr x10,[x25,#128]
 ldr w11,[x25]
 sub w11,w11,#1
 cmp w11,#1
 b.hi .Ldsbind_refuse
 ldr w10,[x10,x11,lsl#2]
 stp w9,w10,[x25,#144]
 str xzr,[x25,#152]
 mov x0,x19
 mov x1,x20
 mov x2,x25
 mov w3,#160
 mov x4,x23
 mov x5,x24
 bl md2asm_initialize_distributed_spectral_field
 b .Ldsbind_return
.Ldsbind_refuse:
 mov w0,#2
.Ldsbind_return:
 ldp x18,x19,[sp,#16]
 ldp x20,x21,[sp,#32]
 ldp x22,x23,[sp,#48]
 ldp x24,x25,[sp,#64]
 ldp x26,x27,[sp,#80]
 ldp x29,x30,[sp],#256
 ret
.Ldsbind_bad:
 mov w0,#2
 ret
.size md2asm_initialize_owned_distributed_spectral_field,.-md2asm_initialize_owned_distributed_spectral_field
.global md2asm_release_distributed_spectral_field
.type md2asm_release_distributed_spectral_field,%function
md2asm_release_distributed_spectral_field:
 b md2asm_release_serial_spectral_field
.size md2asm_release_distributed_spectral_field,.-md2asm_release_distributed_spectral_field
.section .rodata
.p2align 3
.Ldsbind_cookie: .quad 0x445054585f4f574e
.Ldsbind_maps:
 .word 3912,2560
 .word 5448,5120
 .word 5384,8
 .word 5832,12
 .word 5896,12
 .word 6024,8
 .word 3720,5120
 .word 5256,8
.section .note.GNU-stack,"",%progbits
