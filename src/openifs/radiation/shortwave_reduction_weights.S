/* Selected source-ordered SRTM_INIT weight table.
   Contract: skills/md2asm/references/openifs/radiation/shortwave_absorption_setup.md. */
.text
.p2align 4
.global md2asm_shortwave_absorption_weights
.hidden md2asm_shortwave_absorption_weights
.type md2asm_shortwave_absorption_weights,%function
md2asm_shortwave_absorption_weights:
 movz x1,#(4055784 & 65535)
 movk x1,#(4055784 >> 16),lsl #16
 add x1,x0,x1
 movz x2,#(4057944 & 65535)
 movk x2,#(4057944 >> 16),lsl #16
 add x2,x0,x2
 movz x3,#(4055896 & 65535)
 movk x3,#(4055896 >> 16),lsl #16
 add x3,x0,x3
 add x4,x3,#128
 add x5,x4,#128
 mov x6,#0
.Lsw_weight_band:
 ldr w12,[x1,x6,lsl #2]
 mov x7,#0
 mov x8,#0
.Lsw_weight_group:
 ldr w9,[x2],#4
 mov x10,x8
 fmov d0,xzr
.Lsw_weight_sum:
 ldr d1,[x3,x10,lsl #3]
 fadd d0,d0,d1
 add x10,x10,#1
 subs w9,w9,#1
 b.ne .Lsw_weight_sum
 str d0,[x4,x7,lsl #3]
.Lsw_weight_div:
 ldr d1,[x3,x8,lsl #3]
 fdiv d1,d1,d0
 str d1,[x5],#8
 add x8,x8,#1
 cmp x8,x10
 b.lo .Lsw_weight_div
 add x7,x7,#1
 cmp x7,x12
 b.lo .Lsw_weight_group
 add x6,x6,#1
 cmp x6,#14
 b.lo .Lsw_weight_band
 ret
.size md2asm_shortwave_absorption_weights,.-md2asm_shortwave_absorption_weights
.section .note.GNU-stack,"",%progbits
