/* Contract: skills/md2asm/references/openifs/radiation/shortwave_absorption_setup.md.
 * x0 zero-terminated path, x1 bytes excluding terminator, x2 output, x3 capacity.
 * Linux file services load only the original coefficient file; no stored model state. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_read_shortwave_absorption_file
.type md2asm_read_shortwave_absorption_file,%function
md2asm_read_shortwave_absorption_file:
 cbz x0,.Lfile_bad_leaf
 cbz x2,.Lfile_bad_leaf
 tst x2,#7
 b.ne .Lfile_bad_leaf
 cbz x1,.Lfile_bad_leaf
 cmp x1,#4095
 b.hi .Lfile_bad_leaf
 adds x4,x0,x1
 b.cs .Lfile_bad_leaf
 adds x4,x4,#1
 b.cs .Lfile_bad_leaf
 movz x5,#(4059736 & 65535)
 movk x5,#(4059736 >> 16),lsl#16
 cmp x3,x5
 b.lo .Lfile_bad_leaf
 adds x6,x2,x5
 b.cs .Lfile_bad_leaf
 cmp x0,x6
 b.hs .Lfile_disjoint
 cmp x2,x4
 b.lo .Lfile_bad_leaf
.Lfile_disjoint:
 mov x4,#0
.Lpath_scan:
 ldrb w5,[x0,x4]
 cbz w5,.Lfile_bad_leaf
 add x4,x4,#1
 cmp x4,x1
 b.lo .Lpath_scan
 ldrb w5,[x0,x1]
 cbnz w5,.Lfile_bad_leaf
 sub sp,sp,#128
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#112]
 mov x29,sp
 mov x19,x0
 mov x20,x2
 mov x21,x3
 mov x22,#0
 mov x23,#-1
 mov w26,#1
 mov x0,#-100
 mov x1,x19
 mov x2,#0
 mov x3,#0
 mov x8,#56
 svc #0
 cmp x0,#0
 b.lt .Lfile_cleanup
 mov x23,x0
 mov x0,#0
 movz x1,#(1332592 & 65535)
 movk x1,#(1332592 >> 16),lsl#16
 mov x2,#3
 mov x3,#0x22
 mov x4,#-1
 mov x5,#0
 mov x8,#222
 svc #0
 cmn x0,#4095
 b.hs .Lfile_cleanup
 mov x22,x0
 movz x24,#(1332585 & 65535)
 movk x24,#(1332585 >> 16),lsl#16
 mov x25,x22
.Lfile_read:
 mov x0,x23
 mov x1,x25
 mov x2,x24
 mov x8,#63
 svc #0
 cmp x0,#0
 b.lt .Lfile_cleanup
 b.eq .Lfile_eof
 add x25,x25,x0
 subs x24,x24,x0
 b.ne .Lfile_read
 mov w26,#2
 b .Lfile_cleanup
.Lfile_eof:
 cmp x24,#1
 b.eq .Lfile_decode
 mov w26,#2
 b .Lfile_cleanup
.Lfile_decode:
 mov x0,x23
 mov x8,#57
 svc #0
 mov x23,#-1
 mov x0,x22
 movz x1,#(1332584 & 65535)
 movk x1,#(1332584 >> 16),lsl#16
 mov x2,x20
 mov x3,x21
 mov w4,#0
 bl md2asm_initialize_shortwave_absorption
 mov w26,w0
.Lfile_cleanup:
 cmp x23,#0
 b.lt .Lfile_unmap
 mov x0,x23
 mov x8,#57
 svc #0
.Lfile_unmap:
 cbz x22,.Lfile_return
 mov x0,x22
 movz x1,#(1332592 & 65535)
 movk x1,#(1332592 >> 16),lsl#16
 mov x8,#215
 svc #0
.Lfile_return:
 mov w0,w26
 ldr x18,[sp,#112]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp]
 add sp,sp,#128
 ret
.Lfile_bad_leaf:
 mov w0,#2
 ret
.size md2asm_read_shortwave_absorption_file,.-md2asm_read_shortwave_absorption_file
.section .note.GNU-stack,"",%progbits
