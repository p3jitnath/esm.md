// Complete cloud component. Contract: skills/md2fort-gpu/references/openifs/physics/cloud_microphysics_columns.md
.text
.p2align 2
.global md2asm_cloud_columns_launch
.hidden md2asm_cloud_columns_launch
.type md2asm_cloud_columns_launch,%function
md2asm_cloud_columns_launch:
 sub sp,sp,#96
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 str x18,[sp,#80]
 mov x29,sp
 mov x25,x0
 mov x19,x1
 mov x20,x2
 mrs x24,fpcr
 mrs x23,fpsr
 bl __errno_location
 mov x21,x0
 ldr w22,[x21]
 ldr x9,[x19,#64]
 ldr w9,[x9]
 cbz w9,.Lcloud_columns_original
.macro CLOUD_INPUT_STATUS
 msr fpcr,x24
 msr fpsr,x23
 str w22,[x21]
 mov x1,x19
 mov x2,x20
 mov w5,#0
.endm
 CLOUD_INPUT_STATUS
 adrp x0,.Lcloud_prepare
 add x0,x0,:lo12:.Lcloud_prepare
 mov w3,#1
 mov w4,#1
 bl md2asm_openifs_gpu_launch
 cbnz w0,.Lcloud_columns_return
 CLOUD_INPUT_STATUS
 adrp x0,.Lcloud_workers
 add x0,x0,:lo12:.Lcloud_workers
 mov w3,#32
 mov w4,#1
 bl md2asm_openifs_gpu_launch
 cbnz w0,.Lcloud_columns_return
 CLOUD_INPUT_STATUS
 adrp x0,.Lcloud_join
 add x0,x0,:lo12:.Lcloud_join
 mov w3,#1
 mov w4,#1
 bl md2asm_openifs_gpu_launch
 b .Lcloud_columns_return
.Lcloud_columns_original:
 CLOUD_INPUT_STATUS
 mov x0,x25
 mov w3,#1
 mov w4,#128
 bl md2asm_openifs_gpu_launch
.Lcloud_columns_return:
 ldr x18,[sp,#80]
 ldp x25,x26,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#96
 ret
.size md2asm_cloud_columns_launch,.-md2asm_cloud_columns_launch
.section .rodata
.Lcloud_prepare:.asciz "md2asm_gpu_cloud_columns_prepare"
.Lcloud_workers:.asciz "md2asm_gpu_cloud_columns_workers"
.Lcloud_join:.asciz "md2asm_gpu_cloud_columns_join"
.section .note.GNU-stack,"",%progbits
