/* Shared AArch64 frame and external-math obligations. */
.macro LAND_ENTER bytes
 stp x29,x30,[sp,#-\bytes]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 stp d8,d9,[sp,#112]
 stp d10,d11,[sp,#128]
 stp d12,d13,[sp,#144]
 stp d14,d15,[sp,#160]
 mov x29,sp
.endm
.macro LAND_LEAVE bytes
 ldp d8,d9,[sp,#112]
 ldp d10,d11,[sp,#128]
 ldp d12,d13,[sp,#144]
 ldp d14,d15,[sp,#160]
 ldr x18,[sp,#96]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 .if \bytes > 504
 ldp x29,x30,[sp]
 add sp,sp,#\bytes
 .else
 ldp x29,x30,[sp],#\bytes
 .endif
 ret
.endm
.macro LAND_MATH name
 bl \name
 ldr x18,[x29,#96]
.endm
