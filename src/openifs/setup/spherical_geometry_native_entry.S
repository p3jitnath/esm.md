// Original SUGEM2 ABI: x0 live Geometry17096. See skills/md2asm/references/openifs/setup/spherical_geometry_setup.md.
// Live initialized RA/RPI/ROMEGA and process indices are explicit compatibility
// inputs. Geometry supplies stretch and map scalars; no original callable is used.
.text
.p2align 4
.global sugem2_
.type sugem2_,%function
sugem2_:
 cbz x0,.Lnative_fail
 tst x0,#7
 b.ne .Lnative_fail
 mov x9,#17096
 adds x9,x0,x9
 b.cs .Lnative_fail
 stp x29,x30,[sp,#-96]!
 mov x29,sp
 str x18,[sp,#16]
 ldr x9,[x0,#7512]
 str x9,[sp,#32]
 ldr x9,[x0,#7544]
 str x9,[sp,#40]
 ldr x9,[x0,#7552]
 str x9,[sp,#48]
 adrp x9,:got:__yomcst_MOD_ra
 ldr x9,[x9,:got_lo12:__yomcst_MOD_ra]
 ldr x10,[x9]
 str x10,[sp,#56]
 adrp x9,:got:__yomcst_MOD_rpi
 ldr x9,[x9,:got_lo12:__yomcst_MOD_rpi]
 ldr x10,[x9]
 str x10,[sp,#64]
 adrp x9,:got:__yomcst_MOD_romega
 ldr x9,[x9,:got_lo12:__yomcst_MOD_romega]
 ldr x10,[x9]
 str x10,[sp,#72]
 adrp x9,:got:__yommp0_MOD_mysetw
 ldr x9,[x9,:got_lo12:__yommp0_MOD_mysetw]
 ldr w10,[x9]
 str w10,[sp,#80]
 adrp x9,:got:__yommp0_MOD_my_region_ew
 ldr x9,[x9,:got_lo12:__yommp0_MOD_my_region_ew]
 ldr w10,[x9]
 str w10,[sp,#84]
 add x1,sp,#32
 add x2,sp,#80
 bl md2asm_initialize_spherical_geometry
 cbnz w0,.Lnative_fail
 adrp x9,.Lspherical_geometry_calls
 ldr x10,[x9,:lo12:.Lspherical_geometry_calls]
 add x10,x10,#1
 str x10,[x9,:lo12:.Lspherical_geometry_calls]
 ldr x18,[sp,#16]
 ldp x29,x30,[sp],#96
 ret
.Lnative_fail:
 b abort
.size sugem2_,.-sugem2_
.global md2asm_spherical_geometry_native_count_get
.type md2asm_spherical_geometry_native_count_get,%function
md2asm_spherical_geometry_native_count_get:
 adrp x9,.Lspherical_geometry_calls
 ldr x0,[x9,:lo12:.Lspherical_geometry_calls]
 ret
.size md2asm_spherical_geometry_native_count_get,.-md2asm_spherical_geometry_native_count_get
.bss
.p2align 3
.Lspherical_geometry_calls:
 .zero 8
.section .note.GNU-stack,"",%progbits
