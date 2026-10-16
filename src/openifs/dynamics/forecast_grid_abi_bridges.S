/* CTVTOT and GPRCP saved-register bridges.
 * Contract: skills/md2asm/references/openifs/dynamics/retained_forecast_callers.md.
 * Original by-address interfaces and frozen child order are retained. */
.text
.p2align 4
.global md2asm_scan_ctvtot_7358525
.type md2asm_scan_ctvtot_7358525,%function
md2asm_scan_ctvtot_7358525:
 sub sp,sp,#96
 stp d8,d9,[sp]
 stp d10,d11,[sp,#16]
 stp d12,d13,[sp,#32]
 stp d14,d15,[sp,#48]
 stp x18,x30,[sp,#64]
 bl md2asm_scan_ctvtot_body_7358525
 ldp d8,d9,[sp]
 ldp d10,d11,[sp,#16]
 ldp d12,d13,[sp,#32]
 ldp d14,d15,[sp,#48]
 ldp x18,x30,[sp,#64]
 add sp,sp,#96
 ret
.size md2asm_scan_ctvtot_7358525,.-md2asm_scan_ctvtot_7358525
.global md2asm_scan_gprcp_7358525
.type md2asm_scan_gprcp_7358525,%function
md2asm_scan_gprcp_7358525:
 mov x17,sp
 sub sp,sp,#160
 ldr x9,[x17,#0]
 str x9,[sp,#0]
 ldr x9,[x17,#8]
 str x9,[sp,#8]
 ldr x9,[x17,#16]
 str x9,[sp,#16]
 ldr x9,[x17,#24]
 str x9,[sp,#24]
 ldr x9,[x17,#32]
 str x9,[sp,#32]
 ldr x9,[x17,#40]
 str x9,[sp,#40]
 ldr x9,[x17,#48]
 str x9,[sp,#48]
 ldr x9,[x17,#56]
 str x9,[sp,#56]
 stp d8,d9,[sp,#64]
 stp d10,d11,[sp,#80]
 stp d12,d13,[sp,#96]
 stp d14,d15,[sp,#112]
 stp x18,x30,[sp,#128]
 bl md2asm_scan_gprcp_body_7358525
 ldp d8,d9,[sp,#64]
 ldp d10,d11,[sp,#80]
 ldp d12,d13,[sp,#96]
 ldp d14,d15,[sp,#112]
 ldp x18,x30,[sp,#128]
 add sp,sp,#160
 ret
.size md2asm_scan_gprcp_7358525,.-md2asm_scan_gprcp_7358525
.section .note.GNU-stack,"",%progbits
