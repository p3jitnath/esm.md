/* Direct VAL923 constants. Contract: skills/md2asm/references/openifs/setup/land_surface_reference_parameters.md.
 * Parent x0 output272,x1 capacity,w2 LDNEW. Return0/2. Raw x0 output,w1 LDNEW.
 * No arithmetic, allocation or callable dependency. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_land_surface_reference_parameters
.type md2asm_initialize_land_surface_reference_parameters,%function
md2asm_initialize_land_surface_reference_parameters:
 cbz x0,.Llandref_bad
 tst x0,#7
 b.ne .Llandref_bad
 cmp x1,#272
 b.lo .Llandref_bad
 adds x3,x0,#272
 b.cs .Llandref_bad
 cmp w2,#1
 b.hi .Llandref_bad
 mov w1,w2
 b md2asm_set_land_surface_reference_parameters_raw
.Llandref_bad:
 mov w0,#2
 ret
.size md2asm_initialize_land_surface_reference_parameters,.-md2asm_initialize_land_surface_reference_parameters
.p2align 4
.global md2asm_set_land_surface_reference_parameters_raw
.type md2asm_set_land_surface_reference_parameters_raw,%function
md2asm_set_land_surface_reference_parameters_raw:
 adr x9,.Llandref_value_0
 ldr x10,[x9]
 str x10,[x0,#0] /* SMASK */
 adr x9,.Llandref_value_1
 ldr x10,[x9]
 str x10,[x0,#8] /* SMANQ */
 adr x9,.Llandref_value_2
 ldr w10,[x9]
 str w10,[x0,#16] /* NTPMER */
 adr x9,.Llandref_value_3
 ldr w10,[x9]
 str w10,[x0,#20] /* NTPGLA */
 adr x9,.Llandref_value_4
 ldr w10,[x9]
 str w10,[x0,#24] /* NTPDES */
 adr x9,.Llandref_value_5
 ldr w10,[x9]
 str w10,[x0,#28] /* NTPLAC */
 adr x9,.Llandref_value_6
 ldr x10,[x9]
 str x10,[x0,#32] /* SZZ0N */
 adr x9,.Llandref_value_7
 ldr x10,[x9]
 str x10,[x0,#40] /* SZZ0M */
 adr x9,.Llandref_value_8
 ldr x10,[x9]
 str x10,[x0,#48] /* SZZ0B */
 adr x9,.Llandref_value_9
 ldr x10,[x9]
 str x10,[x0,#56] /* SZZ0U */
 adr x9,.Llandref_value_10
 ldr x10,[x9]
 str x10,[x0,#64] /* SZZ0D */
 adr x9,.Llandref_value_11
 ldr x10,[x9]
 str x10,[x0,#72] /* STHER */
 adr x9,.Llandref_value_12
 ldr x10,[x9]
 str x10,[x0,#80] /* SALBN */
 adr x9,.Llandref_value_13
 ldr x10,[x9]
 str x10,[x0,#88] /* SALBX */
 adr x9,.Llandref_value_14
 ldr x10,[x9]
 str x10,[x0,#96] /* SALBM */
 adr x9,.Llandref_value_15
 ldr x10,[x9]
 str x10,[x0,#104] /* SALBG */
 adr x9,.Llandref_value_16
 ldr x10,[x9]
 str x10,[x0,#112] /* SALBB */
 adr x9,.Llandref_value_17
 ldr x10,[x9]
 str x10,[x0,#120] /* SALBD */
 adr x9,.Llandref_value_18
 ldr x10,[x9]
 str x10,[x0,#128] /* SEMIN */
 adr x9,.Llandref_value_19
 ldr x10,[x9]
 str x10,[x0,#136] /* SEMIX */
 adr x9,.Llandref_value_20
 ldr x10,[x9]
 str x10,[x0,#144] /* SEMIM */
 adr x9,.Llandref_value_21
 ldr x10,[x9]
 str x10,[x0,#152] /* SEMIG */
 adr x9,.Llandref_value_22
 ldr x10,[x9]
 str x10,[x0,#160] /* SEMIB */
 adr x9,.Llandref_value_23
 ldr x10,[x9]
 str x10,[x0,#168] /* SEMID */
 adr x9,.Llandref_value_24
 ldr x10,[x9]
 str x10,[x0,#176] /* SDEPN */
 adr x9,.Llandref_value_25
 ldr x10,[x9]
 str x10,[x0,#184] /* SDEPX */
 adr x9,.Llandref_value_26
 ldr x10,[x9]
 str x10,[x0,#192] /* SDEPD */
 adr x9,.Llandref_value_27
 ldr x10,[x9]
 str x10,[x0,#200] /* SARGN */
 adr x9,.Llandref_value_28
 ldr x10,[x9]
 str x10,[x0,#208] /* SARGX */
 adr x9,.Llandref_value_29
 ldr x10,[x9]
 str x10,[x0,#216] /* SARGD */
 adr x9,.Llandref_value_30
 ldr x10,[x9]
 str x10,[x0,#224] /* SSABN */
 adr x9,.Llandref_value_31
 ldr x10,[x9]
 str x10,[x0,#232] /* SSABX */
 adr x9,.Llandref_value_32
 ldr x10,[x9]
 str x10,[x0,#240] /* SSABD */
 adr x9,.Llandref_value_33
 ldr x10,[x9]
 str x10,[x0,#248] /* SRSMX */
 adr x9,.Llandref_value_34
 ldr x10,[x9]
 str x10,[x0,#256] /* SRSMN */
 adr x9,.Llandref_value_35
 ldr x10,[x9]
 str x10,[x0,#264] /* SRSMD */
 cbz w1,.Llandref_done
 adr x9,.Llandref_new_albedo
 ldp x10,x11,[x9]
 str x10,[x0,#80]
 str x11,[x0,#88]
.Llandref_done:
 mov w0,#0
 ret
.size md2asm_set_land_surface_reference_parameters_raw,.-md2asm_set_land_surface_reference_parameters_raw
.section .rodata
.p2align 3
.Llandref_value_0: .quad 0x3fe0000000000000
.Llandref_value_1: .quad 0xc0c3870000000000
.Llandref_value_2: .quad 0x0000000000000001
.Llandref_value_3: .quad 0x0000000000000002
.Llandref_value_4: .quad 0x0000000000000003
.Llandref_value_5: .quad 0x0000000000000005
.Llandref_value_6: .quad 0x3f50624dd2f1a9fc
.Llandref_value_7: .quad 0x3f50624dd2f1a9fc
.Llandref_value_8: .quad 0x3f50624dd2f1a9fc
.Llandref_value_9: .quad 0x4004000000000000
.Llandref_value_10: .quad 0x3f50624dd2f1a9fc
.Llandref_value_11: .quad 0x3fb999999999999a
.Llandref_value_12: .quad 0x3fb1eb851eb851ec
.Llandref_value_13: .quad 0x3fe6666666666666
.Llandref_value_14: .quad 0x3fb1eb851eb851ec
.Llandref_value_15: .quad 0x3fe8000000000000
.Llandref_value_16: .quad 0x3fe4cccccccccccd
.Llandref_value_17: .quad 0x3fb999999999999a
.Llandref_value_18: .quad 0x3feccccccccccccd
.Llandref_value_19: .quad 0x3ff0000000000000
.Llandref_value_20: .quad 0x3feeb851eb851eb8
.Llandref_value_21: .quad 0x3fef5c28f5c28f5c
.Llandref_value_22: .quad 0x3fef0a3d70a3d70a
.Llandref_value_23: .quad 0x3fee2d0e56041893
.Llandref_value_24: .quad 0x3fb999999999999a
.Llandref_value_25: .quad 0x4020000000000000
.Llandref_value_26: .quad 0x3fb999999999999a
.Llandref_value_27: .quad 0x4008000000000000
.Llandref_value_28: .quad 0x404d000000000000
.Llandref_value_29: .quad 0x4008000000000000
.Llandref_value_30: .quad 0x4018000000000000
.Llandref_value_31: .quad 0x4057000000000000
.Llandref_value_32: .quad 0x4057000000000000
.Llandref_value_33: .quad 0x40b3880000000000
.Llandref_value_34: .quad 0x3ff0000000000000
.Llandref_value_35: .quad 0x40b3880000000000
.Llandref_new_albedo: .double 0.05,0.80
.section .note.GNU-stack,"",%progbits
