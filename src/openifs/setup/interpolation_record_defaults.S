// Source declaration defaults from EINT_MOD.SL_STRUCT.
// x0 is live MODEL, x1 is its capacity. The selected incoming SL record is fresh zero storage.
.arch armv8.2-a+simd
.text
.p2align 4
.global md2asm_initialize_interpolation_record_defaults
.type md2asm_initialize_interpolation_record_defaults,%function
md2asm_initialize_interpolation_record_defaults:
 cbz x0,.Lrefuse
 tst x0,#7
 b.ne .Lrefuse
 movz x9,#(4275088 & 65535)
 movk x9,#(4275088 >> 16),lsl#16
 cmp x1,x9
 b.lo .Lrefuse
 adds x10,x0,x9
 b.cs .Lrefuse
 movz x9,#(1573768 & 65535)
 movk x9,#(1573768 >> 16),lsl#16
 add x10,x0,x9
 mov x11,x10
 mov x12,#225
.Lfresh_record:
 ldr x13,[x11],#8
 cbnz x13,.Lrefuse
 subs x12,x12,#1
 b.ne .Lfresh_record
 // All zero and unallocated declarations retain their verified incoming zero bytes.
 mov w9,#0x5858
 strh w9,[x10]
 movz w9,#(999999 & 65535)
 movk w9,#(999999 >> 16),lsl#16
 str w9,[x10,#1040]
 // The FP64 representation is 999999.0. This uses no FP calculation or status write.
 movz x9,#0x847e,lsl#32
 movk x9,#0x412e,lsl#48
 str x9,[x10,#1048]
 mov w0,wzr
 ret
.Lrefuse:
 mov w0,#2
 ret
.size md2asm_initialize_interpolation_record_defaults,.-md2asm_initialize_interpolation_record_defaults
.section .note.GNU-stack,"",%progbits
