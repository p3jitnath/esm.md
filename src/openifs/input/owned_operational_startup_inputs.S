/* Contract: skills/md2asm/references/openifs/input/owned_operational_startup_inputs.md.
 * Direct AArch64 ownership of live files and the completed vertical state. */
.arch armv8.2-a
.equ I_BYTES,9968
.equ I_HEADERS,120
.equ I_CONSTANTS,9448
.text
.macro I_ENTER
 sub sp,sp,#160
 stp x29,x30,[sp]
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 stp x22,x23,[sp,#48]
 stp x24,x25,[sp,#64]
 stp x26,x27,[sp,#80]
 str x28,[sp,#96]
 mov x29,sp
.endm
.macro I_LEAVE
 ldr x28,[sp,#96]
 ldp x26,x27,[sp,#80]
 ldp x24,x25,[sp,#64]
 ldp x22,x23,[sp,#48]
 ldp x20,x21,[sp,#32]
 ldp x18,x19,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#160
 ret
.endm
.p2align 4
.global md2asm_create_operational_startup_inputs
.type md2asm_create_operational_startup_inputs,%function
md2asm_create_operational_startup_inputs:
 I_ENTER
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x25,x3
 mov x22,xzr
 mov w23,#2
 mrs x9,fpcr
 cbnz x9,.Linputs_return
 cbz x25,.Linputs_return
 tst x25,#7
 b.ne .Linputs_return
 adds x12,x25,#8
 b.cs .Linputs_return
 ldr x9,[x25]
 cbnz x9,.Linputs_return
 mov x13,#0
.Linputs_path_select:
 cmp x13,#0
 csel x10,x19,x20,eq
 cmp x13,#2
 csel x10,x21,x10,eq
 cbz x10,.Linputs_return
 mov x11,#0
.Linputs_path_scan:
 adds x14,x10,x11
 b.cs .Linputs_return
 ldrb w9,[x14]
 cbz w9,.Linputs_path_end
 add x11,x11,#1
 cmp x11,#4096
 b.lo .Linputs_path_scan
 b .Linputs_return
.Linputs_path_end:
 cbz x11,.Linputs_return
 adds x14,x14,#1
 b.cs .Linputs_return
 cmp x10,x12
 b.hs .Linputs_path_next
 cmp x25,x14
 b.lo .Linputs_return
.Linputs_path_next:
 add x13,x13,#1
 cmp x13,#3
 b.lo .Linputs_path_select
 mov x0,#1
 mov x1,#I_BYTES
 bl calloc
 mov w23,#1
 cbz x0,.Linputs_return
 mov x22,x0
 mov x0,#1
 movk x0,#4,lsl#16
 bl malloc
 cbz x0,.Linputs_cleanup
 str x0,[x22,#16]
 mov x1,x0
 mov x0,x21
 bl .Linputs_read_text
 mov w23,#3
 cbnz w0,.Linputs_cleanup
 str x1,[x22,#24]
 mov x0,x19
 mov x1,x20
 add x2,x22,#I_HEADERS
 mov x3,#9328
 bl md2asm_read_initial_model_headers
 add w23,w0,#10
 cbnz w0,.Linputs_cleanup
 mov x9,#I_CONSTANTS
 add x0,x22,x9
 mov x1,#520
 bl md2asm_initialize_physical_constants
 add w23,w0,#10
 cbnz w0,.Linputs_cleanup
 /* Explicit selected source modes, with the decoded file layer count. */
 ldr w9,[x22,#I_HEADERS+16]
 mov w10,#1
 stp w9,w10,[sp,#112]
 stp wzr,wzr,[sp,#120]
 ldp x0,x1,[x22,#16]
 add x2,sp,#112
 add x3,x22,#48
 bl md2asm_parse_operational_vertical_configuration
 add w23,w0,#20
 cbnz w0,.Linputs_cleanup
 add x0,x22,#I_HEADERS+96
 add x1,x22,#I_HEADERS+2152
 add x2,x22,#8
 add x3,x22,#48
 bl md2asm_create_operational_vertical_startup_context
 add w23,w0,#30
 cbnz w0,.Linputs_cleanup
 ldr x0,[x22,#8]
 ldr x9,[x0,#20320]
 mov x10,#I_CONSTANTS
 ldr x10,[x22,x10]
 stp x9,x10,[x22,#72]
 add x9,x22,#88
 add x10,x22,#96
 stp x9,x10,[x22,#104]
 add x1,x22,#72
 add x2,x22,#104
 bl md2asm_initialize_operational_owned_vertical_system
 add w23,w0,#40
 cbnz w0,.Linputs_cleanup
 movz x9,#0x5431
 movk x9,#0x5055,lsl#16
 movk x9,#0x494e,lsl#32
 movk x9,#0x4f50,lsl#48
 str x9,[x22]
 str x22,[x25]
 mov w23,#0
 b .Linputs_return
.Linputs_cleanup:
 mov x0,x22
 bl .Linputs_destroy
.Linputs_return:
 mov w0,w23
 I_LEAVE
.size md2asm_create_operational_startup_inputs,.-md2asm_create_operational_startup_inputs
.p2align 4
.global md2asm_release_operational_startup_inputs
.type md2asm_release_operational_startup_inputs,%function
md2asm_release_operational_startup_inputs:
 cbz x0,.Linputs_release_null
 tst x0,#7
 b.ne .Linputs_release_bad
 ldr x9,[x0]
 movz x10,#0x5431
 movk x10,#0x5055,lsl#16
 movk x10,#0x494e,lsl#32
 movk x10,#0x4f50,lsl#48
 cmp x9,x10
 b.ne .Linputs_release_bad
 str xzr,[x0]
 b .Linputs_destroy
.Linputs_release_bad:
 mov w0,#2
 ret
.Linputs_release_null:
 mov w0,#0
 ret
.size md2asm_release_operational_startup_inputs,.-md2asm_release_operational_startup_inputs
/* Internal partial-owner cleanup. No borrowed owner can outlive this call. */
.Linputs_destroy:
 stp x29,x30,[sp,#-32]!
 stp x19,x20,[sp,#16]
 mov x29,sp
 mov x19,x0
 ldr x0,[x19,#8]
 cbz x0,.Linputs_destroy_text
 bl md2asm_release_operational_vertical_startup_context
.Linputs_destroy_text:
 ldr x0,[x19,#16]
 bl free
 mov x0,x19
 bl free
 mov w0,#0
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#32
 ret
/* x0 path,x1 mapped262145-byte buffer; return0/3 and actual length in x1. */
.Linputs_read_text:
 stp x29,x30,[sp,#-64]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 str x23,[sp,#48]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 mov x21,#1
 movk x21,#4,lsl#16
 mov x22,xzr
.Linputs_open:
 mov x0,#-100
 mov x1,x19
 mov x2,#0
 mov x3,#0
 mov x8,#56
 svc #0
 cmn x0,#4
 b.eq .Linputs_open
 tbnz x0,#63,.Linputs_text_bad
 mov x23,x0
.Linputs_read:
 mov x0,x23
 add x1,x20,x22
 sub x2,x21,x22
 mov x8,#63
 svc #0
 cmn x0,#4
 b.eq .Linputs_read
 tbnz x0,#63,.Linputs_read_bad
 cbz x0,.Linputs_eof
 add x22,x22,x0
 cmp x22,x21
 b.hs .Linputs_read_bad
 b .Linputs_read
.Linputs_eof:
 cbz x22,.Linputs_read_bad
 mov x0,x23
 mov x8,#57
 svc #0
 cbnz x0,.Linputs_text_bad
 mov x1,x22
 mov w0,#0
 b .Linputs_text_return
.Linputs_read_bad:
 mov x0,x23
 mov x8,#57
 svc #0
.Linputs_text_bad:
 mov w0,#3
.Linputs_text_return:
 ldr x23,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#64
 ret
.section .note.GNU-stack,"",%progbits
