/* Owned selected surface-input configuration, revision 1.
 * Contract: skills/md2asm/references/openifs/input/owned_surface_input_configuration.md.
 * x0 owned 520-byte constants, x1 writable 2304-byte output, x2 capacity.
 * Source tables come from SUSVEG, with selected SUSSOIL/SUPHEC controls. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_surface_input_configuration
.type md2asm_initialize_surface_input_configuration,%function
md2asm_initialize_surface_input_configuration:
 cbz x0,.Lsurface_config_reject
 cbz x1,.Lsurface_config_reject
 orr x9,x0,x1
 tst x9,#7
 b.ne .Lsurface_config_reject
 cmp x2,#2304
 b.lo .Lsurface_config_reject
 adds x9,x0,#520
 b.cs .Lsurface_config_reject
 adds x10,x1,#2304
 b.cs .Lsurface_config_reject
 cmp x0,x10
 b.hs .Lsurface_config_separate
 cmp x1,x9
 b.lo .Lsurface_config_reject
.Lsurface_config_separate:
 ldr w9,[x0,#512]
 cmp w9,#1
 b.ne .Lsurface_config_reject
 mrs x9,fpcr
 cbnz x9,.Lsurface_config_reject
 mov x9,x1
 mov w10,#144
.Lsurface_config_clear:
 stp xzr,xzr,[x9],#16
 subs w10,w10,#1
 b.ne .Lsurface_config_clear
 mov x9,#2048
 str x9,[x1,#8]
 mov x9,#20
 str x9,[x1,#16]
 str x9,[x1,#112]
 str x9,[x1,#128]
 mov x9,#1
 str x9,[x1,#24]
 str x9,[x1,#40]
 str x9,[x1,#48]
 str x9,[x1,#136]
 ldr x9,[x0,#112]
 str x9,[x1,#64]
 ldr x9,[x0,#368]
 str x9,[x1,#72]
 ldr d0,[x0,#360]
 adrp x9,.Lsurface_constant_literals
 add x9,x9,:lo12:.Lsurface_constant_literals
 ldr d1,[x9]
 fdiv d0,d0,d1
 str d0,[x1,#80]
 ldp x10,x11,[x9,#8]
 stp x10,x11,[x1,#88]
 add x9,x9,#24
 add x10,x1,#256
 add x11,x1,#1280
 mov w12,#21
.Lsurface_config_tables:
 ldr x13,[x9]
 ldr x14,[x9,#168]
 str x13,[x10],#8
 str x14,[x11],#8
 add x9,x9,#8
 subs w12,w12,#1
 b.ne .Lsurface_config_tables
 mov w0,#0
 ret
.Lsurface_config_reject:
 mov w0,#2
 ret
.size md2asm_initialize_surface_input_configuration,.-md2asm_initialize_surface_input_configuration
.section .rodata
.p2align 3
.Lsurface_constant_literals:
 .quad 0x4059000000000000
 .quad 0x3fc999999999999a
 .quad 0x3f947ae147ae147b
 .quad 0x0000000000000000
 .quad 0x3feccccccccccccd
 .quad 0x3feb333333333333
 .quad 0x3feccccccccccccd
 .quad 0x3feccccccccccccd
 .quad 0x3feccccccccccccd
 .quad 0x3fefae147ae147ae
 .quad 0x3fe6666666666666
 .quad 0x0000000000000000
 .quad 0x3fe0000000000000
 .quad 0x3feccccccccccccd
 .quad 0x3fb999999999999a
 .quad 0x0000000000000000
 .quad 0x3fe3333333333333
 .quad 0x0000000000000000
 .quad 0x0000000000000000
 .quad 0x3fe0000000000000
 .quad 0x3fe0000000000000
 .quad 0x3feccccccccccccd
 .quad 0x3feccccccccccccd
 .quad 0x3fe3333333333333
 .quad 0x3fe0000000000000
 .quad 0x4008000000000000
 .quad 0x4000000000000000
 .quad 0x4014000000000000
 .quad 0x4014000000000000
 .quad 0x4014000000000000
 .quad 0x4018000000000000
 .quad 0x4000000000000000
 .quad 0x3fe0000000000000
 .quad 0x3ff0000000000000
 .quad 0x4008000000000000
 .quad 0x3fe0000000000000
 .quad 0x0000000000000000
 .quad 0x4010000000000000
 .quad 0x0000000000000000
 .quad 0x0000000000000000
 .quad 0x4008000000000000
 .quad 0x3ff8000000000000
 .quad 0x4014000000000000
 .quad 0x4004000000000000
 .quad 0x4010000000000000
.section .note.GNU-stack,"",%progbits
