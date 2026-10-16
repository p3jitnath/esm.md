/* Exact SUCSLINT decision order and twelve-byte source character values.
 * Contract: skills/md2asm/references/openifs/setup/grid_field_interpolation_names.md in the repository.
 * x0 logical int32[10], x1 output character[12]; return w0=0 or2.
 * Integer-only leaf. No original data, type, callable or external service.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_grid_field_interpolation_name
.type md2asm_grid_field_interpolation_name,%function
md2asm_grid_field_interpolation_name:
 cbz x0,.Linterpolation_name_reject
 cbz x1,.Linterpolation_name_reject
 tst x0,#3
 b.ne .Linterpolation_name_reject
 mrs x9,fpcr
 cbnz x9,.Linterpolation_name_reject
 mov x2,#0
.Linterpolation_name_validate:
 ldr w9,[x0,x2,lsl#2]
 cmp w9,#1
 b.hi .Linterpolation_name_reject
 add x2,x2,#1
 cmp x2,#10
 b.lo .Linterpolation_name_validate
 ldr w10,[x0]
 cbz w10,.Linterpolation_name_nonslhd
 mov w9,#0
 ldr w10,[x0,#16]
 cbnz w10,.Linterpolation_name_store
 mov w9,#1
 ldr w10,[x0,#20]
 cbnz w10,.Linterpolation_name_store
 mov w9,#2
 b .Linterpolation_name_store
.Linterpolation_name_nonslhd:
 mov w9,#3
 ldr w10,[x0,#8]
 cbnz w10,.Linterpolation_name_store
 ldr w10,[x0,#32]
 cbz w10,.Linterpolation_name_nonlinear
 mov w9,#4
 ldr w10,[x0,#4]
 cbnz w10,.Linterpolation_name_store
 mov w9,#5
 b .Linterpolation_name_store
.Linterpolation_name_nonlinear:
 ldr w10,[x0,#36]
 cbz w10,.Linterpolation_name_nonweno
 mov w9,#6
 ldr w10,[x0,#16]
 cbnz w10,.Linterpolation_name_store
 mov w9,#7
 ldr w10,[x0,#24]
 cbnz w10,.Linterpolation_name_store
 mov w9,#8
 ldr w10,[x0,#20]
 cbnz w10,.Linterpolation_name_store
 mov w9,#9
 b .Linterpolation_name_store
.Linterpolation_name_nonweno:
 ldr w10,[x0,#12]
 cbz w10,.Linterpolation_name_nonhermite
 mov w9,#10
 ldr w10,[x0,#16]
 cbnz w10,.Linterpolation_name_store
 mov w9,#11
 ldr w10,[x0,#20]
 cbnz w10,.Linterpolation_name_store
 mov w9,#12
 b .Linterpolation_name_store
.Linterpolation_name_nonhermite:
 ldr w10,[x0,#24]
 cbz w10,.Linterpolation_name_nonqm3d
 mov w9,#13
 ldr w10,[x0,#4]
 cbnz w10,.Linterpolation_name_store
 mov w9,#14
 b .Linterpolation_name_store
.Linterpolation_name_nonqm3d:
 ldr w10,[x0,#28]
 cbz w10,.Linterpolation_name_nonqml3d
 mov w9,#15
 ldr w10,[x0,#4]
 cbnz w10,.Linterpolation_name_store
 mov w9,#16
 b .Linterpolation_name_store
.Linterpolation_name_nonqml3d:
 ldr w10,[x0,#16]
 cbz w10,.Linterpolation_name_nonqm
 mov w9,#17
 ldr w10,[x0,#4]
 cbnz w10,.Linterpolation_name_store
 mov w9,#18
 b .Linterpolation_name_store
.Linterpolation_name_nonqm:
 ldr w10,[x0,#20]
 cbz w10,.Linterpolation_name_nonqmh
 mov w9,#19
 ldr w10,[x0,#4]
 cbnz w10,.Linterpolation_name_store
 mov w9,#20
 b .Linterpolation_name_store
.Linterpolation_name_nonqmh:
 mov w9,#21
 ldr w10,[x0,#4]
 cbnz w10,.Linterpolation_name_store
 mov w9,#22
.Linterpolation_name_store:
 mov w10,#12
 umull x9,w9,w10
 adr x10,.Linterpolation_names
 add x10,x10,x9
 ldr x11,[x10]
 ldr w12,[x10,#8]
 str x11,[x1]
 str w12,[x1,#8]
 mov w0,#0
 ret
.Linterpolation_name_reject:
 mov w0,#2
 ret
.size md2asm_grid_field_interpolation_name,.-md2asm_grid_field_interpolation_name
.section .rodata
.p2align 2
.Linterpolation_names:
 .ascii "LAITQM(SLD) "
 .ascii "LAITQMH(SLD)"
 .ascii "LAITRI(SLD) "
 .ascii "LAITVSPCQM  "
 .ascii "LIN(MAD)    "
 .ascii "LIN         "
 .ascii "LAITRWENOQM "
 .ascii "LAITRWENOQM3"
 .ascii "LAITRWENOQMH"
 .ascii "LAITRWENO   "
 .ascii "LAIHVTQM    "
 .ascii "LAIHVTQMH   "
 .ascii "LAIHVT      "
 .ascii "LAITQM3(MAD)"
 .ascii "LAITQM3D    "
 .ascii "LAITQML(MAD)"
 .ascii "LAITQML3D   "
 .ascii "LAITQM(MAD) "
 .ascii "LAITQM      "
 .ascii "LAITQMH(MAD)"
 .ascii "LAITQMH     "
 .ascii "LAITRI(MAD) "
 .ascii "LAITRI      "
.section .note.GNU-stack,"",%progbits
