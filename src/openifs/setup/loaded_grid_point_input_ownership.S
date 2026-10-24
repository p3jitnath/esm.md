/* Compose unchanged input owners. Save x18 across public-library children.
 * x0 spectral path,x1 surface path,x2 upper-air path,x3 namelist path,
 * x4 alias destinations120,x5 caller-owned zero holder24.
 * Holder slots: startup,Geometry sidecar,initialized model. Return child status.
 * On failure retained slots identify exact owners for the release entry. */
.text
.p2align 4
.global md2asm_create_loaded_grid_point_inputs
.type md2asm_create_loaded_grid_point_inputs,%function
md2asm_create_loaded_grid_point_inputs:
 stp x29,x30,[sp,#-96]!
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 stp x22,x23,[sp,#48]
 stp x24,x25,[sp,#64]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 mov x23,x4
 mov x24,x5
 cbz x19,.Linput_bad
 cbz x20,.Linput_bad
 cbz x21,.Linput_bad
 cbz x22,.Linput_bad
 cbz x23,.Linput_bad
 cbz x24,.Linput_bad
 orr x9,x23,x24
 tst x9,#7
 b.ne .Linput_bad
 adds x9,x24,#24
 b.cs .Linput_bad
 adds x10,x23,#120
 b.cs .Linput_bad
 cmp x23,x9
 b.hs 1f
 cmp x24,x10
 b.lo .Linput_bad
1:
 ldp x9,x10,[x24]
 ldr x11,[x24,#16]
 orr x9,x9,x10
 orr x9,x9,x11
 cbnz x9,.Linput_bad
 mov x2,x22
 mov x3,x24
 bl md2asm_create_operational_startup_inputs
 cbnz w0,.Linput_return
 ldr x9,[x24]
 ldr x0,[x9,#8]
 add x1,x9,#120
 mov x10,#9448
 add x2,x9,x10
 ldr x3,[x9,#16]
 ldr x4,[x9,#24]
 add x5,x24,#8
 bl md2asm_complete_owned_distributed_geometry
 cbnz w0,.Linput_return
 ldp x0,x1,[x24]
 mov x2,x19
 mov x3,x20
 mov x4,x21
 mov x5,x23
 add x6,x24,#16
 bl md2asm_create_initialized_operational_model
 b .Linput_return
.Linput_bad:
 mov w0,#2
.Linput_return:
 ldp x24,x25,[sp,#64]
 ldp x22,x23,[sp,#48]
 ldp x20,x21,[sp,#32]
 ldp x18,x19,[sp,#16]
 ldp x29,x30,[sp],#96
 ret
.size md2asm_create_loaded_grid_point_inputs,.-md2asm_create_loaded_grid_point_inputs
.global md2asm_release_loaded_grid_point_inputs
.type md2asm_release_loaded_grid_point_inputs,%function
md2asm_release_loaded_grid_point_inputs:
 stp x29,x30,[sp,#-48]!
 stp x18,x19,[sp,#16]
 str x20,[sp,#32]
 mov x19,x0
 cbz x19,.Lrelease_empty
 tst x19,#7
 b.ne .Lrelease_bad
 adds x9,x19,#24
 b.cs .Lrelease_bad
 add x0,x19,#16
 bl md2asm_release_initialized_operational_model
 cbnz w0,.Lrelease_return
 ldr x0,[x19,#8]
 cbz x0,1f
 bl md2asm_release_owned_distributed_geometry
 cbnz w0,.Lrelease_return
 str xzr,[x19,#8]
1:
 ldr x0,[x19]
 cbz x0,.Lrelease_empty
 bl md2asm_release_operational_startup_inputs
 cbnz w0,.Lrelease_return
 str xzr,[x19]
.Lrelease_empty:
 mov w0,#0
 b .Lrelease_return
.Lrelease_bad:
 mov w0,#2
.Lrelease_return:
 ldr x20,[sp,#32]
 ldp x18,x19,[sp,#16]
 ldp x29,x30,[sp],#48
 ret
.size md2asm_release_loaded_grid_point_inputs,.-md2asm_release_loaded_grid_point_inputs
.section .note.GNU-stack,"",%progbits
