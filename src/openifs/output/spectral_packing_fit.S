#ifdef MD2ASM_RUNTIME_SPECTRAL_FIT
#define md2asm_fitspectrum_original_rounding md2asm_fitspectrum_runtime_rounding
#define __fitspectrum_mod_MOD_fitspectrum md2asm_runtime_fitspectrum_interface
#define md2asm_fitspectrum_direct_calls md2asm_runtime_fitspectrum_direct_calls
#endif
/* Spectral packing fit, revision 1.
 * Contract: skills/md2asm/references/openifs/output/spectral_packing_fit.md.
 * The six pointer arguments use x0 through x5. Default controls are 21, 506, 10.
 * Select MD2ASM_RUNTIME_SPECTRAL_FIT for N1 through4096 and live subset/count.
 * The read-only spectral array holds (N+1)(N+2) finite FP64 values.
 * Store the distinct slope output before the intercept output.
 * The default frame is576bytes. The selected frame is256+16(N+1)bytes.
 * Both have16-byte alignment. Preserve x18, saved GPRs,
 * required vector halves, FPCR and errno. Keep cumulative FPSR flags.
 * The only numerical child is the direct positive-normal LOG leaf.
 * Source: original ifsaux/module/fitspectrum_mod.F90 ordered arithmetic.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_fitspectrum_original_rounding
.global __fitspectrum_mod_MOD_fitspectrum
.hidden md2asm_log_positive_normal
.type md2asm_fitspectrum_original_rounding,%function
.type __fitspectrum_mod_MOD_fitspectrum,%function
md2asm_fitspectrum_original_rounding:
__fitspectrum_mod_MOD_fitspectrum:
 mrs x9,fpcr
 cbnz x9,.Lreject
 cbz x0,.Lreject
 cbz x1,.Lreject
 cbz x2,.Lreject
 cbz x3,.Lreject
 cbz x4,.Lreject
 cbz x5,.Lreject
 orr x9,x0,x1
 orr x9,x9,x3
 tst x9,#3
 b.ne .Lreject
 orr x9,x2,x4
 orr x9,x9,x5
 tst x9,#7
 b.ne .Lreject
#ifdef MD2ASM_RUNTIME_SPECTRAL_FIT
 ldr w9,[x0]
 sub w10,w9,#1
 cmp w10,#4095
 b.hi .Lreject
 add x11,x9,#1
 add x12,x9,#2
 mul x11,x11,x12
 ldr w12,[x1]
 cmp x12,x11
 b.ne .Lreject
 ldr w12,[x3]
 cmp w12,w9
 b.hs .Lreject
 adds x10,x2,x11,lsl#3
#else
 ldr w9,[x0]
 cmp w9,#21
 b.ne .Lreject
 ldr w9,[x1]
 cmp w9,#506
 b.ne .Lreject
 ldr w9,[x3]
 cmp w9,#10
 b.ne .Lreject
 adds x10,x2,#4048
#endif
 b.cs .Lreject
 adds x9,x4,#8
 b.cs .Lreject
 adds x9,x5,#8
 b.cs .Lreject
 cmp x4,x5
 b.eq .Lreject
 cmp x4,x2
 b.lo .Lcheck_second_output
 cmp x4,x10
 b.lo .Lreject
.Lcheck_second_output:
 cmp x5,x2
 b.lo .Lfinite_scan
 cmp x5,x10
 b.lo .Lreject
.Lfinite_scan:
 mov x9,x2
#ifdef MD2ASM_RUNTIME_SPECTRAL_FIT
 ldr w10,[x1]
#else
 mov x10,#506
#endif
 movz x13,#0x7ff0,lsl#48
.Lfinite:
 ldr x11,[x9],#8
 and x12,x11,#0x7ff0000000000000
 cmp x12,x13
 b.eq .Lreject
 subs x10,x10,#1
 b.ne .Lfinite
#ifdef MD2ASM_RUNTIME_SPECTRAL_FIT
 ldr w9,[x0]
 add x9,x9,#1
 lsl x16,x9,#4
 add x16,x16,#271
 and x16,x16,#-16
 sub sp,sp,x16
#else
 sub sp,sp,#576
#endif
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 stp x0,x1,[sp,#112]
 stp x2,x3,[sp,#128]
 stp x4,x5,[sp,#144]
 stp d8,d9,[sp,#160]
 stp d10,d11,[sp,#176]
 stp d12,d13,[sp,#192]
 stp d14,d15,[sp,#208]
#ifdef MD2ASM_RUNTIME_SPECTRAL_FIT
 str x16,[sp,#224]
 ldr w28,[x0]
 add x28,x28,#1
 ldr w27,[x3]
#endif
 adrp x9,md2asm_fitspectrum_direct_calls
 add x9,x9,:lo12:md2asm_fitspectrum_direct_calls
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
 mov x19,x2
#ifdef MD2ASM_RUNTIME_SPECTRAL_FIT
 add x23,sp,#256
 add x24,x23,x28,lsl#3
 add x22,x27,#1
#else
 add x23,sp,#224
 add x24,sp,#400
 mov x22,#11
#endif
.Lweights:
#ifdef MD2ASM_RUNTIME_SPECTRAL_FIT
 sub x9,x28,#1
 sub x9,x9,x27
 scvtf d1,x9
 sub x10,x22,x27
#else
 fmov d1,#11.0
 sub x10,x22,#10
#endif
 scvtf d0,x10
 fdiv d0,d1,d0
 str d0,[x23,x22,lsl#3]
 str xzr,[x24,x22,lsl#3]
 add x22,x22,#1
#ifdef MD2ASM_RUNTIME_SPECTRAL_FIT
 cmp x22,x28
#else
 cmp x22,#22
#endif
 b.ne .Lweights
 mov x20,#0
.Lm:
#ifdef MD2ASM_RUNTIME_SPECTRAL_FIT
 lsl x9,x28,#1
 add x9,x9,#1
 sub x9,x9,x20
#else
 mov x9,#45
 sub x9,x9,x20
#endif
 mul x25,x20,x9
 mov x21,#0
#ifdef MD2ASM_RUNTIME_SPECTRAL_FIT
 add x9,x27,#1
#else
 mov x9,#11
#endif
 cmp x20,x9
 csel x26,x20,x9,ge
.Lcomponent:
 mov x22,x26
.Lnorm:
 sub x9,x22,x20
 add x9,x25,x9,lsl#1
 add x9,x9,x21
 ldr d0,[x19,x9,lsl#3]
 fabs d0,d0
 ldr d1,[x24,x22,lsl#3]
 fmax d1,d1,d0
 str d1,[x24,x22,lsl#3]
 add x22,x22,#1
#ifdef MD2ASM_RUNTIME_SPECTRAL_FIT
 cmp x22,x28
#else
 cmp x22,#22
#endif
 b.ne .Lnorm
 cbz x20,.Lnext_m
 add x21,x21,#1
 cmp x21,#2
 b.ne .Lcomponent
.Lnext_m:
 add x20,x20,#1
#ifdef MD2ASM_RUNTIME_SPECTRAL_FIT
 cmp x20,x28
#else
 cmp x20,#22
#endif
 b.ne .Lm
 movz x9,#0x3cb0,lsl#48
 fmov d1,x9
 movz x10,#0x3d19,lsl#48
#ifdef MD2ASM_RUNTIME_SPECTRAL_FIT
 add x22,x27,#1
#else
 mov x22,#11
#endif
.Lfloor:
 ldr d0,[x24,x22,lsl#3]
 fmax d0,d0,d1
 str d0,[x24,x22,lsl#3]
 fcmp d0,d1
 b.ne .Lnext_floor
 str x10,[x23,x22,lsl#3]
.Lnext_floor:
 add x22,x22,#1
#ifdef MD2ASM_RUNTIME_SPECTRAL_FIT
 cmp x22,x28
#else
 cmp x22,#22
#endif
 b.ne .Lfloor
 fmov d8,xzr
 fmov d9,xzr
 fmov d10,xzr
#ifdef MD2ASM_RUNTIME_SPECTRAL_FIT
 add x22,x27,#1
#else
 mov x22,#11
#endif
.Lmeans:
 ldr d11,[x23,x22,lsl#3]
 add x9,x22,#1
 mul x9,x22,x9
 scvtf d0,x9
 bl md2asm_log_positive_normal
 fmov d12,d0
 ldr d0,[x24,x22,lsl#3]
 bl md2asm_log_positive_normal
 fmov d13,d0
 fmul d0,d12,d11
 fadd d8,d8,d0
 fmul d0,d13,d11
 fadd d9,d9,d0
 fadd d10,d10,d11
 add x22,x22,#1
#ifdef MD2ASM_RUNTIME_SPECTRAL_FIT
 cmp x22,x28
#else
 cmp x22,#22
#endif
 b.ne .Lmeans
 fdiv d14,d8,d10
 fdiv d15,d9,d10
 fmov d8,xzr
 fmov d9,xzr
#ifdef MD2ASM_RUNTIME_SPECTRAL_FIT
 add x22,x27,#1
#else
 mov x22,#11
#endif
.Lfit:
 ldr d11,[x23,x22,lsl#3]
 add x9,x22,#1
 mul x9,x22,x9
 scvtf d0,x9
 bl md2asm_log_positive_normal
 fmov d12,d0
 ldr d0,[x24,x22,lsl#3]
 bl md2asm_log_positive_normal
 fmov d13,d0
 fsub d13,d13,d15
 fsub d12,d12,d14
 fmul d0,d11,d13
 fmul d0,d0,d12
 fadd d8,d8,d0
 fmul d0,d12,d12
 fmul d0,d11,d0
 fadd d9,d9,d0
 add x22,x22,#1
#ifdef MD2ASM_RUNTIME_SPECTRAL_FIT
 cmp x22,x28
#else
 cmp x22,#22
#endif
 b.ne .Lfit
 fdiv d1,d8,d9
 ldr x9,[sp,#152]
 str d1,[x9]
 fmul d0,d1,d14
 fsub d0,d15,d0
 ldr x9,[sp,#144]
 str d0,[x9]
#ifdef MD2ASM_RUNTIME_SPECTRAL_FIT
 ldr x16,[sp,#224]
#endif
 ldp d8,d9,[sp,#160]
 ldp d10,d11,[sp,#176]
 ldp d12,d13,[sp,#192]
 ldp d14,d15,[sp,#208]
 ldr x18,[sp,#96]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp]
#ifdef MD2ASM_RUNTIME_SPECTRAL_FIT
 add sp,sp,x16
#else
 add sp,sp,#576
#endif
 ret
.Lreject:
 mov x0,#116
 mov x8,#94
 svc #0
 brk #0
.size md2asm_fitspectrum_original_rounding,.-md2asm_fitspectrum_original_rounding
.size __fitspectrum_mod_MOD_fitspectrum,.-__fitspectrum_mod_MOD_fitspectrum
.data
.p2align 3
.hidden md2asm_fitspectrum_direct_calls
.global md2asm_fitspectrum_direct_calls
.type md2asm_fitspectrum_direct_calls,%object
md2asm_fitspectrum_direct_calls:
 .quad 0
.size md2asm_fitspectrum_direct_calls,8
.section .note.GNU-stack,"",%progbits
