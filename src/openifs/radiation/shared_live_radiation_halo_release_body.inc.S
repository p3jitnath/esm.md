.p2align 4
.global MD2ASM_HALO_RELEASE_ENTRY
.type MD2ASM_HALO_RELEASE_ENTRY,%function
MD2ASM_HALO_RELEASE_ENTRY:
 sub sp,sp,#2048
 stp x29,x30,[sp,#16]
 stp x19,x20,[sp,#32]
 stp x21,x22,[sp,#48]
 stp x23,x24,[sp,#64]
 stp x25,x26,[sp,#80]
 stp x27,x28,[sp,#96]
 str x18,[sp,#112]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 bl __errno_location
 mov x28,x0
 mov x0,x19
 mov x1,x20
 bl MD2ASM_HALO_POINT_VALIDATOR
 cbnz w0,.Lrelease_halo_return
 ldr x21,[x19,#8]
 mov x0,x21
 mov x1,#1376
 bl md2asm_validate_radiation_latitude_owners
 mov w9,w0
 cbnz w0,3f
 mov x0,x21
 mov x1,x19
 bl md2asm_validate_live_latitude_owner_separation
 mov w9,w0
3:
 ldr x10,[x21,#1160]
 cbz x10,1f
 ldr x10,[x21,#1288]
 cbnz x10,2f
1:
 mov w9,#2
2:
 str w9,[sp,#128]
 bl .Lhalo_agree
 ldr w0,[sp,#132]
 cbnz w0,.Lrelease_halo_return
#ifdef MD2ASM_HALO_VALIDATE_ONLY
 mov w0,#0
 b .Lrelease_halo_return
#else
 mov x0,x21
 mov x1,#1376
 bl md2asm_release_runtime_radiation_latitude_interpolation
 cbnz w0,.Lhalo_abort
 ldr x9,=0x52414453544f5232
 str x9,[x19]
 mov x0,x19
 mov x1,x20
 bl md2asm_release_retired_radiation_setup
 cbnz w0,.Lhalo_abort
#endif
.Lrelease_halo_return:
 ldr x18,[sp,#112]
 ldp x27,x28,[sp,#96]
 ldp x25,x26,[sp,#80]
 ldp x23,x24,[sp,#64]
 ldp x21,x22,[sp,#48]
 ldp x19,x20,[sp,#32]
 ldp x29,x30,[sp,#16]
 add sp,sp,#2048
 ret
.size MD2ASM_HALO_RELEASE_ENTRY,.-MD2ASM_HALO_RELEASE_ENTRY
