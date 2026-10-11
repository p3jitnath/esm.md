// Complete solar cosine from formulations/openifs/physics/solar_zenith_angle.md.
// Every ordinary FP64 instruction has its own rounding.
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL md2asm_cos_sza
#endif
.text
.p2align 2
.global ORIGINAL_SYMBOL
.type ORIGINAL_SYMBOL,%function
ORIGINAL_SYMBOL:
 sub sp,sp,#384
 stp x29,x30,[sp,#0]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 stp d8,d9,[sp,#96]
 stp d10,d11,[sp,#112]
 stp d12,d13,[sp,#128]
 stp d14,d15,[sp,#144]
 mov x29,sp
 mov x28,sp
 stp x0,x1,[sp,#288]
 stp x2,x3,[sp,#304]
 stp x4,x5,[sp,#320]
 stp x6,x7,[sp,#336]
 ldp x9,x27,[sp,#384]
 str x9,[sp,#352]
 mrs x10,fpcr
 cbnz x10,.Lreject
 // Type and array addresses have eight-byte alignment.
 orr x10,x0,x1
 orr x10,x10,x2
 orr x10,x10,x6
 orr x10,x10,x7
 orr x10,x10,x27
 tst x10,#7
 b.ne .Lreject
 orr x10,x3,x4
 orr x10,x10,x5
 orr x10,x10,x9
 tst x10,#3
 b.ne .Lreject
 mov x21,x2
 mov x25,x6
 mov x26,x7
 ldrsw x22,[x3]
 ldrsw x23,[x4]
 ldrsw x24,[x5]
 cmp x24,#1
 b.lt .Lreject
 cmp x24,#4096
 b.gt .Lreject
 cmp x22,#1
 b.lt .Lreject
 add x10,x24,#1
 cmp x22,x10
 b.gt .Lreject
 cmp x23,#0
 b.lt .Lreject
 cmp x23,x24
 b.gt .Lreject
 sub x22,x22,#1
 sub x23,x23,#1
 ldr w10,[x9]
 cmp w10,#1
 b.hi .Lreject
 str w10,[x28,#164]
 ldr w11,[x0,#504]
 cmp w11,#1
 b.hi .Lreject
 str w11,[x28,#160]
 ldr w12,[x0,#500]
 cmp w12,#1
 b.hi .Lreject
 cbz w11,.Lcentred_ready
 cmp w12,#1
 b.ne .Lreject
.Lcentred_ready:
 // Check the complete output owner against each immutable owner.
 lsl x12,x24,#3
 add x13,x27,x12
 cmp x13,x27
 b.lo .Lreject
 mov x14,#0
 adr x15,.Lowner_sizes
.Lowner_loop:
 add x16,x28,#288
 ldr x17,[x16,x14,lsl #3]
 cbz x17,.Lreject
 cmp x14,#6
 b.eq .Larray_size
 cmp x14,#7
 b.eq .Larray_size
 ldr w16,[x15,x14,lsl #2]
 b .Lsize_ready
.Larray_size:
 mov x16,x12
.Lsize_ready:
 add x16,x17,x16
 cmp x16,x17
 b.lo .Lreject
 cmp x27,x16
 b.hs .Lowner_next
 cmp x17,x13
 b.lo .Lreject
.Lowner_next:
 add x14,x14,#1
 cmp x14,#9
 b.lt .Lowner_loop
 // Only the selected solar state supplies its numerical values.
 cbz w10,.Lmodel_state
 ldp d9,d8,[x1,#0]
 ldr d10,[x1,#40]
 b .Lstate_ready
.Lmodel_state:
 ldp d9,d8,[x21,#104]
 ldr d10,[x21,#88]
.Lstate_ready:
 fmov d0,#1.0
 fabs d1,d8
 fcmp d1,d0
 b.hi .Lreject
 fcmp d9,#0.0
 b.lt .Lreject
 fcmp d9,d0
 b.hi .Lreject
 fmul d1,d8,d8
 fmul d2,d9,d9
 fadd d1,d1,d2
 fsub d1,d1,d0
 fabs d1,d1
 adr x9,.Lnorm_eps
 ldr d2,[x9]
 fcmp d1,d2
 b.hi .Lreject
 // The phase range covers a complete cycle and its equation-of-time edge.
 adr x9,.Lphase_low
 ldr d0,[x9]
 fcmp d10,d0
 b.lt .Lreject
 adr x9,.Lphase_high
 ldr d0,[x9]
 fcmp d10,d0
 b.hi .Lreject
 fcmp d10,d10
 b.vs .Lreject
 // Reserve a private owner so admission precedes caller writes.
 lsl x9,x24,#3
 add x9,x9,#15
 and x9,x9,#-16
 sub sp,sp,x9
 mov x20,sp
 ldr w9,[x28,#160]
 cbz w9,.Lmidpoint_header
 // Freeze the daily constants consumed by the averaged method.
 adrp x9,:got:__yomcst_MOD_rpi
 ldr x9,[x9,:got_lo12:__yomcst_MOD_rpi]
 ldr x10,[x9]
 adr x11,.Lpi
 ldr x12,[x11]
 cmp x10,x12
 b.ne .Lreject
 adrp x9,:got:__yomcst_MOD_rday
 ldr x9,[x9,:got_lo12:__yomcst_MOD_rday]
 ldr x10,[x9]
 adr x11,.Lday
 ldr x12,[x11]
 cmp x10,x12
 b.ne .Lreject
 ldr d11,[x21,#200]
 fcmp d11,#0.0
 b.le .Lreject
 fcmp d11,d11
 b.vs .Lreject
 ldr w9,[x28,#164]
 cbz w9,.Lfrequency_ready
 ldr x9,[x28,#288]
 ldr w9,[x9,#12]
 cmp w9,#1
 b.lt .Lreject
 scvtf d0,w9
 fmul d11,d11,d0
.Lfrequency_ready:
 adr x9,.Lpi
 ldr d0,[x9]
 fmul d11,d11,d0
 adr x9,.Lday
 ldr d0,[x9]
 fdiv d11,d11,d0
 fcmp d11,#0.0
 b.le .Lreject
 adr x9,.Lhalf_pi
 ldr d0,[x9]
 fcmp d11,d0
 b.hi .Lreject
 fsub d0,d10,d11
 str d0,[x28,#184]
 fadd d0,d10,d11
 str d0,[x28,#192]
 adr x9,.Lprotected_denominator
 ldr d0,[x9]
 fmax d0,d9,d0
 fdiv d0,d8,d0
 str d0,[x28,#176]
 b .Lstart
.Lmidpoint_header:
 fmov d0,d10
 bl md2asm_cos_original_rounding
 str d0,[x28,#208]
 fmov d0,d10
 bl md2asm_sin_original_rounding
 str d0,[x28,#216]
.Lstart:
 mov x19,x22
 cmp x19,x23
 b.gt .Lcommit
.Lcolumn:
 ldr d0,[x25,x19,lsl #3]
 fmov d1,#1.0
 fabs d2,d0
 fcmp d2,d1
 b.hi .Lreject
 ldr d2,[x26,x19,lsl #3]
 fcmp d2,#0.0
 b.lt .Lreject
 adr x9,.Ltwo_pi
 ldr d3,[x9]
 fcmp d2,d3
 b.hi .Lreject
 fcmp d2,d2
 b.vs .Lreject
 fmul d3,d0,d0
 fsub d3,d1,d3
 fsqrt d12,d3
 fmul d13,d8,d0
 fmul d14,d9,d12
 ldr w9,[x28,#160]
 cbz w9,.Lmidpoint
 ldr d1,[x28,#176]
 fneg d1,d1
 fmul d1,d1,d0
 adr x9,.Lprotected_denominator
 ldr d3,[x9]
 fmax d3,d12,d3
 fdiv d0,d1,d3
 fmov d1,#1.0
 fcmp d0,d1
 b.gt .Lzero
 // Construct both original hour angles before sunrise clipping.
 fadd d1,d10,d2
 adr x9,.Ltwo_pi
 ldr d3,[x9]
 fcmp d1,d3
 adr x9,.Lpi
 ldr d3,[x9]
 b.lt .Loffset_ready
 adr x9,.Lthree_pi
 ldr d3,[x9]
.Loffset_ready:
 ldr d1,[x28,#184]
 fadd d1,d1,d2
 fsub d1,d1,d3
 str d1,[x28,#224]
 ldr d1,[x28,#192]
 fadd d1,d1,d2
 fsub d1,d1,d3
 str d1,[x28,#232]
 fmov d1,#-1.0
 fcmp d0,d1
 b.lt .Lintegration
 bl md2asm_acos_original_rounding
 fmov d15,d0
 // No adjacent illuminated interval may be silently omitted.
 fcmp d13,#0.0
 b.ne .Lperiod_admission
 fcmp d14,#0.0
 b.eq .Lperiod_ready
.Lperiod_admission:
 adr x9,.Ltwo_pi
 ldr d2,[x9]
 fsub d0,d15,d2
 ldr d1,[x28,#224]
 fcmp d1,d0
 b.lt .Lreject
 fsub d0,d2,d15
 ldr d1,[x28,#232]
 fcmp d1,d0
 b.gt .Lreject
.Lperiod_ready:
 fneg d2,d15
 ldr d0,[x28,#232]
 fcmp d0,d2
 b.le .Lzero
 ldr d1,[x28,#224]
 fcmp d1,d15
 b.ge .Lzero
 fmin d1,d1,d15
 fmax d1,d2,d1
 str d1,[x28,#224]
 fmin d0,d0,d15
 fmax d0,d2,d0
 str d0,[x28,#232]
.Lintegration:
 ldr d0,[x28,#232]
 ldr d1,[x28,#224]
 fsub d15,d0,d1
 ldr w9,[x28,#164]
 cbz w9,.Lsine_integrals
 adr x9,.Ltiny_interval
 ldr d2,[x9]
 fcmp d15,d2
 b.le .Lzero
.Lsine_integrals:
 bl md2asm_sin_original_rounding
 str d0,[x28,#240]
 ldr d0,[x28,#224]
 bl md2asm_sin_original_rounding
 ldr d1,[x28,#240]
 fsub d0,d1,d0
 fmul d0,d14,d0
 ldr w9,[x28,#164]
 cbz w9,.Lmodel_integral
 fdiv d0,d0,d15
 fadd d0,d13,d0
 b .Lclip_result
.Lmodel_integral:
 fmul d1,d13,d15
 fadd d0,d1,d0
 fadd d1,d11,d11
 fdiv d0,d0,d1
.Lclip_result:
 fcmp d0,#0.0
 b.lt .Lzero
 b .Lstore_private
.Lmidpoint:
 ldr d15,[x26,x19,lsl #3]
 fmov d0,d15
 bl md2asm_cos_original_rounding
 ldr d1,[x28,#208]
 fmul d1,d9,d1
 fmul d1,d1,d12
 fmul d1,d1,d0
 str d1,[x28,#240]
 fmov d0,d15
 bl md2asm_sin_original_rounding
 ldr d1,[x28,#216]
 fmul d1,d9,d1
 fmul d1,d1,d12
 fmul d1,d1,d0
 ldr d0,[x28,#240]
 fsub d0,d13,d0
 fadd d0,d0,d1
 fmov d1,xzr
 fmax d0,d1,d0
 b .Lstore_private
.Lzero:
 fmov d0,xzr
.Lstore_private:
 str d0,[x20,x19,lsl #3]
 add x19,x19,#1
 cmp x19,x23
 b.le .Lcolumn
.Lcommit:
 mov x19,x22
 cmp x19,x23
 b.gt .Lreturn
.Lcopy:
 ldr d0,[x20,x19,lsl #3]
 str d0,[x27,x19,lsl #3]
 add x19,x19,#1
 cmp x19,x23
 b.le .Lcopy
.Lreturn:
 mov sp,x28
 ldp d8,d9,[sp,#96]
 ldp d10,d11,[sp,#112]
 ldp d12,d13,[sp,#128]
 ldp d14,d15,[sp,#144]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp,#0]
 add sp,sp,#384
 ret
.Lreject:
 mov sp,x28
 bl abort
 brk #0
.size ORIGINAL_SYMBOL,.-ORIGINAL_SYMBOL
.section .rodata
.p2align 3
.Lowner_sizes: .word 2040,48,175976,4,4,4,0,0,4
.p2align 3
.Lpi: .quad 0x400921fb54442d18
.Ltwo_pi: .quad 0x401921fb54442d18
.Lthree_pi: .quad 0x4022d97c7f3321d2
.Lhalf_pi: .quad 0x3ff921fb54442d18
.Lphase_low: .quad 0xbff921fb54442d18
.Lphase_high: .quad 0x401f6a7a2955385e
.Lday: .quad 0x40f5180000000000
.Lnorm_eps: .quad 0x3d00000000000000
.Lprotected_denominator: .quad 0x3d719799812dea11
.Ltiny_interval: .quad 0x3e45798ee2308c3a
.section .note.GNU-stack,"",%progbits
