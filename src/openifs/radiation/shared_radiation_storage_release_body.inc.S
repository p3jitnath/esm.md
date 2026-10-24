.global MD2ASM_RAD_RELEASE_ENTRY
.type MD2ASM_RAD_RELEASE_ENTRY,%function
MD2ASM_RAD_RELEASE_ENTRY:
#define MD2ASM_RAD_STORAGE_BAD .Lrelease_bad
#define MD2ASM_RAD_STORAGE_AGREE .Lrelease_agree
#define MD2ASM_RAD_STORAGE_RETURN .Lrelease_return
#define MD2ASM_RAD_STORAGE_ABORT .Lrelease_abort
#include "shared_radiation_storage_release_admission.inc.S"
#undef MD2ASM_RAD_STORAGE_BAD
#undef MD2ASM_RAD_STORAGE_AGREE
#undef MD2ASM_RAD_STORAGE_RETURN
#undef MD2ASM_RAD_STORAGE_ABORT
 mov x0,x20
 bl trans_release_
 ldr x0,[x20,#1096]
 bl free
 str xzr,[x20,#1096]
 ldr x0,[x20,#1032]
 bl free
 str xzr,[x20,#1032]
#ifndef MD2ASM_RAD_STORAGE_ZMU_RETIRED
 ldr x0,[x19,#16]
 bl free
#endif
 ldr x0,[x20,#968]
 bl free
 str xzr,[x20,#968]
 ldr x0,[x20,#344]
 bl free
 str xzr,[x20,#344]
 ldr x0,[x20,#280]
 bl free
 str xzr,[x20,#280]
 ldr x0,[x20,#216]
 bl free
 str xzr,[x20,#216]
 ldr x0,[x20,#624]
 bl free
 str xzr,[x20,#624]
 ldr x0,[x20,#536]
 bl free
 str xzr,[x20,#536]
 str xzr,[x19,#0]
 str xzr,[x19,#8]
 str xzr,[x19,#16]
 str xzr,[x19,#24]
 str xzr,[x19,#32]
 str xzr,[x19,#40]
 str xzr,[x19,#48]
 str xzr,[x19,#56]
 str xzr,[x19,#64]
 str xzr,[x19,#72]
 str xzr,[x19,#80]
 str xzr,[x19,#88]
 str xzr,[x19,#96]
 str xzr,[x19,#104]
 str xzr,[x19,#112]
 str xzr,[x19,#120]
 str xzr,[x19,#128]
 str xzr,[x19,#136]
 str xzr,[x19,#144]
 str xzr,[x19,#152]
 str wzr,[x20]
 mov w0,#0
.Lrelease_return:
 ldp x9,x10,[sp,#64]
 msr fpcr,x9
 msr fpsr,x10
 str w22,[x21]
 ldr x18,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#112
 ret
.Lrelease_abort:
 bl abort
 brk #0
.size MD2ASM_RAD_RELEASE_ENTRY,.-MD2ASM_RAD_RELEASE_ENTRY
.ltorg
